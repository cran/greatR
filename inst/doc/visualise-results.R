## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----vis-reg-data, echo=FALSE, out.width='80%'--------------------------------
knitr::include_graphics("figures/visualisation_process.png")

## ----example, message=FALSE, include=FALSE------------------------------------
# Load the package
library(greatR)
library(dplyr)

## ----register-data, message=FALSE, warning=FALSE, include=FALSE---------------
all_data_df <- system.file("extdata/brapa_arabidopsis_all_replicates.csv", package = "greatR") %>%
  utils::read.csv()

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

## ----get-summary-results------------------------------------------------------
# Get all of summary
all_summary <- summary_model_comparison(registration_results$model_comparison_df)

all_summary$df_summary %>%
  knitr::kable()

## ----print-accession-of-registred-genes---------------------------------------
all_summary$registered_genes

## ----plot-results, fig.height=10, fig.width=10, warning=FALSE-----------------
# Plot registration result
plot_registration_results(
  registration_results$imputed_mean_df,
  ncol = 3
)

## ----plot-results-with-label, fig.height=10, fig.width=10, warning=FALSE------
# Plot registration result
plot_registration_results(
  registration_results$imputed_mean_df,
  registration_results$model_comparison_df,
  ncol = 3,
  sync_timepoints = TRUE
)

## ----get-sample-distance------------------------------------------------------
sample_distance <- calculate_between_sample_distance(
  registration_results$mean_df,
  registration_results$mean_df_sc,
  registration_results$imputed_mean_df,
  accession_data_ref = "Ro18"
)

## ----plot-dist-mean-df, fig.height=5, fig.width=5, warning=FALSE--------------
# Plot heatmap of mean expression profiles distance before scaling
plot_heatmap(sample_distance$distance_mean_df)

## ----plot-dist-scaled-mean-df, fig.height=5, fig.width=5, warning=FALSE-------
# Plot heatmap of mean expression profiles distance after scaling
plot_heatmap(sample_distance$distance_scaled_mean_df)

## ----plot-dist-registered, fig.height=5, fig.width=5, warning=FALSE-----------
# Plot heatmap of mean expression profiles distance after registration process
plot_heatmap(
  sample_distance$distance_registered_df_only_reg, 
  same_max_timepoint = TRUE, 
  same_min_timepoint = TRUE
)

