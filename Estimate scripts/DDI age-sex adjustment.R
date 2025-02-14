#Age-sex adjustment
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
r_list2 = r_list[!r_list %in% sum_list&!grepl("DHS",r_list)&!sub(".RData","",r_list) %in% psu$Country_Survey_Date[!grepl("svyset",psu$`Stata code FINAL`)]]

#Run analysis for unprocessed datasets
with_progress({
  p = progressor(along = seq(length(r_list2)*(3*48+2)))
  foreach(r_name = r_list2, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
    
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
    dck = dck %>% mutate(across(any_of(c("admin1","admin2","admin3","admin_alt")),~as.character(as_factor(.x))))
    # dck = dck %>% mutate(across(any_of(c("admin1","admin2","admin_alt")),~as.factor(.x)),across(any_of(c("admin1","admin2","admin_alt")),~factor(as.character(.x))))
    # dck = dck %>% mutate(across(any_of(c("country_name","country_dataset_year","admin1","admin2","admin_alt")),~as.character(as_factor(.x))))
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
    if ("admin3" %in% names(dck)) if(n_distinct(dck$admin3) < 2) {
      dck = dck %>% select(-admin3)
    } else {
      dck = dck %>% mutate(admin3 = str_to_title(admin3))
    }
    if ("admin_alt" %in% names(dck)) if(n_distinct(dck$admin_alt) < 2) {
      dck = dck %>% select(-admin_alt)
    } else {
      dck = dck %>% mutate(admin_alt = str_to_title(admin_alt))
    }
    
    grp_a = c("female","urban_new","age_group")
    ind_a = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","health_exp_hh","ind_mdp")
    ind_a1 = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","ind_mdp")
    ind_a2 = c("health_exp_hh")
    dis_a = c("disability_any","disability_some","disability_atleast","disability_sev")
    dis_a2 = c("disability_any","disability_some","disability_atleast")
    oth_a = c("disability_any_hh","disability_some_hh","disability_atleast_hh")
    oth_a2 = c("age_sex", "as_weight")
    cou_a = dck %>% select(any_of(c("admin1","admin2","admin3","admin_alt"))) %>% names()
    psu_a = c("hh_id","ind_weight","hh_weight","psu","ssu","sample_strata")
    dom_a = dck %>% select(any_of(c("disability_any","seeing_any","hearing_any","mobile_any","cognition_any","selfcare_any","communicating_any"))) %>% names()
    df_age_sex = dck %>% mutate(n = sum(ind_weight, na.rm = TRUE)) %>% summarise(n = first(as_weight)*first(n), .by = age_sex) %>% arrange(age_sex) %>% as.data.frame()
    
    dck = dck %>% select(all_of(cou_a),all_of(ind_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a))
    dck = dck %>% group_by(hh_id) %>% mutate(hh_id = cur_group_id()) %>% ungroup()
    
    psu2 = psu %>% filter(Country_Survey_Date==dataset)
    
    #Other
    if(grepl("ssu", psu2$`Stata code FINAL`)) {
      if(!"ssu" %in% names(dck)) {
        dck = dck %>% mutate(ssu = hh_id)
      }
      dck2c = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
      dck2c = survey::svydesign(ids = ~psu + ssu, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2c) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2c$fpc$pps = FALSE
      rm(dck)
    } else if(grepl("psu", psu2$`Stata code FINAL`)) {
      dck2c = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ind_weight)&!is.na(age_sex))
      dck2c = survey::svydesign(ids = ~psu, weights = ~ind_weight, strata = NULL, nest = TRUE, data = dck2c) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2c$fpc$pps = FALSE
      rm(dck)
    } else if(grepl("admin", psu2$`Stata code FINAL`)) {
      dck2c = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(hh_id)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
      if (dataset == "South Africa_IPUMS_2011") {
        dck2c = survey::svydesign(ids = ~admin3, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2c) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      } else {
        dck2c = survey::svydesign(ids = ~admin2, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2c) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      }

      dck2c$fpc$pps = FALSE
      rm(dck)
    } else if(grepl("sample_strata", psu2$`Stata code FINAL`)) {
      dck2c = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(hh_id)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
      dck2c = survey::svydesign(ids = ~hh_id, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2c) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2c$fpc$pps = FALSE
      rm(dck)
    } else {
      dck2c = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(ind_weight)&!is.na(age_sex))
      dck2c = survey::svydesign(ids = ~0, weights = ~ind_weight, strata = NULL, nest = TRUE, data = dck2c) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2c$fpc$pps = FALSE
      rm(dck)
    }
    
    #Prevalences for age-sex adjustment
    if(admin_grp == "bypass") {
      tab_as_adj_1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6a, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2c %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
      tab_as_adj_2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6b, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2c %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
    } else {
      tab_as_adj_1 = tab_P1_nr
      tab_as_adj_1 = tab_as_adj_1 %>% mutate(across(starts_with("disability"), ~as.double(NA)))
      tab_as_adj_2 = tab_P2_nr
      tab_as_adj_2 = tab_as_adj_2 %>% mutate(across(contains("_any"), ~as.double(NA)))
    }
    
    #Full
    dck2 = dck %>% select(all_of(cou_a),all_of(dis_a2),all_of(grp_a),any_of(dom_a),all_of(oth_a2),ind_weight,fpc) %>% filter(!is.na(ind_weight)&!is.na(age_sex))
    dck2 = survey::svydesign(ids = ~0, weights = NULL, strata = NULL, nest = TRUE, fpc = ~fpc, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% srvyr::as_survey()
    
    #Prevalences for age-sex adjustment
    if(admin_grp == "bypass") {
      tab_as_adj_1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6a, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2 %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>% mutate(across(contains("mean_se"),~as.double(NA))) %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
      tab_as_adj_2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6b, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2 %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
    } else {
      tab_as_adj_1 = tab_P1_nr
      tab_as_adj_1 = tab_as_adj_1 %>% mutate(across(starts_with("disability"), ~as.double(NA)))
      tab_as_adj_2 = tab_P2_nr
      tab_as_adj_2 = tab_as_adj_2 %>% mutate(across(contains("_any"), ~as.double(NA)))
    }
    
    #Weighted
    dck2 = dck %>% select(all_of(cou_a),all_of(dis_a2),all_of(grp_a),any_of(dom_a),all_of(oth_a2),ind_weight) %>% filter(!is.na(ind_weight)&!is.na(age_sex))
    dck2 = survey::svydesign(ids = ~0, weights = ~ind_weight, strata = NULL, nest = TRUE, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% srvyr::as_survey()
    
    #Prevalences for age-sex adjustment
    if(admin_grp == "bypass") {
      tab_as_adj_1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6a, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2 %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
      tab_as_adj_2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6b, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2 %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
    } else {
      tab_as_adj_1 = tab_P1_nr
      tab_as_adj_1 = tab_as_adj_1 %>% mutate(across(starts_with("disability"), ~as.double(NA)))
      tab_as_adj_2 = tab_P2_nr
      tab_as_adj_2 = tab_as_adj_2 %>% mutate(across(contains("_any"), ~as.double(NA)))
    }
    
    #DHS
    if(grepl("Mauritania",dataset)) {
      dck2e = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(tsu)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
      dck2e = survey::svydesign(ids = ~psu + ssu + tsu, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2e) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      rm(dck)
    } else {
      dck2e = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
      dck2e = survey::svydesign(ids = ~psu + ssu, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2e) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      rm(dck)
    }
    
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
    # p(sprintf("%s, Tab6, %s", r_name, admin_grp))
    # tab_as_adj1 = dck2a %>% group_by(age_sex) %>% summarise(weight = first(as_weight), across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>% select(-1) %>% summarise(across(contains("mean"), ~weighted.mean(.x,weight)))
    # tab_as_adj2 = dck2e %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop")
    # tab_as_adj3 = dck2a2 %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))))
    
    #Code from database creation
    db6 = left_join(tabs$tab_as_adj_1,tabs$tab_as_adj_2)
    db6 = db6 %>% rename(disagg=Agg) %>% filter(!is.na(disagg),!disagg=="urban_new = 2") %>% 
      mutate(disagg = recode_factor(disagg,"All = All"="all_adults","female = 0"="males","female = 1"="females","urban_new = 0"="rural","urban_new = 1"="urban","age_group = 1"="ages15to29","age_group = 2"="ages30to44","age_group = 3"="ages45to64","age_group = 4"="ages65plus"))
    db6b = db6 %>% select(-ends_with("_mean"))
    db6 = db6 %>% select(-ends_with("_mean_se"))
    names(db6) = sub("disability_atleast","severe_disability",sub("disability_some","moderate_disability",sub("disability_any","disability",names(db6))))
    names(db6b) = sub("disability_atleast","severe_disability",sub("disability_some","moderate_disability",sub("disability_any","disability",names(db6b))))
    names(db6) = sub("_mean","_adjusted",sub("_any_mean","_adjusted",names(db6)))
    names(db6b) = sub("_mean_se","_adjusted",sub("_orany_mean_se","_adjusted",names(db6b)))
    db6c = db6 %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db6[-c(1:3)])))
    db6d = db6b %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db6b[-c(1:3)])))
    
    