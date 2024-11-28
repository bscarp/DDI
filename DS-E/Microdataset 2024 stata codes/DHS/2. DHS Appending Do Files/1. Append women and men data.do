********************************************************************************
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

use "${combined_data}\HT_2016_2017_Women_and_Men.dta", clear

local country_list PK ML KH SN ZA RW NG MR TL UG MV KE KH2 TZ NP

foreach country of local country_list  {
		
append using "${combined_data}/`country'_${`country'_SR}_Women_and_Men.dta", force

}

*Generate country abreviation
gen country_abrev = substr(v000,1,2)
replace country_abrev = "KH2" if v000=="KH8"

*Set region name in SN equal to zone. SN DHS 2018 was representative at the zone level. 
decode(szone), gen(szone_str)
decode(smezone), gen(smezone_str)

replace Admin1 = szone_str if country_abrev=="SN"&female==1
replace Admin1 = smezone_str if country_abrev=="SN"&female==0

encode Admin1, gen(Admin1_encode)

********************************************************************************
*Clean and code indicators
********************************************************************************
*Currently working indicator
gen ind_emp=v714 if female==1
replace ind_emp=mv714 if female==0

replace ind_emp=. if female==1&age>49
replace ind_emp=. if female==0&age>54

lab var ind_emp "Employed"

gen lit_new = (v155==2)
replace lit_new = . if v155==.|v155==3
********************************************************************************
*Save
********************************************************************************

save "${combined_data}\\DHS_Women_and_Men_Updated.dta", replace

 