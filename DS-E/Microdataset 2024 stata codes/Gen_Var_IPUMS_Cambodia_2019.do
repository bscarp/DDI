/*******************************************************************************
******************Cambodia-IPUMS-2019********************************************
********************************************************************************
Author: Kaviyarasan Patchaiappan
Reference: DSE
Website:
*******************************************************************************/
use "D:\ipumsi_00049.dta\ipumsi_00049.dta", clear

*keep only households

keep if gq==10 | gq==29

drop if age<15
tab sample
replace age=. if age==999

gen country_name="Cambodia"
gen country_abrev="KHM" 
gen country_dataset_year="Cambodia IPUMS 2019"
gen hh_weight= hhwt
gen ind_weight=perwt
clonevar admin1= geo1_kh2019
clonevar admin2= geo2_kh2019

egen hh_id= concat(sample serial), format(%25.0g) punct(_)
egen ind_id= concat(sample serial pernum), format(%25.0g) punct(_)

*Urban/Rural

gen urban_new=1 if urban==1
replace urban_new=0 if urban==2
replace urban_new=. if urban==9

*Gender

gen female= 1 if ( sex ==2)
replace female=0 if ( sex ==1)

*Age group

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65
replace age_group =. if age==.

*Lit

gen lit_new=1 if lit==2
replace lit_new=0 if lit==1
replace lit_new=. if lit==0 | lit==9

*Everattended School

gen everattended_new=inlist(edattaind, 120, 211, 212, 221, 222, 311, 312, 321, 322, 400)
replace everattended_new=. if inlist(edattaind, 0, 999)

*Education - completed primary school

gen ind_atleastprimary_all = (edattain>=2)
replace ind_atleastprimary_all =. if (edattain==0 | edattain==9)

*Atleastprimary education

gen ind_atleastprimary = (edattain>=2) if age>=25
replace ind_atleastprimary =. if (edattain==0 | edattain==9)

*Atleastsecondary education

gen ind_atleastsecondary = (edattain>=3) if age>=25
replace ind_atleastsecondary =. if (edattain==0 | edattain==9)

*Employment Status

gen ind_emp=.
replace ind_emp=1 if empstat==1
replace ind_emp=0 if empstat==2 | empstat==3

*Female at Managerial Work

gen work_managerial=cond(mi(occisco),.,cond(occisco==1,1,0))
replace work_managerial= 0 if ind_emp==0 | ind_emp==.
replace work_managerial= . if female==0 

*Manufacturing Worker

gen work_manufacturing=cond(mi(indgen),.,cond(indgen==30,1,0))
replace work_manufacturing=. if ind_emp==0 

*Informal Work

gen work_informal=cond(mi(classwkd),.,cond(inlist(classwkd, 100, 101, 120, 208, 230, 300, 320, 310, 350, 400, 208, 220),1,0))

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if (ind_emp==. & work_managerial==.) 

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.

* Youth idle

gen school_new=(school==1)
replace school_new=. if (school==0| school==9)

gen youth_idle=1 if (school_new==0 & ind_emp==0)
replace youth_idle=0 if (school_new==1 | ind_emp==1)
replace youth_idle=. if (school_new==. & ind_emp==.)
replace youth_idle=. if age>24

*Electricity

gen ind_electric= (kh2019a_light==1)
replace ind_electric=. if kh2019a_light==.

*Household Assest

*Radio
gen ind_radio= ( radio==2 )
replace ind_radio=. if radio==0 | radio==9| radio==.

*Phone
gen ind_phone=(phone==2)
replace ind_phone=. if phone==0 | phone==9| phone==.

*Cell
gen cell_new=(cell==1)
replace cell_new=. if cell==.|cell==0|cell==9

*Television
gen ind_tv= ( tv >=20)
replace ind_tv=. if tv==.|tv==0|tv==99

*Computer
gen ind_computer=( computer ==2)
replace ind_computer=. if computer ==.| computer ==0|computer ==9

*Refrig
gen ind_refrig=( refrig ==2)
replace ind_refrig=. if refrig ==.| refrig ==0| refrig ==9

*Motorcycle
gen ind_motorcycle=(kh2019a_motorcyc>=1)

*Bike
gen ind_bike=(kh2019a_bike>=1)

*Autos
gen ind_autos=.
replace ind_autos=0 if autos==0
replace ind_autos=1 if inlist( autos, 1,2,3,4,5,6,7)

*Assests

egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_autos ind_computer ind_bike ind_motorcycle)

***Water***

gen ind_water = inlist(kh2019a_water, 1, 2, 3, 4, 5, 7, 9, 13)
replace ind_water=. if kh2019a_water==.

***Sanitation***

gen toilet= inlist(kh2019a_toilet, 2, 3, 4, 5)
replace toilet=. if kh2019a_toilet==.

gen ind_toilet=0
replace ind_toilet= 1 if toilet == 1 &kh2019a_toiletsh == 2

*Cooking fuel

gen ind_cleanfuel=inlist(fuelcook, 20, 34)
replace ind_cleanfuel=. if fuelcook==99 | fuelcook==0 |fuelcook==.

*Difficulties

clonevar seeing_diff_new= wgvision if wgvision<8
clonevar hearing_diff_new= wghear if wghear<8
clonevar mobility_diff_new= wgmobil if wgmobil<8
clonevar cognitive_diff_new= wgcogn if wgcogn<8
clonevar selfcare_diff_new= wgcare if wgcare<8
clonevar comm_diff_new= wgcomm if wgcomm<8 

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

***Disability levels for any domain***
 
gen disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

gen disability_none = (disability_any==0)

gen disability_nonesome = (disability_none==1|disability_some==1)


***Any difficulty for each domain***

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

***Some difficulty for each domain***

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

***At least alot difficulty for each domain***

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

