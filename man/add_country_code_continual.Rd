% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rdb.gen.R
\name{add_country_code_continual}
\alias{add_country_code_continual}
\title{Add continual country code to referendum data}
\usage{
add_country_code_continual(data)
}
\arguments{
\item{data}{RDB referendum data as returned by \code{\link[=rfrnds]{rfrnds()}}. A data frame that at minimum contains the column \code{country_code} (with \href{https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2} or \href{https://en.wikipedia.org/wiki/ISO_3166-3}{ISO 3166-3 alpha-4} codes).}
}
\value{
A \link[tibble:tbl_df-class]{tibble}.
}
\description{
Augments \code{data} with an additional column \code{country_code_continual} holding the current or future \href{https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2} code of the country where the referendum took place. If the country still exists,
\code{country_code_continual} is identical to \code{country_code}, otherwise it is the \code{country_code} of the successor country. If the country was succeeded by
multiple countries, the code of the largest one in terms of population is taken.
}
\examples{
rdb::rfrnds(quiet = TRUE) |>
  rdb::add_country_code_continual() |>
  dplyr::select(id,
                starts_with("country_"))
}
\seealso{
Other referendum data augmentation functions:
\code{\link{add_country_code_long}()},
\code{\link{add_country_name}()},
\code{\link{add_country_name_long}()},
\code{\link{add_former_country_flag}()},
\code{\link{add_period}()},
\code{\link{add_turnout}()},
\code{\link{add_urls}()},
\code{\link{add_world_regions}()}
}
\concept{augment}
