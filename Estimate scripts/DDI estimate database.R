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
cen_dir = str_extract(getwd(), "[cC]:\\/Users\\/.+?\\/")
db_loc = c(paste0(cen_dir, "Downloads/Census/Database/Backup/"))

if (
  !file.exists(paste0(
    cen_dir,
    "Downloads/Census/Database/DS_E2_All_Estimates.xlsx"
  ))
) {
  file.copy(
    paste0(
      cen_dir,
      "Downloads/Census/Database/DS_E2_All_Estimates - Copy.xlsx"
    ),
    paste0(cen_dir, "Downloads/Census/Database/DS_E2_All_Estimates.xlsx")
  )
}

mean1 = read_xlsx(
  path = paste0(cen_dir, "Downloads/Census/Database/DS_E2_All_Estimates.xlsx")
)

order = unique(c(
  "survey",
  "admin",
  "level",
  names(read_xlsx(
    paste0(cen_dir, "Downloads/Census/Database/Order.xlsx"),
    sheet = "Sheet1",
    range = "C1:BDM1"
  ))
))
order = gsub("  ", " ", order)

#Check for unprocessed summaries
sum_list = dir(paste0(cen_dir, "Downloads/Census/Summaries/"))
sum_list2 = str_extract(sum_list, ".*_.*_[0-9]{4}")
com_list = mean1 %>% select(Survey) %>% unique()
run_list = sum_list[!sum_list2 %in% com_list]
svy_list = sum_list2[!sum_list2 %in% com_list]

#Needs refinement
# check = foreach(file = run_list, svy = svy_list,.verbose = FALSE , .options.future = list(packages = c("tidyverse","haven")), .combine = "rbind") %dofuture% {
#   load(paste0(paste0(cen_dir,"Downloads/Census/Summaries/",file))
#   tabs$tab_m_nr[[1]][[1]] |> summarise(across(everything(),~mode(.x))) |> mutate(svy = svy,.before = admin)
# }

