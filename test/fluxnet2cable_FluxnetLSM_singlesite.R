# using the FluxnetLSM package

rm(list=ls())
source('R/labs.R')

library(FluxnetLSM) 

#clear R environment
rm(list=ls(all=TRUE))


#############################
###--- Required inputs ---###
#############################

#--- User must define these ---#

#Fluxnet site ID (see http://fluxnet.fluxdata.org/sites/site-list-and-pages/)
site_code <- "AU-Tum"

# This directory should contain appropriate data from 
# http://fluxnet.fluxdata.org/data/fluxnet2015-dataset/
in_path <- "E:/fluxsites/GF_HH_HR_raw/"
ERA_path <- "E:/fluxsites/GF_HH_HR_ERA/"

#Outputs will be saved to this directory
out_path <- "E:/fluxsites/GF_HH_HR_MET/sample"


#--- Automatically retrieve all Fluxnet files in input directory ---#

# Input Fluxnet data file (using FULLSET in this example, see R/Helpers.R for details)
infile <- get_fluxnet_files(in_path, site_code)

#Retrieve dataset version
datasetversion <- get_fluxnet_version_no(infile)

#Retrieve ERAinterim file
era_file <- get_fluxnet_erai_files(ERA_path, site_code)


###############################
###--- Optional settings ---###
###############################

#Retrieve default processing options
# conv_opts <- get_default_conversion_options(min_yrs = 3)

# Set gapfilling options to ERAinterim
# conv_opts$met_gapfill  <- "ERAinterim"

conv_opts <- list(
    datasetname        = "FLUXNET2015",
    datasetversion     = "n/a",
    flx2015_version    = "FULLSET",
    fair_use           = "Fair_Use",
    fair_use_vec       = NA,
    met_gapfill        = 'ERAinterim',
    flux_gapfill       = NA,
    missing_met        = 0,
    missing_flux       = 100,
    gapfill_met_tier1  = 100,
    gapfill_met_tier2  = 100,
    gapfill_flux       = 100,
    gapfill_good       = NA,
    gapfill_med        = NA,
    gapfill_poor       = NA,
    gapfill_era        = NA,
    gapfill_stat       = NA,        
    min_yrs            = 2,
    linfill            = 86400,
    copyfill           = 100,
    regfill            = 30,
    lwdown_method      = "Abramowitz_2012",
    check_range_action = "stop",
    include_all_eval   = TRUE,
    aggregate          = NA,
    model              = NA,
    limit_vars         = NA,
    metadata_source    = 'all',
    add_psurf          = TRUE
)



##########################
###--- Run analysis ---###
##########################

convert_fluxnet_to_netcdf(site_code = site_code, infile = infile,
                          era_file  = era_file, out_path = out_path,
                          conv_opts = conv_opts)


#Alternatively you can pass the gapfilling option directly to the main function:
# convert_fluxnet_to_netcdf(site_code = site_code, infile = infile, 
#                           era_file = era_file, out_path = out_path,
#                           met_gapfill="ERAinterim")
