#load libraries
library(tidyverse)

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

