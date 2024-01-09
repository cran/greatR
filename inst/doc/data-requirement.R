## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----fig-all-data-illustration, echo=FALSE, fig.align='center', out.width='75%'----
knitr::include_graphics("figures/all_data_illustration_new.png")

## ----brapa-data-kable, echo=FALSE---------------------------------------------
# Load a data frame from the sample data
b_rapa_data <- system.file("extdata/brapa_arabidopsis_all_replicates.csv", package = "greatR") |>
  data.table::fread()

b_rapa_data[, .SD[1:2], by = accession][, .(gene_id, accession, timepoint, expression_value, replicate)] |>
  knitr::kable()

