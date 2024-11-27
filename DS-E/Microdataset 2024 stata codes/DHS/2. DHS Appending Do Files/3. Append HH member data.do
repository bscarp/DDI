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
********************************************************************************
*Append Household Member Data for all DHS countries
********************************************************************************
**DHS Survey round years
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

use "${clean_data}\HT_2016_2017_Household_Member_Updated.dta", clear

local country_list PK ML KH SN ZA RW NG MR TL UG MV KE KH2 TZ NP

foreach country of local country_list  {
		
append using "${clean_data}\\`country'_${`country'_SR}_Household_Member_Updated.dta", force

}

*drop country_abrev 
*Generate country abreviation
gen country_abrev = substr(v000,1,2)
replace country_abrev = "KH2" if v000=="KH8"

encode admin1, gen(admin1_encode)

sort v000 v001 v002 v003
********************************************************************************
*Save
********************************************************************************

save "${combined_data}\\DHS_Household_Member_Updated.dta", replace