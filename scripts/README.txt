Overview:

The scripts folder contains modular R scripts used to clean, integrate, analyze, and visualize data for the project. The scripts are designed to be run sequentially as a reproducible workflow.

Run the scripts in the following order:

01_clean_air_sites.R

02_clean_emissions.R

03_clean_data_centers.R

04_join_air_emissions.R

05_join_with_data_center.R

06_analysis.R

07_visualizations.R

08_spatial_analysis.R

Script Descriptions:
01–03 (Data Cleaning):
Clean and standardize raw datasets, including air sites, emissions data, and data center locations

04 (Data Integration):
Join emissions data to air site facilities and link to data center locations using identifiers

05 (Data Integration)
Join results from script 04 to data center locations using standardized addresses

06 (Analysis):
Perform exploratory data analysis, including how many data centers are emitting each pollutant

07 (Visualizations):
Generate bar charts and log-scaled box plots

08 (Spatial Analysis):
Convert data to spatial features and create maps to examine geographic patterns and proximity to water bodies

How to Run:

From the project root directory (the top-level folder containing scripts/, data/, and outputs/), run each R script in order:
source("scripts/01_clean_air_sites.R")
source("scripts/02_clean_emissions.R")
source("scripts/03_clean_data_centers.R")
source("scripts/04_join_air_emissions.R")
source("scripts/05_join_with_data_center.R")
source("scripts/06_analysis.R")
source("scripts/07_visualizations.R")
source("scripts/08_spatial_analysis.R")

Notes

All file paths in the scripts are relative to the project root directory, so no setwd() changes are required.

Required R packages: tidyverse, sf, and ggthemes

Raw datasets (including JSON and CSV files) are stored in data/raw_data/.
Intermediate datasets are cleaned and processed files saved in data/processed/ and used in subsequent steps of the workflow.

Visual outputs are saved in:
outputs/



