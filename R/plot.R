# Plotting functions for statistical discrepancy analysis
# Author: Cline
# Created: 2025-01-14

library(ggplot2)
library(corrplot)
library(data.table)
library(scales)  # For number formatting

source("R/config.R")

#' Format large numbers in millions MXN to readable format
#' @param x numeric: Value in millions MXN
#' @return character: Formatted string
format_millions <- function(x) {
  # Since input is already in millions, adjust thresholds
  trillions <- 1e6  # 1e6 million = 1 trillion
  billions <- 1e3   # 1e3 million = 1 billion
  
  result <- case_when(
    abs(x) >= trillions ~ sprintf("%.1fT", x/trillions),
    abs(x) >= billions ~ sprintf("%.1fB", x/billions),
    TRUE ~ sprintf("%.0fM", x)
  )
  
  # Handle negative values
  ifelse(x < 0, paste0("-", gsub("^-", "", result)), result)
}

#' Create a time series plot for a single sector
#' @param data data.table: Processed data for one sector
#' @param sector_name character: Sector to plot
#' @return ggplot object
plot_sector_timeseries <- function(data, sector_name) {
  sector_info <- SECTORS[[sector_name]]
  sector_data <- data[sector == sector_name]
  
  if (nrow(sector_data) == 0) {
    warning(paste("No data found for sector:", sector_name))
    return(NULL)
  }
  
  # Calculate y-axis limits with some padding
  y_range <- range(sector_data$value, na.rm = TRUE)
  y_padding <- diff(y_range) * 0.1
  y_limits <- y_range + c(-y_padding, y_padding)
  
  p <- ggplot(sector_data, aes(x = year, y = value)) +
    geom_line(
      color = PLOT_CONFIG$colors[[sector_name]],
      alpha = 0.5
    ) +
    geom_point(
      color = PLOT_CONFIG$colors[[sector_name]],
      size = 3,
      alpha = 0.8
    ) +
    theme_bw() +
    labs(
      title = paste("Statistical Discrepancy -", sector_info$name_en),
      x = "Year",
      y = "Value (Millions MXN)",
      caption = "Source: Mexico National Accounts"
    ) +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      plot.caption = element_text(hjust = 0, size = 8, color = "gray50"),
      plot.margin = margin(t = 20, r = 20, b = 20, l = 20, unit = "pt")
    ) +
    scale_x_continuous(
      breaks = YEARS,
      expand = expansion(mult = 0.05)
    ) +
    scale_y_continuous(
      labels = format_millions,
      expand = expansion(mult = 0.05),
      limits = y_limits
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  return(p)
}

#' Save a plot to file with standardized naming
#' @param plot ggplot object: Plot to save
#' @param filename character: Base filename without extension
#' @param sector character: Sector name for file naming
save_plot <- function(plot, filename, sector) {
  if (is.null(plot)) {
    return(NULL)
  }
  
  # Create plots directory if it doesn't exist
  plots_dir <- normalizePath(PATHS$plots, mustWork = FALSE)
  dir.create(plots_dir, showWarnings = FALSE, recursive = TRUE)
  
  # Construct file path
  plot_file <- paste0(filename, "_", gsub(" ", "_", tolower(sector)), ".png")
  full_path <- file.path(plots_dir, plot_file)
  
  ggsave(
    full_path,
    plot,
    width = PLOT_CONFIG$width,
    height = PLOT_CONFIG$height,
    dpi = PLOT_CONFIG$dpi,
    bg = "white"  # Ensure white background
  )
}

#' Generate all time series plots
#' @param data data.table: Processed data
#' @return NULL Saves plots to files
generate_all_plots <- function(data) {
  # Create time series plots for each sector
  for (sector_name in names(SECTORS)) {
    p <- plot_sector_timeseries(data, sector_name)
    save_plot(p, "discrepancy_timeseries", sector_name)
  }
}
