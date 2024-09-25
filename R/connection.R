#' Establish a connection to the models collection
#'
#' @param url A mongodb url connection string
get_model_con <- function(url) {
  mongolite::mongo(
    url = url, db = "allodev", collection = "models"
  )
}

#' Establish a connection to the publications collection
#'
#' @param url A mongodb url connection string
get_pub_con <- function(url) {
  mongolite::mongo(
    url = url, db = "allodev", collection = "publications"
  )
}

#' Establish a connection to the update collection
#'
#' @param url A mongodb url connection string
get_update_con <- function(url) {
  mongolite::mongo(
    url = url, db = "allodev", collection = "update"
  )
}