# Configuration settings
# Author: Cline
# Created: 2025-01-14

# File paths
PATHS <- list(
  raw_data = "national_accounts_mexico.csv",
  processed_data = "data/processed_series.rds",
  additional_data = "data/additional_series.rds",
  plots = "plots"
)

# Years to analyze
YEARS <- 2003:2020

# Sector definitions
SECTORS <- list(
  non_financial_corporate = list(
    code = "S.11",
    name_es = "SNF",
    name_en = "NFC"
  ),
  financial = list(
    code = "S.12",
    name_es = "SF",
    name_en = "FC"
  ),
  government = list(
    code = "S.13",
    name_es = "GG",
    name_en = "GG"
  ),
  households = list(
    code = "S.14",
    name_es = "HH",
    name_en = "HH"
  ),
  nonprofit = list(
    code = "S.15",
    name_es = "NPISH",
    name_en = "NPISH"
  ),
  total_economy = list(
    code = "Total",
    name_es = "Total",
    name_en = "Total"
  ),
  rest_of_world = list(
    code = "S.2",
    name_es = "ROW",
    name_en = "ROW"
  )
)

# Series codes for additional data
SERIES_CODES <- list(
  gdp_components = list(
    consumption = list(
      code = "P.3",
      name_es = "Consumo final",
      name_en = "Final Consumption Expenditure"
    ),
    fixed_capital = list(
      code = "N.11",
      name_es = "Activos fijos por tipo",
      name_en = "Fixed Assets by Type"
    ),
    exports = list(
      code = "P.6",
      name_es = "Exportaciones",
      name_en = "Exports"
    ),
    imports = list(
      code = "P.7",
      name_es = "Importaciones",
      name_en = "Imports"
    )
  ),
  flow_of_funds = list(
    monetary_gold = list(
      code = "F.1",
      name_es = "Oro monetario y DEG",
      name_en = "Monetary Gold and SDR"
    ),
    deposits = list(
      code = "F.2",
      name_es = "Dinero legal y depósitos",
      name_en = "Legal Money and Deposits"
    ),
    debt_securities = list(
      code = "F.3",
      name_es = "Títulos de deuda",
      name_en = "Debt Securities"
    ),
    loans = list(
      code = "F.4",
      name_es = "Préstamos",
      name_en = "Loans"
    ),
    equity = list(
      code = "F.5",
      name_es = "Participaciones de capital y en fondos de inversión",
      name_en = "Capital and Investment Fund Shares"
    ),
    insurance = list(
      code = "F.6",
      name_es = "Seguros, pensiones y garantías estandarizadas",
      name_en = "Insurance Pensions and Standardized Guarantees"
    ),
    derivatives = list(
      code = "F.7",
      name_es = "Derivados financieros y opciones de compra de acciones",
      name_en = "Financial Derivatives and Share Options"
    ),
    other_accounts = list(
      code = "F.8",
      name_es = "Otras cuentas por cobrar/pagar",
      name_en = "Other Accounts Receivable/Payable"
    )
  ),
  other_items = list(
    production = list(
      code = "P.1",
      name_es = "Producción",
      name_en = "Production"
    ),
    intermediate_consumption = list(
      code = "P.2",
      name_es = "Consumo intermedio",
      name_en = "Intermediate Consumption"
    ),
    operating_surplus = list(
      code = "B.2b",
      name_es = "Excedente de operación bruto",
      name_en = "Gross Operating Surplus"
    ),
    primary_income = list(
      code = "B.5b",
      name_es = "Saldo de ingresos primarios bruto",
      name_en = "Gross Primary Income Balance"
    ),
    disposable_income = list(
      code = "B.6b",
      name_es = "Ingreso disponible bruto",
      name_en = "Gross Disposable Income"
    ),
    savings = list(
      code = "B.8b",
      name_es = "Ahorro bruto",
      name_en = "Gross Savings"
    )
  )
)

# Plot configuration
PLOT_CONFIG <- list(
  width = 12,
  height = 8,
  dpi = 300,
  colors = list(
    non_financial_corporate = "#1f77b4",
    financial = "#ff7f0e",
    government = "#2ca02c",
    households = "#d62728",
    nonprofit = "#9467bd",
    total_economy = "#8c564b",
    rest_of_world = "#e377c2"
  )
)

# Correlation configuration
CORRELATION_CONFIG <- list(
  use = "pairwise.complete.obs",
  method = "pearson"
)
