#DS-D data creation
library(tidyverse)
library(stringi)
library(readxl)
library(sf)
library(terra)

#DS-E
cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")
df_country_t = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/StatisticsCountry/region_names.xlsx"))
df_indicator_t = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/Types/indicators_types.xlsx"))
df_group_t = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/Types/population_types.xlsx"))
df_disability_t = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/Types/difficulty_types.xlsx"))
data_n = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/StatisticsTopics/satistics_national.xlsx"))
data_n = left_join(left_join(left_join(data_n,df_indicator_t),df_group_t),df_disability_t)
data_n = data_n %>% select(Country,IndicatorName,PopulationName,DifficultyName,Value)
data2 = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/PowerBI/StatisticsCountry/statistics_admin1_level.xlsx"))
data2 = left_join(left_join(left_join(data2,df_indicator_t),df_group_t),df_disability_t)
data2 = data2 %>% select(Country,Region,IndicatorName,PopulationName,DifficultyName,Value)

data = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/S1_Default_Estimates_Means.xlsx"))
names(data) = names(data) %>% sub("Household_Prevalence_","Household_Prevalence ",.)
names(data)[4:84] = names(data)[4:84] %>% paste0("Prevalence ",.)
names(data)[!grepl(" .* ",names(data))][-c(1:3)] = names(data)[!grepl(" .* ",names(data))][-c(1:3)] %>% sub("(\\()(.*)(\\))","\\2 \\1all_adults\\3",.)
data = data %>% pivot_longer(.,names(.)[-c(1:3)],names_to = c("IndicatorName","DifficultyName","PopulationName"),names_pattern = "(.*) (.*) \\((.*)\\)",
                               values_to = "Value")

data0 = data %>% filter(admin == "admin0")
data1 = data
data0 = data0 %>% mutate(IndicatorName  = str_replace_all(IndicatorName, setNames(c("Prevalence",unique(data_n$IndicatorName)), unique(data0$IndicatorName))))
data0 = data0 %>% mutate(DifficultyName = str_replace_all(DifficultyName,setNames(unique(data_n$DifficultyName)[c(3:11,2,1)],unique(data0$DifficultyName)[c(3,10,11,4,5,8,7,9,6,2,1)])))
data0 = data0 %>% mutate(PopulationName = str_replace_all(PopulationName,setNames(c(unique(data_n$PopulationName),"Adults ages 25 to 29"),unique(data0$PopulationName)[c(1,4,5,2,3,6:10)])))
data1 = data1 %>% mutate(IndicatorName  = str_replace_all(IndicatorName, setNames(c("Prevalence",unique(data_n$IndicatorName)), unique(data1$IndicatorName))))
data1 = data1 %>% mutate(DifficultyName = str_replace_all(DifficultyName,setNames(unique(data_n$DifficultyName)[c(3:11,2,1)],unique(data1$DifficultyName)[c(3,10,11,4,5,8,7,9,6,2,1)])))
data1 = data1 %>% mutate(PopulationName = str_replace_all(PopulationName,setNames(c(unique(data_n$PopulationName),"Adults ages 25 to 29"),unique(data1$PopulationName)[c(1,4,5,2,3,6:10)])))

df_country = df_country_t$Country
df_indicator = c("Prevalence",df_indicator_t$IndicatorName)
df_group = df_group_t$PopulationName
df_disability = c("Disability versus no disability" = 1, "Severe versus moderate versus no disability" = 2, "Severe versus moderate or no disability" = 3,
                  "Disability by type" = 4)
df_disability2 = unique(data1$DifficultyName)

map_df = read_sf(paste0(cen_dir,"/Downloads/world shp/ne_10m_admin_1_states_provinces.shp"))
iso = read_xlsx(paste0(cen_dir,"/Downloads/Census/Database/R Shiny/REGION_ISO_CODESv2.xlsx")) %>% select(Country,Region,ISOCode) %>% setNames(c("country","level","ISOCode"))
data1 = left_join(data1,iso %>% filter(!country == "Vietnam"), by = c("country","level"))

data0 = data0 %>% rename("Country" = "country")
data1 = data1 %>% rename("Country" = "country")

key_m = read_xlsx("DS-D files/Key messages.xlsx")

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

key_m = read_xlsx("DS-D files/Key messages.xlsx")

save(ddi_2024, ddi_2024_s, map_df, key_m, file = "DS-QR/Data.RData")
rm(list = ls())
