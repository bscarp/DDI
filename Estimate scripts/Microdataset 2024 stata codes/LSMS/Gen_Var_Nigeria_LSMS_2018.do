/*
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/

Reference to appendix and paper:

For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).

Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478

Questions or comments can be sent to: disability_data_initiative@gmail.com

Author: Jaclyn Yap, Ph.D.

Suggested citation: Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478
*/

*source path*
global PATH " " 

*current directory*
global CLEAN " "

cd "$PATH"
use "${PATH}/sect10_assets.dta", clear 

local asset_number 322
local asset_name radio
fre s10q01 if asset_cd==`asset_number'
gen temp_`asset_name' = (s10q01==1) if  asset_cd==`asset_number'  & !mi(asset_cd) & !mi(s10q01) 
bys hhid: egen ind_`asset_name' = min(temp_`asset_name') 

local asset_number 327
local asset_name tv
fre s10q01 if asset_cd==`asset_number'
gen temp_`asset_name' = (s10q01==1) if  asset_cd==`asset_number'  & !mi(asset_cd) & !mi(s10q01) 
bys hhid: egen ind_`asset_name' = min(temp_`asset_name') 

local asset_number 319
local asset_name autos
fre s10q01 if asset_cd==`asset_number'
gen temp_`asset_name' = (s10q01==1) if  asset_cd==`asset_number'  & !mi(asset_cd) & !mi(s10q01) 
bys hhid: egen ind_`asset_name' = min(temp_`asset_name') 


local asset_number 312
local asset_name refrig
fre s10q01 if asset_cd==`asset_number'
gen temp_`asset_name' = (s10q01==1) if  asset_cd==`asset_number'  & !mi(asset_cd) & !mi(s10q01) 
bys hhid: egen ind_`asset_name' = min(temp_`asset_name') 

local asset_number 328
local asset_name computer
fre s10q01 if asset_cd==`asset_number'
gen temp_`asset_name' = (s10q01==1) if  asset_cd==`asset_number'  & !mi(asset_cd) & !mi(s10q01) 
bys hhid: egen ind_`asset_name' = min(temp_`asset_name') 

local asset_number 318
local asset_name motorcycle
fre s10q01 if asset_cd==`asset_number'
gen temp_`asset_name' = (s10q01==1) if  asset_cd==`asset_number'  & !mi(asset_cd) & !mi(s10q01) 
bys hhid: egen ind_`asset_name' = min(temp_`asset_name') 

local asset_number 317
local asset_name bike
fre s10q01 if asset_cd==`asset_number'
gen temp_`asset_name' = (s10q01==1) if  asset_cd==`asset_number'  & !mi(asset_cd) & !mi(s10q01) 
bys hhid: egen ind_`asset_name' = min(temp_`asset_name') 

gen ind_phone = .


gen temp_cell = (s10q01==1) & (asset_cd==3321 | asset_cd==3322) if !mi(asset_cd) & !mi(s10q01) & (asset_cd==3321 | asset_cd==3322)
bys hhid: egen cell_new = max(temp_cell)
replace cell_new = . if (asset_cd==3321 | asset_cd==3322) & mi(s10q01)


collapse (max) ind_* cell_new, by(hhid)
sort hhid
save "${PATH}/NG_assets.dta", replace

*******************************
* 				SHOCKS questions  
*******************************
use "sect16_shocks", clear 

** s16q01 -- Has your household been affected by [SHOCK] since [3 YEARS AGO]?
** 1: yes 2:no : 
bro hhid shock_cd s16q01
fre shock_cd
bys hhid: egen shock_any = min(s16q01) if !mi(s16q01)
recode shock_any (2=0)
collapse (min) shock_any, by(hhid)
sort hhid
* HH LEVEL DATA
save "NG_shocks.dta" , replace


use "sect8_food_security.dta", clear
/*
a.You, or any other adult in your household, were worried you would run out of food because of a lack of money or other resources?	

d. You, or any other adult in your household, had to skip a meal because there was not enough money or other resources to get food?	

e. You, or any other adult in your household, ate less than you thought you should because of a lack of money or other resources?

f. Your household ran out of food because of a lack of money or other resources?	

g. You, or any other adult in your household, were hungry but did not eat because there was not enough money or other resources for food?	
h. You, or any other adult in your household, went without eating for a whole day because of a lack of money or other resources?	

i. You, or any other adult in your household, restricted consumption in order for children to eat?	

j. You, or any other adult in your household, borrowed food, or relied on help from a friend or relative?
*/

