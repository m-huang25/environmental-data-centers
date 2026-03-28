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

# Determine how many categories within the "city" and "principal_product" categories
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



