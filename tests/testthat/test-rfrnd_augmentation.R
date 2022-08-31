# define some repeatedly used stuff
single_rfrnd <- rfrnd(id = "5bbbe26a92a21351232dd73f")

# add_world_regions ----
test_that("`add_world_regions()` is idempotent", {

  expect_identical(single_rfrnd %>% add_world_regions(),
                   single_rfrnd %>% add_world_regions() %>% add_world_regions())
})
test_that("`add_world_regions()` works for ISO 3166-3 Alpha-4 codes (former countries)", {

  expect_identical(tibble::tibble(country_code = "SUHH") %>% add_world_regions() %$% un_region_tier_2_name,
                   "Eastern Europe")
})

# add_period ----
test_that("`add_period()` is idempotent", {

  expect_identical(single_rfrnd %>% add_period(),
                   single_rfrnd %>% add_period() %>% add_period())
})

# add_turnout ----
test_that("`add_turnout()` is idempotent", {

  expect_identical(single_rfrnd %>% add_turnout(),
                   single_rfrnd %>% add_turnout() %>% add_turnout())
})

test_that("`add_turnout()` throws an error when required input col is missing", {

  expect_error(object = single_rfrnd %>% dplyr::select(-votes_invalid) %>% add_turnout(),
               regexp = "votes_invalid.*is missing")
})
