#load libraries
library(tidyverse)
library(ggthemes)   
library(sf)  

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

# List the categories within the "pollutant_name" categories

unique(air_sites_emissions_clean$pollutant_name)
length(unique(air_sites_emissions_clean$pollutant_name))

# Select only relevant columns
air_sites_emissions_clean <- air_sites_emissions_clean %>%
    select(emissions_year, emission_value, icis_id, pollutant_name)

# Join acive air site and air site emissions datasets

air_emissions_joined <- left_join(x = air_sites_clean, y = air_sites_emissions_clean, by = "icis_id")

air_emissions_joined <- air_emissions_joined[complete.cases(air_emissions_joined), ]

glimpse (air_emissions_joined) # data is in long format


#Import CSV file on data centers in Virginia
data_centers <- read.csv("data/processed/pec_data_centers.csv")

#show first 10 rows
head(data_centers, 10)

#Create new dataframe
data_centers_clean <- as.data.frame(data_centers)

#Rename variables
data_centers_clean <- data_centers_clean %>%
  rename(
    object_id = OBJECTID,
    locality = Locality,
    name = Name,
    owner_applicant = Owner_Applicant,
    street_address = Street_Address,
    construction_type = Construction_Type,
    build_status = Build_Status,
    lat = Lat,
    long = Long,
  )

# Examine rows with missing longitude and latitude coordinates, blank space after the comma means "keep all columns"

data_centers_clean[is.na(data_centers_clean$long) | is.na(data_centers_clean$lat), ]

# Keep rows where long and lat exists

data_centers_clean <- data_centers_clean %>%
  filter(!is.na(long) & !is.na(lat))

# Can disregard #399 and #411 as they are proposed and we only want existing data centers; will filter for existing data centers next  

#Select only relevant columns and rows
data_centers_clean <- data_centers_clean %>%
    select(object_id, locality, name, street_address, owner_applicant, construction_type, build_status,lat, long) %>%
    filter(locality == "Loudoun County")%>% # keep only Loudoun County rows
    filter(build_status == "Existing")   # keep only Existing rows

data_centers_clean

# Standarize the addresses in the air_emissions_joined and data_centers_clean (PEC) datasets

air_emissions_joined <- air_emissions_joined %>%
  mutate(address_clean = address %>%
           str_to_lower() %>%
          str_trim() %>%
          str_replace_all("\\.", "") %>%
          str_replace_all(" pl$", " plaza") %>%
          str_replace_all(" dr$", " drive") %>%
          str_replace_all(" rd$", " road") %>%
          str_replace_all(" ln$", " lane") %>%
          str_replace_all(" cir$", " circle") %>%
          str_replace_all(" pkwy$", " parkway"))

data_centers_clean <- data_centers_clean %>%
  mutate(address_clean = street_address %>%
          str_to_lower() %>%
          str_trim() %>%
          str_replace_all("\\.", "") %>%
          str_replace_all(" pl$", " plaza") %>%
          str_replace_all(" dr$", " drive") %>%
          str_replace_all(" rd$", " road") %>%
          str_replace_all(" ln$", " lane") %>%
          str_replace_all(" cir$", " circle") %>%
          str_replace_all(" blvd$", " boulevard") %>%
          str_replace_all(" pkwy$", " parkway"))

# Manually add in missing address

air_emissions_joined <- air_emissions_joined %>%
  mutate(address_clean = address_clean %>%
           str_replace_all(" plz$", " plaza") %>%
           str_replace_all("round table", "roundtable"))

data_centers_clean <- data_centers_clean %>%
  mutate(address_clean = address_clean %>%
           str_replace_all(" plz$", " plaza") %>%
           str_replace_all("round table", "roundtable"))

data_centers_clean <- data_centers_clean %>%
 mutate(address_clean = case_when(
  address_clean == "45900n pathfinder plaza" ~ "45900 pathfinder way",
   TRUE ~ address_clean
  ))

#  Manually remove addresses 

air_emissions_joined <- air_emissions_joined %>%
  filter(!address_clean %in% c(
    "14725 lee road",
    "14901 conference center drive",
    "4030 lafayette center dr ste a",
    "43673 john mosby highway"
   
  ))

data_centers_clean <- data_centers_clean %>%
  filter(!address_clean %in% c(
    "14725 lee road",
    "14901 conference center drive",
    "4030 lafayette center dr ste a",
    "43673 john mosby highway"
  ))

# Standardize Pathfinder address in emissions dataset
air_emissions_joined <- air_emissions_joined %>%
  mutate(address_clean = case_when(
    str_detect(address_clean, "^45900") &
    str_detect(address_clean, "pathfinder") ~ "45900 pathfinder plaza",
    TRUE ~ address_clean
  ))

