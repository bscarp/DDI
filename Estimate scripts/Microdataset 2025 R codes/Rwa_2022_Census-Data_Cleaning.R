# ---
# title: Rwanda Census 2022 Data cleaning
# author:
# - name: Faith Sikuku
#   affiliation: University of Nairobi
# ---

#**Load  the necessary libraries*
library(haven)
library(future)
# Load packages
library(tidyverse)
library(janitor)
library(labelled)

#Load the dataset
cen_dir = str_extract(getwd(), "[c,C]:\\/Users\\/.+?\\/")
rw_NotClean <- read_dta(paste0(
  cen_dir,
  "/Downloads/Census/Stata Datasets/PHC5_Public_microdata.dta"
))

#**Dropping bellow 15 years*
rw_NotClean <- rw_NotClean %>%
  filter(p04 >= 15) %>% #drop if age < 15
  mutate(p04 = ifelse(p04 == 999, NA, p04)) #replace 999 with NA

#Load the dataset
rw_NotClean1 <- rw_NotClean

#**IDs*
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    # --- Country Information ---
    country_name = "Rwanda",
    country_abrev = "RW",
    country_dataset_year = "Census_2022",

    # --- Administrative Levels ---
    admin1 = haven::as_factor(ml01), # Province
    admin2 = haven::as_factor(ml02), # District
    admin3 = haven::as_factor(ml03), #sector-optional

    # --- Household and Individual IDs ---
    hh_id = hhid,
    ind_id = p01,

    # --- Weights ---
    hh_weight = HH_weight,
    ind_weight = Pop_weight
  )

#**Renaming the Age variable as age*
rw_NotClean1 <- rw_NotClean1 %>%
  rename(age = p04)

##**Adding the age_group variable*
rw_NotClean1 <- rw_NotClean1 %>%
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


#**Converting the Sex variable into binary to enable  numerical analysis*
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    female = case_when(
      p03 == 2 ~ 1, # Female -> 1
      p03 == 1 ~ 0, # Male -> 0
      TRUE ~ NA_real_ # Any missing or other values -> NA
    )
  )

table(rw_NotClean1$female, useNA = "ifany")


#**urban/rural binary*
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    urban_new = case_when(
      ml07 == 1 ~ 1, # Urban
      ml07 == 2 ~ 0, # Rural
      ml07 == 9 ~ NA_real_, # Missing / Unknown
      TRUE ~ NA_real_ # Other values become NA
    )
  )


#**The Functional Difficulties*
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    # --- Washington Group individual difficulty variables ---
    seeing_diff_new = ifelse(p15b <= 3, p15b, NA_real_),
    hearing_diff_new = ifelse(p16b <= 3, p16b, NA_real_),
    mobility_diff_new = ifelse(p17b <= 3, p17b, NA_real_),
    cognitive_diff_new = ifelse(p19b <= 3, p19b, NA_real_),
    selfcare_diff_new = ifelse(p20b <= 3, p20b, NA_real_),
    comm_diff_new = ifelse(p18b <= 3, p18b, NA_real_)
  )


#**Drop rows that have NAs in all the six domains*
new_domains <- c(
  "seeing_diff_new",
  "hearing_diff_new",
  "mobility_diff_new",
  "cognitive_diff_new",
  "selfcare_diff_new",
  "comm_diff_new"
)

rw_NotClean1 <- rw_NotClean1 %>%
  # 1. Drop rows where all six domains are missing
  filter(rowSums(!is.na(across(all_of(new_domains)))) > 0) %>%

  # 2. Calculate functional difficulty (max across the six domains)
  mutate(
    func_difficulty = do.call(
      pmax,
      c(select(., all_of(new_domains)), na.rm = TRUE)
    )
  )


#*** Count missing values*
sum(is.na(rw_NotClean1$func_difficulty))
sum(is.na(rw_NotClean1$age))
sum(is.na(rw_NotClean1$female))
sum(is.na(rw_NotClean1$urban_new))

#**** Count where urban_new OR func_difficulty is missing*
sum(is.na(rw_NotClean1$urban_new) | is.na(rw_NotClean1$func_difficulty))

# 4. Drop cases with missing in either urban_new or func_difficulty
rw_NotClean1 <- rw_NotClean1 %>%
  filter(!is.na(urban_new) & !is.na(func_difficulty))


