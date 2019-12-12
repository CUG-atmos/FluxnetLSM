# GLOBAL FLUXNET2015 processing for CABLE run
# -- 4 -- change vars in nc
# -- 5 -- add MODIS LAI
# GR 20 Mar 2019
# GR 25 Mar 2019

# !!! before processing, copy NC Met generated from Anna package to new folder
# new folder is "E:/fluxsites/GF_HH_HR_MET/Nc_files/Met" in this case

rm(list=ls())
source('R/labs.R')

library(ncdf4)
library(cmsaf)
library(lubridate)
library(zoo)

# nc files
files <- dir("E:/fluxsites/GF_HH_HR_MET/Nc_files/Met/", full.names = T) # folder

# ############################
# function to get time from nc
getNcTime <- function(nc) {
    require(lubridate)
    ncdims  <- names(nc$dim) #get netcdf dimensions
    timevar <- ncdims[which(ncdims %in% c("time", "Time", "datetime", "Datetime", "date", "Date"))[1]] #find time variable
    times   <- ncvar_get(nc, timevar)
    if (length(timevar)==0) stop("ERROR! Could not identify the correct time variable")
    timeatt  <- ncatt_get(nc, timevar) #get attributes
    timedef  <- strsplit(timeatt$units, " ")[[1]]
    timeunit <- timedef[1]
    tz <- timedef[5]
    timestart <- strsplit(timedef[4], ":")[[1]]
    if (length(timestart) != 3 || timestart[1] > 24 || timestart[2] > 60 || timestart[3] > 60 || any(timestart < 0)) {
        cat("Warning:", timestart, "not a valid start time. Assuming 00:00:00\n")
        warning(paste("Warning:", timestart, "not a valid start time. Assuming 00:00:00\n"))
        timedef[4] <- "00:00:00"
    }
    if (! tz %in% OlsonNames()) {
        cat("Warning:", tz, "not a valid timezone. Assuming UTC\n")
        warning(paste("Warning:", timestart, "not a valid start time. Assuming 00:00:00\n"))
        tz <- "UTC"
    }
    timestart <- ymd_hms(paste(timedef[3], timedef[4]), tz=tz)
    f <- switch(tolower(timeunit), #Find the correct lubridate time function based on the unit
                seconds=seconds, second=seconds, sec=seconds,
                minutes=minutes, minute=minutes, min=minutes,
                hours=hours,     hour=hours,     h=hours,
                days=days,       day=days,       d=days,
                months=months,   month=months,   m=months,
                years=years,     year=years,     yr=years,
                NA
    )
    suppressWarnings(if (is.na(f)) stop("Could not understand the time unit format"))
    timestart + f(times)
}

# #########################
# ### asign LAI to site ###
# original LAI downloaded from MODIS at each site 
# "X:/LCD/MODIS/MOD15A2_GLOBALFLUX/LAI" {3*3} grid at 1 km resolution

# ## processed LAI on daily scale {smoothed and gapfilled}
filelai <- "E:/fluxsites/MODIS_LAI_daily/gf_smth_LAI_1D.csv"
df <- fread(filelai, sep = ",", header = T, showProgress = F, verbose = F)
df %<>% data.table()
df$date   %<>% as.Date(format = "%d/%m/%Y")
df$DateTime <- as.POSIXct(paste(df$date, "00:00:00"), format="%Y-%m-%d %H:%M:%S")
df$DateTime <- with_tz(df$DateTime, 'UTC')
myVector    <- c('date','site', 'DateTime', 'LAI_f')
d_set <- df[, myVector, with=FALSE]

