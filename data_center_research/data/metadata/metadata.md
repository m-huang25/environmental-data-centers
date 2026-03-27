Title: Air Pollutant Emissions Across Data Centers in Loudoun County(2024)
Creator: Marjorie Huang, mhuang736@gmail.com
Date: 2025-11-27 to 2026-03-25
Location: Loudoun County, Virginia, USA
Bounding_box: [-77.963439, 38.844263, -77.323973, 39.326230]
Crs: EPSG:4326
Methods: 

## Dataset 1: pec_data_centers.csv
**Description**: Data center location data comes from the Data_Centers_Virginia FeatureServer (ArcGIS REST API), accessed via the Piedmont Environmental Council website. The FeatureServer provides geospatial data on existing and planned data centers across Virginia.
The original imported file was renamed from arcgis_table.csv to pec_data_centers.csv to reflect the content of the data. 
**Source:** Piedmont Environmental Council. https://www.pecva.org/region/loudoun/existing-and-proposed-data-centers-a-web-map/ 
**Retrieval Date:** 2025-11-27
**Query:** Retrieved all records from the Virginia Data Centers FeatureServer (ArcGIS REST API), layer 19, using a query that requested all fields 'outFields=* ' for all features (where=1=1) and excluded geometry (returnGeometry=false). The API returned JSON data, which was converted to CSV for processing. 
**Processing:**
      - Imported table from the source website into Juypter notebook       
      - Renamed column names to lower case
      - Handled missing latitude and longitude values
      - Selected only relevant columns related to locality                  ("Loudoun County") and build_status ("Existing")
      
**Variables:** 

  - name: locality
    description: Geographic location or jurisdiction of the
    data center
    type: string

  - name: name
    description: Official name of the data center
    type: string

  - name: owner_applicant
    description: Name of the entity that owns or has
    applied for the data center
    type: string

  - name: street_address
    description: Physical street address of the data center
    type: string

  - name: building_sq_ft
    description: Total building footprint in square feet
    type: numeric
    units: square feet

  - name: construction_type
    description: Type of construction material or structure
    type: string

  - name: build_status
    description: Current status of the building (e.g.,
    Existing, Proposed)
    type: categorical
    values: Existing, Proposed

  - name: lat
    description: Latitude coordinate of the data center
    location
    type: numeric
    units: decimal degrees

  - name: long
    description: Longitude coordinate of the data center 
    location
    type: numeric
    units: decimal degrees

**Quality notes, including limitations or caveats:** 
  - This dataset is crowd-sourced and may not include all existing data centers.
  - Some facilities may be missing, partially built, or not yet operational.
  - Data accuracy is limited by the fast pace of industry growth and variable data availability.
  - Existing data centers were cross-checked with aerial imagery where possible, but discrepancies may remain.
**License:** The Virginia Data Centers FeatureServer did not provide explicit license. Users should follow the site’s terms of use and provide attribution to the Virginia Data Centers if using the data. See https://services3.arcgis.com/mTaShYKffyWc5uRb/arcgis/rest/services/Data_Centers_Virginia/FeatureServer for details.

## Dataset 2: active_air_sites.csv
**Description**: Data on sites monitoring air pollutants provided by the Virginia Department of Environmental Quality (DEQ).The original retrieved file was renamed from Active_Air_Sites.csv to active_air_sites.csv for consistency with R naming conventions.
**Source:** Virginia Department of Environmental Quality, https://geohub-vadeq.hub.arcgis.com/pages/b207ffb4495e4f41949930743dbdc9b1
**Retrieval Date:** 2026-02-11
**Query:**  The active_air_sites.csv dataset comes from the Virginia Department of Environmental Quality GeoHub. The dataset reflects the full set of records provided at the time of download; no query filters or parameters were applied
**Processing:**
- Imported table from the source website into Juypter notebook
- Renamed column names to lower case
- Selected only relevant columns related to ciies within Loudoun County 
- Excluded facilities in Chantilly (Fairfax County) to restrict the dataset to only Loudoun County, though some excluded sites are near the Loudoun County boundary. Manually reviewed to remove non-Loudoun County facilities.
- Filtered records by principal_product using terms related to data centers (i.e., Data Center, data center, Data center, Data Processing, Information Systems, Communications/Internet, Diesel Generators, Emergency Generation, Backup Power Generation), followed by manual review to remove non-data center facilities.
- Joined the active_air_sites.csv with the air_sites_emissions.csv by"icid_id" to create a new object called air_emissions_joined. 
- Joined the air_emissions_joined dataset with the cleaned
version of pec_data_centers.csv by "address_clean" after
standardizing the addresses from both datasets. The result was a dataset with information (name of data center, address, latitude and longitude) to make spatial maps. 
**Variables:** 
  - name: name
    description: Name of the facility or site
    type: string

  - name: city
    description: City where the facility is located
    type: string

  - name: address
    description: Street address of the facility
    type: string

  - name: principal_product
    description: Primary product or activity associated  
    with the facility
    type: string

  - name: icis_id
    description: Unique identifier assigned to the facility     in the Integrated Compliance Information System (ICIS)
    type: string
**Quality notes,including limitations or caveats: ** 
**License:** The Virginia DEQ GeoHub provided the data for reference purposes only and are in the public domain; users may copy and use the data with attribution. Data are provided "as is" without warranty of accuracy, completeness, or fitness for a particular purpose, and DEQ assumes no liability for errors or damages resulting from use. Users agree not to use the data for unlawful purposes or attempt to derive personal information. Data should not be used for legal determinations and may be updated or removed without notice. See https://geohub-vadeq.hub.arcgis.com/pages/terms-of-use for full terms.

