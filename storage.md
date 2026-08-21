# Storage Plan: from YAML truth source to a queryable flat artifact

## Context and goal

Historically, `models.RDS` was produced by R code on `main` and served as the
data surface users downloaded in order to install models. We are replacing that
entire approach. The YAML under `publications/` remains the single source of
truth, but we now need a compiled, queryable artifact that:

- lets users *and* other processes query models without loading the whole corpus
  into memory,
- is still small enough to live in this repository and be rebuilt by an action
  (as `models.RDS` once was),
- can be produced deterministically from the YAML.

Two candidate formats are under consideration: **DuckDB** and **Parquet**. This
document lays out the translation layer that turns the (still-in-flux) YAML
schema into one of those formats. It deliberately makes the format choice late:
the pipeline, the intermediate records, and the schema are format-agnostic so we
can pick DuckDB or Parquet (or both) without reworking the translation layer.

## Where the gap is

`orc` already walks `publications/`, validates each file against the pydantic
schema, assigns a content hash id, and flattens each file to a
`RegistryRecord` (one row per model) that can be dumped as JSONL. That is a good
foundation, but it is **not yet a complete storage layer**. Three things are
missing before DuckDB/Parquet can be emitted:

1. **`fixed_effects_set` is not flattened.** Today a set is collapsed into a
   single record with `parameter_names` taken from its first specification row.
   Its actual per-spec rows (parameters + per-row `taxa`/`region`/`component`/
   `descriptors`) are dropped. A queryable table wants one row per spec.

2. **Publication metadata is not carried through.** `RegistryRecord` keeps only
   `pub_id` and `pub_year`; the BibTeX fields (title, author, journal, doi, ...)
   live only on the `Publication` model and are lost in the flat output.

3. **There is no writer.** `orc` currently stops at JSONL. There is no function
   that materializes DuckDB or Parquet files, and no GitHub action wired up to
   rebuild them.

## Design

### Two logical layers

Keep the translation in two distinct layers so the format decision stays cheap:

- **Layer A — canonical tabular records** (format-agnostic). Define the set of
  flat, typed records that fully describe the corpus. This is the contract.
- **Layer B — physical writers** (format-specific). One writer per target format
  that consumes the records from Layer A. Adding or swapping a format only
  touches Layer B.

### Layer A: the canonical records

Three related tables (all derived from `ModelsFile` via `orc.ingest`):

#### `models` — one row per model *set* (or single model)

Carries everything shared by a `fixed_effects` model or by all specs in a
`fixed_effects_set`:

| field | type | notes |
|---|---|---|
| `id` | string | 8-char content hash (existing `model_id`) |
| `pub_id` | string | publication key |
| `model_name` | string | unique within file |
| `model_type` | enum | `fixed_effects` \| `fixed_effects_set` |
| `response_name` | string | |
| `response_units` | string | |
| `covariates` | list<struct> | `[{name, units}]` |
| `prediction_function` | string | |
| `covt_defs` | map | |
| `response_definition` | string | |
| `description` | string | |
| `notes` | string | |
| `model_taxa` | list<struct> | set-level taxa, if any |
| `model_region` | list<string> | set-level region |
| `model_component` | string | set-level component |
| `model_descriptors` | map | set-level descriptors |
| `source_file` | string | |

#### `model_specs` — one row per *parameterized spec*

For `fixed_effects` models there is exactly one row (its inline parameters). For
`fixed_effects_set` models there is one row per `specifications` entry, carrying
the spec's own parameters and scope. This is what makes the corpus truly
queryable row-by-row (e.g. "all Douglas-fir models") without dropping data.

| field | type | notes |
|---|---|---|
| `id` | string | FK → `models.id` |
| `spec_index` | int | 0 for single models; ordinal within set |
| `parameters` | map<string,float> | inline or per-spec parameters |
| `spec_taxa` | list<struct> | per-spec taxa (falls back to model taxa) |
| `spec_region` | list<string> | per-spec region (falls back to model region) |
| `spec_component` | string | per-spec component (falls back to model component) |
| `spec_descriptors` | map | per-spec descriptors |