#**Disability levels for any domains*
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    disability_any = case_when(
      is.na(func_difficulty) ~ NA_real_,
      func_difficulty >= 1 ~ 1,
      TRUE ~ 0
    ),
    disability_some = case_when(
      is.na(func_difficulty) ~ NA_real_,
      func_difficulty == 1 ~ 1,
      TRUE ~ 0
    ),
    disability_alot = case_when(
      is.na(func_difficulty) ~ NA_real_,
      func_difficulty == 2 ~ 1,
      TRUE ~ 0
    ),
    disability_unable = case_when(
      is.na(func_difficulty) ~ NA_real_,
      func_difficulty == 3 ~ 1,
      TRUE ~ 0
    ),
    disability_atleast = case_when(
      is.na(func_difficulty) ~ NA_real_,
      func_difficulty >= 2 ~ 1,
      TRUE ~ 0
    ),
    disability_none = case_when(
      is.na(func_difficulty) ~ NA_real_,
      func_difficulty == 0 ~ 1, # no difficulty
      TRUE ~ 0
    ),

    disability_nonesome = case_when(
      is.na(func_difficulty) ~ NA_real_,
      func_difficulty %in% c(0, 1) ~ 1, # none OR some
      TRUE ~ 0
    )
  )


#**Any difficulty *
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    seeing_any = case_when(
      is.na(seeing_diff_new) ~ NA_real_,
      seeing_diff_new >= 1 ~ 1,
      TRUE ~ 0
    ),
    hearing_any = case_when(
      is.na(hearing_diff_new) ~ NA_real_,
      hearing_diff_new >= 1 ~ 1,
      TRUE ~ 0
    ),
    mobile_any = case_when(
      is.na(mobility_diff_new) ~ NA_real_,
      mobility_diff_new >= 1 ~ 1,
      TRUE ~ 0
    ),
    cognition_any = case_when(
      is.na(cognitive_diff_new) ~ NA_real_,
      cognitive_diff_new >= 1 ~ 1,
      TRUE ~ 0
    ),
    selfcare_any = case_when(
      is.na(selfcare_diff_new) ~ NA_real_,
      selfcare_diff_new >= 1 ~ 1,
      TRUE ~ 0
    ),
    communicating_any = case_when(
      is.na(comm_diff_new) ~ NA_real_,
      comm_diff_new >= 1 ~ 1,
      TRUE ~ 0
    )
  )

#**Some difficulty *
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    seeing_some = case_when(
      is.na(seeing_diff_new) ~ NA_real_,
      seeing_diff_new == 1 ~ 1,
      TRUE ~ 0
    ),
    hearing_some = case_when(
      is.na(hearing_diff_new) ~ NA_real_,
      hearing_diff_new == 1 ~ 1,
      TRUE ~ 0
    ),
    mobile_some = case_when(
      is.na(mobility_diff_new) ~ NA_real_,
      mobility_diff_new == 1 ~ 1,
      TRUE ~ 0
    ),
    cognition_some = case_when(
      is.na(cognitive_diff_new) ~ NA_real_,
      cognitive_diff_new == 1 ~ 1,
      TRUE ~ 0
    ),
    selfcare_some = case_when(
      is.na(selfcare_diff_new) ~ NA_real_,
      selfcare_diff_new == 1 ~ 1,
      TRUE ~ 0
    ),
    communicating_some = case_when(
      is.na(comm_diff_new) ~ NA_real_,
      comm_diff_new == 1 ~ 1,
      TRUE ~ 0
    )
  )

#***At least a lot of difficulty *
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    seeing_alot = case_when(
      is.na(seeing_diff_new) ~ NA_real_,
      seeing_diff_new == 2 ~ 1,
      TRUE ~ 0
    ),
    hearing_alot = case_when(
      is.na(hearing_diff_new) ~ NA_real_,
      hearing_diff_new == 2 ~ 1,
      TRUE ~ 0
    ),
    mobile_alot = case_when(
      is.na(mobility_diff_new) ~ NA_real_,
      mobility_diff_new == 2 ~ 1,
      TRUE ~ 0
    ),
    cognition_alot = case_when(
      is.na(cognitive_diff_new) ~ NA_real_,
      cognitive_diff_new == 2 ~ 1,
      TRUE ~ 0
    ),
    selfcare_alot = case_when(
      is.na(selfcare_diff_new) ~ NA_real_,
      selfcare_diff_new == 2 ~ 1,
      TRUE ~ 0
    ),
    communicating_alot = case_when(
      is.na(comm_diff_new) ~ NA_real_,
      comm_diff_new == 2 ~ 1,
      TRUE ~ 0
    )
  )

