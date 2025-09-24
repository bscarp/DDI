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

cen_dir = str_extract(getwd(), "C:\\/Users\\/.+?\\/")

drive_auth("bradley.carpenter@mrc.ac.za")
file.remove(paste0(cen_dir, "Downloads/Census/Dataset list.xlsx"))
drive_download(
  file = "https://docs.google.com/spreadsheets/d/1vIsXVg8xlvJKXxonIggj04oQKsWV56aR/edit?usp=sharing&ouid=104552820408951429298&rtpof=true&sd=true",
  path = paste0(cen_dir, "Downloads/Census/Dataset list.xlsx"),
  overwrite = TRUE
)
data_list = read_xlsx(
  paste0(cen_dir, "Downloads/Census/Dataset list.xlsx"),
  "Sheet1",
  .name_repair = function(x) {
    gsub(" ", "_", gsub("-", "", x))
  }
) |>
  filter(!is.na(Country))
data_list = data_list |>
  select(
    File_Name,
    new_url,
    Clean_data_file__date_of_last_version,
    Output__date_of_last_version,
    Output_needs_revision,
    Round
  ) %>%
  rename(url = new_url)
data_list = data_list |>
  mutate(
    Clean_data_file__date_of_last_version = convert_to_date(
      Clean_data_file__date_of_last_version,
      character_fun = lubridate::dmy
    ),
    Output__date_of_last_version = convert_to_date(
      Output__date_of_last_version,
      character_fun = lubridate::dmy
    )
  )
temp = data_list |>
  filter(
    !File_Name %in%
      sub(".RData", "", dir(paste0(cen_dir, "Downloads/Census/R Datasets/"))) |
      Clean_data_file__date_of_last_version > Output__date_of_last_version |
      Output_needs_revision == "X" |
      Output_needs_revision == "x"
  )

# temp2 = c(paste0(temp$File_Name,"_Cleaned_Individual_Data_Trimmed.RData"),paste0(temp$File_Name,"_Clean.RData"),paste0(temp$File_Name,".RData"))

r_list = dir(paste0(cen_dir, "Downloads/Census/R Datasets/"))
r_list2 = r_list[grepl(
  paste(c("Empty", temp$File_Name), collapse = "|"),
  r_list
)]
if (length(r_list2) > 0) {
  file.remove(paste0(cen_dir, "Downloads/Census/R Datasets/", r_list2))
}
rm(r_list, r_list2)

sum_list = dir(paste0(cen_dir, "Downloads/Census/Summaries/"))
sum_list2 = sum_list[grepl(
  paste(c("Empty", temp$File_Name), collapse = "|"),
  sum_list
)]
if (length(sum_list2) > 0) {
  file.remove(paste0(cen_dir, "Downloads/Census/Summaries/", sum_list2))
}
rm(sum_list, sum_list2)

wid_list = dir(paste0(cen_dir, "Downloads/Census/Database/Individual/"))
wid_list2 = wid_list[grepl(
  paste(c("Empty", temp$File_Name), collapse = "|"),
  wid_list
)]
if (length(wid_list2) > 0) {
  file.remove(paste0(
    cen_dir,
    "Downloads/Census/Database/Individual/",
    wid_list2
  ))
}
rm(wid_list, wid_list2)

bac_list = dir(paste0(cen_dir, "Downloads/Census/Database/Backup/"))
bac_list2 = bac_list[grepl(
  paste(c("Empty", temp$File_Name), collapse = "|"),
  bac_list
)]
if (length(bac_list2) > 0) {
  file.remove(paste0(cen_dir, "Downloads/Census/Database/Backup/", bac_list2))
}
rm(bac_list, bac_list2)

if (
  !file.exists(paste0(
    cen_dir,
    "Downloads/Census/Database/S3_All_Estimates_Means.xlsx"
  ))
) {
  file.copy(
    paste0(
      cen_dir,
      "Downloads/Census/Database/S3_All_Estimates_Means - Copy.xlsx"
    ),
    paste0(cen_dir, "Downloads/Census/Database/S3_All_Estimates_Means.xlsx")
  )
  file.copy(
    paste0(
      cen_dir,
      "Downloads/Census/Database/S3_All_Estimates_Means - Copy.xlsx"
    ),
    paste0(cen_dir, "Downloads/Census/Database/S4_All_Estimates_SE.xlsx")
  )
}

db_m = read_xlsx(paste0(
  cen_dir,
  "Downloads/Census/Database/S3_All_Estimates_Means.xlsx"
)) %>%
  filter(!survey %in% temp$File_Name & survey %in% data_list$File_Name)
db_se = read_xlsx(paste0(
  cen_dir,
  "Downloads/Census/Database/S4_All_Estimates_SE.xlsx"
)) %>%
  filter(!survey %in% temp$File_Name & survey %in% data_list$File_Name)
write_xlsx(
  db_m,
  paste0(cen_dir, "Downloads/Census/Database/S3_All_Estimates_Means.xlsx")
)
write_xlsx(
  db_se,
  paste0(cen_dir, "Downloads/Census/Database/S4_All_Estimates_SE.xlsx")
)
rm(db_m, db_se)

# temp2 = temp |> mutate(File_Name = ifelse(grepl("IPUMS",File_Name)&!grepl("Vietnam.*2019|Cambodia",File_Name),"IPUMS_Cleaned_Individual_Data_Trimmed",File_Name),
#                       File_Name = ifelse(grepl("DHS",File_Name),"Final_Individual_DHS_only",File_Name))
temp2 = temp |> distinct(url, .keep_all = TRUE)

