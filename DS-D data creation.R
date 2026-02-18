#DS-D data creation
library(tidyverse)
library(stringi)
library(readxl)
library(countrycode)
library(sf)
library(terra)
library(arrow)

#DS-E
cen_dir = str_extract(getwd(), "[c,C]:\\/Users\\/.+?\\/")
# df_country_t = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/PowerBI/StatisticsCountry/region_names.xlsx"))
# df_indicator_t = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/PowerBI/Types/indicators_types.xlsx"))
key_m = read_xlsx("DS-D files/Key messages.xlsx")
df_indicator_t = key_m %>% select(Group, IndicatorName, Original)
df_group_t = read_xlsx(paste0(
    cen_dir,
    "Downloads/Census/Database/PowerBI/Types/population_types.xlsx"
))
df_disability_t = read_xlsx(paste0(
    cen_dir,
    "Downloads/Census/Database/PowerBI/Types/difficulty_types.xlsx"
))

data = read_xlsx(paste0(
    cen_dir,
    "Downloads/Census/Database/S1_Default_Estimates_Means.xlsx"
))
names(data) = names(data) %>%
    sub("Household_Prevalence_", "Household_Prevalence ", .)
names(data)[4:84] = names(data)[4:84] %>% paste0("Prevalence ", .)
names(data)[!grepl(" .* ", names(data))][-c(1:3)] = names(data)[
    !grepl(" .* ", names(data))
][-c(1:3)] %>%
    sub("(\\()(.*)(\\))", "\\2 \\1all_adults\\3", .)
data = data %>%
    pivot_longer(
        .,
        names(.)[-c(1:3)],
        names_to = c("IndicatorName", "DifficultyName", "PopulationName"),
        names_pattern = "(.*) (.*) \\((.*)\\)",
        values_to = "Value"
    )

data0 = data %>% filter(admin == "admin0")
data1 = data
data0 = data0 %>%
    mutate(
        IndicatorName = str_replace_all(
            IndicatorName,
            setNames(
                df_indicator_t$IndicatorName[c(2:29, 1)],
                unique(data0$IndicatorName)[c(2:6, 15:18, 7:14, 19:29, 1)]
            )
        )
    )
data0 = data0 %>%
    mutate(
        DifficultyName = str_replace_all(
            DifficultyName,
            setNames(
                unique(df_disability_t$DifficultyName)[c(1, 3, 4, 6:11, 2)],
                unique(data0$DifficultyName)[c(10, 11, 3, 4, 5, 8, 9, 7, 6, 2)]
            )
        ),
        DifficultyName = ifelse(
            DifficultyName == "disability",
            "Disability",
            DifficultyName
        )
    )
data0 = data0 %>%
    mutate(
        PopulationName = str_replace_all(
            PopulationName,
            setNames(
                c(unique(df_group_t$PopulationName), "Adults ages 25 to 29"),
                unique(data0$PopulationName)
            )
        )
    )
data0 = data0 %>%
    mutate(
        admin = str_replace_all(
            admin,
            setNames(
                c(
                    "National",
                    "Subnational division 1",
                    "Subnational division 2",
                    "Alternative subnational division"
                ),
                c("admin0", "admin1", "admin2", "admin_alt")
            )
        )
    )
data1 = data1 %>%
    mutate(
        IndicatorName = str_replace_all(
            IndicatorName,
            setNames(
                df_indicator_t$IndicatorName[c(2:29, 1)],
                unique(data1$IndicatorName)[c(2:6, 15:18, 7:14, 19:29, 1)]
            )
        )
    )
data1 = data1 %>%
    mutate(
        DifficultyName = str_replace_all(
            DifficultyName,
            setNames(
                unique(df_disability_t$DifficultyName)[c(1, 3, 4, 6:11, 2)],
                unique(data1$DifficultyName)[c(10, 11, 3, 4, 5, 8, 9, 7, 6, 2)]
            )
        ),
        DifficultyName = ifelse(
            DifficultyName == "disability",
            "Disability",
            DifficultyName
        )
    )
data1 = data1 %>%
    mutate(
        PopulationName = str_replace_all(
            PopulationName,
            setNames(
                c(unique(df_group_t$PopulationName), "Adults ages 25 to 29"),
                unique(data1$PopulationName)
            )
        )
    )
data1 = data1 %>%
    mutate(
        admin = str_replace_all(
            admin,
            setNames(
                c(
                    "National",
                    "Subnational division 1",
                    "Subnational division 2",
                    "Alternative subnational division"
                ),
                c("admin0", "admin1", "admin2", "admin_alt")
            )
        )
    )

df_country = data0 %>% select(country) %>% filter(!duplicated(country))
ddi_2025 = read_xlsx("DS-D files/DS-QR Database.xlsx", sheet = 2) %>%
    select(Region, Country) %>%
    filter(!duplicated(Country))
df_country = left_join(
    df_country,
    ddi_2025,
    by = join_by("country" == "Country")
) %>%
    select(Region, country)
df_country = df_country %>%
    mutate(
        Region = case_when(
            is.na(Region) & country == "Gambia" ~ "Sub-Saharan Africa",
            TRUE ~ Region
        )
    )
rm(ddi_2025)
df_country = df_country %>%
    select(country, Region) %>%
    setNames(c("label", "group"))
df_country = df_country %>% mutate(value = label, .before = group)

df_group = tibble(label = df_group_t$PopulationName)
df_group = df_group %>% mutate(value = label)
df_group2 = df_group %>%
    mutate(
        label = sub("Adults ages 15 to 29", "Adults ages 25 to 29", label),
        value = sub("Adults ages 15 to 29", "Adults ages 25 to 29", value)
    )