#Run analysis for unprocessed datasets
merged = foreach(
  file = run_list,
  svy = svy_list,
  .verbose = FALSE,
  .combine = "bind_rows",
  .options.future = list(packages = c("tidyverse", "haven"))
) %dofuture%
  {
    ##Load data file created by DDI summary calculations.R
    tabs = NULL
    load(paste0(cen_dir, "Downloads/Census/Summaries/", file))
    print(svy)

    ind_a = c(
      "everattended_new",
      "ind_atleastprimary",
      "ind_atleastsecondary",
      "lit_new",
      "computer",
      "internet",
      "mobile_own",
      "ind_emp",
      "youth_idle",
      "work_manufacturing",
      "work_managerial",
      "work_informal",
      "ind_water",
      "ind_toilet",
      "fp_demsat_mod",
      "anyviolence_byh_12m",
      "bmi",
      "overweight_obese",
      "child_died",
      "healthcare_prob",
      "death_hh",
      "alone",
      "ind_electric",
      "ind_cleanfuel",
      "ind_livingcond",
      "ind_asset_ownership",
      "cell_new",
      "health_insurance",
      "social_prot",
      "food_insecure",
      "shock_any",
      "health_exp_hh",
      "ind_mdp"
    )

    db1 = tabs$tab_P1_nr %>%
      rename(disagg = Agg) %>%
      filter(!is.na(disagg), !disagg == "urban_new = 2") %>%
      mutate(
        disagg = recode_factor(
          disagg,
          "All = All" = "all_adults",
          "female = 0" = "males",
          "female = 1" = "females",
          "urban_new = 0" = "rural",
          "urban_new = 1" = "urban",
          "age_group = 1" = "ages15to29",
          "age_group = 2" = "ages30to44",
          "age_group = 3" = "ages45to64",
          "age_group = 4" = "ages65plus"
        )
      )
    db2 = tabs$tab_m_nr %>%
      rename(disagg = Agg) %>%
      select(
        disagg,
        admin,
        level,
        ends_with("_no"),
        ends_with("_some"),
        ends_with("_atleast"),
        ends_with("_alot"),
        ends_with("_unable"),
        ends_with("any"),
        ends_with("no_l")
      ) %>%
      filter(!is.na(disagg), !disagg == "urban_new = 2") %>%
      mutate(
        disagg = recode_factor(
          disagg,
          "All = All" = "all_adults",
          "female = 0" = "males",
          "female = 1" = "females",
          "urban_new = 0" = "rural",
          "urban_new = 1" = "urban",
          "age_group = 1" = "ages15to29",
          "age_group = 2" = "ages30to44",
          "age_group = 3" = "ages45to64",
          "age_group = 4" = "ages65plus"
        )
      )
    db3 = tabs$tab_P2_nr %>%
      rename(disagg = Agg) %>%
      filter(!is.na(disagg), !disagg == "urban_new = 2") %>%
      mutate(
        disagg = recode_factor(
          disagg,
          "All = All" = "all_adults",
          "female = 0" = "males",
          "female = 1" = "females",
          "urban_new = 0" = "rural",
          "urban_new = 1" = "urban",
          "age_group = 1" = "ages15to29",
          "age_group = 2" = "ages30to44",
          "age_group = 3" = "ages45to64",
          "age_group = 4" = "ages65plus"
        )
      )
    db4 = tabs$tab_P3_nr %>%
      rename(disagg = Agg) %>%
      filter(!is.na(disagg), !disagg == "urban_new = 2") %>%
      mutate(
        disagg = recode_factor(
          disagg,
          "All = All" = "all_adults",
          "female = 0" = "males",
          "female = 1" = "females",
          "urban_new = 0" = "rural",
          "urban_new = 1" = "urban",
          "age_group = 1" = "ages15to29",
          "age_group = 2" = "ages30to44",
          "age_group = 3" = "ages45to64",
          "age_group = 4" = "ages65plus"
        )
      )
    db5 = tabs$tab_P4_nr %>%
      rename(disagg = domain) %>%
      filter(!disagg == "disability_any") %>%
      mutate(disagg = gsub("_any", "", disagg))

    names(db1) = sub("disability", "Prevalence disability", names(db1))
    names(db1) = sub("_mean", " mean", names(db1))
    names(db1) = sub("_n", " n", names(db1))
    names(db1) = sub("mean_se", "se", names(db1))
    names(db1) = sub("disability_any", "any_difficulty", names(db1))
    names(db1) = sub("disability_some", "some_difficulty", names(db1))
    names(db1) = sub("disability_alot", "alot_difficulty", names(db1))
    names(db1) = sub("disability_unable", "cannot_difficulty", names(db1))
    names(db1) = sub("disability_atleast", "alotcannot_difficulty", names(db1))

    names(db2) = sub("everattended_new_", "Ever_attended_school ", names(db2))
    names(db2) = sub("ind_atleastprimary_", "At_least_primary ", names(db2))
    names(db2) = sub("ind_atleastsecondary_", "At_least_secondary ", names(db2))
    names(db2) = sub("lit_new_", "Literacy_rate ", names(db2))
    names(db2) = sub("computer_", "Computer_use ", names(db2))
    names(db2) = sub("internet_", "Internet_use ", names(db2))
    names(db2) = sub("mobile_own_", "Own_Mobile ", names(db2))
    names(db2) = sub("ind_emp_", "Employment ", names(db2))
    names(db2) = sub("youth_idle_", "Youth_idle_rate ", names(db2))
    names(db2) = sub("work_manufacturing_", "Manufacturing_work ", names(db2))
    names(db2) = sub("work_managerial_", "Managerial_work ", names(db2))
    names(db2) = sub("work_informal_", "Informal_work ", names(db2))
    names(db2) = sub("ind_water_", "Water ", names(db2))
    names(db2) = sub("ind_toilet_", "Sanitation ", names(db2))
    names(db2) = sub("fp_demsat_mod_", "Family_Planning_Met ", names(db2))
    names(db2) = sub("anyviolence_byh_12m_", "Any_Violence ", names(db2))
    names(db2) = sub("bmi_", "BMI ", names(db2))
    names(db2) = sub("overweight_obese_", "Obese ", names(db2))
    names(db2) = sub("child_died_", "Child_died ", names(db2))
    names(db2) = sub("healthcare_prob_", "Healthcare_access ", names(db2))
    names(db2) = sub("death_hh_", "Household_Death ", names(db2))
    names(db2) = sub("alone_", "Living_alone ", names(db2))
    names(db2) = sub("ind_electric_", "Electricity ", names(db2))
    names(db2) = sub("ind_cleanfuel_", "Clean_fuel ", names(db2))
    names(db2) = sub("ind_livingcond_", "Adequate_Housing ", names(db2))
    names(db2) = sub("ind_asset_ownership_", "Share_assets_owned ", names(db2))
    names(db2) = sub("cell_new_", "Household_Mobile_phone ", names(db2))
    names(db2) = sub("health_insurance_", "Health_insurance ", names(db2))
    names(db2) = sub("social_prot_", "Social_protection ", names(db2))
    names(db2) = sub("food_insecure_", "Food_insecure ", names(db2))
    names(db2) = sub("shock_any_", "Shock ", names(db2))
    names(db2) = sub("health_exp_hh_", "Health_expenditures ", names(db2))
    names(db2) = sub("ind_mdp_", "Multid_poverty ", names(db2))
    names(db2) = sub("mean_se_", "se ", names(db2))
    names(db2) = sub("mean_", "mean ", names(db2))
    names(db2) = sub(" n_", " n ", names(db2))
    names(db2) = sub(
      "(.* )(.*)( )(.*)",
      "\\1\\4\\3\\2",
      names(db2),
      fixed = FALSE
    )
    names(db2) = sub(" no_l ", " nosome_difficulty ", names(db2))
    names(db2) = sub(" any ", " any_difficulty ", names(db2))
    names(db2) = sub(" no ", " no_difficulty ", names(db2))
    names(db2) = sub(" some ", " some_difficulty ", names(db2))
    names(db2) = sub(" atleast ", " alotcannot_difficulty ", names(db2))
    names(db2) = sub(" alot ", " alot_difficulty ", names(db2))
    names(db2) = sub(" unable ", " cannot_difficulty ", names(db2))

    names(db3) = sub("(.*)(_.*)", "Prevalence \\1\\2", names(db3))
    names(db3) = sub("_mean", " mean", names(db3))
    names(db3) = sub("_n", " n", names(db3))
    names(db3) = sub("mean_se", "se", names(db3))
    names(db3) = sub("_unable", "_cannot", names(db3))

    names(db4) = sub("(.*)(_.*)", "Household_Prevalence \\1\\2", names(db4))
    names(db4) = sub("_mean", " mean", names(db4))
    names(db4) = sub("_n", " n", names(db4))
    names(db4) = sub("mean_se", "se", names(db4))
    names(db4) = sub("disability_any", "any_difficulty", names(db4))
    names(db4) = sub("disability_some", "some_difficulty", names(db4))
    names(db4) = sub("disability_alot", "alot_difficulty", names(db4))
    names(db4) = sub("disability_unable", "cannot_difficulty", names(db4))
    names(db4) = sub("disability_atleast", "alotcannot_difficulty", names(db4))

    db5 = db5 %>%
      mutate(
        disagg = sub(
          "_unable",
          "_cannot",
          sub(
            "seeing$",
            "seeing_any",
            sub(
              "hearing$",
              "hearing_any",
              sub(
                "mobile$",
                "mobile_any",
                sub(
                  "cognition$",
                  "cognition_any",
                  sub(
                    "selfcare$",
                    "selfcare_any",
                    sub("communicating$", "communicating_any", disagg)
                  )
                )
              )
            )
          )
        )
      )
    db5 = db5 %>%
      pivot_wider(
        .,
        id_cols = names(.)[c(2:3)],
        names_from = disagg,
        names_glue = ,
        values_from = names(.)[-c(1:3)]
      ) %>%
      mutate(disagg = factor("all_adults"), .before = admin)
    names(db5) = sub("everattended_new_", "Ever_attended_school ", names(db5))
    names(db5) = sub("ind_atleastprimary_", "At_least_primary ", names(db5))
    names(db5) = sub("ind_atleastsecondary_", "At_least_secondary ", names(db5))
    names(db5) = sub("lit_new_", "Literacy_rate ", names(db5))
    names(db5) = sub("computer_", "Computer_use ", names(db5))
    names(db5) = sub("internet_", "Internet_use ", names(db5))
    names(db5) = sub("mobile_own_", "Own_Mobile ", names(db5))
    names(db5) = sub("ind_emp_", "Employment ", names(db5))
    names(db5) = sub("youth_idle_", "Youth_idle_rate ", names(db5))
    names(db5) = sub("work_manufacturing_", "Manufacturing_work ", names(db5))
    names(db5) = sub("work_managerial_", "Managerial_work ", names(db5))
    names(db5) = sub("work_informal_", "Informal_work ", names(db5))
    names(db5) = sub("ind_water_", "Water ", names(db5))
    names(db5) = sub("ind_toilet_", "Sanitation ", names(db5))
    names(db5) = sub("fp_demsat_mod_", "Family_Planning_Met ", names(db5))
    names(db5) = sub("anyviolence_byh_12m_", "Any_Violence ", names(db5))
    names(db5) = sub("bmi_", "BMI ", names(db5))
    names(db5) = sub("overweight_obese_", "Obese ", names(db5))
    names(db5) = sub("child_died_", "Child_died ", names(db5))
    names(db5) = sub("healthcare_prob_", "Healthcare_access ", names(db5))
    names(db5) = sub("death_hh_", "Household_Death ", names(db5))
    names(db5) = sub("alone_", "Living_alone ", names(db5))
    names(db5) = sub("ind_electric_", "Electricity ", names(db5))
    names(db5) = sub("ind_cleanfuel_", "Clean_fuel ", names(db5))
    names(db5) = sub("ind_livingcond_", "Adequate_Housing ", names(db5))
    names(db5) = sub("ind_asset_ownership_", "Share_assets_owned ", names(db5))
    names(db5) = sub("cell_new_", "Household_Mobile_phone ", names(db5))
    names(db5) = sub("health_insurance_", "Health_insurance ", names(db5))
    names(db5) = sub("social_prot_", "Social_protection ", names(db5))
    names(db5) = sub("food_insecure_", "Food_insecure ", names(db5))
    names(db5) = sub("shock_any_", "Shock ", names(db5))
    names(db5) = sub("health_exp_hh_", "Health_expenditures ", names(db5))
    names(db5) = sub("ind_mdp_", "Multid_poverty ", names(db5))
    names(db5) = sub("mean_se_", "se ", names(db5))
    names(db5) = sub("mean_", "mean ", names(db5))
    names(db5) = sub(" n_", " n ", names(db5))
    names(db5) = sub(
      "(.* )(.*)( )(.*)",
      "\\1\\4\\3\\2",
      names(db5),
      fixed = FALSE
    )
    join = join_by(disagg, admin, level)
    df = full_join(
      full_join(full_join(full_join(db1, db2, join), db3, join), db4, join),
      db5,
      join
    )
    rm(join)

    df = df %>%
      mutate(
        level = stringi::stri_trans_general(
          sub(
            '.\xba\xa1|.\xba\xa3|.\xba\xaf|.\xba\xb1|.\xba\xad',
            'a',
            level,
            useBytes = TRUE
          ) %>%
            sub('.\xba\xbf|.\xbb\x87|.\xbb\x81', 'e', ., useBytes = TRUE) %>%
            sub('.\xbb\x93|.\xbb\x91|.\xbb\x9b', 'o', ., useBytes = TRUE) %>%
            sub('.\xbb\x8b', 'i', ., useBytes = TRUE) %>%
            sub('.\xbb\xab', 'u', ., useBytes = TRUE),
          "latin-ASCII"
        )
      )
    df = df %>% mutate(Survey = svy, .before = disagg)

    df2 = df %>%
      pivot_longer(
        cols = names(.)[-c(1:4)],
        names_to = c("IndicatorName", "DifficultyName", ".value"),
        names_pattern = "(.*) (.*) (.*)"
      )

    #df2 = df2 %>% filter(!is.na(Survey),!is.na(disagg),!is.na(admin),!is.na(level),!is.na(IndicatorName),!is.na(DifficultyName))

    df2 = df2 %>%
      mutate(across(
        c(mean, se, n),
        ~ ifelse(
          disagg == "all_adults" &
            IndicatorName %in%
              c(
                "Youth_idle_rate",
                "Managerial_work",
                "Family_Planning_Met",
                "Any_Violence",
                "Healthcare_access",
                "BMI",
                "Obese"
              ),
          NA,
          .x
        )
      ))

    df2 = df2 %>%
      mutate(across(
        c(mean, se),
        ~ if_else(IndicatorName == "BMI", .x / 100, .x)
      ))

    write_rds(df2, file = paste0(db_loc, svy, ".rds"), compress = "xz")

    rm(ind_a, df)
    gc()
    return(df2)
  }

