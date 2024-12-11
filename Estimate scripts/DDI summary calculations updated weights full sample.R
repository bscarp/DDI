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

plan(list(sequential,sequential,tweak(multisession, workers = 2)))

library(progressr)
handlers(global = TRUE)
handlers("progress")

cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")

drive_auth("bradley.carpenter@mrc.ac.za")
file.remove(paste0(cen_dir,"Downloads/Census/Sampling design table.xlsx"))
drive_download(file = "https://docs.google.com/spreadsheets/d/16gJhGR7dlIiWxCeNlLSqcWcCFZFLaEz2/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
               path = paste0(cen_dir,"Downloads/Census/Sampling design table.xlsx"),overwrite = TRUE)
psu = read_xlsx(paste0(cen_dir,"Downloads/Census/Sampling design table.xlsx"),sheet = "Sampling Design")
psu = psu %>% filter(!is.na(`Stata code FINAL`))

#Check for unprocessed datasets
r_list = dir(paste0(cen_dir,"Downloads/Census/R Datasets/"))
sum_list = dir(paste0(cen_dir,"Downloads/Census/Summaries/"))
sum_list = sub("\\_Summary.RData","\\.RData",sum_list)
full_list = r_list[!r_list %in% sum_list&sub(".RData","",r_list) %in% psu$Country_Survey_Date[grepl("simple mean",psu$`Stata code FINAL`)]]
wei_list = r_list[!r_list %in% sum_list&sub(".RData","",r_list) %in% psu$Country_Survey_Date[!grepl("simple mean",psu$`Stata code FINAL`)&!grepl("svyset",psu$`Stata code FINAL`)]]

