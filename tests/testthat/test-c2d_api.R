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

## count_rfrnds ----
test_that("`count_rfrnds()` returns sensible results", {

  count_rfrnds() %>%
    purrr::pmap(function(local, subnational, national) {
      c(checkmate::test_int(local,
                            lower = 1L),
        checkmate::test_int(subnational,
                            lower = 1L),
        checkmate::test_int(national,
                            lower = 1L))
    }) %>%
    purrr::flatten_lgl() %>%
    all() %>%
    expect_true()
})

## search_rfrnds ----
test_that("`search_rfrnds()` returns sensible results", {

  result <- search_rfrnds(term = "initiative")

  expect_vector(object = result,
                ptype = character())
  expect_gte(object = length(result),
             expected = 3L)
})
