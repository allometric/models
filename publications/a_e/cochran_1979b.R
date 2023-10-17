cochran_1979b <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "techreport",
    key = "cochran_1979b",
    title = "Site index and height growth curves for managed, even-aged stands of Douglas-fir east of the Cascades in Oregon and Washington",
    author = "Cochran, PH",
    volume = 251,
    year = 1979,
    institution = "Department of Agriculture, Forest Service, Pacific Northwest Forest and Range Experiment Station"
  ),
  descriptors = list(
    country = "US",
    region = c("US-OR", "US-WA"),
    family = "Pinaceae",
    genus = "Pseudotsuga",
    species = "menziesii"
  )
)

hstix_df <- FixedEffectsModel(
  response_unit = list(
    hstix50 = units::as_units("ft")
  ),
  covariate_units = list(
    hst = units::as_units("ft"),
    atb = units::as_units("years")
  ),
  parameters = list(
    a = 84.47,
    b = -0.37496,
    c = 1.36164,
    d = -0.00243434,
    e = 0.52032,
    f = -0.0013194,
    g = 27.2823
  ),
  predict_fn = function(hst, atb) {
    a - (exp(b + c * log(atb) + d * log(atb)^4)) *
      (e + f * atb + g / atb) +
      (hst - 4.5) * (e + f * atb + g / atb)
  }
)

cochran_1979b <- cochran_1979b %>%
  add_model(hstix_df)