/*
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/

Reference to appendix and paper:

For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).

Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478

Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com

Author: Kaviyarasan Patchaiappan

Suggested citation: Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478
*/

cd "D:\DDI\Wallis and Futuna - Enquête Budget des Familles 2019 - 2019"

use "SPC_WLF_2019_HIES_30-ExpenditureAggreg_v01_PUF.dta",clear
bysort anon_id07 : egen total_exp = total( annual_amount )
gen exp_health = annual_amount if coicop_div == 6 

bysort anon_id07: egen health_exp = total(exp_health)

duplicates drop anon_id07, force
save "health exp.dta",replace

use "SPC_WLF_2019_HIES_1-DemoCharacter_v01_PUF.dta",clear

merge 1:1 anon_id07 individual_id using "SPC_WLF_2019_HIES_2-Education_v01_PUF.dta", generate(_merge_edu)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             3,965  (_merge_edu==3)
    -----------------------------------------
*/

merge 1:1 anon_id07 individual_id using "SPC_WLF_2019_HIES_3-Health_v01_PUF.dta", generate(_merge_health)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             3,965  (_merge_health==3)
    -----------------------------------------
*/

merge 1:1 anon_id07 individual_id using "SPC_WLF_2019_HIES_4-Disability_v01_PUF.dta", generate(_merge_dis)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             3,965  (_merge_dis==3)
    -----------------------------------------
*/

merge 1:1 anon_id07 individual_id using "SPC_WLF_2019_HIES_5-Communication_v01_PUF.dta", generate(_merge_com)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             3,965  (_merge_com==3)
    -----------------------------------------
*/
merge 1:1 anon_id07 individual_id using "SPC_WLF_2019_HIES_8-LabourForceILO_v01_PUF.dta", generate(_merge_labour)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             3,965  (_merge_labour==3)
    -----------------------------------------
*/

save "Wallis and Futuna Individual.dta",replace 

use "SPC_WLF_2019_HIES_11-Dwelling_v01_PUF.dta",clear

merge 1:1 anon_id07 using "SPC_WLF_2019_HIES_12-Assets_v01_PUF.dta", generate(_merge_asset)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             1,010  (_merge_asset==3)
    -----------------------------------------
*/

merge 1:1 anon_id07 using "SPC_WLF_2019_HIES_13b-Vehicles_v01_PUF.dta", generate(_merge_veh)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             1,010  (_merge_veh==3)
    -----------------------------------------
*/

merge 1:1 anon_id07 using "health exp.dta", generate(_merge_exp)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             1,010  (_merge_exp==3)
    -----------------------------------------
*/

save "Wallis and Futuna HH.dta",replace

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             3,965  (_merge==3)
    -----------------------------------------
*/

merge 1:m anon_id07 using "Wallis and Futuna Individual.dta"

save "Wallis and Futuna raw.dta",replace

use "Wallis and Futuna raw.dta", clear

drop if age_grp5<=3

********Country Name****************
gen country_name="Wallis and Futuna"
********Country Abrevation*********
gen country_abrev="WF" 

*********Country_dataset_year*******
gen country_dataset_year="Wallis and Futuna HIES 2019"

***Household Weight***

gen hh_weight= fweight

***Individual Weight***

gen ind_weight=fweight

*****Household and Individual Ids***********

gen hh_id= anon_id07 
egen ind_id= concat(anon_id07 individual_id), format(%25.0g) punct(_)



*Gender

gen female= 1 if ( sex ==2)
replace female=0 if ( sex ==1)

clonevar age=age_grp5

*Age group

gen age_group = 1 if age ==6
replace age_group = 2 if age>=7 & age<=9
replace age_group = 3 if age>=10 & age<=13
replace age_group = 4 if age>=14
replace age_group =. if age==.

*Difficulties

clonevar seeing_diff_new= p401
clonevar hearing_diff_new= p402
clonevar mobility_diff_new= p403
clonevar cognitive_diff_new= p404
clonevar selfcare_diff_new= p405
clonevar comm_diff_new= p406

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

