/*******************************************************************************
******************Tajikistan WASH 2016 *****************************************
********************************************************************************
Author: Jaclyn Yap
Reference: DSE
Website:
*******************************************************************************/
global PATH "C:\Users\Jaclyn Yap\Desktop\WB_2024\Tajikistan\TJK_2016_WASH_v01_M_STATA11\TJK_2016_WASH_v01_M_STATA11\"

global CLEAN "C:\Users\Jaclyn Yap\Desktop\WB_2024\Clean"
cd "$PATH"


/*
log using "C:\Users\Jaclyn Yap\Desktop\WB_2024\TJK_2016_WASH_v01_M_STATA11\codebook", replace
use new_id REGION M1_* M2_*  using "C:\Users\Jaclyn Yap\Desktop\WB_2024\TJK_2016_WASH_v01_M_STATA11\TJK_2016_WASH_v01_M_STATA11/anon_wb_wash_all_short_.dta" , clear
codebook,c
use new_id M3* LS* using "C:\Users\Jaclyn Yap\Desktop\WB_2024\TJK_2016_WASH_v01_M_STATA11\TJK_2016_WASH_v01_M_STATA11/anon_wb_wash_all_short_.dta" , clear
codebook,c
use new_id REGION M4* HH* using "C:\Users\Jaclyn Yap\Desktop\WB_2024\TJK_2016_WASH_v01_M_STATA11\TJK_2016_WASH_v01_M_STATA11/anon_wb_wash_all_short_.dta" , clear
codebook,c
reshape long M1_Q4_ M1_Q5_ M1_Q3_ M1_Q2_ M1_Q6_ M1_Q9_ M1_Q10_ M1_Q15_ M1_Q12_ M1_Q11_ M1_Q13_  , i(new_id) j(id, string) 
*/

*M2_ household conditions
*M2A -livestock M2B -M2F - consumption
*M3 Water supply M3A_Q8
*M4A_Q1 toilet

use new_id REGION M1_*  using "anon_wb_wash_all_short_.dta" , clear

reshape long M1_Q2_ M1_Q3_ M1_Q4_ M1_Q5_ M1_Q6_ M1_Q7_ M1_Q8_ M1_Q9_ M1_Q10_ M1_Q11_ M1_Q12_ M1_Q13_ M1_Q15_ M1_Q16_ M1_Q17_ M1_Q18_ M1_Q19_ M1_Q20_ M1_Q21_ , i(new_id) j(ind_id, string)

egen missing= rowmiss(M1_Q2_-M1_Q16_)
tab missing
drop if missing ==13


drop missing 

save TJ_roster, replace


**********

use TJ_roster, clear

merge m:1 new_id using "anon_wb_wash_all_short_consumption_.dta", keepusing(M2_Q2* M2_Q1E M3A_Q8  M4A_Q1 M2_Q1C M2_Q1A M2_Q1B) gen(merge_household)
drop if merge_household==2

*This file includes only hh head/spouse/children: total 409 hh and 2837 individuals; indweight pertains to weight of hhhead,spouse, children
gen hhid2=new_id
merge m:1 hhid2 using "tjk_2017_wash_v01_m_v01_a_ecapov_3.dta", keepusing(indweight location gall  health hhsize psu) gen(merge_surveydetails)


drop if merge_surveydetails==2
drop hhid2


save "$PATH/Tajikistan_WASH_2016_NotClean.dta", replace

ren ind_id ind_id_orig

gen country_name="Tajikistan"
gen country_abrev="TJ"

gen hh_id = string(new_id)
gen ind_id= hh_id + ind_id_orig

gen country_dataset_year = 2016
clonevar admin1 = REGION
gen hh_weight = indweight //indweight is the household head weight so it's really for the hh
gen ind_weight = indweight


gen female = 1 if M1_Q3_ == 2 
replace female = 0 if M1_Q3_ ==1
tab M1_Q3_ female, m



*age 
gen age = M1_Q2_

*area of residence - 
fre  location
gen urban_new = 1 if  location  ==3 
replace urban_new  = 0 if location   ==2

tab location urban_new, m

label define URBAN 0 "Rural" 1 "Urban" 
label val urban_new URBAN

tab location urban_new, m 



drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65


** disability

