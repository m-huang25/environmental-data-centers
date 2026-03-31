Main README

## Title 

Air Pollutant Emissions Across Data Centers in Loudoun County

## Summary

This project examines air pollutant emissions from data centers in Loudoun County, Virginia, using regulatory emissions data, spatial layers, and data center locations. Analysis identifies key pollutants, emission patterns, and proximity to waterways, revealing clusters of emitting facilities and potential environmental exposure pathways for nearby water bodies.

## Rationale 

As of 2026, Loudoun County hosts over 209 operational data centers, with an additional 43 facilities under construction, making it the largest concentration of data centers globally. These facilities rely on thousands of diesel backup generators, which emit air pollutants.

These pollutants are associated with environmental concerns, such as smog formation, acid rain, and nutrient deposition that may affect nearby waterways. Given the importance of these local water bodies for drinking water supply, ecosystem health, and economic activity, understanding the cumulative emissions from data centers and how closely these facilities are situated to waterways - many of which are already deemed impaired - can help inform planning and regulatory discussions as the industry grows.

## Research Questions

- How many data centers in Loudoun County, Virginia emitted air pollutants in 2024?
- Which air pollutants are emitted at the highest levels by these data centers?
- Where are spatial clusters of air pollutant–emitting data centers located within Loudoun County, Virginia?
- What is the proximity of these data centers to nearby water bodies?


## Data Sources 

Virginia Department of Environmental Quality (DEQ): Air sites and emissions data

Piedmont Environmental Council: Virginia Data Centers (ArcGIS FeatureServer)

Loudoun County (OMAGI): County boundary and water bodies (GeoJSON)

## Methodology
- Integrated multiple datasets: data center locations, regulated air sites, emissions data, and spatial layers (county boundary and water bodies).
- Cleaned and standardized key variables (e.g., names, addresses) using tidyverse for accurate joins.
- Filtered to include only existing Loudoun County data centers.
- Linked emissions data to air sites, then joined to data center locations using standardized addresses.
- Filled missing coordinates via manual geocoding.
- Created visualizations: bar charts and log-scaled box plots.
- Converted data to spatial features with sf and generated maps using ggplot2 to examine geographic patterns and emissions distribution. 

## Instructions for Reproducing Project

- Clone the repository
- Install required R packages: tidyverse, sf, ggthemes, ggplot2
- Run the R scripts in order from the project root directory:
  - scripts/01_clean_air_sites.R
  - scripts/02_clean_emissions.R
  - scripts/03_clean_data_centers.R
  - scripts/04_join_air_emissions.R
  - scripts/05_join_with_data_center.R
  - scripts/06_analysis.R
  - scripts/07_visualizations.R
  - scripts/08_spatial_analysis.R

Notes:

Each script performs a distinct step in the modular data processing pipeline and should be run sequentially.

All file paths in the scripts are relative to the project root directory.

## Key Findings: 

- 52 data centers reported emissions in 2024.
- Nitrogen oxides and carbon monoxide were the highest gaseous emissions; PM10 and PM2.5 had similar levels.
- Most facilities emit multiple pollutants consistently.
- Emitting data centers cluster in eastern Loudoun County.
- Many are located near water bodies, suggesting potential exposure pathways.

## Audience: 

This repository is suitable for environmental researchers, data scientists, GIS analysts, policy makers, and students interested in air emissions, spatial analysis, and reproducible R workflows.

## Ethical Considerations

- Privacy: No personal data are included.
- Governance: All data are publicly available and ethically sourced.
- Bias: Potential biases in the datasets and analysis have been considered.

## Acknowledging Limitations

Emissions data represent only a subset of operating data centers.
Loudoun County data include only a subset of total facilities.
Analysis did not make any direct measurements of environmental or health impacts


## File Organization:
```
project_root/
├── data_center_research/
│ ├── data/ # Datasets used in the analysis
│ │ ├── raw_data/ # Original input datasets
│ │ ├── processed/ # Copies of original datasets with standardized titles
│ │ └── metadata/ # Metadata file describing the datasets
│ ├── notebooks/ # Jupyter notebooks
│ │ ├── archive/ # Previous drafts and exploratory notebooks
│ │ ├── data_center_loudoun_county_final.ipynb
│ │ └── README.txt
│ ├── outputs/ # Plots and maps
│ │ └── README.txt
│ └── scripts/ # Reproducible workflow scripts
│ └── README.txt
└── README.md  # This file
```
## Requirements: 

R packages: tidyverse, ggthemes, sf
Knowledge/Skills: GIS concepts and spatial data analysis

## License: 

Data used in this project are publicly available and subject to their respective terms of use.

These data are provided "as is" without any warranty, and the original data providers assume no liability for their use.

See the data/metadata/ folder for dataset-specific licensing information.

## Contact: 

Marjorie Huang, mhuang736@gmail.com