gen lit_new=(p201==1 & p202==1)
replace lit_new=. if p202==. & p201==.

*Everattended School

gen everattended_new=p205==1
replace verattended_new=. if p205==.

*Education - completed primary school
*This variable was created for computing multidimensional poverty
gen ind_atleastprimary_all = (p207>=7)
replace ind_atleastprimary_all =. if p207==.

*Atleastprimary education

gen ind_atleastprimary = (p207>=7) if age>=25
replace ind_atleastprimary =. if p207==.

*Atleastsecondary education

gen ind_atleastsecondary = (p207>=14) if age>=25
replace ind_atleastsecondary =. if p207==.

*Employment Status

gen ind_emp=inlist(p801, 2, 3)
replace ind_emp=. if p801==.

*Female at Managerial Work

gen work_managerial2=(p814_1==1)
replace work_managerial2=. if ind_emp==0 
replace work_managerial2=. if ind_emp==. & p812_1==22
replace work_managerial2=. if female==0

*Manufacturing Worker

gen work_manufacturing=p812_1==3
replace work_manufacturing=. if ind_emp==0 | ind_emp==. 


gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.

gen computer=(p520!=3)
replace computer=. if p520==.

clonevar internet= p501

gen mobile_own=(p505a==1)
replace mobile_own=. if p505a==.

*Not in schools
gen school_new=(p208==1)
replace school_new=. if p208==.

* Youth idle

gen youth_idle=1 if (school_new==0 & ind_emp==0)
replace youth_idle=0 if (school_new==1 | ind_emp==1)
replace youth_idle=. if (school_new==. & ind_emp==.)
replace youth_idle=. if age>24

gen health_exp_hh=( health_exp /total_exp)


*health insurance

gen health_insurance=(p303==1)
replace health_insurance=. if p303==.

*Electricity

gen ind_electric=inlist( h1110__1_1, 1) /*Electricity primarly used for lighting*/
replace ind_electric=. if h1110__1_1==.

*Cooking fuel

gen ind_cleanfuel=h1110__1_4==1 /*Gas primarly used for cooking*/
replace ind_cleanfuel=1 if h1110__1_1==1 /*Electricity primarly used for cooking*/
replace ind_cleanfuel=. if h1110__1_1==. & h1110__1_4==.

*Water

gen ind_water = inlist(h1116, 1, 2)
replace ind_water = . if h1116==.



** Adequate housing
*Floor 

gen ind_floor= inlist(h1104, 2,3)
replace ind_floor=. if h1104==.

*Roof 

gen ind_roof= inlist(h1102, 1, 2, 3)
replace ind_roof=. if h1102==.

*Wall

gen ind_wall= h1103==1
replace ind_wall=. if h1103==.


*Housing Condition

gen ind_livingcond=(ind_floor==1&ind_roof==1&ind_wall==1) 
replace ind_livingcond=. if (ind_floor==.&ind_roof==.& ind_wall==.)


*Household Assest


*Phone
gen ind_phone=(h1201__31==1)
replace ind_phone=. if h1201__31==.

*Cell
egen cell_new=max(mobile_own), by(hh_id)

*Television
gen ind_tv= ( h1201__23==1)
replace ind_tv=. if h1201__23==.

*Computer
gen ind_computer=( h1201__32 ==2)
replace ind_computer=. if h1201__32 ==.

*Refrig
gen ind_refrig=( h1201__7 ==1)
replace ind_refrig=. if h1201__7 ==.

*Motorcycle
gen ind_motorcycle=(h13b1__3==1)
replace ind_motorcycle=. if h13b1__3==.

*Bike
gen ind_bike=(h13b1__4==1)
replace ind_bike=. if h13b1__4==9

*Autos
gen ind_autos=.
replace ind_autos=0 if h13b1__1==0
replace ind_autos=1 if h13b1__1==1

