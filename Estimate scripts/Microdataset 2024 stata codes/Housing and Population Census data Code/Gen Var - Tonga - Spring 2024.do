/*******************************************************************************
******************Tonga Census 2016 ********************************************
********************************************************************************
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/
Reference to appendix and paper:
For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).
Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, GVS, Pinilla-Roncancio, M.,  Rivas Velarde, M., Teodoro, D.,  and Mitra, S. (2024). The Disability Statistics – Estimates Database: an innovative database of internationally comparable statistics on disability inequalities. International Journal of Population Data Science.
Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com
Author: Katherine Theiss
Suggested citation: DDI. Disability Statistics Database - Estimates (DS-E Database)). Disability Data Initiative collective. Fordham University: New York, USA. 2024.
*******************************************************************************/
clear
ssc install unique

global tonga_data \\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\Cleaning Do-files\5. TON_PHC_2016\Datasets\2023 Report Clean Data

********************************************************************************
cd "\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\Cleaning Do-files\5. TON_PHC_2016\Datasets"
use Tonga_ind

merge m:1 InterviewId using Tonga_hh

unique InterviewId if _merge==2
unique InterviewId 
drop if _merge==2
drop _merge

save Tonga, replace
drop h3* h4* h5*
drop if age<15
save "Tonga.dta", replace

save "${tonga_data}\Tonga_Cleaned_Data.dta", replace

drop if age<15

gen country_name="Tonga"
la var country_name "Country name"
gen country_abrev="TG"
la var country_abrev "Country abbreviation"
gen country_dataset_year="Tonga_2016"
la var country_dataset_year "Country Data and year"

rename island admin1
la var admin1 "Admin 1 Level"
rename district admin2
la var admin2 "Admin 2 Level"

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65
la var age_group "Age Group"

gen female=1 if sex_new==2
replace female=0 if sex_new==1
la var female "Female or Male"

replace urban_new = 1 if urban_rural==0
replace urban_new = 0 if urban_rural==1
lab var urban_new "Urban or Rural"

*Clean functional difficulty data
********************************************************************************
rename disblnd_wg_new seeing_diff_new
rename disdeaf_wg_new hearing_diff_new
rename dismobil_wg_new mobility_diff_new
rename dismntl_wg_new cognitive_diff_new
rename discare_wg_new selfcare_diff_new
rename dismute_wg_new comm_diff_new

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

*Disability levels for any domain 
gen disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

gen disability_none = (disability_any==0)
lab var disability_none "No Difficulty"
gen disability_nonesome = (disability_none==1|disability_some==1)
lab var disability_nonesome "No or Some Difficulty"

*Any difficulty for each domain
gen seeing_any = (seeing_diff_new>=2) 
replace seeing_any=. if seeing_diff_new ==.

gen hearing_any = (hearing_diff_new>=2) 
replace hearing_any=. if hearing_diff_new ==.

gen mobile_any = (mobility_diff_new>=2) 
replace mobile_any=. if mobility_diff_new ==.

gen cognition_any = (cognitive_diff_new>=2) 
replace cognition_any=. if cognitive_diff_new ==.

gen selfcare_any = (selfcare_diff_new>=2) 
replace selfcare_any=. if selfcare_diff_new ==.

gen communicating_any = (comm_diff_new>=2) 
replace communicating_any=. if comm_diff_new ==.

*Some difficulty for each domain
gen seeing_some = (seeing_diff_new==2) 
replace seeing_some=. if seeing_diff_new ==.

gen hearing_some = (hearing_diff_new==2) 
replace hearing_some=. if hearing_diff_new ==.

gen mobile_some = (mobility_diff_new==2) 
replace mobile_some=. if mobility_diff_new ==.

gen cognition_some = (cognitive_diff_new==2) 
replace cognition_some=. if cognitive_diff_new ==.

gen selfcare_some = (selfcare_diff_new==2) 
replace selfcare_some=. if selfcare_diff_new ==.

gen communicating_some = (comm_diff_new==2) 
replace communicating_some=. if comm_diff_new ==.

*At least alot difficulty for each domain
gen seeing_atleast_alot = (seeing_diff_new>=3) 
replace seeing_atleast_alot=. if seeing_diff_new ==.

gen hearing_atleast_alot = (hearing_diff_new>=3) 
replace hearing_atleast_alot=. if hearing_diff_new ==.

gen mobile_atleast_alot = (mobility_diff_new>=3) 
replace mobile_atleast_alot=. if mobility_diff_new ==.

gen cognition_atleast_alot = (cognitive_diff_new>=3) 
replace cognition_atleast_alot=. if cognitive_diff_new ==.

