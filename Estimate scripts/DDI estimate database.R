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

if(!file.exists(paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means.xlsx"))) {
  file.copy(paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means - Copy.xlsx"),paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means.xlsx"))
  file.copy(paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means - Copy.xlsx"),paste0(cen_dir,"Downloads/Census/Database/S4_All_Estimates_SE.xlsx"))
}

mean1 = read_xlsx(path = paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means.xlsx"))

order = unique(c("survey","admin","level",names(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Order.xlsx"),sheet = "Sheet1",range = "C1:BDM1"))))
order = gsub("  "," ",order)

#Check for unprocessed summaries
sum_list = dir(paste0(cen_dir,"Downloads/Census/Summaries/"))
sum_list2 = str_extract(sum_list,".*_.*_[0-9]{4}")
com_list = unique(mean1$survey)
run_list = sum_list[!sum_list2 %in% com_list]
svy_list = sum_list2[!sum_list2 %in% com_list]

#Needs refinement
# check = foreach(file = run_list, svy = svy_list,.verbose = FALSE , .options.future = list(packages = c("tidyverse","haven")), .combine = "rbind") %dofuture% {
#   load(paste0(paste0(cen_dir,"Downloads/Census/Summaries/",file))
#   tabs$tab_m_nr[[1]][[1]] |> summarise(across(everything(),~mode(.x))) |> mutate(svy = svy,.before = admin)
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
  db1b = db1 %>% select(-ends_with("_mean")) %>% rename("disability"=disability_any_mean_se,"moderate_disability"=disability_some_mean_se, "severe_disability"=disability_atleast_mean_se)
  db1 = db1 %>% select(-ends_with("_mean_se")) %>% rename("disability"=disability_any_mean,"moderate_disability"=disability_some_mean, "severe_disability"=disability_atleast_mean)
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
  names(db2) = sub("_mean_no_l"," noandmoderate_disability",names(db2))
  names(db2) = sub("_mean_any"," disability",names(db2))
  names(db2) = sub("_mean_no"," no_disability",names(db2))
  names(db2) = sub("_mean_some"," moderate_disability",names(db2))
  names(db2) = sub("_mean_atleast"," severe_disability",names(db2))
  names(db2b) = sub("_mean_se_no_l"," noandmoderate_disability",names(db2b))
  names(db2b) = sub("_mean_se_any"," disability",names(db2b))
  names(db2b) = sub("_mean_se_no"," no_disability",names(db2b))
  names(db2b) = sub("_mean_se_some"," moderate_disability",names(db2b))
  names(db2b) = sub("_mean_se_atleast"," severe_disability",names(db2b))
  
  db2c = db2 %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db2[-c(1:3)])))
  db2d = db2b %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db2b[-c(1:3)])))
  db2c = db2c %>% rename("At_least_primary no_disability (ages25to29)"="At_least_primary no_disability (ages15to29)",
                         "At_least_primary moderate_disability (ages25to29)"="At_least_primary moderate_disability (ages15to29)",
                         "At_least_primary severe_disability (ages25to29)"="At_least_primary severe_disability (ages15to29)",
                         "At_least_primary disability (ages25to29)"="At_least_primary disability (ages15to29)",
                         "At_least_primary noandmoderate_disability (ages25to29)"="At_least_primary noandmoderate_disability (ages15to29)",
                         "At_least_secondary no_disability (ages25to29)"="At_least_secondary no_disability (ages15to29)",
                         "At_least_secondary moderate_disability (ages25to29)"="At_least_secondary moderate_disability (ages15to29)",
                         "At_least_secondary severe_disability (ages25to29)"="At_least_secondary severe_disability (ages15to29)",
                         "At_least_secondary disability (ages25to29)"="At_least_secondary disability (ages15to29)",
                         "At_least_secondary noandmoderate_disability (ages25to29)"="At_least_secondary noandmoderate_disability (ages15to29)")
  db2d = db2d %>% rename("At_least_primary no_disability (ages25to29)"="At_least_primary no_disability (ages15to29)",
                         "At_least_primary moderate_disability (ages25to29)"="At_least_primary moderate_disability (ages15to29)",
                         "At_least_primary severe_disability (ages25to29)"="At_least_primary severe_disability (ages15to29)",
                         "At_least_primary disability (ages25to29)"="At_least_primary disability (ages15to29)",
                         "At_least_primary noandmoderate_disability (ages25to29)"="At_least_primary noandmoderate_disability (ages15to29)",
                         "At_least_secondary no_disability (ages25to29)"="At_least_secondary no_disability (ages15to29)",
                         "At_least_secondary moderate_disability (ages25to29)"="At_least_secondary moderate_disability (ages15to29)",
                         "At_least_secondary severe_disability (ages25to29)"="At_least_secondary severe_disability (ages15to29)",
                         "At_least_secondary disability (ages25to29)"="At_least_secondary disability (ages15to29)",
                         "At_least_secondary noandmoderate_disability (ages25to29)"="At_least_secondary noandmoderate_disability (ages15to29)")
  
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
  names(db4) = c("disagg","admin","level","Household_Prevalence_disability","Household_Prevalence_moderate_disability","Household_Prevalence_severe_disability")
  names(db4b) = c("disagg","admin","level","Household_Prevalence_disability","Household_Prevalence_moderate_disability","Household_Prevalence_severe_disability")
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
  db5c = db5 %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db5[-c(1:3)])))
  db5d = db5b %>% pivot_wider(names_from = disagg, names_glue = "{.value} ({disagg})",values_from = c(names(db5b[-c(1:3)])))
  
  db_mean = full_join(full_join(full_join(full_join(db1c,db2c,by = c("admin","level")),db3c,by = c("admin","level")),db4c,by = c("admin","level")),db5c,by = c("admin","level"))
  db_se = full_join(full_join(full_join(full_join(db1d,db2d,by = c("admin","level")),db3d,by = c("admin","level")),db4d,by = c("admin","level")),db5d,by = c("admin","level"))
  rm(db1,db1b,db1c,db1d,db2,db2b,db2c,db2d,db3,db3b,db3c,db3d,db4,db4b,db4c,db4d,db5,db5b,db5c,db5d,tabs)

  db_mean = db_mean |> select(names(db_mean)[names(db_mean) %in% {{order}}]) |> mutate(survey = svy,.before = "admin")
  db_se = db_se |> select(names(db_se)[names(db_se) %in% {{order}}]) |> mutate(survey = svy,.before = "admin")

  db_mean[setdiff(order,names(db_mean))] = NA
  db_se[setdiff(order,names(db_se))] = NA
  
  db_mean = db_mean %>% select({{order}})
  db_se = db_se %>% select({{order}})

  db_mean = db_mean %>% mutate(level = stringi::stri_trans_general(sub('.\xba\xa1|.\xba\xa3|.\xba\xaf|.\xba\xb1|.\xba\xad','a',level,useBytes = TRUE) %>%
                                                                      sub('.\xba\xbf|.\xbb\x87|.\xbb\x81','e',.,useBytes = TRUE) %>%
                                                                      sub('.\xbb\x93|.\xbb\x91|.\xbb\x9b','o',.,useBytes = TRUE) %>%
                                                                      sub('.\xbb\x8b','i',.,useBytes = TRUE) %>%
                                                                      sub('.\xbb\xab','u',.,useBytes = TRUE),"latin-ASCII"))
  db_se = db_se %>% mutate(level = stringi::stri_trans_general(sub('.\xba\xa1|.\xba\xa3|.\xba\xaf|.\xba\xb1|.\xba\xad','a',level,useBytes = TRUE) %>%
                                                                  sub('.\xba\xbf|.\xbb\x87|.\xbb\x81','e',.,useBytes = TRUE) %>%
                                                                  sub('.\xbb\x93|.\xbb\x91|.\xbb\x9b','o',.,useBytes = TRUE) %>%
                                                                  sub('.\xbb\x8b','i',.,useBytes = TRUE) %>%
                                                                  sub('.\xbb\xab','u',.,useBytes = TRUE),"latin-ASCII"))
  
  db_mean = db_mean %>% mutate(across((contains("managerial")&contains("adults"))|contains("Managerial_work ("),~as.double(NA)))
  db_se = db_se %>% mutate(across((contains("managerial")&contains("adults"))|contains("Managerial_work ("),~as.double(NA)))

  save(db_mean,db_se,file = paste0(db_loc,svy,".RData"),compress = "xz")
  
  db = bind_rows(list(mean = db_mean, se = db_se),.id = "output")
  
  rm(ind_a,db_mean,db_se)
  gc()
  db
}