fre event_cd
keep if inlist(event_cd, 1, 4, 5, 6, 7, 8, 9, 10)
bys hhid: egen food_insecure = min(s08q01) if !mi(s08q01)
recode food_insecure (2=0)
collapse (min) food_insecure, by(hhid)
sort hhid

save "food_security.dta", replace


***************


use "${PATH}/sect1_roster.dta", clear 
merge 1:1 hhid indiv using "sect2_education.dta", gen(merge_educ)
merge 1:1 hhid indiv using "sect4a1_labour.dta", gen(merge_labor1)
merge m:1 hhid  using "secta_cover.dta", gen(merge_surveydetails)
merge 1:1 hhid indiv using "sect3_health.dta", gen(merge_fd)
merge m:1 hhid using "sect14_housing.dta", gen(merge_housing) 
drop if merge_housing==2
merge m:1 hhid using "food_security.dta", gen(merge_foodinsec)
merge m:1 hhid using "sect12a_safety.dta", gen(merge_socialprot)
drop if merge_socialprot==2
merge m:1 hhid using "NG_shocks.dta", gen(merge_shocks)
merge m:1 hhid using "NG_assets.dta", gen(merge_assets)
drop if merge_assets==2
merge m:1 hhid using "totcons.dta", gen(merge_expenditures)
drop if merge_expenditures==2

save "$PATH/Nigeria_LSMS_2018_NotClean.dta", replace

**********************

use "$PATH/Nigeria_LSMS_2018_NotClean.dta", clear

gen country_name="Nigeria"
gen country_abrev="NG"

gen hh_id = string(hhid)
gen ind_id= hh_id + string(indiv, "%02.0f")

gen country_dataset_year = 2018

clonevar admin1 = state

clonevar admin_alt = zone
clonevar admin2 = lga

gen hh_weight = wt_final
gen ind_weight = wt_final

gen sample_strata= state
egen psu =group(ea)


save "$PATH/Nigeria_LSMS_2018_NotClean_raw.dta", replace



**************

gen female = 1 if s01q02 == 2 
replace female = 0 if s01q02 ==1
tab s01q02 female, m

*age 
gen age = s01q04a

*area of residence - 
fre  sector
gen urban_new = 1 if  sector  ==1 
replace urban_new  = 0 if sector   ==2

tab sector urban_new, m

label define URBAN 0 "Rural" 1 "Urban" 
label val urban_new URBAN

tab sector urban_new, m 




drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65


fre female


*functional difficulty

clonevar seeing_diff_new = s03q22
clonevar hearing_diff_new = s03q23
clonevar mobility_diff_new = s03q24
clonevar cognitive_diff_new = s03q25 
clonevar selfcare_diff_new = s03q26  
clonevar comm_diff_new = s03q27


fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new selfcare_diff_new 

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new  comm_diff_new selfcare_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m

count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  

tab func_difficulty female,m
drop if mi(female) &  missing_func_difficulty==1

tab func_difficulty missing_func_difficulty , m

count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  


fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new selfcare_diff_new

*logit missing_func_difficulty age female urban_new,or
*tab female missing_func_difficulty, m






*Disability levels for any domain 
gen disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

gen disability_none = (disability_any==0)
gen disability_nonesome = (disability_none==1|disability_some==1)

gen disability_alot=(func_difficulty==3)
	replace disability_alot=. if func_difficulty==.

	gen disability_unable=(func_difficulty==4)
	replace disability_unable=. if func_difficulty==.

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

local diffvars seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new

	foreach var of local diffvars {
    
    local rawdomain = subinstr("`var'", "_diff_new", "", .)

    local domain "`rawdomain'"
	if "`rawdomain'" == "mobility" local domain "mobile"
    if "`rawdomain'" == "cognitive" local domain "cognition"
    if "`rawdomain'" == "comm" local domain "communicating"
	
    gen `domain'_alot = (`var' == 3)
    replace `domain'_alot = . if `var' == .

    gen `domain'_unable = (`var' == 4)
    replace `domain'_unable = . if `var' == .

	}


