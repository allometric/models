test_citation <- RefManageR::BibEntry(
  key = "pemulis_2024",
  bibtype = "article",
  title = "How to Test a Citation to JSON Function",
  author = "Pemulis, Michael",
  journal = "Journal of Precise Unit Testing",
  year = 2024
)

test_that("authors_to_json returns correct value", {
  authors <- list(
    person(given = "Wesley", family = "Finkle Frank"),
    person(given = "Miriam", family = "Finkle Frank")
  )

  parsed <- authors_to_json(authors)

  expect_equal(parsed[[1]][["given"]], "Wesley")
  expect_equal(parsed[[1]][["family"]], "Finkle Frank")

  expect_equal(parsed[[2]][["given"]], "Miriam")
  expect_equal(parsed[[2]][["family"]], "Finkle Frank")
})

test_that("citation_to_json returns correct value", {
  test_citation <- RefManageR::BibEntry(
    key = "pemulis_2024",
    bibtype = "article",
    title = "How to Test a Citation to JSON Function",
    author = "Pemulis, Michael",
    journal = "Journal of Precise Unit Testing",
    year = 2024
  )

  parsed <- citation_to_json(test_citation)

  expect_equal(parsed$pub_id[[1]], "pemulis_2024")
  expect_equal(parsed$title[[1]], "How to Test a Citation to JSON Function")
  expect_equal(parsed$journal[[1]], "Journal of Precise Unit Testing")
  expect_equal(parsed$bibtype[[1]], "Article")
  expect_equal(parsed$year[[1]], 2024)

  expect_equal(parsed$authors[[1]][["given"]], "Michael")
  expect_equal(parsed$authors[[1]][["family"]], "Pemulis")
})

test_that("variables_to_json returns correct value", {
  variables <- list(
    hst = units::as_units("m")
  )

  parsed <- variables_to_json(variables)

  expect_equal(parsed[[1]][["name"]], "hst")
  expect_equal(parsed[[1]][["unit"]], "m")

  expect_equal(length(parsed), 1)
})

test_that("unbox nested unboxes a nested list", {
  nested <- list(list("a"))

  unboxed <- unbox_nested(nested)

  unboxed_class <- class(unboxed[[1]][[1]])

  expect_equal(unboxed_class[[1]], "scalar")
  expect_equal(jsonlite::unbox("a"), unboxed[[1]][[1]])
})

test_that("unbox nonnested unboxes a list", {
  nested <- list("a")

  unboxed <- unbox_nonnested(nested)

  unboxed_class <- class(unboxed[[1]])

  expect_equal(unboxed_class[[1]], "scalar")
  expect_equal(jsonlite::unbox("a"), unboxed[[1]])
})

test_that("taxa_to_json returns correct value", {
  taxa <- allometric::Taxa(
    allometric::Taxon(
      family = "Pinaceae",
      genus = "Pinus",
      species = "ponderosa"
    )
  )

  parsed <- taxa_to_json(taxa)

  expect_equal(parsed[[1]][["family"]], "Pinaceae")
  expect_equal(parsed[[1]][["genus"]], "Pinus")
  expect_equal(parsed[[1]][["species"]], "ponderosa")
})

test_that("descriptors_to_json returns correct value", {
  descriptors_null <- list()

  expect_true(is.null(
    descriptors_to_json(descriptors_null)
  ))

  descriptors_with_taxa <- allometric::brackett_acer@descriptors

  parsed_taxa <- descriptors_to_json(descriptors_with_taxa)["taxa"]

  expect_equal(names(parsed_taxa)[[1]], "taxa")
  expect_equal(parsed_taxa[[1]][[1]][["family"]], "Aceraceae")
  expect_equal(parsed_taxa[[1]][[1]][["genus"]], "Acer")
  expect_true(is.na(parsed_taxa[[1]][[1]][["species"]]))
})

test_that("prepare_inline_ciation returns correct value", {
  one_author <- RefManageR::BibEntry(
    bibtype = "techreport",
    title = "test",
    author = "Pemulis, Michael",
    institution = "Enfield Tennis Academy",
    year = 1996
  )

  expect_equal(prepare_inline_citation(one_author), "Pemulis (1996)")


  two_authors <- RefManageR::BibEntry(
    bibtype = "techreport",
    title = "test",
    author = "Pemulis, Michael and Incandenza, Hal",
    institution = "Enfield Tennis Academy",
    year = 1996
  )

  expect_equal(
    prepare_inline_citation(two_authors),
    "Pemulis and Incandenza (1996)"
  )

  three_authors <- RefManageR::BibEntry(
    bibtype = "techreport",
    title = "test",
    author = "Pemulis, Michael and Incandenza, Hal and Stice, Ortho",
    institution = "Enfield Tennis Academy",
    year = 1996
  )

  expect_equal(
    prepare_inline_citation(three_authors),
    "Pemulis et al. (1996)"
  )
})

test_that("parse_func_body returns correct value", {
  func <- function(x) {x + 2}

  expect_equal(parse_func_body(func), "x + 2")
})

test_that("covariate_definitions_to_json returns correct value", {
  covt_def_data <- list(
    hst = "the total height of the tree but different"
  )

  parsed <- covariate_definitions_to_json(covt_def_data)

  expect_equal(parsed[[1]][["name"]], jsonlite::unbox("hst"))
  expect_equal(
    parsed[[1]][["definition"]],
    jsonlite::unbox("the total height of the tree but different")
  )
})

test_that("model_to_json runs", {
  parsed <- model_to_json(allometric::brackett_acer)

  field_names <- names(parsed)
  all_check <- all(
    field_names %in% c(
      "_id", "pub_id", "model_type", "model_class", "response", "covariates",
      "descriptors", "parameters", "predict_fn_body"
    )
  )

  expect_true(all_check)
})

test_that("publication_to_json_runs", {
  pub_file <- system.file("testdata/test_publications/a_e/barrett_1978.R", package = "models")
  source(pub_file)

  parsed <- publication_to_json(barrett_1978)

  names(parsed) == c("pub_json", "models_json")

  expect_equal(parsed$models_json[[1]][["model_type"]], jsonlite::unbox("site index"))

  expect_true("taxa" %in% names(parsed$models_json[[1]][["descriptors"]]))
})
