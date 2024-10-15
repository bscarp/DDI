#Full population datasets
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
plan(sequential)

library(progressr)
handlers(global = TRUE)
handlers("progress")

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
full_list = r_list[!r_list %in% sum_list&sub(".RData","",r_list) %in% psu$Country_Survey_Date[grepl("simple mean",psu$`Stata code July 17th 2024`)]]
wei_list = r_list[!r_list %in% sum_list&sub(".RData","",r_list) %in% psu$Country_Survey_Date[!grepl("simple mean",psu$`Stata code July 17th 2024`)&!grepl("svyset",psu$`Stata code July 17th 2024`)]]

#Run analysis for unprocessed full datasets
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
  psu_a = c("ind_id","hh_id","ind_weight","ind2_weight","hh_weight","dv_weight","psu","ssu","tsu","sample_strata","country_abrev")
  
  dck = dck %>% select(all_of(cou_a),all_of(ind_a),all_of(dis_a),all_of(grp_a),all_of(oth_a),all_of(oth_a2))
  
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
  
  #Means national and regional
  tab_m_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
    options(future.globals.maxSize = 1e10)
    dis = as.symbol(dis_grp)
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1),
                    dck %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1)) %>%
      arrange({{agg}}, {{dis}}, admin1) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }
  
  #Summary for P1
  tab_P1_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
    options(future.globals.maxSize = 1e10)
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck %>% group_by({{agg}},admin1) %>% summarise(across(all_of(dis_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(as.numeric(.x)-1,na.rm = T)*100),mean_se = ~NA)),.groups = "drop"),
                    dck %>% group_by({{agg}},admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(all_of(dis_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(as.numeric(.x)-1,na.rm = T)*100),mean_se = ~NA)),.groups = "drop")) %>%
      arrange({{agg}}, admin1) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }
  
  #Summary for P2
  tab_P2_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
    options(future.globals.maxSize = 1e10)
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck %>% group_by({{agg}},admin1) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop"),
                    dck %>% group_by({{agg}},admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop")) %>%
      arrange({{agg}}, admin1) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }
  
  dck2 = dck %>% filter(~duplicated(hh_id))
  
  #Summary for P3
  tab_P3_nr = bind_rows(bind_rows(dck2 %>% group_by(admin1) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop"),
                                  dck2 %>% group_by(admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop")) %>%
                          mutate(Agg = "All = All",.before = "admin1"),
                        bind_rows(dck2 %>% group_by(admin1,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop"),
                                  dck2 %>% group_by(admin1,urban_new) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop")) %>%
                          arrange(urban_new, admin1) %>% mutate(Agg = paste0("urban_new = ",urban_new),.before = "admin1") %>% select(-3))
  
  #Indicators by domain
  dom_a = c("disability_any","seeing_any","hearing_any","mobile_any","cognition_any","selfcare_any","communicating_any")
  
  tab_P4_nr = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %do% {
    options(future.globals.maxSize = 1e10)
    dom = as.symbol(dom_grp)
    tab = bind_rows(dck %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop") %>% complete(admin1),
                    dck %>% mutate(disability_any = as.numeric(disability_any)-1,admin1 = factor(admin1_n+1,labels = "National")) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100),mean_se = ~NA)),.groups = "drop") %>% complete(admin1)) %>%
      arrange(admin1) %>% mutate(domain = dom_grp,.before = "admin1")
  }
  
  #Prevalences for age-sex adjustment
  tab_as_adj = dck %>% mutate(female = factor(female,labels = c("Male","Female")),age_sex = paste(age_group5,female)) %>% group_by(age_sex) %>% summarise(across(all_of(dis_a2),~ifelse(sum(!is.na(.x))<50,NA,mean(as.numeric(.x)-1,na.rm = T)*100)),.groups = "drop")
  
  # if("admin2" %in% names(dck) & n_distinct(dck$admin2) > 1) {
  #   
  #   dck = dck %>% mutate(admin2 = as_factor(admin2), admin2 = factor(as.character(admin2)))
  #   
  #   admin2_n = n_distinct(dck$admin2)
  #   
  #   #Means national and sub-regional
  #   tab_m_sn = foreach(agg_grp=c("All","female","urban_new","age_group")) %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  #     options(future.globals.maxSize = 1e10)
  #     dis = as.symbol(dis_grp)
  #     agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
  #     tab = bind_rows(dck %>% group_by({{agg}}, {{dis}}, admin2) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin2),
  #                     dck %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% group_by({{agg}}, {{dis}}, admin2) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin2)) %>% 
  #       arrange({{agg}}, {{dis}}, admin2) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin2") %>% select(-1)
  #   }
  #   
  #   #Summary for P1
  #   tab_P1_sn = foreach(agg_grp=c("All","female","urban_new","age_group")) %do% {
  #     agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
  #     tab = bind_rows(dck %>% group_by({{agg}},admin2) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(as.numeric(.x)-1,na.rm = T)*100))),.groups = "drop"),
  #                     dck %>% group_by({{agg}},admin2) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(as.numeric(.x)-1,na.rm = T)*100))),.groups = "drop"))
  #   }
  #   
  #   #Summary for P2
  #   tab_P2_sn = foreach(agg_grp=c("All","female","urban_new","age_group")) %do% {
  #     agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
  #     tab = bind_rows(dck %>% group_by({{agg}},admin2) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop"),
  #                     dck %>% group_by({{agg}},admin2) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop"))
  #   }
  #   
  #   #Summary for P3
  #   tab_P3_sn = list(bind_rows(dck %>% group_by(admin2) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop"),
  #                              dck %>% group_by(admin2) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop")),
  #                    bind_rows(dck %>% group_by(admin2,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop"),
  #                              dck %>% group_by(admin2,urban_new) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop")))
  #   
  #   #Indicators by domain
  #   tab_P4_sn = cbind(tibble(domain = rep(dom_a,each=admin2_n+1)),foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %dofuture% {
  #     options(future.globals.maxSize = 1e10)
  #     dom = as.symbol(dom_grp)
  #     dom2 = as.character(dom_grp)
  #     tab = bind_rows(dck %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by(admin2) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete(admin2),
  #                     dck %>% mutate(disability_any = as.numeric(disability_any)-1,admin2 = factor(admin2_n+1,labels = "National")) %>% group_by(admin2) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete(admin2))
  #   })
  #   
  #   #write to R
  #   save(tab_m_nr,tab_m_sn,tab_P1_nr,tab_P1_sn,tab_P2_nr,tab_P2_sn,tab_P3_nr,tab_P3_sn,tab_P4_nr,tab_P4_sn,tab_as_adj,file = r_sum_name)
  # } else {
  
  #write to R
  save(tab_m_nr,tab_P1_nr,tab_P2_nr,tab_P3_nr,tab_P4_nr,tab_as_adj,file = r_sum_name)
  # }
  
  rm(list = ls())
  gc()
}

