/*
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/

Reference to appendix and paper:

For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).

Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478

Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com

Author: Kaviyarasan Patchaiappan

Suggested citation: Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478
*/

*Import the data

import excel "C:\Users\kavip\OneDrive\Documents\Malta census.xlsx", sheet("Sheet1") firstrow


**************************************************************************************
***************************************LABELS*****************************************
**************************************************************************************
*Age Group
label define AgeLabel 1 "0-14" 2 "15-19" 3 "20-24" 4 "25-29" 5 "30-34" 6 "35-39" 7 "40-44" 8 "45-49" 9 "50-54" 10 "55-59" 11 "60-64" 12 "65-69" 13 "70-74" 14 "75-79" 15 "80+"
label values Age AgeLabel
label variable Age "Age"

*Label Sex 
label define SexLabel 1 "Male" 2 "Female"
label values Sex SexLabel
label variable Sex "Sex"

* Label Q23 "Do you have any long-term illness, disease, or chronic condition?"
label define Q23Label -2 "Not applicable" 1 "Yes" 2 "No"
label values Q23 Q23Label
label variable Q23 "Do you have any long-term illness, disease, or chronic condition?"

*Label Q24 Seeing
label define Q24_ALabel -2 "Not applicable" 1 "No difficulty" 2 "Yes, some difficulty" ///
                        3 "Yes, a lot of difficulty" 4 "Cannot do at all"
label values Q24_A Q24_ALabel
label variable Q24_A "Difficulty in Seeing"
*Label Q24_B hearing
label define Q24_BLabel -2 "Not applicable" 1 "No difficulty" 2 "Yes, some difficulty" ///
                        3 "Yes, a lot of difficulty" 4 "Cannot do at all"

label values Q24_B Q24_BLabel
label variable Q24_B "Difficulty in Hearing"
*Label Q24_C Walking
label define Q24_CLabel -2 "Not applicable" 1 "No difficulty" 2 "Yes, some difficulty" ///
                        3 "Yes, a lot of difficulty" 4 "Cannot do at all"

label values Q24_C Q24_CLabel
label variable Q24_C "Difficulty in Walking"
*Label Q24_E remembering
label define Q24_DLabel -2 "Not applicable" 1 "No difficulty" 2 "Yes, some difficulty" ///
                        3 "Yes, a lot of difficulty" 4 "Cannot do at all"

label values Q24_D Q24_DLabel
label variable Q24_D "Difficulty in Remembering"
*Label Q24_E Self-care
label define Q24_ELabel -2 "Not applicable" 1 "No difficulty" 2 "Yes, some difficulty" ///
                        3 "Yes, a lot of difficulty" 4 "Cannot do at all"

label values Q24_E Q24_ELabel
label variable Q24_E "Difficulty in Self-care"
*Label Q24_F Communication
label define Q24_FLabel -2 "Not applicable" 1 "No difficulty" 2 "Yes, some difficulty" ///
                        3 "Yes, a lot of difficulty" 4 "Cannot do at all"

label values Q24_F Q24_FLabel
label variable Q24_F "Difficulty in Communication"

*Label Q27 Literate
label define Q27Label -2 "Not applicable" 1 "Literate" 2 "Illiterate"
label value Q27 Q27Label
label variable Q27 "Literate"

*Label Q29 Highest qualification
label define Q29Label -2 "Not applicable" ///
                      1 "ISCED 2 or less - No formal education, primary or lower secondary education" ///
                      2 "ISCED 3 - Upper secondary education" ///
                      3 "ISCED 4 - Post-secondary education" ///
                      4 "ISCED 5-8 - Short-cycle tertiary education, Bachelor's, Master's or Doctoral level or equivalent"
label values Q29 Q29Label
label variable Q29 "Highest qualification"

*Label Q30 Labour Status
label define Q30Label -2 "Not applicable" ///
                      1 "Employed" ///
                      2 "Unemployed" ///
                      3 "Retired" ///
                      4 "Other inactive (unable to work due to illness or disability, student, fulfilling domestic tasks)"

label values Q30 Q30Label
label variable Q30 "Labour Status"

*Label Q36 Employment_status
label define employment_status -2 "Not applicable" 1 "Employee" 2 "Self-employed (with employees)" 3 "Self-employed (without employees)" 4 "Unpaid family worker" 5 "Other"
label values Q36 employment_status
label variable Q36 "Employment_status"

*Label household_size Household Size
label define household_size -2 "Not applicable" 1 "Less than 4" 2 "4" 3 "5" 4 "6" 5 "7" 6 "8" 7 "9" 8 "10" 9 "More than 10"
label values hsize household_size
label variable hsize "Employment_status"


*Label rooms_in_household Number of Rooms Household 
label define rooms_in_household -2 "Not applicable" 1 "Less than 4" 2 "4" 3 "5" 4 "6" 5 "7" 6 "8" 7 "9" 8 "10" 9 "More than 10"
label values num_rooms rooms_in_household
label variable num_rooms "Number of rooms in household"

