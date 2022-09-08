# define some repeatedly used stuff
test_testing <-
  pal::pkg_config_val(key = "test_testing_server",
                      pkg = this_pkg) %>%
  as.logical()

# define fn to test both production and testing servers
test_rfrnd_mod <- function(use_testing_server = FALSE) {

  test_that(paste0("`add_rfrnds()`, `edit_rfrnds()` and `delete_rfrnds()` work", " (on testing server)"[use_testing_server]), {

    skip_if(use_testing_server && !test_testing)

    # add_rfrnds ----
    # TODO: create new rfrnd on production, too, once rfrnd deletion is deployed
    if (use_testing_server) {
      id_new <-
        tibble::tibble(country_code = "IT",
                       level = "national",
                       date = lubridate::as_date("2222-02-02"),
                       title_en = "automated test of c2d R package",
                       result = "yes",
                       electorate_total = 2L,
                       electorate_abroad = 1L,
                       votes_yes = 1L,
                       votes_no = 1L,
                       votes_empty = 0L,
                       votes_invalid = 0L,
                       is_draft = TRUE,
                       type = "mandatory referendum") %>%
        add_rfrnds(use_testing_server = use_testing_server) %>%
        checkmate::assert_string(min.chars = 1L)

    } else {
      id_new <- "5bd0138acb48651e3d268c4a"

      # reset vals that are later changed
      rfrnd(id = id_new) %>%
        dplyr::select(all_of(field_to_var_name(rfrnd_fields$required_for_edits)),
                      country_code,
                      result) %>%
        dplyr::mutate(result = "yes",
                      country_code = "IT") %>%
        edit_rfrnds()
    }

    ## ensure it was actually added
    data_api <- rfrnd(id = id_new,
                      use_testing_server = use_testing_server)

    expect_identical(as.character(data_api$result),
                     "yes")

    # edit_rfrnds ----
    ## result (plus overwriting all other fields with themselves)
    data_api %>%
      dplyr::mutate(result = fct_flip(result)) %>%
      drop_implicit_vars(type = "edit") %>%
      edit_rfrnds(use_testing_server = use_testing_server) %>%
      checkmate::assert_tibble()

    ### ensure it was actually edited
    data_api <- rfrnd(id = id_new,
                      use_testing_server = use_testing_server)

    expect_identical(as.character(data_api$result),
                     "no")

    ## change country_code to historical one
    data_api %>%
      dplyr::select(all_of(field_to_var_name(rfrnd_fields$required_for_edits)),
                    country_code) %>%
      dplyr::mutate(country_code = "BQAQ") %>%
      edit_rfrnds(use_testing_server = use_testing_server) %>%
      checkmate::assert_tibble()

    ### ensure it was actually edited
    data_api <- rfrnd(id = id_new,
                      use_testing_server = use_testing_server)

    expect_identical(as.character(data_api$country_code),
                     "BQAQ")

    # delete_rfrnds ----
    # TODO: remove this restriction once rfrnd deletion is deployed to production
    if (use_testing_server) {
      expect_identical(delete_rfrnds(ids = id_new,
                                     use_testing_server = use_testing_server),
                       id_new)

      ## ensure it was actually deleted
      expect_error(object = rfrnd(id = id_new,
                                  use_testing_server = use_testing_server),
                   regexp = "not_found")
    }
  })
}

test_rfrnd_mod(use_testing_server = FALSE)
test_rfrnd_mod(use_testing_server = TRUE)