#Run analysis for unprocessed weighted datasets
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
  psu_a = c("ind_weight","hh_weight","hh_id")
  
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
  
  #Means national and regional
  tab_m_nr1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
    options(future.globals.maxSize = 1e11)
    dis = as.symbol(dis_grp)
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a1), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1),
                    dck %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a1), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1)) %>%
      arrange({{agg}}, {{dis}}, admin1) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }
  tab_m_nr2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
    options(future.globals.maxSize = 1e10)
    dis = as.symbol(dis_grp)
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,hh_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1),
                    dck %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,hh_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1)) %>%
      arrange({{agg}}, {{dis}}, admin1) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }
  
  tab_m_nr = full_join(tab_m_nr1,tab_m_nr2)
  rm(tab_m_nr1,tab_m_nr2)
  
  #Summary for P1
  tab_P1_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
    options(future.globals.maxSize = 1e10)
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck %>% group_by({{agg}},admin1) %>% summarise(across(all_of(dis_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(as.numeric(.x)-1,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(as.numeric(.x)-1,na.rm = T)/n())*100))),.groups = "drop"),
                    dck %>% group_by({{agg}},admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(all_of(dis_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(as.numeric(.x)-1,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(as.numeric(.x)-1,na.rm = T)/n())*100))),.groups = "drop")) %>%
      arrange({{agg}}, admin1) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }
  
  #Summary for P2
  tab_P2_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
    options(future.globals.maxSize = 1e10)
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck %>% group_by({{agg}},admin1) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop"),
                    dck %>% group_by({{agg}},admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop")) %>%
      arrange({{agg}}, admin1) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }
  
  #Summary for P3
  tab_P3_nr = bind_rows(bind_rows(dck %>% group_by(admin1) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop"),
                                  dck %>% group_by(admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop")) %>%
                          mutate(Agg = "All = All",.before = "admin1"),
                        bind_rows(dck %>% group_by(admin1,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop"),
                                  dck %>% group_by(admin1,urban_new) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop")) %>%
                          arrange(urban_new, admin1) %>% mutate(Agg = paste0("urban_new = ",urban_new),.before = "admin1") %>% select(-3))
  
  #Indicators by domain
  dom_a = c("disability_any","seeing_any","hearing_any","mobile_any","cognition_any","selfcare_any","communicating_any")
  
  tab_P4_nr1 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %do% {
    options(future.globals.maxSize = 1e10)
    dom = as.symbol(dom_grp)
    tab = bind_rows(dck %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a1), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete(admin1),
                    dck %>% mutate(disability_any = as.numeric(disability_any)-1,admin1 = factor(admin1_n+1,labels = "National")) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a1), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete(admin1)) %>%
      arrange(admin1) %>% mutate(domain = dom_grp,.before = "admin1")
  }
  tab_P4_nr2 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %do% {
    options(future.globals.maxSize = 1e10)
    dom = as.symbol(dom_grp)
    tab = bind_rows(dck %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,hh_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete(admin1),
                    dck %>% mutate(disability_any = as.numeric(disability_any)-1,admin1 = factor(admin1_n+1,labels = "National")) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(.x,hh_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,NA,sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete(admin1)) %>%
      arrange(admin1) %>% mutate(domain = dom_grp,.before = "admin1")
  }
  
  tab_P4_nr = full_join(tab_P4_nr1,tab_P4_nr2)
  rm(tab_P4_nr1,tab_P4_nr2)
  
  #Prevalences for age-sex adjustment
  tab_as_adj = dck %>% mutate(female = factor(female,labels = c("Male","Female")),age_sex = paste(age_group5,female)) %>% group_by(age_sex) %>% summarise(across(all_of(dis_a2),~ifelse(sum(!is.na(.x))<50,NA,wtd.mean(as.numeric(.x)-1,na.rm = T)*100)),.groups = "drop")
  
  # if("admin2" %in% names(dck) & n_distinct(dck$admin2) > 1) {
  #   
  #   dck = dck %>% mutate(admin2 = as_factor(admin2), admin2 = factor(as.character(admin2)))
  #   
  #   admin2_n = n_distinct(dck$admin2)
  #   
  #   #Means national and sub-regional
  #   tab_m_sn = foreach(agg_grp=c("All","female","urban_new","age_group")) %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  #     options(future.globals.maxSize = 1e10)
  #     dis = as.symbol(dis_grp)
  #     agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
  #     tab = bind_rows(dck %>% group_by({{agg}}, {{dis}}, admin2) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin2),
  #                     dck %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% group_by({{agg}}, {{dis}}, admin2) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin2)) %>% 
  #       arrange({{agg}}, {{dis}}, admin2) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin2") %>% select(-1)
  #   }
  #   
  #   #Summary for P1
  #   tab_P1_sn = foreach(agg_grp=c("All","female","urban_new","age_group")) %do% {
  #     agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
  #     tab = bind_rows(dck %>% group_by({{agg}},admin2) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(as.numeric(.x)-1,na.rm = T)*100))),.groups = "drop"),
  #                     dck %>% group_by({{agg}},admin2) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(as.numeric(.x)-1,na.rm = T)*100))),.groups = "drop"))
  #   }
  #   
  #   #Summary for P2
  #   tab_P2_sn = foreach(agg_grp=c("All","female","urban_new","age_group")) %do% {
  #     agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
  #     tab = bind_rows(dck %>% group_by({{agg}},admin2) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop"),
  #                     dck %>% group_by({{agg}},admin2) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop"))
  #   }
  #   
  #   #Summary for P3
  #   tab_P3_sn = list(bind_rows(dck %>% group_by(admin2) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop"),
  #                              dck %>% group_by(admin2) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop")),
  #                    bind_rows(dck %>% group_by(admin2,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop"),
  #                              dck %>% group_by(admin2,urban_new) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop")))
  #   
  #   #Indicators by domain
  #   tab_P4_sn = cbind(tibble(domain = rep(dom_a,each=admin2_n+1)),foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %dofuture% {
  #     options(future.globals.maxSize = 1e10)
  #     dom = as.symbol(dom_grp)
  #     dom2 = as.character(dom_grp)
  #     tab = bind_rows(dck %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by(admin2) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop") %>% complete(admin2),
  #                     dck %>% mutate(disability_any = as.numeric(disability_any)-1,admin2 = factor(admin2_n+1,labels = "National")) %>% group_by(admin2) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,wtd.mean(.x,ind_weight,na.rm = T)*100))),.groups = "drop") %>% complete(admin2))
  #   })
  #   
  #   #write to R
  #   save(tab_m_nr,tab_m_sn,tab_P1_nr,tab_P1_sn,tab_P2_nr,tab_P2_sn,tab_P3_nr,tab_P3_sn,tab_P4_nr,tab_P4_sn,tab_as_adj,file = r_sum_name)
  # } else {
  
  #write to R
  save(tab_m_nr,tab_P1_nr,tab_P2_nr,tab_P3_nr,tab_P4_nr,tab_as_adj,file = r_sum_name)
  # }
  
  rm(list = ls())
  gc()
}

file.remove("~/progress.csv")
