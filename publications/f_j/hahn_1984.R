hahn_1984 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "techreport",
    key = "hahn_1984",
    title = "Tree Volume and Biomass Equations for the Lake States",
    author = "Hahn, Jerold T",
    year = 1984,
    institution = "USDA Department of Agriculture, North Central Forest Experiment Station",
    doi = "https://doi.org/10.2737/NC-RP-250"
  ),
  descriptors = list(
    country = "US",
    region = c("US-WI", "US-MI", "US-MN")
  )
)

hst <- FixedEffectsSet(
  response = list(
    hst = units::as_units("ft")
  ),
  covariates = list(
    dsob = units::as_units("in"),
    hstix50 = units::as_units("ft"),
    d = units::as_units("in"),
    gs_s = units::as_units("ft^2 / acre")
  ),
  parameter_names = c("b_1", "b_2", "b_3", "b_4", "b_5", "b_6"),
  predict_fn = function(dsob, hstix50, d, gs_s) {
    T <- (1.00001 - d / dsob)
    4.5 + b_1 * (1 - exp(b_2 * dsob))^b_3 * hstix50^b_4 * T^b_5 * gs_s^b_6
  },
  covariate_definitions = list(
    d = "Top d.o.b., a value of 0 gives total height."
  ),
  model_specifications = load_parameter_frame("hst_hahn_1984") %>%
    aggregate_taxa()
)

cuft <- FixedEffectsSet(
  response = list(
    vsia = units::as_units("ft^3")
  ),
  covariates = list(
    dsob = units::as_units("in"),
    hst = units::as_units("ft")
  ),
  parameter_names = c("b_0", "b_1"),
  predict_fn = function(dsob, hst) {
    b_0 + b_1 * dsob^2 * hst
  },
  model_specifications = load_parameter_frame("vsa_hahn_1984_1") %>%
    aggregate_taxa()
)

bdft <- FixedEffectsSet(
  response = list(
    vsia = units::as_units("board_foot")
  ),
  covariates = list(
    dsob = units::as_units("in"),
    hst = units::as_units("ft")
  ),
  parameter_names = c("b_0", "b_1"),
  predict_fn = function(dsob, hst) {
    b_0 + b_1 * dsob^2 * hst
  },
  model_specifications = load_parameter_frame("vsa_hahn_1984_2") %>%
    aggregate_taxa()
)

vui <- FixedEffectsSet(
  response = list(
    vui = units::as_units("ft^3")
  ),
  covariates = list(
    dsob = units::as_units("in")
  ),
  parameter_names = c("s"),
  predict_fn = function(dsob) {
    s * dsob^2
  },
  model_specifications = load_parameter_frame("vu_hahn_1984") %>%
    aggregate_taxa()
)

rsk <- FixedEffectsSet(
  response = list(
    rsk = units::unitless
  ),
  covariates = list(
    dsob = units::as_units("in")
  ),
  parameter_names = c("b_0", "b_1"),
  predict_fn = function(dsob) {
    (b_0 + b_1 * dsob) / 100
  },
  model_specifications = load_parameter_frame("rsk_hahn_1984") %>%
    aggregate_taxa()
)

# Finally, add individually the

hahn_1984 <- hahn_1984 %>%
  add_set(hst) %>%
  add_set(cuft) %>%
  add_set(bdft) %>%
  add_set(vui) %>%
  add_set(rsk)
