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

# Detemine is there are any missing values or NAs
if (any(is.na(air_sites_clean))) {
  print("There are missing values")
} else {
  print("No missing values ✅")
}

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

# List and count the categories within the "pollutant_name" categories

unique(air_sites_emissions_clean$pollutant_name)
length(unique(air_sites_emissions_clean$pollutant_name))

# Select only relevant columns
air_sites_emissions_clean <- air_sites_emissions_clean %>%
    select(emissions_year, emission_value, icis_id, pollutant_name)

air_sites_emissions_clean 

# Check if missing values exist
any(is.na(air_sites_emissions_clean))

# Count total number of missing values
sum(is.na(air_sites_emissions_clean))

# Examine how many unique identifier have missing emission values
num_missing_unique_identifiers <- air_sites_emissions_clean %>%
  filter(is.na(emission_value)) %>%    # keep only rows where emission_value is missing
  summarise(unique_identifiers_missing_emission_values = n_distinct(icis_id))

num_missing_unique_identifiers

# Join acive air site and air site emissions datasets

air_emissions_joined <- left_join(x = air_sites_clean, y = air_sites_emissions_clean, by = "icis_id")

air_emissions_joined <- air_emissions_joined[complete.cases(air_emissions_joined), ]

glimpse (air_emissions_joined) # data is in long format

# Examine unque number of data centers
unique(air_emissions_joined$name)
length(unique(air_emissions_joined$name))

unique(air_emissions_joined$address)
length(unique(air_emissions_joined$address))

#Create a table of Cities
table(air_emissions_joined$city)

# Length of "emission_value" to determine count of unique value
length(unique(air_emissions_joined$emission_value))

# Analyze how many data centers are emitting each pollutant; distinct data centers can emit more than one pollutant

unique(air_emissions_joined$pollutant_name)

air_emissions_joined %>%
  filter(principal_product %in% c('Data Center', 'data center', 'Data center', 'Data Processing', 'Information systems', 'Communications/Internet', 'Diesel Generators', 'Emergency Generation', 'Backup Power Generation')) %>%
  group_by(pollutant_name) %>%
  summarise(num_data_centers = n()) # num_data_centers is a new column name

#Import CSV file on data centers in Virginia
data_centers <- read.csv("data/processed/pec_data_centers.csv")

#show first 10 rows
head(data_centers, 10)

# Get the dimensions of the dataframe
dim(data_centers)

# Examine the variables of the dataset
names(data_centers)

# Examine the structure of the dataset
str(data_centers)

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

# Check what doesn't match
setdiff(air_emissions_joined$address_clean,
        data_centers_clean$address_clean)

setdiff(data_centers_clean$address_clean,
        air_emissions_joined$address_clean)

length(setdiff(data_centers_clean$address_clean,
               air_emissions_joined$address_clean))

length(setdiff(air_emissions_joined$address_clean,
               data_centers_clean$address_clean))

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

# Double check that all addresses have latitude and longtitude

emissions_coordinates_joined %>%
  filter(is.na(lat) | is.na(long))

# emissions_coordinates_joined

# Remove coordinates with NAs
emissions_tidy <- emissions_coordinates_joined %>%
  drop_na(lat, long)

emissions_tidy

# Check removal worked - second number should be smaller than the firest week
nrow(emissions_coordinates_joined)
nrow(emissions_tidy)

sum(is.na(emissions_tidy$lat))

length(unique(emissions_tidy$address_clean))


