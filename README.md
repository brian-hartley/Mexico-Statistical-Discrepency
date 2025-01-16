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
│   ├── pipeline.R         # Main analysis pipeline
│   ├── config.R           # Configuration settings
│   ├── load.R            # Data loading functions
│   ├── process.R         # Data processing
│   ├── plot.R            # Visualization functions
│   ├── correlate.R       # Correlation analysis
│   ├── analyze.R         # Statistical analysis
│   └── test_*.R          # Test scripts
│
├── data/                  # Data files
│   ├── processed_series.rds
│   ├── additional_series.rds
│   └── test_*.csv
│
├── plots/                 # Generated plots
│   ├── discrepancy_timeseries_*.png
│   └── discrepancy_*_correlation.png
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

2. Analysis:
   - Time series visualization
   - Correlation analysis
   - Cross-sector comparisons

3. Visualization:
   - Individual sector plots
   - Correlation heatmaps
   - Clear labeling and formatting

## Usage

1. Run the main analysis:
```R
Rscript R/pipeline.R
```

2. Examine test data:
```R
Rscript R/test_correlation_data.R
```

## Data Coverage

- Years: 2003-2020
- Sectors: All major institutional sectors
- Values: Millions MXN
- Series types:
  - Statistical discrepancies (YA3)
  - Flow of funds indicators
  - Economic series

## Dependencies

- R 4.1+
- Required packages:
  - data.table
  - tidyr
  - ggplot2
  - corrplot
  - readr
  - scales
