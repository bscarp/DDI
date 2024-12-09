/*******************************************************************************
******************Mexico Census 2020 ********************************************
********************************************************************************
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/
Reference to appendix and paper:
For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).
Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, GVS, Pinilla-Roncancio, M.,  Rivas Velarde, M., Teodoro, D.,  and Mitra, S. (2024). The Disability Statistics – Estimates Database: an innovative database of internationally comparable statistics on disability inequalities. International Journal of Population Data Science.
Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com
Author: Monica Pinilla-Roncancio
Suggested citation: DDI. Disability Statistics Database - Estimates (DS-E Database)). Disability Data Initiative collective. Fordham University: New York, USA. 2024.
*******************************************************************************/
*===============================================================================*
* Project: DDI - Guatemala
* Last modified:  28112024
*===============================================================================*

clear all
clear matrix
clear mata
set more off
set maxvar 10000
set mem 500m
cap log close
pause off


*===============================================================================*
*							       PATHS         						   		*
*===============================================================================*


if  "`c(username)'"=="gustavoco36"{
	gl dta "/Users/gustavoco36/Dropbox/Investigaciones/Proyectos/CODS/DDI/Guatemala" // Ruta de mi computador
}

else {
	gl dta "D:\Dropbox\Dropbox\Guatemala\" // Ruta de ustedes
}

**** DATA


gl results "${dta}/Code/results"
gl dta_work "${dta}/dta/work"

use "${dta_work}/data_final.dta", replace

******* Country information 

gen country_name="Guatemala"
gen country_abrev="GT"
gen country_dataset_year = "Census_2018"
lab var country_name "Country name"
lab var country_abrev "Country abbreviation"
la var  country_dataset_year "Country Data and year"


*****
drop if PCP7<15
count  // 10692397


mdesc PCP6 PCP7 area

****** Disability

*** Functional difficulty variables


clonevar seeing_diff_new=PCP16_A
clonevar hearing_diff_new=PCP16_B
clonevar mobility_diff_new =PCP16_C
clonevar cognitive_diff_new =PCP16_D
clonevar selfcare_diff_new =PCP16_E
clonevar comm_diff_new =PCP16_F 
recode *_diff_new (9=.)
egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

*Disability levels for any domain 
gen     disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

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


gen disability_none = (disability_any==0)
gen disability_nonesome = (disability_none==1|disability_some==1)


 
****** Social Characteristic

gen female=(PCP6==2)
label def female 1 "female" 0 "male"  
label val female female
tab   female, m 
la var female "Female or Male"


gen     age_group=.
replace age_group=1 if PCP7<30
replace age_group=2 if PCP7>=30 & PCP7<45
replace age_group=3 if PCP7>=45 & PCP7<65
replace age_group=4 if PCP7>=65
label   def age_group 1 "15 to 29" 2 "30 to 44" 3 " 45 to 64" 4 "65 or more"
label   val age_group age_group
label   var age_group "Age group"
tab     age_group, m 
rename  PCP7 age 
la var  age_group "Age Group"

gen urban_new=(area==2)
label var urban_new "1 for rural 0 for urban"


****** Education  
tab NIVGRADO 

** Ever attend school 

gen     everattended_new=(NIVGRADO!=10 | PCP18 ==1) 
replace everattended_new =. if  NIVGRADO==. & PCP18==. 
lab var everattended_new "E1_Ever_attended_school binary"
tab     everattended_new

** Adults ages 25+ who have completed primary school or higher 
codebook NIVGRADO , tab(39)
gen     escoacum_new=NIVGRADO

gen     ind_atleastprimary =( escoacum_new>=36)  if  escoacum_new!=.   // Primary education 6 years
replace ind_atleastprimary  =. if age<25
tab     ind_atleastprimary if age>25, m 
label var ind_atleastprimary "Adults ages 25+ who have completed primary school or higher "


** Adults ages 25+ who have completed upper secondary  school or higher  // Secundary 3 years + 3 of diversificado (12 years) 

gen     ind_atleastsecondary  =( escoacum_new>=46)  if  escoacum_new!=. 
replace ind_atleastsecondary  =. if age<25
tab     ind_atleastsecondary if age>25, m 
label var ind_atleastsecondary "Adults ages 25+ who have completed upper secondary  school or higher "

*variable for ages 15+ used for the deprivation variable for multidimensional poverty
gen     ind_atleastprimary_all = ( escoacum_new>=36)  if  escoacum_new!=.

