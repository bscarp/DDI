library(future)
library(doFuture)
options(future.globals.maxSize = 1e10)
library(foreach)
library(tidyverse)
library(haven)
library(readxl)
library(googledrive)
library(rms)
library(tableone)
library(survey)
plan(multisession, workers = 4)

library(progressr)
handlers(global = TRUE)
handlers("progress")

time = tibble(point = "start", val = Sys.time(),diff = val-val)
cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")

drive_auth("bradley.carpenter@mrc.ac.za")
file.remove(paste0(cen_dir,"Downloads/Census/Sampling design table.xlsx"))
drive_download(file = "https://docs.google.com/spreadsheets/d/16gJhGR7dlIiWxCeNlLSqcWcCFZFLaEz2/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
               path = paste0(cen_dir,"Downloads/Census/Sampling design table.xlsx"),overwrite = TRUE)
psu = read_xlsx(paste0(cen_dir,"Downloads/Census/Sampling design table.xlsx"),sheet = "Sampling Design")
psu = psu %>% filter(!is.na(`Stata code July 9th 2024`))

#Check for unprocessed datasets
r_list = dir(paste0(cen_dir,"Downloads/Census/R Datasets/"))
sum_list = dir(paste0(cen_dir,"Downloads/Census/Summaries/"))
sum_list = sub("\\_Summary.RData","\\.RData",sum_list)
full_list = r_list[r_list %in% sum_list&sub(".RData","",r_list) %in% psu$Country_Survey_Date[grepl("simple mean",psu$`Stata code July 17th 2024`)]]
wei_list = r_list[r_list %in% sum_list&sub(".RData","",r_list) %in% psu$Country_Survey_Date[!grepl("simple mean",psu$`Stata code July 17th 2024`)&!grepl("svyset",psu$`Stata code July 17th 2024`)]]
dhs_list = r_list[r_list %in% sum_list&grepl("DHS",r_list)]
r_list2 = r_list[r_list %in% sum_list&!grepl("DHS",r_list)&!sub(".RData","",r_list) %in% psu$Country_Survey_Date[!grepl("svyset",psu$`Stata code July 17th 2024`)]]

plan(sequential)

