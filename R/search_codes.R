# Script to search for series codes in the data
# Author: Cline
# Created: 2025-01-14

library(readr)
library(data.table)
library(dplyr)

# Function to search for codes matching a pattern
search_codes <- function(pattern, n_rows = 50000) {
  # Read a sample of the data
  sample_data <- read_csv(
    "national_accounts_mexico.csv",
    n_max = n_rows,
    show_col_types = FALSE
  )
  
  # Find matching codes
  matches <- sample_data %>%
    filter(grepl(pattern, concept_code, ignore.case = TRUE)) %>%
    select(
      concept_code,
      concept_name_es,
      concept_name_en
    ) %>%
    distinct() %>%
    arrange(concept_code)
  
  return(matches)
}

# Search for gross value added codes
print("Searching for gross value added codes...")
gva_matches <- search_codes("B.*1")
print("\nFound codes:")
print(gva_matches)

# Search for other potentially problematic codes
print("\nSearching for other B codes...")
b_matches <- search_codes("^B\\.")
print("\nFound B codes:")
print(b_matches)
