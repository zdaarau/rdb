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
    all()
})

