nunes_2022 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "article",
    key = "nunes_2022",
    title = "Bulk Density of Shrub Types and Tree Crowns to Use with Forest Inventories in the Iberian Peninsula",
    author = "Nunes, Leonia and Pasalodos-Tato, Maria and Alberdi, Iciar and Sequeira, Ana Catarina and Vega, Jose Antonio and Silva, Vasco and Vieira, Pedro and Rego, Francisco Castro",
    volume = 13,
    issn = "1999-4907",
    doi = "https://doi.org/10.3390/f13040555",
    number = 4,
    journal = "Forests",
    year = 2022
  ),
  descriptors = list(
    country = "ES"
  )
)

hcl_taxa <- FixedEffectsSet(
  response = list(
    hcl = units::as_units("m")
  ),
  covariates = list(
    hst = units::as_units("m"),
    es  = units::as_units("ha^-1")
  ),
  parameter_names = c("a0", "a1"),
  predict_fn = function(hst, es) {
    hst / (1 + a0 * exp(-a1 * (10000 / es)^(-0.5)))
  },
  model_specifications = load_parameter_frame("hcl_nunes_2022") %>%
    dplyr::filter(!is.na(family)) %>%
    aggregate_taxa()
)

hcl_notaxa <- FixedEffectsSet(
  response = list(
    hcl = units::as_units("m")
  ),
  covariates = list(
    hst = units::as_units("m"),
    es  = units::as_units("ha^-1")
  ),
  parameter_names = c("a0", "a1"),
  predict_fn = function(hst, es) {
    hst / (1 + a0 * exp(-a1 * (10000 / es)^(-0.5)))
  },
  model_specifications = load_parameter_frame("hcl_nunes_2022") %>%
    dplyr::filter(is.na(family)) %>%
    dplyr::select(-c(family, genus, species))
)

dc_taxa <- FixedEffectsSet(
  response = list(
    dc = units::as_units("m")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    es =  units::as_units("ha^-1")
  ),
  parameter_names = c("b0", "b1", "b2"),
  predict_fn = function(dsob, es) {
    b0 * (dsob^b1) * ((10000 / es)^(-0.5))^b2
  },
  model_specifications = load_parameter_frame("dc_nunes_2022") %>%
    dplyr::filter(!is.na(family)) %>%
    aggregate_taxa()
)


dc_notaxa <- FixedEffectsSet(
  response = list(
    dc = units::as_units("m")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    es =  units::as_units("ha^-1")
  ),
  parameter_names = c("b0", "b1", "b2"),
  predict_fn = function(dsob, es) {
    b0 * (dsob^b1) * ((10000 / es)^(-0.5))^b2
  },
  model_specifications = load_parameter_frame("dc_nunes_2022") %>%
    dplyr::filter(is.na(family)) %>%
    dplyr::select(-c(family, genus, species))
)

nunes_2022 <- nunes_2022 %>%
  add_set(hcl_taxa) %>%
  add_set(hcl_notaxa) %>%
  add_set(dc_taxa) %>%
  add_set(dc_notaxa)