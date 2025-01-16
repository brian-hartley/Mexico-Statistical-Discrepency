# Test script to examine correlation data structure
# Author: Cline
# Created: 2025-01-14

library(data.table)
library(tidyr)

source("R/config.R")
source("R/load.R")
source("R/process.R")

# Load and process discrepancy data
print("Loading discrepancy data...")
raw_data <- load_discrepancy_data()
processed_data <- process_discrepancy_data(raw_data)
analysis_data <- processed_data[section == "II.1.2"]

# Load and process additional series
print("\nLoading additional series...")
raw_additional <- load_additional_series()
additional_data <- process_additional_series(raw_additional)

# Create wide format for discrepancy data
print("\nCreating wide format discrepancy data...")
disc_wide <- dcast(
  analysis_data,
  year ~ sector,
  value.var = "value",
  fun.aggregate = mean
)

# Create wide format for additional series
print("\nCreating wide format additional series data...")
other_wide <- dcast(
  additional_data,
  year ~ series,
  value.var = "value",
  fun.aggregate = mean
)

# Merge the datasets
print("\nMerging datasets...")
merged_data <- merge(disc_wide, other_wide, by = "year")

# Save all formats for examination
print("\nSaving data for examination...")
fwrite(disc_wide, "data/test_discrepancy_wide.csv")
fwrite(other_wide, "data/test_additional_wide.csv")
fwrite(merged_data, "data/test_merged_wide.csv")

# Print summaries
print("\nDiscrepancy data structure:")
print(str(disc_wide))
print("\nAdditional series structure:")
print(str(other_wide))
print("\nMerged data structure:")
print(str(merged_data))

print("\nDiscrepancy columns:")
print(setdiff(names(disc_wide), "year"))
print("\nAdditional series columns:")
print(setdiff(names(other_wide), "year"))

print("\nSummary of rows per dataset:")
print(paste("Discrepancy rows:", nrow(disc_wide)))
print(paste("Additional series rows:", nrow(other_wide)))
print(paste("Merged rows:", nrow(merged_data)))
