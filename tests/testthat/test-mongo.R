# Create the test publication
test_pub_path <- system.file("testdata/test_publications/a_e/barrett_1978.R", package = "models")
source(test_pub_path)
test_pub <- barrett_1978

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

test_that("upsert_publication inserts a document when it does not exist", {
  with_mocked_database(function(pub_conn, model_conn) {
    pub_parsed <- publication_to_json(test_pub)

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
