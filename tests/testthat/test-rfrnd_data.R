# Referendum data ----
## rfrnd ----
test_that("All variables in `rfrnd()` contain labels", {

  rfrnd(id = "5bbbe26a92a21351232dd73f") %>%
    purrr::map(.f = attr,
               which = "label",
               exact = TRUE) %>%
    purrr::map_lgl(is.null) %>%
    all() %>%
    expect_false()
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
