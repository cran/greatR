## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----all-data-illustration, echo=FALSE, fig.align='center', out.width='80%'----
knitr::include_graphics("figures/all_data_illustration.jpg")

## ----combine-data, echo=FALSE, fig.align='center', out.width='100%'-----------
knitr::include_graphics("figures/prepare_data.png")

## ----example, message=FALSE---------------------------------------------------
# Load the package
library(greatR)
library(dplyr)

## ----load-data, message=FALSE, warning=FALSE----------------------------------
# Load example data
id_table_rapa_subset <- system.file(
  "extdata/sample_data/id_table_5genes.rds", 
  package = "greatR") %>% 
  readRDS()
klepikova_subset <- system.file(
  "extdata/sample_data/arabidopsis_expression_5genes.rds", 
  package = "greatR") %>% 
  readRDS()
rapa_subset <- system.file(
  "extdata/sample_data/brassica_rapa_expression_5genes.rds", 
  package = "greatR") %>% 
  readRDS()

## ----view-ref-----------------------------------------------------------------
# View reference data
rapa_subset %>%
  utils::head(3) %>%
  knitr::kable()

## ----view-data-to-transform---------------------------------------------------
# View query data
klepikova_subset %>%
  utils::head(3) %>%
  knitr::kable()

## ----view-id-table------------------------------------------------------------
# View table ID
id_table_rapa_subset %>%
  dplyr::select(CDS.model, locus_name, symbol, gene_id) %>% 
  utils::head(3) %>%
  knitr::kable()

## ----combine-dataframes, message=FALSE, warning=FALSE-------------------------
all_data <- get_expression_of_interest(
  data_ref = rapa_subset,
  data_to_transform = klepikova_subset,
  id_table = id_table_rapa_subset,
  lookup_col_ref_and_id_table = "CDS.model",
  lookup_col_ref_and_to_transform = "locus_name",
  colnames_wanted = NULL,
  tissue_wanted = "apex",
  gene_of_interest_acc = c("AT1G69120", "AT5G618"),
  sum_exp_data_ref = FALSE,
  accession_data_to_transform = "Col0"
)

## ----view-combined-data-------------------------------------------------------
# View data
all_data %>%
  dplyr::group_by(accession) %>%
  dplyr::slice(1:3) %>%
  knitr::kable()

## ----transform-to-final-data, message=FALSE, warning=FALSE--------------------
all_data_final <- all_data %>% 
  dplyr::select(
    locus_name, 
    accession, 
    timepoint, 
    expression_value = norm.cpm, 
    tissue, 
    group
  )

all_data_final %>%
  dplyr::group_by(accession) %>%
  dplyr::slice(1:6) %>%
  knitr::kable()

