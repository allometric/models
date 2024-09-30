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

#' Get a vector of pub_ids that do not exist in the set of currently maintained
#' pub ids
get_nonexistent_pubs <- function(pub_con, verbose = TRUE) {
  pub_find <- list(
    "_id" = list(
      "$nin" = get_current_pub_ids()
    )
  ) |> jsonlite::toJSON()

  nonexistent_pubs <- pub_con$find(pub_find, fields = '{}')

  if(verbose) {
    print(paste("Found", nrow(nonexistent_pubs), "nonexistent publications"))
  }

  if(nrow(nonexistent_pubs) > 0) {
    return(nonexistent_pubs$`_id`)
  } else {
    return(NULL)
  }
}

#' Delete a set of publications and their models
delete_pubs <- function(pub_con, model_con, pub_ids, verbose = TRUE) {
  for (del_id in pub_ids) {
    delete_pub(pub_con, model_con, del_id, verbose)
  }
}

get_last_update_commit <- function(update_con) {
  res <- update_con$find("{}", sort = '{"datetime": -1}')

  if (nrow(res) == 0) { # The collection is empty
    return(NULL)
  } else {
    commit_id <- substr(res$commit_id[[1]], 1, 7)
    return(commit_id)
  }
}

write_update_commit <- function(update_con, current_commit = NULL) {
  if(is.null(current_commit)) {
    current_commit <- system("git rev-parse HEAD", intern = TRUE)
  }

  insert_obj <- list(
    datetime = as.integer(Sys.time()) |> jsonlite::unbox(),
    commit_id = current_commit |> jsonlite::unbox()
  ) |> jsonlite::toJSON()

  update_con$insert(insert_obj)
}

#' Update the database on push
#'
#' This is the main function for updating the database. It proceeds in five
#' phases, meant to remove old/"hangnail" publications and models.
#'  1. Delete all nonexistent publications from db (i.e., publications
#'     no longer in directory) and their models
#'  2. Determine which publications have been modified since last commit
#'  3. Generate JSON for modified publications+models, retain newly generated
#'     model IDs
#'  4. Upsert the JSON for modified publications
#'  5. Delete any models belonging to the modified publications that are not in
#'     the set of new model IDs. These should represent modified models
update_db <- function(pub_con, model_con, update_con, verbose = TRUE, last_commit = NULL) {
  nonexistent_pubs <- get_nonexistent_pubs(pub_con, verbose = verbose)

  if (!is.null(nonexistent_pubs)) {
    delete_pubs(pub_con, model_con, nonexistent_pubs, verbose = verbose)
  }

  if(is.null(last_commit)) {
    last_commit <- get_last_update_commit(update_con)
  }

  if(is.null(last_commit)) {
    # Process all pub files
    procd_pubs <- map_publications(
      verbose = TRUE, publication_to_json,
      pub_path = "./publications", params_path = "./parameters"
    )
  } else {
    mod_files <- get_modified_files(last_commit)
    mod_files <- mod_files[!mod_files %in% nonexistent_pubs]

    if (length(mod_files) > 0) {
      procd_pubs <- map_publications(
        verbose = TRUE, publication_to_json,
        pub_path = "./publications", params_path = "./parameters",
        subset_ids = mod_files
      )
    } else {
      if(verbose) {
        print(
          paste("No modified publications found since commit", last_commit)
        )
      }

      procd_pubs <- c()
    }
  }

  for (i in seq_along(procd_pubs)) {
    pub_json <- procd_pubs[[i]][["pub_json"]]
    models_json <- procd_pubs[[i]][["models_json"]]

    upsert_publication(pub_con, model_con, pub_json, models_json)
  }

  write_update_commit(update_con)
}