#***At least a lot of difficulty *
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    seeing_unable = case_when(
      is.na(seeing_diff_new) ~ NA_real_,
      seeing_diff_new == 3 ~ 1,
      TRUE ~ 0
    ),
    hearing_unable = case_when(
      is.na(hearing_diff_new) ~ NA_real_,
      hearing_diff_new == 3 ~ 1,
      TRUE ~ 0
    ),
    mobile_unable = case_when(
      is.na(mobility_diff_new) ~ NA_real_,
      mobility_diff_new == 3 ~ 1,
      TRUE ~ 0
    ),
    cognition_unable = case_when(
      is.na(cognitive_diff_new) ~ NA_real_,
      cognitive_diff_new == 3 ~ 1,
      TRUE ~ 0
    ),
    selfcare_unable = case_when(
      is.na(selfcare_diff_new) ~ NA_real_,
      selfcare_diff_new == 3 ~ 1,
      TRUE ~ 0
    ),
    communicating_unable = case_when(
      is.na(comm_diff_new) ~ NA_real_,
      comm_diff_new == 3 ~ 1,
      TRUE ~ 0
    )
  )

#***At least a lot of difficulty *
rw_NotClean1 <- rw_NotClean1 %>%
  mutate(
    seeing_atleast_alot = case_when(
      is.na(seeing_diff_new) ~ NA_real_,
      seeing_diff_new >= 2 ~ 1,
      TRUE ~ 0
    ),
    hearing_atleast_alot = case_when(
      is.na(hearing_diff_new) ~ NA_real_,
      hearing_diff_new >= 2 ~ 1,
      TRUE ~ 0
    ),
    mobile_atleast_alot = case_when(
      is.na(mobility_diff_new) ~ NA_real_,
      mobility_diff_new >= 2 ~ 1,
      TRUE ~ 0
    ),
    cognition_atleast_alot = case_when(
      is.na(cognitive_diff_new) ~ NA_real_,
      cognitive_diff_new >= 2 ~ 1,
      TRUE ~ 0
    ),
    selfcare_atleast_alot = case_when(
      is.na(selfcare_diff_new) ~ NA_real_,
      selfcare_diff_new >= 2 ~ 1,
      TRUE ~ 0
    ),
    communicating_atleast_alot = case_when(
      is.na(comm_diff_new) ~ NA_real_,
      comm_diff_new >= 2 ~ 1,
      TRUE ~ 0
    )
  )

#***Household  level disability***
rw_NotClean1 <- rw_NotClean1 %>%
  group_by(hh_id) %>%
  mutate(
    func_difficulty_hh = max(func_difficulty, na.rm = TRUE)
  ) %>%
  ungroup() %>%

  mutate(
    func_difficulty_hh = ifelse(
      is.infinite(func_difficulty_hh),
      NA_real_,
      func_difficulty_hh
    ),

    disability_any_hh = ifelse(
      !is.na(func_difficulty_hh) & func_difficulty_hh >= 1,
      1,
      ifelse(!is.na(func_difficulty_hh), 0, NA_real_)
    ),

    disability_some_hh = ifelse(
      !is.na(func_difficulty_hh) & func_difficulty_hh == 1,
      1,
      ifelse(!is.na(func_difficulty_hh), 0, NA_real_)
    ),

    disability_alot_hh = ifelse(
      !is.na(func_difficulty_hh) & func_difficulty_hh == 2,
      1,
      ifelse(!is.na(func_difficulty_hh), 0, NA_real_)
    ),

    disability_unable_hh = ifelse(
      !is.na(func_difficulty_hh) & func_difficulty_hh == 3,
      1,
      ifelse(!is.na(func_difficulty_hh), 0, NA_real_)
    ),

    disability_atleast_hh = ifelse(
      !is.na(func_difficulty_hh) & func_difficulty_hh >= 2,
      1,
      ifelse(!is.na(func_difficulty_hh), 0, NA_real_)
    )
  )

##**Mnipulating the Six Domains -Education*
# Load the data back to continue with manipulation
rw_NotClean2 <- rw_NotClean1

##**Education*

