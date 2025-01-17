# Active Context

## Current State

Analysis pipeline has been consolidated and improved:
1. Single script (analyze_series.R) now handles all functionality:
   - Data loading and processing
   - Time series visualization
   - Correlation analysis
   - Log differencing for stationarity

2. Visualization improvements:
   - Added proper value formatting (T/B/M for peso amounts)
   - Clear axis labels indicating "Million Pesos"
   - Generated level plots for discrepancy series
   - Created correlation plots for both original and log-differenced series

3. Data Processing:
   - Removed monetary gold (F.1) from analysis
   - Added log differencing for stationarity
   - Consolidated all series into comprehensive datasets

## Recent Changes

1. Code Consolidation:
   - Merged all functionality into analyze_series.R
   - Removed redundant scripts and utilities
   - Cleaned up project structure

2. Visualization Enhancements:
   - Added format_pesos function for better readability
   - Updated axis labels and formatting
   - Added level plots for discrepancy series

3. Analysis Updates:
   - Added log differencing for stationarity
   - Removed monetary gold from analysis
   - Generated correlation plots for both original and log-differenced series

## Current Focus

The analysis pipeline now provides:
1. Comprehensive visualization of:
   - Statistical discrepancy levels by sector
   - Flow of funds series (excluding monetary gold)
   - Economic indicators

2. Correlation analysis between:
   - Statistical discrepancies across sectors
   - Discrepancies vs flow of funds series
   - Discrepancies vs economic indicators

3. Both original and stationary (log-differenced) series analysis

## Data Coverage

- Years: 2003-2020
- Sectors: All major institutional sectors
- Series: 
  - Statistical discrepancies (YA3)
  - Flow of funds indicators (F.2-F.8)
  - Economic series (P.*, B.*, N.11)