#Existing file merge
files = list.files(db_loc, "*.rds", full.names = TRUE)
merged = bind_rows(lapply(files, read_rds))

#Split database into two (Mean vs SE)
db = full_join(
  read_xlsx(paste0(
    cen_dir,
    "Downloads/Census/Database/DS_E2_All_Estimates.xlsx"
  )),
  merged,
  by = names(merged)
) %>%
  arrange(Survey) %>%
  filter(!Survey == "Test")

db = db %>% mutate(n = if_else(n == 0, NA, n))
db = db %>% mutate(across(c(mean, se), ~ round(.x, 3)))
db2 = db %>% filter(admin %in% c("admin0"))
db3 = db %>% filter(admin %in% c("admin0", "admin1"))

file.remove(paste0(
  cen_dir,
  c(
    "Downloads/Census/Database/DS_E2_All_Estimates.csv",
    "Downloads/Census/Database/DS_E2_All_Estimates_National.xlsx",
    "Downloads/Census/Database/DS_E2_All_Estimates_Admin1.xlsx"
  )
))

write_csv(
  db,
  paste0(cen_dir, "Downloads/Census/Database/DS_E2_All_Estimates.csv")
)

write_xlsx(
  db2,
  paste0(cen_dir, "Downloads/Census/Database/DS_E2_All_Estimates_National.xlsx")
)