#Run analysis for unprocessed full datasets
with_progress({
  p = progressor(along = seq(length(full_list)*(3*29+2)))
  foreach(r_name = full_list, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  
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
                       fpc = n(),
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
  dis_a = c("disability_any","disability_some","disability_atleast","disability_sev")
  dis_a2 = c("disability_any","disability_some","disability_atleast")
  oth_a = c("disability_any_hh","disability_some_hh","disability_atleast_hh")
  oth_a2 = c("age_sex", "as_weight")
  cou_a = dck %>% select(any_of(c("admin1","admin2","admin_alt"))) %>% names()
  psu_a = c("ind_weight","hh_weight","hh_id", "fpc")
  dom_a = dck %>% select(any_of(c("disability_any","seeing_any","hearing_any","mobile_any","cognition_any","selfcare_any","communicating_any"))) %>% names()
  df_age_sex = dck %>% mutate(n = sum(ind_weight)) %>% summarise(n = first(as_weight)*first(n), .by = age_sex) %>% arrange(age_sex) %>% as.data.frame()
  
  dck = dck %>% select(all_of(cou_a),all_of(ind_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a))
  dck = dck %>% group_by(hh_id) %>% mutate(hh_id = cur_group_id()) %>% ungroup()
  
  dck2 = dck %>% filter(!is.na(ind_weight)&!is.na(age_sex))
  dck2 = survey::svydesign(ids = ~0, weights = NULL, strata = NULL, nest = TRUE, fpc = ~fpc, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% srvyr::as_survey()
  
  p(sprintf("%s processed", r_name))
  
  tabs = foreach(admin_grp = c("admin0",cou_a)) %dofuture% {
    options(future.globals.maxSize = 1e10)
    options(survey.adjust.domain.lonely = TRUE)
    options(survey.lonely.psu = "adjust")
    admin = ifelse(admin_grp=="admin0","National",as.symbol(admin_grp))
    
    #Means national and regional
    tab_m_nr  = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
      options(future.globals.maxSize = 1e10)
      options(survey.adjust.domain.lonely = TRUE)
      options(survey.lonely.psu = "adjust")
      p(sprintf("%s, Tab1, %s, %s, %s", r_name, admin_grp, agg_grp, dis_grp))
      dis = as.symbol(dis_grp)
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck %>% group_by({{agg}}, {{dis}}, {{admin}}) %>% summarise(across(any_of(ind_a), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),mean(.x,na.rm = T)*100),mean_se = ~as.double(NA))),.groups = "drop") %>% complete({{agg}}, {{dis}}, {{admin}}) %>%
        arrange({{agg}}, {{dis}}, {{admin}}) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    
    #Summary for P1
    tab_P1_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
      options(future.globals.maxSize = 1e10)
      options(survey.adjust.domain.lonely = TRUE)
      options(survey.lonely.psu = "adjust")
      p(sprintf("%s, Tab2, %s, %s", r_name, admin_grp, agg_grp))
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),mean(as.numeric(.x)-1,na.rm = T)*100),mean_se = ~as.double(NA))),.groups = "drop") %>%
        arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    
    #Summary for P2
    tab_P2_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
      options(future.globals.maxSize = 1e10)
      options(survey.adjust.domain.lonely = TRUE)
      options(survey.lonely.psu = "adjust")
      p(sprintf("%s, Tab3, %s, %s", r_name, admin_grp, agg_grp))
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),mean(.x,na.rm = T)*100),mean_se = ~as.double(NA))),.groups = "drop") %>%
        arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    
    dck3 = dck %>% filter(!duplicated(hh_id))
    
    #Summary for P3
    p(sprintf("%s, Tab4, %s", r_name, admin_grp))
    tab_P3_nr = bind_rows(dck3 %>% group_by({{admin}}) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),mean(.x,na.rm = T)*100),mean_se = ~as.double(NA))),.groups = "drop") %>%
                            mutate(Agg = "All = All", admin = {{admin_grp}}, level = as.character({{admin}}), .after= 1) %>% select(-1),
                          dck3 %>% group_by({{admin}},urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),mean(.x,na.rm = T)*100),mean_se = ~as.double(NA))),.groups = "drop") %>%
                            arrange(urban_new, {{admin}}) %>% mutate(Agg = paste0("urban_new = ",urban_new), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2)))
    
    #Indicators by domain
    tab_P4_nr = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %do% {
      options(future.globals.maxSize = 1e10)
      options(survey.adjust.domain.lonely = TRUE)
      options(survey.lonely.psu = "adjust")
      p(sprintf("%s, Tab5, %s, %s", r_name, admin_grp, dom_grp))
      dom = as.symbol(dom_grp)
      tab = dck %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by({{admin}}) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),mean(.x,na.rm = T)*100),mean_se = ~as.double(NA))),.groups = "drop") %>% complete({{admin}}) %>%
        arrange({{admin}}) %>% mutate(domain = dom_grp, admin = {{admin_grp}}, level = as.character({{admin}}), .after = 1) %>% select(-1)
    }
    
    #Prevalences for age-sex adjustment
    if(admin_grp == "admin0") {
      tab_as_adj_1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2 %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,as.double(NA),survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>% mutate(across(contains("mean_se"),~as.double(NA))) %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
      tab_as_adj_2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2 %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,as.double(NA),survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
    } else {
      tab_as_adj_1 = dck2c %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2),list(mean = as.double(NA), mean_se = as.double(NA))))
      tab_as_adj_2 = dck2c %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any),list(mean = as.double(NA), mean_se = as.double(NA))))
    }

    return(lst(tab_m_nr,tab_P1_nr,tab_P2_nr,tab_P3_nr,tab_P4_nr,tab_as_adj_1,tab_as_adj_2))
  }

  tabs = pmap(tabs,bind_rows)
  
  #write to R
  save(tabs,file = r_sum_name)
  return(r_name)
  gc()
}
})

