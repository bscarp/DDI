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
********************************************************************************
*Globals 
********************************************************************************
clear
clear matrix
clear mata 
set maxvar 30000

global survey_data C:\Users\16313\Dropbox\Apporto - Fordham\Disability Project\DDI 2023 Report\DHS_country_data
*\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data
global clean_data C:\Users\16313\Dropbox\Apporto - Fordham\Disability Project\DDI 2023 Report\DHS_country_data\_Clean Data
*\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Clean Data
global combined_data C:\Users\16313\Dropbox\Apporto - Fordham\Disability Project\DDI 2023 Report\DHS_country_data\_Combined Data
*\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Combined Data

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
*Create sample weights
gen ind2_weight=mv005/1000000
lab var ind2_weight "DHS Individual Sample weight"

if  mv000== "SN7" {
decode(smezone), gen(smezone_str)
gen Admin1 = smezone_str 
}
else {
	decode mv024, gen(Admin1)
}

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

rename mv481 health_insurance
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

la var internet "Individual uses internet"

rename mv012 age
label var v013 "age in 5-year groups"
label var v014 "completeness of age information"

*********************
//Mobile Phone Ownership
if mv000=="KH6"|mv000=="MV5" {
gen mobile_own=.
}
else { 
	rename mv169a mobile_own
}
*********************
//Currently working indicator
gen ind_emp=mv714 
replace ind_emp=. if female==0&age>54
lab var ind_emp "Employed"

*********************
//Literacy
gen lit_new = (mv155==2)
replace lit_new = . if mv155==.|mv155==3
la var lit_new "Literacy"

rename mv025 ResidenceType

keep v001 v002 v003 Admin1 ResidenceType health_insurance gender female age internet mobile_own lit_new ind2_weight ind_emp

merge 1:1 v001 v002 v003 using "${clean_data}//`country'_${`country'_SR}_Household_Member_Updated.dta", keep(match)

save "${clean_data}//`country'_${`country'_SR}_Men_Updated.dta", replace
}
