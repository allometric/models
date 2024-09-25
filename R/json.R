#' Convert citation authors to JSON
#'
#' @param authors A list of Person objects
#' @return A list containing each author, with `given` and `family` name fields
authors_to_json <- function(authors) {
  out <- list()

  for(i in seq_along(authors)) {
    author_parsed <- list(
      given = paste(authors[[i]]$given, collapse = " "),
      family = paste(authors[[i]]$family, collapse = " ")
    )

    out[[i]] <- author_parsed
  }

  out
}

#' Convert citation to JSON
#'
#' @param citation The citation of a publication, as a `RefManageR::BibEntry`
#'  object
#' @return A JSON representation of the citation
citation_to_json <- function(citation) {
  # Prepare output list with required fields
  unclassed_citation <- attributes(unclass(citation)[[1]])
  prepared_authors <- authors_to_json(citation$author)

  optional <- c(
    "institution", "publisher", "journal", "volume", "number", "pages",
    "address", "month", "school", "note", "organization", "series", "booktitle",
    "editor", "howpublished"
  )

  required <- list(
    title = jsonlite::unbox(citation$title),
    bibtype = jsonlite::unbox(unclassed_citation$bibtype),
    pub_id = jsonlite::unbox(unclassed_citation$key),
    year = jsonlite::unbox(as.numeric(citation$year)),
    authors = prepared_authors
  )

  for(opt in optional) {
    val <- do.call("$", list(citation, opt))

    if(!is.null(val)) {
      if (opt == "editor") {
        required[[opt]] <- authors_to_json(val)
      } else {
        required[[opt]] <- jsonlite::unbox(val)
      }
    }
  }

  required
}

#' Convert variables to JSON
#'
#' @param variables A list containing variables, via `response` or `covariates`
#'  slots of a model
#' @return A list of parsed variables
variables_to_json <- function(variables) {
  variable_names <- names(variables)
  out <- list()

  for(i in 1:length(variables)) {
    out[[i]] <- list(
      name = variable_names[[i]],
      unit = allometric:::parse_unit_str(variables[i])
    )
  }

  out
}

#' Unbox the elements of a nested list
#'
#' @param object A nested list
#' @return A list with nested elements unboxed
unbox_nested <- function(object) {
  for(i in 1:length(object)) {
    for(j in 1:length(object[[i]])) {
      object[[i]][[j]] <- jsonlite::unbox(object[[i]][[j]])
    }
  }
  object
}

#' Unbox the elements of a list
#'
#' @param object A nonnested list
#' @return A list with each element unboxed
unbox_nonnested <- function(object) {
  for(i in 1:length(object)) {
    object[[i]] <- jsonlite::unbox(object[[i]])
  }

  object
}

#' Convert a taxa object to JSON
#'
#' @param taxa An `allometric::Taxa()` object
#' @return A list of taxons in list format
taxa_to_json <- function(taxa) {
  out <- list()

  for(i in seq_along(taxa)) {
    taxon <- taxa[[i]]

    out[[i]] <- list(
      family = taxon@family,
      genus = taxon@genus,
      species = taxon@species
    )
  }

  out
}

#' Convert descriptors to JSON
#' 
#' @param descriptors A list containing descriptors
#' @return A list containing descriptors converted to JSON format
descriptors_to_json <- function(descriptors) {
  descriptors_list <- as.list(descriptors)
  if(length(descriptors_list) == 0) {
    return(NULL) # A null value will be encoded as an empty object in JSON
  } else {
    for(i in 1:length(descriptors_list)) {
      if (inherits(descriptors_list[[i]][[1]], "Taxa")) {
        descriptors_list[[i]] <- taxa_to_json(descriptors_list[[i]][[1]])
      }
      else if(typeof(descriptors_list[[i]]) == "list")  {
        descriptors_list[[i]] <- unlist(descriptors_list[[i]])
      } else if(is.na(descriptors_list[[i]])) {
        descriptors_list[[i]] <- list()
      }
    }
  }

  descriptors_list
}

