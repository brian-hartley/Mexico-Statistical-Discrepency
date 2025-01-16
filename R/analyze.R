# Analysis functions for statistical discrepancy analysis
# Author: Cline
# Created: 2025-01-14

library(data.table)
library(dplyr)

source("R/config.R")
source("R/load.R")
source("R/process.R")
source("R/plot.R")
source("R/correlate.R")

#' Calculate summary statistics for each sector
#' @param data data.table: Processed data
#' @return data.table: Summary statistics
calculate_summary_stats <- function(data) {
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
  setorder(data, sector, year)
  data[, `:=`(
    yoy_change = value - shift(value),
    yoy_pct_change = (value - shift(value)) / abs(shift(value)) * 100
  ), by = sector]
  
  return(data)
}

#' Prepare data for plotting
#' @param data data.table: Processed data
#' @return data.table: Data ready for plotting
prepare_for_plotting <- function(data) {
  # Map sector codes to labels
  sector_labels <- sapply(SECTORS, function(x) x$name_en)
  names(sector_labels) <- names(SECTORS)
  
  plot_data <- copy(data)
  plot_data[, sector_label := factor(sector_labels[sector])]
  
  return(plot_data)
}

#' Test the analysis pipeline
#' @return list Analysis results or NULL if test fails
test_analysis <- function() {
  # Load test data
  print("Loading test data...")
  test_data <- test_data_loading()
  print(paste("Test data rows:", nrow(test_data)))
  
  if (nrow(test_data) > 0) {
    print("Test data sectors:")
    print(test_data[, .N, by = .(sector, sector_code)])
    
    # Process test data
    print("\nProcessing test data...")
    processed <- process_discrepancy_data(test_data)
    plot_data <- prepare_for_plotting(processed)
    print(paste("Processed test data rows:", nrow(plot_data)))
    print("Processed test data sectors:")
    print(plot_data[, .N, by = .(sector, sector_code)])
    
    # Calculate summary statistics
    summary_stats <- calculate_summary_stats(plot_data)
    print("Test Summary Statistics:")
    print(summary_stats)
    
    # Try generating a test plot
    if (nrow(plot_data) > 0) {
      test_plot <- plot_sector_timeseries(plot_data, names(SECTORS)[1])
      print("Test plot generated successfully")
    }
    
    return(list(
      data = plot_data,
      summary = summary_stats
    ))
  } else {
    warning("No data found in test sample")
    return(NULL)
  }
}

#' Main analysis function to run the complete workflow
#' @param include_other_series logical: Whether to include other series in analysis
#' @return NULL Saves processed data and generates plots
run_analysis <- function(include_other_series = FALSE) {
  # Load YA3 data
  print("Loading raw data...")
  raw_data <- load_discrepancy_data()
  print(paste("Raw data rows:", nrow(raw_data)))
  print("Raw data sectors:")
  print(raw_data[, .N, by = .(sector, sector_code)])
  
  # Process data
  print("\nProcessing data...")
  processed_data <- process_discrepancy_data(raw_data)
  print(paste("Processed data rows:", nrow(processed_data)))
  print("Processed data sectors:")
  print(processed_data[, .N, by = .(sector, sector_code)])
  
  # Add plotting metadata
  print("\nPreparing plot data...")
  plot_data <- prepare_for_plotting(processed_data)
  print(paste("Plot data rows:", nrow(plot_data)))
  print("Plot data sectors:")
  print(plot_data[, .N, by = .(sector, sector_code)])
  
  # Calculate summary statistics
  summary_stats <- calculate_summary_stats(plot_data)
  print("Summary Statistics by Sector:")
  print(summary_stats)
  
  # Analyze trends
  trends <- analyze_trends(plot_data)
  print("\nTrend Analysis:")
  print(trends)
  
  # Generate plots
  print("\nGenerating plots...")
  generate_all_plots(plot_data)
  
  # Save processed data
  saveRDS(plot_data, PATHS$processed_data)
  
  # Return invisibly for potential further analysis
  invisible(list(
    data = plot_data,
    summary = summary_stats,
    trends = trends
  ))
}