##**Education attainment*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    p30b_clean = ifelse(p30b == 99, NA, p30b),

    edattain_new = case_when(
      # Category 1: No education / Nursery / Incomplete primary
      p30a == 1 |
        p30a == 2 |
        (p30a == 3 & p30b_clean < 6) ~ 1,

      # Category 2: Completed primary / Vocational / Lower secondary / Incomplete upper secondary
      (p30a == 3 & p30b_clean >= 6) |
        p30a == 4 |
        p30a == 5 |
        (p30a == 6 & p30b_clean < 3) ~ 2,

      # Category 3: Completed upper secondary
      (p30a == 6 & p30b_clean >= 3) ~ 3,

      # Category 4: Tertiary
      p30a == 7 ~ 4,

      TRUE ~ NA_real_
    )
  )


#**Ever attended school*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    everattended_new = case_when(
      is.na(p30a) ~ NA_real_, # if missing
      p30a <= 2 ~ 0, # None
      p30a > 2 ~ 1 # Pre-primary or higher
    )
  )

rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    not_in_school = case_when(
      p29 %in% c(9, 99) | is.na(p29) ~ NA_real_, # Not started / missing
      p29 == 2 ~ 0, # Currently attending → in school
      p29 %in% c(1, 3) ~ 1 # Previously attended or never → not in school
    )
  )


##**At least primary school*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    ind_atleastprimary = case_when(
      is.na(edattain_new) ~ NA_real_, # If education missing → missing
      age < 25 ~ NA_real_, # If age < 25 → missing
      edattain_new >= 2 ~ 1, # Completed at least primary
      edattain_new < 2 ~ 0 # Did not complete primary
    )
  )


###**variable for ages 15+ used for the deprivation variable for multidimensional poverty*
#** atleast primary all variable*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    ind_atleastprimary_all = case_when(
      is.na(edattain_new) ~ NA_real_, # same as replace ... if edattain_new==.
      edattain_new >= 2 ~ 1, # completed at least primary
      TRUE ~ 0 # did not complete primary
    )
  )

##**At least secondary*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    ind_atleastsecondary = case_when(
      is.na(edattain_new) ~ NA_real_, # same as replace ... if edattain_new==.
      age < 25 ~ NA_real_, # same as replace ... if age<25
      edattain_new >= 3 ~ 1, # completed at least secondary
      TRUE ~ 0 # edattain_new < 3
    )
  )


##**literacy rate*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    lit_new = case_when(
      p32 == 0 ~ 0, # None → Not literate
      p32 %in% 1:31 ~ 1, # Any language(s) including 'Other' → literate
      p32 == 99 ~ NA_real_, # Not stated → missing
      TRUE ~ NA_real_
    )
  )


##**Currently attending school*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    school_new = case_when(
      p29 == 2 ~ 1, # currently attending
      p29 %in% c(1, 3) ~ 0, # previously attended or never attended → currently not attending
      p29 == 99 ~ NA_real_, # Not stated
      TRUE ~ NA_real_
    )
  )

table(rw_NotClean2$school_new, useNA = "ifany")

#**Computer***
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    computer = NA_real_
  )

#***Internet use and Mobile own***
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    internet = case_when(
      p34 == 1 ~ 1,
      p34 == 2 ~ 0,
      p34 == 9 ~ NA_real_,
      TRUE ~ NA_real_
    ),

    mobile_own = case_when(
      p36c %in% c(1:3) ~ 1,
      p36c == 0 ~ 0,
      TRUE ~ NA_real_
    )
  )


##**Employment status*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    ind_emp = if_else(is.na(p49), 0, 1)
  )

##**Manufacturing*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    work_manufacturing = case_when(
      is.na(p47a) ~ NA_real_, # true missing
      p47a == 22 ~ NA_real_, # "not stated"
      p47a == 3 ~ 1, # manufacturing
      TRUE ~ 0 # all other valid industries
    ),
    # override for non-employed
    work_manufacturing = if_else(
      ind_emp == 0,
      NA_real_,
      work_manufacturing
    )
  )


##** Women in Managerial positions*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    # Treat 99 as missing
    p48a_clean = na_if(p48a, 99),

    # Step 1: Managerial occupation
    work_managerial = case_when(
      is.na(p48a_clean) ~ NA_real_, # missing occupation
      p48a_clean == 1 ~ 1, # managers
      TRUE ~ 0 # all other occupations
    ),

    # Step 2: if not employed → 0
    work_managerial = if_else(
      ind_emp == 0 | is.na(ind_emp),
      NA_real_,
      work_managerial
    ),

    # Step 3: if male → NA
    work_managerial = if_else(
      female == 0,
      NA_real_,
      work_managerial
    )
  )


