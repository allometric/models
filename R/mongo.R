#' Update a publication and its models in mongodb
#'
#' This is the main function for updating the DB. This is done by upserting
#' the publication (which contains model references) and then upserting each
#' individual model
#'
#' @param pub_con A mongodatabase connection to the publications collection
#' @param model_con A mongodatabase connection to the models collection
upsert_publication <- function(pub_con, model_con, pub_json, models_json, verbose = TRUE) {
  # Handle the publication collection
  id_obj <- list("_id" = pub_json[["_id"]]) |> jsonlite::toJSON()
  set_obj <- list("$set" = pub_json) |> jsonlite::toJSON()

  if (verbose) {
    print(paste("Upserting publication:", pub_json[["_id"]]))
  }

  # TODO add created datetime, updated datetime (UTC?)
  pub_con$update(id_obj, set_obj, upsert = TRUE)

  for (i in seq_along(models_json)) {
    model_json_i <- models_json[[i]]
    id_obj <- list("_id" = model_json_i[["_id"]]) |> jsonlite::toJSON()
    set_obj <- list("$set" = model_json_i) |> jsonlite::toJSON()

    if (verbose) {
      print(paste("--- Upserting model:", model_json_i[["_id"]]))
    }

    # TODO add created datetime, updated datetime (UTC?)
    model_con$update(id_obj, set_obj, upsert = TRUE)
  }
}

#' Deletes a publication and its member models from the database
delete_pub <- function(pub_con, model_con, pub_id, verbose = TRUE) {
  pub_find <- list("_id" = jsonlite::unbox(pub_id)) |> jsonlite::toJSON()
  pub_db <- pub_con$find(pub_find)
  model_ids <- pub_db$models[[1]]

  model_find <- list(
    "_id" = list(
      "$in" = model_ids
    )
  ) |> jsonlite::toJSON()

  if(verbose) {
    print(paste("Removing", length(model_ids), "model from", pub_id))
  }

  model_con$remove(model_find)

  if(verbose) {
    print(paste("Removing", pub_id))
  }

  pub_con$remove(pub_find)
}

delete_nonexistent_pubs <- function(pub_con, model_con, verbose = TRUE) {
  pub_find <- list(
    "_id" = list(
      "$nin" = get_current_pub_ids()
    )
  ) |> jsonlite::toJSON()

  deleted_pubs <- pub_con$find(pub_find)

  if(verbose) {
    print(paste("Found", nrow(deleted_pubs), "deleted publications"))
  }

  if (nrow(deleted_pubs) > 0) {
    del_ids <- deleted_pubs$pub_id

    for (del_id in del_ids) {
      delete_pub(pub_con, model_con, del_id, verbose)
    }
  }
}

#' Update the database on push
#'
#' This is the main function for updating the database. It proceeds in five
#' phases, meant to remove old/"hangnail" publications and models.
#'  0. Create update collection if it does not exist, this stores the commit
#'     id for the last update
#'  1. Delete all publications that do not exist locally (i.e., in publications
#'     directory). Delete all models belonging to these
#'  2. Determine which publications have been modified since last commit
#'  3. Generate JSON for modified publications+models, retain newly generated
#'     model IDs
#'  4. Upsert the JSON for modified publications
#'  5. Delete any models belonging to the modified publications that are not in
#'     the set of new model IDs. These should represent modified models
update_db <- function(pub_con, model_con, verbose = TRUE) {
  delete_nonexistent_pubs(pub_con, model_con, verbose)

  modified_pub_ids <- get_modified_files()

  
}
