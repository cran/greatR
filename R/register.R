#' Register or synchronize different expression profiles
#'
#' \code{register()} is a function to register expression profiles a user
#' wishes to compare.
#'
#' @param input Input data frame containing all replicates of gene expression in each genotype at each time point.
#' @param stretches Candidate registration stretch factors to apply to query data, only required if \code{optimise_registration_parameters = FALSE}.
#' @param shifts Candidate registration shift values to apply to query data, only required if \code{optimise_registration_parameters = FALSE}.
#' @param reference Accession name of reference data.
#' @param query Accession name of query data.
#' @param scaling_method Scaling method applied to data prior to registration process. Either \code{none} (default), \code{z-score}, or \code{min-max}.
#' @param overlapping_percent Minimum percentage of overlapping time points on the reference data. Shifts will be only considered if it leaves at least this percentage of overlapping time points after applying the registration function.
#' @param optimise_registration_parameters Whether to optimise registration parameters. By default, \code{TRUE}.
#' @param optimisation_method Optimisation method to use. Either \code{"nm"} for Nelder-Mead (default), \code{"lbfgsb"} for L-BFGS-B, or \code{"sa"} for Simulated Annealing.
#' @param optimisation_config Optional list with arguments to override the default optimisation configuration.
#' @param exp_sd Optional experimental standard deviation on the expression replicates.
#' @param num_cores Number of cores to use if the user wants to register genes asynchronously (in parallel) in the background on the same machine. By default, \code{NA}, the registration will be run without parallelisation.
#'
#' @return This function returns a list of data frames, containing:
#'
#' \item{data}{a table containing the scaled input data and an additional \code{timepoint_reg} column after applying registration parameters to the query data.}
#' \item{model_comparison}{a table comparing the optimal registration function for each gene (based on `all_shifts_df` scores) to model with no registration applied.}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load a data frame from the sample data
#' data_path <- system.file("extdata/brapa_arabidopsis_all_replicates.csv", package = "greatR")
#' all_data <- utils::read.csv(data_path)
#'
#' # Running the registration
#' registration_results <- register(
#'   input = all_data,
#'   reference = "Ro18",
#'   query = "Col0"
#' )
#' }
register <- function(input,
                     stretches = NA,
                     shifts = NA,
                     reference,
                     query,
                     scaling_method = c("none", "z-score", "min-max"),
                     overlapping_percent = 50,
                     optimise_registration_parameters = TRUE,
                     optimisation_method = c("nm", "lbfgsb", "sa"),
                     optimisation_config = NULL,
                     exp_sd = NA,
                     num_cores = NA) {
  # Suppress "no visible binding for global variable" note
  gene_id <- NULL
  accession <- NULL
  timepoint <- NULL
  timepoint_reg <- NULL
  timepoint_id <- NULL
  expression_value <- NULL
  replicate <- NULL

  # Aux iterative registration functions
  register_single_gene_with_optimisation <- function(gene_index) {
    # Filter single gene data
    gene_data <- all_data[all_data$gene_id == gene_id_list[gene_index]]

    # Calculate BIC for Hypothesis 2
    loglik_separate <- calc_loglik_H2(gene_data)

    # Register for Hypothesis 1
    if (optimisation_method == "nm") {
      # Perform multiple optimisation rounds for Nelder-Mead
      results_round1 <- register_with_optimisation(gene_data, stretches, shifts, loglik_separate, overlapping_percent, optimisation_config, optimise_fun)

      # Perform the second round
      stretches <- results_round1$model_comparison$stretch
      shifts <- results_round1$model_comparison$shift
      results_round2 <- register_with_optimisation(gene_data, stretches, shifts, loglik_separate, overlapping_percent, optimisation_config, optimise_fun)

      # Perform the third round
      stretches <- results_round2$model_comparison$stretch
      shifts <- results_round2$model_comparison$shift
      results <- register_with_optimisation(gene_data, stretches, shifts, loglik_separate, overlapping_percent, optimisation_config, optimise_fun)
    } else {
      # Perform optimisation with other optimisation methods
      results <- register_with_optimisation(gene_data, stretches, shifts, loglik_separate, overlapping_percent, optimisation_config, optimise_fun)
    }

    return(results)
  }

  register_single_gene_manually <- function(gene_index) {
    # Filter single gene data
    gene_data <- all_data[all_data$gene_id == gene_id_list[gene_index]]

    # Calculate BIC for Hypothesis 2
    loglik_separate <- calc_loglik_H2(gene_data)

    # Explore search space
    best_params <- explore_manual_search_space(gene_data, stretches, shifts, loglik_separate)

    # Register for Hypothesis 1
    results <- register_manually(gene_data, best_params$stretch, best_params$shift, loglik_separate)

    return(results)
  }

  # Validate input data
  cli::cli_h1("Validating input data")

  match_names(
    x = colnames(input),
    lookup = c("gene_id", "accession", "timepoint", "expression_value", "replicate"),
    error = "Must review the column names of your input data:",
    name_string = "column names"
  )

  match_names(
    x = c(reference, query),
    lookup = unique(input$accession),
    error = "Must review the supplied {.var reference} and {.var query} values:",
    name_string = "accession values"
  )

  # Preprocess data
  overlapping_percent <- overlapping_percent / 100
  all_data <- preprocess_data(input, reference, query, exp_sd, scaling_method)
  gene_id_list <- unique(all_data$gene_id)

  # Begin registration logic
  if (optimise_registration_parameters) {
    optimisation_method <- match.arg(optimisation_method)

    # Registration with optimisation
    cli::cli_h1("Starting registration with optimisation")

    # Select optimisation method
    if (optimisation_method == "nm") {
      cli::cli_alert_info("Using Nelder-Mead method.")
      optimise_fun <- optimise_using_nm
      if (is.null(optimisation_config)) {
        optimisation_config <- list(num_iterations = 100, num_fun_evals = 100)
      }
    } else if (optimisation_method == "sa") {
      cli::cli_alert_info("Using Simulated Annealing method.")
      optimise_fun <- optimise_using_sa
      if (is.null(optimisation_config)) {
        optimisation_config <- list(num_iterations = 60, num_fun_evals = 100)
      }
    } else if (optimisation_method == "lbfgsb") {
      cli::cli_alert_info("Using L-BFGS-B optimization method.")
      optimise_fun <- optimise_using_lbfgsb
    }

    # Validate stretch and shift values
    validate_params(stretches, shifts, "optimisation")

    # Run optimisation
    if (is.na(num_cores)) {
      results <- lapply(
        cli::cli_progress_along(
          x = gene_id_list,
          format = "{cli::pb_spin} Optimising registration parameters for genes ({cli::pb_current}/{cli::pb_total}) [{cli::pb_elapsed_clock}]",
          format_done = "{cli::col_green(cli::symbol$tick)} Optimising registration parameters for genes ({cli::pb_total}/{cli::pb_total}) {cli::col_white(paste0('[', cli::pb_elapsed, ']'))}",
          clear = FALSE
        ),
        register_single_gene_with_optimisation
      )
    } else {
      cli::cli_alert_info("Optimising registration parameters for {length(gene_id_list)} genes (timing not available).")
      future::plan(future::multisession, workers = num_cores)
      results <- furrr::future_map(
        seq_along(gene_id_list),
        register_single_gene_with_optimisation,
        .progress = TRUE
      )
      future::plan(future::sequential)
    }
  } else {
    cli::cli_h1("Starting manual registration")

    # Validate stretch and shift values
    validate_params(stretches, shifts, "manual")

    # Apply manual registration
    if (is.na(num_cores)) {
      results <- lapply(
        cli::cli_progress_along(
          x = gene_id_list,
          format = "{cli::pb_spin} Applying registration for genes ({cli::pb_current}/{cli::pb_total}) [{cli::pb_elapsed_clock}]",
          format_done = "{cli::col_green(cli::symbol$tick)} Applying registration for genes ({cli::pb_total}/{cli::pb_total}) {cli::col_white(paste0('[', cli::pb_elapsed, ']'))}",
          clear = FALSE
        ),
        register_single_gene_manually
      )
    } else {
      cli::cli_alert_info("Applying registration for {length(gene_id_list)} genes (timing not available).")
      future::plan(future::multisession, workers = num_cores)
      results <- furrr::future_map(
        seq_along(gene_id_list),
        register_single_gene_manually,
        .progress = TRUE
      )
      future::plan(future::sequential)
    }
  }

  # Aggregate results
  all_data_reg <- data.table::rbindlist(lapply(results, function(x) x$data_reg))
  model_comparison <- data.table::rbindlist(lapply(results, function(x) x$model_comparison))

  # Drop variance columns
  all_data[, c("var") := NULL]
  all_data_reg[, c("var") := NULL]

  # Left join registered time points
  setnames(all_data_reg, "timepoint", "timepoint_reg")
  all_data[, timepoint_id := order(timepoint, expression_value), by = .(gene_id, accession, replicate)]
  all_data_reg[, timepoint_id := order(timepoint_reg, expression_value), by = .(gene_id, accession, replicate)]

  all_data <- merge(
    all_data,
    all_data_reg,
    by = c("gene_id", "accession", "expression_value", "timepoint_id", "replicate")
  )

  # Arrange data by timepoint
  all_data <- all_data[order(gene_id, accession, timepoint, replicate)]

  # Restore original query and reference accession names
  all_data[, c("time_delta", "timepoint_id") := NULL]
  all_data[, accession := factor(accession, levels = c("ref", "query"), labels = c(reference, query))][, .(gene_id, accession, timepoint, timepoint_reg, expression_value, replicate)]

  # Add accession values as data attributes
  data.table::setattr(all_data, "ref", reference)
  data.table::setattr(all_data, "query", query)

  # Add scaling as a data attribute
  data.table::setattr(all_data, "scaling_method", scaling_method)

  # Results object
  results_list <- list(
    data = all_data,
    model_comparison = model_comparison
  )

  return(results_list)
}

