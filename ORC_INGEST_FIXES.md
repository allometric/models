# orc ingestion fixes — suggested data migration

Handoff for a data-fixing session. `orc` currently rejects **45 of 74**
`publications/*.yaml` files. All of them fail for the **same single reason**;
there are no other validation issues lurking behind it (verified: applying the
one fix below makes all 74 files ingest with **0 errors / 0 warnings**).

## The one fix: split `fixed_effects_set` out of `models:`

The `orc` schema (`orc/schema.py`) requires two separate top-level lists:

- `models:` — only `type: fixed_effects`
- `model_sets:` — only `type: fixed_effects_set`

Today every publication puts *both* kinds under a single `models:` list, using
`type:` to distinguish them (e.g. `winck_2015.yaml` has `bb`, `bs`, `bt`, `bf`
all as `fixed_effects_set` inside `models:`). The schema forbids that, so each
set entry triggers three errors:

```
models.N.type           Input should be 'fixed_effects'   (got 'fixed_effects_set')
models.N.parameters     Field required                    (sets have specifications, not parameters)
models.N.specifications Extra inputs are not permitted
```

### What to change per file

For each publication, split its `models:` entries by `type`:

- entries with `type: fixed_effects` stay in `models:`
- entries with `type: fixed_effects_set` move to a new top-level `model_sets:`
  key (create it if absent; merge with any existing `model_sets:`)

Everything else in the file stays exactly as-is — no fields renamed, no
restructuring, no content changes.

### Example

`winck_2015.yaml` currently has four `fixed_effects_set` entries under `models:`
(`bb`, `bs`, `bt`, `bf`). After the fix:

```yaml
publication:
  key: winck_2015
  # ... unchanged ...
models: []
model_sets:
- name: bb
  type: fixed_effects_set
  # ... unchanged body (taxa/response/covariates/prediction_function/specifications)
- name: bs
  type: fixed_effects_set
  # ...
```

(`models: []` is only needed if no single models remain; otherwise keep the
remaining `fixed_effects` entries there.)

## Affected files (45)

```
a_e/barrett_2006.yaml        a_e/brackett_1977.yaml      a_e/cairns_2003.yaml
a_e/castaneda_2005.yaml      a_e/chojnacky_1985.yaml     a_e/chojnacky_1988.yaml
a_e/chojnacky_1994.yaml      a_e/cochran_1979a.yaml      a_e/delcourt_2022.yaml
a_e/eng_2012.yaml            f_j/feldpausch_2012.yaml    f_j/forrester_2017.yaml
f_j/fvs_2008.yaml            f_j/hahn_1984.yaml          f_j/hahn_1991.yaml
f_j/hann_1978.yaml           f_j/hann_1987.yaml          f_j/hann_1997.yaml
f_j/hann_2011.yaml           f_j/huy_2019.yaml           f_j/huynh_2022.yaml
f_j/iffsc_2022.yaml          k_o/kozak_1988.yaml         k_o/krumland_2005.yaml
k_o/lambert_2005.yaml        k_o/larsen_1985.yaml        k_o/mcardle_1961.yaml
k_o/montero_2005.yaml        k_o/montero_2020.yaml       k_o/moore_1996.yaml
k_o/myers_1964a.yaml         k_o/myers_1972.yaml         k_o/nunes_2022.yaml
p_t/paine_1982.yaml          p_t/poudel_2018.yaml        p_t/poudel_2019.yaml
p_t/ritche_1987.yaml         p_t/rolim_2019b.yaml        p_t/scott_1981.yaml
p_t/sharma_2015.yaml         p_t/temesgen_2007.yaml      p_t/turner_2000.yaml
u_z/ung_2008.yaml            u_z/vibrans_2015.yaml       u_z/winck_2015.yaml
```

## Verified result

After applying the split to a copy of the corpus and running
`orc ingest`:

```
errors: 0   warnings: 0   files: 74
model_types: fixed_effects=123, fixed_effects_set=219
```

Then `orc ingest ../models/publications --parquet out/` writes the three
parquet tables (`publications`, `models`, `model_specs`) for the full corpus.