rename computer computer_hh

*Multidimensional poverty

*if observation has labor information labor_tag==1, otherwise ==0
gen labor_tag=1 if ind_emp!=.
replace labor_tag=0 if ind_emp==.

gen deprive_educ=cond(mi(ind_atleastprimary_all),.,cond(ind_atleastprimary_all==0,0.33,0)) if labor_tag==0
gen deprive_work=.	if	labor_tag==0
		
replace deprive_educ=cond(mi(ind_atleastprimary_all),.,cond(ind_atleastprimary_all==0,0.25,0))  if labor_tag==1
replace deprive_work=cond(mi(ind_emp),.,cond(ind_emp==0,0.25,0))  if labor_tag==1

gen deprive_health_water=cond(mi(ind_water),.,cond(ind_water==0,1,0))
	
gen deprive_health_sanitation=cond(mi(ind_toilet),.,cond(ind_toilet==0,1,0))

gen deprive_sl_electricity=cond(mi(ind_electric),.,cond(ind_electric ==0,1,0))

gen deprive_sl_fuel=cond(mi(ind_cleanfuel),.,cond(ind_cleanfuel==0,1,0))

gen deprive_sl_asset=0
replace deprive_sl_asset=1 if (ind_radio + ind_tv + ind_refrig + ind_phone + ind_bike + ind_motorcycle <2) & ind_autos==0
replace deprive_sl_asset=. if (ind_radio==. & ind_tv==. & ind_refrig==. & ind_phone==. & ind_bike==. & ind_motorcycle==. & ind_autos==.)

*we assume that dimensions can not be missing but indicators inside can be missing. The dimension weights remain the same but the indicators weights should change
egen missing_health=rowmiss(deprive_health_water deprive_health_sanitation)
replace missing_health=2-missing_health
egen health_temp=rowtotal(deprive_health_water deprive_health_sanitation)
					
egen missing_sl=rowmiss(deprive_sl_electricity deprive_sl_fuel deprive_sl_asset)
replace missing_sl=3-missing_sl
egen sl_temp=rowtotal(deprive_sl_electricity deprive_sl_fuel deprive_sl_asset)

****since the housing condition(Wall,roof,floor) is not avaiable we assume the weight is 1/3******						

gen deprive_health=(1/missing_health)*0.33*health_temp if  labor_tag==0
gen deprive_sl=(1/missing_sl)*0.33*sl_temp if  labor_tag==0
	
replace deprive_health=(1/missing_health)*0.25*health_temp if labor_tag==1 
replace deprive_sl=(1/missing_sl)*0.25*sl_temp if  labor_tag==1 

gen mdp_score=cond(mi(deprive_educ)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_health+deprive_sl) if  labor_tag==0
replace mdp_score=cond(mi(deprive_educ)|mi(deprive_work)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_work+deprive_health+deprive_sl) if  labor_tag==1 

gen ind_mdp=cond(mi(mdp_score),.,cond((labor_tag==1 &mdp_score>0.25)|(labor_tag==0 &mdp_score>0.33),1,0))


*Household level Disability 

egen func_difficulty_hh1=max(func_difficulty), by(hh_id)
lab var func_difficulty_hh1 "Max Difficulty in HH"

gen disability_any_hh=1 if func_difficulty_hh>1
replace disability_any_hh=0 if func_difficulty_hh==1
replace disability_any_hh=. if func_difficulty_hh==.
lab var disability_any_hh "P3 Any difficulty in Any Domain for any adult in the hh"

gen disability_some_hh=1 if func_difficulty_hh==2
replace disability_some_hh=0 if func_difficulty_hh!=2
replace disability_some_hh=. if func_difficulty_hh==.
lab var disability_some_hh "P3 Some difficulty in Any Domain for any adult in the hh"

gen disability_atleast_hh=1 if func_difficulty_hh>2
replace disability_atleast_hh=0 if func_difficulty_hh<3
replace disability_atleast_hh=. if func_difficulty_hh==.
lab var disability_atleast_hh "P3 At least a lot of difficulty in Any Domain for any adult in the hh"

save "D:\DDI\Cambodia_IPUMS_2019.dta", replace

egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new cognitive_diff_new mobility_diff_new selfcare_diff_new comm_diff_new)
*change domain
gen ind_func_diff_missing= (func_diff_missing==6)
*change domain
egen disaggvar_missing = rowmiss(female age urban_new)

gen ind_disaggvar_missing = (disaggvar_missing >0)


save "D:\DDI\Cambodia_IPUMS_2019 with missing.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1

*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin3 admin_alt ind_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary   computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh"

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
lab var ind_weight "Individaul Sample weight"
lab var hh_weight "Household Sample weight"
lab var sample_strata "Strata weight"
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
lab var func_difficulty_hh "Max Difficulty in HH"
lab var disability_any_hh "P3 Any difficulty in Any Domain for any adult in the hh"
lab var disability_some_hh "P3 Some difficulty in Any Domain for any adult in the hh"
lab var disability_atleast_hh "P3 At least a lot of difficulty in Any Domain for any adult in the hh"
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
lab var work_managerial "Women in managerial position"
lab var work_informal "Informal work"
lab var ind_water "Safely managed water source"
lab var ind_toilet "Safely managed sanitation"
lab var fp_demsat_mod "H3_Family_planning"
lab var anyviolence_byh_12m "Experienced any violence last 12 months"
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

 
keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight dv_weight sample_strata psu female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight dv_weight sample_strata psu female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

compress

save "D:\DDI\Cambodia_IPUMS_2019_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

save "D:\DDI\Cambodia_IPUMS_2019_Cleaned_Household_Level_Data_Trimmed.dta", replace

su disability_any_hh disability_some_hh disability_atleast_hh
