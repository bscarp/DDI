#**Data cleaning for south Africa 2022 Census*
#Load the necessary libraries
# Load packages

library(haven)
library(readr)
library(labelled)
library(tidyverse)
# library(rio)
# install.packages("janitor")
# library(janitor)

cen_dir <- "C:/Users/bscar/Downloads/Census/R Datasets/"
sta_dir <- "C:/Users/bscar/Downloads/Census/Stata Datasets/"

#**Import the datasets*

if (
  !(file.exists(paste0(cen_dir, "zaf1.rds")) |
    file.exists(paste0(cen_dir, "South Africa_Census_2022.RData")))
) {
  geo <- read_dta(paste0(sta_dir, "sa-census-2022-geography-v1.dta"))
  person <- read_dta(paste0(sta_dir, "sa-census-2022-person-v1.dta"))
  house <- read_dta(paste0(sta_dir, "sa-census-2022-household-v1.dta"))
  codes <- read_csv(paste0(sta_dir, "sa_census_geocodes.csv"))

  geo <- geo |>
    mutate(
      Province = as.character(as_factor(Province)),
      District = sub(".*\\. ", "", as_factor(District)),
      Municipality = sub(".*\\. ", "", as_factor(Municipality)),
      District = recode_values(
        District,
        from = codes$Code,
        to = codes$Name
      ),
      Municipality = recode_values(
        Municipality,
        from = codes$Code,
        to = codes$Name
      )
    )

  # Merge all three datasets by QID
  merged <- geo %>%
    full_join(house, by = "QID") %>%
    full_join(person, by = "QID")

  # Remove duplicates
  merged <- merged %>% distinct()

  # Save merged dataset as RDS
  saveRDS(
    merged,
    file = paste0(cen_dir, "zaf1.rds")
  )

  rm(geo, house, person, merged)
}

if (
  !(file.exists(paste0(cen_dir, "zaf2.rds")) |
    file.exists(paste0(cen_dir, "South Africa_Census_2022.RData")))
) {
  # Load the dataset back for cleaning
  #zaf1 <- read_rds(paste0(cen_dir, "zaf1.rds"))
  zaf2 <- read_rds(paste0(cen_dir, "zaf1.rds"))

  # Rename age variable
  zaf2 <- zaf2 %>%
    rename(age = P04_AGE)

  #**Dropping bellow 15 years*
  zaf2 <- zaf2 %>%
    filter(age >= 15) %>% #drop if age < 15
    mutate(age = ifelse(age == 999, NA, age)) #replace 999 with NA

  # Save merged dataset as RDS
  saveRDS(zaf2, file = paste0(cen_dir, "zaf2.rds"))

  rm(zaf2)
}

