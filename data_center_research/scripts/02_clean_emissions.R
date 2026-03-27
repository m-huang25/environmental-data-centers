# Check script is running
#cat("Script started\n")#
#cat("R version:", R.version.string, "\n")
#if ("IRkernel" %in% loadedNamespaces()) {
#  cat("Running in Jupyter via IRkernel\n")
#} else if (!interactive()) {
#  cat("Running via Rscript (non-interactive)\n")
#} else {
#  cat("Running in an interactive R session (e.g., RStudio)\n")
#}

#load library
library(tidyverse)

# Import CSV file on air_emissions for the year 2024 in Virginia. 
air_sites_emissions <- read.csv("data/processed/air_sites_emissions.csv")

#cat("First few rows:\n")
#print(head(air_sites))

#cat("Number of rows and columns:\n")
#print(dim(air_sites))

#cat("Column names:\n")
#print(colnames(air_sites))

#cat("Script finished successfully.\n")

# Examine the variables of the dataset
names(air_sites_emissions)

# Rename variables
air_sites_emissions_clean <- air_sites_emissions %>%
    rename(
      emissions_year = EMISSIONSYEAR,
      emission_value = EMISSION_VALUE,
      icis_id = PLA_ICIS_ID,
      pollutant_name = CPL_POLLUTANT_NAME
    )

# List and count the "pollutant_name" category

unique(air_sites_emissions_clean$pollutant_name)
length(unique(air_sites_emissions_clean$pollutant_name))

# Select only relevant columns
air_sites_emissions_clean <- air_sites_emissions_clean %>%
    select(emissions_year, emission_value, icis_id, pollutant_name)

air_sites_emissions_clean