write_csv(
  db3,
  paste0(cen_dir, "Downloads/Census/Database/DS_E2_All_Estimates_Admin1.csv")
)

rm(merged, db, mean1, com_list, order, sum_list, sum_list2, svy_list)

# db_m = read_xlsx(paste0(
#   cen_dir,
#   "Downloads/Census/Database/DS_E2_All_Estimates.xlsx"
# ))

# chk_list = dir(db_loc)
# chk_list = chk_list[grep("\\.RData", chk_list)]
# val_list = dir(paste0(cen_dir, "Downloads/Census/Database/Individual/"))
# val_list2 = sub("\\.xlsx", "\\.RData", sub("Wide_Table_Output_", "", val_list))
# chk_list2 = chk_list[!chk_list %in% val_list2]

# foreach(chk = chk_list2) %do%
#   {
#     load(paste0(db_loc, chk))
#     write_xlsx(
#       db_mean,
#       paste0(
#         cen_dir,
#         "Downloads/Census/Database/Individual/Wide_Table_Output_",
#         sub("\\.RData", "", chk),
#         ".xlsx"
#       )
#     )
#   }

# rm(db_mean, db_loc, db_m, db_s, chk, chk_list, chk_list2, val_list, val_list2)
# gc()

drive_auth("bradley.carpenter@mrc.ac.za")
file.remove(paste0(cen_dir, "Downloads/Census/Dataset list.xlsx"))
drive_download(
  file = "https://docs.google.com/spreadsheets/d/1vIsXVg8xlvJKXxonIggj04oQKsWV56aR/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
  path = paste0(cen_dir, "Downloads/Census/Dataset list.xlsx"),
  overwrite = TRUE
)
temp2 = read_xlsx(
  paste0(cen_dir, "Downloads/Census/Dataset list.xlsx"),
  "Sheet1",
  .name_repair = function(x) {
    gsub(" ", "_", gsub("-", "", x))
  }
)
temp2 = temp2 |>
  select(File_Name, Subnational_1_feasible, Subnational_2_feasible) %>%
  arrange(File_Name)

