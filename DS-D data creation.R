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
# df_country_t = read_xlsx(paste0(cen_dir,"PowerBI/StatisticsCountry/region_names.xlsx"))
# df_indicator_t = read_xlsx(paste0(cen_dir,"PowerBI/Types/indicators_types.xlsx"))
key_m = read_xlsx("DS-D files/Key messages.xlsx")
df_indicator_t = key_m %>% select(Group, IndicatorName, Raw)
df_group_t = read_xlsx("DS-D files/population_types.xlsx")
df_country_t = read_xlsx("DS-D files/countries.xlsx")

df_country = df_country_t %>%
    select(CountryName, Region) %>%
    setNames(c("label", "group"))
df_country = df_country %>% mutate(value = label, .before = group)

df_group = read_xlsx("DS-D files/population_types.xlsx") %>%
    select(PopulationName) %>%
    setNames("label") %>%
    mutate(value = label)

df_disability = read_xlsx("DS-D files/breakdown.xlsx")
df_disability2 = read_xlsx("DS-D files/difficulty_types.xlsx")
df_disability2 = df_disability2 %>%
    transmute(label = New_name, value = New_name)

# df_lang = tibble(
#     label = c("English", "French", "Spanish", "Russian", "中文", "Arabic"),
#     value = c("en", "fr", "es", "ru", "zh", "ar")
# )

map_df = readRDS("DS-D files/New map.rds")

iso = read_xlsx("DS-D files/REGION_ISO_CODESv2_1.xlsx") %>%
    select(Country, Region, ISOCode) %>%
    setNames(c("Country", "level", "ISOCode")) %>%
    filter(!is.na(Country)) %>%
    mutate(level = str_to_title(level))

data3 = read_parquet("Output/data2.parquet")
data3 = data3 %>% mutate(level = sub("Ra-o Negro", "Ra-O Negro", level))
data3 = left_join(
    data3,
    iso,
    by = c("Country", "level"),
    multiple = "first"
)

data3 = data3 |>
    mutate(
        Country = recode_values(
            Country,
            from = c(
                df_country_t$Clean,
                df_country_t$Clean2,
                df_country_t$CountryName
            ),
            to = rep(df_country_t$CountryName, 3)
        )
    )

df_country2 = data3 %>%
    select(Country, admin) %>%
    distinct() %>%
    filter(!admin == "National")
df_indicator = data3 %>%
    filter(admin == "National") %>%
    pivot_longer(cols = contains("_mean"), names_pattern = "(.*)_mean") %>%
    select(Country, name, PopulationName) %>%
    rename(IndicatorName = "name") %>%
    distinct()

# df_static = read_xlsx("DS-D files/Static.xlsx")
# df_static = df_static %>%
#     mutate(
#         IndicatorName = ifelse(
#             grepl("_", IndicatorName),
#             gsub("_", " ", str_to_sentence(IndicatorName)),
#             IndicatorName
#         ),
#         IndicatorName = recode_values(
#             IndicatorName,
#             from = key_m$Raw,
#             to = key_m$IndicatorName
#         )
#     )

df_est = c("mean", "se", "n")

save(
    df_country,
    df_country2,
    df_group,
    df_disability,
    df_disability2,
    # df_lang,
    key_m,
    # df_static,
    df_est,
    file = "DS-E/Data.RData"
)
write_parquet(data3, sink = "DS-E/data.parquet")
write_sf(map_df, dsn = "DS-E/map_df.shp", layer_options = c("ENCODING=UTF-8"))
rm(list = ls())

#DS-QR
library(tidyverse)
library(stringi)
library(readxl)
library(countrycode)
library(sf)
library(terra)
library(arrow)

ddi_2025 = read_xlsx("Data/DS-QR Database.xlsx", sheet = 2) %>%
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
