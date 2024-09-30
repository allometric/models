# Create the test publication
test_pub_path <- system.file("testdata/test_publications/a_e/barrett_1978.R", package = "models")
source(test_pub_path)
test_pub <- barrett_1978
pub_parsed <- publication_to_json(test_pub)

is_github_action <- function() {
  return(tolower(Sys.getenv("GITHUB_ACTIONS")) == "true")
}



with_mocked_database <- function(code, ...) {
  if(!is_github_action()) {
    # Populates .env into system variables
    dot_env_path <- system.file(".env", package = "models")
    #dotenv::load_dot_env(dot_env_path)
  }

  pub_conn <- mongolite::mongo(
    collection = "publications",
    db = "test",
    url = Sys.getenv("MONGODB_URL_DEV")
  )

  model_conn <- mongolite::mongo(
    collection = "models",
    db = "test",
    url = Sys.getenv("MONGODB_URL_DEV")
  )

  on.exit({
    model_conn$drop()
    pub_conn$drop()
  }, add = TRUE)

  force(code(pub_conn, model_conn, ...))
}

with_mocked_update_conn <- function(code) {
  update_conn <- mongolite::mongo(
    collection = "update",
    db = "test",
    url = Sys.getenv("MONGODB_URL_DEV")
  )

  on.exit({
    update_conn$drop()
  })

  force(code(update_conn))
}

test_that("upsert_publication inserts a document when it does not exist", {
  with_mocked_database(function(pub_conn, model_conn) {

    upsert_publication(
      pub_conn, model_conn, pub_parsed$pub_json, pub_parsed$models_json,
      verbose = FALSE
    )

    pub_res <- pub_conn$find('{}')
    models_res <- model_conn$find('{}', fields = '{}')

    expect_true(nrow(pub_res) == 1)
    expect_equal(pub_res$models[[1]], "cc2078aa")
    expect_equal(pub_res$citation$pub_id, "barrett_1978")

    expect_true(nrow(models_res) == 1)
    expect_equal(models_res$`_id`, "cc2078aa")
  })
})

test_that("upsert_publication updates a document when it does exist", {
  with_mocked_database(function(pub_conn, model_conn) {
    # insert
    upsert_publication(
      pub_conn, model_conn, pub_parsed$pub_json, pub_parsed$models_json,
      verbose = FALSE
    )

    pub_parsed$pub_json$citation$bibtype <- jsonlite::unbox("Article")

    # update
    upsert_publication(
      pub_conn, model_conn, pub_parsed$pub_json, pub_parsed$models_json,
      verbose = FALSE
    )

    pub_res <- pub_conn$find('{}')

    expect_equal(pub_res$citation$bibtype, "Article")
  })
})

test_that("delete_pubs deletes the publication and its member models", {
  with_mocked_database(function(pub_conn, model_conn) {
    upsert_publication(
      pub_conn, model_conn, pub_parsed$pub_json, pub_parsed$models_json,
      verbose = FALSE
    )

    delete_pubs(pub_conn, model_conn, "barrett_1978", verbose = FALSE)

    pub_res <- pub_conn$find('{}')
    model_res <- model_conn$find('{}')

    expect_equal(nrow(pub_res), 0)
    expect_equal(nrow(model_res), 0)
  })
})

test_that("get_nonexistent_pubs returns correct set of pub_ids", {
  with_mocked_database(function(pub_conn, model_conn) {
    nonexist_ids_first <- get_nonexistent_pubs(pub_conn)
    expect_true(is.null(nonexist_ids_first))

    pub_conn$insert('{"_id": "nonexist_1987"}')
    nonexist_ids <- get_nonexistent_pubs(pub_conn)

    expect_equal(nonexist_ids, "nonexist_1987")
  })
})

test_that("get_last_update_commit gets most recent commit", {
  with_mocked_update_conn(function(update_conn) {
    update_conn$insert('{"datetime": 1727726535, "commit_id": "bbbbbbb"}')
    update_conn$insert('{"datetime": 1727726735,  "commit_id": "aaaaaaa"}')

    last_commit <- get_last_update_commit(update_conn)

    expect_equal(last_commit, "aaaaaaa")
  })
})

test_that("write_update_commit writes an update", {
  with_mocked_update_conn(function(update_conn) {
    write_update_commit(update_conn)

    update_res <- update_conn$find('{}')

    expect_equal(nrow(update_res), 1)
  })
})