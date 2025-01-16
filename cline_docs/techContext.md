# Technical Context

## R Environment

### Core Packages
- data.table - Fast data manipulation
- tidyr - Data tidying
- ggplot2 - Visualization
- corrplot - Correlation plots
- readr - CSV reading with chunking support
- scales - Scale formatting

### Data Structures
1. Discrepancy data:
   - Year (2003-2020)
   - Sector (7 sectors)
   - Value (millions MXN)
   - Section (II.1.1, II.1.2)

2. Additional series:
   - Flow of funds series:
     - monetary_gold
     - deposits
     - debt_securities
     - loans
     - equity
     - derivatives
     - other_accounts
   - Economic series:
     - exports/imports
     - consumption
     - production
     - operating_surplus
     - primary_income
     - disposable_income
     - savings
     - fixed_capital

## Data Processing

1. Chunked reading:
   - Process large CSV in 10,000 row chunks
   - Filter relevant series during reading
   - Accumulate in data.table

2. Data cleaning:
   - Convert values to numeric
   - Map sector codes to names
   - Filter for valid years
   - Aggregate to TOTAL sector level

3. Analysis:
   - Time series visualization
   - Correlation matrices
   - Heatmap generation

## Output Formats

1. Data:
   - RDS files for R objects
   - CSV files for inspection
   - Wide format for correlation analysis

2. Plots:
   - PNG format
   - 900x600 resolution
   - Standardized color schemes
   - Clear labeling
