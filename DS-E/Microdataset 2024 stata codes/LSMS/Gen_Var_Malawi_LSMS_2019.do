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

*prep
use "HH_MOD_L.dta", clear

local asset_number 507
local asset_name radio
fre hh_l02 if hh_l02==`asset_number'
gen `asset_name' = (hh_l03>0 & hh_l03<.) if hh_l02==`asset_number' & !mi(hh_l02) 
bys case_id: egen ind_`asset_name' = min(`asset_name')


local asset_number 509
local asset_name tv
fre hh_l02 if hh_l02==`asset_number'
gen `asset_name' = (hh_l03>0 & hh_l03<.) & hh_l02==`asset_number'
bys case_id: egen ind_`asset_name' = min(`asset_name')
replace ind_`asset_name'  = . if hh_l02 == `asset_number' & mi(hh_l01)

local asset_number 518
local asset_name autos
fre hh_l02 if hh_l02==`asset_number'
gen `asset_name' = (hh_l03>0 & hh_l03<.) & hh_l02==`asset_number' 
bys case_id: egen ind_`asset_name' = min(`asset_name')
replace ind_`asset_name'  = . if hh_l02 == `asset_number' & mi(hh_l01)

local asset_number 529
local asset_name computer
fre hh_l02 if hh_l02==`asset_number'
gen `asset_name' = (hh_l03>0 & hh_l03<.) & hh_l02==`asset_number' 
bys case_id: egen ind_`asset_name' = min(`asset_name')
replace ind_`asset_name'  = . if hh_l02 == `asset_number' & mi(hh_l01)

local asset_number 514
local asset_name refrig
fre hh_l02 if hh_l02==`asset_number'

gen `asset_name' = (hh_l03>0 & hh_l03<.) & hh_l02==`asset_number'
bys case_id: egen ind_`asset_name' = min(`asset_name')
replace ind_`asset_name'  = . if hh_l02 == `asset_number' & mi(hh_l01)


local asset_number 517
local asset_name motorcycle
fre hh_l02 if hh_l02==`asset_number'

gen `asset_name' = (hh_l03>0 & hh_l03<.) & hh_l02==`asset_number' 
bys case_id: egen ind_`asset_name' = min(`asset_name')
replace ind_`asset_name'  = . if hh_l02 == `asset_number' & mi(hh_l01)

local asset_number 516
local asset_name bike
fre hh_l02 if hh_l02==`asset_number'

gen `asset_name' = (hh_l03>0 & hh_l03<.) & hh_l02==`asset_number' 
bys case_id: egen ind_`asset_name' = min(`asset_name')
replace ind_`asset_name'  = . if hh_l02 == `asset_number' & mi(hh_l01)


collapse (min) ind_*, by(case_id)



save "MW_assets.dta", replace

use "HH_MOD_R.dta", clear
*check
bys case_id: egen social_prot = min(hh_r01)
collapse (min) social_prot, by(case_id)
recode social_prot (2=0)
save "MW_socialprot", replace


use "HH_MOD_U.dta", clear
*last 3 years
bys case_id: egen shock_any = min(hh_u01)
collapse (min) shock_any, by(case_id)
recode shock_any (2=0)
save "MW_shock", replace
****************************
*merge
use "HH_MOD_B", clear
unique case_id PID

merge m:1 case_id using "hh_mod_a_filt.dta", gen(merge_location)
merge 1:1 case_id  PID using "HH_MOD_C.dta", gen(merge_educ)
merge 1:1 case_id PID using "HH_MOD_D.dta", gen(merge_fd_health)
merge 1:1 case_id PID using  "HH_MOD_E.dta", gen(merge_employment)
merge m:1 case_id using "HH_MOD_F.dta", gen(merge_household)
merge m:1 case_id using "HH_MOD_H.dta", gen(merge_foodsec)
merge m:1 case_id using "MW_assets.dta", gen(merge_asset)
merge m:1 case_id using "MW_socialprot.dta", gen(merge_socialprot)
merge m:1 case_id  using "MW_shock.dta", gen(merge_shock)
merge m:1 case_id using "ihs5_consumption_aggregate.dta", gen(merge_expenditure) 

