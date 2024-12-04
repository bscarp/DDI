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


*reshape asset
use "sect11_hh_w4.dta", clear

local asset_number 8
local asset_name radio

gen `asset_name' = (s11q00==1) & asset_cd==`asset_number' if !mi(s11q00)
bys household_id: egen ind_`asset_name' = sum(`asset_name')

local asset_number 7
local asset_name phone

gen `asset_name' = (s11q00==1) & asset_cd==`asset_number' if !mi(s11q00)
bys household_id: egen ind_`asset_name' = sum(`asset_name')

local asset_number 9
local asset_name tv

gen `asset_name' = (s11q00==1) & asset_cd==`asset_number' if !mi(s11q00)
bys household_id: egen ind_`asset_name' = sum(`asset_name')

local asset_number 13
local asset_name bike

gen `asset_name' = (s11q00==1) & asset_cd==`asset_number' if !mi(s11q00)
bys household_id: egen ind_`asset_name' = sum(`asset_name')


local asset_number 14
local asset_name motorcycle

gen `asset_name' = (s11q00==1) & asset_cd==`asset_number' if !mi(s11q00)
bys household_id: egen ind_`asset_name' = sum(`asset_name')

local asset_number 21
local asset_name refrig

gen `asset_name' = (s11q00==1) & asset_cd==`asset_number' if !mi(s11q00)
bys household_id: egen ind_`asset_name' = sum(`asset_name')

local asset_number 22
local asset_name autos

gen `asset_name' = (s11q00==1) & asset_cd==`asset_number' if !mi(s11q00)
bys household_id: egen ind_`asset_name' = sum(`asset_name')

collapse (min) ind_*, by(household_id)

gen ind_computer = .

save "ET_assets.dta", replace



*reshape socialprot
use "sect14_hh_w4.dta", clear
bys household_id: egen social_prot = min(s14q01)
collapse (min) social_prot, by(household_id)
recode social_prot (2=0)
save "ET_socialprot.dta", replace


use "sect9_hh_w4.dta", clear
bys household_id: egen shock_any = min(s9q01)
collapse (min) shock_any, by(household_id)
recode shock_any (2=0)
save "ET_shocks.dta", replace



*********************
use "sect1_hh_w4.dta", clear

merge 1:1 household_id  individual_id using "sect2_hh_w4.dta", gen(merge_educ)
merge 1:1 household_id  individual_id using "sect3_hh_w4.dta", gen(merge_health_fd)
merge 1:1 household_id  individual_id using "sect4_hh_w4.dta", gen(merge_emp)
merge m:1 household_id using "sect8_hh_w4.dta", gen(merge_foodinsec)
merge m:1 household_id  using "ET_shocks", gen(merge_shock)
merge m:1 household_id   using "sect10a_hh_w4.dta", gen(merge_housing)
merge m:1 household_id   using "ET_assets.dta", gen(merge_asset)
merge 1:1 household_id  individual_id  using "sect11b1_hh_w4.dta", gen(merge_mobilephone) //administered only to 18 and over
merge m:1 household_id   using "ET_socialprot.dta", gen(merge_socialprot)

save "Ethiopia_LSMS_2018_NotClean.dta", replace
****************

use "Ethiopia_LSMS_2018_NotClean.dta", clear
gen country_name="Ethiopia"
gen country_abrev="ET"

clonevar hh_id = household_id
gen ind_id= hh_id + string(individual_id, "%02.0f")


gen country_dataset_year = 2018
clonevar admin1 = saq01
gen admin2 = string(saq01, "%02.0f")+saq02
gen hh_weight = pw_w4
gen ind_weight = pw_w4

gen 	sample_strata = saq01
egen psu =group(ea_id)
  
**************

gen female = 1 if s1q02  == 2 
replace female = 0 if s1q02  ==1
tab s1q02  female, m

*age already in varname age
gen int age = s1q03a

*area of residence - 
fre  saq14
gen urban_new = 1 if  saq14  ==2
replace urban_new  = 0 if saq14   ==1

tab saq14 urban_new, m

label define URBAN 0 "Rural" 1 "Urban" 
label val urban_new URBAN

tab saq14 urban_new, m 



drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65

*functional difficulty

clonevar seeing_diff_new = s3q21
clonevar hearing_diff_new = s3q22
clonevar mobility_diff_new = s3q23
clonevar cognitive_diff_new = s3q24
clonevar selfcare_diff_new = s3q25
clonevar comm_diff_new = s3q26


fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new selfcare_diff_new

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new  comm_diff_new selfcare_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m

count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  
*3.4%




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
gen everattended_new = (s2q04==1) if !mi(s2q04)
tab everattended_new s2q04, m
 
*lit new any language
gen lit_new = (s2q03==1) if !mi(s2q03)
tab s2q03 lit_new,m

*school_new
fre s2q07
gen school_new=1 if s2q07==1 
replace school_new=0 if s2q07==2
replace school_new=0 if everattended_new==0  //those who never attended school coded as NOT IN SCHOOL
tab s2q07 school_new, m

fre s2q06

*edattain
/*
edattain_new= coded 0 for niu, 9 for unknown 
=1 for less than primary  completed
=2 for primary completed
=3 for secondary completed
=4 for university completed
*/

