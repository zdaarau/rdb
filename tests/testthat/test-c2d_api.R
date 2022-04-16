# C2D API ----
## is_online ----
test_that("C2D API `is_online()`", {

  expect_true(is_online())
})
## auth_session ----
test_that("`auth_session` returns a valid token", {

  skip_if(any(is.na(c(Sys.getenv("C2D_API_USER",
                                 unset = NA_character_),
                      Sys.getenv("C2D_API_PW",
                                 unset = NA_character_)))))

  token <- expect_invisible(auth_session(quiet = TRUE))

  expect_vector(object = token,
                ptype = character(),
                size = 1L)
  expect_false(is_session_expired(token))
})
