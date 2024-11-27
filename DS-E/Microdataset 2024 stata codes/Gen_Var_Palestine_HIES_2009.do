/*******************************************************************************
******************Palestine HIES 2009 ********************************************
********************************************************************************
Author: Jaclyn Yap
Reference: DSE
Website:
*******************************************************************************/
global PATH "C:\Users\Jaclyn Yap\Desktop\WB_2024\Palestine_HIES\WBG_2009_PECS_v01_M_STATA8\WBG_2009_PECS_v01_M_STATA8\"
global CLEAN "C:\Users\Jaclyn Yap\Desktop\WB_2024\Clean"
**************Merge file****************************** 
 cd "$PATH"
use "persons.dta" , clear 

merge m:1 id00 using "house.dta", gen(merge_householdvar)

drop if merge_householdvar==2 

merge m:1 id00 using "locality_2009.dta", gen(merge_location)

gen ID00 = id00
merge m:1 ID00 using "assets_2009.dta", keepusing(i01 I13*) gen(merge_food_socialprot)
drop ID00

merge 1:1 id00 d1 using "indchar09.dta", keepusing(act_type_4cats) gen(merge_industry)

merge m:1 id00  using "final-main09.dta", keepusing(id01 id02 strata clus region wstbank gaza) gen(merge_region) 

merge m:1 id00 using "maingrpsnis.dta", gen(merge_consumption) keepusing(grp1-grp30)
*17 . medical care is label. but group 33 in services

save "Palestine_HIES_2009_NotClean.dta", replace
**************************

use "Palestine_HIES_2009_NotClean.dta" , clear
gen country_name="Palestine/West Bank and Gaza"
gen country_abrev="PS"
gen hh_id = id00*1000
tostring hh_id, replace
tostring d1, replace
gen  ind_id = hh_id+d1

gen country_dataset_year = 2009
gen admin1 =  region 
tab region wstbank
tab region gaza
label def REGION 1 "West Bank" 2 "Gaza Strip"
label val admin1 REGION

gen admin2 = id01 
label def GOV  1 "Jenin" 5 "Tubas" 10 "Tulkarm" 15 "Nablus" 20 "Qalqilya" 25 "Salfit" 30 "Ramallah"	35 "Jericho" 40 "Jerusalem"	45 "Bethlehem" 50 "Hebron" 55 "North Gaza" 60 "Gaza" 65 "Deir Al-Balah" 70 "Khan Younis" 75 "Rafah"	
label val admin2 GOV

gen hh_weight = rw
gen ind_weight = rw
gen sample_strata = strata

**************

gen female = 1 if sex == 2 
replace female = 0 if sex ==1
tab sex female, m

*age already in varname age
tab age

*area of residence - there is camp 11%
*camp recoded as missing in 2021
  
gen urban_new = 1 if  ltype  ==1 
replace urban_new  = 0 if ltype   ==2
replace urban_new  = 2 if ltype   ==3

tab ltype urban_new, m

label define URBAN 0 "Rural" 1 "Urban" 2 "Camp"
label val urban_new URBAN

tab ltype urban_new, m 




drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65

*functional difficulty

gen seeing_diff_new =  d13_1_h
gen hearing_diff_new = d13_2_h
gen mobility_diff_new = d13_3_h
gen cognitive_diff_new = d13_4_h
gen comm_diff_new =	d13_5_h

recode seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new (0=1) (1=2) (2=3) (3=4)


label define FUNCDIFF 1 "No difficulty" 2 "Partial difficulty" 3 "Large difficulty" 4 "Complete difficulty"

label val  seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new FUNCDIFF

fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new

*no selfcare_diff_new
egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new  comm_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m

count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  


logit missing_func_difficulty age female i.urban_new,or



***************************

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

*gen selfcare_any = (selfcare_diff_new>=2) 
*replace selfcare_any=. if selfcare_diff_new ==.

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

*gen selfcare_some = (selfcare_diff_new==2) 
*replace selfcare_some=. if selfcare_diff_new ==.

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

*gen selfcare_atleast_alot = (selfcare_diff_new>=3) 
*replace selfcare_atleast_alot=. if selfcare_diff_new ==.

gen communicating_atleast_alot = (comm_diff_new>=3) 
replace communicating_atleast_alot=. if comm_diff_new ==.



*****Education
gen everattended_new = (d14==1 | d14==2 | d14==3) if !mi(d14)
tab d14 everattended_new, m 

gen school_new =(d14==1) if !mi(d14)
tab d14 school_new, m 


