********************************************************************************
*Globals 
********************************************************************************
clear
clear matrix
clear mata 
set maxvar 32767

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

use "${clean_data}\HT_2016_2017_Household_Updated.dta", clear

local country_list PK ML KH SN ZA RW NG MR TL UG MV KE KH2 TZ NP

foreach country of local country_list  {
		
append using "${clean_data}//`country'_${`country'_SR}_Household_Updated.dta"

}


keep v000 v001 v002 hh_weight hv022 deprive_sl_asset ind_cleanfuel ind_electric water_source sanit_source ind_computer ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer ind_floor ind_roof ind_wall ind_water ind_toilet ind_asset_ownership ind_livingcond roof_source floor_source wall_source

save "${combined_data}\\DHS_Household_Updated.dta", replace

********************************************************************************
*Merge hh member data with with household-level variables
********************************************************************************
use "${combined_data}\\DHS_Household_Member_Updated.dta", clear

sort v000 v001 v002 v003

merge m:1 v000 v001 v002 using "${combined_data}\\DHS_Household_Updated.dta"
*, keep(match)

drop _merge
********************************************************************************
*Merge with individual women and men's employment data 
********************************************************************************
merge 1:1 v000 v001 v002 v003 using "${combined_data}\\DHS_Women_and_Men_indicators.dta"

*drop if country_abrev=="MV"

gen disability_none = 1 if disability_any==0
replace disability_none = 0 if disability_any==1

gen disability_nonesome = (disability_none==1|disability_some==1)
********************************************************************************
*MDP Indicators
********************************************************************************
*Health - access to safely managed drinking water 
gen deprive_health_water=1 if ind_water==0
replace deprive_health_water=0 if ind_water==1
replace deprive_health_water=. if ind_water==.

*Health - access to sanitation services
gen deprive_health_sanitation=1 if ind_toilet==0
replace deprive_health_sanitation=0 if ind_toilet==1
replace deprive_health_sanitation=. if ind_toilet==.

*Standard of living - adequate housing, clean fuel, electricity, and assets
gen deprive_sl_housing=1 if ind_livingcond==0
replace deprive_sl_housing=0 if ind_livingcond==1
replace deprive_sl_housing=. if ind_livingcond==.

gen deprive_sl_fuel=1 if ind_cleanfuel==0
replace deprive_sl_fuel=0 if ind_cleanfuel==1
replace deprive_sl_fuel=. if ind_cleanfuel==.

gen deprive_sl_electricity=1 if ind_electric==0
replace deprive_sl_electricity=0 if ind_electric==1
replace deprive_sl_electricity=. if ind_electric==.

/*
*if observation has labor information labor_tag==1, otherwise ==0
gen labor_tag=1 if ind_emp!=.
replace labor_tag=0 if ind_emp==.

*Education - completed primary school
gen deprive_educ=cond(mi(completed_atleast_primary),.,cond(completed_atleast_primary==0,(1/3),0)) if labor_tag==0
gen deprive_work=.	if	labor_tag==0
		
replace deprive_educ=cond(mi(completed_atleast_primary),.,cond(completed_atleast_primary==0,0.25,0))  if labor_tag==1
replace deprive_work=cond(mi(ind_emp),.,cond(ind_emp==0,0.25,0))  if labor_tag==1
*/
*we assume that dimensions can not be missing but indicators inside can be missing. The dimension weights remain the same but the indicators weights should change
egen missing_health=rowmiss(deprive_health_water deprive_health_sanitation)
replace missing_health=2-missing_health
egen health_temp=rowtotal(deprive_health_water deprive_health_sanitation)
					
egen missing_sl=rowmiss(deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset)
replace missing_sl=4-missing_sl
egen sl_temp=rowtotal(deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset)


