# System Patterns

## Architecture

The analysis pipeline is structured as modular R scripts:

1. `pipeline.R` - Main orchestration script
2. `config.R` - Configuration settings and constants
3. `load.R` - Data loading functions
4. `process.R` - Data processing and cleaning
5. `plot.R` - Visualization functions
6. `correlate.R` - Correlation analysis functions
7. `analyze.R` - Statistical analysis functions
8. `test_correlation_data.R` - Testing script for correlation data

## Data Flow

1. Load raw data:
   - Read CSV chunks to handle large file
   - Filter for relevant series (YA3, economic indicators)
   - Extract TOTAL sector values

2. Process data:
   - Clean and validate
   - Convert to numeric
   - Map sectors to standardized names
   - Ensure consistent time periods

3. Analysis:
   - Generate time series plots
   - Calculate correlations
   - Create heatmaps

## Output Structure

1. Data files:
   - `data/processed_series.rds` - Cleaned discrepancy data
   - `data/additional_series.rds` - Additional economic series
   - `data/test_*.csv` - Wide format data for verification

2. Plots:
   - Individual time series for each sector
   - Correlation heatmaps:
     - Sector-to-sector discrepancy correlations
     - Discrepancy vs flow of funds correlations
     - Discrepancy vs economic series correlations

## Design Patterns

1. Modularity:
   - Each script has a specific responsibility
   - Functions are focused and well-documented
   - Configuration is separated from logic

2. Data handling:
   - Use data.table for efficient operations
   - Chunk processing for large CSV
   - Consistent data structure throughout pipeline

3. Visualization:
   - Standardized plot formatting
   - Clear labeling and titles
   - Consistent color schemes
