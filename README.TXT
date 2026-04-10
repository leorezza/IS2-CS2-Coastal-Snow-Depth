# ICESat-2 & CryoSat-2 Snow Depth Estimation over Arctic Sea Ice 

This repository contains a suite of MATLAB scripts developed to estimate snow depth on Arctic sea ice by synergetically combining laser altimetry (**ICESat-2**) and radar altimetry (**CryoSat-2**).

Developed as part of a Master’s Thesis at the **Technical University of Denmark (DTU)**, in collaboration with **UNIS (The University Centre in Svalbard)**, this toolbox is designed for research reproducibility and coastal Arctic studies.

## Methodology Overview

Snow depth is estimated by exploiting the different penetration depths of laser and radar pulses:
- **ICESat-2 (ATL03):** Measures the air-snow interface (top of the snow pack).
- **CryoSat-2:** Measures the snow-ice interface (top of the sea ice).
- **Snow Depth:** Calculated as the difference between the two elevation products, after careful spatial and temporal co-registration.

## Key Features

- **ATL03 Photon Processing:** Scripts to handle high-resolution ICESat-2 photon data, including noise filtering and surface finding.
- **Multi-Sensor Fusion:** Tools for aligning CryoSat-2 with ICESat-2 measurements.
- **Coastal Arctic Optimization:** Specific focus on the challenges of coastal regions and complex sea ice topographies.
- **Data Analysis:** Statistical tools to validate snow depth estimates against available reference data.


## Data Requirements

Note: This repository does not include the raw datasets. Users must obtain data from:
- **NSIDC:** For ICESat-2 ATL03 products.
- **ESA:** For CryoSat-2 SAR/SARIn products.

## Academic Context

This code was developed for the Master’s Thesis: *"Satellite-derived snow depth and sea ice thickness in coastal Arctic regions: a comparative study of Svalbard and Northern Greenland integrating ICESat2 and CryoSat2 observations"* at DTU Space and UNIS.

## License
Distributed under the MIT License.

