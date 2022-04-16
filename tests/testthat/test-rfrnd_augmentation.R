# Referendum augmentation ----

# define some repeatedly used test data
single_rfrnd <- rfrnd(id = "5bbbe26a92a21351232dd73f")

## add_world_regions ----
test_that("`add_world_regions()` is idempotent", {

  expect_identical(single_rfrnd %>% add_world_regions(),
                   single_rfrnd %>% add_world_regions() %>% add_world_regions())
})
