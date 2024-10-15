library(future)
library(doFuture)
options(future.globals.maxSize = 4e9)
library(foreach)
library(tidyverse)
library(haven)
library(readxl)
library(rms)
library(tableone)
plan(multisession, workers = 4)

library(progressr)
handlers(global = TRUE)
handlers("progress")

#Check for unprocessed datasets
dta_list = dir(paste0(cen_dir,"Downloads/Census/Stata Datasets/"))
dta_list = dta_list[!dta_list %in% c("Archive.7z")]
r_list = dir(paste0(cen_dir,"Downloads/Census/R Datasets/"))
r_list = sub("\\.RData","\\.dta",r_list)
dta_list2 = dta_list[!dta_list %in% r_list]

#Run analysis for unprocessed datasets
foreach(dta = dta_list2) %do% {
  
  data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
  # data_loc2 = paste0(cen_dir,"Downloads/Census/Summaries/")
  data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
  file_name = paste0(data_loc3,dta)
  r_name = paste0(data_loc,sub("\\.dta","\\.RData",dta))
  # r_sum_name = paste0(data_loc2,sub("\\.dta","\\_Summary.RData",dta))
  
  dck = read_dta(file_name)
  dck = dck %>% mutate(across(c(female,urban_new,age_group),~as.double(.x)))
  save(dck,file = r_name)
  
  file.remove(file_name)
}

rm(dta_list,dta_list2,r_list,data_loc,data_loc3,file_name,r_name,dta,dck)
gc()