*Label locality_residence Locality of residence
label define locality_residence ///
    1 "Region 1: Il-Birgu, L-Isla, Bormla, Il-Kalkara" ///
    2 "Region 2: Il-Fgura, Raħal Ġdid, Santa Luċija, Ħal Tarxien" ///
    3 "Region 3: Ħaż-Żabbar, Ix-Xgħajra, Iż-Żejtun, Birżebbuġa, Marsaskala, Marsaxlokk" ///
    4 "Region 4: Ħal Luqa, Il-Gudja, Ħal Għaxaq, Ħal Kirkop, L-Imqabba, Il-Qrendi, Ħal Safi, Iż-Żurrieq" ///
    5 "Region 5: Valletta, Floriana, Il-Marsa, Il-Ħamrun, Tal-Pietà, Santa Venera" ///
    6 "Region 6: Ħal Qormi, Ħaż-Żebbuġ, Is-Siġġiewi" ///
    7 "Region 7: Birkirkara, Il-Gżira, L-Imsida, Ta' Xbiex, San Ġwann" ///
    8 "Region 8: Pembroke, San Ġiljan, Tas-Sliema, Is-Swieqi, Ħal Għargħur" ///
    9 "Region 9: Ħ'Attard, Ħal Balzan, L-Iklin, Ħal Lija" ///
    10 "Region 10: L-Imdina, Ħad-Dingli, Ir-Rabat, L-Imtarfa, L-Imġarr" ///
    11 "Region 11: Il-Mosta, In-Naxxar" ///
    12 "Region 12: Il-Mellieħa, San Pawl Il-Baħar" ///
    13 "Region 13: Għawdex"
label values locality locality_residence
label variable locality "Locality of residence"

*Label InstitutionTag Tag for institutions
label define institution_tag 0 "Private Dwelling" 1 "Institution"
label values tag_institution institution_tag
label variable tag_institution "InstitutionTag Tag for institutions"

bysort HH_Ref: gen hh_size = _N

save "D:\DDI\Malta\Malta census 2021 data.dta",replace

use "D:\DDI\Malta\Malta census 2021 data.dta",clear

**************************************************************************************
***************************************Cleaning***************************************
**************************************************************************************
drop if tag_institution ==1
*(9,545 observations deleted)

drop if Age==1
*(67,567 observations deleted)

gen country_name="Malta"

gen country_abrev="MT"

gen country_dataset_year="Malta Census 2021"

clonevar admin1=locality


gen hh_id=HH_Ref
gen ind_id= Person_Ref

gen ind_weight=1
gen hh_weight=1

***Gender***

	gen female= 1 if (Sex==2)
	replace female=0 if (Sex==1)

	
***Age Group***

	gen age_group = 1 if Age<=4
	replace age_group = 2 if Age>=5 & Age<=7
	replace age_group = 3 if Age>=8 & Age<=11
	replace age_group = 4 if Age>=12

*Difficulties

	clonevar seeing_diff_new= Q24_A 
	clonevar hearing_diff_new= Q24_B 
	clonevar mobility_diff_new= Q24_C 
	clonevar cognitive_diff_new= Q24_D
	clonevar selfcare_diff_new= Q24_E 
	clonevar comm_diff_new= Q24_F

	egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

***Disability levels for any domain***
 
	gen disability_any = (func_difficulty>=2)
	replace disability_any = . if func_difficulty==.

	gen disability_some = (func_difficulty==2)
	replace disability_some = . if func_difficulty==.

	gen disability_atleast = (func_difficulty>=3)
	replace disability_atleast = . if func_difficulty==.

	gen disability_none = (disability_any==0)
	replace disability_none = . if func_difficulty==.

	gen disability_nonesome = (disability_none==1|disability_some==1)
	replace disability_nonesome = . if func_difficulty==.
	
	gen disability_alot=(func_difficulty==3)
	replace disability_alot=. if func_difficulty==.

	gen disability_unable=(func_difficulty==4)
	replace disability_unable=. if func_difficulty==.


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

*Household level Disability 

	egen func_difficulty_hh=max(func_difficulty), by(hh_id)
	lab var func_difficulty_hh "Max Difficulty in HH"

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
	
	gen disability_none_hh = (disability_any_hh==0)

gen disability_nonesome_hh = (disability_none_hh==1|disability_some_hh==1)
	
		gen disability_alot_hh=(func_difficulty_hh==3)
	replace disability_alot_hh=. if func_difficulty_hh==.
	gen disability_unable_hh=(func_difficulty_hh==4)
	replace disability_unable_hh=. if func_difficulty_hh==.
*Lit

	gen lit_new=(Q27==1)


*Atleastprimary education

gen ind_atleastprimary =(Q29>=2) 
replace ind_atleastprimary =. if Age<=3
*Atleastsecondary education

gen ind_atleastsecondary =(Q29>=3) 
replace ind_atleastsecondary =. if Age<=3
*Employment status

gen ind_emp=(Q30==1)

*Informal Work

gen work_informal2=inlist( Q36, 3,4) & ind_emp==1

*Living alone

gen alone=(hh_size==1)

save "D:\DDI\Malta\Malta Census 2021 with raw.dta",replace

egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new cognitive_diff_new mobility_diff_new selfcare_diff_new comm_diff_new)

gen ind_func_diff_missing= (func_diff_missing==6) 

egen disaggvar_missing = rowmiss(female age)

gen ind_disaggvar_missing = (disaggvar_missing >0) 

save "D:\DDI\Malta\Malta_Census_2021 with missing.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1

save "D:\DDI\Malta\Malta_Census_2021.dta", replace

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

save "D:\DDI\Malta\Malta_Census_2021_Cleaned_Individual_Data.dta", replace

duplicates drop hh_id, force

save "D:\DDI\Malta\Malta_Census_2021_Cleaned_Household_Level_Data_Trimmed.dta", replace