** Literacy

gen lit_new =  (PCP22==1) 
lab var lit_new  "E5_literate binary"


****** Personal activities (including work)


** Employed 

gen     acivity_labour=1 if PCP27==1 | inlist(PCP28,1,2,3,4,5,6) // working or not working but in employment 

replace acivity_labour=2 if inlist(PCP29,1,2) // searching for a job
replace acivity_labour=3 if inlist(PCP29,3,4,5,6,7,8)  // outside labour force
replace acivity_labour=. if PCP27==.
tab     acivity_labour

gen     ind_emp= (acivity_labour==1)  if acivity_labour!=.
lab var ind_emp "W1_employed"
tab     ind_emp, m 


** Youth Idle Rate 

gen d_age_15_24 = (age>14&age<25) if age!=.
gen youth_idle=(ind_emp==0 & PCP18==2) if d_age_15_24==1
replace youth_idle =. if PCP18 ==. & ind_emp==.
lab var youth_idle "W2_youth idle binary"

tab youth_idle  disability_atleast, nof col
 
** Working Individulas in Manufacturing

codebook PCP30_1D, tab(30)
gen work_manufacturing= inlist(PCP30_1D,8,7) if ind_emp==1
lab var work_manufacturing "W3_worker in manufacturing binary"


** Women in Managerial Positions

tab PCP30_1D
gen work_managerial= PCP30_1D==1 if (PCP6==2)  & ind_emp==1
lab var work_managerial "W4_woman worker in managerial position binary"

*** Informality 
tab PCP31_D, m 
gen work_informal = (PCP31_D==2 | PCP31_D==3 | PCP31_D==6 | PCP31_D==7 | PCP31_D==9) if PCP31_D!=.
lab var work_informal "W5_Adults who work in the informal labour market"

*work_managerial is a binary for women in managerial work among all women while work_managerial2 code  women in managerial work among working women only. We use  work_managerial2  to generate the  women in managerial work   indicator for the DS-E database.

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if (ind_emp==. & work_managerial==.) 

*work_informal is a binary variable for informal work status among all adults while work_informal2 codes informal work among workers only. We use work_informal2 to generate the informal work indicator for the DS-E database.

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.

** Cell phone
recode PCP26_A (1=1) (2=0) (9=.), gen(cell_new)
lab var cell_new "P2_Adults who used a cell last 3 months"


** Computer
recode PCP26_B (1=1) (2=0) (9=.), gen(computer)
lab var computer "P2_Adults who used a computer last 3 months"

** Internet
recode PCP26_C (1=1) (2=0) (9=.), gen(internet)
lab var internet "P2_Adults who used a internet last 3 months"

****** Health

** Drinking water
codebook PCH4, tab(20)
recode PCH4 (1/3=1) (4/10=0) , gen(ind_water)
lab var ind_water "H1_Water"

** Sanitation services
codebook PCH5, tab(20)
tab PCH6, m nol
recode PCH5 (1/3=1) (4/5=0), gen (ind_toilet)
replace ind_toilet=0 if PCH6==2

*** Living Alone

gen member = 1 										// hh size
bys NUM_VIVIENDA NUM_HOGAR: egen hhsize = sum(member)
lab var hhsize "household size"
ta hhsize, m

gen alone=(hhsize==1) if hhsize!=.
tab alone 
lab var alone "Adults who live alone"

*** Child Mortality
codebook PCP35_A PCP36_A, tab(30)  // Total number of children alive
recode   PCP35_A  (99=.)

gen     mortality= (PCP35_A-PCP36_A) if PCP6==2 & age>=10
replace mortality=0 if PCP35_A==0 & PCP6==2 & age>=10
replace mortality=(mortality>0) if mortality!=.
tab    PCP35_A mortality if PCP6==2 & age>=10, m


gen mujer_10 = (PCP6==2 & age>=10)
tab mujer_10, m

bys NUM_VIVIENDA NUM_HOGAR: egen hh_mujer10 = max(mujer_10)

bys NUM_VIVIENDA NUM_HOGAR: egen child_mortality_hh = max(mortality)
replace child_mortality_hh=0 if hh_mujer10==0 
lab var child_mortality_hh "Any child in a household has died"
tab     child_mortality_hh, m   // missing because no information from women in age group. 

****** Standard of Living

** Electricity
codebook PCH8, tab(20)
recode PCH8 (1/2=1) (3/5=0), gen(ind_electric)
lab var ind_electric "S1_Electricity"


