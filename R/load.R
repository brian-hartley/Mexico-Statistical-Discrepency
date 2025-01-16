# Data loading functions
# Author: Cline
# Created: 2025-01-14

library(readr)
library(data.table)

source("R/config.R")

#' Load discrepancy data from CSV
#' @return data.table: Raw discrepancy data
load_discrepancy_data <- function() {
  # Create environment for accumulating data
  e <- new.env()
  e$discrepancy_data <- data.table()
  
  # Process chunks
  csv_reader <- read_csv_chunked(
    PATHS$raw_data,
    callback = DataFrameCallback$new(function(chunk, pos) {
      # Convert chunk to data.table and filter
      dt <- as.data.table(chunk)
      filtered <- dt[concept_code == "YA3"]
      
      if (nrow(filtered) > 0) {
        e$discrepancy_data <- rbindlist(list(e$discrepancy_data, filtered), fill = TRUE)
      }
      
      return(NULL)
    }),
    chunk_size = 10000,
    col_types = cols(.default = col_character()),
    show_col_types = FALSE,
    progress = FALSE
  )
  
  return(e$discrepancy_data)
}

#' Load additional series data from CSV
#' @return data.table: Raw additional series data
load_additional_series <- function() {
  # Get all series codes we want to load
  series_codes <- c(
    unlist(sapply(SERIES_CODES$gdp_components, function(x) x$code)),
    unlist(sapply(SERIES_CODES$flow_of_funds, function(x) x$code)),
    unlist(sapply(SERIES_CODES$other_items, function(x) x$code))
  )
  
  # Create environment for accumulating data
  e <- new.env()
  e$additional_data <- data.table()
  
  # Process chunks
  csv_reader <- read_csv_chunked(
    PATHS$raw_data,
    callback = DataFrameCallback$new(function(chunk, pos) {
      # Convert chunk to data.table and filter
      dt <- as.data.table(chunk)
      filtered <- dt[concept_code %in% series_codes]
      
      if (nrow(filtered) > 0) {
        # Add series type
        filtered[, series := sapply(concept_code, function(code) {
          for (category in names(SERIES_CODES)) {
            for (series in names(SERIES_CODES[[category]])) {
              if (SERIES_CODES[[category]][[series]]$code == code) {
                return(series)
              }
            }
          }
          return(NA_character_)
        })]
        
        e$additional_data <- rbindlist(list(e$additional_data, filtered), fill = TRUE)
      }
      
      return(NULL)
    }),
    chunk_size = 10000,
    col_types = cols(.default = col_character()),
    show_col_types = FALSE,
    progress = FALSE
  )
  
  return(e$additional_data)
}
