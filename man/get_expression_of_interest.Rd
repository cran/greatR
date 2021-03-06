% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prepare_data.R
\name{get_expression_of_interest}
\alias{get_expression_of_interest}
\title{Get expression of interest}
\usage{
get_expression_of_interest(
  data_ref,
  data_to_transform,
  id_table,
  lookup_col_ref_and_id_table = "CDS.model",
  lookup_col_ref_and_to_transform = "locus_name",
  colnames_wanted = NULL,
  tissue_wanted = NULL,
  gene_of_interest_acc,
  sum_exp_data_ref = FALSE,
  accession_data_to_transform = "Col0"
)
}
\arguments{
\item{data_ref}{Data frame of reference data.}

\item{data_to_transform}{Data frame of data to transform.}

\item{id_table}{Data frame of ID table connecting both reference data and data to transform.}

\item{lookup_col_ref_and_id_table}{Column names shared by both reference data and ID table.}

\item{lookup_col_ref_and_to_transform}{Column names shared by both reference data and data to transform.}

\item{colnames_wanted}{List of column names to keep from both reference data and data to transform.}

\item{tissue_wanted}{Name of tissue from which data will be compared.}

\item{gene_of_interest_acc}{Gene accession list from data to transform.}

\item{sum_exp_data_ref}{If \code{TRUE} then sum all gene data. Default is \code{FALSE}.}

\item{accession_data_to_transform}{Accession name of data which will be transformed.}
}
\value{
A data frame contains both reference data and data to transform for selected gene of interest.
}
\description{
Get expression of interest
}
