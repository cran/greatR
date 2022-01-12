## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----reg-data, echo=FALSE, out.width='50%'------------------------------------
knitr::include_graphics("figures/registration_process.png")

## ----example, message=FALSE---------------------------------------------------
# Load the package
library(greatR)
library(dplyr)

## ----all-data, message=FALSE, warning=FALSE-----------------------------------
# Gene expression data with replicates
all_data_df <- system.file("extdata/brapa_arabidopsis_all_replicates.csv", package = "greatR") %>%
  utils::read.csv()

## ----all-data-kable-----------------------------------------------------------
all_data_df %>%
  dplyr::group_by(accession) %>%
  dplyr::slice(1:6) %>%
  knitr::kable()

## ----estimate-stretch-factors, message=FALSE, warning=FALSE, eval=FALSE-------
#  get_approximate_stretch(
#    input_df = all_data_df,
#    accession_data_to_transform = "Col0",
#    accession_data_ref = "Ro18"
#  )
#  #> [1] 2.666667

## ----register-data, message=FALSE, warning=FALSE------------------------------
# Running the registration
registration_results <- scale_and_register_data(
  input_df = all_data_df,
  stretches = c(3, 2.5, 2, 1.5, 1),
  shift_extreme = 4,
  num_shifts = 33,
  min_num_overlapping_points = 4,
  initial_rescale = FALSE,
  do_rescale = TRUE,
  accession_data_to_transform = "Col0",
  accession_data_ref = "Ro18",
  start_timepoint = "reference"
)
#> 
#> ── Information before registration ─────────────────────────────────────────────
#> ℹ Max value of expression_value of all_data_df: 262.28
#> 
#> ── Analysing models for all stretch and shift factor ───────────────────────────
#> 
#> ── Analysing models for stretch factor = 3 ──
#> ✓ Calculating score for all shifts (10/10) [2s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [55ms]
#> ✓ Applying best shift (10/10) [50ms]
#> ✓ Calculating registration vs non-registration comparison AIC & BIC (10/10) [134ms]
#> ✓ Finished analysing models for stretch factor = 3
#> 
#> ── Analysing models for stretch factor = 2.5 ──
#> ✓ Calculating score for all shifts (10/10) [2.2s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [55ms]
#> ✓ Applying best shift (10/10) [52ms]
#> ✓ Calculating registration vs non-registration comparison AIC & BIC (10/10) [113ms]
#> ✓ Finished analysing models for stretch factor = 2.5
#> 
#> ── Analysing models for stretch factor = 2 ──
#> ✓ Calculating score for all shifts (10/10) [2.2s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [47ms]
#> ✓ Applying best shift (10/10) [50ms]
#> ✓ Calculating registration vs non-registration comparison AIC & BIC (10/10) [99ms]
#> ✓ Finished analysing models for stretch factor = 2
#> 
#> ── Analysing models for stretch factor = 1.5 ──
#> ✓ Calculating score for all shifts (10/10) [2s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [51ms]
#> ✓ Applying best shift (10/10) [52ms]
#> ✓ Calculating registration vs non-registration comparison AIC & BIC (10/10) [102ms]
#> 
#> ✓ Finished analysing models for stretch factor = 1.5
#> 
#> ── Analysing models for stretch factor = 1 ──
#> ✓ Calculating score for all shifts (10/10) [1.9s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [49ms]
#> ✓ Applying best shift (10/10) [49ms]
#> ✓ Calculating registration vs non-registration comparison AIC & BIC (10/10) [108ms]
#> ✓ Finished analysing models for stretch factor = 1
#> 
#> ── Model comparison results ────────────────────────────────────────────────────
#> ℹ BIC finds registration better than non-registration for: 10/10
#> 
#> ── Applying the best-shifts and stretches to gene expression ───────────────────
#> ✓ Normalising expression by mean and sd of compared values (10/10) [48ms]
#> ✓ Applying best shift (10/10) [52ms]
#> ℹ Max value of expression_value: 9.05
#> ✓ Imputing transformed expression values (10/10) [144ms]
#> 

