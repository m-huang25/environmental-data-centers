#load libraries
library(tidyverse)

# Import and clean dataset on air montoring sites in Virginia
air_sites <- read.csv("data/processed/active_air_sites.csv")

# Examine the variables of the dataset
names(air_sites)

# Create new dataframe

air_sites_clean <- as.data.frame(air_sites)

# Rename variables
air_sites_clean <- air_sites %>%
    rename(
      name = PLA_NAME,
      address = FAC_L_ADDR_1,  
      city = FAC_L_CITY,
      principal_product = PLA_PRINCIPAL_PRODUCT,
      icis_id = PLA_ICIS_ID
    )

# List the categories within the "city" and "principal_product" categories
#unique(air_sites_clean$city)
#unique(air_sites_clean$principal_product)
length(unique(air_sites_clean$city))
length(unique(air_sites_clean$principal_product))

# Select only relevant columns and rows
air_sites_clean <- air_sites_clean %>%
    select(name, city, address, principal_product, icis_id) %>%
    filter(city %in% c('Leesburg', 'Ashburn', 'Sterling', 'Aldie', 'Purcellville', 'Potomac Falls', 'Dulles', 'Bluemont', 'Chantilly'))%>% # cities in Loudoun County
    filter(principal_product %in% c('Data Center', 'data center', 'Data center', 'Data Processing', 'Information systems', 'Communications/Internet', 'Diesel Generators', 'Emergency Generation', 'Backup Power Generation')) # data center and data center-related words

air_sites_clean

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

# Join acive air site and air site emissions datasets

air_emissions_joined <- left_join(x = air_sites_clean, y = air_sites_emissions_clean, by = "icis_id")

air_emissions_joined <- air_emissions_joined[complete.cases(air_emissions_joined), ]

glimpse (air_emissions_joined) # data is in long format


