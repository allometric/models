#' Parse parameter file names for publication IDs
#'
#' @param filenames A vector of parameter CSV filenames (including extension)
#' @return A vector of unique publication IDs
parse_parameter_names <- function(filenames) {
  pattern <- "(?:.*_)?([a-zA-Z]+)_(\\d{4}[a-zA-Z]?)(?:_.*)?\\.csv"
  matches <- stringr::str_match(filenames, pattern)

  if(nrow(matches) == 0) {
    return(NULL)
  } else {
    return(unique(paste0(matches[,2], "_", matches[,3])))
  }
}

#' Get publication IDs modified since a specified commit
#'
#' @param last_commit The commit ID to check to
get_modified_files <- function(last_commit) {
  sys_string <- paste0("git diff --name-only ", last_commit, " HEAD")
  files <- system(sys_string, intern = TRUE)

  modified_via_params <- files[startsWith(files, "parameters")] |>
    basename() |>
    parse_parameter_names()

  modified_via_pubs <- files[startsWith(files, "publications")] |>
    basename() |>
    tools::file_path_sans_ext()

  unique_files <- unique(c(modified_via_params, modified_via_pubs))
  return(unique_files)
}