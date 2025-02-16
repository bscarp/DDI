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
plan(list(sequential,tweak(multisession, workers = 4)))

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
sum_list = dir(paste0(cen_dir,"Downloads/Census/Summaries/"))
adj_list = dir(paste0(cen_dir,"Downloads/Census/Adjusted/"))
adj_list = sub("\\_Summary.RData","\\.RData",adj_list)
adj_list2 = sum_list[!sum_list %in% adj_list]

#Run analysis for unprocessed datasets
with_progress({
  p = progressor(along = seq(length(adj_list2)*(3)))
  foreach(r_name = adj_list2, .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
    
    cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
    data_loc = paste0(cen_dir,"Downloads/Census/R Datasets/")
    data_loc2 = paste0(cen_dir,"Downloads/Census/Summaries/")
    # data_loc3 = paste0(cen_dir,"Downloads/Census/Stata Datasets/")
    file_name = paste0(data_loc,r_name)
    r_adj_name = paste0(data_loc2,sub("\\.RData","\\_Summary.RData",r_name))
    dataset = sub(pattern = ".RData", replacement = "", x = r_name)
    
    p(sprintf("Loading %s",r_name))
    
    load(file = file_name)
    
    dck = dck %>% mutate(disability_any = factor(disability_any,labels = c("no_a","any")),
                         disability_some = factor(disability_some,labels = c("no_s","some_n")),
                         disability_atleast = factor(disability_atleast,labels = c("no_l","atleast_n")),
                         age_group5 = cut(age,c(14,19,24,29,34,39,44,49,54,59,64,69,74,79,Inf),c("15 to 19","20 to 24","25 to 29","30 to 34","35 to 39","40 to 44","45 to 49","50 to 54","55 to 59","60 to 64","65 to 69","70 to 74","75 to 79","80+")),
                         male = factor(1 - female, labels = c("Female","Male")),
                         age_sex = interaction(age_group5, male, lex.order = T, sep = " "), 
                         as_weight = case_when(age_sex=="15 to 19 Female" ~ 0.055177596606434,
                                               age_sex=="15 to 19 Male"   ~ 0.058972075585030,
                                               age_sex=="20 to 24 Female" ~ 0.052645623353118,
                                               age_sex=="20 to 24 Male"   ~ 0.056013315727878,
                                               age_sex=="25 to 29 Female" ~ 0.051707309875680,
                                               age_sex=="25 to 29 Male"   ~ 0.054416013872858,
                                               age_sex=="30 to 34 Female" ~ 0.052822752331310,
                                               age_sex=="30 to 34 Male"   ~ 0.054963971372097,
                                               age_sex=="35 to 39 Female" ~ 0.048186006708157,
                                               age_sex=="35 to 39 Male"   ~ 0.049554888100486,
                                               age_sex=="40 to 44 Female" ~ 0.042296557390017,
                                               age_sex=="40 to 44 Male"   ~ 0.043138248784204,
                                               age_sex=="45 to 49 Female" ~ 0.040112435044105,
                                               age_sex=="45 to 49 Male"   ~ 0.040388556981784,
                                               age_sex=="50 to 54 Female" ~ 0.037796232645862,
                                               age_sex=="50 to 54 Male"   ~ 0.037410130435564,
                                               age_sex=="55 to 59 Female" ~ 0.033378697682454,
                                               age_sex=="55 to 59 Male"   ~ 0.032182614793466,
                                               age_sex=="60 to 64 Female" ~ 0.026211922773361,
                                               age_sex=="60 to 64 Male"   ~ 0.024243363314555,
                                               age_sex=="65 to 69 Female" ~ 0.022804381810621,
                                               age_sex=="65 to 69 Male"   ~ 0.020074220984973,
                                               age_sex=="70 to 74 Female" ~ 0.016004133311695,
                                               age_sex=="70 to 74 Male"   ~ 0.013298817567149,
                                               age_sex=="75 to 79 Female" ~ 0.009944878717579,
                                               age_sex=="75 to 79 Male"   ~ 0.007691750239893,
                                               age_sex=="80+ Female"      ~ 0.011571420102771,
                                               age_sex=="80+ Male"        ~ 0.006992083886898,
                                               TRUE                       ~ NA))
    dck = dck %>% filter(complete.cases(disability_any))
    
    if("psu2" %in% names(dck)) {
      dck = dck %>% select(-any_of(c("psu"))) %>% rename(psu = psu2)
    }
    if("strata2" %in% names(dck)) {
      dck = dck %>% select(-any_of(c("sample_strata"))) %>% rename(sample_strata = strata2)
    }
    
    grp_a = c("female","age_group")
    dis_a2 = c("disability_any","disability_some","disability_atleast")
    oth_a2 = c("age_sex", "as_weight")
    psu_a = c("hh_id","ind_weight","hh_weight","psu","ssu","sample_strata")
    dom_a = dck %>% select(any_of(c("disability_any","seeing_any","hearing_any","mobile_any","cognition_any","selfcare_any","communicating_any"))) %>% names()
    df_age_sex = dck %>% mutate(n = sum(ind_weight, na.rm = TRUE)) %>% summarise(n = first(as_weight)*first(n), .by = age_sex) %>% arrange(age_sex) %>% as.data.frame()
    
    dck = dck %>% select(all_of(dis_a),all_of(grp_a),any_of(dom_a),all_of(oth_a2),any_of(psu_a))
    dck = dck %>% group_by(hh_id) %>% mutate(hh_id = cur_group_id()) %>% ungroup()
    
    psu2 = psu %>% filter(Country_Survey_Date==dataset)
    
    #Other
    if(grepl("tsu", psu2$`Stata code FINAL`)) {
      if(!"ssu" %in% names(dck)) {
        dck = dck %>% mutate(ssu = hh_id)
      }
      dck2 = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(tsu)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
      dck2 = survey::svydesign(ids = ~psu + ssu + tsu, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2$fpc$pps = FALSE
      rm(dck)
    } else if(grepl("ssu", psu2$`Stata code FINAL`)) {
      if(!"ssu" %in% names(dck)) {
        dck = dck %>% mutate(ssu = hh_id)
      }
      dck2 = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ssu)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
      dck2 = survey::svydesign(ids = ~psu + ssu, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2$fpc$pps = FALSE
      rm(dck)
    } else if(grepl("psu", psu2$`Stata code FINAL`)) {
      dck2 = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(psu)&!is.na(ind_weight)&!is.na(age_sex))
      dck2 = survey::svydesign(ids = ~psu, weights = ~ind_weight, strata = NULL, nest = TRUE, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2$fpc$pps = FALSE
      rm(dck)
    } else if(grepl("admin", psu2$`Stata code FINAL`)) {
      dck2 = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(hh_id)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
      if (dataset == "South Africa_IPUMS_2011") {
        dck2 = survey::svydesign(ids = ~admin3, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      } else {
        dck2 = survey::svydesign(ids = ~admin2, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      }
      dck2$fpc$pps = FALSE
      rm(dck)
    } else if(grepl("sample_strata", psu2$`Stata code FINAL`)) {
      dck2 = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(hh_id)&!is.na(ind_weight)&!is.na(sample_strata)&!is.na(age_sex))
      dck2 = survey::svydesign(ids = ~hh_id, weights = ~ind_weight, strata = ~sample_strata, nest = TRUE, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2$fpc$pps = FALSE
      rm(dck)
    } else if(grepl("weight", psu2$`Stata code FINAL`)) {
      dck2 = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),any_of(psu_a),all_of(oth_a2)) %>% filter(!is.na(ind_weight)&!is.na(age_sex))
      dck2 = survey::svydesign(ids = ~0, weights = ~ind_weight, strata = NULL, nest = TRUE, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2$fpc$pps = FALSE
      rm(dck)
    } else {
      dck2 = dck %>% select(all_of(cou_a),all_of(dis_a),all_of(grp_a),any_of(dom_a),all_of(oth_a2),ind_weight,fpc) %>% filter(!is.na(ind_weight)&!is.na(age_sex))
      dck2 = survey::svydesign(ids = ~0, weights = NULL, strata = NULL, nest = TRUE, fpc = ~fpc, data = dck2) %>% survey::postStratify(~age_sex, df_age_sex) %>% as_survey()
      dck2$fpc$pps = FALSE
      rm(dck)
    }
    
    #Prevalences for age-sex adjustment
      tab_as_adj = foreach(agg_grp=c("All","female","age_group"), .combine = "full_join", .options.future = list(packages = c("srvyr"))) %dofuture% {
        p(sprintf("%s, Tab6a, %s, %s", r_name, agg_grp))
        agg = ifelse(agg_grp=="All",agg_grp,as.symbol(agg_grp))
        tab = dck2 %>% group_by({{agg}}) %>% summarise(across(c(all_of(dis_a2),seeing_any,hearing_any,mobile_any,cognition_any,selfcare_any,communicating_any), list(mean = ~if_else(sum(!is.na(.x))<50,NA,survey_mean(as.numeric(.x)-1,na.rm = T, df = Inf)*100))),.groups = "drop") %>%
          arrange({{agg}}) %>%  mutate(Agg = paste0(agg_grp," = ",{{agg}}), admin = "admin0", level = "National", .after = 2) %>% select(c(-1,-2))
      }
    
      #write to R
      save(tab_as_adj,file = r_sum_name)
      return(r_name)
      gc()
  }
})
    #Code from database creation
    # db6 = left_join(tabs$tab_as_adj_1,tabs$tab_as_adj_2)
    # db6 = db6 %>% rename(disagg=Agg) %>% filter(!is.na(disagg),!disagg=="urban_new = 2") %>% 
    #   mutate(disagg = recode_factor(disagg,"All = All"="all_adults","female = 0"="males","female = 1"="females","urban_new = 0"="rural","urban_new = 1"="urban","age_group = 1"="ages15to29","age_group = 2"="ages30to44","age_group = 3"="ages45to64","age_group = 4"="ages65plus"))
    # db6b = db6 %>% select(-ends_with("_mean"))
    # db6 = db6 %>% select(-ends_with("_mean_se"))
    # names(db6) = sub("disability_atleast","severe_disability",sub("disability_some","moderate_disability",sub("disability_any","disability",names(db6))))
    # names(db6b) = sub("disability_atleast","severe_disability",sub("disability_some","moderate_disability",sub("disability_any","disability",names(db6b))))
    # names(db6) = sub("_mean","_adjusted",sub("_any_mean","_adjusted",names(db6)))
    # names(db6b) = sub("_mean_se","_adjusted",sub("_orany_mean_se","_adjusted",names(db6b)))
    # db6c = db6 %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db6[-c(1:3)])))
    # db6d = db6b %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db6b[-c(1:3)])))
    
    