#' Auxiliary function to apply registration with optimisation
#'
#' @noRd
register_with_optimisation <- function(data,
                                       stretches = NA,
                                       shifts = NA,
                                       loglik_separate,
                                       overlapping_percent,
                                       optimisation_config,
                                       optimise_fun) {
  # Run optimisation
  optimised_params <- optimise(data, stretches, shifts, overlapping_percent, optimisation_config, optimise_fun)

  # Apply registration
  stretches <- optimised_params$stretch
  shifts <- optimised_params$shift
  data_reg <- apply_registration(data, stretches, shifts)

  # Calculate model comparison
  loglik_combined <- optimised_params$loglik_score

  # Model comparison
  model_comparison <- compare_H1_and_H2(data_reg, stretches, shifts, loglik_combined, loglik_separate)

  # Results object
  results_list <- list(
    data_reg = data_reg,
    model_comparison = model_comparison
  )

  return(results_list)
}

#' Auxiliary function to apply registration manually
#'
#' @noRd
register_manually <- function(data,
                              stretch,
                              shift,
                              loglik_separate,
                              return_data_reg = TRUE) {
  # Apply registration
  data_reg <- apply_registration(data, stretch, shift)

  # Calculate model comparison
  loglik_combined <- calc_loglik_H1(data_reg)

  # Model comparison
  model_comparison <- compare_H1_and_H2(data_reg, stretch, shift, loglik_combined, loglik_separate)

  # Results object
  if (return_data_reg) {
    results_list <- list(
      data_reg = data_reg,
      model_comparison = model_comparison
    )
  } else {
    results_list <- list(
      model_comparison = model_comparison
    )
  }

  return(results_list)
}

#' Explore manual search space for a single gene
#'
#' @noRd
explore_manual_search_space <- function(data, stretches, shifts, loglik_separate) {
  # Suppress "no visible binding for global variable" note
  BIC_diff <- NULL

  # Explore search space
  params_results <- lapply(
    stretches,
    function(stretch) {
      lapply(
        shifts,
        function(shift) {
          results <- register_manually(data, stretch, shift, loglik_separate, return_data_reg = FALSE)
          results$model_comparison
        }
      )
    }
  )

  # Find best registration parameters
  model_comparison <- data.table::rbindlist(do.call(Map, c(f = rbind, params_results)))
  best_params <- model_comparison[BIC_diff == min(model_comparison$BIC_diff), ][, .SD[1]]

  return(best_params)
}
