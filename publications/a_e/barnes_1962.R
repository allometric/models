barnes_1962 <- Publication(
  citation = RefManageR::BibEntry(
    key = "barnes_1962",
    bibtype = "techreport",
    title = "Yield of even-aged stands of western hemlock",
    author = "Barnes, George H",
    number = 1273,
    year = 1962,
    institution = "Department of Agriculture, Forest Service"
  )
)

hstix50 <- FixedEffectsModel(
  response = list(
    "hstix50" = units::as_units("ft")
  ),
  covariates = list(
    "atb" = units::as_units("year"),
    "hst" = units::as_units("ft")
  ),
  parameters = c(
    a = 22.6,
    b = 0.014482,
    c = 0.001162
  ),
  predict_fn = function(atb, hst) {
    4.5 + a * exp((b - c * log(atb)) * (hst - 4.5))
  }
)

barnes_1962 <- barnes_1962 %>%
  add_model(hstix50)