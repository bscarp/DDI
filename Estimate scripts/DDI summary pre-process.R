library(future)
library(doFuture)
options(future.globals.maxSize = 4e9)
library(foreach)
library(tidyverse)
library(haven)
library(readxl)
library(googledrive)
library(rms)
library(tableone)
plan(multisession, workers = 4)

library(progressr)
handlers(global = TRUE)
handlers("progress")

drive_auth("bradley.carpenter@mrc.ac.za")
file.remove(paste0(cen_dir,"Downloads/Census/Dataset list.xlsx"))
drive_download(file = "https://docs.google.com/spreadsheets/d/1rCcLMLu4eaakTW76it5vojo6o2Z6Nxzy/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
               path = paste0(cen_dir,"Downloads/Census/Dataset list.xlsx"),overwrite = TRUE)
data_list = read_xlsx(paste0(cen_dir,"Downloads/Census/Dataset list.xlsx"),"Sheet1",.name_repair = function(x) {gsub(" ","_",gsub("-","",x))}) |> filter(!is.na(Country))
data_list = data_list |> select(File_Name,Subnational_1_feasible,Subnational_2_feasible)

#Check for unprocessed datasets
dta_list = dir(paste0(cen_dir,"Downloads/Census/Stata Datasets/"))
dta_list = dta_list[!dta_list %in% c("Archive.7z")]
r_list = dir(paste0(cen_dir,"Downloads/Census/R Datasets/"))
r_list = sub("\\.RData","\\.dta",r_list)
dta_list2 = dta_list[!dta_list %in% r_list]

#Run analysis for unprocessed datasets
foreach(dta = dta_list2) %do% {
  
  data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
  data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
  file_name = paste0(data_loc3,dta)
  r_name = paste0(data_loc,sub("\\.dta","\\.RData",dta))
  svy = sub(".dta","",dta)
  
  dck = read_dta(file_name)
  dck = dck %>% mutate(across(c(female,urban_new,age_group),~as.double(.x)))
  if(is.na(data_list$Subnational_1_feasible[data_list$File_Name == svy]) & "admin1" %in% names(dck)) {
    dck = dck %>% select(-admin1)
  }
  if(is.na(data_list$Subnational_2_feasible[data_list$File_Name == svy]) & "admin2" %in% names(dck)) {
    dck = dck %>% select(-admin2)
  }
  save(dck,file = r_name)
  
  file.remove(file_name)
}

rm(dta_list,dta_list2,r_list,data_loc,data_loc3,file_name,r_name,dta,dck,data_list)
gc()
