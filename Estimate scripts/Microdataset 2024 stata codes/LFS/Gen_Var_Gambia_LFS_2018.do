/*
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/

Reference to appendix and paper:

For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).

Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478

Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com

Author: Jaclyn Yap, Ph.D.

Suggested citation: Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478
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

gen disability_alot=(func_difficulty==3)
	replace disability_alot=. if func_difficulty==.

	gen disability_unable=(func_difficulty==4)
	replace disability_unable=. if func_difficulty==.
	

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
	gen disability_nonesome_hh = (disability_none_hh==1|disability_some_hh==1)
	
	gen disability_alot_hh=(func_difficulty_hh==3)
	replace disability_alot_hh=. if func_difficulty_hh==.
	
	gen disability_unable_hh=(func_difficulty_hh==4)
	replace disability_unable_hh=. if func_difficulty_hh==.
	
gen alone=(nhhold_memb==1)
replace alone=. if nhhold_memb==.




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

compress

save "D:\DDI\New Indicator\Gambia_LFS_2018_Clean.dta",replace

save "${CLEAN}/Gambia_LFS_2018_Clean.dta", replace
