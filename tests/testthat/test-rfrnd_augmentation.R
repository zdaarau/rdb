# define some repeatedly used stuff
single_rfrnd <-
  rfrnds_old() |>
  dplyr::filter(id == "5bbbe26a92a21351232dd73f")

# define fn to run common augmentation tests
test_augmentation <- function(fns = c("add_former_country_flag",
                                      "add_country_code_continual",
                                      "add_country_code_long",
                                      "add_country_name",
                                      "add_country_name_long",
                                      "add_period",
                                      "add_turnout",
                                      "add_world_regions")) {
  fns %>% purrr::walk(~ {

    fn <- get(.x)

    test_that(glue::glue("`{.x}()` is idempotent"), {

      expect_identical(single_rfrnd %>% fn(),
                       single_rfrnd %>% fn() %>% fn())
    })

    test_that(glue::glue("All variables contain labels after `{.x}()`"), {

      single_rfrnd %>%
        fn() %>%
        purrr::map(.f = attr,
                   which = "label",
                   exact = TRUE) %>%
        purrr::map_lgl(is.null) %>%
        magrittr::is_in(FALSE) %>%
        all() %>%
        expect_true()
    })
  })
}

test_augmentation()

# add_world_regions ----
test_that("`add_world_regions()` works for ISO 3166-3 Alpha-4 codes (former countries)", {

  expect_identical(tibble::tibble(country_code = "SUHH") %>%
                     add_world_regions() %$%
                     un_region_tier_2_name %>%
                     as.character(),
                   "Eastern Europe")
})

# add_turnout ----
test_that("`add_turnout()` throws an error when required input col is missing", {

  expect_error(object = single_rfrnd %>% dplyr::select(-votes_invalid) %>% add_turnout(),
               regexp = "must contain a column `votes_invalid`")
})