if (
  !(file.exists(paste0(cen_dir, "zaf3.rds")) |
    file.exists(paste0(cen_dir, "South Africa_Census_2022.RData")))
) {
  # Load the dataset back for cleaning
  zaf3 <- read_rds(paste0(cen_dir, "zaf2.rds"))

  #**Variable generation**************************

  zaf3 <- zaf3 %>%
    mutate(
      # --- Country Information ---
      country_name = "South_Africa",
      country_abrev = "ZAF",
      country_dataset_year = "South_Africa_Census_2022",

      # --- Administrative Levels ---
      admin1 = Province,
      admin2 = District,
      admin3 = Municipality, # optional if you want a third level

      #*****Household and Individual IDs***
      hh_id = QID,
      ind_id = PID,
      #***Household Weight***
      hh_weight = HH_WGT,
      #***Individual Weight***
      ind_weight = PERS_WGT,
      #***Primary sample unit**
      psu = admin3,
    )

  ##**Introducing the age_group variable to the dataset*
  zaf3 <- zaf3 %>%
    mutate(
      age_group = case_when(
        age == 999 ~ NA_real_,
        age <= 29 ~ 1,
        age <= 44 ~ 2,
        age <= 64 ~ 3,
        age >= 65 ~ 4,
        TRUE ~ NA_real_
      )
    )

  #***Converting the gender variable to binary
  zaf3 <- zaf3 %>%
    mutate(
      female = case_when(
        P02_SEX == 2 ~ 1, # Female -> 1
        P02_SEX == 1 ~ 0, # Male -> 0
        TRUE ~ NA_real_ # Any missing or other values -> NA
      )
    )

  # urban/rural binary coding to enable numerical analysis where  rural Area->1 and urban area ->0.
  zaf3 <- zaf3 %>%
    mutate(
      urban_new = case_when(
        Geo_type == 1 ~ 1, # urban = 1
        Geo_type %in% c(2, 3) ~ 0, # rural = 0
        TRUE ~ NA_real_ # missing/other
      )
    )

  # Check results
  table(zaf3$urban_new, useNA = "ifany")

  #**#The Functional Difficulties*
  #Duplicating some variables the six WGSS Questions*
  #Recode all text responses (including "Unapplicable",“Unspecied”) into numeric codes

  # List of original WG variables and corresponding clean variable names
  wg_vars <- c(
    "P17A_SEEING",
    "P17B_HEARING",
    "P17C_COMMUNICATION",
    "P17D_WALKING",
    "P17E_REMEMBERING",
    "P17F_SELF_CARE"
  )

  clean_names <- c(
    "seeing_diff_new",
    "hearing_diff_new",
    "comm_diff_new",
    "mobility_diff_new",
    "cognitive_diff_new",
    "selfcare_diff_new"
  )

  # Recode and clean in one step
  zaf3 <- zaf3 %>%
    mutate(
      across(
        all_of(wg_vars),
        ~ as.numeric(.x),
        .names = "{.col}_num"
      ) # temporary numeric variables
    ) %>%
    # Rename to intuitive cleaned variable names
    rename_with(~clean_names, ends_with("_num")) %>%
    # Ensure only valid values 1–4 remain, all else → NA
    mutate(across(all_of(clean_names), ~ if_else(.x <= 4, .x, NA_real_))) %>%
    #** DROP ROWS where all 6 cleaned domains are NA*
    filter(!if_all(all_of(clean_names), is.na))

  # Create a new variable 'func_difficulty' which represents
  # the highest (worst) level of difficulty across all six functional domains.
  # Compute row-wise maximum, ignoring NAs
  zaf3 <- zaf3 %>%
    mutate(
      func_difficulty = do.call(
        pmax,
        c(across(all_of(clean_names)), na.rm = TRUE)
      ),
      func_difficulty = if_else(
        rowSums(!is.na(across(all_of(clean_names)))) == 0,
        NA_real_,
        func_difficulty
      )
    )

  #**Disability levels for any domain***

  zaf3 <- zaf3 %>%
    # Create disability indicators
    mutate(
      disability_any = if_else(
        !is.na(func_difficulty),
        as.numeric(func_difficulty >= 2),
        NA_real_
      ),
      disability_some = if_else(
        !is.na(func_difficulty),
        as.numeric(func_difficulty == 2),
        NA_real_
      ),
      disability_alot = if_else(
        !is.na(func_difficulty),
        as.numeric(func_difficulty == 3),
        NA_real_
      ),
      disability_unable = if_else(
        !is.na(func_difficulty),
        as.numeric(func_difficulty == 4),
        NA_real_
      ),
      disability_atleast = if_else(
        !is.na(func_difficulty),
        as.numeric(func_difficulty >= 3),
        NA_real_
      ),
      disability_none = if_else(disability_any == 0, 1, 0),
      disability_none = if_else(
        is.na(disability_any),
        NA_real_,
        disability_none
      ),
      disability_nonesome = if_else(
        disability_none == 1 | disability_some == 1,
        1,
        0
      ),
      disability_nonesome = if_else(
        is.na(disability_none) & is.na(disability_some),
        NA_real_,
        disability_nonesome
      )
    )

  # # Add labeled factors
  # zaf3 <- zaf3 %>%
  #   mutate(
  #     disability_any_label = factor(
  #       disability_any,
  #       levels = c(0, 1),
  #       labels = c("No difficulty", "Some / A lot / Cannot do")
  #     ),
  #     disability_some_label = factor(
  #       disability_some,
  #       levels = c(0, 1),
  #       labels = c("Not some difficulty", "Some difficulty")
  #     ),
  #     disability_atleast_label = factor(
  #       disability_atleast,
  #       levels = c(0, 1),
  #       labels = c("Not at least a lot", "At least a lot")
  #     ),
  #     disability_none_label = factor(
  #       disability_none,
  #       levels = c(0, 1),
  #       labels = c("Has difficulty", "No difficulty")
  #     ),
  #     disability_nonesome_label = factor(
  #       disability_nonesome,
  #       levels = c(0, 1),
  #       labels = c("A lot / Cannot do", "None or Some difficulty")
  #     )
  #   )

  # Disability indicators (numeric 0/1)
  indicators <- c(
    "disability_any",
    "disability_some",
    "disability_alot",
    "disability_unable",
    "disability_atleast",
    "disability_none",
    "disability_nonesome"
  )

  # Loop through indicators and print counts
  for (var in indicators) {
    cat("\n=== ", var, " ===\n")
    print(table(zaf3[[var]], useNA = "ifany"))
  }

  # # Labeled versions
  # label_vars <- c(
  #   "disability_any_label",
  #   "disability_some_label",
  #   "disability_atleast_label",
  #   "disability_none_label",
  #   "disability_nonesome_label"
  # )

  # # Loop through labeled indicators
  # for (var in label_vars) {
  #   cat("\n=== ", var, " ===\n")
  #   counts <- table(zaf3[[var]], useNA = "ifany")
  #   percents <- round(100 * prop.table(counts), 1)
  #   print(cbind(Counts = counts, Percent = percents))
  # }

  # View a few records for inspection
  head(zaf3[, c(
    "func_difficulty",
    "disability_any",
    "disability_some",
    "disability_atleast"
  )])

  #*****Any difficulty for each domain***
  #*
  zaf3 <- zaf3 %>%
    mutate(
      seeing_any = if_else(
        !is.na(seeing_diff_new),
        as.numeric(seeing_diff_new >= 2),
        NA_real_
      ),
      hearing_any = if_else(
        !is.na(hearing_diff_new),
        as.numeric(hearing_diff_new >= 2),
        NA_real_
      ),
      mobile_any = if_else(
        !is.na(mobility_diff_new),
        as.numeric(mobility_diff_new >= 2),
        NA_real_
      ),
      cognition_any = if_else(
        !is.na(cognitive_diff_new),
        as.numeric(cognitive_diff_new >= 2),
        NA_real_
      ),
      selfcare_any = if_else(
        !is.na(selfcare_diff_new),
        as.numeric(selfcare_diff_new >= 2),
        NA_real_
      ),
      communicating_any = if_else(
        !is.na(comm_diff_new),
        as.numeric(comm_diff_new >= 2),
        NA_real_
      )
    )

  ##***Some difficulty for each domain***

  zaf3 <- zaf3 %>%
    mutate(
      seeing_some = if_else(
        !is.na(seeing_diff_new),
        as.numeric(seeing_diff_new == 2),
        NA_real_
      ),
      hearing_some = if_else(
        !is.na(hearing_diff_new),
        as.numeric(hearing_diff_new == 2),
        NA_real_
      ),
      mobile_some = if_else(
        !is.na(mobility_diff_new),
        as.numeric(mobility_diff_new == 2),
        NA_real_
      ),
      cognition_some = if_else(
        !is.na(cognitive_diff_new),
        as.numeric(cognitive_diff_new == 2),
        NA_real_
      ),
      selfcare_some = if_else(
        !is.na(selfcare_diff_new),
        as.numeric(selfcare_diff_new == 2),
        NA_real_
      ),
      communicating_some = if_else(
        !is.na(comm_diff_new),
        as.numeric(comm_diff_new == 2),
        NA_real_
      )
    )

  #***Alot of difficulty for each domain***

  zaf3 <- zaf3 %>%
    mutate(
      seeing_alot = if_else(
        !is.na(seeing_diff_new),
        as.numeric(seeing_diff_new >= 3),
        NA_real_
      ),
      hearing_alot = if_else(
        !is.na(hearing_diff_new),
        as.numeric(hearing_diff_new >= 3),
        NA_real_
      ),
      mobile_alot = if_else(
        !is.na(mobility_diff_new),
        as.numeric(mobility_diff_new >= 3),
        NA_real_
      ),
      cognition_alot = if_else(
        !is.na(cognitive_diff_new),
        as.numeric(cognitive_diff_new >= 3),
        NA_real_
      ),
      selfcare_alot = if_else(
        !is.na(selfcare_diff_new),
        as.numeric(selfcare_diff_new >= 3),
        NA_real_
      ),
      communicating_alot = if_else(
        !is.na(comm_diff_new),
        as.numeric(comm_diff_new >= 3),
        NA_real_
      )
    )

  #***Cannot do difficulty for each domain***

  zaf3 <- zaf3 %>%
    mutate(
      seeing_unable = if_else(
        !is.na(seeing_diff_new),
        as.numeric(seeing_diff_new == 4),
        NA_real_
      ),
      hearing_unable = if_else(
        !is.na(hearing_diff_new),
        as.numeric(hearing_diff_new == 4),
        NA_real_
      ),
      mobile_unable = if_else(
        !is.na(mobility_diff_new),
        as.numeric(mobility_diff_new == 4),
        NA_real_
      ),
      cognition_unable = if_else(
        !is.na(cognitive_diff_new),
        as.numeric(cognitive_diff_new == 4),
        NA_real_
      ),
      selfcare_unable = if_else(
        !is.na(selfcare_diff_new),
        as.numeric(selfcare_diff_new == 4),
        NA_real_
      ),
      communicating_unable = if_else(
        !is.na(comm_diff_new),
        as.numeric(comm_diff_new == 4),
        NA_real_
      )
    )

  #***At least alot difficulty for each domain***

  zaf3 <- zaf3 %>%
    mutate(
      seeing_atleast_alot = if_else(
        !is.na(seeing_diff_new),
        as.numeric(seeing_diff_new >= 3),
        NA_real_
      ),
      hearing_atleast_alot = if_else(
        !is.na(hearing_diff_new),
        as.numeric(hearing_diff_new >= 3),
        NA_real_
      ),
      mobile_atleast_alot = if_else(
        !is.na(mobility_diff_new),
        as.numeric(mobility_diff_new >= 3),
        NA_real_
      ),
      cognition_atleast_alot = if_else(
        !is.na(cognitive_diff_new),
        as.numeric(cognitive_diff_new >= 3),
        NA_real_
      ),
      selfcare_atleast_alot = if_else(
        !is.na(selfcare_diff_new),
        as.numeric(selfcare_diff_new >= 3),
        NA_real_
      ),
      communicating_atleast_alot = if_else(
        !is.na(comm_diff_new),
        as.numeric(comm_diff_new >= 3),
        NA_real_
      )
    )

  # Save dataset as RDS
  saveRDS(zaf3, file = paste0(cen_dir, "zaf3.rds"))
  rm(zaf3, clean_names, indicators, var, wg_vars)
}

