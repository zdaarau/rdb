# define some repeatedly used stuff
test_testing <-
  pal::pkg_config_val(key = "test_testing_server",
                      pkg = this_pkg) %>%
  as.logical()

# define fn to test both production and testing servers
test_rfrnd_data <- function(use_testing_server = FALSE) {

  # rfrnds_old ----
  test_that(paste0("`rfrnds_old()` works", " (on testing server)"[use_testing_server]), {

    skip_if(use_testing_server && !test_testing)

    expect_gte(nrow(rfrnds_old(country_code = "AT",
                               use_testing_server = use_testing_server,
                               use_cache = FALSE,
                               quiet = TRUE)),
               1L)
  })

  # rfrnd ----
  test_that(paste0("`rfrnd()` works", " (on testing server)"[use_testing_server]), {

    skip_if(use_testing_server && !test_testing)

    expect_length(nrow(rfrnd(id = "5bbbe26a92a21351232dd73f",
                             use_testing_server = use_testing_server)),
                  1L)
  })

  test_that(paste0("All variables in `rfrnd()` contain labels", " (on testing server)"[use_testing_server]), {

    skip_if(use_testing_server && !test_testing)

    rfrnd(id = "5bbbe26a92a21351232dd73f",
          use_testing_server = use_testing_server) %>%
      purrr::map(.f = attr,
                 which = "label",
                 exact = TRUE) %>%
      purrr::map_lgl(is.null) %>%
      all() %>%
      expect_false()
  })

  # count_rfrnds ----
  test_that(paste0("`count_rfrnds()` returns sensible results", " (on testing server)"[use_testing_server]), {

    skip_if(use_testing_server && !test_testing)

    count_rfrnds(use_testing_server = use_testing_server) %>%
      purrr::pmap(function(local, subnational, national) {
        c(checkmate::test_int(local,
                              lower = 1L),
          checkmate::test_int(subnational,
                              lower = 1L),
          checkmate::test_int(national,
                              lower = 1L))
      }) %>%
      purrr::list_c(ptype = logical()) %>%
      all() %>%
      expect_true()
  })

  # rfrnd_exists ----
  test_that(paste0("`rfrnd_exists()` works", " (on testing server)"[use_testing_server]), {

    skip_if(use_testing_server && !test_testing)

    expect_true(rfrnd_exists(id = "622b039913bed420d6ffbc21"))
    expect_false(rfrnd_exists(id = "nah"))
  })
}

test_rfrnd_data(use_testing_server = FALSE)
# test_rfrnd_data(use_testing_server = TRUE)
