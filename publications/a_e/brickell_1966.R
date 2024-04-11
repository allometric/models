brickell_1966 <- Publication(
  citation = RefManageR::BibEntry(
    key = "brickell_1966",
    bibtype = "techreport",
    title = "Site index curves for Engelmann spruce in northern and central Rocky Mountains",
    author = "Brickell, James Earl",
    volume = 42,
    year = 1966,
    institution = "US Department of Agriculture, Forest Service"
  ),
  descriptors = list(
    country = "US",
    region = c("US-ID", "US-MT", "US-WY", "US-CO", "US-UT"),
    taxa = Taxa(
      Taxon(
        family = "Pinaceae",
        genus = "Picea",
        species = "engelmanii"
      )
    )
  )
)

hstix50 <- FixedEffectsModel(
  response = list(
    "hstix50" = units::as_units("ft")
  ),
  covariates = list(
    "atb" = units::as_units("year"),
    "hst" = units::as_units("ft")
  ),
  parameters = c(
    b1 = 10.717283,
    b2 = 0.0046314777,
    b3 = 0.74471147,
    b4 = -26413.763,
    b5 = -0.042819823,
    b6 = -0.0047812062,
    b7 = 0.0000049254336,
    b8 = 0.00000021975906,
    b9 = 5.1675949,
    b10 = -0.000000014349139,
    b11 = -9.481014
  ),
  predict_fn = function(atb, hst) {
    hst + b1 * (log(atb) - log(50)) +
      b2 * ((10^10 / atb^5) - 32) +
      b3 * hst * ((10^4 / atb^2) - 4) +
      b4 * hst * (atb^(-2.5) - 50^(-2.5)) +
      b5 * hst * (log(atb) - log(50))^2 +
      b6 * hst^2 * (10^4 / atb^2 - 4) +
      b7 * hst^2 * (10^10 / atb^5 - 32) +
      b8 * hst^3 * (10^10 / atb^5 - 32) +
      b9 * hst^3 * (atb^(-2.75) - 50^(-2.75)) +
      b10 * hst^4 * (100 / atb - 2) +
      b11 * hst^4 * (atb^(-4.5) - 50^(-4.5))
  }
)

brickell_1966 <- brickell_1966 %>%
  add_model(hstix50)