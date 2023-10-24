temesgen_2007 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "article",
    key = "temesgen_2007",
    title = "Regional height--diameter equations for major tree species of southwest Oregon",
    author = "Temesgen, Hailemariam and Hann, David W and Monleon, Vincente J",
    journal = "Western Journal of Applied Forestry",
    volume = 22,
    number = 3,
    pages = "213--219",
    year = 2007,
    publisher = "Oxford University Press",
    doi = "https://doi.org/10.1093/wjaf/22.3.213"
  ),
  descriptors = list(
    country = "US",
    region = "US-OR"
  )
)

eq4 <- FixedEffectsSet(
  response = list(
    hst = units::as_units("m")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameter_names = c("a", "b", "c"),
  predict_fn = function(dsob) {
    1.3 + exp(a + b * dsob^c)
  },
  model_specifications = load_parameter_frame("hst_temesgen_2007") %>%
    aggregate_taxa()
)

temesgen_2007 <- temesgen_2007 %>%
  add_set(eq4)