##**Informal employment**
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    work_informal = case_when(
      is.na(p49) ~ NA_real_,
      p49 %in% c(4, 5, 6, 7) ~ 1, # informal statuses
      p49 %in% c(1, 2, 3) ~ 0, # formal statuses
      TRUE ~ NA_real_
    )
  )


#***Youth Idle rate*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    youth_idle = case_when(
      is.na(ind_emp) & is.na(school_new) ~ NA_real_, # both missing
      age > 24 ~ NA_real_, # age above 24
      ind_emp == 0 & school_new == 0 ~ 1, # not employed and not in school
      TRUE ~ 0 # all others
    )
  )


##**Health Indicator*
#**Water*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    ind_water = case_when(
      h12 %in% c(1, 2, 3, 4, 5, 6, 8, 12) ~ 1, # safe/improved
      h12 %in% c(7, 9, 10, 11, 13) ~ 0, # unsafe/unimproved
      h12 == 99 ~ NA_real_, # missing / not stated
      TRUE ~ NA_real_
    )
  )

#** Safe sanitation*
#**toilet*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    ind_toilet = case_when(
      h13 %in% c(1, 3) ~ 1, # improved toilet and not shared
      h13 %in% c(2, 4, 5, 6, 7, 8) ~ 0, # unimproved toilet/improved but shared
      h13 == 99 ~ NA_real_, # missing / not stated
      TRUE ~ NA_real_
    )
  )

#**Family Planning* Place holder
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    fp_demsat_mod = NA_real_ # variable created, filled with missing values
  )

#**Experienced any violence*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    anyviolence_byh_12m = NA_real_ # variable created, filled with missing values
  )

#**BMI calculation*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    bmi = NA_real_ # Place holder for bmi
  )

#** Obese/overweight calculation*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    overweight_obese = NA_real_
  )

#** Problems in Healthcare access*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    healthcare_prob = NA_real_
  )

##** Child mortality*
#unique(RwA_NotClean1$)
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    child_died = NA_real_
  )

#**Household deaths*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    death_hh = NA_real_
  )

#**Standard of living indicators*
#**Electricity*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    ind_electric = case_when(
      h15 == 99 ~ NA_real_,
      h15 %in% c(1, 2, 3, 4) ~ 1,
      h15 %in% c(5:14) ~ 0,
      TRUE ~ NA_real_
    )
  )

#** Clean cooking fuel*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    ind_cleanfuel = case_when(
      h16 %in% c(15, 99) ~ NA_real_,
      h16 %in% c(3, 4, 6, 7) ~ 1,
      h16 %in% c(1, 2, 5, 8, 9, 10, 11, 12, 13, 14) ~ 0,
      TRUE ~ NA_real_
    )
  )

#**Adequate housing*
#*** floor quality*
rw_NotClean2 = rw_NotClean2 %>%
  mutate(
    ind_floor = case_when(
      h07 %in% c(10, 99) ~ NA_real_,
      h07 %in% c(3, 5, 7, 8) ~ 1,
      h07 %in% c(1, 2, 4, 6, 9) ~ 0,
      TRUE ~ NA_real_
    )
  )

#***wall quality*
rw_NotClean2 = rw_NotClean2 %>%
  mutate(
    ind_wall = case_when(
      h06 == 99 ~ NA_real_,
      h06 %in% c(6, 7, 8, 10, 11) ~ 1,
      h06 %in% c(1:5, 9, 12, 13) ~ 0,
      TRUE ~ NA_real_
    )
  )

#***roof*
rw_NotClean2 = rw_NotClean2 %>%
  mutate(
    ind_roof = case_when(
      h05 == 9 ~ NA_real_,
      h05 %in% c(1, 2, 3, 5) ~ 1,
      h05 %in% c(4, 6, 7, 8) ~ 0,
      TRUE ~ NA_real_
    )
  )

#***living conditions*
rw_NotClean2 = rw_NotClean2 %>%
  mutate(
    ind_livingcond = case_when(
      ind_roof == 1 & ind_floor == 1 & ind_wall == 1 ~ 1,
      is.na(ind_roof) | is.na(ind_floor) | is.na(ind_wall) ~ NA_real_,
      TRUE ~ 0
    )
  )

