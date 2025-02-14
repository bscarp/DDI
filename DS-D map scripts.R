#DDI map script
library(tidyverse)
library(stringi)
library(readxl)
library(countrycode)
library(sf)
library(terra)

cen_dir = str_extract(getwd(),"C:\\/Users\\/.+?\\/")

iso = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/R Shiny/REGION_ISO_CODESv2.xlsx")) %>% select(Country,Region,ISOCode) %>% setNames(c("country","level","ISOCode")) %>% filter(!is.na(country)) %>% mutate(level = str_to_title(level))
map_df = read_sf(paste0(cen_dir,"Downloads/world shp/ne_10m_admin_1_states_provinces.shp")) %>% select(iso_3166_2,iso_a2,name,name_alt,code_hasc,admin,geometry)
map_df2 = read_sf(paste0(cen_dir,"Downloads/world shp2/gadm_410-levels-simple2.shp")) %>% select(ISO_1,GID_0,NAME_1,VARNAME_1,HASC_1,COUNTRY,geometry)  %>% 
  setNames(c("iso_3166_2","iso_a2","name","name_alt","code_hasc","admin","geometry")) %>% filter(admin %in% c("Kenya","Philippines", "Ghana")) %>% mutate(iso_a2 = countrycode(iso_a2,"iso3c","iso2c"))
map_df3 = st_read("C:/Users/bscar/Downloads/geodata/gadm_410-levels.gpkg", layer = "ADM_2") %>% select(GID_2, GID_0, NAME_2, VARNAME_2, HASC_2, COUNTRY, geom) %>%
  setNames(c("iso_3166_2","iso_a2","name","name_alt","code_hasc","admin","geometry")) %>% filter(admin %in% c("Palestine","Gambia")) %>% mutate(iso_a2 = countrycode(iso_a2,"iso3c","iso2c"))
st_geometry(map_df3) <- "geometry"
map_df4 = read_sf(paste0(cen_dir,"Downloads/Other shp/eez_v12_lowres.shp")) %>% select(MRGID,ISO_TER1,GEONAME,SOVEREIGN1,geometry) %>% mutate(name_alt = as.character(NA), code_hasc = as.character(NA), .after = GEONAME) %>%
  setNames(c("iso_3166_2","iso_a2","name","name_alt","code_hasc","admin","geometry")) %>% mutate(iso_a2 = countrycode(iso_a2,"iso3c","iso2c"), iso_3166_2 = sub("8450","KI-P", sub("8441","KI-L", sub("8488","KI-G",iso_3166_2))))
# map_KI = read_sf(paste0(cen_dir,"Downloads/Other shp/kir_admbnda_adm1_2020.shp")) %>% select(ADM1_PCODE,ADM0_PCODE,ADM1_EN,ADM0_EN,geometry) %>% mutate(name_alt = as.character(NA), code_hasc = as.character(NA), .after = ADM1_EN) %>%
#   setNames(c("iso_3166_2","iso_a2","name","name_alt","code_hasc","admin","geometry")) %>% mutate(iso_3166_2 = sub("KI3","KI-P",sub("KI2","KI-L",sub("KI1","KI-G",iso_3166_2))))
map_SR = read_sf(paste0(cen_dir,"Downloads/Other shp/geo1_sr2012.shp")) %>% select(IPUM2012,CNTRY_CODE,ADMIN_NAME,CNTRY_NAME,geometry) %>% mutate(name_alt = as.character(NA), code_hasc = as.character(NA), .after = ADMIN_NAME) %>%
  setNames(c("iso_3166_2","iso_a2","name","name_alt","code_hasc","admin","geometry")) %>% mutate(iso_a2 = "SR")
map_NA = read_sf(paste0(cen_dir,"Downloads/Other shp/nam_admbnda_adm1_nsa_ocha_20200109.shp")) %>% select(ADM1_PCODE,ADM0_PCODE,ADM1_EN,ADM1ALT1EN,ADM0_EN,geometry) %>% mutate(code_hasc = as.character(NA), .after = ADM1ALT1EN) %>%
  setNames(c("iso_3166_2","iso_a2","name","name_alt","code_hasc","admin","geometry")) %>% filter(iso_3166_2 %in% c("NA05", "NA14")) %>% mutate(iso_3166_2 = sub("NA05","NA-KE",sub("NA14","NA-KW",iso_3166_2)))
map_NP = read_sf(paste0(cen_dir,"Downloads/Other shp/npl_admbnda_adm1_nd_20240314.shp")) %>% select(ADM1_PCODE,ADM0_PCODE,ADM1_EN,ADM0_EN,geometry) %>% mutate(name_alt = as.character(NA), code_hasc = as.character(NA), .after = ADM1_EN) %>%
  setNames(c("iso_3166_2","iso_a2","name","name_alt","code_hasc","admin","geometry"))

