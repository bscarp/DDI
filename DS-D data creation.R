#DS-D data creation
library(tidyverse)
library(stringi)
library(readxl)
library(countrycode)
library(sf)
library(terra)
library(arrow)

#DS-E
cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
# df_country_t = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/PowerBI/StatisticsCountry/region_names.xlsx"))
df_indicator_t = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/PowerBI/Types/indicators_types.xlsx"))
key_m = read_xlsx("DS-D files/Key messages.xlsx")
df_indicator_t = key_m %>% select(Group,IndicatorName,Original)
df_group_t = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/PowerBI/Types/population_types.xlsx"))
df_disability_t = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/PowerBI/Types/difficulty_types.xlsx"))

data = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/S1_Default_Estimates_Means.xlsx"))
names(data) = names(data) %>% sub("Household_Prevalence_","Household_Prevalence ",.)
names(data)[4:84] = names(data)[4:84] %>% paste0("Prevalence ",.)
names(data)[!grepl(" .* ",names(data))][-c(1:3)] = names(data)[!grepl(" .* ",names(data))][-c(1:3)] %>% sub("(\\()(.*)(\\))","\\2 \\1all_adults\\3",.)
data = data %>% pivot_longer(.,names(.)[-c(1:3)],names_to = c("IndicatorName","DifficultyName","PopulationName"),names_pattern = "(.*) (.*) \\((.*)\\)",
                               values_to = "Value")

data0 = data %>% filter(admin == "admin0")
data1 = data
data0 = data0 %>% mutate(IndicatorName  = str_replace_all(IndicatorName, setNames(df_indicator_t$IndicatorName[c(2:29,1)], unique(data0$IndicatorName)[c(2:6,15:18,7:14,19:29,1)])))
data0 = data0 %>% mutate(DifficultyName = str_replace_all(DifficultyName,setNames(unique(df_disability_t$DifficultyName)[c(1,3,4,6:11,2,5)],unique(data0$DifficultyName)[c(10,11,3,4,5,8,9,7,6,2,1)])))
data0 = data0 %>% mutate(PopulationName = str_replace_all(PopulationName,setNames(c(unique(df_group_t$PopulationName),"Adults ages 25 to 29"),unique(data0$PopulationName))))
data0 = data0 %>% mutate(admin = str_replace_all(admin,setNames(c("National","Subnational division 1","Subnational division 2","Alternative subnational division"), c("admin0","admin1","admin2","admin_alt"))))
data1 = data1 %>% mutate(IndicatorName  = str_replace_all(IndicatorName, setNames(df_indicator_t$IndicatorName[c(2:29,1)], unique(data1$IndicatorName)[c(2:6,15:18,7:14,19:29,1)])))
data1 = data1 %>% mutate(DifficultyName = str_replace_all(DifficultyName,setNames(unique(df_disability_t$DifficultyName)[c(1,3,4,6:11,2,5)],unique(data1$DifficultyName)[c(10,11,3,4,5,8,9,7,6,2,1)])))
data1 = data1 %>% mutate(PopulationName = str_replace_all(PopulationName,setNames(c(unique(df_group_t$PopulationName),"Adults ages 25 to 29"),unique(data1$PopulationName))))
data1 = data1 %>% mutate(admin = str_replace_all(admin,setNames(c("National","Subnational division 1","Subnational division 2","Alternative subnational division"), c("admin0","admin1","admin2","admin_alt"))))

list_country = data0 %>% select(country) %>% filter(!duplicated(country))
ddi_2024 = read_xlsx("DS-D files/DS-QR Database.xlsx", sheet = 2) %>% select(Region,Country) %>% filter(!duplicated(Country))
list_country = left_join(list_country,ddi_2024, by = join_by("country"=="Country")) %>% select(Region,country)
list_country = list_country %>% mutate(Region = case_when(is.na(Region)&country=="Gambia"~"Sub-Saharan Africa",TRUE~Region))
rm(ddi_2024)
list_country = lapply(split(list_country$country, list_country$Region, drop = TRUE), function(x) as.list(x))