gen selfcare_atleast_alot = (selfcare_diff_new>=3) 
replace selfcare_atleast_alot=. if selfcare_diff_new ==.

gen communicating_atleast_alot = (comm_diff_new>=3) 
replace communicating_atleast_alot=. if comm_diff_new ==.

*Household level Disability 
egen func_difficulty_hh=max(func_difficulty), by(InterviewId)
lab var func_difficulty_hh "Max Difficulty in HH"

gen disability_any_hh=1 if func_difficulty_hh>1
replace disability_any_hh=0 if func_difficulty_hh==1
replace disability_any_hh=. if func_difficulty_hh==.

lab var disability_any_hh "P3 Any difficulty in Any Domain for any adult in the hh"

gen disability_some_hh=1 if func_difficulty_hh==2
replace disability_some_hh=0 if func_difficulty_hh!=2
replace disability_some_hh=. if func_difficulty_hh==.

lab var disability_some_hh "P3 Some difficulty in Any Domain for any adult in the hh"

gen disability_atleast_hh=1 if func_difficulty_hh>2
replace disability_atleast_hh=0 if func_difficulty_hh<3
replace disability_atleast_hh=. if func_difficulty_hh==.

lab var disability_atleast_hh "P3 At least a lot of difficulty in Any Domain for any adult in the hh"

********************************************************************************
*everattended school
rename everattend_new everattended_new 
la var everattended_new "Ever attended school"
lab var edattain_new "1 Less than Prim 2 Prim 3 Sec 4 Higher"
*Education - completed primary school +15 year age
*This variable was created for computing multidimensional poverty
gen ind_atleastprimary_all = (edattain_new>=2)
replace ind_atleastprimary_all =. if edattain_new==.
la var ind_atleastprimary_all "Primary school completion or higher adults 15+"
*Individual atleast Primary Education***
gen ind_atleastprimary = (edattain_new>=2)
replace ind_atleastprimary =. if edattain_new==.
replace ind_atleastprimary =. if age<     25
la var ind_atleastprimary "Primary school completion or higher adults 25+"
*Individual  secondary Education***
gen ind_atleastsecondary = (edattain_new>=3)
replace ind_atleastsecondary =. if edattain_new==.
replace ind_atleastsecondary =. if age<     25
la var ind_atleastsecondary "Upper secondary school completion or higher"
***generating Literacy***
la var lit_new "Literacy"

********************************************************************************
*adult Internet use
rename internet_new internet
lab var internet "Individual uses internet"
*Adult who own mobile phone
gen mobile_own = 1 if f2_mobile_phone==1
replace mobile_own = 0 if f2_mobile_phone==2
lab var mobile_own "Adult owns mobile phone"
*Employment 
gen ind_emp = (d1_main_activity==1|d1_main_activity==2|d1_main_activity==3|d1_main_activity==4|d1_main_activity==5|d1_main_activity==6)
replace ind_emp = . if d1_main_activity==.
*Youth Idle
gen youth_idle = (ind_emp==0&school_new==0)
replace youth_idle=. if age>24
replace youth_idle=. if school_new==.&ind_emp==.
*Manufacturing worker
rename indgen_new work_manufacturing
replace work_manufacturing=. if ind_emp==0
la var work_manufacturing "In manufacturing"
*Women at managerial work
gen work_managerial =cond(mi(main_occup_1digit),.,cond(main_occup_1digit==1,1,0))
replace work_managerial = 0 if ind_emp==0
replace work_managerial = . if female==0
*Infromal work
gen work_informal= (d1_main_activity==2|d1_main_activity==5|d1_main_activity==6) 
replace work_informal=. if d1_main_activity==.
tab d1_main_activity work_informal

*work_managerial is a binary for women in managerial work among all women while work_managerial2 code  women in managerial work among working women only. We use  work_managerial2  to generate the  women in managerial work   indicator for the DS-E database.

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if (ind_emp==. & work_managerial==.) 

*work_informal is a binary variable for informal work status among all adults while work_informal2 codes informal work among workers only. We use work_informal2 to generate the informal work indicator for the DS-E database.

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.