save "${PATH}\Malawi_LSMS_2019_NotClean.dta" , replace

*************************************


use "$PATH/Malawi_LSMS_2019_NotClean.dta", clear



gen country_name="Malawi"
gen country_abrev="MW"

clonevar hh_id = case_id
gen ind_id= hh_id + string(PID, "%02.0f")

gen country_dataset_year = 2019
clonevar admin1 = region
gen hh_weight = hh_wgt
gen ind_weight = hh_wgt
  
gen sample_strata = region
egen psu =group(ea_id)
  
  save "${PATH}\Malawi_LSMS_2019_NotClean_raw.dta" , replace

**************

gen female = 1 if hh_b03 == 2 
replace female = 0 if hh_b03 ==1
tab hh_b03 female, m

*age already in varname age
gen age = hh_b05a

*area of residence - 
fre  reside
gen urban_new = 1 if  reside  ==1 
replace urban_new  = 0 if reside   ==2

tab reside urban_new, m

label define URBAN 0 "Rural" 1 "Urban" 
label val urban_new URBAN

tab reside urban_new, m 




drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65

*functional difficulty
fre hh_d24-hh_d29

clonevar seeing_diff_new = hh_d24
clonevar hearing_diff_new = hh_d25
clonevar mobility_diff_new = hh_d26
clonevar cognitive_diff_new = hh_d27
clonevar selfcare_diff_new = hh_d28
clonevar comm_diff_new = hh_d29


fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new selfcare_diff_new

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new  comm_diff_new selfcare_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m

count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  
*~0



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



*everattended_new
gen everattended_new = 1 if hh_c06==1
replace everattended_new = 0 if hh_c06==2 
tab everattended_new hh_c06, m
 
*lit new any language
gen lit_new = (hh_c05_1==1 | hh_c05_3 ==1) 
replace lit_new = . if mi(hh_c05_1) & mi(hh_c05_3)

*hh_c05_1 -- Can [NAME] read a short text in any language?
*hh_c05_3 -- Can [NAME] write a short note in any language


fre hh_c13
*school_new
gen school_new=1 if hh_c13==1 
replace school_new=0 if hh_c13==2
replace school_new=0 if everattended_new==0  //those who never attended school coded as NOT IN SCHOOL
tab school_new, m
*edattain
/*
edattain_new= coded 0 for niu, 9 for unknown 
=1 for less than primary  completed
=2 for primary completed
=3 for secondary completed
=4 for university completed
*/
* 8 -4 -4 educ
gen edattain_new = 1 if everattended_new==0 | hh_c08<8 // 8 years primary
replace edattain_new = 2 if hh_c08>=8 & hh_c08<12 // 4 years secondary
replace edattain_new = 3 if hh_c08>=12 & 	hh_c08<=17 // complete secondary + some university
replace edattain_new = 3 if hh_c08>=20 & 	hh_c08<=22 //training college

replace edattain_new = 4 if hh_c08>=18 & 	hh_c08<=19 // university and higher 
replace edattain_new = 4 if hh_c08==23 //training college

tab hh_c08 edattain_new,m


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
*H07 How many hours in the last seven days did you spend on household agricultural activities (including livestock and fishing-related activities) whether for sale or for household food? 
*follow up question on whether only or mainly for sale, family use

*H08 How many hours in the last seven days did you run or do any kind of non-agricultural or non-fishing household business, big or small, for yourself?
*H09 How many hours in the last seven days did you help in any of the household's non-agricultural or non-fishing household businesses, if any?
*H10 How many hours in the last seven days did you engage in casual, part-time or ganyu labour?
*H11 How many hours in the last seven days did you do any work for a wage, salary, commission, or any payment in kind, excluding ganyu?
gen ind_emp = ( (hh_e07a>=1 & hh_e07a_1<=2) | hh_e08>=1 | hh_e09>=1 | hh_e10>=1 | hh_e11>=1 )
replace ind_emp = . if  mi(hh_e07a) & mi(hh_e08) & mi(hh_e09) & mi(hh_e10) & mi(hh_e11)