# Standardize Pathfinder address in data centers dataset
data_centers_clean <- data_centers_clean %>%
  mutate(address_clean = case_when(
    str_detect(address_clean, "^45900") &
    str_detect(address_clean, "pathfinder") ~ "45900 pathfinder plaza",
    TRUE ~ address_clean
  ))


# Standardize Kipper address in emissions dataset
air_emissions_joined <- air_emissions_joined %>%
  mutate(address_clean = case_when(
    str_detect(address_clean, "^22370") &
    str_detect(address_clean, "kipper") ~ "22370 kipper drive",
    TRUE ~ address_clean
  ))

# Standardize Kipper address in data centers dataset
data_centers_clean <- data_centers_clean %>%
  mutate(address_clean = case_when(
    str_detect(address_clean, "^22370") &
    str_detect(address_clean, "kipper") ~ "22370 kipper drive",
    TRUE ~ address_clean
  ))

# Standarize Prologis address in emissions dataset

air_emissions_joined <- air_emissions_joined %>%
  mutate(address_clean = case_when(
    str_detect(address_clean, "^45220") &
    str_detect(address_clean, "prolog") ~ "45220 prologis plaza",
    TRUE ~ address_clean
  ))

# Standarize Prologis address in data centers dataset in data centers dataset

data_centers_clean <- data_centers_clean %>%
  mutate(address_clean = case_when(
    str_detect(address_clean, "^45220") &
    str_detect(address_clean, "prolog") ~ "45220 prologis plaza",
    TRUE ~ address_clean
  ))

# Standarize relocation address missing full address in emissions dataset

air_emissions_joined <- air_emissions_joined %>%
  mutate(address_clean = case_when(
    str_detect(address_clean, "^relocation drive$") ~ "22715 relocation drive",
    TRUE ~ address_clean
  ))

# Standarize relocation address missing full address in data centers dataset

data_centers_clean <- data_centers_clean %>%
  mutate(address_clean = case_when(
    str_detect(address_clean, "^relocation drive$") ~ "22715 relocation drive",
    TRUE ~ address_clean
  ))

# Join the two datasets via address_clean so that the air_emissions_joined dataset has longtitude and latitude columns
# Add a column on air emissions to data_centers_clean joining by street_address (PEC database)


# Check that address_clean exists in both datasets
"address_clean" %in% colnames(air_emissions_joined)
"address_clean" %in% colnames(data_centers_clean)

# Create one address per data center in the data_centers_clean dataset removing duplicates
data_centers_coords <- data_centers_clean %>%
  select(address_clean, lat, long) %>%
  distinct(address_clean, .keep_all = TRUE)

# Check that each address appears only once in the data_centers_coords dataset
data_centers_coords %>%
  count(address_clean) %>%
  filter(n > 1)

# Join air_sites_cleanand air_sites_emissions_clean

emissions_coordinates_joined <- air_emissions_joined %>%
  left_join(data_centers_coords, by = "address_clean")

glimpse(emissions_coordinates_joined)

# Check which addresses do not have lat and long

missing_coords <- emissions_coordinates_joined %>%
  filter(is.na(lat) | is.na(long)) %>%
  select(address_clean) %>%
  distinct()

missing_coords

# Manually add in missing coordinates

manual_coords <- tibble::tibble(
  address_clean = c(
    "22995 wilder court",
    "21635 red rum drive",
    "22001 loudoun county parkway",
    "22080 pacific blvd",
    "43673 john mosby highway",
    "511 shaw road",
    "42911 arcola road",
    "23825 erins run drive",
    "22890 platform plaza",
    "22210 loudoun county parkway",
    "22715 relocation drive", 
    "22588 relocation drive",
    "21099 atlantic boulevard",
    "28755 relocation drive",  
    "22426 lockridge road",
    "42575 arcola blvd",
    "19935 sycolin road",
    "44254 import plaza",
    "24282 quail ridge lane",
    "45781 maries road",
    "25430 sutton bay plaza"
   
      
  ),
  latitude = c(
    38.974,39.015966,39.01121,39.0094,38.9419, 39.0069,38.9517,39.058719,39.0142,
    39.068,33.006, 39.0016,39.0142,38.985,38.9959,38.9517772,39.0706627,39.0437,
    38.932,38.9716,38.927
  ),
  longitude = c(
    -77.447,-77.48158,-77.47120,-77.4485,-77.5306, -77.4107,-77.5341,-77.4327656,-77.4727,
    -77.491,-77.428, -77.4578,-77.4311,-77.458,-77.4124,-77.5341578,-77.6047138,-77.4875,
    -77.525,-77.6214,-77.534
  )
)

# Merge new coordinates with existing dataset

