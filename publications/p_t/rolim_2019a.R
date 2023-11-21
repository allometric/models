rolim_2019a <- Publication(
  citation = RefManageR::BibEntry(
    key = "rolim_2019a",
    bibtype = "incollection",
    title = "Biometric Models for Mixed-species Plantation in the North of Espirito Santo, Brazil",
    author = "Rolim, Samir and Orellano, Enrique and Piotto, Daniel and de Souza Vismara, Edgar",
    booktitle = "Silviculture and Wood Properties of Native Species of the Atlantic Forest of Brazil",
    editor = "Rolim, Samir and Piotto, Daniel",
    pages = "21--29",
    year = 2019
  ),
  descriptors = list(
    country = "BR",
    region = "BR-ES"
  )
)

nasland_func <- function(dsob) {
  (dsob / (beta_0 * dsob + beta_1))^2
}

logistic_func <- function(dsob) {
  beta_0 / (1 + beta_2 * exp(-beta_1 * dsob))
}

schumacher_hall_func <- function(dsob, hsm) {
  beta_0 * dsob^beta_1 * hsm^beta_2
}

model_5_func <- function(dsob, hst, rwd) {
  beta_0 * dsob^beta_1 * hst^beta_2 * rwd^beta_3
}

table_2_naslund_hst <- FixedEffectsModel(
  response = list(
    hst = units::as_units("m")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameters = list(
    beta_0 = 0.1749,
    beta_1 = 1.6080
  ),
  predict_fn = nasland_func
)

table_2_logistic_hsm <- FixedEffectsModel(
  response = list(
    hsm = units::as_units("m")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameters = list(
    beta_0 = 12.0811,
    beta_1 = 0.1630,
    beta_2 = 9.3199
  ),
  predict_fn = logistic_func
)

table_3_schumacher_hall_vs <- FixedEffectsModel(
  response = list(
    vsim = units::as_units("m^3")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hsm = units::as_units("m")
  ),
  parameters = list(
    beta_0 = 1.110 * 10^-4,
    beta_1 = 2.0479,
    beta_2 = 0.6352
  ),
  predict_fn = schumacher_hall_func,
)

table_4_model_5 <- FixedEffectsModel(
  response = list(
    bt = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m"),
    rwd = units::as_units("g/cm^3")
  ),
  parameters = list(
    beta_0 = 0.1009,
    beta_1 = 2.2472,
    beta_2 = 0.4333,
    beta_3 = 0.7865
  ),
  predict_fn = model_5_func
)

rolim_2019a <- rolim_2019a %>%
  add_model(table_2_naslund_hst) %>%
  add_model(table_2_logistic_hsm) %>%
  add_model(table_3_schumacher_hall_vs) %>%
  add_model(table_4_model_5)