# file.remove(paste0(
#   cen_dir,
#   "Downloads/Census/Countries with more than one dataset.xlsx"
# ))
# drive_download(
#   file = "https://docs.google.com/spreadsheets/d/1WogcttawVdBur9wyTqUnZzkHvDMui0OP/edit?usp=drive_link&ouid=104552820408951429298&rtpof=true&sd=true",
#   path = paste0(
#     cen_dir,
#     "Downloads/Census/Countries with more than one dataset.xlsx"
#   ),
#   overwrite = TRUE
# )
# temp3 = read_xlsx(
#   paste0(cen_dir, "Downloads/Census/Countries with more than one dataset.xlsx"),
#   "Extraction"
# ) %>%
#   arrange(`File name`)
# temp3 = temp3 %>%
#   mutate(across(
#     dis_a:Multid_poverty,
#     ~ as.numeric(ifelse(.x == "x" | .x == "X", NA, .x))
#   ))

# temp4 = temp3 %>% filter(dis_a == 1) %>% select(Country, Survey, `File name`)

# temp3b = temp3
# names(temp3b) = sub("everattended_new", "Ever_attended_school", names(temp3b))
# names(temp3b) = sub("ind_atleastprimary", "At_least_primary", names(temp3b))
# names(temp3b) = sub("ind_atleastsecondary", "At_least_secondary", names(temp3b))
# names(temp3b) = sub("lit_new", "Literacy_rate", names(temp3b))
# names(temp3b) = sub("computer", "Computer_use", names(temp3b))
# names(temp3b) = sub("internet", "Internet_use", names(temp3b))
# names(temp3b) = sub("mobile_own", "Own_Mobile", names(temp3b))
# names(temp3b) = sub("ind_emp", "Employment", names(temp3b))
# names(temp3b) = sub("youth_idle", "Youth_idle_rate", names(temp3b))
# names(temp3b) = sub("work_manufacturing", "Manufacturing_work", names(temp3b))
# names(temp3b) = sub("work_managerial", "Managerial_work", names(temp3b))
# names(temp3b) = sub("work_informal", "Informal_work", names(temp3b))
# names(temp3b) = sub("ind_water", "Water", names(temp3b))
# names(temp3b) = sub("ind_toilet", "Sanitation", names(temp3b))
# names(temp3b) = sub("fp_demsat_mod", "Family_Planning_Met", names(temp3b))
# names(temp3b) = sub("anyviolence_byh_12m", "Any_Violence", names(temp3b))
# names(temp3b) = sub("ind_electric", "Electricity", names(temp3b))
# names(temp3b) = sub("ind_cleanfuel", "Clean_fuel", names(temp3b))
# names(temp3b) = sub("ind_livingcond", "Adequate_Housing", names(temp3b))
# names(temp3b) = sub("ind_asset_ownership", "Share_assets_owned", names(temp3b))
# names(temp3b) = sub("cell_new", "Household_Mobile_phone", names(temp3b))
# names(temp3b) = sub("health_insurance", "Health_insurance", names(temp3b))
# names(temp3b) = sub("social_prot", "Social_protection", names(temp3b))
# names(temp3b) = sub("food_insecure", "Food_insecure", names(temp3b))
# names(temp3b) = sub("shock_any", "Shock", names(temp3b))
# names(temp3b) = sub("health_exp_hh", "Health_expenditures", names(temp3b))
# names(temp3b) = sub("ind_mdp", "Multid_poverty", names(temp3b))

