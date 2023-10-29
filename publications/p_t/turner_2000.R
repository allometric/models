turner_2000 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "article",
    key = "turner_2000",
    title = "Assessing alternative allometric algorithms for estimating leaf area of Douglas-fir trees and stands",
    author = "Turner, David P and Acker, Steven A and Means, Joseph E and Garman, Steven L",
    journal = "Forest Ecology and Management",
    volume = 126,
    number = 1,
    pages = "61--76",
    year = 2000,
    publisher = "Elsevier",
    doi = "https://doi.org/10.1016/S0378-1127(99)00083-3"
  ),
  descriptors = list(
    country = "US",
    region = "US-OR"
  )
)

bf <- FixedEffectsSet(
  response = list(
    bf = units::as_units("kg")
  ),
  covariates = list(
    dsob = units::as_units("cm")
  ),
  parameter_names = c("a", "b"),
  predict_fn = function(dsob) {
    exp(a + (b * log(dsob)))
  },
  model_specifications = tibble::tibble(
    taxa = list(
      Taxa(
        Taxon(
          family = "Pinaceae",
          genus = "Pseudotsuga",
          species = "menziesii"
        )
      ),
      Taxa(
        Taxon(
          family = "Pinaceae",
          genus = "Tsuga",
          species = "heterophylla"
        )
      ),
      Taxa(
        Taxon(
          family = "Cupressaceae",
          genus = "Thuja",
          species = "plicata"
        )
      )
    ),
    a = c(-2.846, -4.130, -2.617),
    b = c(1.701, 2.128, 1.782)
  )
)

turner_2000 <- add_set(turner_2000, bf)