*Assests

egen ind_asset_ownership=rowmean( ind_tv ind_refrig ind_phone cell_new ind_autos ind_computer ind_bike ind_motorcycle)


*alone

	gen alone=(hhsize==1)

*Multidimensional poverty 	
*if observation has labor information labor_tag==1, otherwise ==0
gen labor_tag=1 if ind_emp!=.
replace labor_tag=0 if ind_emp==.

gen deprive_educ=cond(mi(ind_atleastprimary_all),.,cond(ind_atleastprimary_all==0,0.33,0)) if labor_tag==0
replace deprive_educ=cond(mi(ind_atleastprimary_all),.,cond(ind_atleastprimary_all==0,0.25,0))  if labor_tag==1

gen deprive_work=.	if	labor_tag==0
replace deprive_work=cond(mi(ind_emp),.,cond(ind_emp==0,0.25,0))  if labor_tag==1		

gen deprive_health_water=cond(mi(ind_water),.,cond(ind_water==0,1,0))
	

gen deprive_sl_electricity=cond(mi(ind_electric),.,cond(ind_electric ==0,1,0))

gen deprive_sl_fuel=cond(mi(ind_cleanfuel),.,cond(ind_cleanfuel==0,1,0))

gen deprive_sl_housing=cond(mi(ind_livingcond),.,cond(ind_livingcond==0,1,0))

gen deprive_sl_asset = 0
replace deprive_sl_asset = 1 if ((  ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle) < 2) & ind_autos==0
replace deprive_sl_asset = . if  ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.

lab var deprive_educ "Deprived if less than primary school completion"
lab var deprive_work "Deprived in work binary"
lab var deprive_health_water "Deprived in water binary"

lab var deprive_sl_electricity "Deprived for electricity binary"
lab var deprive_sl_fuel "Deprived in terms of clean fuel binary"
lab var deprive_sl_housing "Deprived in terms of housing binary"
lab var deprive_sl_asset "Deprived in terms of asset ownership binary"

*we assume that dimensions can not be missing but indicators inside can be missing. The dimension weights remain the same but the indicators weights should change
egen missing_health=rowmiss(deprive_health_water)
replace missing_health=2-missing_health
egen health_temp=rowtotal(deprive_health_water)
					
egen missing_sl=rowmiss(deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset)
replace missing_sl=4-missing_sl
egen sl_temp=rowtotal(deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset)
						
gen deprive_health=(1/missing_health)*0.33*health_temp if  labor_tag==0
replace deprive_health=(1/missing_health)*0.25*health_temp if labor_tag==1 

gen deprive_sl=(1/missing_sl)*0.33*sl_temp if  labor_tag==0
replace deprive_sl=(1/missing_sl)*0.25*sl_temp if  labor_tag==1 

gen mdp_score=cond(mi(deprive_educ)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_health+deprive_sl) if  labor_tag==0
replace mdp_score=cond(mi(deprive_educ)|mi(deprive_work)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_work+deprive_health+deprive_sl) if  labor_tag==1 


gen ind_mdp=cond(mi(mdp_score),.,cond((labor_tag==1 &mdp_score>0.25)|(labor_tag==0 &mdp_score>0.33),1,0))


save "Wallis_and_Futuna_LSMS_2019.dta",replace 


egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new cognitive_diff_new mobility_diff_new selfcare_diff_new comm_diff_new)
*change domain
gen ind_func_diff_missing= (func_diff_missing==6) 
*change domain
egen disaggvar_missing = rowmiss(female age)

gen ind_disaggvar_missing = (disaggvar_missing >0) 

save "Wallis_and_Futuna_LSMS_2019 with missing.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1

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

save "Wallis and Futuna_LSMS_2019_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

save "Wallis and Futuna_LSMS_2019_Cleaned_Household_Level_Data_Trimmed.dta", replace

su disability_any_hh disability_some_hh disability_atleast_hh