# # temp2 |> filter((!(Subnational_1_feasible=="X" | Subnational_1_feasible=="x") | !(Subnational_2_feasible=="X" | Subnational_2_feasible=="x") | is.na(Subnational_1_feasible) | is.na(Subnational_2_feasible)) & File_Name %in% temp3$`File name`)
# # Build check for ineligible 1's that have alternative data

# db_m = read_xlsx(
#   paste0(cen_dir, "Downloads/Census/Database/DS_E2_All_Estimates.xlsx"),
#   col_types = c(rep("text", 3), rep("numeric", 1467))
# )

# admin0_m = db_m %>% filter(admin == "admin0") %>% select(-admin)
# admin1_m = db_m %>% filter(admin == "admin1") %>% select(-admin)
# admin2_m = db_m %>% filter(admin == "admin2") %>% select(-admin)
# admina_m = db_m %>% filter(admin == "admin_alt") %>% select(-admin)

# admin0_mb = admin0_m %>%
#   filter(survey %in% temp2$File_Name) %>%
#   rename(country = survey)
# admin1_mb = admin1_m %>%
#   filter(
#     survey %in%
#       temp2$File_Name[
#         temp2$Subnational_1_feasible == "X" |
#           temp2$Subnational_1_feasible == "x"
#       ]
#   ) %>%
#   rename(country = survey)
# admin2_mb = admin2_m %>%
#   filter(
#     survey %in%
#       temp2$File_Name[
#         temp2$Subnational_2_feasible == "X" |
#           temp2$Subnational_2_feasible == "x"
#       ]
#   ) %>%
#   filter(!survey %in% temp3$`File name` | survey %in% temp4$`File name`) %>%
#   mutate(survey = str_extract(survey, ".+?(?=_)")) %>%
#   rename(country = survey)
# admina_mb = admina_m %>%
#   filter(survey %in% temp2$File_Name) %>%
#   filter(!survey %in% temp3$`File name` | survey %in% temp4$`File name`) %>%
#   mutate(survey = str_extract(survey, ".+?(?=_)")) %>%
#   rename(country = survey)

