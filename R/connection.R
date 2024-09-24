get_model_con <- function(url) {
  mongolite::mongo(
    url = url, db = "allodev", collection = "models"
  )
}

get_pub_con <- function(url) {
  mongolite::mongo(
    url = url, db = "allodev", collection = "publications"
  )
}

get_update_con <- function(url) {
  mongolite::mongo(
    url = url, db = "allodev", collection = "update"
  )
}