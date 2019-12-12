# GLOBAL FLUXNET2015 processing for CABLE run
# -- 1 -- using the FluxnetLSM package (by Anna Ukkola)
# GR 20 Mar 2019
# GR 25 Mar 2019

# #########################
#clear R environment
# rm(list=ls(all=TRUE))
rm(list=ls())
# load common library
source('R/labs.R')

# load anna package
library(FluxnetLSM)  # convert_fluxnet_to_netcdf


#############################
###--- Required inputs ---###
#############################

#--- User must define these ---#

# This directory should contain appropriate data from 
# http://fluxnet.fluxdata.org/data/fluxnet2015-dataset/
# input data path
in_path  <- "E:/fluxsites/GF_HH_HR_raw/"
ERA_path <- "E:/fluxsites/GF_HH_HR_ERA/"

# Outputs will be saved to this directory
out_path <- "E:/fluxsites/GF_HH_HR_LSM/"


#--- Automatically retrieve all Fluxnet files in input directory ---#
# Input Fluxnet data files (using FULLSET in this example, se R/Helpers.R for details)
infiles <- get_fluxnet_files(in_path)

#Retrieve dataset versions
datasetversions <- sapply(infiles, get_fluxnet_version_no)

#Retrieve site codes
site_codes      <- sapply(infiles, get_path_site_code)


###############################
###--- Optional settings ---###
###############################
# default from -- ConvertSpreadsheetToNcdf.R --

### converstion set up
### -1- defult conversion set up
# conv_opts <- get_default_conversion_options() # DF values in conv_opts
### -2- personalised conversion set up
conv_opts <- list(
    datasetname       = "FLUXNET2015",
    datasetversion    = "n/a",
    flx2015_version   = "FULLSET",
    fair_use          = "Fair_Use",
    fair_use_vec      = NA,
    met_gapfill       = 'ERAinterim', # set to "ERAinterim", "statistical" or NA
    flux_gapfill      = NA,  # set to "statistical" or NA
    missing_met       = 0,
    missing_flux      = 100,      
    gapfill_met_tier1 = 100, # Maximum percentage of time steps allowed to be gap-filled, Tier 1 met, DF NA
    gapfill_met_tier2 = 100, # Maximum percentage of time steps allowed to be gap-filled, Tier 2 met, DF NA
    gapfill_flux      = 100, # Maximum percentage of time steps allowed to be gap-filled, flux vars,  DF NA
    gapfill_good      = NA,
    gapfill_med       = NA,
    gapfill_poor      = NA,
    gapfill_era       = NA,
    gapfill_stat      = NA,        
    min_yrs  = 2,             # Minimum number of consecutive years to process
    linfill  = 86400,         # Maximum consecutive length of time (in hours) to be gap-filled, linear interpolation, DF 4 hours
    copyfill = 100,           # Maximum consecutive length of time (in number of days) to be gap-filled using copyfill, DF 10 days
    regfill  = 30,            # Maximum consecutive length of time (in number of days) to be gap-filled using multiple linear regression, DF 30 days
    lwdown_method      = "Abramowitz_2012",
    check_range_action = "stop",
    include_all_eval   = TRUE,
    aggregate          = NA,
    model              = NA,
    limit_vars         = NA,
    metadata_source    = 'all',
    add_psurf          = TRUE
)

# ERAinterim meteo file for gap-filling met data (set to NA if not desired)
# Find ERA-files corresponding to site codes
# conv_opts$met_gapfill  <- "ERAinterim"
ERA_files     <- sapply(site_codes, function(x) get_fluxnet_erai_files(ERA_path, site_code=x))

#Stop if didn't find ERA files
if(any(sapply(ERA_files, length)==0) & conv_opts$met_gapfill=="ERAinterim"){
    stop("No ERA files found, amend input path")
}



##########################
###--- Run analysis ---###
##########################

#Loop through sites
mapply(function(site_code, infile, ERA_file, datasetversion) {
    try(
        convert_fluxnet_to_netcdf(site_code = site_code,
                                  infile    = infile,
                                  out_path  = out_path,
                                  era_file  = ERA_file,
                                  conv_opts = conv_opts,
                                  datasetversion = datasetversion)
    )},
    site_code = site_codes,
    infile    = infiles,
    ERA_file  = ERA_files,
    datasetversion = datasetversions)

##########################
###--- end  process ---###
##########################
