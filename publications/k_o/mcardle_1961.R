mcardle_1961 <- Publication(
  citation = RefManageR::BibEntry(
    bibtype = "techreport",
    key = "mcardle_1961",
    title = "The Yield of Douglas-fir in the Pacific Northwest",
    author = "McArdle, Richard E and Meyer, Walter H and Bruce, Donald",
    volume = 201,
    year = 1961,
    institution = "United States Department of Agriculture"
  ),
  descriptors = list(
    country = "US",
    region = c("US-OR", "US-WA"),
    taxa = Taxa(
      Taxon(
        family = "Pinaceae",
        genus = "Pseudotsuga",
        species = "menziesii"
      )
    )
  )
)

# These functions and parameter estimates are from:
# Hanson, Erica J., David L. Azuma, and Bruce A. Hiserote. "Site index equations
# and mean annual increment equations for Pacific Northwest Research Station
# forest inventory and analysis inventories, 1985-2001." Res. Note PNW-RN-533.
# Portland, OR US Department of Agriculture, Forest Service, Pacific Northwest
# Research Station. 24 p 533 (2003).
#
# The original publication (McArdle (1930)) does not appear to publish the
# functions directly. I am guessing that Hanson et al. approximated the
# functions they give using the tables/figures McArdle reports. In any case,
# McArdle deserve the credit. The age_class specification is given by Hanson.

specifications <- tibble::tibble(
  age_class = c("< 40", ">= 40"),
  a = c(3.3, 2.1),
  b = c(-0.8, -0.47),
  c = 0.96,
  d = -2.66
)

hstix_df <- FixedEffectsSet(
  response = list(
    hstix50 = units::as_units("ft")
  ),
  covariates = list(
    hst = units::as_units("ft"),
    atb = units::as_units("years")
  ),
  parameter_names = c("a", "b", "c", "d"),
  model_specifications = specifications,
  predict_fn = function(hst, atb) {
    exp(a + (b * log(atb))) * (c * hst + d)
  }
)

mcardle_1961 <- mcardle_1961 %>%
  add_set(hstix_df)