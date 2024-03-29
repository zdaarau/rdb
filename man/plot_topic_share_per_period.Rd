% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rdb.gen.R
\name{plot_topic_share_per_period}
\alias{plot_topic_share_per_period}
\title{Topic share per period stacked area chart}
\usage{
plot_topic_share_per_period(
  data,
  tier = 1L,
  period = c("week", "month", "quarter", "year", "decade", "century"),
  weight_by_n_rfrnds = TRUE
)
}
\arguments{
\item{data}{RDB referendum data as returned by \code{\link[=rfrnds]{rfrnds()}}. A data frame that at minimum contains the column \code{topics_tier_#} of the specified \code{tier}.}

\item{tier}{Tier of the topics variable to plot. \code{1L}, \code{2L} or \code{3L}.}

\item{period}{Type of period to count topics by. One of
\code{"week"}, \code{"month"}, \code{"quarter"}, \code{"year"}, \code{"decade"} or \code{"century"}.}

\item{weight_by_n_rfrnds}{Whether or not to weight topic occurences by number of referendums. If \code{TRUE}, for a referendum with n different topics of the same
\code{tier}, every topic is counted 1/n.}
}
\value{
A \link[plotly:plot_ly]{plotly object}.
}
\description{
Creates a \href{https://plotly.com/r/filled-area-plots/#stacked-area-chart-with-cumulative-values}{Plotly stacked area chart} that visualizes the share of
referendum topic occurences per period.
}
\details{
Note that the \code{period} types \code{"year"}, \code{"decade"} and \code{"century"} are \emph{unique} timespans, while \code{"week"}, \code{"month"} and \code{"quarter"} are \emph{recurring} timespans (e.g. every year has a week 1).
}
\examples{
rdb::rfrnds(quiet = TRUE) |>
  rdb::plot_topic_share_per_period(period = "decade")
}
\seealso{
Other visualization functions:
\code{\link{ggplot_streamgraph}()},
\code{\link{plot_rfrnd_share_per_period}()},
\code{\link{plot_topic_segmentation}()}
}
\concept{visualize}
