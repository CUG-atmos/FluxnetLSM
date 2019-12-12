# GLOBAL FLUXNET2015 processing for CABLE run
# -- 3 -- creat site list for CABLE run (CABLE set up by Juergen Knauer)
# RG 20 Mar 2019

rm(list=ls())
source('cable_data/R/labs.R')
library(FluxnetLSM)
library(ncdf4)
library(RNetCDF)

files <- dir("E:/fluxsites/GF_HH_HR_MET/Nc_files/Met/", full.names = T)

siteinfo <- list()
blist <- data.table()
sitelist_fun <- function(ncfile){
    tryCatch({
    # ncfile <- files[1]
    ncin <- nc_open(ncfile, write = T)
    sitecode  <-  gsub("*(-)*_.*", "\\1", basename(ncin$filename))
    latitude  <- round(ncvar_get(ncin, "latitude"), digits = 4)
    longitude <- round(ncvar_get(ncin, "longitude"), digits = 4)

    canopy_height <- NA
    tower_height  <- NA
    
    veg        <- ncvar_get(ncin, "IGBP_veg_long")
    vegetation <- str_trim(veg, "right")
    startyear  <- gsub(".*(\\d{4})-.+", "\\1", ncin$filename)
    endyear    <- gsub(".*-(\\d{4})_.*", "\\1", ncin$filename)
    nc_close(ncin)

    # info list for cable
    u <- data.table(sitecode  = sitecode,
                    startyear = startyear,
                    endyear   = endyear,
                    latitude  = latitude,
                    longitude = longitude,
                    canopy_height = canopy_height,
                    tower_height  = tower_height,
                    vegetation    = vegetation)
    return(u)
    }, error = function(e){
        message(sprintf("[e]: site = %s|%s", sitecode, e$message))
    })
}

site_list  <- lapply(files, sitelist_fun)
d_sitelist <- rbindlist(site_list)
rownames(d_sitelist) <- NULL
d_sitelist
listfile <- 'E:/fluxsites/GF_HH_HR_MET/FLUXNET_sitelist.txt'

# note the write format, 'sep' set to '\t' 
write.table(d_sitelist, listfile, append = FALSE, sep = "\t", 
            row.names = FALSE, col.names = TRUE, quote=FALSE)

# ******** end ********