## Dataset 3: air_sites_emissions.csv
**Description**: Data on air pollutant emissions and emission values provided by the Virginia Department of Environmental Quality (DEQ).The original retrieved file was renamed from Air_Sites_Emissions_Totals.csv to air_sites_emissions.csv for consistency with project naming conventions and to reflect the actual year (2024) the data set reflects.
**Source:** Virginia Department of Environmental Quality, https://geohub-vadeq.hub.arcgis.com/pages/b207ffb4495e4f41949930743dbdc9b1
**Retrieval Date:** 2026-02-11
**Query:**  The active_air_sites.csv dataset comes from the Virginia Department of Environmental Quality GeoHub. The dataset reflects the full set of records provided at the time of download; no query filters or parameters were applied
**Processing:**
- Imported table from the source website into Juypter notebook
- Renamed column names to lower case
- Filtered by pollutant_name but excluded "Particulate Matter," which covers the entire range of particulate matter and is vague for assessing impacts on water bodies.  PM 2.5 and PM 10 provide more precise data based on size and their distinct risks to water bodies
- Added the pollutant units to the unique pollutants - parts (of gas) per million (ppm) for gaseous pollutants and micrograms per cubic meter (µg/m³) for particulate matter : Carbon Monoxide (ppm), Nitrogen Oxide (ppm), Sulfur Dioxide (ppm), Volatile Organic Compounds (ppm),Particulate Matter 2.5 (µg/m³), Particulate Matter 10 (µg/m³).
- Joined the air_sites_emissions.csv with the active_air_sites.csv by"icid_id" to create a new object called air_emissions_joined 
- Joined the air_emissions_joined dataset with the cleaned version of pec_data_centers.csv by "address_clean after standardizing the addresses from both datasets. The result was a dataset with information (name of data center, address, latitude and longitude) to make spatial maps. 
**Variables:** .
  - name: emissions_year
    description: Year in which the emissions were recorded
    type: integer

  - name: emission_value
    description: Quantity of pollutant emissions reported
    for the given year
    type: numeric

  - name: icis_id
    description: Unique identifier assigned to the facility
    in the Integrated Compliance Information System (ICIS)
    type: string

  - name: pollutant_name
    description: Name of the pollutant associated with the
    reported emissions
    type: string
**Quality notes, including limitations or caveats:** 
  - Some records may have missing or incomplete values (e.g., emissions data).
  - The dataset reflects a snapshot in time and may not include recent updates or changes.
  - Filtering was applied to include only selected variables and relevant records (e.g., specific localities or facility types).
  - Emissions values and facility attributes are based on reported data and may be subject to measurement or reporting uncertainty.
**License:** The Virginia DEQ GeoHub provided the data for reference purposes only and are in the public domain; users may copy and use the data with attribution. Data are provided "as is" without warranty of accuracy, completeness, or fitness for a particular purpose, and DEQ assumes no liability for errors or damages resulting from use. Users agree not to use the data for unlawful purposes or attempt to derive personal information. Data should not be used for legal determinations and may be updated or removed without notice. See https://geohub-vadeq.hub.arcgis.com/pages/terms-of-use for full terms.

## Dataset 4: Loudoun_County_Boundary.geojson
**Description**: The Loudoun County Office of Mapping and Geographic Information (OMAGI) provided this GeoJSON file containing the geographic boundary of Loudoun County, Virginia, used to define the spatial extent of the research area.
**Source:** https://geohub-loudoungis.opendata.arcgis.com/maps/LoudounGIS::loudoun-county-boundary/explore?location=39.085250%2C-77.643700%2C10
**Retrieval Date:** 2026-21-01
**Query:** The dataset reflects the full set of records provided at the time of download; no query filters or parameters were applied
**Processing:**
  - Imported boundary GeoJSON files using sf in R
  - Used spatial layers as basemaps for emissions visualization
  - Ensured coordinate system compatibility with emissions data 
   (EPSG:4326)
**Attributes:** 
    name: CO_COUNTY
    description: Name of the county boundary (Loudoun  
    County)
    type: string
**Quality notes, including limitations or caveats::** 
**License:**  
  - Data are provided "as is" without warranty of any kind, expressed or implied.
  - Loudoun County assumes no liability for errors or for any use of the data.

## Dataset 5: Loudoun_Water_Bodies.geojson
**Description**: The Loudoun County Office of Mapping and Geographic Information (OMAGI) provided this GeoJSON file containing mapped water bodies within Loudoun County, Virginia, used to represent surface water features in the study area.
**Source:** https://geohub-loudoungis.opendata.arcgis.com/datasets/loudoun-water-bodies/about 
**Retrieval Date:** 2026-21-01
**Query:** The dataset reflects the full set of records provided at the time of download; no query filters or parameters were applied
**Processing:**
  - Imported water body GeoJSON files using sf in R
  - Used spatial layers as basemaps for emissions visualization
  - Ensured coordinate system compatibility with emissions data 
   (EPSG:4326)
**Attributes:** 
Attributes associated with each water body feature:
attributes:
  
  - name: WA_TYPE
    description: Classification of the water body (e.g., lake, pond, river)
    type: string

  - name: SHAPE_Length
    description: Perimeter length of the water body feature
    type: numeric

  - name: SHAPE_Area
    description: Area of the water body feature
    type: numeric

**Quality notes, including limitations or caveats:** 
  - >90% attribute accuracy with QA/QC validation; meets NSSDA positional standards (95% confidence).
  - Updated in phases using aerial imagery; some areas may be outdated.
  - Intended for ~1:2400 scale; accuracy may vary at other scales
  - While countywide coverage is provided, some features may be outdated or incomplete

**License:** 
Loudoun County assumes no liability for use of or reliance on the data. 
 