emissions_coordinates_joined <- emissions_coordinates_joined %>%
  left_join(manual_coords, by = "address_clean", suffix = c("", "_manual")) %>%
  mutate(
    lat = coalesce(lat, latitude),
    long = coalesce(long, longitude)
  ) %>%
  select(-latitude, -longitude)  # drop the temporary manual columns

# Remove coordinates with NAs
emissions_tidy <- emissions_coordinates_joined %>%
  drop_na(lat, long)

emissions_tidy


# Load the Loundoun boundary geojson file from local data
boundary <- st_read("data/raw_data/Loudoun_County_Boundary.geojson")

# Load the Loundoun waterbodies geojson file from local data
water_bodies <- st_read("data/raw_data/Loudoun_Water_Bodies.geojson")

  # Water bodies
  #geom_sf(
   # data = water_bodies,
   # fill = "lightblue",
   # color = "dodgerblue4",
   # alpha = 0.6
  #) 

# Convert points (latitude and longitude of data centers) to spatial features using st_as_sf()

emissions_sf <- st_as_sf(
  emissions_tidy,
  coords = c("long", "lat"),  # X first, Y second
  crs = 4326                  # WGS84 (standard GPS)
)

# Add units of measurement. 

emissions_sf <- emissions_sf %>%
  mutate(
    measurement_unit = case_when(
      pollutant_name %in% c("Carbon Monoxide",
                            "Nitrogen Oxide",
                            "Sulfur Dioxide",
                            "Volatile Organic Compounds") ~ "ppm",
      pollutant_name %in% c(
                            "Particulate Matter 2.5",
                            "Particulate Matter 10") ~ "µg/m³",
      TRUE ~ NA_character_
    )
  )

# Create combined facet label
emissions_sf <- emissions_sf %>%
  mutate(pollutant_label = paste0(pollutant_name, "(", measurement_unit, ")")) # 

# Convert to factor with specific order
emissions_sf <- emissions_sf %>%
  mutate(pollutant_label = factor(  # Must create pollutant_label first. Cannot factor it before it exists.)
    pollutant_label,
    levels = c(
      "Carbon Monoxide (ppm)",
      "Nitrogen Oxide (ppm)",
      "Sulfur Dioxide (ppm)",
      "Volatile Organic Compounds (ppm)",
      "Particulate Matter 2.5 (µg/m³)",
      "Particulate Matter 10 (µg/m³)"
    )
  ))

# Split datasets by measurement unit

emissions_gas <- emissions_sf %>%
  filter(measurement_unit == "ppm")

emissions_pm <- emissions_sf %>%
  filter(measurement_unit == "µg/m³")

# Map Gaseous Emissions 

viz3_map_gas <- ggplot() +
  geom_sf(data = boundary, fill = NA, color = "black", linewidth = 0.8) +
  geom_sf(data = water_bodies, fill = "lightblue", color = "steelblue", alpha = 0.2) +
  geom_sf(
    data = emissions_gas,
    aes(color = emission_value),
    size = 2
  ) +
 facet_wrap(~ pollutant_name) +
  scale_color_viridis_c(
    option = "viridis",
    trans = "log10",
    direction = -1, # reverses color scheme so dark color can reflect higher emission levels
    name = "Emission (ppm)"
  ) +
  theme_minimal() +
  labs(
    title = str_wrap ("Higher Emissions Are Concentrated in Eastern County Near Multiple Water Bodies", width = 45),
    subtitle = str_wrap ("Spatial Patterns of Log-Scaled Gaseous Emissions from Data Centers in Loudoun County (2024)", width = 60) 
  ) +
  theme(
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 14)
  )

print(viz3_map_gas)

# Map Particulate Emissions 

viz3_map_pm <- ggplot() +
  geom_sf(data = boundary, fill = NA, color = "black", linewidth = 0.8) +
  geom_sf(data = water_bodies, fill = "lightblue", color = "steelblue", alpha = 0.2) +
  geom_sf(
    data = emissions_pm,
    aes(color = emission_value),
    size = 2
  ) +
  facet_wrap(~ pollutant_name) +
  scale_color_viridis_c(
    option = "viridis",
    trans = "log10",
    direction = -1, # reverses color scheme so dark color can reflect higher emission levels
    name = "Emission (µg/m³)"
  ) +
  theme_minimal() +
  labs(
    title = str_wrap ("Higher Emissions Are Concentrated in Eastern County Near Multiple Water Bodies", width = 45),
    subtitle = str_wrap ("Spatial Patterns of Log-Scaled Particulate Matter Emissions from Data Centers in Loudoun County (2024)", width = 60) 
  ) +
  theme(
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 14)
  )

print(viz3_map_pm)
