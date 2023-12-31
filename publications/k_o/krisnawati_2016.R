krisnawati_2016 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "article",
    key = "krisnawati_2016",
    title = "A compatible estimation model of stem volume and taper for Acacia mangium Willd. plantations",
    journal = "Indoensian Journal of Forestry Research",
    author = "Krisnawati, Haruni",
    volume = 3,
    number = 1,
    pages = "49--64",
    year = 2016,
    doi = "https://doi.org/10.20886/ijfr.2016.3.1.49-64"
  ),
  descriptors = list(
    country = "ID",
    region = "ID-SS",
    taxa = Taxa(
      Taxon(
        family = "Fabaceae",
        genus = "Acacia",
        species = "mangium"
      )
    )
  )
)

# Eq. 23
vsoa <- FixedEffectsModel(
  response = list(
    vsoa = units::as_units("m^3")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameters = list(
    a = 0.0000636,
    b = 1.736,
    c = 1.0734
  ),
  predict_fn = function(dsob, hst) {
    a * dsob^b * hst^c
  }
)

# Eq. 24
vsia <- FixedEffectsModel(
  response = list(
    vsia = units::as_units("m^3")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m")
  ),
  parameters = list(
    a = 0.0000542,
    b = 1.0778,
    c = 1.04
  ),
  predict_fn = function(dsob, hst) {
    a * dsob^b * hst^c
  }
)

# Eq. 25
dsoh <- FixedEffectsModel(
  response = list(
    dsoh = units::as_units("cm")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m"),
    hsl = units::as_units("m")
  ),
  parameters = list(
    a = 1.384,
    b = 0.8678,
    c = -0.6393,
    d = 0.676
  ),
  predict_fn = function(dsob, hst, hsl) {
    a * dsob^b * hst^c * hsl^d
  }
)


# Eq. 26
dsih <- FixedEffectsModel(
  response = list(
    dsih = units::as_units("cm")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m"),
    hsl = units::as_units("m")
  ),
  parameters = list(
    a = 1.256,
    b = 0.889,
    c = -0.6213,
    d = 0.643
  ),
  predict_fn = function(dsob, hst, hsl) {
    a * dsob^b * hst^c * hsl^d
  },
  descriptors = list(
    volume_type = "merchantable volume outside bark to specified height"
  )
)

# Eq. 27
vsom <- FixedEffectsModel(
  response = list(
    vsom = units::as_units("m^3")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m"),
    dsoh = units::as_units("cm")
  ),
  parameters = list(
    a = 0.0000636,
    b = 1.736,
    c = -1.2786,
    d = 2.352,
    e = 0.326,
    f = 3.479,
    g = -3.019,
    h = 2.224
  ),
  predict_fn = function(dsob, hst, dsoh) {
    a * dsob^b * hst^c * (hst^d - (e * dsoh^f * dsob^g * hst^h))
  }
)

# Eq. 28
vsim <- FixedEffectsModel(
  response = list(
    vsim = units::as_units("m^3")
  ),
  covariates = list(
    dsob = units::as_units("cm"),
    hst = units::as_units("m"),
    dsih = units::as_units("cm")
  ),
  parameters = list(
    a = 0.0000542,
    b = 1.778,
    c = -1.2426,
    d = 2.286,
    e = 0.445,
    f = 3.555,
    g = -3.161,
    h = 2.209
  ),
  predict_fn = function(dsob, hst, dsih) {
    a * dsob^b * hst^c * (hst^d - (e * dsih^f * dsob^g * hst^h))
  },
  descriptors = list(
    volume_type = "merchantable volume inside bark to specified height"
  )
)

krisnawati_2016 <- krisnawati_2016 %>%
  add_model(vsoa) %>%
  add_model(vsia) %>%
  add_model(dsoh) %>%
  add_model(dsih) %>%
  add_model(vsim) %>%
  add_model(vsom)
