barrett_2006 <- Publication(
  citation = RefManageR::BibEntry(
    key = "barrett_2006",
    bibtype = "article",
    title = "Optimizing efficiency of height modeling for extensive forest inventories",
    author = "Barrett, T.M.",
    volume = 36,
    year = 2006,
    journal = "Canadian Journal of Forest Research",
    doi = "https://doi.org/10.1139/x06-128"
  ),
  descriptors = list(
    region = c("US-WA", "US-OR", "US-CA"),
    country = "US"
  )
)

hst <- FixedEffectsSet(
  response = list(
    hst = units::as_units("m")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameter_names = c("alpha", "beta", "gamma"),
  predict_fn = function(dsob) {
    1.37 + alpha * (1-  exp(-beta * dsob)^gamma)
  },
  model_specifications = load_parameter_frame("hst_barrett_2006") %>%
    aggregate_taxa()
)

barrett_2006 <- barrett_2006 %>%
  add_set(hst)