************************************************************************************
*Drinking water source
rename watsup_new ind_water 
*Sanitation
rename toilet_new ind_toilet 
replace ind_toilet = 0 if g11_share_toilet ==1
*acces to electircity
rename electric_new ind_electric 
*clean cooking fuel 
rename fuelcook_new ind_cleanfuel 
** Adequate housing
*Floor
gen ind_floor = (g3a_floor==2|g3a_floor==3)
replace ind_floor =. if g3a_floor==.
*roof
gen ind_roof = (g4a_roof==2|g4a_roof==3)
replace ind_roof =. if g4a_roof==.
*wall
gen ind_wall = (g5a_wall==2|g5a_wall==3)
replace ind_wall =. if g5a_wall==.
*living condition
gen ind_livingcond = (ind_floor==1&ind_roof==1&ind_wall==1)
replace ind_livingcond = . if (ind_floor==.&ind_roof==.&ind_wall==.)

tab ind_livingcond 

**Houshold goods
* radio
gen ind_radio = 1 if g17z_radio ==1
replace ind_radio = 0 if g17z_radio ==2
*television
rename tv_new ind_tv
*bike
rename bike_new ind_bike
*Motorcycle
rename motorcycle_new ind_motorcycle
*telephone
rename phone_new ind_phone
*refrig
rename refrig_new ind_refrig
*computer
rename computer_new ind_computer
*autos
gen ind_autos = (g17_hhld_goods__1==1|g17_hhld_goods__2==1|g17_hhld_goods__3==1|g17_hhld_goods__5==1)
replace ind_autos = . if g17_hhld_goods__1==.&g17_hhld_goods__2==.&g17_hhld_goods__3==.&g17_hhld_goods__5==.
*assets ownership
egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_motorcycle ind_autos ind_computer ind_bike)

********************************************************************************
*Multidimensional poverty 	
*if observation has labor information labor_tag==1, otherwise ==0
gen labor_tag=1 if ind_emp!=.
replace labor_tag=0 if ind_emp==.

*Education - completed primary school
gen deprive_educ=cond(mi(ind_atleastprimary_all),.,cond(ind_atleastprimary_all==0,0.33,0)) if labor_tag==0
gen deprive_work=.	if	labor_tag==0
		
replace deprive_educ=cond(mi(ind_atleastprimary_all),.,cond(ind_atleastprimary_all==0,0.25,0))  if labor_tag==1
replace deprive_work=cond(mi(ind_emp),.,cond(ind_emp==0,0.25,0))  if labor_tag==1

gen deprive_health_water=cond(mi(ind_water),.,cond(ind_water==0,1,0))
	
gen deprive_health_sanitation=cond(mi(ind_toilet),.,cond(ind_toilet==0,1,0))

gen deprive_sl_electricity=cond(mi(ind_electric),.,cond(ind_electric ==0,1,0))

gen deprive_sl_fuel=cond(mi(ind_cleanfuel),.,cond(ind_cleanfuel==0,1,0))

gen deprive_sl_housing=cond(mi(ind_livingcond),.,cond(ind_livingcond==0,1,0))
	
gen deprive_sl_asset = 0
replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)

replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.

lab var deprive_educ "Deprived if less than primary school completion"
lab var deprive_work "Deprived in work"
lab var deprive_health_water "Deprived in water"
lab var deprive_health_sanitation "Deprived in terms of sanitation"
lab var deprive_sl_electricity "Deprived for electricity"
lab var deprive_sl_fuel "Deprived in terms of clean fuel"
lab var deprive_sl_housing "Deprived in terms of housing binary"
lab var deprive_sl_asset "Deprived in terms of asset ownership"

*we assume that dimensions can not be missing but indicators inside can be missing. The dimension weights remain the same but the indicators weights should change
egen missing_health=rowmiss(deprive_health_water deprive_health_sanitation)
replace missing_health=2-missing_health
egen health_temp=rowtotal(deprive_health_water deprive_health_sanitation)
					
egen missing_sl=rowmiss(deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset)
replace missing_sl=4-missing_sl
egen sl_temp=rowtotal(deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset)
						
gen deprive_health=(1/missing_health)*0.33*health_temp if  labor_tag==0
gen deprive_sl=(1/missing_sl)*0.33*sl_temp if  labor_tag==0
	
replace deprive_health=(1/missing_health)*0.25*health_temp if labor_tag==1 
replace deprive_sl=(1/missing_sl)*0.25*sl_temp if  labor_tag==1 

gen mdp_score=cond(mi(deprive_educ)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_health+deprive_sl) if  labor_tag==0
replace mdp_score=cond(mi(deprive_educ)|mi(deprive_work)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_work+deprive_health+deprive_sl) if  labor_tag==1 

gen ind_mdp=cond(mi(mdp_score),.,cond((labor_tag==1 &mdp_score>0.25)|(labor_tag==0 &mdp_score>0.33),1,0))

lab var mdp_score "Multidemensional Poverty Score"
lab var ind_mdp "M1_Multidemensional Poverty status"

