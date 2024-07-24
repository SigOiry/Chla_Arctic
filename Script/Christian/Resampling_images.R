## This scrit take a list of images and resampled them to the same grid

library(tidyverse)
library(terra)
library(ncdf4)

img_list <- "Data/CCI_v6/GSM/" %>% 
  list.files(full.names = T) %>% 
  as_tibble() %>% 
  rename(path = "value") %>% 
  mutate(name = gsub(".*/","",path))


template <- list.files("Data/template/", full.names = T) %>% 
  rast()

# find the extent of each image
for (i in 1:nrow(img_list)) {
  
  img <- rast(img_list$path[i])
  if (i == 1 ) {
    df_extent <- data.frame(
      xmin = rep(NA,nrow(img_list)),
      xmax = rep(NA,nrow(img_list)),
      ymin = rep(NA,nrow(img_list)),
      ymax = rep(NA,nrow(img_list))
        )
  }
  
  df_extent$xmin[i] <- ext(img)[1] %>% as.numeric()
  df_extent$xmax[i] <- ext(img)[2] %>% as.numeric()
  df_extent$ymin[i] <- ext(img)[3] %>% as.numeric()
  df_extent$ymax[i] <- ext(img)[4] %>% as.numeric()
}


for (i in 1:nrow(img_list)) {
  
  img <- rast(img_list$path[i])

  
  img_resampled <- resample(img,template) %>% 
    raster::raster()
  
  
  
  raster::writeRaster(img_resampled, 
              filename = paste0("D:/Resample_chouchou/",img_list$name[i]),
              xname='lon', yname='lat',
              format = "CDF",
              overwrite = TRUE)
  
}
