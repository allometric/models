# Rewrite the entire set of publications
# This is used locally to initialize (or re-initialize) the entire database,
# which may happen for a variety of reasons
library(mongolite)
library(allometric)
devtools::load_all()

dotenv::load_dot_env()
con_string <- Sys.getenv("MONGODB_URL_DEV")

set_params_path("./parameters")

pub_con <- mongolite::mongo(
  url = con_string, db = "allodev", collection = "publications"
)

model_con <- mongolite::mongo(
  url = con_string, db = "allodev", collection = "models"
)

update_con <- mongolite::mongo(
  url = con_string, db = "allodev", collection = "update"
)

pub_con$drop()
model_con$drop()
update_con$drop()

update_db(pub_con, model_con, update_con)