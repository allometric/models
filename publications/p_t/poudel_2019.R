poudel_2019 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "article",
    key = "poudel_2019",
    title = "Estimating individual-tree aboveground biomass of tree species in the western USA",
    author = "Poudel, Krishna P and Temesgen, Hailemariam and Radtke, Philip J and Gray, Andrew N",
    journal = "Canadian Journal of Forest Research",
    volume = 49,
    number = 6,
    pages = "701--714",
    year = 2019,
    publisher = "NRC Research Press",
    doi = "https://doi.org/10.1139/cjfr-2018-0361"
  ),
  descriptors = list(
    country = c("US", "CA"),
    region = c(
      "CA-BC", "US-WA", "US-OR",
      "US-CA", "US-NV", "US-ID",
      "US-MT", "US-UT", "US-AZ",
      "US-CO"
    )
  )
)

cvts <- FixedEffectsSet(
  response = list(
    vsia = units::as_units("m^3")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameter_names = c("a", "b", "c"),
  predict_fn = function(dsob, hst) {
    exp(a + b * log(dsob) + c * log(hst))
  },
  model_specifications = load_parameter_frame("vsa_poudel_2019") %>%
    aggregate_taxa()
)

# Table 4, models that use a, b and c parameters
agb_1 <- FixedEffectsSet(
  response = list(
    bt = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameter_names = c("a", "b", "c", "cf"),
  predict_fn = function(dsob, hst) {
    cf * exp(a + b * log(dsob) + c * log(hst))
  },
  model_specifications = load_parameter_frame("bt_poudel_2019_1") %>%
    aggregate_taxa()
)

# Table 4, ponderosa pine model
agb_pp <- FixedEffectsModel(
  response = list(
    bt = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameters = list(
    a = -0.6616,
    b = 0.8288,
    c = 0.2127,
    d = 0.4145,
    cf = 1.0246
  ),
  predict_fn = function(dsob, hst) {
    cf * exp(a + b * log(dsob) + c * log(dsob)^2 + d * log(hst))
  },
  descriptors = list(
    taxa = Taxa(Taxon(family = "Pinaceae", genus = "Pinus", species = "ponderosa"))
  )
)

# Table 4, subalpine fir model
agb_sa <- FixedEffectsModel(
  response = list(
    bt = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameters = list(
    a = -5.5175,
    b = 2.6795,
    c = 1.2805,
    cf = 1
  ),
  predict_fn = function(dsob, hst) {
    cf * exp(a + b * log(dsob) + c * log(hst))
  },
  descriptors = list(
    taxa = Taxa(Taxon(family = "Pinaceae", genus = "Abies", species = "lasiocarpa"))
  )
)

# Table 4, models that use a and b parameters
agb_2 <- FixedEffectsSet(
  response = list(
    bt = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameter_names = c("a", "b", "cf"),
  predict_fn = function(dsob) {
    cf * exp(a + b * log(dsob))
  },
  model_specifications = load_parameter_frame("bt_poudel_2019_2") %>%
    aggregate_taxa()
)

# Table 6, volume to biomass conversion
v_to_agb <- FixedEffectsSet(
  response = list(
    bt = units::as_units("kg")
  ),
  covariates = list(
    vsia = units::as_units("m^3")
  ),
  parameter_names = c("a", "b", "cf"),
  predict_fn = function(vsia) {
    cf * exp(a + b * log(vsia))
  },
  model_specifications = load_parameter_frame("bt_poudel_2019_3") %>%
    aggregate_taxa()
)

rsbt <- FixedEffectsSet(
  response = list(
    rsbt = units::as_units("kg / kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameter_names = c(
    paste("a", seq(4), sep = "_"),
    paste("b", seq(4), sep = "_"),
    paste("c", seq(4), sep = "_")
  ),
  predict_fn = function(dsob, hst) {
    denom <- sum(
      exp(a_1 + b_1 * log(dsob) + c_1 * log(hst)),
      exp(a_2 + b_2 * log(dsob) + c_2 * log(hst)),
      exp(a_3 + b_3 * log(dsob) + c_3 * log(hst)),
      exp(a_4 + b_4 * log(dsob) + c_4 * log(hst))
    )

    exp(a_1 + b_1 * log(dsob) + c_1 * log(hst)) / denom
  },
  model_specifications = load_parameter_frame("b_poudel_2019")
)

rkbt <- FixedEffectsSet(
  response = list(
    rkbt = units::as_units("kg / kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameter_names = c(
    paste("a", seq(4), sep = "_"),
    paste("b", seq(4), sep = "_"),
    paste("c", seq(4), sep = "_")
  ),
  predict_fn = function(dsob, hst) {
    denom <- sum(
      exp(a_1 + b_1 * log(dsob) + c_1 * log(hst)),
      exp(a_2 + b_2 * log(dsob) + c_2 * log(hst)),
      exp(a_3 + b_3 * log(dsob) + c_3 * log(hst)),
      exp(a_4 + b_4 * log(dsob) + c_4 * log(hst))
    )

    exp(a_2 + b_2 * log(dsob) + c_2 * log(hst)) / denom
  },
  model_specifications = load_parameter_frame("b_poudel_2019")
)


rfbt <- FixedEffectsSet(
  response = list(
    rfbt = units::as_units("kg / kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameter_names = c(
    paste("a", seq(4), sep = "_"),
    paste("b", seq(4), sep = "_"),
    paste("c", seq(4), sep = "_")
  ),
  predict_fn = function(dsob, hst) {
    denom <- sum(
      exp(a_1 + b_1 * log(dsob) + c_1 * log(hst)),
      exp(a_2 + b_2 * log(dsob) + c_2 * log(hst)),
      exp(a_3 + b_3 * log(dsob) + c_3 * log(hst)),
      exp(a_4 + b_4 * log(dsob) + c_4 * log(hst))
    )

    exp(a_3 + b_3 * log(dsob) + c_3 * log(hst)) / denom
  },
  model_specifications = load_parameter_frame("b_poudel_2019")
)

rbbt <- FixedEffectsSet(
  response = list(
    rbbt = units::as_units("kg / kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameter_names = c(
    paste("a", seq(4), sep = "_"),
    paste("b", seq(4), sep = "_"),
    paste("c", seq(4), sep = "_")
  ),
  predict_fn = function(dsob, hst) {
    denom <- sum(
      exp(a_1 + b_1 * log(dsob) + c_1 * log(hst)),
      exp(a_2 + b_2 * log(dsob) + c_2 * log(hst)),
      exp(a_3 + b_3 * log(dsob) + c_3 * log(hst)),
      exp(a_4 + b_4 * log(dsob) + c_4 * log(hst))
    )

    exp(a_4 + b_4 * log(dsob) + c_4 * log(hst)) / denom
  },
  model_specifications = load_parameter_frame("b_poudel_2019")
)

poudel_2019 <- poudel_2019 %>%
  add_set(cvts) %>%
  add_set(agb_1) %>%
  add_model(agb_pp) %>%
  add_model(agb_sa) %>%
  add_set(agb_2) %>%
  add_set(v_to_agb) %>%
  add_set(rfbt) %>%
  add_set(rkbt) %>%
  add_set(rsbt) %>%
  add_set(rbbt)
