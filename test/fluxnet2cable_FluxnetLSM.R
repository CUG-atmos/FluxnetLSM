# GLOBAL FLUXNET2015 processing for CABLE run
# -- 1 -- using the FluxnetLSM package (by Anna Ukkola)
# GR 20 Mar 2019
# GR 25 Mar 2019

# kongdd, 12 Dec 2019
# #########################
# library(fluxnetLSM)  # convert_fluxnet_to_netcdf
source('test/main_pkgs.R')
indir <- "G:/Github/data/flux/fluxnet212_raw/raw/FULLSET/tier1"
files <- dir(indir, recursive = T,
    pattern = "*.FULLSET_[HR|HH]_*.", full.names = T)
filesERA <- dir(indir, recursive = T,
             pattern = "*.ERAI_[HR|HH]_*.", full.names = T)

#--- User must define these ---#
# This directory should contain appropriate data from
# http://fluxnet.fluxdata.org/data/fluxnet2015-dataset/
# input data path
# in_path  <- "E:/fluxsites/GF_HH_HR_raw/"
# ERA_path <- "E:/fluxsites/GF_HH_HR_ERA/"

# Outputs will be saved to this directory
out_path <- "OUTPUTS"

# infiles <- get_fluxnet_files(in_path)
datasetversions <- map_chr(files, get_fluxnet_version_no)
site_codes      <- map_chr(files, get_path_site_code)

###--- Optional settings ---###
# default from -- ConvertSpreadsheetToNcdf.R --
### converstion set up
### -1- defult conversion set up
# conv_opts <- get_default_conversion_options() # DF values in conv_opts
### -2- personalised conversion set up
# get_default_conversion_options
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
    gapfill_flux      = 100, # Maximum   percentage of time steps allowed to be gap-filled, flux vars,  DF NA
    gapfill_good      = NA,
    gapfill_med       = NA,
    gapfill_poor      = NA,
    gapfill_era       = NA,
    gapfill_stat      = NA,
    min_yrs  = 1,             # Minimum number of consecutive years to process
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
# ERA_files     <- sapply(site_codes, function(x) get_fluxnet_erai_files(ERA_path, site_code=x))

#Stop if didn't find ERA files
if (any(sapply(filesERA, length) == 0) & conv_opts$met_gapfill == "ERAinterim") {
    stop("No ERA files found, amend input path")
}

#Loop through sites
temp <- foreach(site_code = site_codes, infile = files, file_EAR = filesERA,
    datasetversion = datasetversions, i = icount()) %do% {
    if (i <= 24) return()

    convert_fluxnet_to_netcdf(site_code, infile, file_EAR, out_path,
        conv_opts = conv_opts, datasetversion = datasetversion, plot = c("annual", "diurnal"))
}

# microbenchmark::microbenchmark(
#     d = fread(infile),
#     d = fread(infile) %>% as.data.frame(), times = 10
# )