df_disability = tibble(
    label = c(
        "Disability versus no disability",
        "Severe versus moderate versus no disability",
        "Severe versus moderate or no disability",
        "Disability by type"
    ),
    value = c(1, 2, 3, 4)
)
df_disability2 = tibble(label = unique(data1$DifficultyName))
df_disability2 = df_disability2 %>% mutate(value = label)

df_lang = tibble(
    label = c("English", "French", "Spanish", "Russian", "中文", "Arabic"),
    value = c("en", "fr", "es", "ru", "zh", "ar")
)

map_df = readRDS("DS-D files/New map.rds")
iso = read_xlsx(paste0(
    cen_dir,
    "Downloads/Census/Database/R Shiny/REGION_ISO_CODESv2.xlsx"
)) %>%
    select(Country, Region, ISOCode) %>%
    setNames(c("country", "level", "ISOCode")) %>%
    filter(!is.na(country)) %>%
    mutate(level = str_to_title(level))
data1 = data1 %>% mutate(level = sub("Ra-o Negro", "Ra-O Negro", level))
data1 = left_join(
    data1,
    iso %>% filter(!country == "Vietnam"),
    by = c("country", "level")
)

data0 = data0 %>% rename("Country" = "country")
data1 = data1 %>% rename("Country" = "country")

df_country2 = data1 %>%
    select(Country, admin) %>%
    distinct() %>%
    filter(!admin == "National")
df_indicator = data0 %>%
    select(Country, IndicatorName, PopulationName) %>%
    distinct()

df_static = read_xlsx("DS-D files/Static.xlsx")
df_static = df_static %>%
    mutate(
        IndicatorName = str_replace_all(
            IndicatorName,
            setNames(
                df_indicator_t$IndicatorName,
                unique(IndicatorName)[c(
                    23,
                    15,
                    9,
                    3:4,
                    18,
                    28,
                    24,
                    10,
                    2,
                    6,
                    17,
                    22,
                    8,
                    29,
                    20,
                    19,
                    16,
                    7,
                    5,
                    1,
                    25,
                    14,
                    13,
                    27,
                    11,
                    26,
                    12,
                    21
                )]
            )
        )
    )

save(
    df_country,
    df_country2,
    df_group,
    df_group2,
    df_disability,
    df_disability2,
    df_lang,
    key_m,
    df_country,
    df_static,
    file = "DS-E/Data.RData"
)
write_parquet(data0, sink = "DS-E/data0.parquet")
write_parquet(data1, sink = "DS-E/data1.parquet")
write_sf(map_df, dsn = "DS-E/map_df.shp")
rm(list = ls())

#DS-QR
library(tidyverse)
library(stringi)
library(readxl)
library(countrycode)
library(sf)
library(terra)
library(arrow)

ddi_2025 = read_xlsx("DS-D files/DS-QR Database.xlsx", sheet = 2) %>%
    rename(WG = `WG-SS`, FL = `Other functional difficulty questions`) %>%
    select(!c(Sum, Year))
ddi_2025 = ddi_2025 %>%
    mutate(ISO3 = countrycode::countryname(Country, "iso3c"), .after = Country)
ddi_2025 = ddi_2025 %>%
    mutate(
        ISO3 = case_when(
            is.na(ISO3) & Country == "Northern Ireland" ~ "GB",
            is.na(ISO3) & Country == "Scotland" ~ "GB",
            is.na(ISO3) & Country == "Kosovo" ~ "XK",
            TRUE ~ ISO3
        )
    )
ddi_2025_s = ddi_2025 %>%
    group_by(ISO3) %>%
    filter(!is.na(ISO3)) %>%
    summarise(
        Region = first(Region),
        Country = first(Country),
        WG = max(WG, na.rm = TRUE),
        FL = max(FL, na.rm = TRUE)
    ) %>%
    select(Region, Country, ISO3, WG, FL)
ddi_2025_s = ddi_2025_s %>%
    mutate(
        Summary = case_when(
            WG == 1 ~ "Washington Group Short Set",
            FL == 1 ~ "Other functional difficulty questions",
            WG == 0 & FL == 0 ~ "No functional difficulty questions",
            TRUE ~ NA
        )
    )
ddi_2025 = ddi_2025 %>%
    mutate(
        WG = case_when(WG == 1 ~ "Yes", WG == 0 ~ "No", TRUE ~ NA),
        FL = case_when(FL == 1 ~ "Yes", FL == 0 ~ "No", TRUE ~ NA)
    )

ddi_2025 = ddi_2025 %>% mutate(across(c(Region, Country, WG, FL), as_factor))
ddi_2025_s = ddi_2025_s %>%
    mutate(across(c(Region, Country, Summary), as_factor))

ddi_2025 = ddi_2025 %>%
    rename(
        Year = `Year(s)`,
        `WG-SS` = WG,
        `Other functional difficulty questions` = FL
    )

map_df = read_sf("DS-D files/ne_110m_admin_0_countries.shp")
map_df = map_df %>% mutate(ISO_A3 = if_else(ADMIN == "Kosovo", "XK", ISO_A3))
map_df = map_df %>% mutate(ISO3 = if_else(ISO_A3 == "-99", ADM0_A3, ISO_A3))
map_df = map_df %>% filter(!NAME == "Antarctica")

df_region = tibble(
    value = c("World", as.character(unique(ddi_2025_s$Region))),
    label = c("World", as.character(unique(ddi_2025_s$Region)))
)

df_lang = tibble(
    label = c("English", "French", "Spanish", "Russian", "中文", "Arabic"),
    value = c("en", "fr", "es", "ru", "zh", "ar")
)

save(
    ddi_2025,
    ddi_2025_s,
    map_df,
    df_region,
    df_lang,
    file = "DS-QR/Data.RData"
)
rm(list = ls())
