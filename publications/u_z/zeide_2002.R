zeide_2002 <- Publication(
  citation = RefManageR::BibEntry(
    key = "zeide_2002",
    bibtype = "inproceedings",
    title = "The effect of density on the height-diameter relationship",
    author = "Zeide, Boris and Vanderschaaf, Curtis",
    booktitle = "Proceedings of the 11th Biennial Southern Silvicultural Research Conference",
    pages = "463--466",
    year = 2002,
    organization = "General Technical Report SRS-48. USDA, Forest Service. Southern Research Station"
  ),
  descriptors = list(
    family = "Pinaceae",
    genus = "Pinus",
    species = "taeda",
    country = "US",
    region = "US-AR"
  )
)

normal <- FixedEffectsModel(
  response_unit = list(
    hst_s = units::as_units("ft")
  ),
  covariate_units = list(
    dsob_s = units::as_units("in")
  ),
  parameters = list(
    a = 9.4734,
    b = 0.7374
  ),
  predict_fn = function(dsob_s) {
    a * dsob_s^b
  },
  covariate_definitions = list(
    dsob_s = "Quadratic mean diameter"
  ),
  descriptors = list(
    model_name = "Normal height-diameter relationship"
  )
)

zeide_2002 <- zeide_2002 %>%
  add_model(normal)