list_indicator = lapply(split(df_indicator_t$IndicatorName, df_indicator_t$Group, drop = TRUE), function(x) as.list(x))[c("Proportion with disabilities (Prevalence)", "Education", "Personal activities","Health","Standard of living","Insecurity","Multidimensional poverty")]
list_group = df_group_t$PopulationName
list_disability = c("Disability versus no disability" = 1, "Severe versus moderate versus no disability" = 2, "Severe versus moderate or no disability" = 3,
                  "Disability by type" = 4)
list_disability2 = unique(data1$DifficultyName)

map_df = readRDS("DS-D files/New map.rds")
iso = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/R Shiny/REGION_ISO_CODESv2.xlsx")) %>% select(Country,Region,ISOCode) %>% setNames(c("country","level","ISOCode")) %>% filter(!is.na(country)) %>% mutate(level = str_to_title(level))
data1 = data1 %>% mutate(level = sub("Ra-o Negro","Ra-O Negro",level))
data1 = left_join(data1,iso %>% filter(!country == "Vietnam"), by = c("country","level"))

data0 = data0 %>% rename("Country" = "country")
data1 = data1 %>% rename("Country" = "country")

df_country = data1 %>% select(Country,admin) %>% distinct() %>% filter(!admin == "National")
df_indicator = data0 %>% select(Country,IndicatorName,PopulationName) %>% distinct()

df_static = read_xlsx("DS-D files/Static.xlsx")
df_static = df_static %>% mutate(IndicatorName  = str_replace_all(IndicatorName, setNames(df_indicator_t$IndicatorName, unique(IndicatorName)[c(23,15,9,3:4,18,28,24,10,2,6,17,22,8,29,20,19,16,7,5,1,25,14,13,27,11,26,12,21)])))

save(list_country, list_indicator, list_group, list_disability, list_disability2, key_m, df_country, df_static, file = "DS-E/Data.RData")
write_parquet(data0, sink = "DS-E/data0.parquet")
write_parquet(data1, sink = "DS-E/data1.parquet")
write_sf(map_df, dsn = "DS-E/map_df.shp")
rm(list = ls())

#DS-QR
ddi_2024 = read_xlsx("DS-D files/DS-QR Database.xlsx", sheet = 2) %>% rename(WG = `WG-SS`, FL = `Other functional difficulty questions`) %>% select(!sum)
ddi_2024 = ddi_2024 %>% mutate(ISO3 = countrycode::countryname(Country, "iso3c"), .after = Country)
ddi_2024_s = ddi_2024 %>% group_by(ISO3) %>% summarise(Region = first(Region), Country = first(Country), WG = max(WG, na.rm = TRUE), FL = max(FL, na.rm = TRUE)) %>% select(Region,Country,ISO3,WG,FL)
ddi_2024_s = ddi_2024_s %>% mutate(Summary = case_when(WG == 1 ~ "Washington Group\nShort Set",
                                                       FL == 1 ~ "Other functional\ndifficulty questions",
                                                       WG == 0 & FL == 0 ~ "No functional\ndifficulty questions",
                                                       TRUE ~ NA))
ddi_2024 = ddi_2024 %>% mutate(WG = case_when(WG==1~"Yes", WG==0~"No", TRUE~NA), FL = case_when(FL==1~"Yes", FL==0~"No", TRUE~NA))

ddi_2024 = ddi_2024 %>% mutate(across(c(Region, Country, WG, FL),as_factor))
ddi_2024_s = ddi_2024_s %>% mutate(across(c(Region, Country, Summary),as_factor))

ddi_2024 = ddi_2024 %>% rename(Year = `Year(s)`, `WG-SS` = WG, `Other functional difficulty questions` = FL)

map_df = read_sf("DS-D files/ne_110m_admin_0_countries.shp")
map_df = map_df %>% mutate(ISO3 = if_else(ISO_A3=="-99", ADM0_A3, ISO_A3))
map_df = left_join(map_df,ddi_2024_s, by = join_by(ISO3)) %>% mutate(Summary = factor(if_else(is.na(Summary),"Not assessed",Summary), levels = c("Washington Group\nShort Set", "Other functional\ndifficulty questions", "No functional\ndifficulty questions", "Not assessed")))
map_df = map_df %>% filter(!NAME == "Antarctica")

save(ddi_2024, ddi_2024_s, map_df, file = "DS-QR/Data.RData")
rm(list = ls())
