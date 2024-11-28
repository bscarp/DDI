/*******************************************************************************
******************Kenya Census 2019 ********************************************
********************************************************************************
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/
Reference to appendix and paper:
For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).
Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, GVS, Pinilla-Roncancio, M.,  Rivas Velarde, M., Teodoro, D.,  and Mitra, S. (2024). The Disability Statistics – Estimates Database: an innovative database of internationally comparable statistics on disability inequalities. International Journal of Population Data Science.
Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com
Author: Bradley Carpenter
Suggested citation: DDI. Disability Statistics Database - Estimates (DS-E Database)). Disability Data Initiative collective. Fordham University: New York, USA. 2024.
*******************************************************************************/
********************************************************************************
*Globals 
********************************************************************************
*ssc install unique 
clear
clear matrix
clear mata 
set maxvar 30000

*Merge population with household data
*use "C:\Users\bscar\Downloads\Census\2019TenPercent_Population.dta", clear
*merge m:1 COUNTY subcounty_code divisionname_code locationname_code sublocation_code EA ENUMERATOR_ID STRNUMBER HHNUMBER using "C:\Users\bscar\Downloads\Census\2019TenPercent_Households.dta"
*save "C:\Users\bscar\Downloads\Census\2019TenPercent_Merged.dta"

*Load data
cd "C:\Users\bscar\Downloads\Census\Kenya\"
use "C:\Users\bscar\Downloads\Census\Kenya\2019TenPercent_Merged.dta", clear

**Initial setup
clonevar age = P12
drop if age<15
gen country_name="Kenya"
la var country_name "Country name"
gen country_abrev = "KE"
la var country_abrev "Country abbreviation"
gen country_dataset_year="Kenya_Census_2019"
la var country_dataset_year "Country Data and year"
*Needs fixing
egen hh_id = concat(COUNTY subcounty_code divisionname_code locationname_code sublocation_code EA STRNUMBER HHNUMBER),format(%03.0f)
la var hh_id "Household ID"
egen ind_id = concat(HHNUMBER LINE_NUMBER)
la var ind_id "Individual ID"
clonevar admin1 = COUNTY
la var admin1 "Admin 1 Level"
clonevar admin2 = subcounty_code
la var admin2 "Admin 2 Level"
**Weights**
gen hh_weight=1
lab var hh_weight "Household Sample weight"
gen ind_weight=1 
lab var ind_weight "Individual Sample weight"
***Age group
gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65
la var age_group "Age Group"
***Gender
gen female=1 if P11==2
replace female=0 if P11==1
la var female "Female or Male"
**Rural/Urban
gen urban_new=EA_TYPE - 1

/*
decode COUNTY, generate(region_name)
gen region_name_enc = COUNTY
gen hh_weight = 1

*Set specifications (P11 is for Intersex)
drop if P12 < 15
drop if P11 == 3
drop if missing(female)
drop if missing(age_group)
*/

**Disability indicators
clonevar seeing_diff_new=P42_1
replace seeing_diff_new=. if P42_1>4
clonevar hearing_diff_new=P42_2
replace hearing_diff_new=. if P42_2>4
clonevar mobility_diff_new=P42_3
replace mobility_diff_new=. if P42_3>4
clonevar cognition_diff_new=P42_4
replace cognition_diff_new=. if P42_4>4
clonevar selfcare_diff_new=P42_5
replace selfcare_diff_new=. if P42_5>4
clonevar comm_diff_new=P42_6
replace comm_diff_new=. if P42_6>4

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognition_diff_new selfcare_diff_new comm_diff_new)

*Disability levels for any domain
gen disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

*Create indicators for no disability and for none or some disability
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

gen cognition_any = (cognition_diff_new>=2) 
replace cognition_any=. if cognition_diff_new ==.

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

gen cognition_some = (cognition_diff_new==2) 
replace cognition_some=. if cognition_diff_new ==.

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

gen cognition_atleast_alot = (cognition_diff_new>=3) 
replace cognition_atleast_alot=. if cognition_diff_new ==.

gen selfcare_atleast_alot = (selfcare_diff_new>=3) 
replace selfcare_atleast_alot=. if selfcare_diff_new ==.

gen communicating_atleast_alot = (comm_diff_new>=3) 
replace communicating_atleast_alot=. if comm_diff_new ==.

*Household level Disability 
egen func_difficulty_hh=max(func_difficulty), by(COUNTY subcounty_code divisionname_code locationname_code sublocation_code EA ENUMERATOR_ID STRNUMBER HHNUMBER)
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

