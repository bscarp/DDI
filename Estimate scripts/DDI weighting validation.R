library(future)
library(doFuture)
options(future.globals.maxSize = 1e10)
library(foreach)
library(tidyverse)
library(haven)
library(readxl)
library(rms)
library(tableone)
library(srvyr)
plan(multisession, workers = 4)

library(progressr)
handlers(global = TRUE)
handlers("progress")

r_list = dir(paste0(cen_dir,"Downloads/Census/R Datasets/"))

drive_auth("bradley.carpenter@mrc.ac.za")
file.remove(paste0(cen_dir,"Downloads/Census/Sampling design table.xlsx"))
drive_download(file = "https://docs.google.com/spreadsheets/d/16gJhGR7dlIiWxCeNlLSqcWcCFZFLaEz2/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
               path = paste0(cen_dir,"Downloads/Census/Sampling design table.xlsx"),overwrite = TRUE)
psu = read_xlsx(paste0(cen_dir,"Downloads/Census/Sampling design table.xlsx"),sheet = "Sampling Design")
psu = psu %>% filter(!is.na(`Stata code July 9th 2024`))

valid = foreach(r_name = r_list, .combine = "rbind", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
  data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
  data_loc2 = paste0(cen_dir,"Downloads/Census/Summaries/")
  # data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
  file_name = paste0(data_loc,r_name)
  r_sum_name = paste0(data_loc2,sub("\\.RData","\\_Summary.RData",r_name))
  dataset = sub(pattern = ".RData", replacement = "", x = r_name)

  load(file = file_name)
  if(grepl("DHS",dataset)&!grepl("Mauritania",dataset)) {
    psu2 = psu %>% filter(is.na(Country_Survey_Date))
  } else {
    psu2 = psu %>% filter(Country_Survey_Date==dataset)
  }
  
  # print(paste0(dataset,nrow(psu2),collapse = ", "))
  
  if(grepl("tsu", psu2$`Stata code July 17th 2024`)) {
    dck2 = dck %>% select(any_of(c("tsu", "ssu", "psu", "ind_weight", "sample_strata")))
    c(dataset, "tsu_group", paste0(names(dck2), collapse = ", "))
  } else if(grepl("ssu", psu2$`Stata code July 17th 2024`)) {
    dck2 = dck %>% select(any_of(c("ssu", "psu", "ind_weight", "sample_strata")))
    c(dataset, "ssu_group", paste0(names(dck2), collapse = ", "))
  } else if(grepl("psu", psu2$`Stata code July 17th 2024`)) {
    dck2 = dck %>% select(any_of(c("psu", "ind_weight", "country_abrev")))
    c(dataset, "psu_group", paste0(names(dck2), collapse = ", "))
  } else if(grepl("sample_strata", psu2$`Stata code July 17th 2024`)) {
    dck2 = dck %>% select(any_of(c("hh_id", "ind_weight", "sample_strata")))
    c(dataset, "strata_group", paste0(names(dck2), collapse = ", "))
  } else if(grepl("simple mean", psu2$`Stata code July 17th 2024`)) {
    c(dataset, "mean_group", "mean")
  } else {
    dck2 = dck %>% select(any_of(c("ind_weight")))
    c(dataset, "weight_group", paste0(names(dck2), collapse = ", "))
  }
}