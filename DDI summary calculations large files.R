library(future)
library(doFuture)
options(parallelly.fork.enable = TRUE)
options(future.globals.maxSize = 4e9)
library(foreach)
library(tidyverse)
library(haven)
library(readxl)
library(rms)
library(tableone)

library(progressr)
handlers(global = TRUE)
handlers("progress")

data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
data_loc2 = paste0(cen_dir,"Downloads/Census/Summaries/")
data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
# dta_append = "_Cleaned_Individual_Data_Trimmed.dta"
r_append = ".RData"
dta_list = dir(paste0(cen_dir,"Downloads/Census/Stata Datasets/"))

if("IPUMS_Cleaned_Individual_Data_Trimmed.dta" %in% dta_list) {
  plan(sequential)
  dta = "IPUMS_Cleaned_Individual_Data_Trimmed.dta"
  file_name = paste0(data_loc3,dta)
  dck2 = read_dta(file_name)
  dck2 = dck2 %>% mutate(across(c(country_name,country_abrev,country_dataset_year,admin1,admin2),~as.character(as_factor(.x))))
  dck2 = dck2 %>% mutate(country_dataset_year = sub(" IPUMS ","_IPUMS_",country_dataset_year))
  dck2 = dck2 %>% filter(!country_dataset_year=="Vietnam_IPUMS_2009")
  datasets = unique(dck2$country_dataset_year)
  foreach(i = datasets) %do% {
    # dck %>% filter(country_dataset_year==i) %>% write_dta(path = paste0(data_loc3,i,dta_append))
    dck = dck2 %>% filter(country_dataset_year==i)
    save(dck, file = paste0(data_loc,i,r_append))
  }
  file.remove(file_name)
  rm(dta,file_name,dck2,datasets)
}

if("Final_Individual_DHS_only.dta" %in% dta_list) {
  plan(multisession, workers = 4)
  dta = "Final_Individual_DHS_only.dta"
  file_name = paste0(data_loc3,dta)
  dck2 = read_dta(file_name)
  dck2 = dck2 %>% mutate(across(c(country_name,country_abrev,country_dataset_year,admin1,admin2),~as.character(as_factor(.x))))
  dck2 = dck2 %>% mutate(country_dataset_year = sub("_","_DHS_",gsub("Cambodia2","Cambodia",country_dataset_year)))
  datasets = unique(dck2$country_dataset_year)
  foreach(i = datasets, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
    # dck %>% filter(country_dataset_year==i) %>% write_dta(path = paste0(data_loc3,i,dta_append))
    dck = dck2 %>% filter(country_dataset_year==i)
    save(dck, file = paste0(data_loc,i,r_append))
  }
  file.remove(file_name)
  rm(dta,file_name,dck2,datasets)
}

rm(data_loc,data_loc2,data_loc3,dta_list,r_append)
gc()