#Split database into two (Mean vs SE)
db_mean = merged %>% filter(output == "mean") %>% select(-1)
db_se = merged %>% filter(output == "se") %>% select(-1)

db_mean = full_join(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means.xlsx")),db_mean, by = names(db_mean)) %>% arrange(survey) %>% filter(!survey=="Test")
db_se = full_join(read_xlsx(paste0(cen_dir,"Downloads/Census/Database/S4_All_Estimates_SE.xlsx")),db_se, by = names(db_se)) %>% arrange(survey) %>% filter(!survey=="Test")

db_se = db_se %>% mutate(across(!survey&!admin&!level,~if_else(.x=="Inf",NA,.x))) %>% mutate(across(!survey&!admin&!level&where(is.character),~as.numeric(.x)))

file.remove(paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means.xlsx"))
file.remove(paste0(cen_dir,"Downloads/Census/Database/S4_All_Estimates_SE.xlsx"))

write_xlsx(db_mean,paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means.xlsx"))
write_xlsx(db_se,paste0(cen_dir,"Downloads/Census/Database/S4_All_Estimates_SE.xlsx"))

rm(merged,db_mean,db_se,mean1,com_list,order,sum_list,sum_list2,svy_list)

db_m = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means.xlsx"))
db_s = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/S4_All_Estimates_SE.xlsx"))

chk_list = dir(db_loc)
chk_list = chk_list[grep("\\.RData",chk_list)]
val_list = dir(paste0(cen_dir,"Downloads/Census/Database/Individual/"))
val_list2 = sub("\\.xlsx","\\.RData",sub("Wide_Table_Output_","",val_list))
chk_list2 = chk_list[!chk_list %in% val_list2]

foreach(chk = chk_list2) %do% {
  load(paste0(db_loc,chk))
  write_xlsx(list("Means" = db_mean, "Standard Errors" = db_se),paste0(cen_dir,"Downloads/Census/Database/Individual/Wide_Table_Output_",sub("\\.RData","",chk),".xlsx"))
}

rm(db_loc,db_m,db_s,chk,chk_list,chk_list2,val_list,val_list2)
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

temp3b = temp3
names(temp3b) = sub("everattended_new","Ever_attended_school",names(temp3b))
names(temp3b) = sub("ind_atleastprimary","At_least_primary",names(temp3b))
names(temp3b) = sub("ind_atleastsecondary","At_least_secondary",names(temp3b))
names(temp3b) = sub("lit_new","Literacy_rate",names(temp3b))
names(temp3b) = sub("computer","Computer_use",names(temp3b))
names(temp3b) = sub("internet","Internet_use",names(temp3b))
names(temp3b) = sub("mobile_own","Own_Mobile",names(temp3b))
names(temp3b) = sub("ind_emp","Employment",names(temp3b))
names(temp3b) = sub("youth_idle","Youth_idle_rate",names(temp3b))
names(temp3b) = sub("work_manufacturing","Manufacturing_work",names(temp3b))
names(temp3b) = sub("work_managerial","Managerial_work",names(temp3b))
names(temp3b) = sub("work_informal","Informal_work",names(temp3b))
names(temp3b) = sub("ind_water","Water",names(temp3b))
names(temp3b) = sub("ind_toilet","Sanitation",names(temp3b))
names(temp3b) = sub("fp_demsat_mod","Family_Planning_Met",names(temp3b))
names(temp3b) = sub("anyviolence_byh_12m","Any_Violence",names(temp3b))
names(temp3b) = sub("ind_electric","Electricity",names(temp3b))
names(temp3b) = sub("ind_cleanfuel","Clean_fuel",names(temp3b))
names(temp3b) = sub("ind_livingcond","Adequate_Housing",names(temp3b))
names(temp3b) = sub("ind_asset_ownership","Share_assets_owned",names(temp3b))
names(temp3b) = sub("cell_new","Household_Mobile_phone",names(temp3b))
names(temp3b) = sub("health_insurance","Health_insurance",names(temp3b))
names(temp3b) = sub("social_prot","Social_protection",names(temp3b))
names(temp3b) = sub("food_insecure","Food_insecure",names(temp3b))
names(temp3b) = sub("shock_any","Shock",names(temp3b))
names(temp3b) = sub("health_exp_hh","Health_expenditures",names(temp3b))
names(temp3b) = sub("ind_mdp","Multid_poverty",names(temp3b))

# temp2 |> filter((!(Subnational_1_feasible=="X" | Subnational_1_feasible=="x") | !(Subnational_2_feasible=="X" | Subnational_2_feasible=="x") | is.na(Subnational_1_feasible) | is.na(Subnational_2_feasible)) & File_Name %in% temp3$`File name`)
# Build check for ineligible 1's that have alternative data

db_m = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/S3_All_Estimates_Means.xlsx"))
db_s = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/S4_All_Estimates_SE.xlsx"))

admin0_m = db_m %>% filter(admin == "admin0") %>% select(-admin)
admin1_m = db_m %>% filter(admin == "admin1") %>% select(-admin)
admin2_m = db_m %>% filter(admin == "admin2") %>% select(-admin)
admina_m = db_m %>% filter(admin == "admin_alt") %>% select(-admin)
admin0_se = db_s %>% filter(admin == "admin0") %>% select(-admin)
admin1_se = db_s %>% filter(admin == "admin1") %>% select(-admin)
admin2_se = db_s %>% filter(admin == "admin2") %>% select(-admin)
admina_se = db_s %>% filter(admin == "admin_alt") %>% select(-admin)

multicountry = bind_cols(temp3 %>% select(`File name`), rep(temp3 %>% select(dis_a),27), rep(temp3 %>% select(dom_a),54), rep(temp3 %>% select(Household_Prevalence),9), rep(temp3 %>% select(Ever_attended_school:Multid_poverty),each=51),.name_repair = "minimal")
names(multicountry) = names(admin0_m)[-2]
multicountry = multicountry %>% filter(survey %in% admin0_m$survey)

admin0_mb = admin0_m %>% filter(survey %in% temp2$File_Name) %>% rename(country=survey)
admin1_mb = admin1_m %>% filter(survey %in% temp2$File_Name[temp2$Subnational_1_feasible=="X"|temp2$Subnational_1_feasible=="x"]) %>%
                         filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                         mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)
admin2_mb = admin2_m %>% filter(survey %in% temp2$File_Name[temp2$Subnational_2_feasible=="X"|temp2$Subnational_2_feasible=="x"]) %>%
                         filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                         mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)
admina_mb = admina_m %>% filter(survey %in% temp2$File_Name) %>% filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                         mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)

