# Analyze and plot all series
# Author: Cline
# Created: 2024-01-14

library(data.table)
library(ggplot2)
library(scales)  # For number formatting

# Format large numbers (input is already in millions of pesos)
format_pesos <- function(x) {
  # Since input is in millions:
  # 1 trillion pesos = 1e6 million pesos
  # 1 billion pesos = 1e3 million pesos
  ifelse(abs(x) >= 1e6,
         paste0(round(x/1e6, 1), "T"),
         ifelse(abs(x) >= 1e3,
                paste0(round(x/1e3, 1), "B"),
                paste0(round(x, 1), "M")))
}

# Load all series
load_series <- function(code) {
  filename <- file.path("data", paste0(code, "_wide.csv"))
  cat("Loading:", normalizePath(filename), "\n")
  dt <- fread(filename)
  
  # For YA3, keep all columns
  if (code == "YA3") {
    return(dt)
  }
  
  # Special handling for P.6 and P.7 - use S.2 as total
  if (code %in% c("P.6", "P.7")) {
    dt <- dt[, c("year", "S.2"), with = FALSE]
    setnames(dt, "S.2", paste0(code, "_Total"))
    return(dt)
  }
  
  # For other series, keep Total column
  dt <- dt[, c("year", "Total"), with = FALSE]
  setnames(dt, "Total", paste0(code, "_Total"))
  return(dt)
}

# Series to analyze (removed F.1 monetary gold)
series_codes <- c(
  "YA3",  # Statistical discrepancy
  # Flow series (F.1 removed)
  "F.2", "F.3", "F.4", "F.5", "F.6", "F.7", "F.8",
  # Economic series
  "P.3", "N.11", "P.6", "P.7", "P.1", "P.2", 
  "B.2b", "B.5b", "B.6b", "B.8b"
)

# Series labels (removed F.1)
series_labels <- c(
  "F.2" = "Deposits",
  "F.3" = "Debt Securities",
  "F.4" = "Loans",
  "F.5" = "Equity",
  "F.6" = "Insurance",
  "F.7" = "Derivatives",
  "F.8" = "Other Accounts",
  "P.3" = "Consumption",
  "N.11" = "Fixed Capital",
  "P.6" = "Exports",
  "P.7" = "Imports",
  "P.1" = "Production",
  "P.2" = "Intermediate Consumption",
  "B.2b" = "Operating Surplus",
  "B.5b" = "Primary Income",
  "B.6b" = "Disposable Income",
  "B.8b" = "Savings"
)

# Sector labels
sector_labels <- c(
  "S.11" = "Non-Financial Corporate",
  "S.12" = "Financial",
  "S.13" = "Government",
  "S.14" = "Households",
  "S.15" = "Non-Profit",
  "S.2" = "Rest of World"
)

# Load and merge all series
all_data <- list()
all_data[["YA3"]] <- load_series("YA3")  # Always load YA3 first

# Load other series
for (code in series_codes[-1]) {  # Skip YA3 since we already loaded it
  series_data <- load_series(code)
  all_data[[code]] <- series_data
}

# Merge all data
merged_data <- Reduce(function(x, y) merge(x, y, by = "year"), all_data)

# Create log differenced versions of all series
numeric_cols <- names(merged_data)[sapply(merged_data, is.numeric)]
merged_data_log_diff <- data.table(year = merged_data$year)

for (col in numeric_cols) {
  # Calculate log differences
  log_diff_values <- c(NA, diff(log(abs(merged_data[[col]]) + 1)))
  merged_data_log_diff[, (col) := log_diff_values]
}

# Save complete datasets
fwrite(merged_data, "data/all_series_wide.csv")
fwrite(merged_data_log_diff, "data/all_series_wide_logdiff.csv")
cat("Saved complete datasets\n")

