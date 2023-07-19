## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----reg-data, echo=FALSE, fig.align='center', out.width='20%'----------------
knitr::include_graphics("figures/01_registration_opt_default.png")

## ----load-greatR, message=FALSE-----------------------------------------------
# Load the package
library(greatR)
library(data.table)

## ----brapa-data, message=FALSE, warning=FALSE---------------------------------
# Load a data frame from the sample data
b_rapa_data <- system.file("extdata/brapa_arabidopsis_all_replicates.csv", package = "greatR") |>
  data.table::fread()

## ----brapa-data-kable-clean, eval=FALSE---------------------------------------
#  b_rapa_data[, .SD[1:6], by = accession] |>
#    knitr::kable()

## ----brapa-data-kable, echo=FALSE---------------------------------------------
b_rapa_data[, .SD[1:6], by = accession][, .(gene_id, accession, timepoint, expression_value, replicate)] |>
  knitr::kable()

## ----register-data-raw, message=FALSE, warning=FALSE, eval=FALSE--------------
#  registration_results <- register(
#    b_rapa_data,
#    reference = "Ro18",
#    query = "Col0"
#  )
#  #> ── Validating input data ────────────────────────────────────────────────────────
#  #> ℹ Will process 10 genes.
#  #>
#  #> ── Starting registration with optimisation ──────────────────────────────────────
#  #> ℹ Using Nelder-Mead method.
#  #> ℹ Using computed stretches and shifts search space limits.
#  #> ✔ Optimising registration parameters for genes (10/10) [2.3s]

## ----register-data, message=FALSE, warning=FALSE, include=FALSE---------------
# Load a data frame from the sample data
registration_results <- system.file("extdata/brapa_arabidopsis_registration.rds", package = "greatR") |>
  readRDS()

registration_results$model_comparison <- registration_results$model_comparison[, .(gene_id, stretch, shift, BIC_separate, BIC_combined, registered)]

## ----get-model-summary-data, warning=FALSE------------------------------------
registration_results$model_comparison |>
  knitr::kable()

