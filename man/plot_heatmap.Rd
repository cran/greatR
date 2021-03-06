% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/visualise_result.R
\name{plot_heatmap}
\alias{plot_heatmap}
\title{Visualise distances between samples from different time points}
\usage{
plot_heatmap(
  sample_dist_df,
  title = NULL,
  axis_fontsize = NULL,
  same_min_timepoint = FALSE,
  same_max_timepoint = FALSE
)
}
\arguments{
\item{sample_dist_df}{Input data frame containing sample distance between two different species.}

\item{title}{Optional plot title.}

\item{axis_fontsize}{Font size of X and Y axes labels.}

\item{same_min_timepoint}{If \code{FALSE}, the default, will not take data with the same minimum time point.}

\item{same_max_timepoint}{If \code{FALSE}, the default, will not take data with the same maximum time point.}
}
\value{
Distance heatmap of gene expression profiles over time between two different species.
}
\description{
Function \code{plot_heatmap()} allows users to plot distances between samples from different time points to investigate the similarity of progression of gene expression states between species before or after registration.
}
