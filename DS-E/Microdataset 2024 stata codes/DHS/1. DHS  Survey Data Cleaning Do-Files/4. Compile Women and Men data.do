*******************************************************************************
/*******************************************************************************
********************************DHS*********************************************
********************************************************************************
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/
Reference to appendix and paper:
For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).
Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, GVS, Pinilla-Roncancio, M.,  Rivas Velarde, M., Teodoro, D.,  and Mitra, S. (2024). The Disability Statistics – Estimates Database: an innovative database of internationally comparable statistics on disability inequalities. International Journal of Population Data Science.
Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com
Author: Katherine Theiss
Suggested citation: DDI. Disability Statistics Database - Estimates (DS-E Database)). Disability Data Initiative collective. Fordham University: New York, USA. 2024.
*******************************************************************************/
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
*Merge with Disability Data and Append Men's Data
********************************************************************************
*******************************************************************
*Merge Individual Women's Data with Household Member Data; Append Men's data
*Need Women and Men surveys include data on frequency of ICT Usage 
*Household member dataset includes data on functional difficulty
*Clearn data and create indicators
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
	
use "${clean_data}//`country'_${`country'_SR}_Women_Updated.dta", clear
	
merge 1:1 v001 v002 v003 using "${clean_data}//`country'_${`country'_SR}_Household_Member_Updated.dta", keep(match)

append using "${clean_data}//`country'_${`country'_SR}_Men_Updated.dta"

*Create sample weights
gen ind2_weight=v005/1000000
lab var ind2_weight "DHS Individual Sample weight"

if v000!="MV5" {
gen dv_weight=d005/1000000
lab var dv_weight "DHS Domestic Violence sample weight"
}

rename v025 ResidenceType
rename v001 cluster_number
rename v002 hh_number

save "${combined_data}/`country'_${`country'_SR}_Women_and_Men.dta",replace
}
