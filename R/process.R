# Data processing functions
# Author: Cline
# Created: 2025-01-14

library(data.table)
library(dplyr)

source("R/config.R")

#' Process raw discrepancy data
#' @param data data.table: Raw data
#' @return data.table: Processed data
process_discrepancy_data <- function(data) {
  # Basic data validation
  required_cols <- c("year", "concept_code", "value", "sector_code", "section")
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
  
  # Add sector labels
  sector_labels <- sapply(SECTORS, function(x) x$name_en)
  names(sector_labels) <- names(SECTORS)
  data[, sector_label := factor(sector_labels[sector])]
  
  # Handle missing sectors
  if (any(is.na(data$sector))) {
    warning("Some sector codes could not be mapped: ", 
            paste(unique(data[is.na(sector), sector_code]), collapse = ", "))
    data <- data[!is.na(sector)]
  }
  
  # Filter for valid years
  data <- data[year %between% range(YEARS)]
  
  # Sort data
  setorder(data, sector, year)
  
  return(data)
}

#' Process additional series data
#' @param data data.table: Raw additional series data
#' @return data.table: Processed data with only TOTAL sector values
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
  
  # Filter for valid years and TOTAL sector only, exclude insurance series
  result <- data[
    year %between% range(YEARS) & 
    sector_code == "Total" &
    series != "insurance"
  ]
  
  # Print debug info
  print("Data summary before aggregation:")
  print(result[, .(
    rows = .N,
    min_year = min(year),
    max_year = max(year),
    n_years = uniqueN(year)
  ), by = .(series, sector_code)])
  
  # Aggregate by year and series (in case there are multiple entries per year)
  result <- result[, .(
    value = sum(value, na.rm = TRUE)
  ), by = .(year, series, sector_code)]
  
  print("\nData summary after aggregation:")
  print(result[, .(
    rows = .N,
    min_year = min(year),
    max_year = max(year),
    n_years = uniqueN(year)
  ), by = .(series, sector_code)])
  
  # Keep only series that have exactly 18 observations (one per year)
  series_counts <- result[, .N, by = series]
  valid_series <- series_counts[N == 18, series]
  result <- result[series %in% valid_series]
  
  # Sort data
  setorder(result, series, year)
  
  return(result)
}

#' Calculate summary statistics
#' @param data data.table: Processed data
#' @return data.table: Summary statistics
calculate_summary_stats <- function(data) {
  # Calculate statistics
  summary_stats <- data[, .(
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE),
    min = min(value, na.rm = TRUE),
    max = max(value, na.rm = TRUE),
    n_years = uniqueN(year),
    missing = sum(is.na(value))
  ), by = .(sector, sector_label)]
  
  return(summary_stats)
}

#' Analyze trends in the data
#' @param data data.table: Processed data
#' @return data.table: Trend analysis results
analyze_trends <- function(data) {
  # Calculate year-over-year changes
  trend_data <- copy(data)
  setorder(trend_data, sector, year)
  trend_data[, `:=`(
    yoy_change = value - shift(value),
    yoy_pct_change = (value - shift(value)) / abs(shift(value)) * 100
  ), by = sector]
  
  return(trend_data)
}
