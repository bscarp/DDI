library(future)
library(doFuture)
options(future.globals.maxSize = 1e10)
library(foreach)
library(tidyverse)
library(googledrive)
library(readxl)
library(writexl)
library(arrow)
library(data.table)
library(dtplyr)
plan(multisession, workers = 4)

## Check what happens when disagg is NA !!!!
cen_dir = str_extract(getwd(), "[cC]:\\/Users\\/.+?\\/")
db_loc = c(paste0(cen_dir, "Downloads/Census/Database/Backup/"))

mean1 = read_xlsx(
  path = paste0(cen_dir, "Downloads/Census/Database/DS_E2_All_Estimates.xlsx")
)

key_m = read_xlsx("DS-D files/Key messages.xlsx")

order = paste0(
  rep(key_m$IndicatorName, each = 3),
  c("_mean", "_se", "_n")
)

diff_type = read_xlsx("DS-D files/difficulty_types.xlsx")
pop_type = read_xlsx("DS-D files/population_types.xlsx")

#Check for unprocessed summaries
sum_list = dir(paste0(cen_dir, "Downloads/Census/Summaries/"))
sum_list2 = str_extract(sum_list, ".*_.*_[0-9]{4}")
com_list = mean1 %>% pull(Survey) %>% unique()
run_list = sum_list[!sum_list2 %in% com_list]
svy_list = sum_list2[!sum_list2 %in% com_list]

