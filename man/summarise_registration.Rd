% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary.R
\name{summarise_registration}
\alias{summarise_registration}
\title{Summarise registration results}
\usage{
summarise_registration(results)
}
\arguments{
\item{results}{Registration results, output of the \code{\link{register}} registration process.}
}
\value{
This function returns a list containing:

\item{summary}{contains result summaries of the registration results.}
\item{registered_genes}{vector of gene accessions which were successfully registered.}
\item{non_registered_genes}{vector of non-registered gene accessions.}
}
\description{
Summarise registration results
}