*education

gen everattended_new = 1 if s02q05 ==1
replace everattended_new = 0 if s02q05 ==2 
tab everattended_new s02q05, m

gen lit_new = (s02q04==1) if !mi(s02q04)
replace lit_new = (s02q04b==1) if lit_new==. & !(s02q04b)
tab s02q04 lit_new,m

gen school_new=1 if s02q09==1 
replace school_new=0 if s02q09==2
replace school_new=0 if everattended_new==0  //those who never attended school coded as NOT IN SCHOOL
tab school_new, m


gen edattain_new = 1 if everattended_new ==0 | s02q07<=15 | s02q07 ==51 | s02q07==52
replace edattain_new = 2 if s02q07>=16 & s02q07<26
replace edattain_new = 3 if s02q07==26 | s02q07==27 | s02q07==28 | s02q07>=31 & s02q07<=35 |s02q07==61 |s02q07==321 | s02q07==322
replace edattain_new = 4 if s02q07==41 | s02q07==43 | s02q07>=411 & s02q07<.
tab s02q07 edattain_new,m


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
codebook s04aq04-s04aq12,c
gen ind_emp = ((s04aq04 ==1 & s04aq05>=1 & s04aq05<. ) | (s04aq06==1 & s04aq07>=1 & (s04aq08==1| s04aq08==2) ) | (s04aq09==1 & s04aq10>=1) | ((s04aq11==1 | s04aq11==2) & s04aq12>=1))
replace ind_emp = . if mi(s04aq04) & mi(s04aq06) & mi(s04aq09) & mi(s04aq11)

*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24


*work_manufacturing=1 if manufacturing =0 otherwise 
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if s04aq29==3 & ind_emp==1
replace work_manufacturing=. if ind_emp==0


* women in managerial work
/*
Senior and middle management correspond to sub-major groups
*/
*included managers and supervisors, legislative officials, leaders
fre s04aq28b
gen work_managerial = 0 if female==1 // denominator - all women
replace work_managerial = (s04aq28b>= 1110 & s04aq28b<= 1318)  if ind_emp==1 & female==1
replace work_managerial = . if female==0 

*informal
*The numerator includes adults who are informal workers. 
*The denominator includes all adults age 15 and above.
*Informal workers include the self-employed, those who work for a microenterprise of five or fewer employees or in a firm that is unregistered, and those who have no written contract with their employers. Workers who produce goods for own and/or family consumption are included as informal workers. Additionally, family workers without pay are included as informal workers.
*However, unlike in SDG 8.3.1, we use all adults as a denominator as many individuals with disabilities are not employed (out of the labor force) and would otherwise not be captured in the denominator which would then be very small. 


gen work_informal = 0
replace work_informal = 1 if ((s04aq06==1 & s04aq07>=1 & s04aq08>=3) | (s04aq09==1 & s04aq10>=1)| (s04aq11==2 & s04aq12>=1)) //ag activities, self employed/ work for hh member /informal apprenticeship

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

*social_prot
*s14q1b -- IS THERE ANY YES RESPONSE IN Q1?
*14. q1: Has HH received any assistance from any institution in form of?:cash assistance, food assistance, other in-kind assistance, scholarship?
gen social_prot = (s12q01a == 1) if !mi(s12q01a)
** END HERE

*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water
*source during rainy season
gen ind_water= (inlist(s14q27,1,2,3,4,5,6,8,10,14,15,16)) if !mi(s14q27)
tab s14q27 ind_water, m

fre s14q32 //different source during dry season? 18% said yes
gen cleanwater_dry =  (inlist(s14q32,1,2,3,4,5,6,8,10,14,15,16)) if !mi(s14q31)
tab s14q32 cleanwater_dry,m

*only those with clean water in rainy and dry season (among those who said they have a different source during dry season) are ==1
replace ind_water=(ind_water==1 & cleanwater_dry==1) if s14q31==1