* everattended_new=1 if ever attended school; =0 no schooling ; =. don't know
gen everattended_new =P45
recode everattended_new (9=.) (4=0) (3=1) (2=1)
tab everattended_new P45, m
/*
edattain_new= coded 0 for niu, 9 for unknown 
=1 for less than primary  completed
=2 for primary completed
=3 for secondary completed
=4 for university completed
For P47 (completed) that have "Not stated/DK", I used P46 (attended) with: attended primary=1, attended secondary=2, attended first tertiary=3, attended post-tertiary=4
*/
gen edattain_new=1 if everattended_new==0 | (!missing(everattended_new) & !missing(P47))
replace edattain_new=2 if  (P47 >= 8 & P47 <= 11) | P47 == 21 | (P47 == 98 & ((P46 >= 9 & P46 <= 12) | P47 == 22))
replace edattain_new=3 if  (P47 >= 12 & P47 <= 14) | P47 == 22 | (P47 == 98 & ((P46 >= 13 & P46 <= 17) | P47 == 23 | P47 == 24))
replace edattain_new=4 if  (P47 >= 15 & P47 <= 20) | P47 == 23 | P47 == 24 | (P47 == 98 & P46 >= 18 & P46 <= 20)
tab edattain_new P47,m
*school_new=0 if currently not in school =1 if currently in school
gen school_new=P45
recode school_new (9=.) (4=0) (3=0) (2=0)
tab school_new P45, m
gen ind_less_primary = (edattain_new==1)
replace ind_less_primary = . if edattain_new==.

lab var edattain_new "1 Less than Prim 2 Prim 3 Sec 4 Higher"

*variable for ages 15+ used for the deprivation variable for multidimensional poverty
gen ind_atleastprimary_all = (edattain_new>=2)
replace ind_atleastprimary_all =. if edattain_new==.

***Individual atleast Primary Education***
gen ind_atleastprimary = (edattain_new>=2)
replace ind_atleastprimary =. if edattain_new==.
replace ind_atleastprimary =. if age<     25
***Individual  secondary Education***

gen ind_atleastsecondary = (edattain_new>=3)
replace ind_atleastsecondary =. if edattain_new==.
replace ind_atleastsecondary =. if age<     25
      

*internet	=1 =0
gen computer=1 if P58==1
replace computer=0 if P58==2
gen internet=1 if P57==1
replace internet=0 if P57==2
gen mobile_own = 1 if P55==1
replace mobile_own = 0 if P55==2
*Employment
gen ind_emp = (P49 > 0 & P49 < 10)
replace ind_emp = . if P49==.
*Youth Idle
gen youth_idle = (ind_emp==0&school_new==0)
replace youth_idle=. if age>24
replace youth_idle =. if school_new ==. & ind_emp==.

*work_manufacturing=1 if manufacturing =0 otherwise 
gen work_manufacturing= (P53 == 3)
replace work_manufacturing=. if P53==.
*Informal work
gen work_informal= (P50 == 12 | P50 == 13 | P50 == 15 | P50 == 17 | P50 == 18) 
replace work_informal=. if P50==.
tab work_informal P50
*work_informal is a binary variable for informal work status among all adults while work_informal2 codes informal work among workers only. We use work_informal2 to generate the informal work indicator for the DS-E database.

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.


*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water
gen ind_water= (H33 == 5 | H33 == 7 | (H33 >= 9 & H33 <= 15))
replace ind_water=. if H33==.

*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet
gen ind_toilet= (H34 >= 1 & H34 <= 3 ) | H34 == 9 | (H34 >= 4 & H34 <= 5 & H35 == 2)
replace ind_toilet=. if H34==.

*ind_electric	=1 if yes =0 otherwise
gen ind_electric= (H38 == 1 | H38 == 7)
replace ind_electric=. if H38==.
*ind_cleanfuel (see description below of clean fuel)	=1 if good - NOT organic material =0 if bad - organic (dung, coal, etc)
gen ind_cleanfuel= (H37 == 1 | H37 == 3 | H37 == 4 | H37 == 7)
replace ind_cleanfuel=. if H37==.

** Adequate housing

*g3a_floor==1|
gen ind_floor = (H32 > 4 & H32 < 10)
replace ind_floor =. if H32==.
*g4a_roof==1|
gen ind_roof = (H30 == 5 | H30 == 8 | H30 == 9 | H30 == 11 | H30 == 13)
replace ind_roof =. if H30==.
*g5a_wall==1|
gen ind_wall = ((H31 > 10 & H31 < 14 ) | H31 == 16 | H31 == 17)
replace ind_wall =. if H31==.
***Living condition
gen ind_livingcond = (ind_floor==1&ind_roof==1&ind_wall==1)
replace ind_livingcond = . if (ind_floor==.&ind_roof==.&ind_wall==.)

