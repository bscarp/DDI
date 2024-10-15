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
plan(multisession, workers = 4)

library(progressr)
handlers(global = TRUE)
handlers("progress")

time = tibble(point = "start", val = Sys.time(),diff = val-val)
cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")

#Download and extract revisions
#source("./DDI Revision.R")

#Split large dataset (IPUMS)
#source("./DDI summary calculations large files.R")

#Save new datasets to R
#source("./DDI summary pre-process.R")

time = time %>% add_row(.,point = "Processing", val = Sys.time(), diff = val-time$val[1])

#Process full population datasets
#source("./DDI summary calculations updated weights full sample.R")

time = time %>% add_row(.,point = "Summaries full", val = Sys.time(), diff = val-time$val[2])

#Process DHS datasets
#source("./DDI summary calculations updated weights DHS.R")

time = time %>% add_row(.,point = "Summaries DHS", val = Sys.time(), diff = val-time$val[3])

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
r_list2 = r_list[!r_list %in% sum_list&!grepl("DHS",r_list)&!sub(".RData","",r_list) %in% psu$Country_Survey_Date[!grepl("svyset",psu$`Stata code July 17th 2024`)]]

library(srvyr)
options(survey.adjust.domain.lonely = TRUE)
options(survey.lonely.psu = "adjust")
plan(sequential)

