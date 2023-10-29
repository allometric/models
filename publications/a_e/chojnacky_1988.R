chojnacky_1988 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "techreport",
    key = "chojnacky_1988",
    title = "Juniper, pinyon, oak, and mesquite volume equations for Arizona",
    author = "Chojnacky, David C",
    volume = 391,
    year = 1988,
    institution = "US Department of Agriculture, Forest Service, Intermountain Research Station",
    doi = "https://doi.org/10.5962/bhl.title.68960"
  ),
  descriptors = list(
    country = "US",
    region = "US-AZ"
  )
)

vsoa_small <- FixedEffectsSet(
  response = list(
    vsoa = units::as_units("ft^3")
  ),
  covariates = list(
    dsoc = units::as_units("in"),
    hst = units::as_units("ft")
  ),
  parameter_names = c("beta_0", "beta_1", "beta_2"),
  predict_fn = function(dsoc, hst) {
    X <- dsoc^2 * hst / 1000
    beta_0 + beta_1 * X + beta_2 * X^2
  },
  model_specifications = load_parameter_frame("vsa_1988_1") %>%
    aggregate_taxa()
)

vsoa_large <- FixedEffectsSet(
  response = list(
    vsoa = units::as_units("ft^3")
  ),
  covariates = list(
    dsoc = units::as_units("in"),
    hst = units::as_units("ft")
  ),
  parameter_names = c("beta_3", "beta_1", "beta_4"),
  predict_fn = function(dsoc, hst) {
    X <- dsoc^2 * hst / 1000
    beta_3 + beta_1 * X + beta_4 / X
  },
  model_specifications = load_parameter_frame("vsa_1988_2") %>%
    aggregate_taxa()
)

chojnacky_1988 <- chojnacky_1988 %>%
  add_set(vsoa_small) %>%
  add_set(vsoa_large)
