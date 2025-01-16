# Correlation analysis functions for statistical discrepancy analysis
# Author: Cline
# Created: 2025-01-14

library(data.table)
library(tidyr)
library(ggplot2)
library(corrplot)

source("R/config.R")

#' Create correlation matrix for discrepancy series
#' @param data data.table: Processed discrepancy data
#' @return matrix: Correlation matrix
create_discrepancy_correlation <- function(data) {
  # Reshape data to wide format for correlation
  wide_data <- dcast(
    data,
    year ~ sector,
    value.var = "value",
    fun.aggregate = mean  # Handle any duplicates
  )
  
  # Remove year column for correlation
  cor_data <- as.matrix(wide_data[, -1])  # Exclude first column (year)
  
  # Calculate correlation matrix
  cor_matrix <- cor(
    cor_data,
    use = CORRELATION_CONFIG$use,
    method = CORRELATION_CONFIG$method
  )
  
  return(cor_matrix)
}

#' Create correlation matrix between discrepancies and other series
#' @param disc_data data.table: Discrepancy data
#' @param other_data data.table: Other series data (TOTAL sector only)
#' @param series_filter function: Function to filter series
#' @param title character: Plot title
#' @param output_path character: Path to save plot
#' @return matrix: Correlation matrix
create_series_correlation <- function(disc_data, other_data, series_filter, title, output_path) {
  # Print debug info
  print("Available series:")
  print(unique(other_data$series))
  
  # Prepare discrepancy data
  disc_wide <- dcast(
    disc_data,
    year ~ sector,
    value.var = "value",
    fun.aggregate = mean  # Handle any duplicates
  )
  
  # Filter and prepare other series data
  filtered_series <- sapply(unique(other_data$series), series_filter)
  other_filtered <- other_data[series %in% names(filtered_series)[filtered_series]]
  
  print("Filtered series:")
  print(unique(other_filtered$series))
  
  # Cast to wide format
  other_wide <- dcast(
    other_filtered,
    year ~ series,
    value.var = "value",
    fun.aggregate = mean  # Handle any duplicates
  )
  
  # Merge data
  merged_data <- merge(disc_wide, other_wide, by = "year")
  
  # Calculate correlation matrix
  disc_cols <- setdiff(names(disc_wide), "year")
  other_cols <- setdiff(names(other_wide), "year")
  
  print("Correlation columns:")
  print(paste("Discrepancy:", paste(disc_cols, collapse = ", ")))
  print(paste("Additional:", paste(other_cols, collapse = ", ")))
  
  # Convert to matrix for correlation
  disc_matrix <- as.matrix(merged_data[, ..disc_cols])
  other_matrix <- as.matrix(merged_data[, ..other_cols])
  
  # Calculate correlation matrix
  cor_matrix <- cor(
    disc_matrix,
    other_matrix,
    use = CORRELATION_CONFIG$use,
    method = CORRELATION_CONFIG$method
  )
  
  # Set up PNG device
  png(
    output_path,
    width = PLOT_CONFIG$width * 150,  # Increased width for better readability
    height = PLOT_CONFIG$height * 100,
    bg = "white"
  )
  
  # Create heatmap
  corrplot(
    cor_matrix,
    method = "color",
    type = "full",
    order = "original",  # Keep original order
    addCoef.col = "black",
    tl.col = "black",
    tl.srt = 45,
    diag = TRUE,
    title = title,
    mar = c(2, 0, 4, 0),  # Adjusted margins
    cl.ratio = 0.2,  # Color key size
    number.cex = 0.7,  # Correlation coefficient text size
    tl.cex = 0.8,  # Label text size
    col = colorRampPalette(c("#D73027", "#F46D43", "#FDAE61", 
                            "#FEE090", "#FFFFBF", "#E0F3F8", 
                            "#ABD9E9", "#74ADD1", "#4575B4"))(100)
  )
  
  # Close device
  dev.off()
  
  return(cor_matrix)
}

#' Plot correlation heatmap
#' @param cor_matrix matrix: Correlation matrix
#' @param output_path character: Path to save the plot
#' @return NULL Saves plot to file
plot_correlation_heatmap <- function(cor_matrix, output_path) {
  # Set up PNG device
  png(
    output_path,
    width = PLOT_CONFIG$width * 100,
    height = PLOT_CONFIG$height * 100,
    bg = "white"
  )
  
  # Create heatmap
  corrplot(
    cor_matrix,
    method = "color",
    type = "upper",
    order = "original",  # Keep original order
    addCoef.col = "black",
    tl.col = "black",
    tl.srt = 45,
    diag = FALSE,
    title = "Statistical Discrepancy Correlations Across Sectors",
    mar = c(0, 0, 2, 0),
    cl.ratio = 0.2,  # Color key size
    number.cex = 0.7,  # Correlation coefficient text size
    tl.cex = 0.8,  # Label text size
    col = colorRampPalette(c("#D73027", "#F46D43", "#FDAE61", 
                            "#FEE090", "#FFFFBF", "#E0F3F8", 
                            "#ABD9E9", "#74ADD1", "#4575B4"))(100)
  )
  
  # Close device
  dev.off()
}

#' Run correlation analysis and generate plots
#' @param disc_data data.table: Discrepancy data
#' @param additional_data data.table: Additional series data (TOTAL sector only)
#' @return list: Correlation matrices
run_correlation_analysis <- function(disc_data, additional_data = NULL) {
  # Calculate basic correlation matrix
  cor_matrix <- create_discrepancy_correlation(disc_data)
  
  # Create output directory if needed
  dir.create(PATHS$plots, showWarnings = FALSE, recursive = TRUE)
  
  # Generate and save basic heatmap
  output_path <- file.path(PATHS$plots, "discrepancy_correlation_heatmap.png")
  plot_correlation_heatmap(cor_matrix, output_path)
  
  # Store all correlation matrices
  results <- list(
    discrepancy = cor_matrix
  )
  
  # If additional data is provided, create additional correlation matrices
  if (!is.null(additional_data)) {
    # Flow of funds correlation
    flow_filter <- function(series) {
      series %in% c("monetary_gold", "deposits", "debt_securities", 
                   "loans", "equity", "derivatives", "other_accounts")
    }
    results$flows <- create_series_correlation(
      disc_data,
      additional_data,
      flow_filter,
      "Discrepancy vs Flow of Funds Correlations",
      file.path(PATHS$plots, "discrepancy_flows_correlation.png")
    )
    
    # Economic series correlation
    econ_filter <- function(series) {
      series %in% c("exports", "imports", "consumption", "production",
                   "operating_surplus", "primary_income", "disposable_income",
                   "savings", "fixed_capital")
    }
    results$economic <- create_series_correlation(
      disc_data,
      additional_data,
      econ_filter,
      "Discrepancy vs Economic Series Correlations",
      file.path(PATHS$plots, "discrepancy_economic_correlation.png")
    )
  }
  
  return(results)
}