# loop through all sites
for(file in files){
    tryCatch({
        # ## test site ##
        # file <- files[2]
        
        # change var names: Psurf(_qc) to PSurf(_qc)
        change_att('Psurf',file, v_name='PSurf')
        change_att('Psurf_qc',file, v_name='PSurf_qc')
        
        # --1-- match LAI to nc
        # 1) get time var in nc
        sitecode <- sitecode <- gsub("*(-)*_.*", "\\1", basename(file))
        ncin     <- nc_open(file, write = T)
        times    <- ncvar_get(ncin, varid = 'time')
        tm_utc   <- getNcTime(ncin)
        nc_t     <- data.table(DateTime = tm_utc, site = sitecode)
        
        # 2) get MODIS LAI according to sitecode
        d_sub <- d_set[site == sitecode]
        
        # 3) interpolate daily LAI to HH|HR
        # with interpolation time frame set to period when LAI is available 
        # with -9999 asign to missing
        if(nrow(d_sub)>0){
            # set LAI interpolation time frame 
            s_time <- d_sub$DateTime[1]-days(3)
            e_time <- d_sub$DateTime[nrow(d_sub)]+ days(2) # additional two days at the end of time frame
            o_sub  <- merge (d_sub,nc_t,by = c('DateTime', 'site'), all=TRUE)
            o_sub %<>% data.table()
            o_sub[s_time<=o_sub$DateTime & o_sub$DateTime<=e_time, itp_id := 1]
            # interpolate, linear
            o_sub$LAI_f <- na.approx(o_sub$LAI_f,  na.rm = TRUE)
            o_sub[, LAI:= ifelse(!is.na(itp_id), LAI_f, NA)] 
        } else {
            o_sub <- merge (d_sub,nc_t,by = c('DateTime', 'site'), all=TRUE)
            o_sub %<>% data.table()
            o_sub$LAI <- NA
        }
        # plot(o_sub$DateTime, o_sub$LAI)
        
        
        # ---2--- save LAI to nc
        # 1) ### set nc var ###
        xd <- ncin$dim[['x']]
        yd <- ncin$dim[['y']]
        td <- ncin$dim[['time']]
        mv <- -9999
        
        var_lai <- ncvar_def(name  = 'LAI', 
                             units = 'm2/m2', 
                             dim   = list(xd,yd,td), 
                             longname = 'MOD15A2 LAI',
                             missval = mv )
        var_rain <- ncvar_def(name   = 'Rainf',
                              units  = 'mm/s', 
                              dim    = list(xd,yd,td), 
                              longname = 'Rainfall',
                              missval = mv )
        var_rain_qc <- ncvar_def(name   = 'Rainf_qc',
                                 units  = '-', 
                                 dim    = list(xd,yd,td), 
                                 longname = 'Rainfall quality control flag',
                                 missval = mv )
        
        
        # 2) ### add var lai to nc ###
        ncin <- ncvar_add(ncin, var_lai)
        ncin <- ncvar_add(ncin, var_rain)
        ncin <- ncvar_add(ncin, var_rain_qc)
        
        rain    <- ncvar_get(ncin, varid = 'Precip')
        rain_qc <- ncvar_get(ncin, varid = 'Precip_qc')
        
        # 3) ### asign value to lai var in nc ###
        nt <- length(times)
        for (i in 1:nt) { 
            ncvar_put(nc    = ncin, 
                      varid = var_lai, 
                      vals  = o_sub$LAI[i], 
                      start = c(1, 1, i), 
                      count = c(-1, -1, 1))
            ncvar_put(nc    = ncin, 
                      varid = var_rain, 
                      vals  = rain[i], 
                      start = c(1, 1, i), 
                      count = c(-1, -1, 1))
            ncvar_put(nc    = ncin, 
                      varid = var_rain_qc, 
                      vals  = rain_qc[i], 
                      start = c(1, 1, i), 
                      count = c(-1, -1, 1))
        }
        # print(ncin)
        
        # show assigned result
        print(paste("The file", sitecode, "has", ncin$nvars,"variables"))
        nc_close(ncin) # close 
    },
    error = function(e) message(sprintf("%s", e)))
}

# ###########
# ### END ###
# ###########
