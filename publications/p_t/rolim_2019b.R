rolim_2019b <- Publication(
  citation = RefManageR::BibEntry(
    key = "rolim_2019b",
    bibtype = "incollection",
    title = "Diameter Growth Models for 35 Atlantic Forest Tree Species in Silvicultural Trials in the North of Espirito Santo, Brazil",
    author = "Rolim, Samir and Piotto, Daniel and Orellana, Enrique",
    booktitle = "Silviculture and Wood Properties of Native Species of the Atlantic Forest of Brazil",
    editor = "Rolim, Samir and Piotto, Daniel",
    pages = "31--44",
    year = 2019
  ),
  descriptors = list(
    country = "BR",
    region = "BR-ES"
  )
)

dia_gro_funcs <- list(
  H = function(att) {
    A * (1 + c * exp(-k * log(att)))^-1
  },
  W = function(att) {
    A * (1 - exp(-k * att^c))
  },
  K = function(att) {
    A * exp(-k * att^(-c))
  },
  G = function(att) {
    A * exp(-c * exp(-k * att))
  }
)

params <- load_parameter_frame("dsob_rolim_2019b") %>%
  aggregate_taxa()

pred_fns <- unique(params$pred_fn)

for(pred_fn_name in pred_fns) {
  func <- dia_gro_funcs[[pred_fn_name]]

  set <- FixedEffectsSet(
    response = list(
      dsob = units::as_units("cm")
    ),
    covariates = list(
      att = units::as_units("years")
    ),
    predict_fn = func,
    parameter_names = c("A", "k", "c"),
    model_specifications = params %>% dplyr::filter(pred_fn == pred_fn_name)
  )

  rolim_2019b <- rolim_2019b %>% add_set(set)
}