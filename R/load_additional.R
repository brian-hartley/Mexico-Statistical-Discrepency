# Additional series loading functions
# Author: Cline
# Created: 2025-01-14

library(readr)
library(data.table)

source("R/config.R")

#' Get all series codes from configuration
#' @return character vector: All series codes
get_all_series_codes <- function() {
  codes <- c()
  
  # Extract codes from each category
  for (category in names(SERIES_CODES)) {
    for (series in names(SERIES_CODES[[category]])) {
      codes <- c(codes, SERIES_CODES[[category]][[series]]$code)
    }
  }
  
  return(unique(codes))
}

#' Map series code to series name
#' @param code character: Series code to map
#' @return character: Series name
map_code_to_series <- function(code) {
  for (category in names(SERIES_CODES)) {
    for (series in names(SERIES_CODES[[category]])) {
      if (SERIES_CODES[[category]][[series]]$code == code) {
        return(series)
      }
    }
  }
  return(NA_character_)
}

#' Load additional series data from CSV
#' @return data.table: Raw additional series data
load_additional_series <- function() {
  # Get all series codes we want to load
  series_codes <- get_all_series_codes()
  print(paste("Looking for series:", paste(series_codes, collapse = ", ")))
  
  # Read CSV in chunks to handle large file
  chunk_size <- 10000
  
  # Create environment for accumulating data
  e <- new.env()
  e$additional_data <- data.table()
  
  # Process chunks
  csv_reader <- read_csv_chunked(
    PATHS$raw_data,
    callback = DataFrameCallback$new(function(chunk, pos) {
      # Convert chunk to data.table
      dt <- as.data.table(chunk)
      
      # Filter for our series
      filtered <- dt[concept_code %in% series_codes]
      
      if (nrow(filtered) > 0) {
        # Add series type
        filtered[, series := sapply(concept_code, map_code_to_series)]
        
        # Accumulate filtered data
        e$additional_data <- rbindlist(list(e$additional_data, filtered), fill = TRUE)
      }
      
      return(NULL)
    }),
    chunk_size = chunk_size,
    col_types = cols(.default = col_character()),
    show_col_types = FALSE,
    progress = FALSE
  )
  
  # Print debug info
  print(paste("Total additional rows loaded:", nrow(e$additional_data)))
  print("Series loaded:")
  print(e$additional_data[, .N, by = series])
  
  return(e$additional_data)
}

#' Process additional series data
#' @param data data.table: Raw additional series data
#' @return data.table: Processed data
process_additional_series <- function(data) {
  # Basic data validation
  required_cols <- c("year", "concept_code", "value", "sector_code", "series")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Convert to data.table if needed
  if (!is.data.table(data)) {
    data <- as.data.table(data)
  }
  
  # Ensure numeric values
  data[, value := as.numeric(value)]
  data[, year := as.numeric(year)]
  
  # Map sectors to standardized names
  sector_map <- sapply(SECTORS, function(x) x$code)
  names(sector_map) <- names(SECTORS)
  
  # Create sector mapping
  data[, sector := names(sector_map)[match(sector_code, sector_map)]]
  
  # Handle missing sectors
  if (any(is.na(data$sector))) {
    warning("Some sector codes could not be mapped: ", 
            paste(unique(data[is.na(sector), sector_code]), collapse = ", "))
    data <- data[!is.na(sector)]
  }
  
  # Filter for valid years
  data <- data[year %between% range(YEARS)]
  
  # Sort data
  setorder(data, series, sector, year)
  
  # Print debug info
  print("Additional series summary:")
  print(data[, .N, by = .(series, sector)])
  
  return(data)
}