#' Generate an inline citation
#'
#' @param citation A `RefManageR::BibEntry` object
#' @return A string containing the inline citation
prepare_inline_citation <- function(citation) {
  n_authors <- length(citation$author)

  pub_year <- citation$year
  family_names <- c()

  for(i in 1:n_authors) {
    family_names <- c(family_names, citation$author[[i]]$family)
  }

  if(n_authors == 2) {
    out <- paste(
      family_names[[1]], " and ", family_names[[2]],
      " (", pub_year, ")",
      sep = ""
    )
  } else if(n_authors == 1) {
    out <- paste(
      family_names[[1]], " ",
      "(", pub_year, ")",
      sep = ""
    )
  } else {
    out <- paste(
      family_names[[1]], " et al. ",
      "(", pub_year, ")",
      sep = ""
    )
  }

  out
}

#' Parse a function into a string
#'
#' @param func_body The body of a function
#' @return A string representation of the function
parse_func_body <- function(func_body) {
  body_list <- as.list(body(func_body))[-1]
  body_characters <- c()

  for(i in 1:length(body_list)) {
    deparsed_line <- deparse(body_list[[i]])
    pasted_line <- paste(deparsed_line, collapse = "")
    squished_line <- stringr::str_squish(pasted_line)

    body_characters <- c(body_characters, squished_line)
  }

  body_characters
}

#' Convert covariate definitions to JSON
#'
#' @param covt_def_data A list of covariate definitions
#' @return A list of covariate definitions parsable to JSON
covariate_definitions_to_json <- function(covt_def_data) {
  if(length(covt_def_data) == 0) {
    return(list())
  } else {

    variable_names <- names(covt_def_data)
    out <- list()

    for(i in 1:length(covt_def_data)) {
      out[[i]] <- list(
        name = variable_names[[i]],
        definition = covt_def_data[[i]]
      )
    }

    return(unbox_nested(out))
  }
}

#' Convert model to JSON
#'
#' @param model A model object, i.e., `allometric::FixedEffectsModel()`
#' @return A list containing a parsable form of the model object
model_to_json <- function(model) {
  proxy_id <- get_model_hash(
    model@predict_fn_populated, model@descriptors
  )

  model_id <- substr(proxy_id, 1, 8)
  model_descriptors <- model@descriptors
  model_class <- as.character(class(model))

  response_definition <- ifelse(
    is.na(model@response_definition), "", model@response_definition
  )

  required <- list(
    "_id" = jsonlite::unbox(model_id),
    pub_id = jsonlite::unbox(model@pub_id),
    model_type = jsonlite::unbox(allometric:::get_model_type(names(model@response))[[1]]),
    model_class = jsonlite::unbox(model_class),
    response = unbox_nested(variables_to_json(model@response))[[1]],
    covariates = unbox_nested(variables_to_json(model@covariates)),
    descriptors = descriptors_to_json(model_descriptors),
    parameters = unbox_nonnested(as.list(model@parameters)),
    predict_fn_body = parse_func_body(model@predict_fn)
  )

  if(!is.na(model@response_definition)) {
    required[["response_definition"]] <- jsonlite::unbox(response_definition)
  }

  if(!length(model@covariate_definitions) == 0) {
    required[["covariate_definitions"]] <- covariate_definitions_to_json(model@covariate_definitions)
  }

  required
}

#' Convert a publication to a JSON representation
#'
#' This is the main function for processing publications and the models they
#' contain into JSON, and is used directly by `map_publications`.
#'
#' @param publication The `allometric::Publication` object
#' @return A list containing fields `pub_json`, which is sent to the
#'  publications collection and `models_json`, which is a list of JSON
#'  representations of models in the publication.
publication_to_json <- function(publication) {
  citation_json <- citation_to_json(publication@citation)
  models_json <- list()
  model_ids <- c()

  l <- 1
  for (i in 1:length(publication@response_sets)) { # response set
    response_set_i <- publication@response_sets[[i]]
    for (j in 1:length(response_set_i)) { # model set
      model_set_ij <- response_set_i[[j]]

      for (k in 1:length(model_set_ij@models)) {
        model_ijk <- model_set_ij@models[[k]]
        models_json[[l]] <- model_to_json(model_ijk)
        model_ids <- c(model_ids, models_json[[l]][["_id"]])

        l <- l + 1
      }

    }
  }

  pub_json <- list(
    "_id" = jsonlite::unbox(publication@id),
    citation = citation_json,
    models = model_ids
  )

  list(
    pub_json = pub_json,
    models_json = models_json
  )
}