admin0_seb = admin0_se %>% filter(survey %in% temp2$File_Name) %>% rename(country=survey)
admin1_seb = admin1_se %>% filter(survey %in% temp2$File_Name[temp2$Subnational_1_feasible=="X"|temp2$Subnational_1_feasible=="x"]) %>%
                           filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                           mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)
admin2_seb = admin2_se %>% filter(survey %in% temp2$File_Name[temp2$Subnational_2_feasible=="X"|temp2$Subnational_2_feasible=="x"]) %>%
                           filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                           mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)
admina_seb = admina_se %>% filter(survey %in% temp2$File_Name) %>% filter(!survey %in% temp3$`File name`|survey %in% temp4$`File name`) %>%
                           mutate(survey = str_extract(survey,".+?(?=_)")) %>% rename(country=survey)

rm(admin0_m,admin1_m,admin2_m,admina_m,admin0_se,admin1_se,admin2_se,admina_se)

admin0_mc = admin0_mb %>% filter(country %in% temp3$`File name`)
admin0_mb = admin0_mb %>% filter(!country %in% temp3$`File name`)
admin0_sec = admin0_seb %>% filter(country %in% temp3$`File name`)
admin0_seb = admin0_seb %>% filter(!country %in% temp3$`File name`)
# admin1_mc = admin1_mb %>% filter(country %in% temp3$`File name`)
# admin1_mb = admin1_mb %>% filter(!country %in% temp3$`File name`)
# admin1_sec = admin1_seb %>% filter(country %in% temp3$`File name`)
# admin1_seb = admin1_seb %>% filter(!country %in% temp3$`File name`)
# admin2_mc = admin2_mb %>% filter(country %in% temp3$`File name`)
# admin2_mb = admin2_mb %>% filter(!country %in% temp3$`File name`)
# admin2_sec = admin2_seb %>% filter(country %in% temp3$`File name`)
# admin2_seb = admin2_seb %>% filter(!country %in% temp3$`File name`)

