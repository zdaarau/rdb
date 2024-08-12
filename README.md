# rdb

<a href="https://cran.r-project.org/package=rdb" class="pkgdown-release"><img src="https://r-pkg.org/badges/version/rdb" alt="CRAN Status" /></a>

rdb provides access to the Referendum Database (RDB) from R. This database aims to record all direct democratic votes worldwide and is operated by the [Centre for Democracy Studies Aarau (ZDA)](https://www.zdaarau.ch/en/) at the University of Zurich, Switzerland.

## Documentation

[![Netlify Status](https://api.netlify.com/api/v1/badges/a8c23b19-d831-4621-81a8-0a5a346c3df9/deploy-status)](https://app.netlify.com/sites/rdb-rpkg-dev/deploys)

The documentation of this package is found [here](https://rdb.rpkg.dev).

## Installation

To install the latest development version of rdb, run the following in R:

``` r
if (!("remotes" %in% rownames(installed.packages()))) {
  install.packages(pkgs = "remotes",
                   repos = "https://cloud.r-project.org/")
}

remotes::install_gitlab(repo = "zdaarau/rpkgs/rdb")
```

## Package configuration

Some of rdb’s functionality is controlled via package-specific global configuration which can either be set via [R options](https://rdrr.io/r/base/options.html) or [environment variables](https://en.wikipedia.org/wiki/Environment_variable) (the former take precedence). This configuration includes:

::: table-wide
| **Description**                                                                                                                                            | **R option**               | **Environment variable**     | **Default value** |
|:-----------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------|:-----------------------------|:------------------|
| RDB Services API username                                                                                                                                  | `rdb.api_username`         | `R_RDB_API_USERNAME`         |                   |
| RDB Services API password                                                                                                                                  | `rdb.api_password`         | `R_RDB_API_PASSWORD`         |                   |
| Maximal timespan to preserve the package’s [pkgpins](https://pkgpins.rpkg.dev/) cache. Cache entries older than this will be deleted upon package loading. | `rdb.global_max_cache_age` | `R_RDB_GLOBAL_MAX_CACHE_AGE` | `"30 days"`       |
| Whether or not to use the testing servers instead of the production servers for RDB Services API calls etc.                                                | `rdb.use_testing_server`   | `R_RDB_USE_TESTING_SERVER`   | `FALSE`           |
| Whether or not to run the tests that use the testing servers for RDB Services API calls etc. during `devtools::test()`.                                    | `rdb.test_testing_server`  | `R_RDB_TEST_TESTING_SERVER`  | `FALSE`           |

:::

## Development

### R Markdown format

This package’s source code is written in the [R Markdown](https://rmarkdown.rstudio.com/) file format to facilitate practices commonly referred to as [*literate programming*](https://en.wikipedia.org/wiki/Literate_programming). It allows the actual code to be freely mixed with explanatory and supplementary information in expressive Markdown format instead of having to rely on [`#` comments](https://cran.r-project.org/doc/manuals/r-release/R-lang.html#Comments) only.

All the `.gen.R` suffixed R source code found under [`R/`](https://gitlab.com/zdaarau/rpkgs/rdb/-/tree/master/R/) is generated from the respective R Markdown counterparts under [`Rmd/`](https://gitlab.com/zdaarau/rpkgs/rdb/-/tree/master/Rmd/) using [`pkgpurl::purl_rmd()`](https://pkgpurl.rpkg.dev/dev/reference/purl_rmd.html)[^1]. Always make changes only to the `.Rmd` files – never the `.R` files – and then run `pkgpurl::purl_rmd()` to regenerate the R source files.

### Coding style

This package borrows a lot of the [Tidyverse](https://www.tidyverse.org/) design philosophies. The R code adheres to the principles specified in the [Tidyverse Design Guide](https://principles.tidyverse.org/) wherever possible and is formatted according to the [Tidyverse Style Guide](https://style.tidyverse.org/) (TSG) with the following exceptions:

-   Line width is limited to **160 characters**, double the [limit proposed by the TSG](https://style.tidyverse.org/syntax.html#long-lines) (80 characters is ridiculously little given today’s high-resolution wide screen monitors).

    Furthermore, the preferred style for breaking long lines differs. Instead of wrapping directly after an expression’s opening bracket as [suggested by the TSG](https://style.tidyverse.org/syntax.html#long-lines), we prefer two fewer line breaks and indent subsequent lines within the expression by its opening bracket:

    ``` r
    # TSG proposes this
    do_something_very_complicated(
      something = "that",
      requires = many,
      arguments = "some of which may be long"
    )

    # we prefer this
    do_something_very_complicated(something = "that",
                                  requires = many,
                                  arguments = "some of which may be long")
    ```

    This results in less vertical and more horizontal spread of the code and better readability in pipes.

-   Usage of [magrittr’s compound assignment pipe-operator `%<>%`](https://magrittr.tidyverse.org/reference/compound.html) is desirable[^2].

-   Usage of [R’s right-hand assignment operator `->`](https://rdrr.io/r/base/assignOps.html) is not allowed[^3].

-   R source code is *not* split over several files as [suggested by the TSG](https://style.tidyverse.org/package-files.html) but instead is (as far as possible) kept in the single file [`Rmd/rdb.Rmd`](https://gitlab.com/zdaarau/rpkgs/rdb/-/tree/master/Rmd/rdb.Rmd) which is well-structured thanks to its [Markdown support](#r-markdown-format).

As far as possible, these deviations from the TSG plus some additional restrictions are formally specified in [`pkgpurl::default_linters`](https://pkgpurl.rpkg.dev/reference/default_linters), which is (by default) used in [`pkgpurl::lint_rmd()`](https://pkgpurl.rpkg.dev/reference/lint_rmd), which in turn is the recommended way to lint this package.
:::

---

[^1]: The very idea to leverage the R Markdown format to author R packages was originally proposed by Yihui Xie. See his excellent [blog post](https://yihui.name/rlp/) for his point of view on the advantages of literate programming techniques and some practical examples. Note that using `pkgpurl::purl_rmd()` is a less cumbersome alternative to the Makefile approach outlined by him.

[^2]: The TSG [explicitly instructs to avoid this operator](https://style.tidyverse.org/pipes.html#assignment-2) – presumably because it’s relatively unknown and therefore might be confused with the forward pipe operator `%>%` when skimming code only briefly. I don’t consider this to be an actual issue since there aren’t many sensible usage patterns of `%>%` at the beginning of a pipe sequence inside a function – I can only think of creating side effects and relying on [R’s implicit return of the last evaluated expression](https://rdrr.io/r/base/function.html). Therefore – and because I really like the `%<>%` operator – it’s usage is welcome.

[^3]: The TSG [explicitly accepts `->` for assignments at the end of a pipe sequence](https://style.tidyverse.org/pipes.html#assignment-2) while Google’s R Style Guide [considers this bad practice](https://google.github.io/styleguide/Rguide.html#right-hand-assignment) because it “makes it harder to see in code where an object is defined”. I second the latter.