gen edattain_new = 1 if everattended_new==0 | s2q06 <8 | s2q06 ==93 | s2q06 ==98
replace edattain_new = 2 if s2q06 == 8 | s2q06>=9 & s2q06<12 | (s2q06>=21 & s2q06<=23) | s2q06== 25 | s2q06==26 | s2q06==28 | s2q06==29 | (s2q06>=94 & s2q06<=96 )
replace edattain_new = 3 if s2q06==12 | s2q06>=13 & s2q06 <=18   | s2q06== 24   |  s2q06== 27 | (s2q06>=30 & s2q06<=33) 
replace edattain_new = 4 if s2q06==19 | s2q06==20 | s2q06 ==34 | s2q06==35
replace edattain_new =. if s2q06 ==99
tab s2q06 edattain_new,m



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

*work in ag | own business | part time/casual |wage
gen ind_emp = ( (s4q05==1 & s4q06>=1 & s4q07<=2) | (s4q08==1 & s4q09>=1) | (s4q10==1 & s4q11>=1 ) | (s4q12==1 & s4q13>=1 & s4q13<.) )
replace ind_emp = . if  mi(s4q05) & mi(s4q08) & mi(s4q10) & mi(s4q12) 



*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24

fre s4q34d

*work_manufacturing=1 if manufacturing =0 otherwise 
*Classification from basic info document
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if s4q34d==4 & ind_emp==1
replace work_manufacturing=. if ind_emp==0


* women in managerial work
/*
Senior and middle management correspond to sub-major groups
*/
*included managers and supervisors, legislative officials, leaders
fre s4q34b
gen work_managerial = 0 if female==1 // denominator - all women
replace work_managerial =(s4q34b ==1) if ind_emp==1 & female==1
replace work_managerial = . if female==0 

*informal
*The numerator includes adults who are informal workers. 
*The denominator includes all adults age 15 and above.
*Informal workers include the self-employed, those who work for a microenterprise of five or fewer employees or in a firm that is unregistered, and those who have no written contract with their employers. Workers who produce goods for own and/or family consumption are included as informal workers. Additionally, family workers without pay are included as informal workers.
*However, unlike in SDG 8.3.1, we use all adults as a denominator as many individuals with disabilities are not employed (out of the labor force) and would otherwise not be captured in the denominator which would then be very small. 


gen work_informal = 0
replace work_informal = 1 if ((s4q05==1 & s4q06>=1 & s4q07>=3) | (s4q08==1 & s4q09>=1) | (s4q10==1 & s4q11>=1 ) ) //ag activities, non-ag self employed, help business, casual labor

gen cell_new = (s10aq41==1) if !mi(s10aq41)

gen mobile_own = (s11b_ind_01==1) if !mi(s11b_ind_01) // info only among 18 and older. also question is own or co-ownership

/*
19.
What type of Health insurance does
[NAME] currently covered under (such
as through an employer, community
health insurance scheme, or private
health insurance)?
Community Based health
Insurance... 1
Private health Insurance
(from financial
institutions).......2
Employer Health ....3
Don't have health
insurance...........4
*/

fre s3q19
gen health_insurance = (s3q19<4) if !mi(s3q19)
tab s3q19 health_insurance,m


*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water
*source of drinkingwater during rainy season
gen ind_water= (inlist(s10aq21, 1, 2, 3, 4, 5, 6, 8, 10, 11, 12, 14)) if !mi( s10aq21)
tab s10aq21 ind_water, m

fre s10aq26 //different source during dry season? 18% said yes
gen cleanwater_dry = inlist(s10aq27, 1, 2, 3, 4, 5, 6, 8, 10, 11, 12, 14) if s10aq26==1
tab s10aq27 cleanwater_dry

*only those with clean water in rainy and dry season (among those who said they have a different source during dry season) are ==1
replace ind_water=(ind_water==1 & cleanwater_dry==1) if s10aq26==1
*(521 real changes made) 


*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet
tab s10aq12 s10aq15,m
gen ind_toilet = ( inlist(s10aq12, 1, 2, 3, 6, 9, 11, 13) ) if !mi(s10aq12)
replace ind_toilet = 1 if  ind_toilet ==1 &  s10aq15==2 // shared? no
replace ind_toilet = 0 if  s10aq15==1 //shared, regardless of facility 11% missing
tab  s10aq15 ind_toilet, m 

*ind_electric	=1 if yes =0 otherwise
gen ind_electric= (s10aq34==1|s10aq34==2|s10aq34==4) if !mi(s10aq34)
tab s10aq34 ind_electric ,m

*In the last 12 months, have you been faced with a situation when you did not have enough food to feed the household?

gen food_insecure =  (s8q01==1 | s8q06 ==1)  
replace food_insecure = . if mi(s8q06) & mi(s8q01)
replace food_insecure = 1 if (s8q02h>0)

*ind_cleanfuel (see description below of clean fuel)	=1 if good - NOT organic material =0 if bad - organic (dung, coal, etc)

gen ind_cleanfuel= (inlist(s10aq38, 8, 9, 10, 11)) if !mi(s10aq38)
replace  ind_cleanfuel= . if s10aq38==12 //None
tab s10aq38 ind_cleanfuel,m

fre s10aq07
gen ind_wall = (inlist(s10aq07,6,7,8,9, 11)) if !mi(s10aq07)
tab s10aq07 ind_wall, m 

fre s10aq08 
gen ind_roof = (s10aq08==1 | s10aq08== 2| s10aq08== 8) if !mi(s10aq08)
tab s10aq08 ind_roof, m

fre s10aq09
gen ind_floor = (inlist(s10aq09, 4, 5, 6, 7, 8, 9)) if !mi(s10aq09)
tab s10aq09 ind_floor, m



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

*old			qui egen disability_status_hh=max(disability_status) if age_new>=15 & age_new<., by(serial)

bys hh_id: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)



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

save "${CLEAN}\Ethiopia_LSMS_2018_Clean.dta" , replace