*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet
fre s14q40 
gen ind_toilet = ( inlist(s14q40, 1,2,3,6,7,9) ) if !mi(s14q40)
replace ind_toilet =0 if s14q45>=1 & s14q45<. //shared
*(10,380 real changes made)
tab s14q40 ind_toilet, m 


*ind_electric	=1 if yes =0 otherwise
fre s14q19
gen ind_electric=(s14q19==1) if !mi(s14q19)
tab s14q19 ind_electric ,m


*ind_cleanfuel (see description below of clean fuel)	=1 if good - NOT organic material =0 if bad - organic (dung, coal, etc)

gen ind_cleanfuel= (s14q13==5 |s14q13==7) if !mi(s14q13)
replace ind_cleanfuel=. if s14q13==0 | s14q13==98 //does not cook
tab s14q13 ind_cleanfuel,m

fre s14q09 s14q10 s14q11 

gen ind_wall = (s14q09 == 4 |  s14q09== 5) if !mi(s14q09)
tab s14q09 ind_wall, m 

gen ind_roof = (inlist(s14q10, 2, 3, 4, 8 , 9)) if !mi(s14q10)
tab s14q10 ind_roof, m

gen ind_floor = (s14q11==3 | s14q11==5) if !mi(s14q11)
tab s14q11 ind_floor, m



gen ind_livingcond = (ind_floor==1 & ind_roof==1 & ind_wall==1)
replace ind_livingcond = . if (ind_floor==. & ind_roof==. & ind_wall==.)

egen ind_asset_ownership =rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer)

gen alone=(hhsize==1)


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

*old			qui egen disability_status_hh=max(disability_status) if age_new>=15 & age_new<., by(serial)

bys hhid: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)
gen disability_none_hh = (disability_any_hh==0)

	gen disability_nonesome_hh = (disability_none_hh==1|disability_some_hh==1)
	
	gen disability_alot_hh=(func_difficulty_hh==3)
	replace disability_alot_hh=. if func_difficulty_hh==.
	
	gen disability_unable_hh=(func_difficulty_hh==4)
	replace disability_unable_hh=. if func_difficulty_hh==.

*health expenditures
gen health_expense = health31 + health32
gen tot_exp =  food_purch1+ food_purch2+ food_purch3+ food_purch4+ food_purch5+ food_purch6+ food_purch7+ food_purch8+ food_purch9+ food_purch10+ food_purch11+ food_purch12+ food_purch13+ food_purch14+ food_purch15+ food_purch16+ food_purch17+ food_purch18+ food_purch19+ food_meals20+ nonfood21+ nonfood22+ nonfood23+ nonfood24+ nonfood25+ nonfood26+ nonfood27+ nonfood28+ edu29+ edu30+ health31+ health32+ rent33 //food purchases only, excluded own food production

gen health_exp_hh = health_expense / tot_exp

su health_exp_hh
*totcons_pc
*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin3 admin_alt ind_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome disability_alot disability_unable seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot seeing_alot hearing_alot mobile_alot cognition_alot selfcare_alot communicating_alot seeing_unable hearing_unable mobile_unable cognition_unable selfcare_unable communicating_unable everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary computer internet mobile_own ind_emp youth_idle work_manufacturing work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m bmi overweight_obese child_died healthcare_prob death_hh alone ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_none_hh disability_nonesome_hh disability_any_hh disability_some_hh disability_atleast_hh disability_alot_hh disability_unable_hh"

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
 
