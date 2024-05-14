### Clear all variables
if( dev.cur() > 1 ) dev.off() #Delete figures
rm( list = ls( envir = globalenv() ), envir = globalenv() ) #Delete objects
gc()

library(sp)
library(ncdf4)
library(raster)
library(rgdal)

# Extent area 
ext <- extent(-180, 180, 64, 90) # define spatial extent 

# Set wd and define paths for .nc files
setwd("Data/Netcdf/RAW")
Path <- getwd()

tmp <- system(paste("ls",Path))

# list of file 
data_obs <- data.frame(file_name = tmp, date = format(strptime(substr(tmp, 1, 8),"%Y%m%d")), stringsAsFactors = F)

########################################################################################

lambda <- c("RRS412", "RRS443", "RRS490", "RRS510", "RRS560", "RRS665")
date <- character()

for (i in 1:dim(data_obs)[1]) {

index <- (i-1) %% 6 + 1
ncdf_file <- terra::rast(paste(Path, as.character(data_obs$file_name[i]), sep = ""), lambda[index])
#ncdf_file <- raster(paste(Path, as.character(data_obs$file_name[index]), sep = ""), varname = lambda[index])  
ncdf_file <- crop(ncdf_file, ext)
ncdf_file <- raster(ncdf_file)

#names(ncdf_file) <- lambda[index]
date[index] <- gsub("-", "", data_obs[i,2])

output_folder <- "/Users/argonauta74/Desktop/Laura_files_work/Laura_cropped_files/2009"
output_filename <- paste(date[index],'_',lambda[index],'_L3m_cci-4km-rep-v02.nc', sep = "")

# Write the raster to a NetCDF file in the dedicated folder
writeRaster(ncdf_file, 
            filename = file.path(output_folder, output_filename),
            xname='lon', yname='lat',
            format = "CDF",
            overwrite = TRUE)  # Set overwrite to TRUE if you want to overwrite an existing file

#writeRaster(ncdf_file, filename= paste(date[index],'_',lambda[index],'_L3m_cci-4km-rep-v02-crop.nc', sep = ""), 
#            xname='lon', yname='lat', format="CDF", overwrite=TRUE)

print(i)
print(index)

} # end of index

########################################################################################