#Run analysis for unprocessed datasets
processed = foreach(
  file = run_list,
  svy = svy_list,
  .verbose = FALSE,
  .combine = "c",
  .options.future = list(packages = c("tidyverse", "haven"))
) %dofuture%
  {
    ##Load data file created by DDI summary calculations.R
    tabs = NULL
    load(paste0(cen_dir, "Downloads/Census/Summaries/", file))

    db1 = tabs$tab_P1_nr %>%
      rename(disagg = Agg) %>%
      filter(disagg %in% pop_type$Clean) %>%
      mutate(
        disagg = recode_values(
          disagg,
          from = pop_type$Clean,
          to = pop_type$PopulationName
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
        ends_with("_any"),
        ends_with("_no_l")
      ) %>%
      filter(disagg %in% pop_type$Clean) %>%
      mutate(
        disagg = recode_values(
          disagg,
          from = pop_type$Clean,
          to = pop_type$PopulationName
        )
      )
    db3 = tabs$tab_P2_nr %>%
      rename(disagg = Agg) %>%
      filter(disagg %in% pop_type$Clean) %>%
      mutate(
        disagg = recode_values(
          disagg,
          from = pop_type$Clean,
          to = pop_type$PopulationName
        )
      )
    db4 = tabs$tab_P3_nr %>%
      rename(disagg = Agg) %>%
      filter(disagg %in% pop_type$Clean) %>%
      mutate(
        disagg = recode_values(
          disagg,
          from = pop_type$Clean,
          to = pop_type$PopulationName
        )
      )
    db5 = tabs$tab_P4_nr %>%
      rename(disagg = domain) %>%
      filter(!disagg == "disability_any")

    names(db1) = sub(
      "disability",
      "Adults with disabilities_disability",
      names(db1)
    )
    names(db1) = sub("mean_se", "se", names(db1))
    db1 = db1 %>%
      rename(any_of(setNames(
        paste0(
          "Adults with disabilities_",
          rep(diff_type$Clean, each = 3),
          c("_mean", "_se", "_n")
        ),
        paste0(
          "Adults with disabilities_",
          rep(diff_type$New_name, each = 3),
          c("_mean", "_se", "_n")
        )
      )))

    names(db2) = sub("mean_se", "se", names(db2))
    db2 = db2 %>%
      rename(any_of(setNames(
        paste0(
          rep(
            paste0(
              rep(key_m$Clean, each = 3),
              c("_mean", "_se", "_n")
            ),
            each = length(diff_type$Clean2[grepl(
              "disability",
              diff_type$Clean
            )])
          ),
          "_",
          diff_type$Clean2[grepl("disability", diff_type$Clean)]
        ),
        paste0(
          rep(
            paste0(
              rep(key_m$IndicatorName, each = 3),
              c("_mean", "_se", "_n")
            ),
            each = length(diff_type$New_name[grepl(
              "disability",
              diff_type$Clean
            )])
          ),
          "_",
          diff_type$New_name[grepl("disability", diff_type$Clean)]
        )
      )))
    names(db2) = sub(
      "(.*_)(.*)(_)(.*)",
      "\\1\\4\\3\\2",
      names(db2),
      fixed = FALSE
    )

    names(db3) = sub("mean_se", "se", names(db3))
    names(db3) = sub("_atleast_alot", "_atleast", names(db3))
    db3 = db3 %>%
      rename(any_of(setNames(
        paste0(
          rep(diff_type$Clean, each = 3),
          c("_mean", "_se", "_n")
        ),
        paste0(
          "Adults with disabilities_",
          rep(diff_type$New_name, each = 3),
          c("_mean", "_se", "_n")
        )
      )))

    names(db4) = sub("mean_se", "se", names(db4))
    names(db4) = sub("_hh", "", names(db4))
    db4 = db4 %>%
      rename(any_of(setNames(
        paste0(
          rep(diff_type$Clean, each = 3),
          c("_mean", "_se", "_n")
        ),
        paste0(
          "Households with disabilities_",
          rep(diff_type$New_name, each = 3),
          c("_mean", "_se", "_n")
        )
      )))

    names(db5) = sub("_mean_se", "_se", names(db5))
    db5 = db5 %>%
      pivot_longer(
        cols = contains("_"),
        names_to = c(".value", "type"),
        names_pattern = "(.*)_(.*)$"
      ) %>%
      pivot_wider(
        id_cols = c(admin, level),
        names_from = c(disagg, type),
        names_glue = "{.value}_{disagg}_{type}",
        values_from = where(is.numeric)
      ) %>%
      mutate(disagg = "All adults (ages 15 and older)", .before = admin)
    names(db5) = sub("_atleast_alot", "_atleast", names(db5))

    db5 = db5 %>%
      rename(any_of(setNames(
        paste0(
          rep(
            paste0(
              rep(
                key_m$Clean,
                each = length(diff_type$Clean2[
                  !grepl("disability", diff_type$Clean)
                ])
              ),
              "_",
              diff_type$Clean2[!grepl("disability", diff_type$Clean)]
            ),
            each = 3
          ),
          c("_mean", "_se", "_n")
        ),
        paste0(
          rep(
            paste0(
              rep(
                key_m$IndicatorName,
                each = length(diff_type$New_name[
                  !grepl("disability", diff_type$Clean)
                ])
              ),
              "_",
              diff_type$New_name[!grepl("disability", diff_type$Clean)]
            ),
            each = 3
          ),
          c("_mean", "_se", "_n")
        )
      )))

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

    df = df %>%
      mutate(
        admin = replace_values(
          admin,
          from = c("admin0", "admin1", "admin2", "admin_alt"),
          to = c(
            "National",
            "Subnational division 1",
            "Subnational division 2",
            "Alternative subnational division"
          )
        )
      )

    df2 = df %>%
      pivot_longer(
        cols = names(.)[-c(1:4)],
        names_to = c(".value", "DifficultyName", ".value"),
        names_pattern = "(.*)_(.*)(_.*)"
      )

    df2 = df2 %>%
      mutate(
        across(contains("_mean") | contains("_se"), ~ .x / 100),
        across(
          contains("Adults with disabilities"),
          ~ ifelse(DifficultyName == "nosome_difficulty", NA, .x)
        )
      )

    write_rds(df2, file = paste0(db_loc, svy, ".rds"), compress = "xz")

    rm(df, df2)
    gc()
    return(svy)
  }

#Create merged file
merged = list.files(db_loc, "*.rds", full.names = TRUE) %>%
  map(read_rds) %>%
  rbindlist(use.names = TRUE) %>%
  lazy_dt()

merged = merged %>% select(Survey:DifficultyName, all_of(order))
merged = merged %>%
  filter(
    !DifficultyName == "NA",
    !disagg == "age_group = NA",
    !disagg == "urban_new = NA",
    !disagg == "female = NA"
  )

merged = merged %>%
  rename(
    "PopulationName" = "disagg"
  )

data_c = duckplyr::read_parquet_duckdb("Output/data.parquet") %>%
  filter(admin == "National") %>%
  select(Country) %>%
  n_distinct() %>%
  paste0("There are ", ., " surveys in the file") %>%
  menu(
    c("Delete existing file", "Append to existing file"),
    TRUE,
    .
  )
if (data_c == 0) {
  stop("Cancelled script")
} else if (data_c == 1) {
  file.remove("Output/data.parquet")
  merged %>% collect() %>% write_parquet("Output/data.parquet")
} else if (data_c == 2) {
  data = read_parquet("Output/data.parquet")
  data = full_join(data, collect(merged))
  write_parquet(data, "Output/data.parquet")
} else {
  stop("Error, no selection made")
}
rm(
  merged,
  data,
  processed,
  diff_type,
  mean1,
  pop_type,
  order,
  com_list,
  run_list,
  sum_list,
  svy_list
)

#Create default estimates
data = read_parquet("Output/data.parquet") %>% lazy_dt()
data = data |>
  mutate(Country = str_extract(Survey, "(.+?)_.*", group = 1), .before = Survey)

drive_auth("bradley.carpenter@mrc.ac.za")
file.remove(paste0(cen_dir, "Downloads/Census/Dataset list.xlsx"))
drive_download(
  file = "https://docs.google.com/spreadsheets/d/1QweNwgkecGAknSQ-ICNSsXHsaBqZgtTA/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
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

file.remove(paste0(
  cen_dir,
  "Downloads/Census/Countries with more than one dataset.xlsx"
))
drive_download(
  file = "https://docs.google.com/spreadsheets/d/1AMjlJy6W0vz2DTEYmyIvTzoZ2q16JqNe/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
  path = paste0(
    cen_dir,
    "Downloads/Census/Countries with more than one dataset.xlsx"
  ),
  overwrite = TRUE
)
temp3 = read_xlsx(
  paste0(cen_dir, "Downloads/Census/Countries with more than one dataset.xlsx"),
  "Extraction"
) %>%
  filter(!is.na(Country)) %>%
  select(!Survey) %>%
  arrange(`File name`)
temp3 = temp3 %>%
  mutate(across(
    `Adults with disabilities`:`Multidimensional poverty`,
    ~ as.numeric(ifelse(.x == "x" | .x == "X", NA, .x))
  ))
temp3 = temp3 %>%
  rename(setNames(
    c("File name", key_m$IndicatorName),
    c("Survey", paste0(key_m$IndicatorName, "_def"))
  ))
temp3 = full_join(temp3, tibble(Survey = sum_list2)) |>
  mutate(
    across(
      any_of(paste0(key_m$IndicatorName, "_def")),
      ~ ifelse(is.na(Country), 1, .x)
    ),
    Country = str_split(Survey, "_", simplify = T)[, 1]
  )

data2 = left_join(
  data |> collect(),
  temp3,
  by = join_by(Country, Survey)
)
data2 = data2 |>
  select(
    1:6,
    paste0(rep(key_m$IndicatorName, each = 4), c("_def", "_mean", "_se", "_n"))
  )
data3 = data2 |>
  pivot_longer(
    cols = !1:6,
    names_pattern = "(.*)_(.*)",
    names_to = c("IndicatorName", ".value")
  ) |>
  filter(!is.na(def)) |>
  select(!Survey) |>
  pivot_wider(
    id_cols = 1:5,
    values_from = c(def:n),
    names_from = "IndicatorName",
    names_glue = "{IndicatorName}_{.value}"
  )
data3 = data3 |>
  select(
    1:5,
    paste0(rep(key_m$IndicatorName, each = 3), c("_mean", "_se", "_n"))
  )

write_parquet(data3, sink = "Output/data2.parquet")

# temp4 = temp3 %>%
#   filter(`Adults with disabilities` == 1) %>%
#   select(Country, Survey, `File name`)

# temp2 |>
#   filter(
#     (!(Subnational_1_feasible == "X" | Subnational_1_feasible == "x") |
#       !(Subnational_2_feasible == "X" | Subnational_2_feasible == "x") |
#       is.na(Subnational_1_feasible) |
#       is.na(Subnational_2_feasible)) &
#       File_Name %in% temp3$`File name`
#   )
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
#   rep(temp3 %>% select(Household_prevalence), 9),
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
#   sub("Household_prevalence_", "Household_prevalence ", .)
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
#   sub("Household_prevalence_", "Household_prevalence ", .)
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