Flattening rule: for a set, each spec row inherits the model-level fields from
`models`; `spec_taxa` is the spec's own `taxa` if present, else the model-level
`taxa`. The content hash id stays at the *set* granularity (it already hashes the
whole model including all specs), so `spec_index` disambiguates rows within a
set. This mirrors how `parameter_names` is currently derived but keeps the data
instead of discarding it.

#### `publications` — one row per publication

All BibTeX fields from `Publication` plus `key`. `models.pub_id` joins here. This
restores title/author/journal/doi/etc. to the query surface, which the current
JSONL drops.

### Nested vs. relational shape

Taxa, covariates, regions, descriptors, and parameters are all naturally nested
(e.g. a model may list several taxa). DuckDB and Parquet both support nested
types (`STRUCT`/`LIST`/`MAP`), so the canonical records above are written **as
nested columns** rather than being denormalized into wide strings. This:

- preserves the exact semantics of the YAML (no lossy string encoding),
- keeps queries on, say, `species` expressive (filter on a nested list),
- maps cleanly to the current R consumer, which already filters over list
  columns (`purrr::map_lgl(taxa, ...)`).

Do **not** pivot nested lists into comma-joined strings — that is the trap that
would make filtering (by species, author, region) awkward.

### Layer B: writers

Two writer modules under `orc/` (both consume Layer A records):

- `orc/parquet.py` — writes `models.parquet`, `model_specs.parquet`,
  `publications.parquet` via `pyarrow`.
- `orc/duckdb.py` — writes a `publications.duckdb` via `duckdb` with the three
  tables above (`CREATE TABLE ... AS SELECT`).

Both are thin: parse → validate → build Layer A records → write. A shared
`orc/records.py` holds the dataclasses and the flattening logic so the two
writers do not duplicate it.

## Rejected alternative: UnQLite

UnQLite (an embedded, transactional key/value + document store, single portable
file, BSD licensed) was considered. It is technically possible — we could store
each model as a JSON document and query it via its Jx9 scripting layer — but it
is a poor fit:

- **No ecosystem tooling for our consumers.** There is no mainstream binding in
  R (the `allometric` consumer is R) and no first-class Python wheel. It is a
  C/C++ library you must embed, unlike `duckdb`/`pyarrow`, which are `pip`
  installs.
- **Key/value + JSON docs, not queryable columns.** Records would live as JSON
  blobs queried with Jx9, a worse querying experience than DuckDB's SQL or
  Parquet's columnar reads — directly at odds with the "query models without
  loading everything" goal.
- **No relational joins.** Our data is naturally relational (`models` →
  `model_specs` → `publications`); UnQLite would require reimplementing joins in
  Jx9.
- **Low activity / last release old** (1.2.1) compared to the actively
  maintained DuckDB/Arrow ecosystems.

DuckDB already delivers UnQLite's one advantage (single embedded file, no
server) while also giving real SQL, native Parquet reading, and first-class
Python *and* R bindings. Parquet covers the open-format angle better still.
UnQLite is therefore rejected.

## Format decision: DuckDB vs Parquet

The two are not strictly either/or — DuckDB can query Parquet files directly —
but they differ in what they optimize:

| | Parquet | DuckDB |
|---|---|---|
| Querying | needs an engine (duckdb, polars, arrow, R `arrow`, ...) | bundled SQL engine |
| Shape | one file per table (or a partitioned set) | single file, multiple tables |
| Schema | nested types, columnar, strong | same nested types, plus SQL views |
| Versioning / diffing | file-per-table, appendable | single binary file (harder to diff) |
| Stored in git | compact, well-supported | fine, but less friendly to non-SQL tooling |
| Zero-dep read | R `arrow`, polars, pandas read it natively | R `duckdb`, python `duckdb` |

**Recommendation: emit Parquet as the canonical published artifact, and offer
DuckDB as an optional convenience wrapper.** Rationale:

