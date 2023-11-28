# define some repeatedly used stuff
test_testing <-
  pal::pkg_config_val(key = "test_testing_server",
                      pkg = this_pkg) %>%
  as.logical()

# define fn to test both production and testing servers
test_api <- function(use_testing_server = FALSE) {

  # is_online ----
  test_that(paste0("RDB API `is_online()`", " (on testing server)"[use_testing_server]), {

    skip_if(use_testing_server && !test_testing)

    expect_true(is_online(use_testing_server = use_testing_server))
  })

  # auth_session ----
  test_that(paste0("`auth_session()` returns a valid token", " (on testing server)"[use_testing_server]), {

    skip_if(use_testing_server && !test_testing)

    has_creds <-
      pal::has_pkg_config_val(key = "api_username",
                              pkg = this_pkg) &&
      pal::has_pkg_config_val(key = "api_password",
                              pkg = this_pkg)

    skip_if_not(has_creds)

    token <- expect_invisible(auth_session(quiet = TRUE,
                                           use_testing_server = use_testing_server))
    expect_vector(object = token,
                  ptype = character(),
                  size = 1L)
    expect_false(is_session_expired(token,
                                    use_testing_server = use_testing_server))
  })

  # download_file_attachment ----
  test_that(paste0("`download_file_attachment()` works", " (on testing server)"[use_testing_server]), {

    skip("`/s3_object` API endpoint is currently broken")
    skip_if(use_testing_server && !test_testing)

    withr::local_file(.file = list("test.pdf" = download_file_attachment(s3_object_key = "referendum_6231e99713bed420d6ffbcf8_0001.pdf",
                                                                         path = "test.pdf",
                                                                         use_testing_server = use_testing_server)))
    expect_gte(as.integer(fs::file_size(path = "test.pdf")),
               500000)
  })
}

test_api(use_testing_server = FALSE)
test_api(use_testing_server = TRUE)