lab var country_name "Country name"
lab var country_abrev "Country abbreviation"
lab var country_dataset_year "Country Data and year"
lab var ind_id "Individual ID"
lab var hh_id "Household ID"
lab var admin1 "Admin 1 level"
lab var admin2 "Admin 2 level"
lab var admin3 "Admin 3 level"
lab var admin_alt "alternative admin"
lab var ind_weight "Individaul Sample weight"
lab var hh_weight "Household Sample weight"
lab var dv_weight "DHS Domestic Violence sample weight"
lab var sample_strata "Strata weight"
lab var psu "Primary sampling unit"
lab var female "Female or Male"
lab var urban_new "Urban or Rural"
lab var age "Age"
lab var age_group "Age group"
lab var seeing_diff_new "Difficulty in seeing"
lab var hearing_diff_new "Difficulty in hearing"
lab var mobility_diff_new "Difficulty in walking"
lab var cognitive_diff_new "Difficulty in cognitive"
lab var selfcare_diff_new "Difficulty in selfcare"
lab var comm_diff_new "Difficulty in communication"
lab var func_difficulty "Functional difficulty"
lab var disability_any "Any Difficulty"
lab var disability_some "Some Difficulty"
lab var disability_atleast "At least a lot of difficulty"
lab var disability_alot "Alot Difficulty"
lab var disability_unable "Unable"
lab var seeing_any "Any Difficulty in seeing"
lab var hearing_any "Any Difficulty in hearing"
lab var mobile_any "Any Difficulty in walking"
lab var cognition_any "Any Difficulty in cognition"
lab var selfcare_any "Any Difficulty in selfcare"
lab var communicating_any "Any Difficulty in communicating"
lab var seeing_some "Some Difficulty in seeing"
lab var hearing_some "Some Difficulty in hearing"
lab var mobile_some "Some Difficulty in walking"
lab var cognition_some "Some Difficulty in cognition"
lab var selfcare_some "Some Difficulty in selfcare"
lab var communicating_some "Some Difficulty in communicating"
lab var seeing_atleast_alot "At least a lot Difficulty in seeing"
lab var hearing_atleast_alot "At least a lot Difficulty in hearing"
lab var mobile_atleast_alot "At least a lot Difficulty in walking"
lab var cognition_atleast_alot "At least a lot Difficulty in cognition"
lab var selfcare_atleast_alot "At least a lot Difficulty in selfcare"
lab var communicating_atleast_alot "At least a lot Difficulty in communicating"
lab var seeing_alot "Some Difficulty in seeing"
lab var hearing_alot "Some Difficulty in hearing"
lab var mobile_alot "Some Difficulty in walking"
lab var cognition_alot "Some Difficulty in cognition"
lab var selfcare_alot "Some Difficulty in selfcare"
lab var communicating_alot "Some Difficulty in communicating"
lab var seeing_unable "Some Difficulty in seeing"
lab var hearing_unable "Some Difficulty in hearing"
lab var mobile_unable "Some Difficulty in walking"
lab var cognition_unable "Some Difficulty in cognition"
lab var selfcare_unable "Some Difficulty in selfcare"
lab var communicating_unable "Some Difficulty in communicating"
lab var func_difficulty_hh "Max Difficulty in HH"
lab var disability_any_hh "P3 Any difficulty in Any Domain for any adult in the hh"
lab var disability_some_hh "P3 Some difficulty in Any Domain for any adult in the hh"
lab var disability_atleast_hh "P3 At least a lot of difficulty in Any Domain for any adult in the hh"
lab var disability_alot_hh "Alot Difficulty in the hh"
lab var disability_unable_hh "Unable in the hh"
lab var edattain_new "1 Less than Prim 2 Prim 3 Sec 4 Higher"
lab var everattended_new "Ever attended school"
lab var ind_atleastprimary "Primary school completion or higher adults 25+"
lab var ind_atleastprimary_all "Primary school completion or higher adults 15+"
lab var ind_atleastsecondary "Upper secondary school completion or higher adults 25+"
lab var lit_new "Literacy"
lab var school_new "Currently attending school"
lab var computer "Individual uses computer"
lab var internet "Individual uses internet"
lab var mobile_own "Adult owns mobile phone"
lab var ind_emp "Employed"
lab var youth_idle "Youth is idle"
lab var work_manufacturing "In manufacturing"
lab var work_managerial2 "Women in managerial position"
lab var work_informal2 "Informal work"
lab var ind_water "Safely managed water source"
lab var ind_toilet "Safely managed sanitation"
lab var fp_demsat_mod "H3_Family_planning"
lab var anyviolence_byh_12m "Experienced any violence last 12 months"
lab var bmi "Body Mass Index"
lab var overweight_obese "Overweight or Obese"
lab var child_died "Women who reported having child died"
lab var healthcare_prob "Women having atleast one problem in accessing healthcare"
lab var death_hh "Recent death in past 12 months"
lab var alone "Living alone"
lab var ind_electric "Electricity"
lab var ind_cleanfuel "Clean cooking fuel"
lab var ind_floor "Floor quality"
lab var ind_wall "Wall quality"
lab var ind_roof "Roof quality"
lab var ind_livingcond "Adequate housing"
lab var ind_radio "Household has radio"
lab var ind_tv "Household has television"
lab var ind_refrig "Household has refrigerator"
lab var ind_bike "Household has bike"
lab var ind_motorcycle "Household has motorcycle"
lab var ind_phone "Household has telephone"
lab var ind_computer "Household has computer"
lab var ind_autos "Household has automobile"
lab var cell_new "Household has mobile"
lab var ind_asset_ownership "Share of Assets"
lab var cell_new "Individual in household with cell phone"
lab var health_insurance "Adults with a health insurance coverage"
lab var social_prot "Household received any transfer or social protection"
lab var food_insecure "Household respondent said they worried about not having enough food in the past week OR experienced not having enough food sometime in the past year"
lab var shock_any "Household respondent said they experienced any negative shock based on a list of shocks"
lab var health_exp_hh "Proportion of health expenditures of the household relative to total expenditures (food and non-food)."
lab var deprive_educ "Deprived if less than primary school completion"
lab var deprive_health_water "Deprived in water"
lab var deprive_health_sanitation "Deprived in terms of sanitation"
lab var deprive_work "Deprived in work"
lab var deprive_sl_electricity "Deprived for electricity"
lab var deprive_sl_fuel "Deprived in terms of clean fuel"
lab var deprive_sl_housing "Deprived in terms housing binary"
lab var deprive_sl_asset "Deprived in terms of assets ownership"
lab var mdp_score "Multidimensional poverty Score"
lab var ind_mdp "M1_Multidemensional Poverty status"

 
keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin3 admin_alt ind_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome disability_alot disability_unable seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot seeing_alot hearing_alot mobile_alot cognition_alot selfcare_alot communicating_alot seeing_unable hearing_unable mobile_unable cognition_unable selfcare_unable communicating_unable everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary computer internet mobile_own ind_emp youth_idle work_manufacturing work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m bmi overweight_obese child_died healthcare_prob death_hh alone ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_none_hh disability_nonesome_hh disability_any_hh disability_some_hh disability_atleast_hh disability_alot_hh disability_unable_hh 

