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

use "$PATH\GMB_2018_LFS_v01_M_STATA\GMB_2018_LFS_v01_M_STATA\LFS_Final.dta", clear


save "Gambia_LFS_2018_NotClean.dta"
************

use "Gambia_LFS_2018_NotClean.dta", clear

desc
*geographical var

gen country_name="Gambia"
gen country_abrev="GM"

gen hh_id= string(hh8, "%1.0f") + string(hh1, "%03.0f") + string(hh2, "%02.0f") 
gen ind_id= string(hh8, "%1.0f") + string(hh1, "%03.0f") + string(hh2, "%02.0f") + string(hl1, "%03.0f")

bys ind_id: gen dup_ind = (_N>1) 
bys ind_id: gen dup_ind1 = (_n>1) 
tab dup_ind

drop if hl1==.
tab dup_ind
drop dup_ind dup_ind1
 
gen country_dataset_year = 2018
clonevar ind_weight = weight
clonevar hh_weight = weight
clonevar admin1 = hh8
clonevar sample_strata = stratum
gen psu = hh1


gen female = 1 if hl4==2
replace female = 0 if hl4 ==1


*area of residence
gen urban_new = 1 if hh7==1
replace urban_new = 0 if hh7==2

label define URBAN 0 "Rural" 1 "Urban"
label val urban_new URBAN

tab hh7 urban_new, m 

clonevar age = hl6
tab age
drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65

fre fn3-fn8


clonevar seeing_diff_new = fn3
clonevar hearing_diff_new = fn4
clonevar mobility_diff_new = fn5
clonevar cognitive_diff_new = fn6
clonevar selfcare_diff_new = fn7
clonevar comm_diff_new = fn8

recode seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new (8=.)

fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new



egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m


*each func diff var has 6.63% missing

*overall
count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  
*2084 ~ 6.63% missing

*missing data analysis
*logit missing_func_difficulty age female urban_new, or //does not converge
*logistic missing_func_difficulty age female urban_new // does not converge
reg missing_func_difficulty age female urban_new



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

fre ed4
*everattended_new
gen everattended_new = 1 if ed4==1
replace everattended_new = 0 if ed4==2 
replace everattended_new =. if ed4==8
tab everattended_new ed4, m

fre ed6 ed7* ed8_level


/*
edattain_new= coded 0 for niu, 9 for unknown 
=1 for less than primary  completed
=2 for primary completed
=3 for secondary completed
=4 for university completed
*/

gen edattain_new = .
replace edattain_new = . if ed4==8 | ed6==8
replace edattain_new = 1 if ed4==2 // never attended school
replace edattain_new = 1  if ed4==1 & ed6==1 & inlist(ed7_level,0,1) //ever attended and is in school & grade level is ECE or primary - this is done for simplicity and easier to understand
replace edattain_new = 2  if ed4==1 & ed6==1 & inlist(ed7_level,2,3,4) //ever attended and is in school & lower, upper secondary, vocational 
replace edattain_new = 3  if ed4==1 & ed6==1 & ed7_level==5 //diploma
replace edattain_new = 4 if ed4==1 & ed6==1 & ed7_level==6 //higher
replace edattain_new = . if ed4==1 & ed6==1 & ed7_level==98 

replace edattain_new = 1 if ed4==1 & ed6==2 & ed8_level==0
replace edattain_new = 1 if ed4==1 & ed6==2 & (ed8_level==1 & ed8_grade<6)
replace edattain_new = 2 if ed4==1 & ed6==2 & (ed8_level==1 & ed8_grade==6)
replace edattain_new = . if ed4==1 & ed6==2 & (ed8_level==1 & ed8_grade==6)

replace edattain_new = 2 if ed4==1 & ed6==2 & ed8_level==2
replace edattain_new = 2 if ed4==1 & ed6==2 & ed8_level==3 & (ed8_grade <3 | ed8_grade >3) //assume that they are repeated grades? it's hard to make sense if numbers are beyond year 3
replace edattain_new = 3 if ed4==1 & ed6==2 & ed8_level==3 & ed8_grade ==3
replace edattain_new = 3 if ed4==1 & ed6==2 & (ed8_level==4 | ed8_level==5) //assume vocational and diploma are secondary completed - number is small
replace edattain_new = 4 if ed4==1 & ed6==2 & ed8_level==6
replace edattain_new = . if ed8_level==98