# Plot discrepancy level series
disc_cols <- names(merged_data)[grep("^S\\.", names(merged_data))]
for (col in disc_cols) {
  sector_name <- sector_labels[col]
  if (is.na(sector_name)) sector_name <- col
  
  filename <- paste0("plots/discrepancy_levels_", tolower(col), ".png")
  
  p <- ggplot(merged_data, aes(x = year, y = get(col))) +
    geom_line(linewidth = 1, color = "steelblue") +
    geom_point(color = "steelblue") +
    scale_y_continuous(labels = format_pesos) +
    labs(
      title = paste("Statistical Discrepancy -", sector_name),
      x = "Year",
      y = "Value (Million Pesos)",
      caption = "Source: Mexico National Accounts"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.title = element_text(size = 12),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  ggsave(filename, p, width = 10, height = 6, dpi = 300)
  cat("Saved:", normalizePath(filename), "\n")
}

# Plot flow series
flow_cols <- grep("F\\.\\d+_Total$", names(merged_data), value = TRUE)
for (col in flow_cols) {
  series_code <- gsub("_Total$", "", col)
  series_name <- series_labels[series_code]
  if (is.na(series_name)) series_name <- series_code
  
  filename <- paste0("plots/flow_timeseries_", tolower(series_code), ".png")
  
  p <- ggplot(merged_data, aes(x = year, y = get(col))) +
    geom_line(linewidth = 1, color = "steelblue") +
    geom_point(color = "steelblue") +
    scale_y_continuous(labels = format_pesos) +
    labs(
      title = paste("Flow Series -", series_name),
      x = "Year",
      y = "Value (Million Pesos)",
      caption = "Source: Mexico National Accounts"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.title = element_text(size = 12),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  ggsave(filename, p, width = 10, height = 6, dpi = 300)
  cat("Saved:", normalizePath(filename), "\n")
}

# Plot economic series
econ_cols <- grep("^(P\\.|B\\.|N\\.)", names(merged_data), value = TRUE)
econ_cols <- econ_cols[grep("_Total$", econ_cols)]  # Keep only total columns
for (col in econ_cols) {
  series_code <- gsub("_Total$", "", col)
  series_name <- series_labels[series_code]
  if (is.na(series_name)) series_name <- series_code
  
  filename <- paste0("plots/economic_timeseries_", tolower(series_code), ".png")
  
  p <- ggplot(merged_data, aes(x = year, y = get(col))) +
    geom_line(linewidth = 1, color = "steelblue") +
    geom_point(color = "steelblue") +
    scale_y_continuous(labels = format_pesos) +
    labs(
      title = paste("Economic Series -", series_name),
      x = "Year",
      y = "Value (Million Pesos)",
      caption = "Source: Mexico National Accounts"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.title = element_text(size = 12),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  ggsave(filename, p, width = 10, height = 6, dpi = 300)
  cat("Saved:", normalizePath(filename), "\n")
}

# Plot discrepancy correlations (triangular) - Original Series
disc_cols <- names(merged_data)[grep("^S\\.", names(merged_data))]
disc_cor <- cor(as.matrix(merged_data[, ..disc_cols]), use = "pairwise.complete.obs")

# Ensure diagonal is exactly 1
diag(disc_cor) <- 1

# Convert to triangular format (keep lower triangle)
disc_cor[upper.tri(disc_cor)] <- NA

# Convert to long format for plotting
disc_cor_long <- as.data.table(disc_cor, keep.rownames = TRUE)
setnames(disc_cor_long, "rn", "Sector1")
disc_cor_long <- melt(disc_cor_long, 
                     id.vars = "Sector1",
                     variable.name = "Sector2",
                     value.name = "Correlation")

# Remove NA values
disc_cor_long <- disc_cor_long[!is.na(Correlation)]

# Add sector labels
disc_cor_long[, Sector1 := factor(Sector1, 
                                 levels = names(sector_labels),
                                 labels = sector_labels)]
disc_cor_long[, Sector2 := factor(Sector2, 
                                 levels = names(sector_labels),
                                 labels = sector_labels)]

p_disc <- ggplot(disc_cor_long, aes(x = Sector1, y = Sector2, fill = Correlation)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  geom_text(aes(label = sprintf("%.2f", Correlation)), 
            size = 2.5) +
  labs(
    title = "Correlation between Statistical Discrepancies (Original Series)",
    x = "Sector",
    y = "Sector",
    fill = "Correlation"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 12),
    legend.position = "right"
  )

ggsave("plots/discrepancy_correlations.png", 
       p_disc, width = 12, height = 10, dpi = 300)

# Plot discrepancy correlations for log differenced series
disc_cor_logdiff <- cor(as.matrix(merged_data_log_diff[, ..disc_cols]), 
                       use = "pairwise.complete.obs")

# Ensure diagonal is exactly 1
diag(disc_cor_logdiff) <- 1

# Convert to triangular format (keep lower triangle)
disc_cor_logdiff[upper.tri(disc_cor_logdiff)] <- NA

# Convert to long format for plotting
disc_cor_logdiff_long <- as.data.table(disc_cor_logdiff, keep.rownames = TRUE)
setnames(disc_cor_logdiff_long, "rn", "Sector1")
disc_cor_logdiff_long <- melt(disc_cor_logdiff_long,
                             id.vars = "Sector1",
                             variable.name = "Sector2",
                             value.name = "Correlation")

# Remove NA values
disc_cor_logdiff_long <- disc_cor_logdiff_long[!is.na(Correlation)]

# Add sector labels
disc_cor_logdiff_long[, Sector1 := factor(Sector1,
                                         levels = names(sector_labels),
                                         labels = sector_labels)]
disc_cor_logdiff_long[, Sector2 := factor(Sector2,
                                         levels = names(sector_labels),
                                         labels = sector_labels)]

p_disc_logdiff <- ggplot(disc_cor_logdiff_long, 
                        aes(x = Sector1, y = Sector2, fill = Correlation)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  geom_text(aes(label = sprintf("%.2f", Correlation)),
            size = 2.5) +
  labs(
    title = "Correlation between Statistical Discrepancies (Log Differenced)",
    x = "Sector",
    y = "Sector",
    fill = "Correlation"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 12),
    legend.position = "right"
  )

ggsave("plots/discrepancy_correlations_logdiff.png",
       p_disc_logdiff, width = 12, height = 10, dpi = 300)

# Calculate correlations between discrepancies and other series
# For both original and log differenced series
other_cols <- c(flow_cols, econ_cols)

# Original series correlations
disc_other_cor <- cor(as.matrix(merged_data[, ..disc_cols]),
                     as.matrix(merged_data[, ..other_cols]),
                     use = "pairwise.complete.obs")

disc_other_cor_long <- as.data.table(disc_other_cor, keep.rownames = TRUE)
setnames(disc_other_cor_long, "rn", "Sector")
disc_other_cor_long <- melt(disc_other_cor_long,
                           id.vars = "Sector",
                           variable.name = "Series",
                           value.name = "Correlation")

# Clean up names and add labels
disc_other_cor_long[, Series := gsub("_Total$", "", Series)]
disc_other_cor_long[, Series_label := series_labels[Series]]
disc_other_cor_long[, Sector_label := sector_labels[Sector]]

p_disc_other <- ggplot(disc_other_cor_long,
                      aes(x = Series_label, y = Sector_label, fill = Correlation)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  geom_text(aes(label = sprintf("%.2f", Correlation)),
            size = 2.5) +
  labs(
    title = "Correlation between Discrepancies and Other Series (Original)",
    x = "Series",
    y = "Sector",
    fill = "Correlation"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 12),
    legend.position = "right"
  )

ggsave("plots/discrepancy_other_correlations.png",
       p_disc_other, width = 15, height = 10, dpi = 300)

# Log differenced series correlations
disc_other_cor_logdiff <- cor(as.matrix(merged_data_log_diff[, ..disc_cols]),
                             as.matrix(merged_data_log_diff[, ..other_cols]),
                             use = "pairwise.complete.obs")

disc_other_cor_logdiff_long <- as.data.table(disc_other_cor_logdiff, keep.rownames = TRUE)
setnames(disc_other_cor_logdiff_long, "rn", "Sector")
disc_other_cor_logdiff_long <- melt(disc_other_cor_logdiff_long,
                                   id.vars = "Sector",
                                   variable.name = "Series",
                                   value.name = "Correlation")

# Clean up names and add labels
disc_other_cor_logdiff_long[, Series := gsub("_Total$", "", Series)]
disc_other_cor_logdiff_long[, Series_label := series_labels[Series]]
disc_other_cor_logdiff_long[, Sector_label := sector_labels[Sector]]

p_disc_other_logdiff <- ggplot(disc_other_cor_logdiff_long,
                              aes(x = Series_label, y = Sector_label, fill = Correlation)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  geom_text(aes(label = sprintf("%.2f", Correlation)),
            size = 2.5) +
  labs(
    title = "Correlation between Discrepancies and Other Series (Log Differenced)",
    x = "Series",
    y = "Sector",
    fill = "Correlation"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 12),
    legend.position = "right"
  )

ggsave("plots/discrepancy_other_correlations_logdiff.png",
       p_disc_other_logdiff, width = 15, height = 10, dpi = 300)