foreach(r_name = full_list, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  
  cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
  data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
  data_loc2 = paste0(cen_dir,"Downloads/Census/Summaries/")
  # data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
  file_name = paste0(data_loc,r_name)
  r_sum_name = paste0(data_loc2,sub("\\.RData","\\_Summary.RData",r_name))
  dataset = sub(pattern = ".RData", replacement = "", x = r_name)
  
  file.remove("~/progress.csv")
  write.csv(x = dataset, file = "~/progress.csv")
  
  load(file = file_name)
  load(file = r_sum_name)
  
  dck = dck %>% mutate(disability_any = factor(disability_any,labels = c("no_a","any")),
                       disability_sev = factor(disability_some + 2*disability_atleast,labels = c("no","some","atleast")),
                       disability_some = factor(disability_some,labels = c("no_s","some_n")),
                       disability_atleast = factor(disability_atleast,labels = c("no_l","atleast_n")),
                       admin1 = as_factor(admin1), admin1 = factor(as.character(admin1)),
                       age_group5 = cut(age,c(14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,89,Inf),c("15 to 19","20 to 24","25 to 29","30 to 34","35 to 39","40 to 44","45 to 49","50 to 54","55 to 59","60 to 64","65 to 69","70 to 74","75 to 79","80 to 84","85 to 89","90+")))
  dck = dck %>% mutate(across(c(country_name,country_abrev,country_dataset_year,admin1,admin2),~as.character(as_factor(.x))))
  dck = dck %>% filter(complete.cases(disability_any))
  
  grp_a = c("female","urban_new","age_group")
  ind_a = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","health_exp_hh","ind_mdp")
  dis_a = c("disability_any","disability_some","disability_atleast","disability_sev")
  dis_a2 = c("disability_any","disability_some","disability_atleast")
  oth_a = dck %>% select(!mobile_own) %>% select(disability_any_hh,disability_some_hh,disability_atleast_hh,seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any) %>% names()
  oth_a2 = c("age_group5")
  cou_a = c("admin1","admin2")
  psu_a = c("hh_id","ind_weight","hh_weight")
  
  dck = dck %>% select(all_of(cou_a),all_of(ind_a),all_of(dis_a),all_of(grp_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a))
  
  size = object.size(dck)
  if(size < 3400000000) {
    plan(multisession, workers = 6)
  } else if(size < 4000000000){
    plan(multisession, workers = 5)
  } else if(size < 4800000000){
    plan(multisession, workers = 4)
  } else if(size < 6000000000){
    plan(multisession, workers = 3)
  } else if(size < 8000000000){
    plan(multisession, workers = 2)
  } else {
    plan(sequential)
    options(future.globals.maxSize = 1e10)
  }
  plan()
  
  admin1_n = n_distinct(dck$admin1)
  
  dck = dck %>% filter(!duplicated(hh_id))
  
  #Summary for P3
  tab_P3_nr = bind_rows(bind_rows(dck %>% group_by(admin1) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop"),
                                  dck %>% group_by(admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop")) %>%
                          mutate(Agg = "All = All",.before = "admin1"),
                        bind_rows(dck %>% group_by(admin1,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop"),
                                  dck %>% group_by(admin1,urban_new) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop")) %>%
                          arrange(urban_new, admin1) %>% mutate(Agg = paste0("urban_new = ",urban_new),.before = "admin1") %>% select(-3))
  
  #write to R
  save(tab_m_nr,tab_P1_nr,tab_P2_nr,tab_P3_nr,tab_P4_nr,tab_as_adj,file = r_sum_name)
  plan(sequential)
  }

foreach(r_name = wei_list, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  
  cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
  data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
  data_loc2 = paste0(cen_dir,"Downloads/Census/Summaries/")
  # data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
  file_name = paste0(data_loc,r_name)
  r_sum_name = paste0(data_loc2,sub("\\.RData","\\_Summary.RData",r_name))
  dataset = sub(pattern = ".RData", replacement = "", x = r_name)
  
  file.remove("~/progress.csv")
  write.csv(x = dataset, file = "~/progress.csv")
  
  load(file = file_name)
  load(file = r_sum_name)
  
  dck = dck %>% mutate(disability_any = factor(disability_any,labels = c("no_a","any")),
                       disability_sev = factor(disability_some + 2*disability_atleast,labels = c("no","some","atleast")),
                       disability_some = factor(disability_some,labels = c("no_s","some_n")),
                       disability_atleast = factor(disability_atleast,labels = c("no_l","atleast_n")),
                       admin1 = as_factor(admin1), admin1 = factor(as.character(admin1)),
                       age_group5 = cut(age,c(14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,89,Inf),c("15 to 19","20 to 24","25 to 29","30 to 34","35 to 39","40 to 44","45 to 49","50 to 54","55 to 59","60 to 64","65 to 69","70 to 74","75 to 79","80 to 84","85 to 89","90+")))
  dck = dck %>% mutate(across(c(country_name,country_abrev,country_dataset_year,admin1,admin2),~as.character(as_factor(.x))))
  dck = dck %>% filter(complete.cases(disability_any))
  
  grp_a = c("female","urban_new","age_group")
  ind_a = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","health_exp_hh","ind_mdp")
  ind_a1 = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","ind_mdp")
  ind_a2 = c("health_exp_hh")
  dis_a = c("disability_any","disability_some","disability_atleast","disability_sev")
  dis_a2 = c("disability_any","disability_some","disability_atleast")
  oth_a = dck %>% select(!mobile_own) %>% select(disability_any_hh,disability_some_hh,disability_atleast_hh,seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any) %>% names()
  oth_a2 = c("age_group5")
  cou_a = c("admin1","admin2")
  psu_a = c("hh_id","ind_weight","hh_weight")
  
  dck = dck %>% select(all_of(cou_a),all_of(ind_a),all_of(dis_a),all_of(grp_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a))
  
  size = object.size(dck)
  if(size < 3400000000) {
    plan(multisession, workers = 6)
  } else if(size < 4000000000){
    plan(multisession, workers = 5)
  } else if(size < 4800000000){
    plan(multisession, workers = 4)
  } else if(size < 6000000000){
    plan(multisession, workers = 3)
  } else if(size < 8000000000){
    plan(multisession, workers = 2)
  } else {
    plan(sequential)
    options(future.globals.maxSize = 1e10)
  }
  plan()
  
  admin1_n = n_distinct(dck$admin1)
  
  dck = dck %>% filter(!duplicated(hh_id))
  
  tab_P3_nr = bind_rows(bind_rows(dck %>% group_by(admin1) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop"),
                                  dck %>% group_by(admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop")) %>%
                          mutate(Agg = "All = All",.before = "admin1"),
                        bind_rows(dck %>% group_by(admin1,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop"),
                                  dck %>% group_by(admin1,urban_new) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop")) %>%
                          arrange(urban_new, admin1) %>% mutate(Agg = paste0("urban_new = ",urban_new),.before = "admin1") %>% select(-3))
  
  #write to R
  save(tab_m_nr,tab_P1_nr,tab_P2_nr,tab_P3_nr,tab_P4_nr,tab_as_adj,file = r_sum_name)
  plan(sequential)
  }

library(srvyr)
options(survey.adjust.domain.lonely = TRUE)
options(survey.lonely.psu = "adjust")
plan(sequential)

foreach(r_name = dhs_list, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  
  cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
  data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
  data_loc2 = paste0(cen_dir,"Downloads/Census/Summaries/")
  # data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
  file_name = paste0(data_loc,r_name)
  r_sum_name = paste0(data_loc2,sub("\\.RData","\\_Summary.RData",r_name))
  dataset = sub(pattern = ".RData", replacement = "", x = r_name)
  
  load(file = file_name)
  load(file = r_sum_name)
  
  dck = dck %>% mutate(disability_any = factor(disability_any,labels = c("no_a","any")),
                       disability_sev = factor(disability_some + 2*disability_atleast,labels = c("no","some","atleast")),
                       disability_some = factor(disability_some,labels = c("no_s","some_n")),
                       disability_atleast = factor(disability_atleast,labels = c("no_l","atleast_n")),
                       admin1 = as_factor(admin1), admin1 = factor(as.character(admin1)),
                       age_group5 = cut(age,c(14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,89,Inf),c("15 to 19","20 to 24","25 to 29","30 to 34","35 to 39","40 to 44","45 to 49","50 to 54","55 to 59","60 to 64","65 to 69","70 to 74","75 to 79","80 to 84","85 to 89","90+")))
  dck = dck %>% mutate(across(c(country_name,country_abrev,country_dataset_year,admin1,admin2),~as.character(as_factor(.x))))
  
  grp_a = c("female","urban_new","age_group")
  ind_a = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","health_exp_hh","ind_mdp")
  ind_a1 = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","social_prot","food_insecure","shock_any","ind_mdp")
  ind_a2 = c("lit_new","computer","internet","mobile_own","ind_emp","fp_demsat_mod","health_insurance")
  ind_a3 = c("health_exp_hh")
  ind_a4 = c("anyviolence_byh_12m")
  dis_a = c("disability_any","disability_some","disability_atleast","disability_sev")
  dis_a2 = c("disability_any","disability_some","disability_atleast")
  oth_a = dck %>% select(!mobile_own) %>% select(func_difficulty_hh,disability_any_hh,disability_some_hh,disability_atleast_hh,contains("seeing"),contains("hearing"),contains("mobile"),contains("cognition"),contains("selfcare"),contains("communicating")) %>% names()
  oth_a2 = c("age_group5")
  cou_a = c("admin1","admin2")
  psu_a = c("ind_id","hh_id","ind_weight","ind2_weight","hh_weight","dv_weight","psu","ssu","tsu","sample_strata","country_abrev")
  
  dck = dck %>% select(all_of(cou_a),all_of(ind_a),all_of(dis_a),all_of(grp_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a))
  
  size = object.size(dck)
  if(size < 3400000000) {
    plan(multisession, workers = 6)
  } else if(size < 4000000000){
    plan(multisession, workers = 5)
  } else if(size < 4800000000){
    plan(multisession, workers = 4)
  } else if(size < 6000000000){
    plan(multisession, workers = 3)
  } else if(size < 8000000000){
    plan(multisession, workers = 2)
  } else {
    plan(sequential)
    options(future.globals.maxSize = 1e10)
  }
  plan()
  
  admin1_n = n_distinct(dck$admin1)
  
  if(grepl("Mauritania",dataset)) {
    dck2c = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a3)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(tsu)&!is.na(hh_weight  )&!is.na(sample_strata))
    dck2c = dck2c %>% as_survey(ids = c(psu, ssu, tsu), weights = c(hh_weight  , NULL, NULL), strata = c(sample_strata, NULL, NULL), nest = TRUE)
    rm(dck)
  } else {
    dck2c = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a3)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(hh_weight  )&!is.na(sample_strata))
    dck2c = dck2c %>% as_survey(ids = c(psu, ssu), weights = c(hh_weight  , NULL), strata = c(sample_strata, NULL), nest = TRUE)
    rm(dck)
  }
  
  dck2c = dck2c %>% filter(!duplicated(hh_id))
  
  tab_P3_nr = bind_rows(bind_rows(dck2c %>% group_by(admin1) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
                                  dck2c %>% group_by(admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop")) %>%
                          mutate(Agg = "All = All",.before = "admin1"),
                        bind_rows(dck2c %>% group_by(admin1,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
                                  dck2c %>% group_by(admin1,urban_new) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop")) %>%
                          arrange(urban_new, admin1) %>% mutate(Agg = paste0("urban_new = ",urban_new),.before = "admin1") %>% select(-3))
  
  #write to R
  save(tab_m_nr,tab_P1_nr,tab_P2_nr,tab_P3_nr,tab_P4_nr,tab_as_adj,file = r_sum_name)
  plan(sequential)
  }

foreach(r_name = r_list2, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  
  cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
  data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
  data_loc2 = paste0(cen_dir,"Downloads/Census/Summaries/")
  # data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
  file_name = paste0(data_loc,r_name)
  r_sum_name = paste0(data_loc2,sub("\\.RData","\\_Summary.RData",r_name))
  dataset = sub(pattern = ".RData", replacement = "", x = r_name)
  
  if(file.exists("~/progress.csv")) {
    file.remove("~/progress.csv")
  }
  write.csv(x = dataset, file = "~/progress.csv")
  
  load(file = file_name)
  load(file = r_sum_name)
  
  dck = dck %>% mutate(disability_any = factor(disability_any,labels = c("no_a","any")),
                       disability_sev = factor(disability_some + 2*disability_atleast,labels = c("no","some","atleast")),
                       disability_some = factor(disability_some,labels = c("no_s","some_n")),
                       disability_atleast = factor(disability_atleast,labels = c("no_l","atleast_n")),
                       admin1 = as_factor(admin1), admin1 = factor(as.character(admin1)),
                       age_group5 = cut(age,c(14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,89,Inf),c("15 to 19","20 to 24","25 to 29","30 to 34","35 to 39","40 to 44","45 to 49","50 to 54","55 to 59","60 to 64","65 to 69","70 to 74","75 to 79","80 to 84","85 to 89","90+")))
  dck = dck %>% mutate(across(c(country_name,country_abrev,country_dataset_year,admin1,admin2),~as.character(as_factor(.x))))
  dck = dck %>% filter(complete.cases(disability_any))
  
  grp_a = c("female","urban_new","age_group")
  ind_a = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","health_exp_hh","ind_mdp")
  ind_a1 = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","ind_mdp")
  ind_a2 = c("health_exp_hh")
  dis_a = c("disability_any","disability_some","disability_atleast","disability_sev")
  dis_a2 = c("disability_any","disability_some","disability_atleast")
  oth_a = dck %>% select(!mobile_own) %>% select(age_group5,seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any) %>% names()
  oth_a2 = c("disability_any_hh","disability_some_hh","disability_atleast_hh")
  cou_a = c("admin1","admin2")
  psu_a = c("hh_id","ind_weight","hh_weight","psu","ssu","sample_strata","country_abrev")
  
  dck = dck %>% select(all_of(cou_a),all_of(ind_a),all_of(dis_a),all_of(grp_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a))
  dck = dck %>% group_by(hh_id) %>% mutate(hh_id = cur_group_id()) %>% ungroup()
  
  size = object.size(dck)
  if(size < 3400000000) {
    plan(multisession, workers = 6)
  } else if(size < 4000000000){
    plan(multisession, workers = 5)
  } else if(size < 4800000000){
    plan(multisession, workers = 4)
  } else if(size < 6000000000){
    plan(multisession, workers = 3)
  } else if(size < 8000000000){
    plan(multisession, workers = 2)
  } else {
    plan(sequential)
    options(future.globals.maxSize = 1e10)
  }
  plan()
  
  admin1_n = n_distinct(dck$admin1)
  
  psu2 = psu %>% filter(Country_Survey_Date==dataset)
  
  if(grepl("ssu", psu2$`Stata code July 17th 2024`)) {
    if(!"ssu" %in% names(dck)) {
      dck = dck %>% mutate(ssu = hh_id)
    }
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(hh_weight  )&!is.na(sample_strata))
    dck2b = dck2b %>% as_survey_design(ids = c(psu, ssu), weights = c(hh_weight , NULL), strata = c(sample_strata, NULL), nest = TRUE)
    rm(dck)
  } else if(grepl("psu", psu2$`Stata code July 17th 2024`)) {
    psu_a = psu_a[!grepl("ssu|sample_strata",psu_a)]
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(psu)&!is.na(hh_weight)&!is.na(country_abrev))
    dck2b = dck2b %>% as_survey_design(ids = psu, weights = hh_weight, strata = country_abrev, nest = TRUE)
    rm(dck)
  } else if(grepl("sample_strata", psu2$`Stata code July 17th 2024`)) {
    psu_a = psu_a[!grepl("ssu|psu",psu_a)]
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(hh_id)&!is.na(hh_weight)&!is.na(sample_strata))
    dck2b = dck2b %>% as_survey_design(ids = hh_id, weights = hh_weight, strata = sample_strata, nest = TRUE)
    rm(dck)
  } else {
    psu_a = psu_a[!grepl("ssu|psu|sample_strata|country_abrev",psu_a)]
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(hh_weight))
    dck2b = dck2b %>% as_survey_design(ids = NULL, weights = hh_weight)
    rm(dck)
  }
  
  dck2b = dck2b %>% filter(!duplicated(hh_id))
  
  tab_P3_nr = bind_rows(bind_rows(dck2b %>% group_by(admin1) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
                                  dck2b %>% group_by(admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop")) %>%
                          mutate(Agg = "All = All",.before = "admin1"),
                        bind_rows(dck2b %>% group_by(admin1,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
                                  dck2b %>% group_by(admin1,urban_new) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop")) %>%
                          arrange(urban_new, admin1) %>% mutate(Agg = paste0("urban_new = ",urban_new),.before = "admin1") %>% select(-3))
  
  #write to R
  save(tab_m_nr,tab_P1_nr,tab_P2_nr,tab_P3_nr,tab_P4_nr,tab_as_adj,file = r_sum_name)
  plan(sequential)
  }
