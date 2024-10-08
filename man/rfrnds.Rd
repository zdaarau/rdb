% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rdb.gen.R
\name{rfrnds}
\alias{rfrnds}
\title{Get referendum data}
\usage{
rfrnds(
  is_draft = FALSE,
  incl_archive = FALSE,
  use_cache = TRUE,
  max_cache_age = "1 week",
  quiet = FALSE
)
}
\arguments{
\item{is_draft}{\code{TRUE} means to include only referendum entries with \emph{draft} status, \code{FALSE} to include only normal entries. Set to \code{NULL} in order to
include both draft and normal entries.}

\item{incl_archive}{Whether or not to include an \code{archive} column containing data from an earlier, obsolete state of the Referendum Database (RDB).}

\item{use_cache}{Whether or not to return cached results if possible. If \code{FALSE}, results are always newly fetched regardless of \code{max_cache_age}.}

\item{max_cache_age}{Duration after which cached results are refreshed (i.e. newly fetched). A valid \link[lubridate:as.duration]{lubridate duration}. Use \code{Inf} to disable cache expiry. Only relevant if \code{use_cache = TRUE}.}

\item{quiet}{Whether or not to suppress printing status output from internal processing.}
}
\value{
A \link[tibble:tbl_df-class]{tibble}.
}
\description{
Downloads the referendum data from the Referendum Database (RDB). See the \code{\link{codebook}} for a detailed description of all variables.
}
\examples{
# get all referendums (excl. drafts)
rdb::rfrnds()
}
\seealso{
Other referendum data functions:
\code{\link{add_rfrnds}()},
\code{\link{assert_vars}()},
\code{\link{count_rfrnds}()},
\code{\link{delete_rfrnds}()},
\code{\link{download_file_attachment}()},
\code{\link{edit_rfrnds}()},
\code{\link{rfrnd}()},
\code{\link{rfrnd_exists}()},
\code{\link{rfrnds_old}()},
\code{\link{search_rfrnds}()},
\code{\link{validate_rfrnds}()}
}
\concept{rfrnd}
