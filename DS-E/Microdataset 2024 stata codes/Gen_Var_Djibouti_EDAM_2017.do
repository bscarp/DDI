/*******************************************************************************
******************Djibouti EDAM 2017 *******************************************
********************************************************************************
Author: Jaclyn Yap
Reference: DSE
Website:
*******************************************************************************/
global PATH "C:\Users\Jaclyn Yap\Desktop\WB_2024\Djibouti\DJI_2017_EDAM_v01_M_v01_A_PUF_Stata15\"
global CLEAN "C:\Users\Jaclyn Yap\Desktop\WB_2024\Clean"
cd "$PATH"

*assets reshape
use "EDAM2017_Section_06_PUF.dta" , clear



local asset_number 5
local asset_name radio
fre q06_01 if code_article==`asset_number'
gen `asset_name' = (q06_01==1) if code_article==`asset_number' & !mi(code_article) 
bys id_men: egen ind_`asset_name' = min(`asset_name')


local asset_number 6
local asset_name tv
fre q06_01 if code_article==`asset_number'
gen `asset_name' = (q06_01==1) if code_article==`asset_number' & !mi(code_article) 
bys id_men: egen ind_`asset_name' = min(`asset_name')


local asset_number 30
local asset_name autos
fre q06_01 if code_article==`asset_number'
gen `asset_name' = (q06_01==1) if code_article==`asset_number' & !mi(code_article) 
bys id_men: egen ind_`asset_name' = min(`asset_name')


local asset_number 3
local asset_name computer
fre q06_01 if code_article==`asset_number'
gen `asset_name' = (q06_01==1) if code_article==`asset_number' & !mi(code_article) 
bys id_men: egen ind_`asset_name' = min(`asset_name')


local asset_number 11
local asset_name refrig
fre q06_01 if code_article==`asset_number'
gen `asset_name' = (q06_01==1) if code_article==`asset_number' & !mi(code_article) 
bys id_men: egen ind_`asset_name' = min(`asset_name')



local asset_number 32
local asset_name motorcycle
fre q06_01 if code_article==`asset_number'
gen `asset_name' = (q06_01==1) if code_article==`asset_number' & !mi(code_article) 
bys id_men: egen ind_`asset_name' = min(`asset_name')


local asset_number 33
local asset_name bike
fre q06_01 if code_article==`asset_number'
gen `asset_name' = (q06_01==1) if code_article==`asset_number' & !mi(code_article) 
bys id_men: egen ind_`asset_name' = min(`asset_name')


local asset_number 2
local asset_name phone
fre q06_01 if code_article==`asset_number'
gen `asset_name' = (q06_01==1) if code_article==`asset_number' & !mi(code_article) 
bys id_men: egen ind_`asset_name' = min(`asset_name')


local asset_number 1
local asset_name cell_new
fre q06_01 if code_article==`asset_number'
gen `asset_name'_1 = (q06_01==1) if code_article==`asset_number' & !mi(code_article) 
bys id_men: egen `asset_name' = min(`asset_name'_1)



collapse (min) ind_* cell_new, by(id_men)

save "DJ_assets", replace

use "EDAM2017_Section_10b_PUF.dta" , clear

bys id_men: egen shock_any = min(q10_10)
collapse (min) shock_any, by(id_men)
recode shock_any (2=0)

save "DJ_shocks", replace
******************
use "EDAM2017_Section_01-04_PUF.dta" ,clear


merge m:1 id_men using  "EDAM2017_Section_05_PUF.dta", gen(merge_housing)

merge m:1 id_men using  "EDAM2017_Section_10a_PUF.dta" , gen(merge_foodinsec)

merge m:1 id_men using "EDAM2017_Depenses_PUF.dta" , gen(merge_expenditures)


merge m:1 id_men using "DJ_assets", gen(merge_assets)
merge m:1 id_men using "DJ_shocks", gen(merge_shocks)

save "Djibouti_EDAM_2017_NotClean", replace

************************

use "Djibouti_EDAM_2017_NotClean", clear

gen country_name="Djibouti"
gen country_abrev="DJ"

gen hh_id =string(id_men, "%04.0f")
gen ind_id= hh_id + string(id_pers, "%02.0f")
gen country_dataset_year = 2017
clonevar admin1 = region
gen hh_weight = w1 
gen ind_weight = popwt1
gen sample_strata = strata 
gen psu = PSU  

  
gen female = 1 if q01_02 == 2 
replace female = 0 if q01_02 ==1
tab q01_02 female, m

*age 
gen age = q01_04_rec
recode age (99=.)
*60 - 60-64
*65 65-69
*70

*area of residence - 
fre  milieu
gen urban_new = 1 if  milieu  ==1 
replace urban_new  = 0 if milieu   ==2

tab milieu urban_new, m

label define URBAN 0 "Rural" 1 "Urban" 
label val urban_new URBAN

tab milieu urban_new, m 


drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65

*functional difficulty


clonevar seeing_diff_new = q03_21
clonevar hearing_diff_new = q03_22
clonevar mobility_diff_new = q03_23
clonevar cognitive_diff_new = q03_24
gen selfcare_diff_new = .
clonevar comm_diff_new = q03_25


fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new /* selfcare_diff_new*/

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new  comm_diff_new /* selfcare_diff_new*/)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m

count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  
*286


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

/*
gen selfcare_any = (selfcare_diff_new>=2) 
replace selfcare_any=. if selfcare_diff_new ==.
*/

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

/*
gen selfcare_some = (selfcare_diff_new==2) 
replace selfcare_some=. if selfcare_diff_new ==.
*/

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

/*
gen selfcare_atleast_alot = (selfcare_diff_new>=3) 
replace selfcare_atleast_alot=. if selfcare_diff_new ==.
*/

gen communicating_atleast_alot = (comm_diff_new>=3) 
replace communicating_atleast_alot=. if comm_diff_new ==.


*everattended_new
gen everattended_new = 1 if q02_03==1
replace everattended_new = 0 if q02_03==2 
tab everattended_new q02_03, m
 
*lit new any language
gen lit_new = (q02_01==1) if !mi(q02_01)
tab q02_01 lit_new,m

*5 4 3
gen edattain_new =1 if everattended_new==0 | (q02_05>=0 & q02_05<5) |q02_05==16 | q02_05==17
replace edattain_new = 2 if (q02_05>=5 & q02_05<13)
replace edattain_new = 3 if (q02_05>=13 & q02_05<=14)
replace edattain_new = 4 if q02_05==15
tab q02_05 edattain_new,m

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


gen school_new=1 if (q02_08==0|q02_08==1 )
replace school_new=0 if q02_08==2
replace school_new=0 if everattended_new==0  //those who never attended school coded as NOT IN SCHOOL
tab school_new, m

*employment

gen ind_emp = (q04_01==1) if !mi(q04_01) 
replace  ind_emp = inrange(q04_02,1,7) if !mi(q04_02)
replace ind_emp = . if  mi(q04_01) & mi(q04_02) 

*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24


*work_manufacturing=1 if manufacturing =0 otherwise 
*Classification from basic info document
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if (q04_15==4 | q04_15==5) & ind_emp==1
replace work_manufacturing=. if ind_emp==0



* women in managerial work
/*
Senior and middle management correspond to sub-major groups
*/
*included managers and supervisors, legislative officials, leaders
fre q04_08_rec
gen work_managerial = 0 if female==1 // denominator - all women
replace work_managerial = (q04_08_rec==1 | q04_08_rec==4)  if ind_emp==1 & female==1
replace work_managerial = . if female==0 



*informal
gen work_informal=0 
replace work_informal = 1 if q04_02==6
replace work_informal=1 if q04_09==3 | q04_09==10
replace work_informal=1 if q04_10 ==3
replace work_informal=1 if q04_11 ==2
replace work_informal = 1 if q04_13==2
replace work_informal = 1 if q04_14==3 | q04_14==4
replace work_informal = 1 if q04_17<4

tab work_informal,m

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if (ind_emp==. & work_managerial==.) 

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.

*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water

gen ind_water= (inlist(q05_21,1,2,3,4)) if !mi(q05_21)
tab q05_21 ind_water, m

gen toilet_new=cond(mi( q05_28),.,cond(inrange( q05_28,1,3) & q05_29==1,1,0))

*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet
gen ind_toilet = ( inlist(q05_28,1,2,3) ) if !mi(q05_28)
replace ind_toilet = 1 if  ind_toilet ==1 & q05_29==1 // Prive
replace ind_toilet = 0 if q05_29==2 //partage, regardless of facility
tab q05_28 ind_toilet, m 

*ind_electric	=1 if yes =0 otherwise
fre q05_13
gen ind_electric= (q05_13==1|q05_13==4) if !mi(q05_13)
tab q05_13 ind_electric ,m



*ind_cleanfuel (see description below of clean fuel)	=1 if good - NOT organic material =0 if bad - organic (dung, coal, etc)

gen ind_cleanfuel= (q05_10==1 | q05_10==3) if !mi(q05_10)
tab q05_10 ind_cleanfuel,m

gen ind_wall = (q05_02==1 | q05_02==3 | q05_02==6) if !mi(q05_02)
tab q05_02 ind_wall, m 

gen ind_roof = (q05_03==1 | q05_03==3 | q05_03==5 ) if !mi(q05_03)
tab q05_03 ind_roof, m

gen ind_floor = (q05_04==1 | q05_04==2) if !mi(q05_04)
tab q05_04  ind_floor, m




gen ind_livingcond = (ind_floor==1 & ind_roof==1 & ind_wall==1)
replace ind_livingcond = . if (ind_floor==. & ind_roof==. & ind_wall==.)

egen ind_asset_ownership =rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer)




gen food_insecure= (q10_01==1 | q10_04==1 | q10_06==1|q10_08==1)
replace food_insecure = . if mi(q10_01) & mi(q10_04) & mi(q10_06) & mi(q10_08)


bys hh_id: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)


codebook hhexp_health hhexp1
fre hhexp_health
gen health_exp_hh = hhexp_health/hhexp1
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


order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 		seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 	/*education*/	everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_f ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

save "${CLEAN}\Djibouti_EDAM_2017_Clean.dta" , replace

