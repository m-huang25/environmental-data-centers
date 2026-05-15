## Air Pollutant Emissions Across Data Centers in Loudoun County, VA

This project investigates air pollutant emissions from data centers in Loudoun County, the world's largest and fastest-growing data center hub, where thousands of backup diesel generators across more than 209 facilities are raising growing environmental concerns. Using cleaned, filtered,and harmonized datasets linking air monitoring sites, emissions records, and data center locations - including manually geocoded facilities - this analysis combines statistical visualization techniques (bar charts and box plots) with spatial mapping to examine the concentration and distribution of key pollutants across the county. 

Among 52 facilities with publicly available emission records, all emit carbon monoxide (CO) and nitrogen oxides (NOx), while 96% emit volatile organic compounds (VOCs), 90% emit PM10 and 84% emit PM2.5 pollutants. Statistical analysis identifies potential high-emitting outlier facilities, suggesting that a subset of data centers may contribute disproportionately to local air pollution patterns. Spatial analysis further identifies clustering of data centers and associated emissions in eastern Loudoun County, including areas near sensitive waterways. 

Together, these findings establish a foundation for future work exploring emission drivers and potential impacts on surrounding surface waters and nearby communities.      

## Instructions for Reproducing Project

- Clone the repository
- Install required R packages: tidyverse, sf, ggthemes
- Run the R scripts in order from the project root directory:

Preprocessing - cleaned and standardized key variables:
  - scripts/01_clean_air_sites.R # Filtered for relevant cities and data center operations.
  - scripts/02_clean_emissions.R # Filtered for emission values and pollutants.
  - scripts/03_clean_data_centers.R # Filtered for Loudoun County and existing data centers.
  
Harmonizing:  
  - scripts/04_join_air_emissions.R # Joined emissions data to air sites.
  - scripts/05_join_with_data_center.R # Joined emissions data and air sites to data center locations using standardized addresses.
  
Analysis and Visualization: 
  - scripts/06_analysis.R # Initial analysis of preprocessed datasets to understand the characteristics and structure of the data.
  - scripts/07_visualizations.R # Bar charts and log-scaled box plots.
  - scripts/08_spatial_analysis.R # Maps to examine geographic patterns. 

Notes:

Each script performs a distinct step in the modular data processing pipeline and should be run sequentially.

## Data Sources 

Virginia Department of Environmental Quality (DEQ): Air sites and emissions data

Piedmont Environmental Council: Virginia Data Centers (ArcGIS FeatureServer)

Loudoun County (OMAGI): County boundary and water bodies (GeoJSON)

## Ethical Considerations

- Privacy: No personal data are included.
- Governance: All data are publicly available and ethically sourced.
- Bias: Potential biases in the datasets and analysis have been considered.

## Acknowledging Limitations

Emissions data represent only a subset of operating data centers.
Loudoun County data include only a subset of total facilities.
Analysis did not make any direct measurements of environmental or health impacts
`

## License: 

Data used in this project are publicly available and subject to their respective terms of use.

These data are provided "as is" without any warranty, and the original data providers assume no liability for their use.

See the data/metadata/ folder for dataset-specific licensing information.

## Contact: 

Marjorie Huang, XXX@gmail.com


