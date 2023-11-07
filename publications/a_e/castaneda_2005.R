castaneda_2005 <- Publication(
  citation =  RefManageR::BibEntry(
    key = "castaneda_2005",
    bibtype = "article",
    title = "Carbon Accumulation in the Aboveground Biomass of a Bambusa oldhamii Plantation",
    author = "Casta{~n}eda-Mendoza, Arturo and Vargas-Hern{'a}ndez, Jes{'u}s and G{'o}mez-Guerrero, Armando and Valdez-Hern{'a}ndez, Juan I and Vaquera-Huerta, Humberto",
    journal = "Agrociencia",
    volume = 39,
    number = 1,
    pages = "107--116",
    year = 2005,
    publisher = "Colegio de Postgraduados"
  ),
  descriptors = list(
    taxa = Taxa(
      Taxon(
        family = "Poaceae",
        genus = "Bambusa",
        species = "oldhamii"
      )
    ),
    country = "MX",
    region = "MX-VER"
  )
)

params <- load_parameter_frame("b_castaneda_2005")
variables <- unique(params$variable)

for(var in variables) {
  var_frame <- params %>%
    dplyr::filter(variable == var) %>%
    dplyr::select(-c(variable))

  response <- list()
  response[[var]] <- units::as_units("g")

  var_set <- FixedEffectsSet(
    response = response,
    covariates = list(
      dsob = units::as_units("cm")
    ),
    parameter_names = c("alpha", "beta"),
    predict_fn = function(dsob) {
      alpha * dsob^beta
    },
    model_specifications = var_frame
  )

  castaneda_2005 <- castaneda_2005 %>%
    add_set(var_set)
}
