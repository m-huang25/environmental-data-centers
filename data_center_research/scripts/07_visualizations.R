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

# Determine how many categories are within the "city" and "principal_product" categories
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

# List the categories within the "pollutant_name" categories

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

air_emissions_joined %>%
  filter(principal_product %in% c('Data Center', 'data center', 'Data center', 'Data Processing', 'Information systems', 'Communications/Internet', 'Diesel Generators', 'Emergency Generation', 'Backup Power Generation')) %>%
  group_by(pollutant_name) %>%
  summarise(num_data_centers = n()) # num_data_centers is a new column name

# VISUALIZATION 1: Distribution 

# Summarize the data

facility_counts <- air_emissions_joined %>%
  filter(!is.na(emission_value)) %>%      # selects the values that are NOT missing/excludes missing emissions
  filter(pollutant_name %in% c("Carbon Monoxide", "Nitrogen Oxide", "Sulfur Dioxide", "Volatile Organic Compounds", "Particulate Matter 10", "Particulate Matter 2.5")) %>% # excludes "Particulate Matter"  
  group_by(pollutant_name) %>%           
  summarise(num_datacenters = n_distinct(name), .groups = "drop") # removes the grouping after summarizing, so the output is a regular, ungrouped data frame; n_distinct is part of the dplyr package and counts the number of unique values in a vector

facility_counts


viz1 <- ggplot(facility_counts,
                aes(x = reorder(pollutant_name, num_datacenters), # reorder() to change the order of the factor levels
                    y = num_datacenters,
                    fill = ifelse(pollutant_name %in% 
                                  c("Carbon Monoxide", "Nitrogen Oxide",
                                    "Sulfur Dioxide", "Volatile Organic Compounds"),
                                  "Gaseous Pollutants",
                                  "Particulate Matter"))) +
  geom_col() +                            # geom_col()is part of the ggplot2 package 
  geom_text(aes(label = num_datacenters), # geom_text()is part of the ggplot2 package
            hjust = -0.1,
            size = 3.5) +
  scale_fill_manual(    # scale_fill_manual()is part of the ggplot2 package 
    values = c(
      "Gaseous Pollutants" = "dodgerblue3",
      "Particulate Matter" = "goldenrod2"), 
      labels = c("Gaseous (ppm)", "Particulate (µg/m³)"),
      name = "Pollutant Type"
  ) +
  coord_flip() +   # coord_flip()is part of the ggplot2 package
  labs(            # labs() is part of the ggplots2 package
    title = "Nitrogen Oxide and Carbon Monoxide:\nMost Commonly Reported Pollutants",  
    subtitle = str_wrap("Data Center Air Emissions by Pollutant, Loudoun County, VA (2024)", width = 60), #str_wrap() is part of the stringr package, used so titles and subtitles don't run off the page
    x = "Pollutant",
    y = "Number of Data Centers",
    caption = "Data source: Virginia Department of Environmental Quality (DEQ)"
  ) +
  theme_minimal() + # theme_minimal is part of the ggplot2 package and applies a clean, simplified visual style to the plot
  theme(
    axis.text.y = element_text(size = 10),
    plot.title = element_text(size = 16, face = "bold")
  ) +
  ylim(0, max(facility_counts$num_datacenters) * 1.1)

viz1


# Create two different datasets based on units of measurements
# Add units of measurement

gas_df <- air_emissions_joined %>%
  filter(pollutant_name %in% c("Carbon Monoxide",
                               "Nitrogen Oxide",
                               "Sulfur Dioxide",
                               "Volatile Organic Compounds"))

pm_df <- air_emissions_joined %>%
  filter(pollutant_name %in% c("Particulate Matter 2.5",
                               "Particulate Matter 10"))


# VISUALIZATION 2: Relationship or Comparison
#  Create Boxplot by Measurement Unit for gaseous pollutants, use log scale

viz2_gas <- ggplot(gas_df,
                   aes(x = pollutant_name,
                       y = emission_value,
                       fill = pollutant_name)) +
  geom_boxplot(outlier.alpha = 0.4) +
  scale_y_log10() +
  scale_fill_manual(values = c(
    "Carbon Monoxide" = "blue",   
    "Nitrogen Oxide" = "orange",    
    "Sulfur Dioxide" = "#009E73",     
    "Volatile Organic Compounds" = "magenta"  
  )) +
  labs(
    title = str_wrap ("Nitrogen Oxide and Carbon Monoxide Lead Emissions Amid Data Center Variability", width = 45),
    subtitle = str_wrap ("Comparison of Gaseous Emissions from Data Centers in Loudoun County, VA (2024)", width = 60),  
    x = "Pollutant",
    y = "Emission Value (ppm, log scale)"
  ) +
  theme_minimal() +
  theme(
  plot.margin = margin(t = 20, r = 20, b = 20, l = 5)
  )+
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(size = 18, face = "bold"),
    plot.subtitle = element_text(size = 14, face = "italic"),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14)
  )

# Create Boxplot by Measurement Unit for PM 2.5, and PM 10

viz2_pm <- ggplot(pm_df,
                  aes(x = pollutant_name,
                      y = emission_value,
                      fill = pollutant_name)) +
  geom_boxplot(outlier.alpha = 0.4) +
  scale_y_log10() +
  scale_fill_manual(values = c(                   
    "Particulate Matter 2.5" = "blue",               
    "Particulate Matter 10" = "magenta"                 
  )) +
  labs(
    title = str_wrap ("PM2.5 and PM10 Have Similar Medians with Notable Variation Across Data Centers", width = 45),
    subtitle = str_wrap ("Comparison of Particulate Matter from Data Centers in Loudoun County, VA (2024)", width = 60),  
    x = "Pollutant",
    y = "Emission Value (µg/m³, log scale)"
  ) +
  theme_minimal() +
  theme(
  plot.margin = margin(t = 20, r = 20, b = 20, l = 5)
  )+
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(size = 18, face = "bold"),
    plot.subtitle = element_text(size = 14, face = "italic"),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14)
  ) 

viz2_gas
viz2_pm