dta_list = dir(paste0(cen_dir, "Downloads/Census/Stata Datasets/"))
r_list = dir(paste0(cen_dir, "Downloads/Census/R Datasets/"))

download = temp2 %>%
  filter(
    !File_Name %in% sub(".dta|.zip|.7z", "", dta_list) &
      !File_Name %in% sub(".RData", "", r_list),
    !is.na(url)
  ) %>%
  select(File_Name, url)

foreach(i = download$url, j = download$File_Name) %do%
  {
    k = drive_download(file = i)
    l = ifelse(
      grepl(".dta", k$name) & !k$name == "Final_Individual_DHS_only.dta",
      j,
      k$name
    )
    file.rename(
      from = paste0(getwd(), "/", k$name),
      to = paste0(cen_dir, "Downloads/Census/Stata Datasets/", l)
    )
  }
rm(data_list, temp2, dta_list, download)

dta_list = dir(paste0(cen_dir, "Downloads/Census/Stata Datasets/"))
dta_list2 = dta_list %>% sub(" ", "_", .)
file.rename(
  paste0(cen_dir, "Downloads/Census/Stata Datasets/", dta_list),
  paste0(cen_dir, "Downloads/Census/Stata Datasets/", dta_list2)
)

unzip_7z <- function(zipfile, exdir) {
  str1 <- sprintf('C:/"Program Files"/7-Zip/7z.exe e %s -o%s', zipfile, exdir)
  shell(str1, wait = TRUE)
}

dta_list = dir(paste0(cen_dir, "Downloads/Census/Stata Datasets/"))
zip_list = sapply(dta_list[grepl(".zip|.7z", dta_list)], function(x) {
  paste0(cen_dir, "Downloads/Census/Stata Datasets/", x)
})
foreach(i = zip_list) %do%
  {
    dta_list = dir(paste0(cen_dir, "Downloads/Census/Stata Datasets/"))
    unzip_7z(
      sub('Stata Datasets', '"Stata Datasets"', i),
      paste0(cen_dir, 'Downloads/Census/"Stata Datasets"/')
    )
    dta_list2 = dir(paste0(cen_dir, "Downloads/Census/Stata Datasets/"))
    dta_list2 = dta_list2[!dta_list2 %in% dta_list & grepl("\\.dta", dta_list2)]
    if(!grepl("IPUMS.*International",i)) {
      file.rename(
        from = paste0(cen_dir, "Downloads/Census/Stata Datasets/", dta_list2),
        to = sub(".zip", ".dta", i)
      )}
    file.remove(i)
  }

dta_list = dir(paste0(cen_dir, "Downloads/Census/Stata Datasets/"))
dta_list_c = dta_list[grepl("house", dta_list, ignore.case = TRUE)]
file.remove(paste0(cen_dir, "Downloads/Census/Stata Datasets/", dta_list_c))

#sub("KHM_IPUMS_Cleaned_Individual_Data.dta", "Cambodia_IPUMS_2019.dta",.) %>% sub("VNM1_IPUMS_Cleaned_Individual_Data.dta", "Vietnam_IPUMS_2019.dta",.) %>%
dta_list = dir(paste0(cen_dir, "Downloads/Census/Stata Datasets/"))
dta_list2 = dta_list %>%
  sub("_Cleaned_Individual_Data", "", .) %>%
  sub("_Sample", "", .) %>%
  sub("_Trimmed", "", .) %>%
  sub("MAR_IPUMS.dta", "Morocco_IPUMS_2014.dta", .) %>%
  sub("MMR_IPUMS.dta", "Myanmar_IPUMS_2014.dta", .) %>%
  sub("MUS_IPUMS.dta", "Mauritius_IPUMS_2011.dta", .) %>%
  sub("SEN_IPUMS.dta", "Senegal_IPUMS_2013.dta", .) %>%
  sub("SUR_IPUMS.dta", "Suriname_IPUMS_2012.dta", .) %>%
  sub("TZA_IPUMS.dta", "Tanzania_IPUMS_2012.dta", .) %>%
  sub("UGA_IPUMS.dta", "Uganda_IPUMS_2014.dta", .) %>%
  sub("URY_IPUMS.dta", "Uruguay_IPUMS_2011.dta", .) %>%
  sub("VNM_IPUMS.dta", "Vietnam_IPUMS_2009.dta", .) %>%
  sub("ZAF_IPUMS.dta", "South Africa_IPUMS_2011.dta", .) %>%
  sub("ZAF1_IPUMS.dta", "South Africa_IPUMS_2016.dta", .) %>%
  sub("Philippine_", "Philippines_", .)
file.rename(
  paste0(cen_dir, "Downloads/Census/Stata Datasets/", dta_list),
  paste0(cen_dir, "Downloads/Census/Stata Datasets/", dta_list2)
)

dta_list = dir(paste0(cen_dir, "Downloads/Census/Stata Datasets/"))
dta_list_c = dta_list[
  !sub(".dta", "", dta_list) %in% temp$File_Name &
    !dta_list == "Final_Individual_DHS_only.dta" &
    !dta_list == "Final_DHS_only.dta"
]
file.remove(paste0(cen_dir, "Downloads/Census/Stata Datasets/", dta_list_c))

rm(temp, dta_list, r_list, dta_list2, dta_list_c, zip_list, i, j, k, l, unzip_7z)
gc()
