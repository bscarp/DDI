#DHS datasets
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
library(srvyr)
plan(list(sequential,sequential,tweak(multisession, workers = 4)))

library(progressr)
handlers(global = TRUE)
handlers("progress")

cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")

#Check for unprocessed datasets
r_list = dir(paste0(cen_dir,"Downloads/Census/R Datasets/"))
sum_list = dir(paste0(cen_dir,"Downloads/Census/Summaries/"))
sum_list = sub("\\_Summary.RData","\\.RData",sum_list)
dhs_list = r_list[!r_list %in% sum_list&grepl("DHS",r_list)]

#Run analysis for unprocessed datasets
with_progress({
  p = progressor(along = seq(length(dhs_list)*(3*85+2)))
  foreach(r_name = dhs_list, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  
  cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
  data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
  data_loc2 = paste0(cen_dir,"Downloads/Census/Summaries/")
  # data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
  file_name = paste0(data_loc,r_name)
  r_sum_name = paste0(data_loc2,sub("\\.RData","\\_Summary.RData",r_name))
  dataset = sub(pattern = ".RData", replacement = "", x = r_name)
  
  p(sprintf("Loading %s",r_name))
  
  load(file = file_name)
  
  dck = dck %>% mutate(disability_any = factor(disability_any,labels = c("no_a","any")),
                       disability_sev = factor(disability_some + 2*disability_atleast,labels = c("no","some","atleast")),
                       disability_some = factor(disability_some,labels = c("no_s","some_n")),
                       disability_atleast = factor(disability_atleast,labels = c("no_l","atleast_n")),
                       age_group5 = cut(age,c(14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,89,Inf),c("15 to 19","20 to 24","25 to 29","30 to 34","35 to 39","40 to 44","45 to 49","50 to 54","55 to 59","60 to 64","65 to 69","70 to 74","75 to 79","80 to 84","85 to 89","90+")),
                       age_group10 = cut(age, c(14,24,34,44,54,64,Inf),c("15 to 24","25 to 34","35 to 44","45 to 54","55 to 64","65+")),
                       male = factor(1 - female, labels = c("Female","Male")),
                       age_sex = interaction(age_group10, male, lex.order = T, sep = " "), 
                       as_weight = case_when(age_sex=="15 to 24 Female" ~ 0.107823219959552, age_sex=="15 to 24 Male" ~ 0.114985391312909, age_sex=="25 to 34 Female" ~ 0.104530062206990, age_sex=="25 to 34 Male" ~ 0.109379985244955, age_sex=="35 to 44 Female" ~ 0.090482564098174, age_sex=="35 to 44 Male" ~ 0.092693136884689, age_sex=="45 to 54 Female" ~ 0.077908667689967, age_sex=="45 to 54 Male" ~ 0.077798687417348, age_sex=="55 to 64 Female" ~ 0.059590620455815, age_sex=="55 to 64 Male" ~ 0.056425978108021, age_sex=="65+ Female" ~ 0.060324813942667 , age_sex=="65+ Male" ~ 0.048056872678913, TRUE ~ NA))
  dck = dck %>% mutate(across(any_of(c("admin1","admin2","admin_alt")),~as.character(as_factor(.x))))
  # dck = dck %>% mutate(across(any_of(c("admin1","admin2","admin_alt")),~as.factor(.x)),across(any_of(c("admin1","admin2","admin_alt")),~factor(as.character(.x))))
  # dck = dck %>% mutate(across(any_of(c("country_name","country_abrev","country_dataset_year","admin1","admin2","admin_alt")),~as.character(as_factor(.x))))
  dck = dck %>% filter(complete.cases(disability_any))
  
  if("psu2" %in% names(dck)) {
    dck = dck %>% select(-any_of(c("psu"))) %>% rename(psu = psu2)
  }
  if("strata2" %in% names(dck)) {
    dck = dck %>% select(-any_of(c("sample_strata"))) %>% rename(sample_strata = strata2)
  } 
  if("informal2" %in% names(dck)) {
    dck = dck %>% select(-any_of(c("work_informal"))) %>% rename(work_informal = informal2)
  } 
  if("work_informal2" %in% names(dck)) {
    dck = dck %>% select(-any_of(c("work_informal"))) %>% rename(work_informal = work_informal2)
  } 
  if("work_managerial2" %in% names(dck)) {
    dck = dck %>% select(-any_of(c("work_managerial"))) %>% rename(work_managerial = work_managerial2)
  } 
  
  if ("admin1" %in% names(dck)) if(n_distinct(dck$admin1) < 2) {
    dck = dck %>% select(-admin1)
  } else {
    dck = dck %>% mutate(admin1 = str_to_title(admin1))
  }
  if ("admin2" %in% names(dck)) if(n_distinct(dck$admin2) < 2) {
    dck = dck %>% select(-admin2)
  } else {
    dck = dck %>% mutate(admin2 = str_to_title(admin2))
  }
  if ("admin_alt" %in% names(dck)) if(n_distinct(dck$admin_alt) < 2) {
    dck = dck %>% select(-admin_alt)
  } else {
    dck = dck %>% mutate(admin_alt = str_to_title(admin_alt))
  }
  
  grp_a = c("female","urban_new","age_group")
  ind_a = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","health_exp_hh","ind_mdp")
  ind_a1 = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","social_prot","food_insecure","shock_any","ind_mdp")
  ind_a2 = c("lit_new","computer","internet","mobile_own","ind_emp","fp_demsat_mod","health_insurance")
  ind_a3 = c("health_exp_hh")
  ind_a4 = c("anyviolence_byh_12m")
  dis_a = c("disability_any","disability_some","disability_atleast","disability_sev")
  dis_a2 = c("disability_any","disability_some","disability_atleast")
  oth_a = c("disability_any_hh","disability_some_hh","disability_atleast_hh")
  oth_a2 = c("age_sex", "as_weight")
  cou_a = dck %>% select(any_of(c("admin1","admin2","admin_alt"))) %>% names()
  psu_a = c("ind_id","hh_id","ind_weight","ind2_weight","hh_weight","dv_weight","psu","ssu","tsu","sample_strata","country_abrev")
  dom_a = dck %>% select(any_of(c("disability_any","seeing_any","hearing_any","mobile_any","cognition_any","selfcare_any","communicating_any"))) %>% names()
  df_age_sex = dck %>% mutate(n = sum(ind_weight, na.rm = TRUE)) %>% summarise(n = first(as_weight)*first(n), .by = age_sex) %>% arrange(age_sex) %>% as.data.frame()
  
  dck = dck %>% select(all_of(cou_a),all_of(ind_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a))
  dck = dck %>% mutate(hh_id = cur_group_id(), .by = "hh_id")

  if(grepl("Mauritania",dataset)) {
    dck2a = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(ind_a1)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(tsu)&!is.na(ind_weight)&!is.na(sample_strata))
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(tsu)&!is.na(ind2_weight)&!is.na(sample_strata))
    dck2c = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(ind_a3),all_of(oth_a)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(tsu)&!is.na(hh_weight)&!is.na(sample_strata))
    dck2d = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(ind_a4)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(tsu)&!is.na(dv_weight)&!is.na(sample_strata))
    dck2e = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(tsu)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
    dck2a = dck2a %>% as_survey(ids = c(psu, ssu, tsu), weights = c(ind_weight , NULL, NULL), strata = c(sample_strata, NULL, NULL), nest = TRUE)
    dck2b = dck2b %>% as_survey(ids = c(psu, ssu, tsu), weights = c(ind2_weight, NULL, NULL), strata = c(sample_strata, NULL, NULL), nest = TRUE)
    dck2c = dck2c %>% as_survey(ids = c(psu, ssu, tsu), weights = c(hh_weight  , NULL, NULL), strata = c(sample_strata, NULL, NULL), nest = TRUE)
    dck2d = dck2d %>% as_survey(ids = c(psu, ssu, tsu), weights = c(dv_weight  , NULL, NULL), strata = c(sample_strata, NULL, NULL), nest = TRUE)
    dck2e = survey::svydesign(ids = ~psu + ssu + tsu, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2e) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
    rm(dck)
  } else {
    dck2a = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(ind_a1),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(ind_weight)&!is.na(sample_strata))
    dck2b = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(ind_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(ind2_weight)&!is.na(sample_strata))
    dck2c = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(ind_a3),all_of(oth_a)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(hh_weight)&!is.na(sample_strata))
    dck2d = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(ind_a4)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(dv_weight)&!is.na(sample_strata))
    dck2e = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
    dck2a = dck2a %>% as_survey(ids = c(psu, ssu), weights = c(ind_weight , NULL), strata = c(sample_strata, NULL), nest = TRUE)
    dck2b = dck2b %>% as_survey(ids = c(psu, ssu), weights = c(ind2_weight, NULL), strata = c(sample_strata, NULL), nest = TRUE)
    dck2c = dck2c %>% as_survey(ids = c(psu, ssu), weights = c(hh_weight  , NULL), strata = c(sample_strata, NULL), nest = TRUE)
    dck2d = dck2d %>% as_survey(ids = c(psu, ssu), weights = c(dv_weight  , NULL), strata = c(sample_strata, NULL), nest = TRUE)
    dck2e = survey::svydesign(ids = ~psu + ssu, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2e) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
    rm(dck)
  }
  
  p(sprintf("%s processed", r_name))
  
  tabs = foreach(admin_grp = c("admin0",cou_a)) %dofuture% {
    options(future.globals.maxSize = 1e10)
    options(survey.adjust.domain.lonely = TRUE)
    options(survey.lonely.psu = "adjust")
    admin = ifelse(admin_grp=="admin0","National",as.symbol(admin_grp))
    
    #Means national and regional
    tab_m_nr1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
      options(future.globals.maxSize = 1e10)
      options(survey.adjust.domain.lonely = TRUE)
      options(survey.lonely.psu = "adjust")
      p(sprintf("%s, Tab1, %s, %s, %s", r_name, admin_grp, agg_grp, dis_grp))
      dis = as.symbol(dis_grp)
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck2a %>% group_by({{agg}}, {{dis}}, {{admin}}) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, {{admin}}) %>%
        arrange({{agg}}, {{dis}}, {{admin}}) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    tab_m_nr2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
      options(future.globals.maxSize = 1e10)
      options(survey.adjust.domain.lonely = TRUE)
      options(survey.lonely.psu = "adjust")
      p(sprintf("%s, Tab1b, %s, %s, %s", r_name, admin_grp, agg_grp, dis_grp))
      dis = as.symbol(dis_grp)
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck2b %>% group_by({{agg}}, {{dis}}, {{admin}}) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, {{admin}}) %>%
        arrange({{agg}}, {{dis}}, {{admin}}) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    if(sum(!is.na(dck2c$variables$health_exp_hh))>0) {
      tab_m_nr3 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
        options(future.globals.maxSize = 1e10)
        options(survey.adjust.domain.lonely = TRUE)
        options(survey.lonely.psu = "adjust")
        p(sprintf("%s, Tab1c, %s, %s, %s", r_name, admin_grp, agg_grp, dis_grp))
        dis = as.symbol(dis_grp)
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2c %>% group_by({{agg}}, {{dis}}, {{admin}}) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, {{admin}}) %>%
          arrange({{agg}}, {{dis}}, {{admin}}) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
    } else {
      tab_m_nr3 = tab_m_nr1 %>% select(Agg,admin,level,contains("everattended_new"))
      tab_m_nr3 = tab_m_nr3 %>% mutate(across(contains("everattended_new"),~as.double(NA)))
      names(tab_m_nr3) = sub("everattended_new_","health_exp_hh_",names(tab_m_nr3))
    }
    if(sum(!is.na(dck2d$variables$anyviolence_byh_12m))>0) {
      tab_m_nr4 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
        options(future.globals.maxSize = 1e10)
        options(survey.adjust.domain.lonely = TRUE)
        options(survey.lonely.psu = "adjust")
        p(sprintf("%s, Tab1d, %s, %s, %s", r_name, admin_grp, agg_grp, dis_grp))
        dis = as.symbol(dis_grp)
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2d %>% group_by({{agg}}, {{dis}}, {{admin}}) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, {{admin}}) %>%
          arrange({{agg}}, {{dis}}, {{admin}}) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
    } else {
      tab_m_nr4 = tab_m_nr1 %>% select(Agg,admin,level,contains("everattended_new"))
      tab_m_nr4 = tab_m_nr4 %>% mutate(across(contains("everattended_new"),~as.double(NA)))
      names(tab_m_nr4) = sub("everattended_new_","anyviolence_byh_12m",names(tab_m_nr4))
    }
    
    tab_m_nr = full_join(full_join(full_join(tab_m_nr1,tab_m_nr2),tab_m_nr3),tab_m_nr4)
    rm(tab_m_nr1,tab_m_nr2,tab_m_nr3,tab_m_nr4)
    
    #Summary for P1
    tab_P1_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
      p(sprintf("%s, Tab2, %s, %s", r_name, admin_grp, agg_grp))
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck2a %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
        arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    
    #Summary for P2
    tab_P2_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
      p(sprintf("%s, Tab3, %s, %s", r_name, admin_grp, agg_grp))
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck2a %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
        arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    
    dck3c = dck2c %>% filter(!duplicated(hh_id))
    
    #Summary for P3
    p(sprintf("%s, Tab4, %s", r_name, admin_grp))
    tab_P3_nr = bind_rows(dck3c %>% group_by({{admin}}) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
                            mutate(Agg = "All = All", admin = {{admin_grp}}, level = as.character({{admin}}), .after= 1) %>% select(-1),
                          dck3c %>% group_by({{admin}},urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
                            arrange(urban_new, {{admin}}) %>% mutate(Agg = paste0("urban_new = ",urban_new), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2)))
    
    #Indicators by domain
    tab_P4_nr1 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %dofuture% {
      options(future.globals.maxSize = 1e10)
      options(survey.adjust.domain.lonely = TRUE)
      options(survey.lonely.psu = "adjust")
      p(sprintf("%s, Tab5, %s, %s", r_name, admin_grp, dom_grp))
      dom = as.symbol(dom_grp)
      tab = dck2a %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by({{admin}}) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>% complete({{admin}}) %>%
        arrange({{admin}}) %>% mutate(domain = dom_grp, admin = {{admin_grp}}, level = as.character({{admin}}), .after = 1) %>% select(-1)
    }
    tab_P4_nr2 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %dofuture% {
      options(future.globals.maxSize = 1e10)
      options(survey.adjust.domain.lonely = TRUE)
      options(survey.lonely.psu = "adjust")
      p(sprintf("%s, Tab5b, %s, %s", r_name, admin_grp, dom_grp))
      dom = as.symbol(dom_grp)
      tab = dck2b %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by({{admin}}) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>% complete({{admin}}) %>%
        arrange({{admin}}) %>% mutate(domain = dom_grp, admin = {{admin_grp}}, level = as.character({{admin}}), .after = 1) %>% select(-1)
    }
    if(sum(!is.na(dck2c$variables$health_exp_hh))>0) {
      tab_P4_nr3 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %dofuture% {
        options(future.globals.maxSize = 1e10)
        options(survey.adjust.domain.lonely = TRUE)
        options(survey.lonely.psu = "adjust")
        p(sprintf("%s, Tab5c, %s, %s", r_name, admin_grp, dom_grp))
        dom = as.symbol(dom_grp)
        tab = dck2c %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by({{admin}}) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>% complete({{admin}}) %>%
          arrange({{admin}}) %>% mutate(domain = dom_grp, admin = {{admin_grp}}, level = as.character({{admin}}), .after = 1) %>% select(-1)
      }
    } else {
      tab_P4_nr3 = tab_P4_nr1 %>% select(domain,admin,level,contains("everattended_new"))
      tab_P4_nr3 = tab_P4_nr3 %>% mutate(across(contains("everattended_new"),~as.double(NA)))
      names(tab_P4_nr3) = sub("everattended_new_","health_exp_hh_",names(tab_P4_nr3))
    }
    if(sum(!is.na(dck2d$variables$anyviolence_byh_12m))>0) {
      tab_P4_nr4 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %dofuture% {
        options(future.globals.maxSize = 1e10)
        options(survey.adjust.domain.lonely = TRUE)
        options(survey.lonely.psu = "adjust")
        p(sprintf("%s, Tab5d, %s, %s", r_name, admin_grp, dom_grp))
        dom = as.symbol(dom_grp)
        tab = dck2d %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by({{admin}}) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(any_of(ind_a), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>% complete({{admin}}) %>%
          arrange({{admin}}) %>% mutate(domain = dom_grp, admin = {{admin_grp}}, level = as.character({{admin}}), .after = 1) %>% select(-1)
      }
    } else {
      tab_P4_nr4 = tab_P4_nr1 %>% select(domain,admin,level,contains("everattended_new"))
      tab_P4_nr4 = tab_P4_nr4 %>% mutate(across(contains("everattended_new"),~as.double(NA)))
      names(tab_P4_nr4) = sub("everattended_new_","anyviolence_byh_12m",names(tab_P4_nr4))
    }
    
    tab_P4_nr = full_join(full_join(full_join(tab_P4_nr1,tab_P4_nr2),tab_P4_nr3),tab_P4_nr4)
    rm(tab_P4_nr1,tab_P4_nr2,tab_P4_nr3,tab_P4_nr4)
    
    #Prevalences for age-sex adjustment
    if(admin_grp == "bypass") {
      tab_as_adj_1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6a, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2e %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
      tab_as_adj_2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6b, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2e %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
    } else {
      tab_as_adj_1 = tab_P1_nr
      tab_as_adj_1 = tab_as_adj_1 %>% mutate(across(starts_with("disability"), ~as.double(NA)))
      tab_as_adj_2 = tab_P2_nr
      tab_as_adj_2 = tab_as_adj_2 %>% mutate(across(contains("_any"), ~as.double(NA)))
      }
    }
    # p(sprintf("%s, Tab6, %s", r_name, admin_grp))
    # tab_as_adj1 = dck2a %>% group_by(age_sex) %>% summarise(weight = first(as_weight), across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>% select(-1) %>% summarise(across(contains("mean"), ~weighted.mean(.x,weight)))
    # tab_as_adj2 = dck2e %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop")
    # tab_as_adj3 = dck2a2 %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))))
    
    return(lst(tab_m_nr,tab_P1_nr,tab_P2_nr,tab_P3_nr,tab_P4_nr,tab_as_adj_1,tab_as_adj_2))
  }

  tabs = pmap(tabs,bind_rows)
  
  #write to R
  save(tabs,file = r_sum_name)
  return(r_name)
  gc()
}
})