map_ET = map_df %>% filter(iso_3166_2 %in% c("ET-SI", "ET-SN", "ET-SW"))
map_df = map_df %>% filter(!iso_3166_2 %in% c("ET-SI", "ET-SN", "ET-SW"))
map_ET = map_ET %>% summarise(iso_3166_2 = "ET-SN", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))

map_KE = map_df2 %>% filter(admin %in% c("Kenya"))
map_KE$iso_3166_2 = paste0("KE-",c(paste0("0",seq(1,9)),seq(10,47)))

map_KI = map_df4 %>% filter(admin %in% c("Kiribati"))

map_GH = map_df2 %>% filter(admin == "Ghana")
map_df = map_df %>% filter(!admin == "Ghana")

map_GM1 = map_df3 %>% filter(code_hasc %in% c("GM.MC.FW", "GM.MC.JJ", "GM.MC.ND", "GM.MC.NE", "GM.MC.NW"))
map_GM2 = map_df3 %>% filter(code_hasc %in% c("GM.MC.LS", "GM.MC.NI", "GM.MC.NJ", "GM.MC.SM", "GM.MC.US"))
map_GM3 = map_df3 %>% filter(code_hasc %in% c("GM.BJ.BJ"))
map_GM4 = map_df3 %>% filter(code_hasc %in% c("GM.BJ.KF"))
map_df = map_df %>% filter(!iso_3166_2 %in% c("GM-M", "GM-B"))
map_GM1 = map_GM1 %>% summarise(iso_3166_2 = "GM-JJ", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_GM2 = map_GM2 %>% summarise(iso_3166_2 = "GM-KU", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_GM3 = map_GM3 %>% summarise(iso_3166_2 = "GM-BJ", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_GM4 = map_GM4 %>% summarise(iso_3166_2 = "GM-KF", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_GM = bind_rows(mget(ls(pattern="^map_GM")))
rm(list = ls(pattern="^map_GM."))

map_MW1 = map_df %>% filter(iso_3166_2 %in% c("MW-CT", "MW-KR", "MW-LK", "MW-MZ", "MW-NB", "MW-RU"))
map_MW2 = map_df %>% filter(iso_3166_2 %in% c("MW-DE","MW-DO","MW-KS","MW-LI","MW-MC","MW-NK","MW-NU","MW-NI","MW-SA"))
map_MW3 = map_df %>% filter(iso_3166_2 %in% c("MW-BA","MW-BL","MW-CK","MW-CR","MW-MH","MW-MG","MW-MU","MW-MW","MW-NE","MW-NS","MW-PH","MW-TH","MW-ZO"))
map_MW1 = map_MW1 %>% summarise(iso_3166_2 = "MW-N", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_MW2 = map_MW2 %>% summarise(iso_3166_2 = "MW-C", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_MW3 = map_MW3 %>% summarise(iso_3166_2 = "MW-S", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_MW = bind_rows(mget(ls(pattern="^map_MW")))
rm(list = ls(pattern="^map_MW."))

map_MU = map_df %>% filter(iso_3166_2 %in% c("MU-PW", "MU-BR", "MU-QB", "MU-VP", "MU-CU"))
map_df = map_df %>% filter(!iso_3166_2 %in% c("MU-PW", "MU-BR", "MU-QB", "MU-VP", "MU-CU"))
map_MU = map_MU %>% summarise(iso_3166_2 = "MU-PW", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = "MU.PW", admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))

map_PK = map_df %>% filter(iso_3166_2 %in% c("PK-TA", "PK-KP"))
map_df = map_df %>% filter(!iso_3166_2 %in% c("PK-TA", "PK-KP"))
map_PK = map_PK %>% summarise(iso_3166_2 = "PK-KP", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = "PK.NW", admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))

map_PS = map_df3 %>% filter(admin == "Palestine") %>% mutate(name = sub("Gaza ash Shamaliyah", "North Gaza", sub("Ramallah and Al-Bireh", "Ramallah", name)))

map_PH01 = map_df2 %>% filter(iso_3166_2 %in% c("PH-ILN", "PH-ILS", "PH-LUN", "PH-PAN"))
map_PH02 = map_df2 %>% filter(iso_3166_2 %in% c("PH-BTN", "PH-CAG", "PH-ISA", "PH-NUV", "PH-QUI"))
map_PH03 = map_df2 %>% filter(iso_3166_2 %in% c("PH-AUR", "PH-BAN", "PH-BUL", "PH-NUE", "PH-PAM", "PH-TAR", "PH-ZMB"))
map_PH04 = map_df2 %>% filter(iso_3166_2 %in% c("PH-ALB", "PH-CAN", "PH-CAS", "PH-CAT", "PH-MAS", "PH-SOR"))
map_PH05 = map_df2 %>% filter(iso_3166_2 %in% c("PH-AKL", "PH-ANT", "PH-CAP", "PH-GUI", "PH-ILI", "PH-NEC"))
map_PH06 = map_df2 %>% filter(iso_3166_2 %in% c("PH-BOH", "PH-CEB", "PH-NER", "PH-SIG"))
map_PH07 = map_df2 %>% filter(iso_3166_2 %in% c("PH-BIL", "PH-EAS", "PH-LEY", "PH-NSA", "PH-WSA", "PH-SLE"))
map_PH08 = map_df2 %>% filter(iso_3166_2 %in% c("PH-BAS", "PH-ZAN", "PH-ZAS", "PH-ZSI"))
map_PH09 = map_df2 %>% filter(iso_3166_2 %in% c("PH-BUK", "PH-CAM", "PH-MSC", "PH-MSR"))
map_PH10 = map_df2 %>% filter(iso_3166_2 %in% c("PH-COM", "PH-DAV", "PH-DAS", "PH-DVO", "PH-DAO", "PH-SAR", "PH-SCO"))
map_PH11 = map_df2 %>% filter(iso_3166_2 %in% c("PH-NCO", "PH-LAN", "PH-SUK"))
map_PH12 = map_df2 %>% filter(iso_3166_2 %in% c("PH-AGN", "PH-AGS", "PH-DIN", "PH-SUN", "PH-SUR"))
map_PH13 = map_df2 %>% filter(iso_3166_2 %in% c("PH-LAS", "PH-MGN", "PH-MGS", "PH-SLU", "PH-TAW"))
map_PH14 = map_df2 %>% filter(iso_3166_2 %in% c("PH-ABR", "PH-APA", "PH-BEN", "PH-IFU", "PH-KAL", "PH-MOU"))
map_PH15 = map_df2 %>% filter(iso_3166_2 %in% c("PH-BTG", "PH-CAV", "PH-LAG", "PH-QUE", "PH-RIZ"))
map_PH16 = map_df2 %>% filter(iso_3166_2 %in% c("PH-MAD", "PH-MDC", "PH-MDR", "PH-PLW", "PH-ROM"))
map_PH01 = map_PH01 %>% summarise(iso_3166_2 = "PH-01", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH02 = map_PH02 %>% summarise(iso_3166_2 = "PH-02", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH03 = map_PH03 %>% summarise(iso_3166_2 = "PH-03", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH04 = map_PH04 %>% summarise(iso_3166_2 = "PH-05", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH05 = map_PH05 %>% summarise(iso_3166_2 = "PH-06", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH06 = map_PH06 %>% summarise(iso_3166_2 = "PH-07", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH07 = map_PH07 %>% summarise(iso_3166_2 = "PH-08", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH08 = map_PH08 %>% summarise(iso_3166_2 = "PH-09", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH09 = map_PH09 %>% summarise(iso_3166_2 = "PH-10", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH10 = map_PH10 %>% summarise(iso_3166_2 = "PH-11", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH12 = map_PH12 %>% summarise(iso_3166_2 = "PH-12", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH13 = map_PH13 %>% summarise(iso_3166_2 = "PH-13", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH11 = map_PH11 %>% summarise(iso_3166_2 = "PH-14", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH14 = map_PH14 %>% summarise(iso_3166_2 = "PH-15", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH15 = map_PH15 %>% summarise(iso_3166_2 = "PH-40", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH16 = map_PH16 %>% summarise(iso_3166_2 = "PH-41", iso_a2 = first(iso_a2), name = as.character(NA), name_alt = as.character(NA), code_hasc = as.character(NA), admin = first(admin), geometry = st_union(geometry)) %>% mutate(name = iso %>% filter(ISOCode==iso_3166_2) %>% pull(level))
map_PH = bind_rows(mget(ls(pattern="^map_PH")))
rm(list = ls(pattern="^map_PH."))

map_df = map_df %>% filter(!iso_3166_2 %in% c("NA-OK", "MU-RO", "MU-AG"))

map_df = map_df %>% filter(!admin %in% c("Kenya","Kiribati","Malawi","Palestine","Philippines","Nepal"))
map_df = bind_rows(map_df,map_KE,map_KI,map_SR,map_NA,map_ET,map_GH,map_GM,map_MW,map_MU,map_PK,map_PS,map_PH,map_NP)

map_df[map_df$iso_a2=="KI",] = map_df[map_df$iso_a2=="KI",] %>% st_shift_longitude()

saveRDS(map_df, "DS-D files/New map.rds")
rm(list = ls())
