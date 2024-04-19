winck_2015 <- Publication(
  citation = RefManageR::BibEntry(
    key = "winck_2015",
    bibtype = "article",
    title = "Regional prediction models for the aboveground biomass estimation of eucalyptus grandis in Northeastern Argentina",
    author = "Winck, Rosa and Fassola, Hugo and Barth, Sara Regina and Crechi, Ernesto and Keller, Aldo and Videla, Daniel and Zaderenko, Constantino",
    year = 2015,
    month = 7,
    pages = "595--606",
    volume = 25,
    journal = "Ciencia Florestal",
    doi = "https://doi.org/10.5902/1980509819611"
  ),
  descriptors = list(
    country = "AR",
    taxa = Taxa(
      Taxon(
        family = "Myrtaceae",
        genus = "Eucalyptus",
        species = "grandis"
      )
    )
  )
)

b_param_sets <- load_parameter_frame("b_winck_2015_1") %>%
  split(.$response)

# Do first 3 biomass model sets
for(i in seq_along(b_param_sets)) {
  response_name <- names(b_param_sets)[[i]]

  response <- list()
  response[[response_name]] <- units::as_units("kg")

  mod_set <- FixedEffectsSet(
    response = response,
    covariates = list(
      dsob = units::as_units("cm"),
      hst = units::as_units("m")
    ),
    parameter_names = c("a", "b", "c"),
    predict_fn = function(dsob, hst) {
      exp(a + b * log(dsob) + c * log(hst))
    },
    model_specifications = b_param_sets[[i]]
  )

  winck_2015 <- winck_2015 %>% add_set(mod_set)
}

# Do diameter-specific branch biomass
bb_dias <- FixedEffectsSet(
  response = list(
    bb = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameter_names = c("a", "b", "c"),
  predict_fn = function(dsob, hst) {
    exp(a + b * log(dsob) + c * log(hst))
  },
  model_specifications = load_parameter_frame("br_winck_2015")
)

winck_2015 <- winck_2015 %>% add_set(bb_dias)

# Do foliage biomass
bf <- FixedEffectsSet(
  response = list(
    bf = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m"),
    att = units::as_units("years"),
    gs_s = units::as_units("m^2/ha"),
    es_s = units::as_units("ha^-1")
  ),
  parameter_names = c("a", "b", "c", "d", "e", "f"),
  predict_fn = function(dsob, hst, att, gs_s, es_s) {
    exp(a + b * dsob + c * hst + d * att + e * gs_s + f * es_s)
  },
  model_specifications = tibble::tibble(
    a = c(-6.12, -5.63),
    b = c(3.26, 3.26),
    c = c(-1.08, -1.08),
    d = c(-0.65, -0.65),
    e = c(-0.43, -0.43),
    f = c(0.71, 0.71)
  )
)

winck_2015 <- winck_2015 %>% add_set(bf)