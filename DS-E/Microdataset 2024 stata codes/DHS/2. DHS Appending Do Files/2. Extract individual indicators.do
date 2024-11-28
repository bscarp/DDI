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
set maxvar  30000

global survey_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data
global clean_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Clean Data
global combined_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Combined Data

********************************************************************************
*Extract employment data from women and men file
********************************************************************************
use "${combined_data}\\DHS_Women_and_Men_Updated.dta", clear

gen v001= cluster_number
gen v002= hh_number

replace v003=mv003 if gender=="male"

gen mobile_own  = v169a if female==1
replace mobile_own  = mv169a if female==0
la var mobile_own "Adult owns mobile phone"

la var internet "Individual uses internet"
la var lit_new "Literacy"

keep v000 v001 v002 v003 lit_new ind_emp anyviolence_byh_12m fp_demsat_mod ind2_weight dv_weight mobile_own internet

save "${combined_data}\\DHS_Women_and_Men_indicators.dta", replace
********************************