#*** Asset ownership*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    # Radio
    ind_radio = case_when(
      h21_01 == 1 ~ 1,
      h21_01 == 2 ~ 0,
      TRUE ~ NA_real_
    ),

    # TV
    ind_tv = case_when(
      h21_02 == 1 ~ 1,
      h21_02 == 2 ~ 0,
      TRUE ~ NA_real_ # all missing
    ),

    # Bicycle
    ind_bike = case_when(
      h21_15 == 1 ~ 1,
      h21_15 == 2 ~ 0,
      TRUE ~ NA_real_
    ),

    # Motorcycle
    ind_motorcycle = case_when(
      h21_14 == 1 ~ 1,
      h21_14 == 2 ~ 0,
      TRUE ~ NA_real_
    ),

    # Refrigerator
    ind_refrig = case_when(
      h21_03 == 1 ~ 1,
      h21_03 == 2 ~ 0,
      TRUE ~ NA_real_
    ),
    #phonee
    ind_phone = NA_real_,

    # Computer
    ind_computer = case_when(
      h21_12 == 1 ~ 1,
      h21_12 == 2 ~ 0,
      TRUE ~ NA_real_
    ),

    # Automobiles
    ind_autos = case_when(
      h21_13 == 1 ~ 1,
      h21_13 == 2 ~ 0,
      TRUE ~ NA_real_
    ),
    cell_new = NA_real_
  )


#**Asset owned*

# Compute the mean of asset ownership indicators for each household/individual
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    ind_asset_ownership = rowMeans(
      select(
        .,
        ind_radio,
        ind_tv,
        ind_refrig,
        ind_phone,
        cell_new,
        ind_bike,
        ind_motorcycle,
        ind_autos,
        ind_computer
      ),
      na.rm = TRUE
    )
  )

#***Insecurity indicators*
#**Medical insurance*
rw_NotClean2 <- rw_NotClean2 %>%
  mutate(
    health_insurance = case_when(
      p14 %in% c(9, 99) ~ NA_real_,
      p14 %in% c(1:7) ~ 1,
      p14 == 8 ~ 0,
      TRUE ~ NA_real_
    )
  )
table(rw_NotClean2$health_insurance, useNA = "ifany")

#**Social protection*
rw_NotClean2 = rw_NotClean2 %>%
  mutate(social_prot = NA_real_)


#***food insecurity*
rw_NotClean2 = rw_NotClean2 %>%
  mutate(food_insecure = NA_real_)


#***Negative shock*
rw_NotClean2 = rw_NotClean2 %>%
  mutate(shock_any = NA_real_)


#**Social protection*
rw_NotClean2 = rw_NotClean2 %>%
  mutate(health_exp_hh = NA_real_)


