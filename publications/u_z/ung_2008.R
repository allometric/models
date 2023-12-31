ung_2008 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "article",
    key = "ung_2008",
    title = "Canadian national biomass equations: new parameter estimates that include British Columbia data",
    author = "Ung, Chhun-Huor and Bernier, Pierre and Guo, Xiao-Jing",
    doi = "https://doi.org/10.1139/X07-224",
    issn = "0045-5067",
    journal = "Canadian Journal of Forest Research",
    volume = 38,
    number = 5,
    month = "may",
    url = "http://www.nrcresearchpress.com/doi/abs/10.1139/X07-224",
    pages = "1123--1132",
    year = 2008,
    publisher = "NRC Research Press Ottawa, Canada"
  ),
  descriptors = list(
    country = "CA"
  )
)

b_params <- load_parameter_frame('b_ung_2008') %>%
  aggregate_taxa()

taxa_key <- b_params %>%
  dplyr::select(model, region, code, taxa) %>%
  dplyr::group_by(model, region, code) %>%
  dplyr::filter(dplyr::row_number() == 1)

b_params <- b_params %>%
  dplyr::mutate(na_genus = purrr::map_lgl(taxa, ~ "NA" %in% .)) %>%
  dplyr::select(-c(taxa))

dia_b_params <- b_params %>% dplyr::filter(model == "DBH")
dia_b_params_names <- unique(dia_b_params$parameter)

diaht_b_params <- b_params %>% dplyr::filter(model == "DBHHT")
diaht_b_params_names <- unique(diaht_b_params$parameter)

dia_response_funcs <- list(
  wood = function(dsob) {
    bwood1 * dsob^bwood2
  },
  bark = function(dsob) {
    bbark1 * dsob^bbark2
  },
  branches = function(dsob) {
    bbranches1 * dsob^bbranches2
  },
  foliage = function(dsob) {
    bfoliage1 * dsob^bfoliage2
  }
)

diaht_response_funcs <- list(
  wood = function(dsob, hst) {
    bwood1 * dsob^bwood2 * hst^bwood3
  },
  bark = function(dsob, hst) {
    bbark1 * dsob^bbark2 * hst^bbark3
  },
  branches = function(dsob, hst) {
    bbranches1 * dsob^bbranches2 * hst^bbranches3
  },
  foliage = function(dsob, hst) {
    bfoliage1 * dsob^bfoliage2 * hst^bfoliage3
  }
)

dia_covariates <- list(dsob = units::as_units("cm"))
diaht_covariates <- list(
  dsob = units::as_units("cm"),
  hst = units::as_units("m")
)

response_defs <- list(
  wood = "bs",
  bark = "bk",
  branches = "bb",
  foliage = "bf"
)

construct_ung_set <- function(category, b_params, b_params_names,
  covariates, response_funcs, na_genus) {
  response <- list()
  response[[response_defs[[category]]]] <- units::as_units("kg")


  parameter_names <- b_params_names[grepl(category, b_params_names, fixed=T)]

  if(!na_genus) {
    b_params <- b_params %>% dplyr::filter(na_genus != "NA")
  } else {
    b_params <- b_params %>% dplyr::filter(na_genus == "NA")
  }

  if(!na_genus) {
    model_specifications <- b_params %>%
      dplyr::filter(parameter %in% parameter_names) %>%
      tidyr::pivot_wider(names_from = parameter, values_from = estimate) %>%
      dplyr::left_join(taxa_key, by = c("model", "region", "code")) %>%
      dplyr::select(-c(model, code)) %>%
      dplyr::mutate(region = as.list(strsplit(region, ", ")))
  } else {
    model_specifications <- b_params %>%
      dplyr::filter(parameter %in% parameter_names) %>%
      tidyr::pivot_wider(names_from = parameter, values_from = estimate) %>%
      dplyr::left_join(taxa_key, by = c("model", "region", "code")) %>%
      dplyr::mutate(region = as.list(strsplit(region, ", "))) %>%
      dplyr::mutate(species_group = dplyr::recode(code, UNKN.HWD = "hardwood", UNKN.SWD = "softwood", UNKN.SPP = "all")) %>%
      dplyr::select(-c(model, code))
  }

  FixedEffectsSet(
    response = response,
    covariates = covariates,
    parameter_names = parameter_names,
    predict_fn = response_funcs[[category]],
    model_specifications = model_specifications
  )
}

# Diameter-only models with at least a genus defined
for (i in seq_along(dia_response_funcs)) {
  category <- names(dia_response_funcs)[[i]]

  set <- construct_ung_set(
    category,
    dia_b_params,
    dia_b_params_names,
    dia_covariates,
    dia_response_funcs,
    na_genus = FALSE
  )

  ung_2008 <- ung_2008 %>% add_set(set)
}

# Dia-ht models with at least a genus defined
for (i in seq_along(dia_response_funcs)) {
  category <- names(dia_response_funcs)[[i]]

  set <- construct_ung_set(
    category,
    diaht_b_params,
    diaht_b_params_names,
    diaht_covariates,
    diaht_response_funcs,
    na_genus = FALSE
  )

  ung_2008 <- ung_2008 %>% add_set(set)
}

# Diameter-only models of "pooled" models
for (i in seq_along(dia_response_funcs)) {
  category <- names(dia_response_funcs)[[i]]

  set <- construct_ung_set(
    category,
    dia_b_params,
    dia_b_params_names,
    dia_covariates,
    dia_response_funcs,
    na_genus = TRUE
  )

  ung_2008 <- ung_2008 %>% add_set(set)
}

# Dia-ht models of "pooled" models
for (i in seq_along(dia_response_funcs)) {
  category <- names(dia_response_funcs)[[i]]

  set <- construct_ung_set(
    category,
    diaht_b_params,
    diaht_b_params_names,
    diaht_covariates,
    diaht_response_funcs,
    na_genus = TRUE
  )

  ung_2008 <- ung_2008 %>% add_set(set)
}