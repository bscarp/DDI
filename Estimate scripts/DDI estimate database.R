library(future)
library(doFuture)
options(future.globals.maxSize = 1e10)
library(foreach)
library(tidyverse)
library(googledrive)
library(readxl)
library(writexl)
plan(multisession, workers = 4)

## Check what happens when disagg is NA !!!!
cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
db_loc = c(paste0(cen_dir,"Downloads/Census/Database/Backup/"))

if(!file.exists(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"))) {
  file.copy(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0 - Copy.xlsx"),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"))
  file.copy(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1 - Copy.xlsx"),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"))
  file.copy(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2 - Copy.xlsx"),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"))
}

# wb1 <- loadWorkbook(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output.xlsx"))
# wb2 <- loadWorkbook(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"))
# mean1 = readWorksheet(wb1,"Means", colTypes = c(rep("character",2),rep("numeric",1305)), check.names = FALSE)
# se1 = readWorksheet(wb1,"Standard Errors", colTypes = c(rep("character",2),rep("numeric",1305)), check.names = FALSE)
# mean2 = readWorksheet(wb2,"Means", colTypes = c(rep("character",2),rep("numeric",1305)), check.names = FALSE)
# se2 = readWorksheet(wb2,"Standard Errors", colTypes = c(rep("character",2),rep("numeric",1305)), check.names = FALSE)
mean1 = read_xlsx(path = paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"),"Means")

# temp = read_xlsx(paste0(cen_dir,"Downloads/Census/Kenya/2024/Results/Wide_Table_Output_Admin1.xlsx"))
# order = names(temp %>% select(!...1))
# save(order,file=paste0(cen_dir,"Downloads/Census/Kenya/2024/Order.RData"))
# rm(order,temp)

order = unique(c("survey","admin1",names(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Order.xlsx"),sheet = "Sheet1",range = "B1:BDM1"))))
order = gsub("  "," ",order)
order2 = sub("admin1", "admin2", order)

#Check for unprocessed summaries
sum_list = dir(paste0(cen_dir,"Downloads/Census/Summaries/"))
sum_list2 = str_extract(sum_list,".*_.*_[0-9]{4}")
com_list = unique(mean1$survey)
run_list = sum_list[!sum_list2 %in% com_list]
svy_list = sum_list2[!sum_list2 %in% com_list]

#Needs refinement
# check = foreach(file = run_list, svy = svy_list,.verbose = FALSE , .options.future = list(packages = c("tidyverse","haven")), .combine = "rbind") %dofuture% {
#   load(paste0(paste0(cen_dir,"Downloads/Census/Summaries/",file))
#   tabs$tab_m_nr[[1]][[1]] |> summarise(across(everything(),~mode(.x))) |> mutate(svy = svy,.before = admin1)
# }

#Run analysis for unprocessed datasets
merged = foreach(file = run_list, svy = svy_list, .verbose = FALSE, .combine = "bind_rows", .options.future = list(packages = c("tidyverse","haven"))) %dofuture% {
    
  ##Load data file created by DDI summary calculations.R
  load(paste0(cen_dir,"Downloads/Census/Summaries/",file))
  print(svy)
  
  ind_a = c("everattended_new","ind_atleastprimary","ind_atleastsecondary","lit_new","computer","internet","mobile_own","ind_emp","youth_idle","work_manufacturing",
            "work_managerial","work_informal","ind_water","ind_toilet","fp_demsat_mod","anyviolence_byh_12m","ind_electric","ind_cleanfuel","ind_livingcond",
            "ind_asset_ownership","cell_new","health_insurance","social_prot","food_insecure","shock_any","health_exp_hh","ind_mdp")
  
  db1 = tabs$tab_P1_nr %>% rename(disagg=Agg) %>% filter(!is.na(disagg),!disagg=="urban_new = 2") %>% mutate(disagg = recode_factor(disagg,"All = All"="all_adults","female = 0"="males","female = 1"="females","urban_new = 0"="rural","urban_new = 1"="urban","age_group = 1"="ages15to29","age_group = 2"="ages30to44","age_group = 3"="ages45to64","age_group = 4"="ages65plus"))
  db1b = db1 %>% select(-ends_with("_mean")) %>% rename("any_difficulty"=disability_any_mean_se,"some_difficulty"=disability_some_mean_se, "atleast_alot_difficulty"=disability_atleast_mean_se)
  db1 = db1 %>% select(-ends_with("_mean_se")) %>% rename("any_difficulty"=disability_any_mean,"some_difficulty"=disability_some_mean, "atleast_alot_difficulty"=disability_atleast_mean)
  db1c = db1 %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db1[-c(1:3)])))
  db1d = db1b %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db1b[-c(1:3)])))
  
  db2 = tabs$tab_m_nr %>% rename(disagg=Agg) %>% select(disagg,admin,level,ends_with("_no"),ends_with("_some"),ends_with("_atleast"),ends_with("any"),ends_with("no_l")) %>% 
    filter(!is.na(disagg),!disagg=="urban_new = 2") %>% mutate(disagg = recode_factor(disagg,"All = All"="all_adults","female = 0"="males","female = 1"="females","urban_new = 0"="rural","urban_new = 1"="urban","age_group = 1"="ages15to29","age_group = 2"="ages30to44","age_group = 3"="ages45to64","age_group = 4"="ages65plus"))

  names(db2) = sub("everattended_new","Ever_attended_school",names(db2))
  names(db2) = sub("ind_atleastprimary","At_least_primary",names(db2))
  names(db2) = sub("ind_atleastsecondary","At_least_secondary",names(db2))
  names(db2) = sub("lit_new","Literacy_rate",names(db2))
  names(db2) = sub("computer","Computer_use",names(db2))
  names(db2) = sub("internet","Internet_use",names(db2))
  names(db2) = sub("mobile_own","Own_Mobile",names(db2))
  names(db2) = sub("ind_emp","Employment",names(db2))
  names(db2) = sub("youth_idle","Youth_idle_rate",names(db2))
  names(db2) = sub("work_manufacturing","Manufacturing_work",names(db2))
  names(db2) = sub("work_managerial","Managerial_work",names(db2))
  names(db2) = sub("work_informal","Informal_work",names(db2))
  names(db2) = sub("ind_water","Water",names(db2))
  names(db2) = sub("ind_toilet","Sanitation",names(db2))
  names(db2) = sub("fp_demsat_mod","Family_Planning_Met",names(db2))
  names(db2) = sub("anyviolence_byh_12m","Any_Violence",names(db2))
  names(db2) = sub("ind_electric","Electricity",names(db2))
  names(db2) = sub("ind_cleanfuel","Clean_fuel",names(db2))
  names(db2) = sub("ind_livingcond","Adequate_Housing",names(db2))
  names(db2) = sub("ind_asset_ownership","Share_assets_owned",names(db2))
  names(db2) = sub("cell_new","Household_Mobile_phone",names(db2))
  names(db2) = sub("health_insurance","Health_insurance",names(db2))
  names(db2) = sub("social_prot","Social_protection",names(db2))
  names(db2) = sub("food_insecure","Food_insecure",names(db2))
  names(db2) = sub("shock_any","Shock",names(db2))
  names(db2) = sub("health_exp_hh","Health_expenditures",names(db2))
  names(db2) = sub("ind_mdp","Multid_poverty",names(db2))
  db2b = db2 %>% select(disagg,admin,level,contains("_mean_se_"))
  db2 = db2 %>% select(-contains("_mean_se_"))
  names(db2) = sub("_mean_no_l"," nosome_difficulty",names(db2))
  names(db2) = sub("_mean_any"," any_difficulty",names(db2))
  names(db2) = sub("_mean_no"," no_difficulty",names(db2))
  names(db2) = sub("_mean_some"," some_difficulty",names(db2))
  names(db2) = sub("_mean_atleast"," atleast_alot_difficulty",names(db2))
  names(db2b) = sub("_mean_se_no_l"," nosome_difficulty",names(db2b))
  names(db2b) = sub("_mean_se_any"," any_difficulty",names(db2b))
  names(db2b) = sub("_mean_se_no"," no_difficulty",names(db2b))
  names(db2b) = sub("_mean_se_some"," some_difficulty",names(db2b))
  names(db2b) = sub("_mean_se_atleast"," atleast_alot_difficulty",names(db2b))
  
  db2c = db2 %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db2[-c(1:3)])))
  db2d = db2b %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db2b[-c(1:3)])))
  db2c = db2c %>% rename("At_least_primary no_difficulty (ages25to29)"="At_least_primary no_difficulty (ages15to29)",
                         "At_least_primary some_difficulty (ages25to29)"="At_least_primary some_difficulty (ages15to29)",
                         "At_least_primary atleast_alot_difficulty (ages25to29)"="At_least_primary atleast_alot_difficulty (ages15to29)",
                         "At_least_primary any_difficulty (ages25to29)"="At_least_primary any_difficulty (ages15to29)",
                         "At_least_primary nosome_difficulty (ages25to29)"="At_least_primary nosome_difficulty (ages15to29)",
                         "At_least_secondary no_difficulty (ages25to29)"="At_least_secondary no_difficulty (ages15to29)",
                         "At_least_secondary some_difficulty (ages25to29)"="At_least_secondary some_difficulty (ages15to29)",
                         "At_least_secondary atleast_alot_difficulty (ages25to29)"="At_least_secondary atleast_alot_difficulty (ages15to29)",
                         "At_least_secondary any_difficulty (ages25to29)"="At_least_secondary any_difficulty (ages15to29)",
                         "At_least_secondary nosome_difficulty (ages25to29)"="At_least_secondary nosome_difficulty (ages15to29)")
  db2d = db2d %>% rename("At_least_primary no_difficulty (ages25to29)"="At_least_primary no_difficulty (ages15to29)",
                         "At_least_primary some_difficulty (ages25to29)"="At_least_primary some_difficulty (ages15to29)",
                         "At_least_primary atleast_alot_difficulty (ages25to29)"="At_least_primary atleast_alot_difficulty (ages15to29)",
                         "At_least_primary any_difficulty (ages25to29)"="At_least_primary any_difficulty (ages15to29)",
                         "At_least_primary nosome_difficulty (ages25to29)"="At_least_primary nosome_difficulty (ages15to29)",
                         "At_least_secondary no_difficulty (ages25to29)"="At_least_secondary no_difficulty (ages15to29)",
                         "At_least_secondary some_difficulty (ages25to29)"="At_least_secondary some_difficulty (ages15to29)",
                         "At_least_secondary atleast_alot_difficulty (ages25to29)"="At_least_secondary atleast_alot_difficulty (ages15to29)",
                         "At_least_secondary any_difficulty (ages25to29)"="At_least_secondary any_difficulty (ages15to29)",
                         "At_least_secondary nosome_difficulty (ages25to29)"="At_least_secondary nosome_difficulty (ages15to29)")
  
  db3 = tabs$tab_P2_nr %>% rename(disagg=Agg) %>% filter(!is.na(disagg),!disagg=="urban_new = 2") %>% 
    mutate(disagg = recode_factor(disagg,"All = All"="all_adults","female = 0"="males","female = 1"="females","urban_new = 0"="rural","urban_new = 1"="urban","age_group = 1"="ages15to29","age_group = 2"="ages30to44","age_group = 3"="ages45to64","age_group = 4"="ages65plus"))
  db3b = db3 %>% select(-ends_with("_mean"))
  db3 = db3 %>% select(-ends_with("_mean_se"))
  names(db3) = sub("_any_mean","",names(db3))
  names(db3b) = sub("_any_mean_se","",names(db3b))
  db3c = db3 %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db3[-c(1:3)])))
  db3d = db3b %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db3b[-c(1:3)])))

  db4 = tabs$tab_P3_nr %>% rename(disagg=Agg) %>% filter(!is.na(disagg),!disagg=="urban_new = 2") %>% 
    mutate(disagg = recode_factor(disagg,"All = All"="all_adults","female = 0"="males","female = 1"="females","urban_new = 0"="rural","urban_new = 1"="urban","age_group = 1"="ages15to29","age_group = 2"="ages30to44","age_group = 3"="ages45to64","age_group = 4"="ages65plus"))
  db4b = db4 %>% select(-ends_with("_mean"))
  db4 = db4 %>% select(-ends_with("_mean_se"))  
  names(db4) = c("disagg","admin","level","Household_Prevalence_any_difficulty","Household_Prevalence_some_difficulty","Household_Prevalence_atleast_alot_difficulty")
  names(db4b) = c("disagg","admin","level","Household_Prevalence_any_difficulty","Household_Prevalence_some_difficulty","Household_Prevalence_atleast_alot_difficulty")
  db4c = db4 %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db4[-c(1:3)])))
  db4d = db4b %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db4b[-c(1:3)])))
  
  db5 = tabs$tab_P4_nr %>% rename(disagg=domain) %>% filter(!disagg=="disability_any") %>% mutate(disagg = gsub("_any","",disagg))
  names(db5) = sub("everattended_new","Ever_attended_school",names(db5))
  names(db5) = sub("ind_atleastprimary","At_least_primary",names(db5))
  names(db5) = sub("ind_atleastsecondary","At_least_secondary",names(db5))
  names(db5) = sub("lit_new","Literacy_rate",names(db5))
  names(db5) = sub("computer","Computer_use",names(db5))
  names(db5) = sub("internet","Internet_use",names(db5))
  names(db5) = sub("mobile_own","Own_Mobile",names(db5))
  names(db5) = sub("ind_emp","Employment",names(db5))
  names(db5) = sub("youth_idle","Youth_idle_rate",names(db5))
  names(db5) = sub("work_manufacturing","Manufacturing_work",names(db5))
  names(db5) = sub("work_managerial","Managerial_work",names(db5))
  names(db5) = sub("work_informal","Informal_work",names(db5))
  names(db5) = sub("ind_water","Water",names(db5))
  names(db5) = sub("ind_toilet","Sanitation",names(db5))
  names(db5) = sub("fp_demsat_mod","Family_Planning_Met",names(db5))
  names(db5) = sub("anyviolence_byh_12m","Any_Violence",names(db5))
  names(db5) = sub("ind_electric","Electricity",names(db5))
  names(db5) = sub("ind_cleanfuel","Clean_fuel",names(db5))
  names(db5) = sub("ind_livingcond","Adequate_Housing",names(db5))
  names(db5) = sub("ind_asset_ownership","Share_assets_owned",names(db5))
  names(db5) = sub("cell_new","Household_Mobile_phone",names(db5))
  names(db5) = sub("health_insurance","Health_insurance",names(db5))
  names(db5) = sub("social_prot","Social_protection",names(db5))
  names(db5) = sub("food_insecure","Food_insecure",names(db5))
  names(db5) = sub("shock_any","Shock",names(db5))
  names(db5) = sub("health_exp_hh","Health_expenditures",names(db5))
  names(db5) = sub("ind_mdp","Multid_poverty",names(db5))
  
  db5b = db5 %>% select(-ends_with("_mean"))
  db5 = db5 %>% select(-ends_with("_mean_se"))
  names(db5) = sub("_mean$","",names(db5))
  names(db5b) = sub("_mean_se$","",names(db5b))
  db5c = db5 %>% pivot_wider(names_from = disagg, names_glue = "{.value} {disagg} (all_adults)",values_from = c(names(db5[-c(1:3)])))
  db5d = db5b %>% pivot_wider(names_from = disagg, names_glue = "{.value} {disagg} (all_adults)",values_from = c(names(db5b[-c(1:3)])))
  
  db_mean = full_join(full_join(full_join(full_join(db1c,db2c,by = c("admin","level")),db3c,by = c("admin","level")),db4c,by = c("admin","level")),db5c,by = c("admin","level"))
  db_se = full_join(full_join(full_join(full_join(db1d,db2d,by = c("admin","level")),db3d,by = c("admin","level")),db4d,by = c("admin","level")),db5d,by = c("admin","level"))
  rm(db1,db1b,db1c,db1d,db2,db2b,db2c,db2d,db3,db3b,db3c,db3d,db4,db4b,db4c,db4d,db5,db5b,db5c,db5d)

  rm(tabs)
  
  db_mean = db_mean |> select(names(db_mean)[names(db_mean) %in% {{order}}]) |> mutate(survey = svy,.before = admin1)
  db_admin1_se = db_admin1_se |> select(names(db_admin1_se)[names(db_admin1_se) %in% {{order}}]) |> mutate(survey = svy,.before = admin1)
  if(exists("db_admin2_mean")) {
  db_admin2_mean = db_admin2_mean |> select(names(db_admin2_mean)[names(db_admin2_mean) %in% {{order2}}]) |> mutate(survey = svy,.before = admin2)
  db_admin2_se = db_admin2_se |> select(names(db_admin2_se)[names(db_admin2_se) %in% {{order2}}]) |> mutate(survey = svy,.before = admin2)
  }
  
  db_mean[setdiff(order,names(db_mean))] = NA
  db_admin1_se[setdiff(order,names(db_admin1_se))] = NA
  if(exists("db_admin2_mean")) {
  db_admin2_mean[setdiff(order2,names(db_admin2_mean))] = NA
  db_admin2_se[setdiff(order2,names(db_admin2_se))] = NA
  }
  
  db_mean = db_mean %>% select({{order}})
  db_admin1_se = db_admin1_se %>% select({{order}})
  if(exists("db_admin2_mean")) {
  db_admin2_mean = db_admin2_mean %>% select({{order2}})
  db_admin2_se = db_admin2_se %>% select({{order2}})
  }
  
  db_admin0_mean = db_admin1_mean %>% filter(admin1 == "National") %>% select(-admin1) %>% mutate(date = as.character(today()), .after = "survey")
  db_admin0_se = db_admin1_se %>% filter(admin1 == "National") %>% select(-admin1) %>% mutate(date = as.character(today()), .after = "survey")
  db_admin1_mean = db_admin1_mean %>% filter(!admin1 == "National")
  db_admin1_se = db_admin1_se %>% filter(!admin1 == "National")
  if(exists("db_admin2_mean")) {
  db_admin2_mean = db_admin2_mean %>% filter(!admin2 == "National")
  db_admin2_se = db_admin2_se %>% filter(!admin2 == "National")
  }
  
  db_mean = db_mean %>% mutate(admin1 = stringi::stri_trans_general(sub('.\xba\xa1|.\xba\xa3|.\xba\xaf|.\xba\xb1|.\xba\xad','a',admin1,useBytes = TRUE) %>%
                                                                                    sub('.\xba\xbf|.\xbb\x87|.\xbb\x81','e',.,useBytes = TRUE) %>%
                                                                                    sub('.\xbb\x93|.\xbb\x91|.\xbb\x9b','o',.,useBytes = TRUE) %>%
                                                                                    sub('.\xbb\x8b','i',.,useBytes = TRUE) %>%
                                                                                    sub('.\xbb\xab','u',.,useBytes = TRUE),"latin-ASCII"))
  db_admin1_se = db_admin1_se %>% mutate(admin1 = stringi::stri_trans_general(sub('.\xba\xa1|.\xba\xa3|.\xba\xaf|.\xba\xb1|.\xba\xad','a',admin1,useBytes = TRUE) %>%
                                                                                sub('.\xba\xbf|.\xbb\x87|.\xbb\x81','e',.,useBytes = TRUE) %>%
                                                                                sub('.\xbb\x93|.\xbb\x91|.\xbb\x9b','o',.,useBytes = TRUE) %>%
                                                                                sub('.\xbb\x8b','i',.,useBytes = TRUE) %>%
                                                                                sub('.\xbb\xab','u',.,useBytes = TRUE),"latin-ASCII"))  
  if(exists("db_admin2_mean")) {
    db_admin2_mean = db_admin2_mean %>% mutate(admin2 = stringi::stri_trans_general(sub('.\xba\xa1|.\xba\xa3|.\xba\xaf|.\xba\xb1|.\xba\xad','a',admin2,useBytes = TRUE) %>%
                                                                                    sub('.\xba\xbf|.\xbb\x87|.\xbb\x81','e',.,useBytes = TRUE) %>%
                                                                                    sub('.\xbb\x93|.\xbb\x91|.\xbb\x9b','o',.,useBytes = TRUE) %>%
                                                                                    sub('.\xbb\x8b','i',.,useBytes = TRUE) %>%
                                                                                    sub('.\xbb\xab','u',.,useBytes = TRUE),"latin-ASCII"))
    db_admin2_se = db_admin2_se %>% mutate(admin2 = stringi::stri_trans_general(sub('.\xba\xa1|.\xba\xa3|.\xba\xaf|.\xba\xb1|.\xba\xad','a',admin2,useBytes = TRUE) %>%
                                                                                  sub('.\xba\xbf|.\xbb\x87|.\xbb\x81','e',.,useBytes = TRUE) %>%
                                                                                  sub('.\xbb\x93|.\xbb\x91|.\xbb\x9b','o',.,useBytes = TRUE) %>%
                                                                                  sub('.\xbb\x8b','i',.,useBytes = TRUE) %>%
                                                                                  sub('.\xbb\xab','u',.,useBytes = TRUE),"latin-ASCII"))
    }

  save(db_mean,db_se,file = paste0(db_loc,svy,".RData"),compress = "xz")

  # write.xlsx(db_admin1_se,paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output.xlsx"),"Standard Errors", append = TRUE)
  # write.xlsx(db_admin2_mean,paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"),"Means")
  # write.xlsx(db_admin2_se,paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"),"Standard Errors", append = TRUE)
  # mean1 = full_join(mean1,db_admin1_mean, by = names(mean1))
  # se1 = full_join(se1,db_admin1_se, by = names(se1))
  # mean2 = full_join(mean2,db_admin2_mean, by = names(mean2))
  # se2 = full_join(se2,db_admin2_se, by = names(se2))
  
  if(exists("db_admin2_mean")) {
  rm(ind_a,db_admin0_mean,db_admin0_se,db_admin1_mean,db_admin1_se,db_admin2_mean,db_admin2_se,temp0,temp1,temp2)
  } else {
  rm(ind_a,db_admin0_mean,db_admin0_se,db_admin1_mean,db_admin1_se,temp0,temp1) 
  }
  gc()
  merged
}

