parse_parameter_names <- function(filenames) {
  pattern <- "(?:.*_)?([a-zA-Z]+)_(\\d{4}[a-zA-Z]?)(?:_.*)?\\.csv"
  matches <- stringr::str_match(filenames, pattern)

  unique(paste0(matches[,2], "_", matches[,3]))
}

get_modified_files <- function() {
  # FIXME assumes one commit is pushed at a time...
  files <- system("git diff --name-only HEAD~1 HEAD", intern = TRUE)

  modified_via_params <- files[startsWith(files, "parameters")] |>
    basename() |>
    parse_parameter_names()

  modified_via_pubs <- files[startsWith(files, "publications")] |>
    basename() |>
    tools::file_path_sans_ext()

  unique(c(modified_via_params, modified_via_pubs))
}