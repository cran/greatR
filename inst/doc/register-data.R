## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----reg-data, echo=FALSE, fig.align='center', out.width='50%'----------------
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
  shifts = seq(-4, 4, length.out = 33),
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
#> ✓ Calculating score for all shifts (10/10) [2.6s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [85ms]
#> ✓ Applying best shift (10/10) [91ms]
#> ✓ Calculating registration vs non-registration comparison BIC (10/10) [140ms]
#> ✓ Finished analysing models for stretch factor = 3
#> 
#> ── Analysing models for stretch factor = 2.5 ──
#> ✓ Calculating score for all shifts (10/10) [2.8s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [81ms]
#> ✓ Applying best shift (10/10) [103ms]
#> ✓ Calculating registration vs non-registration comparison BIC (10/10) [160ms]
#> ✓ Finished analysing models for stretch factor = 2.5
#> 
#> ── Analysing models for stretch factor = 2 ──
#> ✓ Calculating score for all shifts (10/10) [2.9s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [95ms]
#> ✓ Applying best shift (10/10) [82ms]
#> ✓ Calculating registration vs non-registration comparison BIC (10/10) [164ms]
#> ✓ Finished analysing models for stretch factor = 2
#> 
#> ── Analysing models for stretch factor = 1.5 ──
#> ✓ Calculating score for all shifts (10/10) [3s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [107ms]
#> ✓ Applying best shift (10/10) [84ms]
#> ✓ Calculating registration vs non-registration comparison BIC (10/10) [171ms]
#> ✓ Finished analysing models for stretch factor = 1.5
#> 
#> ── Analysing models for stretch factor = 1 ──
#> ✓ Calculating score for all shifts (10/10) [2.7s]
#> ✓ Normalising expression by mean and sd of compared values (10/10) [85ms]
#> ✓ Applying best shift (10/10) [90ms]
#> ✓ Calculating registration vs non-registration comparison BIC (10/10) [154ms]
#> ✓ Finished analysing models for stretch factor = 1
#> 
#> ── Model comparison results ────────────────────────────────────────────────────
#> ℹ BIC finds registration better than non-registration for: 10/10
#> 
#> ── Applying the best-shifts and stretches to gene expression ───────────────────
#> ✓ Normalising expression by mean and sd of compared values (10/10) [85ms]
#> ✓ Applying best shift (10/10) [98ms]
#> ℹ Max value of expression_value: 9.05
#> ✓ Imputing transformed expression values (10/10) [209ms]
#> 

