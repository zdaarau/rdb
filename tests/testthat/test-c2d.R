# Referendum data ----
## count_referendums ----
test_that("`count_referendums()` returns sensible results", {

  count_referendums() %>%
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

## search_referendums ----
test_that("`search_referendums()` returns sensible results", {

  result <- search_referendums(term = "initiative")

  expect_vector(object = result,
                ptype = character())
  expect_gte(object = length(result),
             expected = 3L)
})
