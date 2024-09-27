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
