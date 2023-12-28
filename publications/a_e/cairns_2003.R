cairns_2003 <- Publication(
  citation = RefManageR::BibEntry(
    key = "cairns_2003",
    bibtype = "article",
    title = "Composition and aboveground tree biomass of a dry semi-evergreen forest on Mexico’s Yucatan Peninsula",
    author = "Cairns, Michael A and Olmsted, Ingrid and Granados, Juli{\'a}n and Argaez, Jorge",
    journal = "Forest Ecology and Management",
    volume = 186,
    number = "1-3",
    pages = "125--132",
    year = 2003,
    publisher = "Elsevier"
  ),
  descriptors = list(
    country = "MX",
    region = c("MX-YUC", "MX-CAM", "MX-ROO")
  )
)

bt <- FixedEffectsSet(
  response = list(
    bt = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameter_names = c("beta_0", "beta_1"),
  predict_fn = function(dsob, hst) {
    beta_0 + beta_1 * dsob^2 * hst
  },
  model_specifications = load_parameter_frame("bt_cairns_2003") %>%
    aggregate_taxa()
)

cairns_2003 <- cairns_2003 %>% add_set(bt)