### Clear all variables
if( dev.cur() > 1 ) dev.off() #Delete figures
rm( list = ls( envir = globalenv() ), envir = globalenv() ) #Delete objects
gc()

###-------------------------------------------------------------------------------------------------
### Load packages 
library(qchlorophyll)
library(ncdf4)
library(dplyr)
library(oceancolouR)
library(raster)

###-------------------------------------------------------------------------------------------------
# Set the directory containing the NetCDF files

netcdf_path <- "/Users/argonauta74/Desktop/Laura_files_work/Laura_cropped_files/2007"

# List all NetCDF files in the directory
file_list <- list.files(netcdf_path, pattern = "\\.nc$", full.names = TRUE)

lambda <- c("RRS412", "RRS443", "RRS490", "RRS510", "RRS560", "RRS665")
list_df <- list()

for (i in 1:length(file_list)) {

  index <- (i-1) %% 6 + 1  
  rrs <- load_nc_file(file_list[i], variables = lambda[index])
  rrs <- rrs %>% mutate(id_pixel = row_number())
  list_df[[i]] <- rrs
  rm(rrs)
  
  print(index)
}

subset_list <- list()

# Use a for loop to subset the list
for (i in seq(1, length(list_df), by = 6)) {
  
  end <- min(i + 5, length(list_df))
  subset_list <- list_df[i:end]
  
  combined_df <- Reduce(function(x, y) {
    left_join(x, y, by = c("lat","lon","id_pixel", "date","id_date", "month", "year"))
  }, subset_list)
  
  # Subset the df and get only rrs columns  
  rrs_df <- combined_df[, c("RRS412", "RRS443", "RRS490", "RRS510", "RRS560", "RRS665")]
  
  ### Create a matrix of rrs values from above to below sea level: 
  rrs_bw <- unname(sapply(rrs_df, function(rrs) rrs/(0.52 + 1.7*rrs))) 
  
  # Select wavelengths 
  lambda <- c(412, 443, 490, 510, 560, 665)
  
  # Compute the inherent optical properties (IOPs) of the water (adg443, bbp443, chla) 
  # using the GSMsemi-analytical algorithm with default globally-tuned exponent
  # run GSM to process multiple records stored in an rrs matrix, where rows=records and columns=wavelengths
  
  # Lower bounds for parameters
  lower_bounds <- c(0, 0.0001, 0.0001)
  
  # Upper bounds for parameters
  upper_bounds <- c(64, 2, 0.1)
  
  GSM_IOPs <- t(apply(X=rrs_bw, MARGIN=1, FUN=gsm, lambda=lambda, 
                      algorithm="port", lower=lower_bounds , upper =upper_bounds))
  
  ###-------------------------------------------------------------------------------------------------
  
  # Add GSM data to Original data frame
  combined_df <- combined_df %>% mutate(chl_GSM = GSM_IOPs[,1], adg443_GSM = GSM_IOPs[,2], 
                                        bbp443_GSM = GSM_IOPs[,3], invalid_GSM = GSM_IOPs[,4])
  # Subset to get only Lat, Lon, and Chl_GSM
  Chl_gsm_df <- combined_df[,c('lon','lat','chl_GSM')]
  
  #
  r <- rasterFromXYZ(Chl_gsm_df)
  projection(r) <- CRS(as.character(NA))
  new.prj <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84")  
  projection(r) <- new.prj
  isLonLat(r)
  
  date_file <- gsub("-", "", unique(combined_df$date))
  
  output_folder <- "/Users/argonauta74/Desktop/Laura_files_work/Chl_output_files/"
  output_filename <- paste('L3m_',date_file,'_CHL_GSM-4km-rep-v02.nc', sep = "")
  
  # Write the raster to a NetCDF file in the dedicated folder
  writeRaster(r, 
              filename = file.path(output_folder, output_filename),
              xname='lon', yname='lat',
              format = "CDF",
              overwrite = TRUE)  # Set overwrite to TRUE if you want to overwrite an existing file
  
  rm(rrs_df)
  rm(rrs_bw)
  rm(combined_df)
  rm(GSM_IOPs)
  rm(Chl_gsm_df)
  rm(date_file)
  rm(r)
  
}

###-------------------------------------------------------------------------------------------------
# end script 