clonevar seeing_diff_new = M1_Q9_
clonevar hearing_diff_new = M1_Q10_
clonevar mobility_diff_new = M1_Q11_
clonevar cognitive_diff_new = M1_Q12_
clonevar selfcare_diff_new = M1_Q13_ 
clonevar comm_diff_new = M1_Q15_


fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new selfcare_diff_new

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new  comm_diff_new selfcare_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m

count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  
*41




*Disability levels for any domain 
gen disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

gen disability_none = (disability_any==0)
gen disability_nonesome = (disability_none==1|disability_some==1)

*No difficulty in any domain indicator
gen no_difficulty=1 if func_difficulty==1
replace no_difficulty = 0 if func_difficulty>1
replace no_difficulty = . if func_difficulty==.

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
**************

gen everattended_new = (M1_Q6_>1) if !mi(M1_Q6_)

gen edattain_new = 1 if M1_Q6_<=2 
replace edattain_new = 2 if M1_Q6_>=3 & M1_Q6_<=4
replace edattain_new = 3 if M1_Q6_>=5 & M1_Q6_<=8
replace edattain_new = 4 if M1_Q6_==9 | M1_Q6_==10


gen ind_atleastprimary = (edattain_new>=2)
replace ind_atleastprimary =. if edattain_new==.
replace ind_atleastprimary =. if age<25
*variable for ages 15+ used for the deprivation variable for multidimensional poverty

gen ind_atleastprimary_all = (edattain_new>=2)
replace ind_atleastprimary_all =. if edattain_new==.


gen ind_atleastsecondary = (edattain_new>=3)
replace ind_atleastsecondary =. if edattain_new==.
replace ind_atleastsecondary =. if age<25

tab edattain_new ind_atleastprimary,m
tab edattain_new  ind_atleastsecondary, m



*employment
fre M1_Q7_
gen ind_emp = (M1_Q7_<=7) if !mi(M1_Q7_) 
tab M1_Q7_ ind_emp
*no ind, occup, informal


gen ind_water = (inlist(M3A_Q8, 11, 12, 13,14, 21,31,41,51,91)) if !mi(M3A_Q8)
tab M3A_Q8 ind_water,m

gen ind_toilet = (inlist(M4A_Q1,11,12,21,22,31 )) if !mi(M4A_Q1)
tab M4A_Q1 ind_toilet,m

gen ind_electric = (M2_Q1E==1) if !mi(M2_Q1E)
** housing
gen ind_autos = (M2_Q2A==1) if !mi(M2_Q2A)

gen ind_refrig = (M2_Q2B==1) if !mi(M2_Q2B)

gen cell_new =(M2_Q2G==1) if !mi(M2_Q2G)

gen ind_radio =.
gen ind_tv =.
gen ind_phone =.
gen ind_bike =.
gen ind_motorcycle = .
gen ind_computer = .
egen ind_asset_ownership =rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer)

gen ind_cleanfuel=. //generate for mdp code to run

gen ind_wall = (M2_Q1A==1) if !mi(M2_Q1A)
tab M2_Q1A ind_wall,m

gen ind_roof = (M2_Q1B==1|M2_Q1B==2|M2_Q1B==3|M2_Q1B==6) if !mi(M2_Q1B)
tab M2_Q1B ind_roof,m

gen ind_floor = (M2_Q1C==1 | M2_Q1C==4 | M2_Q1C==5 |M2_Q1C==6) if !mi(M2_Q1C)
tab M2_Q1C ind_floor,m



gen ind_livingcond = (ind_floor==1 & ind_roof==1 & ind_wall==1)
replace ind_livingcond = . if (ind_floor==. & ind_roof==. & ind_wall==.)





bys hh_id: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)

gen health_exp = health
gen health_exp_hh = health/(gall+health)
su health_exp_hh



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

gen deprive_sl_asset = . //because there are only 2 assets in the dataset this is coded as missing
*replace deprive_sl_asset = 1 if ( (ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle <2) & ind_autos==0)
*replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.


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






*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu  	 female urban_new age  age_group 	seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 		seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 		everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  	computer internet mobile_own 	ind_emp youth_idle work_manufacturing  work_managerial  work_informal ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m 	ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership 	health_insurance social_prot food_insecure shock_any health_exp_hh 	deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp"
	
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
					
keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 		seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 	/*education*/	everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 	


order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 	seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 	/*education*/	everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_f ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

save "$CLEAN/Tajikistan_WASH_2016_Clean.dta", replace