- Parquet is the more open, language-agnostic format: R (`arrow`), Python
  (`polars`/`pandas`/`duckdb`), and many other tools read it directly. It is the
  natural "data surface" for an ecosystem that is already multi-language.
- DuckDB's value (a queryable SQL file) can be provided *on top of* Parquet
  without duplicating data — a `publications.duckdb` can `CREATE VIEW` over the
  parquet files, or a small wrapper copies them in.
- Parquet diffing and versioning in the repo is friendlier than a single growing
  binary.

Final choice can be deferred until both writers exist; the Layer A/B split means
switching costs ~a writer module.

## Repository layout & build

Artifacts are committed to this repo (small corpus) and regenerated by CI:

```
models/
  publications/            # YAML truth source (unchanged)
  storage.md               # this document
  dist/                    # generated, committed
    models.parquet         # or publications.duckdb
    model_specs.parquet
    publications.parquet
  .github/workflows/build-storage.yaml
```

GitHub action (mirroring the old `models.install.yaml` shape, but Python):

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install orc
        run: pip install ./orc  # or: pip install -e "$GITHUB_WORKSPACE/orc"
      - name: Build storage artifacts
        run: |
          orc ingest publications --registry dist/registry.jsonl
          orc build-parquet publications --out dist
          # or: orc build-duckdb publications --out dist/publications.duckdb
      - name: Commit artifacts
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: Updating compiled storage artifacts
          file_pattern: 'dist/*'
```

The build must be **deterministic**: stable record ordering (sort by `id`,
then `spec_index`), and no timestamps embedded, so a no-op push produces no diff.

## Dependencies

Add to `orc` (currently only `PyYAML` + `pydantic`):

- `pyarrow` (or `duckdb`, which can also emit parquet) for the writer.
- `duckdb` if we add the SQL wrapper.

These are build-time/CI dependencies in `orc`, not in the data repo itself; the
committed artifact is what downstream consumers depend on.

## Implementation steps

1. `orc/records.py` — define the three Layer A dataclasses and the flattening
   logic that expands `fixed_effects_set` into `model_specs` rows (including the
   taxa/region/component/descriptors fallback) and carries `Publication`
   metadata into `publications`.
2. Extend `orc/ingest.py` to produce these records (superseding the lossy
   `RegistryRecord`/`write_registry_jsonl` path, or adding a new writer that
   keeps it).
3. `orc/parquet.py` writer; verify by round-tripping a small fixture through
   `pyarrow` and querying it.
4. `orc/duckdb.py` writer (SQL wrapper or direct table) if we want the `.duckdb`.
5. Wire the action above; commit `dist/` artifacts.
6. Update `README.md` to point users at the new artifact instead of `models.RDS`.
7. Coordinate with `allometric/allometric` on the consumer side: read Parquet
   (or DuckDB) instead of `models.RDS`, preserving the nested list-column
   filtering behavior that `load_models()` exposes today.

The concrete `orc` code changes (Layer A records, writers, CLI subcommands,
dependencies, tests) are tracked in `orc/TODO.md`, the handoff doc for the
session that implements them.

## Open questions to settle before/while building

- **Spec-level ids:** keep the content hash at the *set* level (as today) and
  disambiguate rows with `spec_index`, or introduce a per-spec hash? Keeping the
  current set-level hash is simpler and backward-compatible; note this in the
  schema.
- **`fixed_effects` vs `fixed_effects_set` shape:** should a single
  `fixed_effects` model also appear in `model_specs` (one row) so consumers query
  only one table, or should they be distinguished by `model_type`? Recommend the
  former (single uniform `model_specs` table, `model_type` retained as a column).
- **DuckDB or Parquet or both as the committed artifact:** default to Parquet
  (see above); confirm with downstream consumers before locking in.
- **`descriptors` typing:** the schema allows `Scalar | list` values; confirm how
  mixed-typed descriptor values should be represented in a typed column (likely
  `VARCHAR`/JSON).
