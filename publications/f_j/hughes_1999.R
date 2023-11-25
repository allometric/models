hughes_1999 <- Publication(
  citation = RefManageR::BibEntry(
    key = "hughes_1999",
    bibtype = "article",
    title = "Biomass, carbon, and nutrient dynamics of secondary forests in a humid tropical region of Mexico",
    author = "Hughes, R Flint and Kauffman, J Boone and Jaramillo, Victor J",
    journal = "Ecology",
    volume = 80,
    number = 6,
    pages = "1892--1907",
    year = 1999,
    publisher = "Wiley Online Library"
  ),
  descriptors = list(
    country = "MX",
    region = "MX-VER"
  )
)

hst <- FixedEffectsModel(
  response = list(
    hst = units::as_units("m")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameters = list(
    a = 4.722,
    b = -13.323
  ),
  predict_fn = function(dsob) {
    a * log(dsob^2) + b
  },
  descriptors = list(
    dsob_limit = "> 10 cm"
  )
)

bt <- FixedEffectsModel(
  response = list(
    bt = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameters = list(
    a = 4.9375,
    b = 1.0583,
    cf = 1.14
  ),
  predict_fn = function(dsob) {
    (exp(a + b * log(dsob^2))) * cf / (10^6)
  },
  descriptors = list(
    dsob_limit = "< 10 cm"
  )
)

bt_palms <- FixedEffectsModel(
  response = list(
    bt = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameters = list(
    a = 3.6272,
    b = 0.5768,
    cf = 1.02
  ),
  predict_fn = function(dsob, hst) {
    (exp(a + b * log(dsob^2 * hst))) * cf / (10^6)
  },
  descriptors = list(
    taxa = Taxa(
      Taxon(
        family = "Arecaceae"
      )
    )
  )
)

hughes_1999 <- hughes_1999 %>%
  add_model(hst) %>%
  add_model(bt) %>%
  add_model(bt_palms)