*for both who are not in school and those who are currently in school
gen edattain_new = 1 if everattended_new ==0 | d16 ==1| d16==2 | (d16 ==3 & (d14==1 | d14==2))  //elementary and left before completing or currently attending
replace edattain_new = 2 if (d16==3 & d14==3) | d16 ==4 //completed elementary 
replace edattain_new = 2 if ( d16 ==5 & (d14==1 | d14==2)) //secondary and left before completing or currently attending
replace edattain_new = 3 if (d16 ==5 & d14==3) | d16==6 //secondary, attended and graduated
replace edattain_new = 4 if inlist(d16, 7,8 ,9 ,10)
tab d16 edattain_new ,m

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

gen ind_emp = (inlist(d18, 1,2,3)) if !mi(d18)
tab d18 ind_emp, m


*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24


gen work_informal = 0
replace work_informal = 1 if d19==2 | d19==3 | d19==5 



*work_manufacturing=1 if manufacturing =0 otherwise 
*denominator is only among those employed
* act_type_4cats = workers: type of economic activity ag, manf, constr, svcs
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if ind_emp==1 & act_type_4cats==2
replace work_manufacturing=. if ind_emp==0 | act_type_4cats==.

* women in managerial work
*supposedly d21 in questionnaire but cannot find in dataset (and most have no labels)

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if (ind_emp==. & work_managerial==.) 

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.

gen ind_radio = (h21_19==1) if !mi(h21_19)
gen ind_tv = (h21_11 == 1) if !mi(h21_11)
gen ind_autos = (h21_1 ==1) if !mi(h21_1)
gen ind_computer = (h21_16 ==1) if !mi(h21_16) //typo in 2021
gen ind_refrig = (h21_2 ==1) if !mi(h21_2)
gen ind_phone = (h21_13==1) if !mi(h21_13)
gen ind_truck  = (h22_3==1) if !mi(h22_3)
gen cell_new = (h21_15==1) if !mi(h21_15)
gen ind_bike = .
gen ind_motorcycle = . 


gen ind_cleanfuel = (inlist(h13_1,1,3)) if !mi(h13_1)
tab h13_1  ind_cleanfuel,m

gen ind_electric = (h9b==1) if !mi(h9b)
tab h9b ind_electric, m 

*Is not specified as drinking water - connection to public networks -water
*Local Public network 2. Israelian network 3. rain water 4. Bridges 5. Tank 6. other
gen ind_water = (inlist(h9a, 1, 2, 3)) if !mi(h9a)

*h12 Availability of a toilet (WC): 1. Toilet with Piped Water 2. Toilet without Piped Water 3. No Toilet
gen ind_toilet = (h12==1 | h12==2) if !mi(h12)


gen ind_floor = .

gen ind_roof =.

fre h3
gen ind_wall = (inlist(h3, 1, 2, 5)) if !mi(h3)
tab h3 ind_wall

gen ind_livingcond = (ind_wall==1)
replace ind_livingcond = . if ( ind_wall==.)

egen ind_asset_ownership =rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer)

gen food_insecure = 0 if I13_1==0
replace food_insecure = 1 if inlist(I13_1, 1, 2, 3) 
replace food_insecure = 1 if inlist(I13_5, 1, 2, 3) 
replace food_insecure = 1 if inlist(I13_6, 1, 2, 3)
replace food_insecure = 1 if inlist(I13_8, 1, 2, 3)
replace food_insecure = 1 if inlist(I13_9, 1, 2, 3) 
replace food_insecure = . if mi(I13_1) & mi(I13_5) & mi(I13_6) & mi(I13_8) & mi(I13_9)
replace food_insecure = . if I13_1==99 & I13_5==99 & I13_6==99 & I13_8==99 & I13_9==99



gen social_prot = (i01==1 |i01==2)
replace social_prot =. if i01==99 | i01==5
tab i01 social_prot, m 

gen health_insurance = (d11>0) if !mi(d11)
tab d11 health_insurance ,m 

****************
bys hh_id: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)


egen hh_cons_month = rowtotal(grp1-grp26) //based on IHSN data variables dictionary
gen health_exp_hh = grp17 / hh_cons_month //medical care is grp 33 in questionnaire

*****************


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

gen deprive_sl_asset = 0
replace deprive_sl_asset = 1 if ( (ind_radio + ind_tv + ind_phone + ind_refrig <2) & ind_autos==0)
replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_autos==.


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
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu  	 female urban_new age  age_group 	seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 		seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 		everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  	computer internet mobile_own 	ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m 	ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership 	health_insurance social_prot food_insecure shock_any health_exp_hh 	deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp"
	
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
					
keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 		seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 	/*education*/	everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 	


order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 		seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 	/*education*/	everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 



save "${CLEAN}\Palestine_HIES_2009_Clean.dta" , replace