#**Multidimensional poverty *
rw_NotClean2 <- rw_NotClean2 %>%
  #--------------------------
  # 1. Deprivation indicators
  #--------------------------
  mutate(
    labor_tag = ifelse(!is.na(ind_emp), 1, 0),

    # Education
    deprive_educ = case_when(
      labor_tag == 0 & is.na(ind_atleastprimary_all) ~ NA_real_,
      labor_tag == 0 & ind_atleastprimary_all == 0 ~ 0.33,
      labor_tag == 0 & ind_atleastprimary_all == 1 ~ 0,
      labor_tag == 1 & is.na(ind_atleastprimary_all) ~ NA_real_,
      labor_tag == 1 & ind_atleastprimary_all == 0 ~ 0.25,
      labor_tag == 1 & ind_atleastprimary_all == 1 ~ 0
    ),

    # Work
    deprive_work = case_when(
      labor_tag == 0 ~ NA_real_,
      labor_tag == 1 & is.na(ind_emp) ~ NA_real_,
      labor_tag == 1 & ind_emp == 0 ~ 0.25,
      labor_tag == 1 & ind_emp == 1 ~ 0
    ),

    # Binary indicators (Health + SL)
    deprive_health_water = ifelse(
      is.na(ind_water),
      NA_real_,
      ifelse(ind_water == 0, 1, 0)
    ),
    deprive_health_sanitation = ifelse(
      is.na(ind_toilet),
      NA_real_,
      ifelse(ind_toilet == 0, 1, 0)
    ),
    deprive_sl_electricity = ifelse(
      is.na(ind_electric),
      NA_real_,
      ifelse(ind_electric == 0, 1, 0)
    ),
    deprive_sl_fuel = ifelse(
      is.na(ind_cleanfuel),
      NA_real_,
      ifelse(ind_cleanfuel == 0, 1, 0)
    ),
    deprive_sl_housing = ifelse(
      is.na(ind_livingcond),
      NA_real_,
      ifelse(ind_livingcond == 0, 1, 0)
    )
  ) %>%

  #-----------------------
  # 2. Asset deprivation
  #-----------------------
  mutate(
    all_missing_assets = rowSums(is.na(cbind(
      ind_radio,
      ind_tv,
      ind_phone,
      ind_refrig,
      ind_bike,
      ind_motorcycle,
      ind_autos
    ))) ==
      7,

    asset_count = rowSums(
      cbind(
        ind_radio,
        ind_tv,
        ind_phone,
        ind_refrig,
        ind_bike,
        ind_motorcycle
      ) ==
        1,
      na.rm = FALSE
    ),

    deprive_sl_asset = case_when(
      all_missing_assets ~ NA_real_,
      asset_count < 2 & ind_autos == 0 ~ 1,
      TRUE ~ 0
    )
  ) %>%

  #-----------------------------
  # 3. Health dimension weights
  #-----------------------------
  mutate(
    missing_health = rowSums(
      !is.na(cbind(deprive_health_water, deprive_health_sanitation))
    ),
    health_temp = rowSums(
      cbind(deprive_health_water, deprive_health_sanitation),
      na.rm = TRUE
    ),

    deprive_health = case_when(
      labor_tag == 0 & missing_health > 0 ~ (1 / missing_health) *
        0.33 *
        health_temp,
      labor_tag == 1 & missing_health > 0 ~ (1 / missing_health) *
        0.25 *
        health_temp,
      TRUE ~ NA_real_
    )
  ) %>%

  #---------------------------------------
  # 4. Living standards weighted dimension
  #---------------------------------------
  mutate(
    missing_sl = rowSums(
      !is.na(cbind(
        deprive_sl_electricity,
        deprive_sl_fuel,
        deprive_sl_housing,
        deprive_sl_asset
      ))
    ),
    sl_temp = rowSums(
      cbind(
        deprive_sl_electricity,
        deprive_sl_fuel,
        deprive_sl_housing,
        deprive_sl_asset
      ),
      na.rm = TRUE
    ),

    deprive_sl = case_when(
      labor_tag == 0 & missing_sl > 0 ~ (1 / missing_sl) * 0.33 * sl_temp,
      labor_tag == 1 & missing_sl > 0 ~ (1 / missing_sl) * 0.25 * sl_temp,
      TRUE ~ NA_real_
    )
  ) %>%

  #-----------------------------
  # 5. Total MPI score + binary
  #-----------------------------
  mutate(
    mdp_score = case_when(
      labor_tag == 0 ~ deprive_educ + deprive_health + deprive_sl,
      labor_tag == 1 ~ deprive_educ + deprive_work + deprive_health + deprive_sl
    ),

    ind_mdp = case_when(
      labor_tag == 1 & mdp_score > 0.25 ~ 1,
      labor_tag == 0 & mdp_score > 0.33 ~ 1,
      !is.na(mdp_score) ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%

  #--------------------------------
  # 6. Automatic variable labeling
  #--------------------------------
  set_variable_labels(
    labor_tag = "Employment info available (1=Yes,0=No)",
    deprive_educ = "Education deprivation score",
    deprive_work = "Work deprivation score",
    deprive_health_water = "Water deprivation (binary)",
    deprive_health_sanitation = "Sanitation deprivation (binary)",
    deprive_sl_electricity = "Electricity deprivation (binary)",
    deprive_sl_fuel = "Clean fuel deprivation (binary)",
    deprive_sl_housing = "Housing deprivation (binary)",
    deprive_sl_asset = "Asset ownership deprivation (binary)",
    deprive_health = "Weighted health deprivation",
    deprive_sl = "Weighted living standards deprivation",
    mdp_score = "Total MPI score",
    ind_mdp = "MPI poor indicator"
  )

#Load the dataset back for further manipulation
rw_NotClean3 <- rw_NotClean2

rw_NotClean3 <- rw_NotClean3 %>%
  # Step 1: Identify missing functional difficulty
  mutate(
    func_diff_missing = rowSums(is.na(select(
      .,
      seeing_diff_new,
      hearing_diff_new,
      cognitive_diff_new,
      mobility_diff_new,
      selfcare_diff_new,
      comm_diff_new
    ))),
    ind_func_diff_missing = as.integer(func_diff_missing == 6) # 1/0 like Stata
  ) %>%

  # Step 2: Identify missing disaggregation variables
  mutate(
    ind_disaggvar_missing = as.integer(
      is.na(female) | is.na(age) | is.na(urban_new)
    ) # 1/0 like Stata
  )

dck <- rw_NotClean3

# Step 3: Drop rows
dck <- dck %>%
  filter(ind_func_diff_missing != 1, ind_disaggvar_missing != 1)


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
  "hearing_alot",
  "mobile_alot",
  "cognition_alot",
  "selfcare_alot",
  "communicating_alot",
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
  "bmi",
  "overweight_obese",
  "healthcare_prob",
  "alone"
)

# Add missing variables as NA
for (v in vars_to_check) {
  if (!v %in% names(dck)) {
    dck[[v]] <- NA_real_
    message(v, " added")
  } else {
    message(v, " exists")
  }
}


#***2. ADD VARIABLE LABELS*

var_label(dck) <- list(
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
  disability_any = "Any difficulty",
  disability_some = "Some difficulty",
  disability_alot = "A lot of difficulty",
  disability_unable = "Cannot do at all",
  disability_atleast = "At least a lot of difficulty",
  seeing_any = "Any difficulty in seeing",
  hearing_any = "Any difficulty in hearing",
  mobile_any = "Any difficulty in walking",
  cognition_any = "Any difficulty in cognition",
  selfcare_any = "Any difficulty in selfcare",
  communicating_any = "Any difficulty in communicating",
  seeing_some = "Some difficulty in seeing",
  hearing_some = "Some difficulty in hearing",
  mobile_some = "Some difficulty in walking",
  cognition_some = "Some difficulty in cognition",
  selfcare_some = "Some difficulty in selfcare",
  communicating_some = "Some difficulty in communicating",
  seeing_alot = "Alot ofdifficulty in seeing",
  hearing_alot = "Alot of difficulty in hearing",
  mobile_alot = "Alot of difficulty in walking",
  cognition_alot = "Alot of difficulty in cognition",
  selfcare_alot = "Alot of difficulty in selfcare",
  communicating_alot = "Alot of difficulty in communicating",
  seeing_unable = "Cannot see at all",
  hearing_unable = "Cannot hear at all",
  mobile_unable = "Cannot walk at all",
  cognition_unable = "Cannot concentrate/remember at all",
  selfcare_unable = "Cannot care for oneself at all",
  communicating_unable = "Cannot communicate at all",
  seeing_atleast_alot = "At least a lot difficulty in seeing",
  hearing_atleast_alot = "At least a lot difficulty in hearing",
  mobile_atleast_alot = "At least a lot difficulty in walking",
  cognition_atleast_alot = "At least a lot difficulty in cognition",
  selfcare_atleast_alot = "At least a lot difficulty in selfcare",
  communicating_atleast_alot = "At least a lot difficulty in communicating",
  func_difficulty_hh = "Max Difficulty in HH",
  disability_any_hh = "P3 Any difficulty in Any Domain for any adult in the hh",
  disability_some_hh = "P3 Some difficulty in Any Domain for any adult in the hh",
  disability_alot_hh = "P3 Alot of difficulty in Any Domain for any adult in the hh",
  disability_unable_hh = "P3 Cannot do at all in Any Domain for any adult in the hh",
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

dck <- dck %>% select(all_of(vars_to_check))

#**Female at Managerial Work*
# *work_managerial is a binary for women in managerial work among all women while work_managerial2 code  women in managerial work among working women only.
#We use  work_managerial2  to generate the  women in managerial work   indicator for the DS-E database.

dck <- dck %>%
  mutate(
    work_managerial2 = case_when(
      ind_emp == 1 & work_managerial == 1 & female == 1 ~ 1,
      ind_emp == 1 & female == 1 ~ 0,
      is.na(ind_emp) & is.na(work_managerial) ~ NA_real_,
      TRUE ~ NA_real_
    )
  )


#**Informal Work*
# *work_informal is a binary variable for informal work status among all adults while work_informal2 codes informal work among workers only.
#We use work_informal2 to generate the informal work indicator for the DS-E database.

dck <- dck %>%
  mutate(
    work_informal2 = case_when(
      ind_emp == 1 & work_informal == 1 ~ 1,
      ind_emp == 1 ~ 0,
      is.na(ind_emp) & is.na(work_informal) ~ NA_real_,
      TRUE ~ NA_real_
    )
  )

# Optional: save the dataset with missing indicators
save(
  dck,
  file = paste0(
    cen_dir,
    "/Downloads/Census/R Datasets/Rwanda_Census_2022.RData"
  )
)