if (
  !(file.exists(paste0(cen_dir, "zaf4.rds")) |
    file.exists(paste0(cen_dir, "South Africa_Census_2022.RData")))
) {
  # Load the dataset back for cleaning
  zaf4 <- read_rds(paste0(cen_dir, "zaf3.rds"))

  #***Household level Disability*

  zaf4 <- zaf4 %>%
    mutate(
      # Max functional difficulty per household
      func_difficulty_hh = max(func_difficulty, na.rm = TRUE),
      .by = hh_id
    ) %>%
    mutate(
      func_difficulty_hh = ifelse(
        is.infinite(func_difficulty_hh),
        NA_real_,
        func_difficulty_hh
      ),

      # Household-level disability indicators
      disability_any_hh = case_when(
        is.na(func_difficulty_hh) ~ NA_real_,
        func_difficulty_hh > 1 ~ 1,
        func_difficulty_hh == 1 ~ 0
      ),
      disability_some_hh = case_when(
        is.na(func_difficulty_hh) ~ NA_real_,
        func_difficulty_hh == 2 ~ 1,
        func_difficulty_hh != 2 ~ 0
      ),
      disability_alot_hh = case_when(
        is.na(func_difficulty_hh) ~ NA_real_,
        func_difficulty_hh == 2 ~ 1,
        func_difficulty_hh != 2 ~ 0
      ),
      disability_unable_hh = case_when(
        is.na(func_difficulty_hh) ~ NA_real_,
        func_difficulty_hh == 2 ~ 1,
        func_difficulty_hh != 2 ~ 0
      ),
      disability_atleast_hh = case_when(
        is.na(func_difficulty_hh) ~ NA_real_,
        func_difficulty_hh > 2 ~ 1,
        func_difficulty_hh < 3 ~ 0
      ),

      # Labeled versions for readability
      disability_any_hh_label = factor(
        disability_any_hh,
        levels = c(0, 1),
        labels = c("No difficulty", "Some/A lot/Cannot do")
      ),
      disability_some_hh_label = factor(
        disability_some_hh,
        levels = c(0, 1),
        labels = c("Not some difficulty", "Some difficulty")
      ),
      disability_alot_hh_label = factor(
        disability_some_hh,
        levels = c(0, 1),
        labels = c("Not some difficulty", "Some difficulty")
      ),
      disability_unable_hh_label = factor(
        disability_some_hh,
        levels = c(0, 1),
        labels = c("Not some difficulty", "Some difficulty")
      ),
      disability_atleast_hh_label = factor(
        disability_atleast_hh,
        levels = c(0, 1),
        labels = c("Not at least a lot", "At least a lot")
      )
    )

  # Add attribute
  attr(zaf4$func_difficulty_hh, "label") <- "Max Difficulty in HH"

  # Save dataset as RDS
  saveRDS(zaf4, file = paste0(cen_dir, "zaf4.rds"))
  rm(zaf4)
}

