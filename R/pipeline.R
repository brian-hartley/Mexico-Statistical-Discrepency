# Analysis pipeline for statistical discrepancy analysis
# Author: Cline
# Created: 2025-01-14

library(data.table)
library(tidyr)
library(ggplot2)
library(corrplot)

source("R/config.R")
source("R/load.R")
source("R/process.R")
source("R/plot.R")
source("R/correlate.R")
source("R/analyze.R")
source("R/load_additional.R")

# Create output directories
dir.create("data", showWarnings = FALSE, recursive = TRUE)
dir.create("plots", showWarnings = FALSE, recursive = TRUE)

# Step 1: Load and process discrepancy data
print("Loading and processing discrepancy data...")
raw_data <- load_discrepancy_data()
processed_data <- process_discrepancy_data(raw_data)
analysis_data <- processed_data[section == "II.1.2"]

# Step 2: Calculate summary statistics
print("\nCalculating summary statistics...")
summary_stats <- calculate_summary_stats(analysis_data)
print(summary_stats)

# Step 3: Load and process additional series
print("\nLoading additional series...")
raw_additional <- load_additional_series()
additional_data <- process_additional_series(raw_additional)

# Save processed data in both formats
saveRDS(additional_data, PATHS$additional_data)
csv_path <- gsub("\\.rds$", ".csv", PATHS$additional_data)
if (file.exists(csv_path)) {
  file.remove(csv_path)
}
fwrite(additional_data, csv_path)

# Step 4: Generate plots
print("\nGenerating plots...")
generate_all_plots(analysis_data)

# Step 5: Run correlation analyses
print("\nRunning correlation analyses...")
cor_results <- run_correlation_analysis(analysis_data, additional_data)

print("\nAnalysis complete!")
print("\nGenerated files:")
print("1. Time series plots:")
ts_plots <- list.files(PATHS$plots, pattern = "timeseries", full.names = TRUE)
print(basename(ts_plots))

print("\n2. Correlation plots:")
cor_plots <- list.files(PATHS$plots, pattern = "correlation", full.names = TRUE)
print(basename(cor_plots))

print("\n3. Data files:")
print(paste("- Processed discrepancy data:", basename(PATHS$processed_data)))
print(paste("- Additional series data (RDS):", basename(PATHS$additional_data)))
print(paste("- Additional series data (CSV):", basename(csv_path)))
