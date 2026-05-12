********************************************************************************
*Globals 
********************************************************************************
clear
clear matrix
clear mata 
set maxvar 30000

global survey_data D:\DDI\DHS
global clean_data D:\DDI\DHS\_Clean Data
global combined_data D:\DDI\DHS\_Combined Data

*******************************************************************
*Household Level Analysis: Create Indicators and Clean data
*******************************************************************
**DHS Survey round years
global PK_SR 2017_2018
global ML_SR 2018
global MV_SR 2009
global HT_SR 2016_2017
global KH_SR 2014
global SN_SR 2018
global SN2_SR 2019
global ZA_SR 2016
global RW_SR 2019_2020
global NG_SR 2018 
global MR_SR 2019_2021
global TL_SR 2016
global UG_SR 2016
global KE_SR 2022
global KH2_SR 2021_2022
global TZ_SR 2022
global NP_SR 2022
global JO_SR 2023
global MZ_SR 2022_2023
global AO_SR 2023_2024


local country_list PK ML HT KH SN SN2 ZA RW NG MR TL UG MV KE KH2 TZ NP JO MZ AO


foreach country of local country_list  {

use "${survey_data}\\`country'_${`country'_SR}\\`country'_BR.dta", clear

rename v001 cluster_number
rename v002 hh_number

if v000=="SN7" & v007==2019{
replace v000="SN71" 
}


* 1. DATE OF DEATH AND TIME SINCE DEATH

	gen date_death = b3 + b7 if b5==0
	label var date_death "Date of death (CMC)"

	gen mdead_survey = v008 - date_death if b5==0
	label var mdead_survey "Months since death"

	gen ydead_survey = mdead_survey/12 if b5==0
	label var ydead_survey "Years since death"

* 2. AGE AT DEATH

gen age_death = b7 if b5==0
label var age_death "Age at death in months"

* 3. CHILD DEATH INDICATOR

gen child_death = .
replace child_death = 1 if b5==0
replace child_death = 0 if b5==1

label define lab_died 1 "child has died" 0 "child is alive"
label values child_death lab_died

/* 4. UNDER-18 MORTALITY (EVER)

gen child_died18 = 0

* died before age 18 (216 months)
replace child_died18 = 1 if child_died==1 & age_death < 216

label var child_died18 "Child died before age 18"

* 5. WOMAN-LEVEL UNDER-18 (EVER)

bysort caseid: egen childu18_died_per_wom = max(child_died18)
label var childu18_died_per_wom "Woman had child die before age 18"

* 6. UNDER-18 MORTALITY (LAST 5 YEARS)

gen child18_died5 =0

* died before 18 AND within last 5 years
replace child18_died5 = 1 if child_died==1 & age_death < 216 & ydead_survey <= 5

label var child18_died5 "Child died before 18 in last 5 years"

bysort caseid: egen childu18_died_per_wom_5y = max(child18_died5)
label var childu18_died_per_wom_5y "Woman had child die before 18 (last 5 years)"

* 7. UNDER-5 MORTALITY (LAST 5 YEARS)

gen child5_died = 0

* died before age 5 (60 months) AND within last 5 years
replace child5_died = 1 if child_died==1 & age_death < 60 & ydead_survey <= 5
label var child5_died "Child died before age 5 in last 5 years"

bysort caseid: egen childu5_died_per_wom_5y = max(child5_died)
label var childu5_died_per_wom_5y "Woman had child die before age 5 (last 5 years)"*/

* 8. UNDER-5 MORTALITY EVER 

gen child5_died_ever = 0

replace child5_died_ever = 1 if child_death==1 & age_death < 60 
label var child5_died_ever "Child died before age 5 in last 5 years"

bysort caseid: egen child_died = max(child5_died_ever)
label var child_died "Woman had child die before age 5 ever"


duplicates drop caseid, force

keep v000 cluster_number hh_number v003 child_died

merge 1:1 cluster_number hh_number v003 using "${combined_data}//`country'_${`country'_SR}_Women_and_Men.dta", generate(_mergebr)

*replace child_dead_binary=. if female_chd==0

save "${combined_data}//`country'_${`country'_SR}_Women_and_Men.dta",replace
}