temp5 = bind_cols(admin0_mc[1:2],admin0_mc[3:1469] %>% as.matrix() * multicountry[2:1468] %>% as.matrix())
temp6 = bind_cols(admin0_sec[1:2],admin0_sec[3:1469] %>% as.matrix() * multicountry[2:1468] %>% as.matrix())
temp5 = temp5 %>% mutate(country = str_extract(country,".+?(?=_)"))
temp6 = temp6 %>% mutate(country = str_extract(country,".+?(?=_)"))
admin0_mc = temp5 %>% group_by(country) %>% summarise(level = first(level),across(`disability (all_adults)`:`Multid_poverty (communicating)`,~ifelse(sum(!is.na(.x))==1,na.omit(.x),NA)))
admin0_sec = temp6 %>% group_by(country) %>% summarise(level = first(level),across(`disability (all_adults)`:`Multid_poverty (communicating)`,~ifelse(sum(!is.na(.x))==1,na.omit(.x),NA)))
admin0_mb = admin0_mb %>% mutate(country = str_extract(country,".+?(?=_)"))
admin0_seb = admin0_seb %>% mutate(country = str_extract(country,".+?(?=_)"))

admin0_mb = full_join(admin0_mb,admin0_mc,by = names(admin0_mb)) %>% arrange(country)
admin0_seb = full_join(admin0_seb,admin0_sec,by = names(admin0_mb)) %>% arrange(country)

