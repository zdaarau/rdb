# define some repeatedly used test data
single_rfrnd <- rfrnd(id = "5bbbe26a92a21351232dd73f")
test_testing <-
  pal::pkg_config_val(key = "test_testing_server",
                      pkg = this_pkg) %>%
  as.logical()

# rfrnds ----
test_that("`rfrnds()` works (on testing server)", {

  skip_if_not(test_testing)

  expect_gte(nrow(rfrnds(country_code = "AT",
                         use_testing_server = TRUE)),
             1L)
})

# rfrnd ----
test_that("`rfrnd()` works (on testing server)", {

  skip_if_not(test_testing)

  expect_length(nrow(rfrnd(id = "5bbbe26a92a21351232dd73f",
                           use_testing_server = TRUE)),
                1L)
})

test_that("All variables in `rfrnd()` contain labels", {

  single_rfrnd %>%
    purrr::map(.f = attr,
               which = "label",
               exact = TRUE) %>%
    purrr::map_lgl(is.null) %>%
    all() %>%
    expect_false()
})

# count_rfrnds ----
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

test_that("`count_rfrnds()` returns sensible results (on testing server)", {

  skip_if_not(test_testing)

  count_rfrnds(use_testing_server = TRUE) %>%
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

# search_rfrnds ----
test_that("`search_rfrnds()` returns sensible results", {

  result <- search_rfrnds(term = "initiative")

  expect_vector(object = result,
                ptype = character())
  expect_gte(object = length(result),
             expected = 3L)
})

test_that("`search_rfrnds()` returns sensible results (on testing server)", {

  skip_if_not(test_testing)

  result <- search_rfrnds(term = "initiative",
                          use_testing_server = TRUE)

  expect_vector(object = result,
                ptype = character())
  expect_gte(object = length(result),
             expected = 3L)
})
