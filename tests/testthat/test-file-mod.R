test_that("parse_parameter_names returns correct pub ID", {
  expect_equal(parse_parameter_names("kozak_1988.csv"), "kozak_1988")

  empty_parse <- parse_parameter_names("")
  expect_true(is.null(empty_parse))
})

test_that("get_modified_files returns valid pub IDs", {
  skip_on_ci()
  check <- get_modified_files("32006ca", "018e79d")
  expect_equal(check, "sharma_2015")
})