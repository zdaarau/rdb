% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rdb.gen.R
\name{infer_topics}
\alias{infer_topics}
\title{Infer higher-tier topics}
\usage{
infer_topics(topics, tier = 1L)
}
\arguments{
\item{topics}{Topics from which the corresponding (grand)parent topics are to be determined. A factor or character vector.}

\item{tier}{Tier of the inferred topics. Either \code{1L} or \code{2L}.}
}
\value{
A character vector.
}
\description{
Determines the top-tier (\code{tier = 1L}) or second-tier (\code{tier = 2L}) topics corresponding to \code{topics} in the
\link[=data_topics]{hierarchy}, i.e. either \code{topics} themselves or their (grand)parent topics.
}
\examples{
rdb::infer_topics(topics = c("EU", "animal protection"),
                  tier = 1L)
rdb::infer_topics(topics = c("EU", "animal protection"),
                  tier = 2L)

# topics of different tiers can mixed in `topics`
rdb::infer_topics(topics = c("EU", "environment"),
                  tier = 2L)

# but `topics` of a higher tier than `tier` will be ignored
rdb::infer_topics(topics = "foreign policy",
                  tier = 2L)
}
\seealso{
Other referendum topic functions:
\code{\link{data_topics}},
\code{\link{hierarchize_topics}()},
\code{\link{hierarchize_topics_fast}()},
\code{\link{topics}()}
}
\concept{topics}
