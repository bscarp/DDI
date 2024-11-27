********************************************************************************
*Globals 
********************************************************************************
clear
clear matrix
clear mata 
set maxvar 30000

global survey_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data
global clean_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Clean Data
global combined_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Combined Data
*******************************************************************
*Mens: Create Indicators and Clean data
*******************************************************************
global PK_SR 2017_2018
global ML_SR 2018
global MV_SR 2009
global HT_SR 2016_2017
global KH_SR 2014
global SN_SR 2018
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

local country_list PK ML HT KH SN ZA RW NG MR TL UG MV KE KH2 TZ NP

foreach country of local country_list  {

use "${survey_data}\\`country'_${`country'_SR}\\`country'_Men.dta", clear

gen v001 = mv001
gen v002 = mv002
gen v003 = mv003
sort v001 v002 v003

if mv000=="PK7" {
replace mv005 = smv005 if mv000=="PK7"&(mv024==7|mv024==5)
}

gen v000= mv000
gen gender="male"
gen female=0

*Men's sample weight
gen v005=mv005

decode mv024, gen(Admin1)

gen survey_month=mv006
gen survey_year=mv007

gen v013=mv013
gen v014=mv014

*Literacy and education indicators
gen v155 = mv155 
gen v106 = mv106 
gen v107 = mv107 
gen v133 = mv133 
gen v149 = mv149 

*Working Indicators
gen v714 = mv714 
gen v716 = mv716 
gen v717 = mv717
gen v731 = mv731
gen v732 = mv731
gen v741 = mv717

*********************
//Internet Use
if mv000 !="KH6"&mv000!="MV5" {
gen internet =  mv171a
recode internet (0 2 3 = 0)
}

if mv000 == "KH6" {
	gen  internet = 1 if (sm112a==1|sm112a==2)
	replace  internet = 0 if (sm112a==0)
}

if mv000 =="MV5" {
gen internet =  sm109 if female==0
recode internet (1 2 3 = 1)
}

rename mv012 age
label var v013 "age in 5-year groups"
label var v014 "completeness of age information"

merge 1:1 v001 v002 v003 using "${clean_data}//`country'_${`country'_SR}_Household_Member_Updated.dta", keep(match)

save "${clean_data}//`country'_${`country'_SR}_Men_Updated.dta", replace
}