if (
  !(file.exists(paste0(cen_dir, "zaf5.rds")) |
    file.exists(paste0(cen_dir, "South Africa_Census_2022.RData")))
) {
  # Load the dataset back for cleaning
  zaf5 <- read_rds(paste0(cen_dir, "zaf4.rds"))

  ##**Manipulating the Six Indicator Groups -Education*

  #***Literacy rate*
  # Do not have literacy rate thus creating a place holder
  zaf5 <- zaf5 %>%
    mutate(lit_new = NA_real_)

  #***Ever attended School*

  zaf5 <- zaf5 %>%
    mutate(
      # --- Ever attended school (based on highest education) ---
      everattended_new = case_when(
        P21_EDULEVEL == 98 ~ 0, # Never attended
        P21_EDULEVEL > 80 ~ NA_real_, # Unclear/missing
        TRUE ~ 1 # All other valid education
      )
    )

  # Check your results
  table(zaf5$everattended_new, zaf5$P21_EDULEVEL, useNA = "ifany")

  #**Education - completed primary school*
  #*This variable was created for computing multidimensional poverty
  zaf5 <- zaf5 %>%
    mutate(
      ind_atleastprimary_all = case_when(
        P21_EDULEVEL < 7 | P21_EDULEVEL == 98 ~ 0, # Not completed primary
        P21_EDULEVEL > 27 ~ NA_real_, # Missing / unclear
        TRUE ~ 1 # All others completed primary or higher
      )
    )

  #**At least primary education *

  zaf5 <- zaf5 %>%
    mutate(
      ind_atleastprimary = case_when(
        age < 25 ~ NA_real_,
        P21_EDULEVEL < 7 | P21_EDULEVEL == 98 ~ 0, # Not completed primary
        P21_EDULEVEL > 27 ~ NA_real_, # Missing / unclear
        TRUE ~ 1 # All others completed primary or higher
      )
    )

  # Optional: check summary of the new variable
  table(zaf5$ind_atleastprimary, zaf5$P21_EDULEVEL, useNA = "ifany")

  #**Atleastsecondary education*

  zaf5 <- zaf5 %>%
    mutate(
      ind_atleastsecondary = case_when(
        age < 25 ~ NA_real_,
        P21_EDULEVEL > 27 ~ NA_real_, # Missing / unclear
        P21_EDULEVEL == 12 | P21_EDULEVEL > 14 ~ 1, # Completed secondary
        TRUE ~ 0 # All others not completed secondary or higher
      )
    )

  ##**Employment Status*#
  ##*Creating an employment place holder with NAs*
  zaf5 <- zaf5 %>%
    mutate(ind_emp = NA_real_)

  #**Manufacturing Worker *

  zaf5 <- zaf5 %>%
    mutate(
      work_manufacturing = NA_real_ # variable created, filled with missing values
    )

  #***Female at Managerial Work *

  #Creating an NAs place holder for the Female at Managerial Work
  zaf5 <- zaf5 %>%
    mutate(
      work_managerial = NA_real_ # No ISCO occupation info in SA 2022 Census
    )

  ##**Informal Work *

  zaf5 <- zaf5 %>%
    mutate(
      work_informal = NA_real_ # No ISCO occupation info in SA 2022 Census
    )

  ##***Youth Idle *
  zaf5 <- zaf5 %>%
    mutate(
      youth_idle = NA_real_ # No employment info in SA 2022 Census
    )

  #****Electricity**#

  zaf5 <- zaf5 %>%
    mutate(
      # Create electricity indicator using case_when
      ind_electric = case_when(
        H10_ENERGY_LIGHTING %in% c(1, 6) ~ 1, # Has electricity
        H10_ENERGY_LIGHTING > 0 ~ 0, # No electricity
        TRUE ~ NA_real_ # Default to NA if something unexpected
      )
    )

  ##*****Clean Cooking Fuel**#

  zaf5 <- zaf5 %>%
    mutate(
      # Create a clean cooking fuel indicator
      ind_cleanfuel = case_when(
        H09_ENERGY_COOKING %in% c(1, 3, 8) ~ 1, # Clean fuel
        H09_ENERGY_COOKING > 0 ~ 0, # Unclean fuel
        TRUE ~ NA_real_ # Catch any unexpected values
      )
    )

  #** Water**
  zaf5 <- zaf5 %>%
    mutate(
      # Create indicator for improved water access
      ind_water = case_when(
        H06_WATERSOURCE %in% c(1:4, 7) ~ 1,
        H06_WATERSOURCE > 0 ~ 0, # Unimproved (unsafe) water sources
        TRUE ~ NA_real_
      )
    )

  # View counts
  table(zaf5$ind_water, zaf5$H06_WATERSOURCE, useNA = "ifany")

  ##** Sanitation- toilet**

  zaf5 <- zaf5 %>%
    mutate(
      # Initialize toilet indicator as NA
      ind_toilet = case_when(
        H08_TOILET %in% c(1:4, 6) ~ 1, # Improved toilet
        H08_TOILET > 0 ~ 0, # Unimproved toilet
        TRUE ~ NA_real_ # Catch any unexpected values
      )
    )

  ##**Family Planing*

  zaf5 <- zaf5 %>%
    mutate(
      fp_demsat_mod = NA_real_ # No family planing info in SA 2022 Census
    )

  ##**Women subjected to violence*

  zaf5 <- zaf5 %>%
    mutate(
      anyviolence_byh_12m = NA_real_ # No violence info in SA 2022 Census
    )

  ###**BMI*

  zaf5 <- zaf5 %>%
    mutate(
      bmi = NA_real_ # No bmi info in SA 2022 Census
    )

  ####**Overweight/obse*
  zaf5 <- zaf5 %>%
    mutate(
      overweight_obese = NA_real_ # No obese info in SA 2022 Census
    )

  ####**Child Mortality*

  zaf5 <- zaf5 %>%
    mutate(
      child_died = NA_real_ # No child mortality info in SA 2022 Census
    )

  ###**Health Access problem*

  zaf5 <- zaf5 %>%
    mutate(
      healthcare_prob = NA_real_ # No healthcare access problem info in SA 2022 Census
    )
  ###**Household mortality*
  zaf5 <- zaf5 %>%
    mutate(
      death_hh = NA_real_ # No household mortality problem info in SA 2022 Census
    )

  ####**Housing Condition****

  zaf5 <- zaf5 %>%
    mutate(
      # Define indicator for "good" living condition dwellings
      ind_livingcond = case_when(
        H02_MAINDWELLING %in% c(1, 3:7) ~ 1, # good condition
        H02_MAINDWELLING > 0 ~ 0, # Bad condition
        TRUE ~ NA_real_ # Missing values
      )
    )

  ##**floor quality*
  zaf5 <- zaf5 %>%
    mutate(
      ind_floor = NA_real_ # No  info in SA 2022 Census
    )

  ##**wall quality*
  zaf5 <- zaf5 %>%
    mutate(
      ind_wall = NA_real_ # No  info in SA 2022 Census
    )
  ###**roof quality*
  zaf5 <- zaf5 %>%
    mutate(
      ind_roof = NA_real_ # No  info in SA 2022 Census
    )

  #**House Goods***
  #**Radio**

  zaf5 <- zaf5 %>%
    mutate(
      ind_radio = case_when(
        H12_RADIO == 1 ~ 1,
        H12_RADIO == 2 ~ 0,
        TRUE ~ NA_real_
      )
    )

  table(zaf5$ind_radio, zaf5$H12_RADIO, useNA = "ifany")

  #***Cell phone**

  zaf5 <- zaf5 %>%
    mutate(
      cell_new = case_when(
        H12_CELLPHONE == 1 ~ 1,
        H12_CELLPHONE == 2 ~ 0,
        TRUE ~ NA_real_
      )
    )
  table(zaf5$cell_new, zaf5$H12_CELLPHONE, useNA = "ifany")

  ###**Television*

  zaf5 <- zaf5 %>%
    mutate(
      ind_tv = case_when(
        H12_TELEVISION == 1 | H12_SATELLITE == 1 ~ 1,
        H12_TELEVISION == 2 & H12_SATELLITE == 2 ~ 0,
        TRUE ~ NA_real_
      )
    )

  table(zaf5$ind_tv, zaf5$H12_TELEVISION, useNA = "ifany")
  table(zaf5$ind_tv, zaf5$H12_SATELLITE, useNA = "ifany")

  #***Computer**

  zaf5 <- zaf5 %>%
    mutate(
      ind_computer = case_when(
        H12_COMPUTER == 1 ~ 1,
        H12_COMPUTER == 2 ~ 0,
        TRUE ~ NA_real_
      )
    )
  table(zaf5$ind_computer, zaf5$H12_COMPUTER, useNA = "ifany")

  ##**Refrigerator*

  zaf5 <- zaf5 %>%
    mutate(
      ind_refrig = case_when(
        H12_REFRIGERATOR == 1 ~ 1,
        H12_REFRIGERATOR == 2 ~ 0,
        TRUE ~ NA_real_
      )
    )

  table(zaf5$ind_refrig, zaf5$H12_REFRIGERATOR, useNA = "ifany")

  ###**Automobiles*

  zaf5 <- zaf5 %>%
    mutate(
      ind_autos = case_when(
        H12_MOTOR_CAR == 1 ~ 1,
        H12_MOTOR_CAR == 2 ~ 0,
        TRUE ~ NA_real_
      )
    )

  table(zaf5$ind_autos, zaf5$H12_MOTOR_CAR, useNA = "ifany")

  ###**Telephone/Landline*
  zaf5 <- zaf5 %>%
    mutate(
      ind_phone = case_when(
        H12_LANDLINE == 1 ~ 1,
        H12_LANDLINE == 2 ~ 0,
        TRUE ~ NA_real_
      )
    )

  table(zaf5$ind_phone, zaf5$H12_LANDLINE, useNA = "ifany")

  ###**bike*
  zaf5 <- zaf5 %>%
    mutate(
      ind_bike = NA_real_ # No  info in SA 2022 Census
    )
  ##**Motocycle*

  zaf5 <- zaf5 %>%
    mutate(
      ind_motorcycle = NA_real_ # No  info in SA 2022 Census
    )

  #####**Asset Ownership*

  #calculates the mean across columns for each row

  vars <- c(
    "ind_radio",
    "ind_tv",
    "ind_refrig",
    "ind_phone",
    "cell_new",
    "ind_autos",
    "ind_computer",
    "ind_bike",
    "ind_motorcycle"
  )

  zaf5$ind_asset_ownership <- rowMeans(zaf5[, vars], na.rm = TRUE)

  ##**Internet Acess*
  zaf5 <- zaf5 %>%
    mutate(
      internet = NA_real_
    )

  #**Household Computer*
  zaf5 <- zaf5 %>%
    mutate(
      computer = NA_real_
    )

  #**Own mobile*
  zaf5 <- zaf5 %>%
    mutate(
      mobile_own = NA_real_
    )

  ##**Insecurity*
  ##**Food Insecurity*
  zaf5 <- zaf5 %>%
    mutate(
      food_insecure = case_when(
        A4_ADULT_HUNGER %in% c(2:5) | A5_CHILD_HUNGER %in% c(2:5) ~ 1,
        A4_ADULT_HUNGER == 1 | A5_CHILD_HUNGER == 1 ~ 0, # no hunger
        TRUE ~ NA_real_ # Unspecified or other missing
      )
    )

  #**Health insurance*

  zaf5 <- zaf5 %>%
    mutate(
      health_insurance = NA_real_ # No  info in SA 2022 Census
    )

  #**Social protection*

  zaf5 <- zaf5 %>%
    mutate(
      social_prot = NA_real_ # No  info in SA 2022 Census
    )

  #**Shock

  zaf5 <- zaf5 %>%
    mutate(
      shock_any = NA_real_ # No  info in SA 2022 Census
    )

  #**Health Expenditure*

  zaf5 <- zaf5 %>%
    mutate(
      health_exp_hh = NA_real_ # No  info in SA 2022 Census
    )

  #####**Multidimensional Poverty

  #****1. Compute deprivation indicators***
  zaf5 <- zaf5 %>%
    mutate(
      # Labor tag
      labor_tag = ifelse(!is.na(ind_emp), 1, 0),

      # Education deprivation
      deprive_educ = case_when(
        labor_tag == 0 & ind_atleastprimary_all == 0 ~ 0.33,
        labor_tag == 0 & ind_atleastprimary_all == 1 ~ 0,
        labor_tag == 1 & ind_atleastprimary_all == 0 ~ 0.25,
        labor_tag == 1 & ind_atleastprimary_all == 1 ~ 0,
        TRUE ~ NA_real_
      ),

      # Work deprivation
      deprive_work = case_when(
        ind_emp == 0 ~ 0.25,
        ind_emp == 1 ~ 0,
        TRUE ~ NA_real_
      ),

      # Health and living standards binary indicators
      deprive_health_water = recode_values(ind_water, 0 ~ 1, 1 ~ 0),
      deprive_health_sanitation = recode_values(ind_toilet, 0 ~ 1, 1 ~ 0),
      deprive_sl_electricity = recode_values(ind_electric, 0 ~ 1, 1 ~ 0),
      deprive_sl_fuel = recode_values(ind_cleanfuel, 0 ~ 1, 1 ~ 0),
      deprive_sl_housing = recode_values(ind_livingcond, 0 ~ 1, 1 ~ 0),
    )
  #*** 2. Asset deprivation***
  zaf5 <- zaf5 %>%
    mutate(
      all_missing_assets = is.na(ind_radio) &
        is.na(ind_tv) &
        is.na(ind_phone) &
        is.na(ind_refrig) &
        is.na(ind_bike) &
        is.na(ind_motorcycle) &
        is.na(ind_autos),

      asset_count = rowSums(
        cbind(
          ind_radio,
          ind_tv,
          ind_phone,
          ind_refrig,
          ind_bike,
          ind_motorcycle,
          ind_computer,
          ind_autos
        ) ==
          1,
        na.rm = TRUE
      ),

      deprive_sl_asset = case_when(
        all_missing_assets ~ NA_real_,
        asset_count < 2 & ind_autos == 0 ~ 1,
        TRUE ~ 0
      )
    ) %>%
    #*** 3. Health dimension weighted ***
    mutate(
      missing_health = rowSums(
        !is.na(cbind(deprive_health_water, deprive_health_sanitation))
      ),
      health_sum = rowSums(
        cbind(deprive_health_water, deprive_health_sanitation),
        na.rm = TRUE
      ),
      deprive_health = case_when(
        labor_tag == 0 & missing_health > 0 ~ (health_sum / missing_health) *
          0.33,
        labor_tag == 1 & missing_health > 0 ~ (health_sum / missing_health) *
          0.25,
        TRUE ~ NA_real_
      )
    ) %>%
    #**** 4. Living standards weighted****
    mutate(
      missing_sl = rowSums(
        !is.na(cbind(
          deprive_sl_electricity,
          deprive_sl_fuel,
          deprive_sl_housing,
          deprive_sl_asset
        ))
      ),
      sl_sum = rowSums(
        cbind(
          deprive_sl_electricity,
          deprive_sl_fuel,
          deprive_sl_housing,
          deprive_sl_asset
        ),
        na.rm = TRUE
      ),
      deprive_sl = case_when(
        labor_tag == 0 & missing_sl > 0 ~ (1 / missing_sl) * 0.33 * sl_sum,
        labor_tag == 1 & missing_sl > 0 ~ (1 / missing_sl) * 0.25 * sl_sum,
        TRUE ~ NA_real_
      )
    ) %>%
    #***5. Total MPI score ****
    mutate(
      mdp_score = case_when(
        labor_tag == 0 ~ deprive_educ + deprive_health + deprive_sl,
        labor_tag == 1 ~ deprive_educ +
          deprive_work +
          deprive_health +
          deprive_sl
      ),
      # Binary multidimensional poverty indicator
      ind_mdp = case_when(
        labor_tag == 1 & mdp_score > 0.25 ~ 1,
        labor_tag == 0 & mdp_score > 0.33 ~ 1,
        !is.na(mdp_score) ~ 0,
        TRUE ~ NA_real_
      )
    )

  #**** 6. Add variable labels***
  var_label(zaf5) <- list(
    labor_tag = "Indicator if employment info exists (1=Yes,0=No)",
    deprive_educ = "Deprived if less than primary school completion",
    deprive_work = "Deprived in work binary",
    deprive_health_water = "Deprived in water binary",
    deprive_health_sanitation = "Deprived in terms of sanitation binary",
    deprive_sl_electricity = "Deprived for electricity binary",
    deprive_sl_fuel = "Deprived in terms of clean fuel binary",
    deprive_sl_housing = "Deprived in terms of housing binary",
    deprive_sl_asset = "Deprived in terms of asset ownership binary",
    deprive_health = "Weighted health deprivation score",
    deprive_sl = "Weighted living standards deprivation score",
    mdp_score = "Total multidimensional poverty score",
    ind_mdp = "Binary indicator of multidimensional poverty"
  )

  #***Renaming the computer and internet*

  #zaf5 <- zaf5 %>%
  #rename(
  #computer_hh = computer,
  #internet_hh  = internet
  # )

  # Save dataset as RDS
  saveRDS(zaf5, file = paste0(cen_dir, "zaf5.rds"))
  rm(zaf5, vars)
}