order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin3 admin_alt ind_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome disability_alot disability_unable seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot seeing_alot hearing_alot mobile_alot cognition_alot selfcare_alot communicating_alot seeing_unable hearing_unable mobile_unable cognition_unable selfcare_unable communicating_unable everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary computer internet mobile_own ind_emp youth_idle work_manufacturing work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m bmi overweight_obese child_died healthcare_prob death_hh alone ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_none_hh disability_nonesome_hh disability_any_hh disability_some_hh disability_atleast_hh disability_alot_hh disability_unable_hh

label define state_id 1 "Abia" 2 "Adamawa" 3 "Akwa Ibom" 4 "Anambra" 5 "Bauchi" 6 "Bayelsa" 7 "Benue" 8 "Borno" 9 "Cross River" 10 "Delta" 11 "Ebonyi" 12 "Edo" 13 "Ekiti" 14 "Enugu" 15 "Gombe" 16 "Imo" 17 "Jigawa" 18 "Kaduna" 19 "Kano" 20 "Katsina" 21 "Kebbi" 22 "Kogi" 23 "Kwara" 24 "Lagos" 25 "Nasarawa" 26 "Niger" 27 "Ogun" 28 "Ondo" 29 "Osun" 30 "Oyo" 31 "Plateau" 32 "Rivers" 33 "Sokoto" 34 "Taraba" 35 "Yobe" 36 "Zamfara" 37 "Abuja Federal Capital Territory", replace

compress



label define zone_id 1 "North Central" 2 "North East" 3 "North West" 4 "South East" 5 "South South" 6 "South West", modify

save "D:\DDI\New Indicator\Nigeria_LSMS_2018_clean.dta",replace
duplicates drop hh_id, force
save "D:\DDI\New Indicator\NG_HH.dta",replace

save "${CLEAN}\Nigeria_LSMS_2018_Clean.dta" , replace
