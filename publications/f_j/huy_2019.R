
huy_2019_citation <- RefManageR::BibEntry(
  bibtype = "article",
  key = "huy_2019",
  title = "Taxon-specific modeling systems for improving reliability of tree aboveground biomass and its components estimates in tropical dry dipterocarp forests",
  author = "Huy, Bao and Tinh, Nguyen Thi and Poudel, Krishna P and Frank, Bryce Michael and Temesgen, Hailemariam",
  journal = "Forest Ecology and Management",
  volume = 437,
  pages = "156-174",
  year = 2019,
  publisher = "Elsevier",
  doi = "https://doi.org/10.1016/j.foreco.2019.01.038"
)

huy_2019 <- Publication(
  citation = huy_2019_citation,
  descriptors = list(
    country = "VN"
  )
)

mixed_species_taxa <- Taxa(
  Taxon(
    family = "Dipterocarpaceae",
    genus = "Dipterocarpus"
  ),
  Taxon(
    family = "Dipterocarpaceae",
    genus = "Shorea"
  )
)

bs_huy_2019_1_spec <- load_parameter_frame("bs_huy_2019_1") %>%
  dplyr::select(-c("family"))

bs_huy_2019_1_spec$taxa <- list(
  mixed_species_taxa, Taxa(Taxon(family = "Dipterocarpaceae"))
)


bs_huy_2019_1 <- FixedEffectsSet(
  response = list(
    bs = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m"),
    es = units::as_units("g/cm^3")
  ),
  parameter_names = c("a_1", "b_11", "b_12", "b_13"),
  predict_fn = function(dsob, hst, es) {
    a_1 * dsob^b_11 * hst^b_12 * es^b_13
  },
  model_specifications = bs_huy_2019_1_spec
)

bs_huy_2019_2 <- FixedEffectsSet(
  response = list(
    bs = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameter_names = c("a_1", "b_11"),
  predict_fn = function(dsob) {
    a_1 * dsob^b_11
  },
  model_specifications = load_parameter_frame("bs_huy_2019_2") %>%
    aggregate_taxa()
)

bb_huy_2019_1_spec_all <- load_parameter_frame("bb_huy_2019_1")

bb_huy_2019_1_spec_na <- bb_huy_2019_1_spec_all %>%
  dplyr::filter(is.na(family)) %>%
  dplyr::select(-c("family", "genus")) %>%
  dplyr::mutate(taxa = list(mixed_species_taxa))

bb_huy_2019_1_spec_nona <- bb_huy_2019_1_spec_all %>%
  dplyr::filter(!is.na(family)) %>%
  aggregate_taxa()

bb_huy_2019_1_spec <- dplyr::bind_rows(
  bb_huy_2019_1_spec_na, bb_huy_2019_1_spec_nona
)

bb_huy_2019 <- FixedEffectsSet(
  response = list(
    bb = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameter_names = c("a_2", "b_21"),
  predict_fn = function(dsob) {
    a_2 * dsob^b_21
  },
  model_specifications = bb_huy_2019_1_spec
)

bf_huy_2019_spec_all <- load_parameter_frame("bf_huy_2019")

bf_huy_2019_spec_na <- bf_huy_2019_spec_all %>%
  dplyr::filter(is.na(family)) %>%
  dplyr::select(-c("family", "genus")) %>%
  dplyr::mutate(taxa = list(mixed_species_taxa))

bf_huy_2019_spec_nona <- bf_huy_2019_spec_all %>%
  dplyr::filter(!is.na(family)) %>%
  aggregate_taxa()

bf_huy_2019_spec <- dplyr::bind_rows(
  bf_huy_2019_spec_na, bf_huy_2019_spec_nona
)

bf_huy_2019 <- FixedEffectsSet(
  response = list(
    bf = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameter_names = c("a_3", "b_31"),
  predict_fn = function(dsob) {
    a_3 * dsob^b_31
  },
  model_specifications = bf_huy_2019_spec
)

bk_huy_2019_spec_all <- load_parameter_frame("bk_huy_2019")

bk_huy_2019_spec_na <- bk_huy_2019_spec_all %>%
  dplyr::filter(is.na(family)) %>%
  dplyr::select(-c("family", "genus")) %>%
  dplyr::mutate(taxa = list(mixed_species_taxa))

bk_huy_2019_spec_nona <- bk_huy_2019_spec_all %>%
  dplyr::filter(!is.na(family)) %>%
  aggregate_taxa()

bk_huy_2019_spec <- dplyr::bind_rows(
  bk_huy_2019_spec_na, bk_huy_2019_spec_nona
)

bk_huy_2019 <- FixedEffectsSet(
  response = list(
    bk = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameter_names = c("a_4", "b_41"),
  predict_fn = function(dsob) {
    a_4 * dsob^b_41
  },
  model_specifications = bk_huy_2019_spec
)

huy_2019 <- huy_2019 %>%
  add_set(bs_huy_2019_1) %>%
  add_set(bs_huy_2019_2) %>%
  add_set(bb_huy_2019) %>%
  add_set(bf_huy_2019) %>%
  add_set(bk_huy_2019)
