# load labs

library(data.table)
library(plyr)
# library(lubridate)
# library(tidyverse)
library(magrittr)
library(Cairo)
library(maptools)
library(ggpmisc)
library(ggplot2)
library(devtools)
library(zoo)
library(quantreg)

# for install of FluxnetLSM from Anna https://github.com/kongdd/FluxnetLSM
library('R.utils')
library('ncdf4')
library('xml2')
library('rvest')
library('devtools')
library('githubinstall')
# library('Rtools')
# library(ggplus)

# githubinstall("FluxnetLSM") # or
# devtools::install_github("kongdd/FluxnetLSM")


# # function to separate data to steps of x, obtain 95 quantile value for smooth 
# upper_envelope <- function(x, y, step = 0.2, alpha = 0.95){
#     xrange <- range(x, na.rm = T)
#     
#     brks <- seq(xrange[1], xrange[2], by = step)
#     n    <- length(brks)
#     xmid <- (brks[-n] + brks[-1])/2
#     
#     brks[n] <- Inf
#     
#     res <- numeric(n-1)*NA_real_
#     
#     for (i in 1:(n-1)){
#         val_min <- brks[i]
#         val_max <- brks[i+1]
#         
#         I <- x >= val_min & x < val_max
#         res[i] <- quantile(y[I], alpha, na.rm = T)
#     }
#     
#     data.table(x = xmid, y = res)
# }
