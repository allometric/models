#' Load a parameter frame from the models/parameters directory
#'
#' This is a convenience function that allows a user to easily load parameter
#' files from a directory, and is typically used when creating
#' `FixedEffectsSet`. By default the function will load parameter frames
#' from an existing `allometric` installation. For the purposes of testing
#' publication files locally, refer to `set_params_path`.
#'
#' @param name The name of the file, excluding the extension
#' @return A tibble::tbl_df of the parameter data.
#' @export
load_parameter_frame <- function(name) {
  csv_name <- paste(name, ".csv", sep = "")
  param_search_path <- get_params_path()
  
  if(param_search_path == "package") {
    file_path <- system.file(
      "models-main/parameters", csv_name,
      package = "allometric"
    )
  } else {
    file_path <- file.path(param_search_path, csv_name)
  }

  table <- utils::read.csv(file_path, na.strings = "")
  tibble::as_tibble(table)
}

#' Set the parameter search path
#'
#' The parameter search path is where `allometric` looks for parameter frames.
#' By default, the package searches the local installation, however it is
#' useful when testing publication files to search a local directory, which
#' can be set here.
#'
#' @param params_path The file path containing parameter files
#' @export
set_params_path <- function(params_path) {
  params_path <- list(params_path = params_path)
  rds_path <- file.path(system.file("extdata", package = "allometric"), "params_path.RDS")
  saveRDS(params_path, rds_path)
}

#' Get the parameter search path
#'
#' @return A string containing the currently set parameter search path
#' @export
get_params_path <- function() {
  rds_path <- file.path(system.file("extdata", package = "allometric"), "params_path.RDS")
  rds <- readRDS(rds_path)
  rds$params_path
}