tab edattain_new

*school_new=0 if currently not in school =1 if currently in school
gen school_new=ed6
recode school_new (2=0) (8=.)
replace school_new =0 if everattended_new == 0
tab ed6 school_new


gen ind_atleastprimary = (edattain_new>=2)
replace ind_atleastprimary =. if edattain_new==.
replace ind_atleastprimary =. if age<25

gen ind_atleastprimary_all = (edattain_new>=2)
replace ind_atleastprimary_all =. if edattain_new==.


gen ind_atleastsecondary = (edattain_new>=3)
replace ind_atleastsecondary =. if edattain_new==.
replace ind_atleastsecondary =. if age<25

tab edattain_new ind_atleastprimary,m
tab edattain_new  ind_atleastsecondary, m

*literacy
gen lit_new =  cond(mi(ed9)|ed9== 8 ,., cond(ed9==1,1,0))
tab ed9 lit_new,m


*internet	=1 =0
gen internet=.

*epr
fre emp5
gen ind_emp = 1 if inrange(emp5,1,6) 
replace ind_emp = 0 if  emp5==7
replace ind_emp = . if mi(emp5)


*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24


*work_manufacturing=1 if manufacturing =0 otherwise 
*according to Gambia LFS 2018 report (page 9), economic activities is based on International Standard Industrial Classification ISIC Rev 4 for industry. C= Manufacturing
*emp16 codes =C  manufacturing as per the ISIC classifiction
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if emp16=="C" & ind_emp==1
replace work_manufacturing=. if ind_emp==0


* women in mangerial work
gen work_managerial = 0 if female==1 // denominator - all women
replace work_managerial = emp14a if ind_emp==1 & female==1 // emp14a is only ==1 and missing otherwise
replace work_managerial = . if female==0

*informal
*The numerator includes adults who are informal workers. 
*The denominator includes all adults age 15 and above.
*Informal workers include the self-employed, those who work for a microenterprise of five or fewer employees or in a firm that is unregistered, and those who have no written contract with their employers. Workers who produce goods for own and/or family consumption are included as informal workers. Additionally, family workers without pay are included as informal workers.
*However, unlike in SDG 8.3.1, we use all adults as a denominator as many individuals with disabilities are not employed (out of the labor force) and would otherwise not be captured in the denominator which would then be very small. 
gen work_informal = 0
replace work_informal = 1 if emp5 ==5 | emp5 ==6 //unpaid workers, unpaid farmers, also includes those who produce for own consumption (emp12)
replace work_informal = 1 if  eb11==2 // Oral work contract
replace work_informal = 1 if emp17 == 4 // self employed without employees
replace work_informal = 1 if sb6==1 | sb6==2 | sb6 ==3 //employees working in business includes just self, self and unpaid fam, less than 5

/*

*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water
gen ind_water= .

*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet
gen ind_toilet=.
*ind_electric	=1 if yes =0 otherwise
gen ind_electric= .
*ind_cleanfuel (see description below of clean fuel)	=1 if good - NOT organic material =0 if bad - organic (dung, coal, etc)
gen ind_cleanfuel= .

gen ind_floor = .
gen ind_roof = .
gen ind_wall = .

gen ind_livingcond = .

**Houshold goods
gen ind_radio = .

*ind_tv	=1  =0
gen ind_tv=.

*ind_bike	=1 =0
gen ind_bike=.

*ind_motorcycle	=1 =0
gen ind_motorcycle=.

*ind_phone=1 with phone (telephone) =0 
gen ind_phone= .

*ind_refrig	=1 =0
gen ind_refrig=.

*cell_new 	=1 =0
gen cell_new=.

*ind_computer	=1 if computer =0 
gen ind_computer=.
gen ind_autos = .
*/


**************************


bys hh_id: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)
gen disability_none_hh = (func_difficulty_hh==1) if !mi(func_difficulty_hh)





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

save "${CLEAN}/Gambia_LFS_2018_Clean.dta", replace