db_admin0_mean = merged %>% filter(admin == "0", output == "mean") %>% select(-c(1,2)) %>% mutate(date = today())
db_admin0_se = merged %>% filter(admin == "0", output == "se") %>% select(-c(1,2)) %>% mutate(date = today())
db_admin1_mean = merged %>% filter(admin == "1", output == "mean") %>% select(-c(1,2)) %>% rename("admin1"="date")
db_admin1_se = merged %>% filter(admin == "1", output == "se") %>% select(-c(1,2)) %>% rename("admin1"="date")
db_admin2_mean = merged %>% filter(admin == "2", output == "mean") %>% select(-c(1,2)) %>% rename("admin2"="date")
db_admin2_se = merged %>% filter(admin == "2", output == "se") %>% select(-c(1,2)) %>% rename("admin2"="date")

if(exists("db_admin0_mean")&nrow(db_admin0_mean)>0) {
  db_admin0_mean = full_join(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"),"Means"),db_admin0_mean, by = names(db_admin0_mean)) %>% arrange(survey) %>% filter(!survey=="Test")
  db_admin0_se = full_join(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"),"Standard Errors"),db_admin0_se, by = names(db_admin0_se)) %>% arrange(survey) %>% filter(!survey=="Test")
} else {
  rm(db_admin0_mean,db_admin0_se)
}
if(exists("db_admin1_mean")&nrow(db_admin1_mean)>0) {
  db_admin1_mean = full_join(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"),"Means"),db_admin1_mean, by = names(db_admin1_mean)) %>% arrange(survey,admin1) %>% filter(!survey=="Test")
  db_admin1_se = full_join(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"),"Standard Errors"),db_admin1_se, by = names(db_admin1_se)) %>% arrange(survey,admin1) %>% filter(!survey=="Test")
} else {
  rm(db_admin1_mean,db_admin1_se)
}
if(exists("db_admin2_mean")&nrow(db_admin2_mean)>0) {
  db_admin2_mean = full_join(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"),"Means"),db_admin2_mean, by = names(db_admin2_mean)) %>% arrange(survey,admin2) %>% filter(!survey=="Test")
  db_admin2_se = full_join(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"),"Standard Errors"),db_admin2_se, by = names(db_admin2_se)) %>% arrange(survey,admin2) %>% filter(!survey=="Test")
} else {
  rm(db_admin2_mean,db_admin2_se)
}

if(exists("db_admin0_mean")) {
  file.remove(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"))
}
if(exists("db_admin1_mean")) {
  file.remove(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"))
}
if(exists("db_admin2_mean")) {
  file.remove(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"))
}

if(exists("db_admin0_mean")) {
  write_xlsx(list("Means" = db_admin0_mean, "Standard Errors" = db_admin0_se),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"))
}
if(exists("db_admin1_mean")) {
  write_xlsx(list("Means" = db_admin1_mean, "Standard Errors" = db_admin1_se),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"))
}
if(exists("db_admin2_mean")) {
  write_xlsx(list("Means" = db_admin2_mean, "Standard Errors" = db_admin2_se),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"))
}

rm(merged,db_admin0_mean,db_admin0_se,db_admin1_mean,db_admin1_se,db_admin2_mean,db_admin2_se,mean1,com_list,order,order2,run_list,sum_list,sum_list2,svy_list)

admin1_m = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"),"Means")
admin1_se = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"),"Standard Errors")

chk_list = dir(db_loc)
chk_list = chk_list[grep("\\.RData",chk_list)]
val_list = dir(paste0(cen_dir,"Downloads/Census/Database/Individual/"))
val_list2 = sub("\\.xlsx","\\.RData",sub("Wide_Table_Output_","",val_list))
chk_list2 = chk_list[!chk_list %in% val_list2]

foreach(chk = chk_list2) %do% {
  load(paste0(db_loc,chk))
  write_xlsx(list("Means" = db_admin1_mean, "Standard Errors" = db_admin1_se),paste0(cen_dir,"Downloads/Census/Database/Individual/Wide_Table_Output_",sub("\\.RData","",chk),".xlsx"))
}

rm(db_loc,admin1_m,admin1_se,chk,chk_list,chk_list2,db_admin0_mean,db_admin0_se,db_admin1_mean,db_admin1_se,db_admin2_mean,db_admin2_se,val_list,val_list2)
gc()

drive_auth("bradley.carpenter@mrc.ac.za")
file.remove(paste0(cen_dir,"Downloads/Census/Dataset list.xlsx"))
drive_download(file = "https://docs.google.com/spreadsheets/d/1rCcLMLu4eaakTW76it5vojo6o2Z6Nxzy/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
               path = paste0(cen_dir,"Downloads/Census/Dataset list.xlsx"),overwrite = TRUE)
temp2 = read_xlsx(paste0(cen_dir,"Downloads/Census/Dataset list.xlsx"),"Sheet1",.name_repair = function(x) {gsub(" ","_",gsub("-","",x))})
temp2 = temp2 |> select(File_Name,Subnational_1_feasible,Subnational_2_feasible) %>% arrange(File_Name)

file.remove(paste0(cen_dir,"Downloads/Census/Countries with more than one dataset.xlsx"))
drive_download(file = "https://docs.google.com/spreadsheets/d/1JXb5Y5mRSn7UI9I7uoHTfaGDpYKh1Fcd/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
               path = paste0(cen_dir,"Downloads/Census/Countries with more than one dataset.xlsx"),overwrite = TRUE)
temp3 = read_xlsx(paste0(cen_dir,"Downloads/Census/Countries with more than one dataset.xlsx"),"Extraction") %>% arrange(`File name`)
temp3 = temp3 %>% mutate(across(dis_a:Multid_poverty,~as.numeric(ifelse(.x=="x"|.x=="X",NA,.x))))

temp4 = temp3 %>% filter(dis_a==1) %>% select(Country,Survey,`File name`)

# temp2 |> filter((!(Subnational_1_feasible=="X" | Subnational_1_feasible=="x") | !(Subnational_2_feasible=="X" | Subnational_2_feasible=="x") | is.na(Subnational_1_feasible) | is.na(Subnational_2_feasible)) & File_Name %in% temp3$`File name`)
# Build check for ineligible 1's that have alternative data

admin0_m = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"),"Means")
admin1_m = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"),"Means")
admin2_m = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"),"Means")
admin0_se = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"),"Standard Errors")
admin1_se = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"),"Standard Errors")
admin2_se = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"),"Standard Errors")

multicountry = bind_cols(temp3 %>% select(`File name`), rep(temp3 %>% select(dis_a),27), rep(temp3 %>% select(dom_a),54), rep(temp3 %>% select(Household_Prevalence),9), rep(temp3 %>% select(Ever_attended_school:Multid_poverty),each=51),.name_repair = "minimal")
names(multicountry) = names(admin0_m)[-2]
multicountry = multicountry %>% filter(survey %in% admin0_m$survey)

admin0_mb = admin0_m %>% filter(survey %in% temp2$File_Name)
admin1_mb = admin1_m %>% filter(survey %in% temp2$File_Name[temp2$Subnational_1_feasible=="X"|temp2$Subnational_1_feasible=="x"]) %>%
                         filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                         mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)
admin2_mb = admin2_m %>% filter(survey %in% temp2$File_Name[temp2$Subnational_2_feasible=="X"|temp2$Subnational_2_feasible=="x"]) %>%
                         filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                         mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)

admin0_seb = admin0_se %>% filter(survey %in% temp2$File_Name)
admin1_seb = admin1_se %>% filter(survey %in% temp2$File_Name[temp2$Subnational_1_feasible=="X"|temp2$Subnational_1_feasible=="x"]) %>%
                           filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                           mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)
admin2_seb = admin2_se %>% filter(survey %in% temp2$File_Name[temp2$Subnational_2_feasible=="X"|temp2$Subnational_2_feasible=="x"]) %>%
                           filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                           mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)

rm(admin0_m,admin1_m,admin2_m,admin0_se,admin1_se,admin2_se)

admin0_seb = admin0_seb %>% mutate(across(!survey&where(is.character),~as.numeric(if_else(.x=="Inf",NA,.x))))

admin0_mc = admin0_mb %>% filter(survey %in% temp3$`File name`)
admin0_mb = admin0_mb %>% filter(!survey %in% temp3$`File name`)
admin0_sec = admin0_seb %>% filter(survey %in% temp3$`File name`)
admin0_seb = admin0_seb %>% filter(!survey %in% temp3$`File name`)
# admin1_mc = admin1_mb %>% filter(survey %in% temp3$`File name`)
# admin1_mb = admin1_mb %>% filter(!survey %in% temp3$`File name`)
# admin1_sec = admin1_seb %>% filter(survey %in% temp3$`File name`)
# admin1_seb = admin1_seb %>% filter(!survey %in% temp3$`File name`)
# admin2_mc = admin2_mb %>% filter(survey %in% temp3$`File name`)
# admin2_mb = admin2_mb %>% filter(!survey %in% temp3$`File name`)
# admin2_sec = admin2_seb %>% filter(survey %in% temp3$`File name`)
# admin2_seb = admin2_seb %>% filter(!survey %in% temp3$`File name`)

temp5 = bind_cols(admin0_mc[1:2],admin0_mc[3:1469] %>% as.matrix() * multicountry[2:1468] %>% as.matrix())
temp6 = bind_cols(admin0_sec[1:2],admin0_sec[3:1469] %>% as.matrix() * multicountry[2:1468] %>% as.matrix())
temp5 = temp5 %>% mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)
temp6 = temp6 %>% mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)
admin0_mc = temp5 %>% group_by(country) %>% summarise(date = min(date),across(`any_difficulty (all_adults)`:`Multid_poverty communicating (all_adults)`,~ifelse(sum(!is.na(.x))==1,na.omit(.x),NA)))
admin0_sec = temp6 %>% group_by(country) %>% summarise(date = min(date),across(`any_difficulty (all_adults)`:`Multid_poverty communicating (all_adults)`,~ifelse(sum(!is.na(.x))==1,na.omit(.x),NA)))
admin0_mb = admin0_mb %>% mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)
admin0_seb = admin0_seb %>% mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)

admin0_mb = full_join(admin0_mb,admin0_mc,by = names(admin0_mb)) %>% arrange(country)
admin0_seb = full_join(admin0_seb,admin0_sec,by = names(admin0_mb)) %>% arrange(country)

rm(admin0_mc,admin0_sec,temp2,temp3,temp4,temp5,temp6,multicountry)

# Use locations from excel to identify blocks of values to assign into ordered list

#admin1_m |> mutate(country = str_extract(string=survey,pattern = "^.+?(?=_)")) |> group_by(country) | > mutate(n = length(unique(survey)))
if(file.exists(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0_reduced.xlsx"))) {
file.remove(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0_reduced.xlsx"),
            paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1_reduced.xlsx"),
            paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2_reduced.xlsx"))
  }
write_xlsx(list("Means" = admin0_mb, "Standard Errors" = admin0_seb),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0_reduced.xlsx"))
write_xlsx(list("Means" = admin1_mb, "Standard Errors" = admin1_seb),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1_reduced.xlsx"))
write_xlsx(list("Means" = admin2_mb, "Standard Errors" = admin2_seb),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2_reduced.xlsx"))

rm(admin0_mb,admin1_mb,admin2_mb,admin0_seb,admin1_seb,admin2_seb)
gc()

# temp0_m = admin0_mb %>% mutate(survey = substr(survey,1,str_locate(survey,"_")-1)) %>% rename(country=survey)
# temp0_se = admin0_seb %>% mutate(survey = substr(survey,1,str_locate(survey,"_")-1)) %>% rename(country=survey)
# temp1_m = admin1_mb %>% mutate(survey = substr(survey,1,str_locate(survey,"_")-1)) %>% rename(country=survey)
# temp1_se = admin1_seb %>% mutate(survey = substr(survey,1,str_locate(survey,"_")-1)) %>% rename(country=survey)
# temp2_m = admin2_mb %>% mutate(survey = substr(survey,1,str_locate(survey,"_")-1)) %>% rename(country=survey)
# temp2_se = admin2_seb %>% mutate(survey = substr(survey,1,str_locate(survey,"_")-1)) %>% rename(country=survey)
# write_xlsx(list("Means" = temp0_m, "Standard Errors" = temp0_se),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0_reduced.xlsx"))
# write_xlsx(list("Means" = temp1_m, "Standard Errors" = temp1_se),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1_reduced.xlsx"))
# write_xlsx(list("Means" = temp2_m, "Standard Errors" = temp2_se),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2_reduced.xlsx"))
# rm(temp0_m,temp0_se,temp1_m,temp1_se,temp2_m,temp2_se)

# writeWorksheet(wb1,mean1,"Means")
# writeWorksheet(wb1,se1,"Standard Errors")
# writeWorksheet(wb2,mean2,"Means")
# writeWorksheet(wb2,se2,"Standard Errors")
# saveWorkbook(wb1)
# saveWorkbook(wb2)
# rm(wb1,wb2)