**Assets
*radio
gen ind_radio = 1 if H39_1 ==1
replace ind_radio = 0 if H39_1 ==2

*ind_tv	=1  =0
gen ind_tv = 1 if (H39_2 == 1 | H39_3 == 1 | H39_4 == 1 | H39_5 == 1)
replace ind_tv = . if (H39_2==.&H39_3==.&H39_4==.&H39_5==.)

*ind_bike	=1 =0
gen ind_bike = 1 if H39_9 ==1
replace ind_bike = 0 if H39_9 ==2

*ind_motorcycle	=1 =0
gen ind_motorcycle = 1 if H39_10 ==1
replace ind_motorcycle = 0 if H39_10 ==2


*ind_refrig	=1 =0
gen ind_refrig = 1 if H39_13 ==1
replace ind_refrig = 0 if H39_13 ==2

*cell_new 	=1 =0
egen cell_new= max(mobile_own), by(COUNTY subcounty_code divisionname_code locationname_code sublocation_code EA ENUMERATOR_ID STRNUMBER HHNUMBER)

*ind_computer	=1 if computer =0
gen ind_computer = 1 if H39_8 ==1
replace ind_computer = 0 if H39_8 ==2

*Automobiles include car,truck,motorboat,tuk tuk, and tractor
gen ind_autos = (H39_11==1 | H39_12==1 | H39_14==1 | H39_17==1 | H39_18==1)
replace ind_autos = . if H39_11==.&H39_12==.&H39_14==.&H39_17==.&H39_18==.

egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig cell_new ind_motorcycle ind_autos ind_computer ind_bike)

*Multidimensional poverty 	
*if observation has employment information labor_tag==1, otherwise ==0
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

* NEW CODE FOR DEPRIVE_SL_ASSET added Jan 18th 2024

gen deprive_sl_asset = 0
replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)

replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.

lab var deprive_educ "Deprived if less than primary school completion"
lab var deprive_work "Deprived in work binary"
lab var deprive_health_water "Deprived in water binary"
lab var deprive_health_sanitation "Deprived in terms of sanitation binary"
lab var deprive_sl_electricity "Deprived for electricity binary"
lab var deprive_sl_fuel "Deprived in terms of clean fuel binary"
lab var deprive_sl_housing "Deprived in terms of housing binary"
lab var deprive_sl_asset "Deprived in terms of asset ownership binary"

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
****************************************************************************

/* keep command
keep country_name country_abrev country_dataset_year ind_id hh_id admin1 admin2 female age age_group urban_new seeing_diff_new hearing_diff_new mobility_diff_new cognition_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_* *_any *_some *_atleast_alot everattended_new edattain_new ind_atleastprimary_all ind_atleastprimary ind_atleastsecondary ind_emp youth_idle work_manufacturing work_informal computer internet mobile_own ind_water ind_toilet ind_electric ind_cleanfuel ind_livingcond ind_asset_ownership cell_new ind_floor ind_roof ind_wall ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_autos ind_computer deprive_educ deprive_work deprive_health_water deprive_health_sanitation deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset mdp_score  ind_mdp
*/



lab var disability_atleast_hh "P3 At least a lot of difficulty in Any Domain for any adult in the hh"

egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new comm_diff_new cognition_diff_new mobility_diff_new selfcare_diff_new)
gen ind_func_diff_missing= (func_diff_missing==6)

egen disaggvar_missing = rowmiss(female age urban_new)

gen ind_disaggvar_missing = (disaggvar_missing >0)

save "C:\Users\bscar\Downloads\Census\Kenya\2024\Kenya_Census_2019_Cleaned_Individual_Data_withmissing.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1


drop func_diff_missing ind_func_diff_missing disaggvar_missing ind_disaggvar_missing 

*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognition_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary   computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh"

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

keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognition_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognition_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh

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
la var cognition_diff_new "Difficulty in cognition"
la var mobility_diff_new "Difficulty in walking"

la var selfcare_diff_new "Difficulty in selfcare"
la var func_difficulty "Difficulty in Any Domain"

save "C:\Users\bscar\Downloads\Census\Kenya\2024\Kenya_Census_2019_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

save "C:\Users\bscar\Downloads\Census\Kenya\2024\Kenya_Census_2019_Cleaned_Household_Level_Data_Trimmed.dta", replace
