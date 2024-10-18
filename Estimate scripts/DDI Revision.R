library(future)
library(doFuture)
options(future.globals.maxSize = 1e10)
library(foreach)
library(tidyverse)
library(janitor)
library(rvest)
library(googledrive)
options(java.parameters = "-Xmx8192m")
library(readxl)
library(writexl)

drive_auth("bradley.carpenter@mrc.ac.za")
file.remove(paste0(cen_dir,"Downloads/Census/Dataset list.xlsx"))
drive_download(file = "https://docs.google.com/spreadsheets/d/1rCcLMLu4eaakTW76it5vojo6o2Z6Nxzy/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
               path = paste0(cen_dir,"Downloads/Census/Dataset list.xlsx"),overwrite = TRUE)
data_list = read_xlsx(paste0(cen_dir,"Downloads/Census/Dataset list.xlsx"),"Sheet1",.name_repair = function(x) {gsub(" ","_",gsub("-","",x))}) |> filter(!is.na(Country))
data_list = data_list |> select(File_Name,url,Clean_data_file__date_of_last_version,Output__date_of_last_version,Output_needs_revision)
data_list = data_list |> mutate(Clean_data_file__date_of_last_version = convert_to_date(Clean_data_file__date_of_last_version,character_fun = lubridate::dmy),
                      Output__date_of_last_version = convert_to_date(Output__date_of_last_version,character_fun = lubridate::dmy))
temp = data_list |> filter(!File_Name %in% sub(".RData","",dir(paste0(cen_dir,"Downloads/Census/R Datasets/"))))

# temp2 = c(paste0(temp$File_Name,"_Cleaned_Individual_Data_Trimmed.RData"),paste0(temp$File_Name,"_Clean.RData"),paste0(temp$File_Name,".RData"))

r_list = dir(paste0(cen_dir,"Downloads/Census/R Datasets/"))
r_list2 = r_list[grepl(paste(c("ABCDE",temp$File_Name),collapse = "|"),r_list)]
if(length(r_list2)>0) {
  file.remove(paste0(cen_dir,"Downloads/Census/R Datasets/",r_list2))
  }
rm(r_list,r_list2)

sum_list = dir(paste0(cen_dir,"Downloads/Census/Summaries/"))
sum_list2 = sum_list[grepl(paste(c("ABCDE",temp$File_Name),collapse = "|"),sum_list)]
if(length(sum_list2)>0) {
  file.remove(paste0(cen_dir,"Downloads/Census/Summaries/",sum_list2))
}
rm(sum_list,sum_list2)

wid_list = dir(paste0(cen_dir,"Downloads/Census/Database/Individual/"))
wid_list2 = wid_list[grepl(paste(c("ABCDE",temp$File_Name),collapse = "|"),wid_list)]
if(length(wid_list2)>0) {
  file.remove(paste0(cen_dir,"Downloads/Census/Database/Individual/",wid_list2))
}
rm(wid_list,wid_list2)

bac_list = dir(paste0(cen_dir,"Downloads/Census/Database/Backup/"))
bac_list2 = bac_list[grepl(paste(c("ABCDE",temp$File_Name),collapse = "|"),bac_list)]
if(length(bac_list2)>0) {
  file.remove(paste0(cen_dir,"Downloads/Census/Database/Backup/",bac_list2))
}
rm(bac_list,bac_list2)

if(!file.exists(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"))) {
  file.copy(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0 - Copy.xlsx"),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"))
  file.copy(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1 - Copy.xlsx"),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"))
  file.copy(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2 - Copy.xlsx"),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"))
}

admin0_m = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"),"Means") %>% filter(!survey %in% temp$File_Name&survey %in% data_list$File_Name)
admin0_se = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"),"Standard Errors") %>% filter(!survey %in% temp$File_Name&survey %in% data_list$File_Name)
admin1_m = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"),"Means") %>% filter(!survey %in% temp$File_Name&survey %in% data_list$File_Name)
admin1_se = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"),"Standard Errors") %>% filter(!survey %in% temp$File_Name&survey %in% data_list$File_Name)
admin2_m = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"),"Means") %>% filter(!survey %in% temp$File_Name&survey %in% data_list$File_Name)
admin2_se = read_xlsx(paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"),"Standard Errors") %>% filter(!survey %in% temp$File_Name&survey %in% data_list$File_Name)
write_xlsx(list("Means" = admin0_m, "Standard Errors" = admin0_se),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin0.xlsx"))
write_xlsx(list("Means" = admin1_m, "Standard Errors" = admin1_se),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin1.xlsx"))
write_xlsx(list("Means" = admin2_m, "Standard Errors" = admin2_se),paste0(cen_dir,"Downloads/Census/Database/Wide_Table_Output_Admin2.xlsx"))
rm(admin0_m,admin1_m,admin2_m,admin0_se,admin1_se,admin2_se)

temp2 = temp |> mutate(File_Name = ifelse(grepl("IPUMS",File_Name)&!grepl("Vietnam.*2019|Cambodia",File_Name),"IPUMS_Cleaned_Individual_Data_Trimmed",File_Name),
                      File_Name = ifelse(grepl("DHS",File_Name),"Final_Individual_DHS_only",File_Name))
temp2 = temp2 |> distinct(File_Name,.keep_all = TRUE)

dta_list = dir(paste0(cen_dir,"Downloads/Census/Stata Datasets/"))

download = temp2 %>% filter(!File_Name %in% sub(".dta|.zip|.7z","",dta_list),!is.na(url)) %>% select(File_Name,url)

foreach(i = download$url,j = download$File_Name) %do% {
  k = str_extract(drive_get(i)$name,"\\..{1,4}$")
  drive_download(file = i, path = paste0(cen_dir,"Downloads/Census/Stata Datasets/",j,k))
  }
rm(data_list,temp,temp2,dta_list,download)

unzip_7z <- function(zipfile,exdir){
  str1 <- sprintf('C:/"Program Files"/7-Zip/7z.exe e %s -o%s',zipfile,exdir)
  shell(str1,wait = TRUE)
}

dta_list = dir(paste0(cen_dir,"Downloads/Census/Stata Datasets/"))
zip_list = sapply(dta_list[grepl(".zip|.7z",dta_list)],function(x) paste0(cen_dir,"Downloads/Census/Stata Datasets/",x))
foreach(i=zip_list) %do% {
  dta_list = dir(paste0(cen_dir,"Downloads/Census/Stata Datasets/"))
  unzip_7z(sub('Stata Datasets','"Stata Datasets"',i),paste0(cen_dir,'Downloads/Census/"Stata Datasets"/'))
  dta_list2 = dir(paste0(cen_dir,"Downloads/Census/Stata Datasets/"))
  dta_list2 = dta_list2[!dta_list2 %in% dta_list&grepl("\\.dta",dta_list2)]
  file.rename(from = paste0(cen_dir,"Downloads/Census/Stata Datasets/",dta_list2), to = sub(".zip",".dta",i))
  file.remove(i)
}

dta_list = dir(paste0(cen_dir,"Downloads/Census/Stata Datasets/"))
dta_list_c = dta_list[grepl("house",dta_list,ignore.case = TRUE)]
file.remove(paste0(cen_dir,"Downloads/Census/Stata Datasets/",dta_list_c))

rm(dta_list,dta_list_c,zip_list,i,j,k,unzip_7z)
gc()