/*						
gen deprive_health=(1/missing_health)*(1/3)*health_temp if  labor_tag==0
gen deprive_sl=(1/missing_sl)*(1/3)*sl_temp if  labor_tag==0
	
replace deprive_health=(1/missing_health)*0.25*health_temp if labor_tag==1 
replace deprive_sl=(1/missing_sl)*0.25*sl_temp if  labor_tag==1 

gen mdp_score=cond(mi(deprive_educ)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_health+deprive_sl) if  labor_tag==0
replace mdp_score=cond(mi(deprive_educ)|mi(deprive_work)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_work+deprive_health+deprive_sl) if  labor_tag==1 

gen ind_mdp=cond(mi(mdp_score),.,cond((labor_tag==1 &mdp_score>0.25)|(labor_tag==0 &mdp_score>(1/3)),1,0))
*/

lab var deprive_health_water "Deprived in water"
lab var deprive_health_sanitation "Deprived in terms of sanitation"
lab var deprive_sl_electricity "Deprived for electricity"
lab var deprive_sl_fuel "Deprived in terms of clean fuel"
lab var deprive_sl_housing "Deprived in terms of housing binary"
lab var deprive_sl_asset "Deprived in terms of asset ownership"

*MDP calculation without employment
gen deprive_educ_v2=cond(mi(ind_atleastprimary_all),.,cond(ind_atleastprimary_all==0,(1/3),0)) 
gen deprive_health_v2=(1/missing_health)*(1/3)*health_temp 
gen deprive_sl_v2=(1/missing_sl)*(1/3)*sl_temp 

gen mdp_score_v2=cond(mi(deprive_educ_v2)|mi(deprive_health_v2)|mi(deprive_sl_v2),.,deprive_educ_v2+deprive_health_v2+deprive_sl_v2) 

gen ind_mdp_v2=cond(mi(mdp_score_v2),.,cond(mdp_score_v2>(1/3),1,0))
*replace ind_mdp_v2=0 if mi(ind_mdp_v2)

lab var mdp_score_v2 "Multidimensional poverty Score wo emp"
lab var ind_mdp_v2 "M1_Multidemensional Poverty status binary wo emp"

rename mdp_score_v2 mdp_score
rename ind_mdp_v2 ind_mdp
rename deprive_educ_v2 deprive_educ

la var deprive_educ "Deprived is less than primary school completion"

********************************************************************************
egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new comm_diff_new cognitive_diff_new mobility_diff_new selfcare_diff_new)
gen ind_func_diff_missing= (func_diff_missing==6)

egen disaggvar_missing = rowmiss(female age urban_new)
gen ind_disaggvar_missing = (disaggvar_missing >0)

/*
ta roof_source roof_new, m
ta floor_source floor_new, m
ta wall_source wall_new, m
*/

drop hv005 hv006 hv007 v000 v001 v002 hv016 hv024 hv206 hv207 hv208 hv218 hv221 hv243a v003 hvidx idxh4 idxh4 hv121 hv027 roof_source floor_source wall_source 

********************************************************************************
*Save
********************************************************************************
save "${combined_data}\\DHS_Cross_Country_Data_withmissdata.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1

la var country_abrev "Country abrevation"

drop missing_health missing_sl func_diff_missing ind_func_diff_missing disaggvar_missing ind_disaggvar_missing edattain_new sex_new hv021 hv022 shv005 survey admin1_encode _merge hv000 hv001 hv002 age_group_label health_temp sl_temp deprive_health_v2 deprive_sl_v2

*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight ind2_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary   computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh"

foreach var in `variable_tocheck'  {
capture confirm variable `var', exact
if _rc {
gen `var' = .
di "`var' added"
}
else {
di "`var' exists"
}
 }


keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 ind_weight ind2_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 ind_weight ind2_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

save "${combined_data}\\DHS_Cross_Country_Data.dta", replace

la var disability_none "No Difficulty"
la var disability_nonesome "No or Some Difficulty"

duplicates drop country_abrev hh_id, force

save "${combined_data}\\DHS_Cross_Country_HH_Data.dta", replace