if (
  !(file.exists(paste0(cen_dir, "sa_cleaned_with_missing.rds")) |
    file.exists(paste0(cen_dir, "South Africa_Census_2022.RData")))
) {
  #***Missing***
  # Load the dataset back
  zaf6 <- read_rds(paste0(cen_dir, "zaf5.rds"))

  zaf6 <- zaf6 %>%
    # Step 2: Identify missing disaggregation variables
    mutate(
      ind_disaggvar_missing = as.integer(
        is.na(female) | is.na(age) | is.na(urban_new)
      ) # 1/0 like Stata
    )

  # Optional: save the dataset with missing indicators
  saveRDS(zaf6, paste0(cen_dir, "sa_cleaned_with_missing.rds"))
  rm(zaf6)
}

if (!file.exists(paste0(cen_dir, "South Africa_Census_2022.RData"))) {
  # Load the dataset back
  cleaned <- read_rds(paste0(cen_dir, "sa_cleaned_with_missing.rds"))

  # Step 3: Drop rows
  cleaned <- cleaned %>%
    filter(ind_disaggvar_missing != 1)

  #***Checking if the variables exisT*

  #**STEP 1 —  missing variables if they do not exist*

  vars_to_check <- c(
    "country_name",
    "country_abrev",
    "country_dataset_year",
    "ind_id",
    "hh_id",
    "admin1",
    "admin2",
    "admin3",
    "admin_alt",
    "ind_weight",
    "hh_weight",
    "dv_weight",
    "sample_strata",
    "psu",
    "female",
    "urban_new",
    "age",
    "age_group",
    "seeing_diff_new",
    "hearing_diff_new",
    "mobility_diff_new",
    "cognitive_diff_new",
    "selfcare_diff_new",
    "comm_diff_new",
    "func_difficulty",
    "disability_any",
    "disability_some",
    "disability_alot",
    "disability_unable",
    "disability_atleast",
    "disability_none",
    "disability_nonesome",
    "seeing_any",
    "hearing_any",
    "mobile_any",
    "cognition_any",
    "selfcare_any",
    "communicating_any",
    "seeing_some",
    "hearing_some",
    "mobile_some",
    "cognition_some",
    "selfcare_some",
    "communicating_some",
    "seeing_atleast_alot",
    "hearing_atleast_alot",
    "mobile_atleast_alot",
    "cognition_atleast_alot",
    "selfcare_atleast_alot",
    "communicating_atleast_alot",
    "everattended_new",
    "lit_new",
    "school_new",
    "edattain_new",
    "ind_atleastprimary",
    "ind_atleastprimary_all",
    "ind_atleastsecondary",
    "computer",
    "internet",
    "mobile_own",
    "ind_emp",
    "youth_idle",
    "work_manufacturing",
    "work_managerial",
    "work_informal",
    "work_managerial2",
    "work_informal2",
    "ind_water",
    "ind_toilet",
    "fp_demsat_mod",
    "anyviolence_byh_12m",
    "ind_electric",
    "ind_cleanfuel",
    "ind_floor",
    "ind_wall",
    "ind_roof",
    "ind_livingcond",
    "ind_radio",
    "ind_tv",
    "ind_refrig",
    "ind_bike",
    "ind_motorcycle",
    "ind_phone",
    "ind_computer",
    "ind_autos",
    "cell_new",
    "ind_asset_ownership",
    "health_insurance",
    "social_prot",
    "food_insecure",
    "shock_any",
    "health_exp_hh",
    "bmi",
    "overweight_obese",
    "healthcare_prob",
    "deprive_educ",
    "deprive_health_water",
    "deprive_health_sanitation",
    "deprive_work",
    "deprive_sl_electricity",
    "deprive_sl_fuel",
    "deprive_sl_housing",
    "deprive_sl_asset",
    "mdp_score",
    "ind_mdp",
    "func_difficulty_hh",
    "disability_any_hh",
    "disability_some_hh",
    "disability_alot_hh",
    "disability_unable_hh",
    "disability_atleast_hh",
    "disability_none_hh",
    "overcrowd",
    "not_owned_hh",
    "death_hh",
    "child_died",
    "alone"
  )

  # Add missing variables as NA
  for (v in vars_to_check) {
    if (!v %in% names(cleaned)) {
      cleaned <- cleaned %>% mutate({{ v }} := NA_real_)
      message(v, " added")
    } else {
      message(v, " exists")
    }
  }

  #***2. ADD VARIABLE LABELS*

  var_label(cleaned) <- list(
    country_name = "Country name",
    country_abrev = "Country abbreviation",
    country_dataset_year = "Country Data and year",
    ind_id = "Individual ID",
    hh_id = "Household ID",
    admin1 = "Admin 1 level",
    admin2 = "Admin 2 level",
    ind_weight = "Individaul Sample weight",
    hh_weight = "Household Sample weight",
    dv_weight = "DHS Domestic Violence sample weight",
    sample_strata = "Strata weight",
    female = "Female or Male",
    urban_new = "Urban or Rural",
    age = "Age",
    age_group = "Age group",
    seeing_diff_new = "Difficulty in seeing",
    hearing_diff_new = "Difficulty in hearing",
    mobility_diff_new = "Difficulty in walking",
    cognitive_diff_new = "Difficulty in cognitive",
    selfcare_diff_new = "Difficulty in selfcare",
    comm_diff_new = "Difficulty in communication",
    func_difficulty = "Functional difficulty",
    disability_any = "Any Difficulty",
    disability_some = "Some Difficulty",
    disability_atleast = "At least a lot of difficulty",
    seeing_any = "Any Difficulty in seeing",
    hearing_any = "Any Difficulty in hearing",
    mobile_any = "Any Difficulty in walking",
    cognition_any = "Any Difficulty in cognition",
    selfcare_any = "Any Difficulty in selfcare",
    communicating_any = "Any Difficulty in communicating",
    seeing_some = "Some Difficulty in seeing",
    hearing_some = "Some Difficulty in hearing",
    mobile_some = "Some Difficulty in walking",
    cognition_some = "Some Difficulty in cognition",
    selfcare_some = "Some Difficulty in selfcare",
    communicating_some = "Some Difficulty in communicating",
    seeing_atleast_alot = "At least a lot Difficulty in seeing",
    hearing_atleast_alot = "At least a lot Difficulty in hearing",
    mobile_atleast_alot = "At least a lot Difficulty in walking",
    cognition_atleast_alot = "At least a lot Difficulty in cognition",
    selfcare_atleast_alot = "At least a lot Difficulty in selfcare",
    communicating_atleast_alot = "At least a lot Difficulty in communicating",
    func_difficulty_hh = "Max Difficulty in HH",
    disability_any_hh = "P3 Any difficulty in Any Domain for any adult in the hh",
    disability_some_hh = "P3 Some difficulty in Any Domain for any adult in the hh",
    disability_atleast_hh = "P3 At least a lot of difficulty in Any Domain for any adult in the hh",
    edattain_new = "1 Less than Prim 2 Prim 3 Sec 4 Higher",
    everattended_new = "Ever attended school",
    ind_atleastprimary = "Primary school completion or higher adults 25+",
    ind_atleastprimary_all = "Primary school completion or higher adults 15+",
    ind_atleastsecondary = "Upper secondary school completion or higher adults 25+",
    lit_new = "Literacy",
    school_new = "Currently attending school",
    computer = "Individual uses computer",
    internet = "Individual uses internet",
    mobile_own = "Adult owns mobile phone",
    ind_emp = "Employed",
    youth_idle = "Youth is idle",
    work_manufacturing = "In manufacturing",
    work_managerial = "Women in managerial position",
    work_informal = "Informal work",
    ind_water = "Safely managed water source",
    ind_toilet = "Safely managed sanitation",
    fp_demsat_mod = "H3_Family_planning",
    anyviolence_byh_12m = "Experienced any violence last 12 months",
    ind_electric = "Electricity",
    ind_cleanfuel = "Clean cooking fuel",
    ind_floor = "Floor quality",
    ind_wall = "Wall quality",
    ind_roof = "Roof quality",
    ind_livingcond = "Adequate housing",
    ind_radio = "Household has radio",
    ind_tv = "Household has television",
    ind_refrig = "Household has refrigerator",
    ind_bike = "Household has bike",
    ind_motorcycle = "Household has motorcycle",
    ind_phone = "Household has telephone",
    ind_computer = "Household has computer",
    ind_autos = "Household has automobile",
    cell_new = "Household has mobile / Individual with cell",
    ind_asset_ownership = "Share of Assets",
    health_insurance = "Adults with a health insurance coverage",
    social_prot = "Household received any transfer or social protection",
    food_insecure = "Food insecurity in past week/year",
    shock_any = "Experienced any negative shock",
    health_exp_hh = "Health expenditure share",
    deprive_educ = "Deprived if less than primary school completion",
    deprive_health_water = "Deprived in water",
    deprive_health_sanitation = "Deprived in sanitation",
    deprive_work = "Deprived in work",
    deprive_sl_electricity = "Deprived for electricity",
    deprive_sl_fuel = "Deprived in terms of clean fuel",
    deprive_sl_housing = "Deprived housing",
    deprive_sl_asset = "Deprived assets",
    mdp_score = "Multidimensional poverty Score",
    ind_mdp = "M1 Multidimensional Poverty status"
  )

  #**STEP 3 — Keep only the listed variables*

  cleaned <- cleaned %>% select(all_of(vars_to_check))

  #***STEP 4 — Order variables**
  #cleaned <- cleaned %>% select(all_of(vars_to_check))

  # Optional: save the dataset with missing indicators
  dck <- cleaned
  save(dck, file = paste0(cen_dir, "South Africa_Census_2022.RData"))
  file.remove(paste0(
    cen_dir,
    c(
      "zaf1.rds",
      "zaf2.rds",
      "zaf3.rds",
      "zaf4.rds",
      "zaf5.rds",
      "sa_cleaned_with_missing.rds"
    )
  ))
  rm(cleaned, dck, vars_to_check, v)
}

load(paste0(cen_dir, "South Africa_Census_2022.RData"))
