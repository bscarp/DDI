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
