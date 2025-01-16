# Project Context

This project analyzes statistical discrepancies in Mexican national accounts data. The statistical discrepancy represents the difference between:
- Current account totals (net lending/borrowing position)
- Financial account totals (allocation of net lending/borrowing position to financial assets/liabilities)

## Key Components

- Statistical discrepancy time series (YA3 code) for each sector:
  - Non-financial corporate sector
  - Financial sector
  - Government sector
  - Household sector
  - Non-profit institutions serving households
  - Total economy
  - Rest of world sector

## Analysis Goals

1. Create clean time series data for statistical discrepancies (2003-2020)
2. Compare discrepancies with related economic flows:
   - Flow of funds series (monetary_gold, deposits, debt_securities, etc.)
   - Economic series (exports, imports, consumption, etc.)
3. Generate visualizations:
   - Individual time series plots for each sector's discrepancy
   - Correlation heatmaps comparing discrepancies with other series

## Data Source

Mexican national accounts data provided in CSV format, containing:
- Time series from 2003 to 2020
- Multiple sectors and economic concepts
- Values in millions of Mexican pesos (MXN)
