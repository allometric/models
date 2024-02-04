forrester_2017 <- Publication(
  citation = RefManageR::BibEntry(
    key = "forrester_2017",
    bibtype = "article",
    title = "Generalized biomass and leaf area allometric equations for European tree species incorporating stand structure, tree age and climate",
    author = "Forrester, David I and Tachauer, I Heloise H and Annighoefer, Peter and Barbeito, Ignacio and Pretzsch, Hans and Ruiz-Peinado, Ricardo and Stark, Hendrik and Vacchiano, Giorgio and Zlatanov, Tzvetan and Chakraborty, Tamalika and others",
    journal = "Forest Ecology and Management",
    volume = 396,
    pages = "160--175",
    year = 2017,
    publisher = "Elsevier"
  ),
  descriptors = list(
    country = c(
      "AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR",
      "HU", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI",
      "ES"
    )
  )
)

# Using only those used in Table A.5
pred_fns <- list(
  "3" = list(
    fn = function(dsob) {
      exp(log(beta_0) + beta_1 * log(dsob)) * cf
    },
    covts = list(
      dsob = units::as_units("cm")
    )
  ),
  "4" = list(
    fn = function(dsob, gs_s) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * gs_s) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      gs_s = units::as_units("m^2 * ha^-1")
    )
  ),
  "5" = list(
    fn = function(dsob, att) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * log(att)) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      att = units::as_units("years")
    )
  ),
  "6" = list(
    fn = function(dsob, es) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * log(es)) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      es =  units::as_units("ha^-1")
    )
  ),
  "7" = list(
    fn = function(dsob, nol) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * nol) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      nol = units::as_units("degree")
    )
  ),
  "8" = list(
    fn = function(dsob, hlp) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * hlp) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      hlp = units::as_units("mm")
    )
  ),
  "9" = list(
    fn = function(dsob, tl) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * tl) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      tl = units::as_units("C")
    )
  ),
  "10" = list(
    fn = function(dsob, gs_s, att) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * gs_s + beta_3 * log(att)) *
        cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      gs_s = units::as_units("m^2 * ha^-1"),
      att = units::as_units("years")
    )
  ),
  "11" = list(
    fn = function(dsob, gs_s, es) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * gs_s + beta_3 * log(es)) *
        cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      gs_s = units::as_units("m^2 * ha^-1"),
      es =  units::as_units("ha^-1")
    )
  ),
  "12" = list(
    fn = function(dsob, gs_s, nol) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * gs_s + beta_3 * nol) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      gs_s = units::as_units("m^2 * ha^-1"),
      nol = units::as_units("degree")
    )
  ),
  "13" = list(
    fn = function(dsob, gs_s, hlp) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * gs_s + beta_3 * hlp) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      gs_s = units::as_units("m^2 * ha^-1"),
      hlp = units::as_units("mm")
    )
  ),
  "14" = list(
    fn = function(dsob, gs_s, tl) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * gs_s + beta_3 * tl) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      gs_s = units::as_units("m^2 * ha^-1"),
      tl = units::as_units("C")
    )
  ),
  "15" = list(
    fn = function(dsob, att, es) {
      exp(
        log(beta_0) + beta_1 * log(dsob) + beta_2 * log(att) + beta_3 * log(es)
      ) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      att = units::as_units("years"),
      es =  units::as_units("ha^-1")
    )
  ),
  "16" = list(
    fn = function(dsob, es, hlp) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * log(es) + beta_3 * hlp) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      es =  units::as_units("ha^-1"),
      hlp = units::as_units("mm")
    )
  ),
  "17" = list(
    fn = function(dsob, es, tl) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * log(es) + beta_3 * tl) * cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      es =  units::as_units("ha^-1"),
      tl = units::as_units("C")
    )
  ),
  "18" = list(
    fn = function(dsob, es, noa) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * log(es) + beta_3 * noa) *
        cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      es =  units::as_units("ha^-1"),
      noa = units::as_units("degree")
    )
  ),
  "19" = list(
    fn = function(dsob, att, hlp) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * log(att) + beta_3 * hlp) *
        cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      att = units::as_units("years"),
      hlp = units::as_units("mm")
    )
  ),
  "20" = list(
    fn = function(dsob, att, tl) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * log(att) + beta_3 * tl) *
        cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      att = units::as_units("years"),
      tl = units::as_units("C")
    )
  ),
  "21" = list(
    fn = function(dsob, att, nol) {
      exp(log(beta_0) + beta_1 * log(dsob) + beta_2 * log(att) + beta_3 * nol) *
        cf
    },
    covts = list(
      dsob = units::as_units("cm"),
      att = units::as_units("years"),
      nol = units::as_units("degree")
    )
  )
)