#Run analysis for unprocessed datasets
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
    dck2a = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a ),any_of(psu_a),all_of(ind_a1)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(ind_weight )&!is.na(sample_strata))
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(hh_weight  )&!is.na(sample_strata))
    dck2a = dck2a %>% as_survey_design(ids = c(psu, ssu), weights = c(ind_weight , NULL), strata = c(sample_strata, NULL), nest = TRUE)
    dck2b = dck2b %>% as_survey_design(ids = c(psu, ssu), weights = c(hh_weight , NULL), strata = c(sample_strata, NULL), nest = TRUE)
    rm(dck)
  } else if(grepl("psu", psu2$`Stata code July 17th 2024`)) {
    psu_a = psu_a[!grepl("ssu|sample_strata",psu_a)]
    dck2a = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a ),any_of(psu_a),all_of(ind_a1)) %>% filter(!is.na(psu)&!is.na(ind_weight)&!is.na(country_abrev))
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(psu)&!is.na(hh_weight)&!is.na(country_abrev))
    dck2a = dck2a %>% as_survey_design(ids = psu, weights = ind_weight, strata = country_abrev, nest = TRUE)
    dck2b = dck2b %>% as_survey_design(ids = psu, weights = hh_weight, strata = country_abrev, nest = TRUE)
    rm(dck)
  } else if(grepl("sample_strata", psu2$`Stata code July 17th 2024`)) {
    psu_a = psu_a[!grepl("ssu|psu",psu_a)]
    dck2a = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a ),any_of(psu_a),all_of(ind_a1)) %>% filter(!is.na(hh_id)&!is.na(ind_weight)&!is.na(sample_strata))
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(hh_id)&!is.na(hh_weight)&!is.na(sample_strata))
    dck2a = dck2a %>% as_survey_design(ids = hh_id, weights = ind_weight, strata = sample_strata, nest = TRUE)
    dck2b = dck2b %>% as_survey_design(ids = hh_id, weights = hh_weight, strata = sample_strata, nest = TRUE)
    rm(dck)
  } else {
    psu_a = psu_a[!grepl("ssu|psu|sample_strata|country_abrev|hh_id",psu_a)]
    dck2a = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a ),any_of(psu_a),all_of(ind_a1)) %>% filter(!is.na(ind_weight))
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),all_of(oth_a2),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(hh_weight))
    dck2a = dck2a %>% as_survey_design(ids = NULL, weights = ind_weight)
    dck2b = dck2b %>% as_survey_design(ids = NULL, weights = hh_weight)
    rm(dck)
  }
  
  #Means national and regional
  tab_m_nr1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
    options(future.globals.maxSize = 1e10)
    options(survey.adjust.domain.lonely = TRUE)
    options(survey.lonely.psu = "adjust")
    dis = as.symbol(dis_grp)
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck2a %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = TRUE)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1),
                    dck2a %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = TRUE)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1)) %>%
      arrange({{agg}}, {{dis}}, admin1) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }
  if(sum(!is.na(dck2b$health_exp_hh))>0) {
    tab_m_nr2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
    options(future.globals.maxSize = 1e10)
    options(survey.adjust.domain.lonely = TRUE)
    options(survey.lonely.psu = "adjust")
    dis = as.symbol(dis_grp)
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck2b %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1),
                    dck2b %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% group_by({{agg}}, {{dis}}, admin1) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin1)) %>%
      arrange({{agg}}, {{dis}}, admin1) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
    }
  } else {
    tab_m_nr2 = tab_m_nr1 %>% select(Agg,admin1,contains("everattended_new"))
    names(tab_m_nr2) = sub("anyviolence_byh_12m_","health_exp_hh_",names(tab_m_nr2))
  }

  tab_m_nr = full_join(tab_m_nr1,tab_m_nr2)
  rm(tab_m_nr1,tab_m_nr2)
  
  #Summary for P1
  tab_P1_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck2a %>% group_by({{agg}},admin1) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T)*100))),.groups = "drop"),
                    dck2a %>% group_by({{agg}},admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T)*100))),.groups = "drop")) %>%
      arrange({{agg}}, admin1) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }

  #Summary for P2
  tab_P2_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
    agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
    tab = bind_rows(dck2a %>% group_by({{agg}},admin1) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
                    dck2a %>% group_by({{agg}},admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop")) %>%
      arrange({{agg}}, admin1) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin1") %>% select(-1)
  }
  
  #Summary for P3
  tab_P3_nr = bind_rows(bind_rows(dck2b %>% group_by(admin1) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
                                  dck2b %>% group_by(admin1) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop")) %>%
                          mutate(Agg = "All = All",.before = "admin1"),
                        bind_rows(dck2b %>% group_by(admin1,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
                                  dck2b %>% group_by(admin1,urban_new) %>% mutate(admin1 = factor(admin1_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop")) %>%
                          arrange(urban_new, admin1) %>% mutate(Agg = paste0("urban_new = ",urban_new),.before = "admin1") %>% select(-3))
  
  #Indicators by domain
  dom_a = c("disability_any","seeing_any","hearing_any","mobile_any","cognition_any","selfcare_any","communicating_any")
  
  tab_P4_nr1 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %dofuture% {
    options(future.globals.maxSize = 1e10)
    options(survey.adjust.domain.lonely = TRUE)
    options(survey.lonely.psu = "adjust")
    dom = as.symbol(dom_grp)
    tab = bind_rows(dck2a %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete(admin1),
                    dck2a %>% mutate(disability_any = as.numeric(disability_any)-1,admin1 = factor(admin1_n+1,labels = "National")) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete(admin1)) %>%
      arrange(admin1) %>% mutate(domain = dom_grp,.before = "admin1")
  }  
  if(sum(!is.na(dck2b$health_exp_hh))>0) {
    tab_P4_nr2 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %dofuture% {
    options(future.globals.maxSize = 1e10)
    options(survey.adjust.domain.lonely = TRUE)
    options(survey.lonely.psu = "adjust")
    dom = as.symbol(dom_grp)
    tab = bind_rows(dck2b %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete(admin1),
                    dck2b %>% mutate(disability_any = as.numeric(disability_any)-1,admin1 = factor(admin1_n+1,labels = "National")) %>% group_by(admin1) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete(admin1)) %>%
      arrange(admin1) %>% mutate(domain = dom_grp,.before = "admin1")
    }
  } else {
    tab_P4_nr2 = tab_P4_nr1 %>% select(domain,admin1,contains("everattended_new"))
    names(tab_P4_nr2) = sub("anyviolence_byh_12m_","health_exp_hh_",names(tab_P4_nr2))
  }
  
  tab_P4_nr = full_join(tab_P4_nr1,tab_P4_nr2)
  rm(tab_P4_nr1,tab_P4_nr2)

  #Prevalences for age-sex adjustment
  tab_as_adj = dck2a %>% mutate(female = factor(female,labels = c("Male","Female")),age_sex = paste(age_group5,female)) %>% group_by(age_sex) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T)*100))),.groups = "drop")
  
  # if("admin2" %in% names(dck2) & n_distinct(dck2$admin2) > 1) {
  #   
  #   dck2 = dck2 %>% mutate(admin2 = as_factor(admin2), admin2 = factor(as.character(admin2)))
  #   
  #   admin2_n = n_distinct(dck2$admin2)
  #   
  #   #Means national and sub-regional
  #   tab_m_sn = foreach(agg_grp=c("All","female","urban_new","age_group")) %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  #     options(future.globals.maxSize = 1e10)
  #     options(survey.adjust.domain.lonely = TRUE)
  #     options(survey.lonely.psu = "adjust")
  #     dis = as.symbol(dis_grp)
  #     agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
  #     tab = bind_rows(dck2 %>% group_by({{agg}}, {{dis}}, admin2) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin2),
  #                     dck2 %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% group_by({{agg}}, {{dis}}, admin2) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, admin2)) %>% 
  #       arrange({{agg}}, {{dis}}, admin2) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}),.before = "admin2") %>% select(-1)
  #   }
  #   
  #   #Summary for P1
  #   tab_P1_sn = foreach(agg_grp=c("All","female","urban_new","age_group")) %do% {
  #     agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
  #     tab = bind_rows(dck2 %>% group_by({{agg}},admin2) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T)*100))),.groups = "drop"),
  #                     dck2 %>% group_by({{agg}},admin2) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T)*100))),.groups = "drop"))
  #   }
  #   
  #   #Summary for P2
  #   tab_P2_sn = foreach(agg_grp=c("All","female","urban_new","age_group")) %do% {
  #     agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
  #     tab = bind_rows(dck2 %>% group_by({{agg}},admin2) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
  #                     dck2 %>% group_by({{agg}},admin2) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"))
  #   }
  #   
  #   #Summary for P3
  #   tab_P3_sn = list(bind_rows(dck2 %>% group_by(admin2) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
  #                              dck2 %>% group_by(admin2) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop")),
  #                    bind_rows(dck2 %>% group_by(admin2,urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop"),
  #                              dck2 %>% group_by(admin2,urban_new) %>% mutate(admin2 = factor(admin2_n+1,labels = "National")) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop")))
  #   
  #   #Indicators by domain
  #   tab_P4_sn = cbind(tibble(domain = rep(dom_a,each=admin2_n+1)),foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %dofuture% {
  #     options(future.globals.maxSize = 1e10)
  #     options(survey.adjust.domain.lonely = TRUE)
  #     options(survey.lonely.psu = "adjust")
  #     dom = as.symbol(dom_grp)
  #     dom2 = as.character(dom_grp)
  #     tab = bind_rows(dck2 %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by(admin2) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete(admin2),
  #                     dck2 %>% mutate(disability_any = as.numeric(disability_any)-1,admin2 = factor(admin2_n+1,labels = "National")) %>% group_by(admin2) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T)*100))),.groups = "drop") %>% complete(admin2))
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

time = time %>% add_row(.,point = "Summaries", val = Sys.time(), diff = val-time$val[4])

#Process estimates for database
# source("./DDI estimate database.R")

time = time %>% add_row(.,point = "Estimates", val = Sys.time(), diff = val-time$val[5])