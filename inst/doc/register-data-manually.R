## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----load-greatR, message=FALSE-----------------------------------------------
# Load the package
library(greatR)
library(data.table)

## ----brapa-data, message=FALSE, warning=FALSE---------------------------------
# Load a data frame from the sample data
b_rapa_data <- system.file("extdata/brapa_arabidopsis_all_replicates.csv", package = "greatR") |>
  data.table::fread()

## ----get-subset-data, message=FALSE, warning=FALSE----------------------------
gene_BRAA03G023790.3C_data <- b_rapa_data[gene_id == "BRAA03G023790.3C"]

## ----reg-data-manual, echo=FALSE, fig.align='center', out.width='75%'---------
knitr::include_graphics("figures/02_registration_without_opt.png")

## ----get-approximate, message=FALSE, warning=FALSE----------------------------
get_approximate_stretch(
  gene_BRAA03G023790.3C_data,
  reference = "Ro18",
  query = "Col0"
)

## ----register-subset-data, message=FALSE, warning=FALSE-----------------------
registration_results <- register(
  gene_BRAA03G023790.3C_data,
  reference = "Ro18",
  query = "Col0",
  stretches = 2.6,
  shifts = 4,
  optimise_registration_parameters = FALSE
)
#> ── Validating input data ───────────────────────────────────────────────────────
#> ℹ Will process 1 gene.
#>
#> ── Starting manual registration ────────────────────────────────────────────────
#> ✔ Applying registration for genes (1/1) [29ms]

## ----get-model-summary-data, warning=FALSE------------------------------------
registration_results$model_comparison |>
  knitr::kable()

## ----register-multiple-gene-manual, message=FALSE, warning=FALSE, eval=FALSE----
#  registration_results <- register(
#    b_rapa_data,
#    reference = "Ro18",
#    query = "Col0",
#    stretches = seq(1, 3, 0.1),
#    shifts = seq(0, 4, 0.1),
#    optimise_registration_parameters = FALSE
#  )
#  #> ── Validating input data ───────────────────────────────────────────────────────
#  #> ℹ Will process 10 genes.
#  #>
#  #> ── Starting manual registration ────────────────────────────────────────────────
#  #> ✔ Applying registration for genes (10/10) [15.8s]

