test_that("Model row is correctly made", {
  pub <- allometric::Publication(
    citation = RefManageR::BibEntry(
      key = "test_2000",
      bibtype = "article",
      author = "test",
      title = "test",
      journal = "test",
      year = 2000,
      volume = 0
    ),
    descriptors = list(
      region = "US-WA"
    )
  )

  model_row <- create_model_row(allometric::brackett_acer, pub, "test_id")

  expect_s4_class(model_row$model[[1]], "FixedEffectsModel")
})

test_that("aggregate_pub_models runs", {
  pub <- allometric::Publication(
    citation = RefManageR::BibEntry(
      key = "test_2000",
      bibtype = "article",
      author = "test",
      title = "test",
      journal = "test",
      year = 2000,
      volume = 0
    )
  )

  pub <- allometric::add_model(pub, allometric::brackett_acer)

  agg_models <- aggregate_pub_models(pub)
  expect_s4_class(agg_models$model[[1]], "FixedEffectsModel")
})

test_that("ingest_models runs correctly with locally specified data", {
  pub_path <- system.file("testdata/test_publications", package = "models")
  params_path <- system.file("testdata/test_parameters", package = "models")

  models_ingested <- ingest_models(
    FALSE, pub_path = pub_path, params_path = params_path
  )

  expect_equal(25, nrow(models_ingested))
})

test_that("get_model_hash returns an md5 string", {
  predict_fn_populated <- function(dsob) {
    1.2 * dsob
  }
  descriptors <- tibble::tibble(country = "US")

  hash <- get_model_hash(predict_fn_populated, descriptors)
  expect_equal(hash, "e826bd8a3a66fc5d77e95e812a8ae6c9")
})

test_that("append_search_descriptors creates a valid tibble row", {
  row <- tibble::tibble(a = c(1))
  descriptors <- tibble::tibble(country = "US")

  suppressWarnings((
    row <- append_search_descriptors(row, descriptors)
  ))

  test_row <- tibble::tibble(a = 1, country = list("US"), region = list(NULL))

  expect_equal(row, test_row)
})

test_that("get_current_pub_ids returns valid publication ids", {
  current_pub_ids <- get_current_pub_ids()
  underscore_check <- grepl("_", current_pub_ids)

  # All pub_ids contain an underscore
  expect_true(all(underscore_check))

  # All pub_ids contain a 4 digit string
  all(grepl("\\d{4}", current_pub_ids))

  # All pub_ids contain only characters before the year
  all(grepl("^[a-zA-Z]+_\\d{4}[a-zA-Z]?$", current_pub_ids))
})

test_that("get_current_pub_ids_params returns valid publication ids", {
  current_pub_ids <- get_current_pub_ids_params()
  underscore_check <- grepl("_", current_pub_ids)

  # All pub_ids contain an underscore
  expect_true(all(underscore_check))

  # All pub_ids contain a 4 digit string
  all(grepl("\\d{4}", current_pub_ids))

  # All pub_ids contain only characters before the year
  all(grepl("^[a-zA-Z]+_\\d{4}[a-zA-Z]?$", current_pub_ids))
})