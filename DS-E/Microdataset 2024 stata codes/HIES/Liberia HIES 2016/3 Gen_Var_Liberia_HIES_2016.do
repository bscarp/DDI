/*
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/

Reference to appendix and paper:

For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).

Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, GVS, Pinilla-Roncancio, M.,  Rivas Velarde, M., Teodoro, D.,  and Mitra, S. (2024). The Disability Statistics – Estimates Database: an innovative database of internationally comparable statistics on disability inequalities. International Journal of Population Data Science.

Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com

Author: Jaclyn Yap, Ph.D.

Suggested citation: DDI. Disability Statistics Database - Estimates (DS-E Database). Disability Data Initiative collective. Fordham University: New York, USA. 2024.
*/

*source path*
global PATH " " 

*current directory*
global CLEAN " "

cd "$PATH"

use "HH_B.dta", clear
codebook weight_adjusted hh_b_07  hh_b_23 hh_b_02 hh_b_06 hh_b_06 new_urban_rural,c

*education
count
unique hhid ind_id
merge 1:1 hhid ind_id using "HH_C.dta", gen(merge_HH_C)
*functional difficulty
merge 1:1 hhid ind_id using "HH_D.dta", gen(merge_HH_D)

*employment
merge 1:1 hhid ind_id using "HH_E.dta", gen(merge_HH_E)

merge m:1 hhid  using "LR_HIES_food_insecure", gen(merge_food_ins)

*Housing
merge m:1 hhid  using "HH_J1", gen(merge_HH_J1)

merge m:1 hhid  using "LR_HIES_assets", gen(merge_assets)

merge m:1 hhid  using "LR_HIES_social_prot", gen(merge_social_prot)

save "Liberia_HIES_2016_NotClean.dta", replace

***************
*IDs
**************************

use "Liberia_HIES_2016_NotClean.dta", clear
rename  ind_id ind_id_orig // already in dataset
rename hh_id hh_id_orig // already in dataset
gen country_name="Liberia"
gen country_abrev="LR"

gen hh_id = string(hhid, "%15.0f") 

gen ind_id= string(hhid, "%15.0f") + string(ind_id, "%02.0f")
*destring(ind_id), replace
*format ind_id %16.0f

gen country_dataset_year = 2016
gen admin1 = hh_a_01
gen admin2 = hh_a_02

label def county 3 "Bomi" 6 "Bong" 9 "Grand Bassa" 12 "Grand Cape Mount" 15 "Grand Gedeh" 18 "Grand Kru" 21 "Lofa" 24 "Margibi" 27 "Maryland" 30 "Montserrado" 33 "Nimba" 36 "Rivercess" 39  "Sinoe" 42 "River Gee" 45 "Gbarpolu"

label val admin1 county

gen hh_weight = weight_adjusted 
gen ind_weight = weight_adjusted 
gen sample_strata = stratum
*********************


gen female = 1 if hh_b_02==2
replace female = 0 if hh_b_02 ==1
tab  female hh_b_02, m

*area of residence
gen urban_new = 1 if new_urban_rural==1
replace urban_new = 0 if new_urban_rural==2

label define URBAN 0 "Rural" 1 "Urban"
label val urban_new URBAN

tab new_urban_rural urban_new , m


recode age (999 =.)
tab age
drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65

*FUNCTIONAL DIFFICULTY VARIABLES
fre hh_d_24  - hh_d_29
clonevar seeing_diff_new=hh_d_24
clonevar hearing_diff_new=hh_d_25
clonevar mobility_diff_new =hh_d_26
clonevar cognitive_diff_new =hh_d_27
clonevar selfcare_diff_new =hh_d_28
clonevar comm_diff_new =hh_d_29


fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m


*overall
count
*19511
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  
*10

*since missing data is <5%, did not run logit
*logit missing_func_difficulty age female urban_new

*Disability levels for any domain 
gen disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

gen disability_none = (disability_any==0)
gen disability_nonesome = (disability_none==1|disability_some==1)

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

*education

*literacy
tab hh_c_04* 
tab hh_c_05 // read and write in any other language
gen lit_new =  cond(mi(hh_c_04_a),., cond(hh_c_04_a==1,1,0))
replace lit_new = cond(mi(hh_c_05),., cond(hh_c_05==1,1,0)) if lit_new==0 | lit_new==. // replace only for those who answered no in first question
tab lit_new hh_c_04_a,m

*everattended_new
fre hh_c_06
gen everattended_new = 1 if hh_c_06==1
replace everattended_new = 0 if hh_c_06==2 
tab hh_c_06 everattended_new , m

*school
fre hh_c_09
gen school_new = (hh_c_09==1) if !mi(hh_c_09)
replace school_new =0 if everattended_new==0

tab hh_c_09 school_new,m
fre hh_c_11 hh_c_12

*for both who are not in school and those who are currently in school
gen edattain_new = 1 if hh_c_06 == 2| hh_c_11<=15 | hh_c_12<=15
replace edattain_new = 2 if  inrange(hh_c_11, 16, 21) | inrange(hh_c_12, 16, 21)
replace edattain_new = 3 if  inrange(hh_c_11, 22, 26) | inrange(hh_c_12, 22, 26)
replace edattain_new = 4 if  inrange(hh_c_11, 27, 28) | inrange(hh_c_12, 27, 28)

tab   hh_c_11 edattain_new
tab   hh_c_12 edattain_new



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
*epr
*last 7 days
fre hh_e_09
fre hh_e_10_1
fre hh_e_07*
gen ind_emp = (hh_e_08==1) //includes those who said yes for any in  7A-7E 


*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24


