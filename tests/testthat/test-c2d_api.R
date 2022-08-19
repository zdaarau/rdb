# define some repeatedly used test data
test_testing <-
  pal::pkg_config_val(key = "test_testing_server",
                      pkg = this_pkg) %>%
  as.logical()

# is_online ----
test_that("C2D API `is_online()`", {

  expect_true(is_online())
})

test_that("C2D API `is_online()` (on testing server)", {

  skip_if_not(test_testing)
  expect_true(is_online(use_testing_server = TRUE))
})

# auth_session ----
has_creds <-
  pal::has_pkg_config_val(key = "api_username",
                          pkg = this_pkg) &&
  pal::has_pkg_config_val(key = "api_password",
                          pkg = this_pkg)

test_that("`auth_session` returns a valid token", {

  skip_if_not(has_creds)

  token <- expect_invisible(auth_session(quiet = TRUE))

  expect_vector(object = token,
                ptype = character(),
                size = 1L)
  expect_false(is_session_expired(token))
})

test_that("`auth_session` returns a valid token (on testing server)", {

  skip_if_not(has_creds && test_testing)

  token <- expect_invisible(auth_session(quiet = TRUE,
                                         use_testing_server = TRUE))
  expect_vector(object = token,
                ptype = character(),
                size = 1L)
  expect_false(is_session_expired(token))
})

# download_file_attachment ----
test_that("`download_file_attachment()` works", {

  withr::local_file(.file = list("test.pdf" = download_file_attachment(s3_object_key = "referendum_6231e99713bed420d6ffbcf8_0001.pdf",
                                                                       path = "test.pdf")))
  expect_gte(as.integer(fs::file_size(path = "test.pdf")),
             500000)
})

test_that("`download_file_attachment()` works (on testing server)", {

  skip_if_not(test_testing)

  withr::local_file(.file = list("test.pdf" = download_file_attachment(s3_object_key = "referendum_6231e99713bed420d6ffbcf8_0001.pdf",
                                                                       path = "test.pdf",
                                                                       use_testing_server = TRUE)))
  expect_gte(as.integer(fs::file_size(path = "test.pdf")),
             500000)
})