rm(admin0_mc,admin0_sec,temp2,temp3,temp4,temp5,temp6,multicountry)

# Use locations from excel to identify blocks of values to assign into ordered list

db_mb = bind_rows(admin0 = admin0_mb,admin1 = admin1_mb,admin2 = admin2_mb,admin_alt = admina_mb, .id = "admin") %>% select(country,names(db_m)[-1]) %>% arrange(country,admin,level)
db_sb = bind_rows(admin0 = admin0_seb,admin1 = admin1_seb,admin2 = admin2_seb,admin_alt = admina_seb, .id = "admin") %>% select(country, names(db_s)[-1]) %>% arrange(country,admin,level)

if(file.exists(paste0(cen_dir,"Downloads/Census/Database/S1_Default_Estimates_Means.xlsx"))) {
file.remove(paste0(cen_dir,"Downloads/Census/Database/S2_Default_Estimates_SE.xlsx"))
}
write_xlsx(db_mb,paste0(cen_dir,"Downloads/Census/Database/S1_Default_Estimates_Means.xlsx"))
write_xlsx(db_sb,paste0(cen_dir,"Downloads/Census/Database/S2_Default_Estimates_SE.xlsx"))

rm(admin0_mb,admin1_mb,admin2_mb,admina_mb,admin0_seb,admin1_seb,admin2_seb,admina_seb)
gc()
