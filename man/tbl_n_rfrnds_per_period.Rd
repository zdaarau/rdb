% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rdb.gen.R
\name{tbl_n_rfrnds_per_period}
\alias{tbl_n_rfrnds_per_period}
\title{Tabulate number of referendums per period}
\usage{
tbl_n_rfrnds_per_period(
  data,
  by = NULL,
  period = c("week", "month", "quarter", "year", "decade", "century"),
  fill_gaps = TRUE,
  period_floor = NULL,
  period_ceiling = NULL,
  squeeze_zero_rows = TRUE,
  descending = TRUE,
  add_total_row = TRUE,
  add_total_col = NULL,
  lbl_total_row = gt::md("**Total**"),
  lbl_total_col = lbl_total_row
)
}
\arguments{
\item{data}{RDB referendum data as returned by \code{\link[=rfrnds]{rfrnds()}}. A data frame that at minimum contains the column specified in \code{period} or the column \code{date} (to
compute the \link[=add_period]{period column}), plus the one(s) specified via \code{by} (if any).}

\item{by}{Up to two additional \code{data} columns to group by before counting number of referendums. \link[dplyr:dplyr_tidy_select]{Tidy selections} are supported.}

\item{period}{Type of period to count referendums by. One of
\code{"week"}, \code{"month"}, \code{"quarter"}, \code{"year"}, \code{"decade"} or \code{"century"}.}

\item{fill_gaps}{Whether or not to add zero-value rows to the result for \code{period} gaps in \code{data}.}

\item{period_floor}{Lower \code{period} limit up to which gaps are filled. If \code{NULL}, the lower limit is set to the minimum of \code{period} present in \code{data}. Only
relevant if \code{fill_gaps = TRUE} and \code{period} is set to a unique timespan type (\code{"year"}, \code{"decade"} or \code{"century"}).}

\item{period_ceiling}{Upper \code{period} limit up to which gaps are filled. If \code{NULL}, the upper limit is set to the maximum of \code{period} present in \code{data}. Only
relevant if \code{fill_gaps = TRUE} and \code{period} is set to a unique timespan type (\code{"year"}, \code{"decade"} or \code{"century"}).}

\item{squeeze_zero_rows}{Whether or not to compress consecutive zero-sum rows into single period span rows.}

\item{descending}{Whether to sort the resulting table by \code{period} in descending or in ascending order.}

\item{add_total_row}{Whether or not to add a summary row at the very end of the table containing column totals. If \code{NULL}, a total row is added only if
at least one column is provided in \code{by}.}

\item{add_total_col}{Whether or not to add a summary column at the very end of the table containing row totals. If \code{NULL}, a total column is added only if
\code{by} is non-empty.}

\item{lbl_total_row}{Label of the summary row containing column totals. Only relevant if \code{add_total_row = TRUE}. A character scalar. \code{\link[gt:md]{gt::md()}} or
\code{\link[gt:html]{gt::html()}} can be used to format the label text.}

\item{lbl_total_col}{Label of the summary column containing row totals. Only relevant if \code{add_total_col = TRUE}. A character scalar. \code{\link[gt:md]{gt::md()}} or
\code{\link[gt:html]{gt::html()}} can be used to format the label text.}
}
\value{
A \code{\link[gt:gt]{gt_tbl}} object.
}
\description{
Creates a ready-to-print \link[gt:gt]{gt} table with the number of referendums per period, optionally counted \code{by} up to two additional columns.
}
\details{
Note that the \code{period} types \code{"year"}, \code{"decade"} and \code{"century"} are \emph{unique} timespans, while \code{"week"}, \code{"month"} and \code{"quarter"} are \emph{recurring} timespans (e.g. every year has a week 1).
}
\examples{
rdb::rfrnds(quiet = TRUE) |>
  rdb::tbl_n_rfrnds_per_period(period = "decade")

# grouped by a single additional column
rdb::rfrnds(quiet = TRUE) |>
  rdb::tbl_n_rfrnds_per_period(by = level,
                               period = "decade")

# grouped by two addtional columns
rdb::rfrnds(quiet = TRUE) |>
  rdb::tbl_n_rfrnds_per_period(by = c(level, type),
                               period = "decade")

# count ballot dates instead of referendums
rdb::rfrnds(quiet = TRUE) |>
  rdb::as_ballot_dates() |>
  rdb::tbl_n_rfrnds_per_period(period = "decade")
}
\seealso{
Other tabulation functions:
\code{\link{tbl_n_rfrnds}()}
}
\concept{tabulate}