taxa_models_params <- load_parameter_frame("b_forrester_2017_1")
taxa_models_params$proc_group <- "taxa"

nontaxa_models_params <- load_parameter_frame("b_forrester_2017_2")
nontaxa_models_params$proc_group <- "nontaxa"

models_params <- dplyr::bind_rows(taxa_models_params, nontaxa_models_params)

response_types <- list(
  "aboveground" = list(
    "bt" = units::as_units("kg")
  ),
  "stem mass" = list(
    "bs" = units::as_units("kg")
  ),
  "stem + branch mass" = list(
    "bsr" = units::as_units("kg")
  ),
  "foliage mass" = list(
    "bf" = units::as_units("kg")
  ),
  "total branch" = list(
    "bb" = units::as_units("kg")
  ),
  "dead branch" = list(
    "bbd" = units::as_units("kg")
  ),
  "live branch" = list(
    "bbl" = units::as_units("kg")
  ),
  "root mass" = list(
    "br" = units::as_units("kg")
  ),
  "leaf area" = list(
    "rfa" = units::as_units("m^2")
  )
)

add_model_group <- function(params_group, key) {
  eq_no <- as.character(key$equation)
  component <- as.character(key$component)

  response <- response_types[[component]]
  covariates <- pred_fns[[eq_no]][["covts"]]
  pred_fn <- pred_fns[[eq_no]][["fn"]]

  params_data <- params_group %>% dplyr::select(c("beta_1", "beta_2", "beta_3", "cf"))

  na_cols <- names(which(sapply(params_data, anyNA)))
  non_na_data <- params_group %>% dplyr::select(-na_cols)

  proc_group <- as.character(key$proc_group)

  if(proc_group == "taxa") {
    agged_params <- non_na_data %>% aggregate_taxa(grouping_col = "taxa_id")

    param_vals <- agged_params %>%
      dplyr::select(-c("equation", "component", "taxa", "proc_group", "species_group"))      
  } else if (proc_group == "nontaxa") {
    agged_params <- non_na_data %>% dplyr::select(-c("family", "genus", "species", "taxa_id"))

    param_vals <- agged_params %>%
      dplyr::select(-c("equation", "component", "proc_group", "species_group"))
  }

  if(nrow(params_group) == 1) {
    # Add a standalone model
    mod_params <- as.list(param_vals)

    if(proc_group == "taxa") {
      descriptors <- list(
        eq_no = eq_no,
        taxa = agged_params$taxa[[1]]
      )
    } else if (proc_group == "nontaxa") {
      descriptors <- list(
        eq_no = eq_no,
        species_group = as.character(agged_params$species_group[[1]])
      )
    }

    model <- FixedEffectsModel(
      response = response,
      covariates = covariates,
      parameters = mod_params,
      predict_fn = pred_fn,
      descriptors = descriptors
    )

    model_group <- list("model" = model)
  } else {
    # Add a model set
    model <- FixedEffectsSet(
      response = response,
      covariates = covariates,
      parameter_names = names(param_vals),
      predict_fn = pred_fn,
      model_specifications = agged_params
    )

    model_group <- list("set" = model)
  }

  model_group
}


iter_keys <- models_params %>% dplyr::distinct(equation, component, proc_group)

for(i in 1:nrow(iter_keys)) {
  iter_key <- iter_keys[i,]
  iter_data <- models_params %>%
    dplyr::right_join(iter_key, by = c("equation", "component", "proc_group"))

  model_group <- add_model_group(iter_data, iter_key)

  if(names(model_group)[[1]] == "model") {
    forrester_2017 <- add_model(forrester_2017, model_group[[1]])
  } else if(names(model_group)[[1]] == "set") {
    forrester_2017 <- add_set(forrester_2017, model_group[[1]])
  }
}