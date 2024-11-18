#DS-D data creation
library(tidyverse)
library(stringi)
library(readxl)
library(countrycode)
library(sf)
library(terra)

#DS-E
cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
# df_country_t = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/StatisticsCountry/region_names.xlsx"))
df_indicator_t = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/Types/indicators_types.xlsx"))
key_m = read_xlsx("DS-D files/Key messages.xlsx")
df_indicator_t = key_m %>% select(Group,IndicatorName,Original)
df_group_t = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/Types/population_types.xlsx"))
df_disability_t = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/Types/difficulty_types.xlsx"))

data = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/S1_Default_Estimates_Means.xlsx"))
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
data1 = data1 %>% mutate(IndicatorName  = str_replace_all(IndicatorName, setNames(df_indicator_t$IndicatorName[c(2:29,1)], unique(data1$IndicatorName)[c(2:6,15:18,7:14,19:29,1)])))
data1 = data1 %>% mutate(DifficultyName = str_replace_all(DifficultyName,setNames(unique(df_disability_t$DifficultyName)[c(1,3,4,6:11,2,5)],unique(data1$DifficultyName)[c(10,11,3,4,5,8,9,7,6,2,1)])))
data1 = data1 %>% mutate(PopulationName = str_replace_all(PopulationName,setNames(c(unique(df_group_t$PopulationName),"Adults ages 25 to 29"),unique(data1$PopulationName))))

df_country = data0 %>% select(country) %>% filter(!duplicated(country))
ddi_2024 = read_xlsx("DS-D files/Dataset_Review_Results_2024_full.xlsx", sheet = 1) %>% select(Region,Country) %>% filter(!duplicated(Country))
df_country = left_join(df_country,ddi_2024, by = join_by("country"=="Country")) %>% select(Region,country)
df_country = df_country %>% mutate(Region = case_when(is.na(Region)&country=="Gambia"~"Sub-Saharan Africa",TRUE~Region))
rm(ddi_2024)
df_country = lapply(split(df_country$country, df_country$Region, drop = TRUE), function(x) as.list(x))

df_indicator = split(df_indicator_t$IndicatorName, df_indicator_t$Group, drop = TRUE)[c(5,1,2,4,6,3)]
df_group = df_group_t$PopulationName
df_disability = c("Disability versus no disability" = 1, "Severe versus moderate versus no disability" = 2, "Severe versus moderate or no disability" = 3,
                  "Disability by type" = 4)
df_disability2 = unique(data1$DifficultyName)

map_df = read_sf(paste0(cen_dir,"/Downloads/world shp/ne_10m_admin_1_states_provinces.shp"))
iso = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/R Shiny/REGION_ISO_CODESv2.xlsx")) %>% select(Country,Region,ISOCode) %>% setNames(c("country","level","ISOCode"))
data1 = left_join(data1,iso %>% filter(!country == "Vietnam"), by = c("country","level"))

data0 = data0 %>% rename("Country" = "country")
data1 = data1 %>% rename("Country" = "country")

save(data0, data1, map_df, df_country, df_indicator, df_group, df_disability, df_disability2, key_m, file = "DS-E/Data.RData")
rm(list = ls())

#DS-QR
ddi_2024 = read_xlsx("DS-D files/Dataset_Review_Results_2024_full.xlsx", sheet = 1)
ddi_2024 = ddi_2024 %>% mutate(ISO3 = countrycode::countryname(Country, "iso3c"), .after = Country)
ddi_2024_s = ddi_2024 %>% group_by(ISO3) %>% summarise(Region = first(Region), Country = first(Country), WG = max(WG, na.rm = TRUE), FL = max(FL, na.rm = TRUE)) %>% select(Region,Country,ISO3,WG,FL)
ddi_2024_s = ddi_2024_s %>% mutate(Summary = case_when(WG == 1 ~ "Washington Group\nShort Set",
                                                       FL == 1 ~ "Other functional\ndifficulty questions",
                                                       WG == 0 & FL == 0 ~ "No",
                                                       TRUE ~ NA))
ddi_2024 = ddi_2024 %>% mutate(WG = case_when(WG==1~"Yes", WG==0~"No", TRUE~NA), FL = case_when(FL==1~"Yes", FL==0~"No", TRUE~NA))

ddi_2024 = ddi_2024 %>% mutate(across(c(Region, Country, Years, WG, FL),as_factor))
ddi_2024_s = ddi_2024_s %>% mutate(across(c(Region, Country, Summary),as_factor))

ddi_2024 = ddi_2024 %>% rename(Year = Years, `WG-SS` = WG, `Other functional difficulty questions` = FL)

map_df = read_sf("DS-D files/ne_110m_admin_0_countries.shp")
map_df = map_df %>% mutate(ISO3 = if_else(ISO_A3=="-99", ADM0_A3, ISO_A3))
map_df = left_join(map_df,ddi_2024_s, by = join_by(ISO3)) %>% mutate(Summary = factor(if_else(is.na(Summary),"Not assessed",Summary), levels = c("Washington Group\nShort Set", "Other functional\ndifficulty questions", "No", "Not assessed")))
map_df = map_df %>% filter(!NAME == "Antarctica")

save(ddi_2024, ddi_2024_s, map_df, file = "DS-QR/Data.RData")
rm(list = ls())