*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24


*work_manufacturing=1 if manufacturing =0 otherwise 
*Classification from basic info document
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if inrange(hh_e20b,31,39) & ind_emp==1
replace work_manufacturing=. if ind_emp==0


* women in managerial work
/*
Senior and middle management correspond to sub-major groups
*/
*included managers and supervisors, legislative officials, leaders
fre hh_e19b
gen work_managerial = 0 if female==1 // denominator - all women
replace work_managerial = (inlist(hh_e19b,20, 21, 22,40,50,60,70))  if ind_emp==1 & female==1
replace work_managerial = . if female==0 

*informal
*The numerator includes adults who are informal workers. 
*The denominator includes all adults age 15 and above.
*Informal workers include the self-employed, those who work for a microenterprise of five or fewer employees or in a firm that is unregistered, and those who have no written contract with their employers. Workers who produce goods for own and/or family consumption are included as informal workers. Additionally, family workers without pay are included as informal workers.
*However, unlike in SDG 8.3.1, we use all adults as a denominator as many individuals with disabilities are not employed (out of the labor force) and would otherwise not be captured in the denominator which would then be very small. 


gen work_informal = 0
replace work_informal = 1 if ( (hh_e07a>=1 & hh_e07a_1>2) | hh_e08>=1  | hh_e09>=1 | hh_e10>=1) //ag activities who produce mainly for family use, non-ag self employed, help business, casual labor



gen ind_phone = (hh_f31==1) if !mi(hh_f31)
gen cell_new = (hh_f34>0) & !mi(hh_f34)

gen mobile_own = (hh_b04a==1) if !mi(hh_b04a)

*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water
*update - done in google sheet

gen ind_water= (inlist(hh_f36, 1, 2, 3, 6, 7, 8, 9, 13, 15, 17)) if !mi(hh_f36)
tab hh_f36 ind_water, m

*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet
*update - done in google sheet
fre hh_f41 hh_f42
gen ind_toilet = ( inlist(hh_f41, 1, 2, 3, 6, 7, 9) ) if !mi(hh_f41)
replace ind_toilet = 1 if  ind_toilet ==1 & hh_f41_4==2 // NO, not shared
replace ind_toilet = 0 if hh_f41_4==1 //shared, regardless of facility
tab hh_f41 ind_toilet, m 

*ind_electric	=1 if yes =0 otherwise
fre hh_f19
gen ind_electric= (hh_f19==1) if !mi(hh_f19)
tab hh_f19 ind_electric ,m

*food insecure
*update
gen food_insecure =  (hh_h01 == 1 | hh_h04 ==1)  
replace food_insecure = . if mi(hh_h01) & mi(hh_h04)

*ind_cleanfuel (see description below of clean fuel)	=1 if good - NOT organic material =0 if bad - organic (dung, coal, etc)

gen ind_cleanfuel= (hh_f12==4 | hh_f12 ==5) if !mi(hh_f12)
tab hh_f12 ind_cleanfuel,m


gen ind_wall = (hh_f07 == 5 |  hh_f07 == 6) if !mi(hh_f07)
tab hh_f07 ind_wall, m 

gen ind_roof = (hh_f08==2 | hh_f08==3 | hh_f08==4) if !mi(hh_f08)
tab hh_f08 ind_roof, m

gen ind_floor = (hh_f09==3 | hh_f09==5) if !mi(hh_f09)
tab hh_f09 ind_floor, m



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


bys hh_id: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)


codebook rex*,c
su rexp_cat061 rexp_cat062 rexp_cat063
egen health_exp_annual =rowtotal (rexp_cat061 rexp_cat062 rexp_cat063)
gen health_exp_hh = health_exp_annual/ rexpagg

su health_exp_hh
*rexp_cat061 Health drugs, nominal annual consumption
*rexp_cat062 Health out-patient, nominal annual consumption
*rexp_cat063 Health hospitalization, nominal annual consumption



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


order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 		seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 	/*education*/	everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_f ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

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

save "${CLEAN}\Malawi_LSMS_2019_Clean.dta" , replace
