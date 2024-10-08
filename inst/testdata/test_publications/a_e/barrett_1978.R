barrett_1978 <- allometric::Publication(
  citation = RefManageR::BibEntry(
    key = "barrett_1978",
    bibtype = "techreport",
    title = "Height growth and site index curves for managed, even-aged stands of ponderosa pine in the Pacific Northwest",
    author = "Barrett, James Willis",
    volume = 232,
    year = 1978,
    institution = "Department of Agriculture, Forest Service, Pacific Northwest Forest and Range Research Station",
    doi = "https://doi.org/10.5962/bhl.title.94197"
  ),
  descriptors = list(
    taxa = allometric::Taxa(
      allometric::Taxon(
        family = "Pinaceae",
        genus = "Pinus",
        species = "ponderosa"
      )
    ),
    region = c("US-WA", "US-OR"),
    country = "US"
  )
)

hstix100 <- allometric::FixedEffectsModel(
  response = list(
    hstix100 = units::as_units("ft")
  ),
  covariates = list(
    hst = units::as_units("ft"),
    atb = units::as_units("years")
  ),
  parameters = list(
    a = 100.43,
    b = 1.198632,
    c = 0.00283073,
    d = 8.44441,
    e = 128.8952205,
    f = 0.016959,
    g = 1.23114
  ),
  predict_fn = function(hst, atb) {
    a - (b - c * atb + d / atb) * (e * (1 - exp(-f * atb)^g)) +
      ((b - c * atb + d / atb) * (hst - 4.5)) + 4.5
  }
)

barrett_1978 <- barrett_1978 %>%
  allometric::add_model(hstix100)