# multicountry = bind_cols(
#   temp3 %>% select(`File name`),
#   rep(temp3 %>% select(dis_a), 27),
#   rep(temp3 %>% select(dom_a), 54),
#   rep(temp3 %>% select(Household_Prevalence), 9),
#   rep(temp3 %>% select(Ever_attended_school:Multid_poverty), each = 51),
#   .name_repair = "minimal"
# )
# names(multicountry) = names(admin0_m)[-2]
# multicountry = multicountry %>% filter(survey %in% admin0_m$survey)

# multicountry2 = admin1_mb %>%
#   filter(country %in% multicountry$survey) %>%
#   select(1:2)
# multicountry2 = left_join(
#   multicountry2,
#   multicountry,
#   by = join_by(country == survey)
# )

# rm(admin0_m, admin1_m, admin2_m, admina_m)

# admin0_mc = admin0_mb %>% filter(country %in% temp3$`File name`)
# admin0_mb = admin0_mb %>% filter(!country %in% temp3$`File name`)
# admin1_mc = admin1_mb %>% filter(country %in% temp3$`File name`)
# admin1_mb = admin1_mb %>% filter(!country %in% temp3$`File name`)
# # admin2_mc = admin2_mb %>% filter(country %in% temp3$`File name`)
# # admin2_mb = admin2_mb %>% filter(!country %in% temp3$`File name`)

# static = multicountry
# names(static) = names(static) %>%
#   sub("Household_Prevalence_", "Household_Prevalence ", .)
# names(static)[2:82] = names(static)[2:82] %>% paste0("Prevalence ", .)
# names(static)[!grepl(" .* ", names(static))][-1] = names(static)[
#   !grepl(" .* ", names(static))
# ][-1] %>%
#   sub("(\\()(.*)(\\))", "\\2 \\1all_adults\\3", .)
# static = static %>%
#   pivot_longer(
#     .,
#     names(.)[-1],
#     names_to = c("IndicatorName", "DifficultyName", "PopulationName"),
#     names_pattern = "(.*) (.*) \\((.*)\\)",
#     values_to = "Value"
#   )
# static = static %>%
#   filter(
#     PopulationName == "all_adults",
#     DifficultyName == "disability",
#     !is.na(Value)
#   ) %>%
#   select(-DifficultyName, -PopulationName, -Value)
# static = static %>% mutate(source = survey) %>% rename(Country = survey)
# static = static %>%
#   add_row(tibble(
#     Country = rep(admin0_mb$country, each = n_distinct(static$IndicatorName)),
#     IndicatorName = rep(
#       unique(static$IndicatorName),
#       times = n_distinct(admin0_mb$country)
#     ),
#     source = rep(admin0_mb$country, each = n_distinct(static$IndicatorName))
#   ))
# static = static %>%
#   mutate(Country = str_extract(Country, ".+?(?=_)")) %>%
#   complete(Country, IndicatorName)

