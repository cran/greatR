## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----vis-reg-data, echo=FALSE, fig.align='center', out.width='90%'------------
knitr::include_graphics("figures/visualisation_process.png")

## ----load-greatR, message=FALSE, include=FALSE--------------------------------
# Load the package
library(greatR)
library(data.table)

## ----brapa-data-results, message=FALSE, warning=FALSE, include=FALSE----------
# Load a data frame from the sample data
registration_results <- system.file("extdata/brapa_arabidopsis_registration.rds", package = "greatR") |>
  readRDS()

## ----get-summary-results------------------------------------------------------
# Get registration summary
reg_summary <- summarise_registration(registration_results)

reg_summary$summary |>
  knitr::kable()

## ----print-accession-of-registered-genes--------------------------------------
reg_summary$registered_genes

## ----print-accession-of-non-registered-genes----------------------------------
reg_summary$non_registered_genes

## ----plot-results, fig.align='center', fig.height=8, fig.width=7, warning=FALSE----
# Plot registration result
plot_registration_results(
  registration_results,
  ncol = 2
)

## ----get-sample-distance------------------------------------------------------
sample_distance <- calculate_distance(registration_results)

## ----plot-dist-original, fig.align='center', fig.height=5, fig.width=5, warning=FALSE----
# Plot heatmap of mean expression profiles distance before registration process
plot_heatmap(
  sample_distance,
  type = "original"
)

## ----plot-dist-registered, fig.align='center', fig.height=5, fig.width=5, warning=FALSE----
# Plot heatmap of mean expression profiles distance after registration process
plot_heatmap(
  sample_distance,
  type = "registered",
  match_timepoints = TRUE
)