*work_manufacturing=1 if manufacturing =0 otherwise 
*using ISIC codes for C- Manufacturing in the Liberia HIES Basic Information Document Appendix 8 ISIC Occupation codes
*denominator is only among those employed
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if ind_emp==1 & ((hh_e_19_2 >= 10 & hh_e_19_2 <= 33) | (hh_e_19_2 >= 101 & hh_e_19_2<= 330) )
replace work_manufacturing=. if ind_emp==0 | hh_e_19_2==.

* women in managerial work
gen work_managerial = 0 if female==1 // denominator - all women
replace work_managerial = 1 if  (hh_e_18_2 >= 11 &  hh_e_18_2 <= 14)  & female==1 
replace work_managerial = 1 if ( hh_e_18_2 >=  111 & hh_e_18_2<= 143)  & female==1 
replace work_managerial = 1 if (hh_e_18_2 >= 1111 &  hh_e_18_2 <= 1439) & female==1 
replace work_managerial = . if female==0


*informal
*The numerator includes adults who are informal workers. 
*The denominator includes all adults age 15 and above.
*Informal workers include the self-employed, those who work for a microenterprise of five or fewer employees or in a firm that is unregistered, and those who have no written contract with their employers. Workers who produce goods for own and/or family consumption are included as informal workers. Additionally, family workers without pay are included as informal workers.
*However, unlike in SDG 8.3.1, we use all adults as a denominator as many individuals with disabilities are not employed (out of the labor force) and would otherwise not be captured in the denominator which would then be very small. 
gen work_informal = 0
replace work_informal = 1 if hh_e_10_1==4 | hh_e_10_1==5 |hh_e_10_1==6 //unpaid workers, unpaid farmers, also includes those who produce for own consumption
replace work_informal = 1 if hh_e_10_1 == 3 // self employed without employees
replace work_informal = 1 if  hh_e_33==2 // No contract 
replace work_informal = 1 if hh_e_20<=5 // employees are 5 or fewer
fre hh_e_20

*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water
*Two questions on water - for rainy and dry season
*first create water indicator for each season. ind_water is ==1 if household used clean drinking water for BOTH seasons. 
*If rainy season ==1 AND dry season ==1 then ind_water ==1
*codes are taken from questionnaire
fre hh_j_18  hh_j_21
gen ind_water_rainy = ( inlist(hh_j_18, 1, 2, 3, 4, 5, 6, 8, 11, 12))
tab hh_j_18 ind_water_rainy, m

gen ind_water_dry = ( inlist(hh_j_21, 1, 2, 3, 4, 5, 6, 8, 11, 12))
tab hh_j_21 ind_water_dry, m

tab ind_water_rainy ind_water_dry
gen ind_water = ( ind_water_rainy == 1 & ind_water_dry ==1)
tab ind_water, m 


*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet
fre hh_j_12
gen ind_toilet= 1 if  inlist(hh_j_12 , 1, 3, 5)
replace ind_toilet = 0 if inlist(hh_j_12 , 2, 4, 6, 7)
tab hh_j_12 ind_toilet ,m 

*ind_electric	=1 if yes =0 otherwise
fre hh_j_15
gen ind_electric= 1 if hh_j_15==4 | hh_j_15==5
replace  ind_electric= 0 if  inlist(hh_j_15, 1, 2, 3, 6, 7)
tab  hh_j_15 ind_electric 

*ind_cleanfuel (see description below of clean fuel)	=1 if good - NOT organic material =0 if bad - organic (dung, coal, etc)
gen ind_cleanfuel= 1 if hh_j_17==1 | hh_j_17==3
replace ind_cleanfuel = 0 if hh_j_17==2 | hh_j_17 ==4 | hh_j_17 ==5 | hh_j_17 ==6
tab hh_j_17 ind_cleanfuel, m 

fre hh_j_10
gen ind_floor = 1 if hh_j_10 == 2 | hh_j_10 == 3 
replace ind_floor = 0 if hh_j_10  ==1 | hh_j_10 ==4 | hh_j_10 ==6
tab hh_j_10  ind_floor 

fre hh_j_09
gen ind_roof = 1 if hh_j_09 == 1 | hh_j_09==2 | hh_j_09==4
replace ind_roof = 0 if hh_j_09 ==3 | hh_j_09 ==5 | hh_j_09==6
tab hh_j_09 ind_roof 

fre hh_j_08
gen ind_wall = 1 if inlist(hh_j_08, 3, 4, 5)
replace ind_wall = 0 if inlist(hh_j_08 , 1, 2, 6, 7, 8, 9)
tab hh_j_08 ind_wall

gen ind_livingcond = (ind_floor==1 & ind_roof==1 & ind_wall==1)
replace ind_livingcond = . if (ind_floor==. & ind_roof==. & ind_wall==.)


	
egen ind_asset_ownership =rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer)



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
replace deprive_sl_asset = 1 if ( (ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle <2) & ind_autos==0)
replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.


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



**************************

bys hhid: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)

merge m:1 hhid using "LR_expenditure", keepusing(total_exp_month health_exp health_exp_hh) gen(merge_expenditure)





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


order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 		seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 	/*education*/	everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

*Female at Managerial Work
*work_managerial is a binary for women in managerial work among all women while work_managerial2 code  women in managerial work among working women only. We use  work_managerial2  to generate the  women in managerial work   indicator for the DS-E database.

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if (ind_emp==. & work_managerial==.)

*Informal Work
*work_informal is a binary variable for informal work status among all adults while work_informal2 codes informal work among workers only. We use work_informal2 to generate the informal work indicator for the DS-E database.

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.

save "${CLEAN}/Liberia_HIES_2016_Clean.dta" , replace