********************************************************************************
keep InterviewId country_name country_abrev country_dataset_year admin1 admin2 female age age_group urban_new urban_rural disability_* *_any *_some *_atleast_alot school_new edattain_new everattended_new ind_atleastprimary_all ind_atleastprimary ind_atleastsecondary lit_new ind_emp youth_idle work_manufacturing work_managerial work_informal internet mobile_own ind_water ind_toilet ind_electric ind_cleanfuel ind_livingcond ind_asset_ownership cell_new ind_floor ind_roof ind_wall ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_autos ind_phone ind_computer deprive_educ deprive_work deprive_health_water deprive_health_sanitation deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset mdp_score ind_mdp person_id seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty


egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new comm_diff_new cognitive_diff_new mobility_diff_new selfcare_diff_new)
gen ind_func_diff_missing= (func_diff_missing==6)

egen disaggvar_missing = rowmiss(female age urban_new)

gen ind_disaggvar_missing = (disaggvar_missing >0)

save "${tonga_data}\Tonga_Cleaned_Individual_Data_withmissing.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1


rename InterviewId hh_id
la var hh_id "Household ID"

tostring person_id, gen (person_num) 
gen ind_id = hh_id + " "  + person_num
la var ind_id "Individual ID"

gen hh_weight=1
lab var hh_weight "Household Sample weight"
gen ind_weight=1 
lab var ind_weight "Individual Sample weight"
gen ind2_weight=1
lab var ind2_weight "DHS Individual sample weight"
gen dv_weight=1 
lab var dv_weight "DHS Domestic Violence sample weight"

drop person_id person_num 
drop func_diff_missing ind_func_diff_missing disaggvar_missing ind_disaggvar_missing 

la var ind_emp "Employed"
la var youth_idle "Youth is idle"
la var work_managerial "Women in managerial position"
la var work_informal "Informal work"
la var ind_water "Safely managed water source "
la var ind_toilet "Safely managed sanitation"
la var ind_electric "Electricity"
la var ind_cleanfuel "Clean cooking fuel"
la var ind_floor "Floor quality"
la var ind_wall "Wall quality"
la var ind_roof "Roof quality"
la var ind_livingcond "Adequate housing"
la var ind_radio "Household has radio"
la var ind_tv "Household has television"
la var ind_refrig "Household has refrigerator"
la var ind_bike "Household has bike"
la var ind_motorcycle "Household has motocycle"
la var ind_phone "Household has telephone"
la var ind_computer "Household has computer"
la var ind_autos "Household has automobile"
la var cell_new "Household has mobile"
la var ind_asset_ownership "Share of  Assets"

la var disability_any "Any Difficulty"
la var seeing_any "Any Difficulty in seeing"
la var hearing_any "Any Difficulty in hearing"
la var mobile_any "Any Difficulty in walking"
la var cognition_any "Any Difficulty in cognition"
la var selfcare_any "Any Difficulty in selfcare"
la var communicating_any "Any Difficulty in communicating"

la var disability_some "Some Difficulty"
la var seeing_some "Some Difficulty in seeing"
la var hearing_some "Some Difficulty in hearing"
la var mobile_some "Some Difficulty in walking"
la var cognition_some "Some Difficulty in cognition"
la var selfcare_some "Some Difficulty in selfcare"
la var communicating_some "Some Difficulty in communicating"

la var disability_atleast "At least a lot  Difficulty"
la var seeing_atleast_alot "At least a lot  Difficulty in seeing"
la var hearing_atleast_alot "At least a lot  Difficulty in hearing"
la var mobile_atleast_alot "At least a lot  Difficulty in walking"
la var cognition_atleast_alot "At least a lot  Difficulty in cognition"
la var selfcare_atleast_alot "At least a lot  Difficulty in selfcare"
la var communicating_atleast_alot "At least a lot  Difficulty in communicating"

la var seeing_diff_new "Difficulty in seeing"
la var hearing_diff_new "Difficulty in hearing"
la var comm_diff_new "Difficulty in communicating"
la var cognitive_diff_new "Difficulty in cognition"
la var mobility_diff_new "Difficulty in walking"

la var selfcare_diff_new "Difficulty in selfcare"
la var func_difficulty "Difficulty in Any Domain"

*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 ind_weight ind2_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary   computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal ind_water work_managerial2  work_informal2 ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh"

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

keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 ind_weight ind2_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2/*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 ind_weight ind2_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2/*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

save "${tonga_data}\Tonga_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

save "${tonga_data}\Tonga_Cleaned_Household_Level_Data_Trimmed.dta", replace

