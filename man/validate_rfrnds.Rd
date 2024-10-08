% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rdb.gen.R
\name{validate_rfrnds}
\alias{validate_rfrnds}
\title{Validate referendum data}
\usage{
validate_rfrnds(
  data,
  check_applicability_constraint = TRUE,
  check_id_sudd_prefix = TRUE
)
}
\arguments{
\item{data}{Referendum data to validate, as returned by \code{\link[=rfrnds]{rfrnds()}}.}

\item{check_applicability_constraint}{Whether or not to check that no applicability constraints as defined in the \link[=data_codebook]{codebook} are violated.}

\item{check_id_sudd_prefix}{Whether or not to check that all \href{https://rdb.rpkg.dev/articles/codebook.html#id-sudd}{\code{id_sudd}} prefixes are valid.}
}
\value{
\code{data}, invisibly.
}
\description{
Performs various data validation steps to ensure there are no errors in the supplied \code{data}.
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
\code{\link{rfrnds}()},
\code{\link{rfrnds_old}()},
\code{\link{search_rfrnds}()}
}
\concept{rfrnd}