** Cooking Fuel
codebook PCH14, tab(20)
recode PCH14 (1=1) (2=0) (3=1) (4=0) (5/7=1) (6=0), gen(ind_cleanfuel)
lab var ind_cleanfuel "S2_Clean_fuel"


** Adequate housing

* Floor
codebook PCV5, tab(20)
recode PCV5 (1/4=1) (5/8=0) , gen(ind_floor)
lab var ind_floor "Individual in a house with quality floor materials"

* Roof
codebook PCV3, tab(20)
recode PCV3 (1/4=1) (5/7=0) (9=.), gen(ind_roof)
lab var ind_roof "Individual in a house with quality roof materials"

* Walls
codebook PCV2, tab(20)
recode PCV2 (1/3=1) (4/10=0) , gen(ind_wall)
lab var ind_wall "Individual in a house with quality wall materials"


gen ind_livingcond=(ind_floor==1 | ind_roof==1 | ind_wall==1) if ind_floor!=. & ind_roof!=. &ind_wall!=.
lab var ind_livingcond "S3_Individual in a house with  adequate housing (quality floor, quality roof, quality wall materials)"


** Owing Assets:  radio, TV, telephone, bike, or motorbike or fridge); and the household does not own a car (or truck).
tab1   PCH9_*, m
recode PCH9_* (1=1) (2=0)  (99=.)
egen   ind_asset_ownership=rowmean(PCH9_A PCH9_C PCH9_E PCH9_H PCH9_L)
lab var ind_asset_ownership "S4_Owns_assets"
gen     ind_asset_ownership_binary = ind_asset_ownership>1 if  ind_asset_ownership!=.
replace ind_asset_ownership_binary = 1 if PCH9_M==1  
lab var ind_asset_ownership_binary "S4_Owns_assets_binary"

** Radio
gen ind_radio=(PCH9_A==1) if PCH9_A!=.
lab var ind_radio "Individual in a household that owns radio"

** TV
gen ind_tv=(PCH9_C==1) if PCH9_C!=.
lab var ind_tv "Individual in a household that owns tv"

** Refrigerator
gen ind_refrig=(PCH9_E==1) if PCH9_E!=.
lab var ind_refrig "Individual in a household that owns refrigerator"

** Motorcycle
gen ind_motorcycle=(PCH9_L==1) if PCH9_L!=.
lab var ind_motorcycle "Individual in a household that owns motorbike"

** Autos
gen ind_autos=(PCH9_M==1) if PCH9_M!=.
lab var ind_autos "Individual in a household that owns autos"

** Computer
gen ind_computer=(PCH9_H==1) if PCH9_H!=.
lab var ind_computer "Individual in a household that owns computer"

***Phone 
gen ind_phone = (PCP26_A==1) if PCP26_A!=.
lab var cell_new "Individual in a household that owns cell-phone"


gen 	admin1=1 if DEPARTAMENTO==1
replace admin1=2 if DEPARTAMENTO==15 |DEPARTAMENTO==16
replace admin1=3 if DEPARTAMENTO==2 |DEPARTAMENTO==19 |DEPARTAMENTO==18|DEPARTAMENTO==20
replace admin1=4 if DEPARTAMENTO==6 |DEPARTAMENTO==22 |DEPARTAMENTO==21
replace admin1=5 if DEPARTAMENTO==3 |DEPARTAMENTO==4 
replace admin1=6 if DEPARTAMENTO==7 |DEPARTAMENTO==8 |DEPARTAMENTO==9|DEPARTAMENTO==12
replace admin1=7 if DEPARTAMENTO==14 |DEPARTAMENTO==13
replace admin1=8 if DEPARTAMENTO==17
replace admin1=9 if DEPARTAMENTO==11 |DEPARTAMENTO==10 |DEPARTAMENTO==5



label define admin1 1 "Metropolitana" 2 "Las Verapaces" 3 "Nororiente" 4 "Suroriente" 5"Centro" 6"Occidente"  7"Noroccidente" 8"Petén" 9 "Costa Sur"
label values admin1 admin1
rename PCP1 ind_id 
rename DEPARTAMENTO admin2
rename MUNICIPIO district 


la var admin1 "Admin 1 Level"
rename district admin3
la var admin2 "Admin 2 Level"
la var admin3 "Admin 3 Level"

***

