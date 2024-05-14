
# GSM_Laura_Update

## Overview

This project provides a set of functions for processing NetCDF files, specifically for cropping and analyzing ocean color data using the GSM (Global Solar Maps) method. The main functionalities include cropping NetCDF files to specified geographical bounds and processing them to obtain chlorophyll concentrations.

## Author

Simon Oiry

## Files

- **GSM_Update.Rmd**: An R Markdown file containing the scripts and functions necessary for processing the data.

## Dependencies

The following R packages are required:

- `ncdf4`
- `tidyverse`
- `terra`
- `qchlorophyll`
- `oceancolouR`
- `parallel`
- `tictoc`

## Installation

To install the required packages, you can use the following commands in R:

```R
install.packages(c("ncdf4", "tidyverse", "terra", "qchlorophyll", "parallel", "tictoc"))
# For oceancolouR, install from GitHub
remotes::install_github("BIO-RSG/oceancolouR", build_vignettes = TRUE)
```

## Functions

### 1. Cropping_CCI

This function crops NetCDF files to specified geographical boundaries.

**Arguments:**
- `path`: Path to the directory containing NetCDF files.
- `xmin`, `xmax`, `ymin`, `ymax`: Geographical bounds for cropping.
- `saveNC`: Logical, whether to save the cropped files as NetCDF.

### 2. GSM

This function processes the cropped images to generate chlorophyll maps.

**Arguments:**
- `path`: Path to the directory containing cropped TIFF files.
- `lower_bounds`, `upper_bounds`: Bounds for the GSM function.
- `lambda`: Wavelengths used by the GSM function.

### 3. Batch_processing

This function handles the entire processing pipeline, from cropping to generating chlorophyll maps.

**Arguments:**
- `path`: Path to the directory containing raw NetCDF files.
- `path_cropped`: Path to the directory for saving cropped TIFF files.
- `lower_bounds`, `upper_bounds`, `lambda`: Parameters for the GSM function.
- `xmin`, `xmax`, `ymin`, `ymax`: Geographical bounds for cropping.
- `saveNC`: Logical, whether to save the cropped files as NetCDF.

## Usage

To use the batch processing function, you can run the following command in R:

```R
Batch_processing(path ="Data/CCI_v5/NC")
```

### Arguments

- `path`: Path location of raw NetCDF files. (default = `Data/CCI_v5/NC`)
- `path_cropped`: Path location of cropped TIFF files. (default = `Data/CCI_v5/Cropped_TIF`)
- `xmin`: Minimum longitude to crop the image. (default = `-180`)
- `xmax`: Maximum longitude to crop the image. (default = `180`)
- `ymin`: Minimum latitude to crop the image. (default = `64`)
- `ymax`: Maximum latitude to crop the image. (default = `90`)
- `saveNC`: Logical, whether to save NetCDF files at the cropping step. (default = `FALSE`)
- `lower_bounds`: Lower bounds used by the GSM function. (default = `c(0, 0.0001, 0.0001)`)
- `upper_bounds`: Upper bounds used by the GSM function. (default = `c(64, 2, 0.1)`)
- `lambda`: Wavelengths used by the GSM function. (default = `c(412, 443, 490, 510, 560, 665)`)

## License

Specify the license under which the project is distributed.
