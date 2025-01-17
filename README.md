# Statistical Discrepancy Analysis - Mexican National Accounts

Analysis of statistical discrepancies in Mexican national accounts data, examining relationships between discrepancies and various economic indicators.

## Overview

This project analyzes statistical discrepancies (YA3 code) across different sectors of the Mexican economy, comparing them with:
- Flow of funds indicators
- Economic series
- Cross-sector relationships

## Structure

```
.
├── R/                      # R scripts
│   └── analyze_series.R   # Main analysis script
│
├── data/                  # Data files
│   ├── *_wide.csv        # Wide-format data files
│   ├── all_series_wide.csv
│   └── all_series_wide_logdiff.csv
│
├── plots/                 # Generated plots
│   ├── discrepancy_levels_*.png      # Level plots for each sector
│   ├── discrepancy_correlations.png  # Original series correlations
│   ├── discrepancy_correlations_logdiff.png  # Log-differenced correlations
│   ├── flow_timeseries_*.png         # Flow series plots
│   └── economic_timeseries_*.png     # Economic series plots
│
└── cline_docs/           # Documentation
    ├── projectContext.md
    ├── systemPatterns.md
    ├── techContext.md
    ├── activeContext.md
    └── progress.md
```

## Features

1. Data Processing:
   - Efficient handling of large CSV files
   - Focused extraction of relevant series
   - Clean and standardized output
   - Log-differenced series for stationarity

2. Analysis:
   - Time series visualization with proper scaling (T/B/M pesos)
   - Correlation analysis for both original and log-differenced series
   - Cross-sector comparisons

3. Visualization:
   - Individual sector plots with formatted axis labels (T/B/M pesos)
   - Correlation heatmaps
   - Clear labeling and formatting

## Usage

Run the main analysis:
```R
Rscript R/analyze_series.R
```

This will:
1. Load and process all series
2. Generate level plots for discrepancies
3. Create correlation plots
4. Save both original and log-differenced datasets

## Data Coverage

- Years: 2003-2020
- Sectors: All major institutional sectors
- Values: Millions MXN
- Series types:
  - Statistical discrepancies (YA3)
  - Flow of funds indicators (excluding monetary gold)
  - Economic series

## Dependencies

- R 4.1+
- Required packages:
  - data.table
  - ggplot2
  - scales