clonevar admin_alt=admin1
la var admin_alt "Admin 1 Level Alternative"
drop admin1

rename admin2 admin1
la var admin1 "Admin 1 Level"

rename admin3 admin2
la var admin2 "Admin 2 Level"




****** Multidimensional Poverty 


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
	

gen     deprive_sl_asset = 0
replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + /*ind_bike +*/ ind_motorcycle < 2) & ind_autos==0)
replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. /*& ind_bike==.*/ & ind_motorcycle==. & ind_autos==.

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
						
gen deprive_health=(1/missing_health)*0.33*health_temp 
gen deprive_sl=(1/missing_sl)*0.33*sl_temp 
replace deprive_health=(1/missing_health)*0.25*health_temp 
replace deprive_sl=(1/missing_sl)*0.25*sl_temp 

gen mdp_score=cond(mi(deprive_educ)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_health+deprive_sl) 
replace mdp_score=cond(mi(deprive_educ)|mi(deprive_work)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_work+deprive_health+deprive_sl) 

gen ind_mdp=cond(mi(mdp_score),.,cond((mdp_score>0.33),1,0))



*Household level Disability 
egen    func_difficulty_hh=max(func_difficulty), by(NUM_VIVIENDA NUM_HOGAR)
lab var func_difficulty_hh "Max Difficulty in HH"

gen     disability_any_hh=1 if func_difficulty_hh>1
replace disability_any_hh=0 if func_difficulty_hh==1
replace disability_any_hh=. if func_difficulty_hh==.

lab var disability_any_hh "P3 Any difficulty in Any Domain for any adult in the hh"

gen     disability_some_hh=1 if func_difficulty_hh==2
replace disability_some_hh=0 if func_difficulty_hh!=2
replace disability_some_hh=. if func_difficulty_hh==.

lab var disability_some_hh "P3 Some difficulty in Any Domain for any adult in the hh"

gen     disability_atleast_hh=1 if func_difficulty_hh>2
replace disability_atleast_hh=0 if func_difficulty_hh<3
replace disability_atleast_hh=. if func_difficulty_hh==.

lab var disability_atleast_hh "P3 At least a lot of difficulty in Any Domain for any adult in the hh"

egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new comm_diff_new cognitive_diff_new mobility_diff_new selfcare_diff_new)
gen ind_func_diff_missing= (func_diff_missing==6)

egen disaggvar_missing = rowmiss(female age urban_new)

gen ind_disaggvar_missing = (disaggvar_missing >0)

compress
save "${dta_work}/Guatemala_Cleaned_Individual_Data_withmissing.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1

*Create indicators for no disability and for none or some disability
*gen disability_none = (disability_any==0)
*lab var disability_none "No Difficulty"

*gen disability_nonesome = (disability_none==1|disability_some==1)
*lab var disability_nonesome "No or Some Difficulty"

egen hh_id = group(NUM_VIVIENDA NUM_HOGAR)

gen     hh_weight=1
lab var hh_weight "Household Sample weight"
gen     ind_weight=1 
lab var ind_weight "Individual Sample weight"

*drop person_id person_num 
drop func_diff_missing ind_func_diff_missing disaggvar_missing ind_disaggvar_missing 

*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin_alt ind_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary   computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh bmi obese overweight_obese child_mortality_hh mosquito_net healthcare_prob death_hh alone not_owned_hh overcrowd not_owned_hh overcrowd"

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
la var cognitive_diff_new "Difficulty in cognition"
la var mobility_diff_new "Difficulty in walking"

la var selfcare_diff_new "Difficulty in selfcare"
la var func_difficulty "Difficulty in Any Domain"

keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  admin_alt///
ind_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group ///
 /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new ///
 comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome ///
 seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some ///
 cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot ///
 selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ///
 ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle ///
 work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2/*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ///
 bmi obese overweight_obese child_mortality_hh mosquito_net healthcare_prob death_hh alone ///
 /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond  not_owned_hh overcrowd ///
 /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos ///
 cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh ///
 /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  ///
 deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh ///
 disability_some_hh disability_atleast_hh  admin_alt 

order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin_alt ///
ind_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group ///
 /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new ///
 comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome ///
 seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some ///
 cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot ///
 selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ///
 ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle ///
 work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2/*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ///
 /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ///
 /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos ///
 cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh ///
 /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  ///
 deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh ///
 disability_some_hh disability_atleast_hh 

 
 
 save "${dta_work}/Guatemala_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

