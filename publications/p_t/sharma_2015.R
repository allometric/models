sharma_2015 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "article",
    key = "sharma_2015",
    title = "Modeling height-diameter relationships for Norway spruce, Scots pine, and downy birch using Norwegian national forest inventory data",
    author = "Sharma, Ram P and Breidenbach, Johannes",
    journal = "Forest Science and Technology",
    volume = 11,
    number = 1,
    pages = "45--53",
    year = 2015,
    publisher = "Taylor & Francis",
    doi = "https://doi.org/10.1080/21580103.2014.957354"
  ),
  descriptors = list(
    country = "NO"
  )
)

hst_1 <- FixedEffectsSet(
  response = list(
    hst = units::as_units("m")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameter_names = c("b_1", "b_2"),
  predict_fn = function(dsob) {
    1.3 + (dsob / (b_1 + b_2 * dsob))^3
  },
  model_specifications = load_parameter_frame(
    "hst_sharma_2015"
  ) %>% aggregate_taxa()
)

sharma_2015 <- sharma_2015 %>%
  add_set(hst_1)
