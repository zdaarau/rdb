% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rdb.gen.R
\name{unnest_var}
\alias{unnest_var}
\title{Unnest multi-value variable}
\usage{
unnest_var(data, var)
}
\arguments{
\item{data}{RDB referendum data as returned by \code{\link[=rfrnds]{rfrnds()}}. A data frame that at minimum contains the column specified in \code{var}.}

\item{var}{\code{data} column to unnest. One of the multi-value variables:
\itemize{
\item \code{topics_tier_1}
\item \code{topics_tier_2}
\item \code{topics_tier_3}
\item \code{inst_object_revision_modes}
\item \code{inst_topics_only}
\item \code{inst_topics_excluded}
}

\link[dplyr:dplyr_tidy_select]{Tidy selections} are supported.}
}
\value{
A \link[tibble:tbl_df-class]{tibble}.
}
\description{
Unnests a multi-value variable of type list to long format. Multi-value variables can contain more than one value per observation and thus break with the
\href{https://tidyr.tidyverse.org/articles/tidy-data.html}{tidy-data convention}. This function allows to conveniently expand \code{data} to contain a single \code{var}
value per observation only, thereby increasing the number of observations (i.e. rows).
}
\examples{
rdb::rfrnds(quiet = TRUE) |>
  rdb::unnest_var(topics_tier_2)
}
\seealso{
Other referendum data transformation functions:
\code{\link{as_ballot_dates}()},
\code{\link{n_rfrnds}()},
\code{\link{n_rfrnds_per_period}()},
\code{\link{prettify_col_names}()}

Other variable unnesting functions:
\code{\link{var_name_unnested}()}
}
\concept{transform}
\concept{unnest}