# temp5 = bind_cols(
#   admin0_mc[1:2],
#   admin0_mc[3:1469] %>% as.matrix() * multicountry[2:1468] %>% as.matrix()
# )
# temp7 = bind_cols(
#   admin1_mc[1:2],
#   admin1_mc[3:1469] %>% as.matrix() * multicountry2[3:1469] %>% as.matrix()
# )
# temp5 = temp5 %>% mutate(country = str_extract(country, ".+?(?=_)"))
# temp7 = temp7 %>% mutate(country = str_extract(country, ".+?(?=_)"))
# admin0_mc = temp5 %>%
#   group_by(country) %>%
#   summarise(
#     level = first(level),
#     across(
#       `disability (all_adults)`:`Multid_poverty (communicating)`,
#       ~ ifelse(sum(!is.na(.x)) == 1, na.omit(.x), NA)
#     )
#   )
# admin1_mc = temp7 %>%
#   group_by(country, level) %>%
#   summarise(across(
#     `disability (all_adults)`:`Multid_poverty (communicating)`,
#     ~ ifelse(sum(!is.na(.x)) == 1, na.omit(.x), NA)
#   ))
# admin0_mb = admin0_mb %>% mutate(country = str_extract(country, ".+?(?=_)"))
# admin1_mb = admin1_mb %>% mutate(country = str_extract(country, ".+?(?=_)"))

# admin0_mb = full_join(admin0_mb, admin0_mc, by = names(admin0_mb)) %>%
#   arrange(country)
# admin1_mb = full_join(admin1_mb, admin1_mc, by = names(admin1_mb)) %>%
#   arrange(country)

# rm(
#   admin0_mc,
#   admin1_mc,
#   temp2,
#   temp3,
#   temp3b,
#   temp4,
#   temp5,
#   temp7,
#   multicountry,
#   multicountry2
# )

# static2 = admin1_mb %>% rename("Country" = "country")
# names(static2) = names(static2) %>%
#   sub("Household_Prevalence_", "Household_Prevalence ", .)
# names(static2)[3:83] = names(static2)[3:83] %>% paste0("Prevalence ", .)
# names(static2)[!grepl(" .* ", names(static2))][-c(1:2)] = names(static2)[
#   !grepl(" .* ", names(static2))
# ][-c(1:2)] %>%
#   sub("(\\()(.*)(\\))", "\\2 \\1all_adults\\3", .)
# static2 = static2 %>%
#   pivot_longer(
#     .,
#     names(.)[-c(1:2)],
#     names_to = c("IndicatorName", "DifficultyName", "PopulationName"),
#     names_pattern = "(.*) (.*) \\((.*)\\)",
#     values_to = "Value"
#   )
# static2 = static2 %>%
#   summarise(
#     min = min(Value, na.rm = T),
#     max = max(Value, na.rm = T),
#     .by = c(Country, IndicatorName)
#   )
# static = left_join(static, static2)

# # Use locations from excel to identify blocks of values to assign into ordered list

# db_mb = bind_rows(
#   admin0 = admin0_mb,
#   admin1 = admin1_mb,
#   admin2 = admin2_mb,
#   admin_alt = admina_mb,
#   .id = "admin"
# ) %>%
#   select(country, names(db_m)[-1]) %>%
#   arrange(country, admin, level)

# if (
#   file.exists(paste0(
#     cen_dir,
#     "Downloads/Census/Database/S1_Default_Estimates_Means.xlsx"
#   ))
# ) {
#   file.remove("DS-D files/Static.xlsx")
#   file.remove(paste0(
#     cen_dir,
#     "Downloads/Census/Database/S1_Default_Estimates_Means.xlsx"
#   ))
# }
# write_xlsx(static, "DS-D files/Static.xlsx")
# write_xlsx(
#   db_mb,
#   paste0(cen_dir, "Downloads/Census/Database/S1_Default_Estimates_Means.xlsx")
# )

# rm(admin0_mb, admin1_mb, admin2_mb, admina_mb, static, static2, db_m, db_mb)
# gc()