#Run analysis for unprocessed weighted datasets
with_progress({
  p = progressor(along = seq(length(wei_list)*(3*48+2)))
  foreach(r_name = wei_list, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
  
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
                       fpc = n(),
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
  ind_a1 = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing","work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond","ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","ind_mdp")
  ind_a2 = c("health_exp_hh")
  dis_a = c("disability_any","disability_some","disability_atleast","disability_sev")
  dis_a2 = c("disability_any","disability_some","disability_atleast")
  oth_a = c("disability_any_hh","disability_some_hh","disability_atleast_hh")
  oth_a2 = c("age_sex", "as_weight")
  cou_a = dck %>% select(any_of(c("admin1","admin2","admin_alt"))) %>% names()
  psu_a = c("ind_weight","hh_weight","hh_id")
  dom_a = dck %>% select(any_of(c("disability_any","seeing_any","hearing_any","mobile_any","cognition_any","selfcare_any","communicating_any"))) %>% names()
  df_age_sex = dck %>% mutate(n = sum(ind_weight)) %>% summarise(n = first(as_weight)*first(n), .by = age_sex) %>% arrange(age_sex) %>% as.data.frame()
  
  dck = dck %>% select(all_of(cou_a),all_of(ind_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),all_of(oth_a),all_of(oth_a2),any_of(psu_a))
  dck = dck %>% group_by(hh_id) %>% mutate(hh_id = cur_group_id()) %>% ungroup()
  
  dck2 = dck %>% filter(!is.na(ind_weight)&!is.na(age_sex))
  dck2 = survey::svydesign(ids = ~0, weights = ~ind_weight, strata = NULL, nest = TRUE, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% srvyr::as_survey()
  
  p(sprintf("%s processed", r_name))
  
  tabs = foreach(admin_grp = c("admin0",cou_a)) %dofuture% {
    options(future.globals.maxSize = 1e10)
    options(survey.adjust.domain.lonely = TRUE)
    options(survey.lonely.psu = "adjust")
    admin = ifelse(admin_grp=="admin0","National",as.symbol(admin_grp))
    
    #Means national and regional
    tab_m_nr1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
      options(future.globals.maxSize = 1e11)
      p(sprintf("%s, Tab1, %s, %s, %s", r_name, admin_grp, agg_grp, dis_grp))
      dis = as.symbol(dis_grp)
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck %>% group_by({{agg}}, {{dis}}, {{admin}}) %>% summarise(across(any_of(ind_a1), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,as.double(NA),sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, {{admin}}) %>%
        arrange({{agg}}, {{dis}}, {{admin}}) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    tab_m_nr2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %:% foreach(dis_grp=c("disability_any","disability_sev","disability_atleast"), .combine = "full_join", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
      options(future.globals.maxSize = 1e10)
      p(sprintf("%s, Tab1b, %s, %s, %s", r_name, admin_grp, agg_grp, dis_grp))
      dis = as.symbol(dis_grp)
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck %>% group_by({{agg}}, {{dis}}, {{admin}}) %>% summarise(across(any_of(ind_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),wtd.mean(.x,hh_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,as.double(NA),sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete({{agg}}, {{dis}}, {{admin}}) %>%
        arrange({{agg}}, {{dis}}, {{admin}}) %>% pivot_wider(names_from = {{dis}},values_from = -c(1:3)) %>% mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    
    tab_m_nr = full_join(tab_m_nr1,tab_m_nr2)
    rm(tab_m_nr1,tab_m_nr2)
    
    #Summary for P1
    tab_P1_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
      options(future.globals.maxSize = 1e10)
      p(sprintf("%s, Tab2, %s, %s", r_name, admin_grp, agg_grp))
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),wtd.mean(as.numeric(.x)-1,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,as.double(NA),sqrt(wtd.var(as.numeric(.x)-1,na.rm = T)/n())*100))),.groups = "drop") %>%
        arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }
    
    #Summary for P2
    tab_P2_nr = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join") %do% {
      options(future.globals.maxSize = 1e10)
      p(sprintf("%s, Tab3, %s, %s", r_name, admin_grp, agg_grp))
      agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
      tab = dck %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,as.double(NA),sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>%
        arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
    }

    dck3 = dck %>% filter(!duplicated(hh_id))
    
    #Summary for P3
    p(sprintf("%s, Tab4, %s", r_name, admin_grp))
    tab_P3_nr = bind_rows(dck3 %>% group_by({{admin}}) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,as.double(NA),sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>%
                            mutate(Agg = "All = All", admin = {{admin_grp}}, level = as.character({{admin}}), .after= 1) %>% select(-1),
                          dck3 %>% group_by({{admin}},urban_new) %>% summarise(across(c(disability_any_hh,disability_some_hh,disability_atleast_hh),list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,as.double(NA),sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>%
                            arrange(urban_new, {{admin}}) %>% mutate(Agg = paste0("urban_new = ",urban_new), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2)))
    
    #Indicators by domain
    tab_P4_nr1 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %do% {
      options(future.globals.maxSize = 1e10)
      p(sprintf("%s, Tab5, %s, %s", r_name, admin_grp, dom_grp))
      dom = as.symbol(dom_grp)
      tab = dck %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by({{admin}}) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a1), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),wtd.mean(.x,ind_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,as.double(NA),sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete({{admin}}) %>%
        arrange({{admin}}) %>% mutate(domain = dom_grp, admin = {{admin_grp}}, level = as.character({{admin}}), .after = 1) %>% select(-1)
    }
    tab_P4_nr2 = foreach(dom_grp=dom_a, .options.future = list(packages = c("tidyverse","haven")),.combine = "rbind") %do% {
      options(future.globals.maxSize = 1e10)
      p(sprintf("%s, Tab5b, %s, %s", r_name, admin_grp, dom_grp))
      dom = as.symbol(dom_grp)
      tab = dck %>% mutate(disability_any = as.numeric(disability_any)-1) %>% group_by({{admin}}) %>% filter({{dom}}==1, .preserve = TRUE) %>% summarise(across(all_of(ind_a2), list(mean = ~ifelse(sum(!is.na(.x))<50,as.double(NA),wtd.mean(.x,hh_weight,na.rm = T)*100),mean_se = ~ifelse(sum(!is.na(.x))<50,as.double(NA),sqrt(wtd.var(.x,na.rm = T)/n())*100))),.groups = "drop") %>% complete({{admin}}) %>%
        arrange({{admin}}) %>% mutate(domain = dom_grp, admin = {{admin_grp}}, level = as.character({{admin}}), .after = 1) %>% select(-1)
    }
    
    tab_P4_nr = full_join(tab_P4_nr1,tab_P4_nr2)
    rm(tab_P4_nr1,tab_P4_nr2)
    
    #Prevalences for age-sex adjustment
    if(admin_grp == "admin0") {
      tab_as_adj_1 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2 %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2), list(mean = ~if_else(sum(!is.na(.x))<50,as.double(NA),survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
      tab_as_adj_2 = foreach(agg_grp=c("All","female","urban_new","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6, %s, %s", r_name, admin_grp, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2 %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,as.double(NA),survey_mean(.x,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}, {{admin}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = {{admin_grp}}, level = as.character({{admin}}), .after = 2) %>% select(c(-1,-2))
      }
    } else {
      tab_as_adj_1 = dck2c %>% group_by({{agg}},{{admin}}) %>% summarise(across(all_of(dis_a2),list(mean = as.double(NA), mean_se = as.double(NA))))
      tab_as_adj_2 = dck2c %>% group_by({{agg}},{{admin}}) %>% summarise(across(c(seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any),list(mean = as.double(NA), mean_se = as.double(NA))))
    }

    return(lst(tab_m_nr,tab_P1_nr,tab_P2_nr,tab_P3_nr,tab_P4_nr,tab_as_adj_1,tab_as_adj_2))
  }
  
  tabs = pmap(tabs,bind_rows)
  
  #write to R
  save(tabs,file = r_sum_name)
  return(r_name)
  gc()
}
})
