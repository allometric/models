# This script writes the local variable naming system into a json representation
library(mongolite)
library(dplyr)
library(tidyr)
dotenv::load_dot_env()

db_url <- Sys.getenv("MONGODB_URL_DEV")

variables_con <- mongo(url = db_url, db = "allodev", collection = "variables")
meta_con <- mongo(url = db_url, db = "allodev", collection = "meta")

var_defs_dir <- system.file("variable_defs", package = "allometric")

csv_paths <- list.files(var_defs_dir, full.names = TRUE)
exceptions <- c("components", "measures", "model_types_defined", "prefix", "suffix")

for(i in seq_along(csv_paths)) {
  path <- csv_paths[[i]]
  filename <- tools::file_path_sans_ext(basename(path))

  if(!filename %in% exceptions) {

    data <- read.csv(path) |>
      unite("variable", -c(description), sep = "", remove = F)

    variables_con$insert(data)
  } else {
    data <- read.csv(path)

    data_list <- list(
      filename = data
    )

    names(data_list) <- filename

    json <- data_list |> jsonlite::toJSON()
    meta_con$insert(json)
  }
}
