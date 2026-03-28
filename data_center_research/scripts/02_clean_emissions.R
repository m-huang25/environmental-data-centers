#load library
library(tidyverse)

# Import CSV file on air_emissions for the year 2024 in Virginia. 
air_sites_emissions <- read.csv("data/processed/air_sites_emissions.csv")

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