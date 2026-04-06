/*
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/

Reference to appendix and paper:

For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).

Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478

Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com

Author: Kaviyarasan Patchaiappan

Suggested citation: Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478
*/

cd "D:\DDI\New Datasets\MLI_2021_EHCVM-2_v01_M_STATA14"
*****************Mali LSMS 2021************************************************
*****************Household data Clean & merge***********************************
use "ehcvm_conso_mli2021.dta",clear
bysort vague grappe menage : egen total_exp = total( depan )
gen exp_health = depan if coicop == 6 | inrange(codpr, 774,777)
bysort vague grappe menage: egen health_exp = total(exp_health)

duplicates drop vague grappe menage, force
save "health exp.dta",replace

use "s12_me_mli2021.dta", clear
 keep grappe menage vague s12q01 s12q02
 keep if inlist(s12q01, 16,19, 20, 28, 29, 30, 34, 35, 37)
 tab s12q01
  reshape wide s12q02 , i(grappe menage vague) j( s12q01 )

	label variable s12q0216 "refridge"
	label variable s12q0219 "radio"
	label variable s12q0220 "tv"
	label variable s12q0228 "car"
	label variable s12q0229 "motorcycle"
	label variable s12q0230 "bicycle"
	label variable s12q0234 "telephone"
	label variable s12q0235 "cell phone"
	label variable s12q0237 "computer"

save "assets.dta",replace

use "s14b_me_mli2021.dta", clear
keep grappe menage vague s14bq01 s14bq02
  reshape wide s14bq02 , i(grappe menage vague) j( s14bq01 )
save "shock.dta",replace

 use "s15_me_mli2021.dta", clear
 
 keep grappe menage vague s15q01 s15q02
  reshape wide s15q02 , i(grappe menage vague) j( s15q01 )
  drop if s15q021==.
save "social_prot.dta",replace

use "s11_me_mli2021.dta", clear


keep grappe menage vague s11q18 s11q19 s11q20 s11q26a s11q26b s11q37 s11q52__4 s11q52__5 s11q54 s11q55

merge 1:1 grappe menage vague using "assets.dta", generate(_merge_asset)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             6,143  (_merge_asset==3)
    -----------------------------------------*/

merge 1:1 grappe menage vague using "s08a_me_mli2021.dta", generate(_merge_food)

/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             6,143  (_merge_food==3)
    -----------------------------------------*/
merge 1:1 grappe menage vague using "shock.dta", generate(_merge_shock)
/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             6,143  (_merge_shock==3)
    -----------------------------------------*/	
	
merge 1:1 grappe menage vague using "health exp.dta", generate(_merge_health_exp)
/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             6,143  (_merge_health_exp==3)
    -----------------------------------------*/	

merge 1:1 grappe menage vague using "social_prot.dta", generate(_merge_social_prot)
/*  Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             6,143  (_merge_social_prot==3)
    -----------------------------------------*/	
drop _merge_asset _merge_food _merge_shock _merge_health_exp _merge_social_prot
save "Mali_LSMS_2021_HH.dta", replace
*************************************************************************************************************************************************
use "ehcvm_individu_mli2021",clear
rename numind membres__id
merge 1:1 grappe menage vague membres__id using "s04a_me_mli2021.dta",gen(_merge_s04a)

/*       Result                      Number of obs
    -----------------------------------------
    Not matched                         6,335
        from master                     6,335  (_merge_s04a==1)
        from using                          0  (_merge_s04a==2)

    Matched                            37,137  (_merge_s04a==3)
    -----------------------------------------
*/


count
merge 1:1 grappe menage vague membres__id using "s04b_me_mli2021.dta",gen(_merge_s04b)

/*      Result                      Number of obs
    -----------------------------------------
    Not matched                        28,867
        from master                    28,867  (_merge_s04b==1)
        from using                          0  (_merge_s04b==2)

    Matched                            14,605  (_merge_s04b==3)
    -----------------------------------------

*/
count
merge 1:1 grappe menage vague membres__id using "s03_me_mli2021.dta", gen(_merge_s03)
/*  
	Result                      Number of obs
    -----------------------------------------
    Not matched                            10
        from master                        10  (_merge_s03==1)
        from using                          0  (_merge_s03==2)

    Matched                            43,462  (_merge_s03==3)
    -----------------------------------------


*/
count

keep country year vague hhid grappe menage membres__id zae zaemil region prefecture commune milieu hhweight resid sexe age alfa scol educ_hi telpor internet s04q06 s04q07 s04q08 s04q09 s04q18a s04q18b s04q28a s04q28b s04q30b s04q29b s04q39 s03q41 s03q42 s03q43 s03q44 s03q45 s03q46 s03q32 _merge_s04a _merge_s04b _merge_s03

bysort hhid: gen hh_size = _N

save "Mali_LSMS_2021_Ind.dta", replace 

use "Mali_LSMS_2021_HH.dta",clear
merge 1:m grappe menage vague using "Mali_LSMS_2021_Ind.dta"

/*   Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            43,472  (_merge==3)
    -----------------------------------------


*/

save "Mali  LSMS 2021 raw .dta", replace 
use "Mali  LSMS 2021 raw .dta",clear
*keep if vague==1
drop if age<15

*********************************************************************************

********Country Name****************
gen country_name="Mali"
********Country Abrevation*********
gen country_abrev="ML" 

*********Country_dataset_year*******
gen country_dataset_year="Mali LSMS 2021-2022"


***Household Weight***

gen hh_weight= hhweight

***Individual Weight***

gen ind_weight=hhweight

*****Household and Individual Ids***********

gen hh_id= hhid
egen ind_id= concat(hhid membres__id), format(%25.0g) punct(_)

egen sample_strata=group(region milieu)
gen psu=grappe
*Urban/Rural

gen urban_new=1 if milieu==1
replace urban_new=0 if milieu==2


clonevar admin1=region 
clonevar admin2=prefecture  

*Gender

gen female= 1 if ( sexe ==2)
replace female=0 if ( sexe ==1)

*Age group

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65
replace age_group =. if age==.

*Difficulties

clonevar seeing_diff_new= s03q41 
replace seeing_diff_new=. if s03q41==5
clonevar hearing_diff_new= s03q42 
replace hearing_diff_new=. if s03q42==5
clonevar mobility_diff_new= s03q43 
replace mobility_diff_new=. if s03q43==5
clonevar cognitive_diff_new= s03q44 
replace cognitive_diff_new=. if s03q44==5
clonevar selfcare_diff_new= s03q45 
replace selfcare_diff_new=. if s03q45==5
clonevar comm_diff_new= s03q46
replace comm_diff_new=. if s03q46==5

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

gen lit_new=1 if alfa==1
replace lit_new=0 if alfa==0

*Everattended School

gen everattended_new=(educ_hi>1)
replace everattended_new=. if educ_hi==.

*Education - completed primary school
*This variable was created for computing multidimensional poverty
gen ind_atleastprimary_all = (educ_hi>=3)
replace ind_atleastprimary_all =. if (educ_hi==.)

*Atleastprimary education

gen ind_atleastprimary = (educ_hi>=3) if age>=25
replace ind_atleastprimary =. if (educ_hi==.)

*Atleastsecondary education

gen ind_atleastsecondary = (educ_hi>=6) if age>=25
replace ind_atleastsecondary =. if (educ_hi==.)

*Mobile use
gen mobile_own=(telpor==1)

*Employment
gen ind_emp=( s04q06==1 | s04q07==1 | s04q08==1 | s04q09==1)
replace ind_emp=. if s04q06==. & s04q07==. & s04q08==. & s04q09==.

*Female at Managerial Work

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & (s04q29b==1 | s04q18b==1) & female==1
replace work_managerial2= . if (ind_emp==. & s04q29b==. & s04q18b==. ) 

*Manufacturing Worker

gen work_manufacturing=cond(mi(s04q30b),.,cond(s04q30b==3,1,0))
replace work_manufacturing=1 if s04q18a==3
replace work_manufacturing=. if ind_emp==0 

*Informal Work

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & (inlist(s04q28a, 1,2,4,5) | inlist(s04q28b, 1,2,4,5) | inlist(s04q39, 4,5,7,8,9,10))
replace work_informal2=. if ind_emp==. & s04q28a==. & s04q28b==. & s04q39==.

* Youth idle

gen school_new=(scol==1)
replace school_new=. if scol==.

gen youth_idle=1 if (school_new==0 & ind_emp==0)
replace youth_idle=0 if (school_new==1 | ind_emp==1)
replace youth_idle=. if (school_new==. & ind_emp==.)
replace youth_idle=. if age>24

gen ind_wall=inlist(s11q18, 1,2)
gen ind_roof=inlist(s11q19, 1,2,3)
gen ind_floor=inlist(s11q20, 1,2)

*Living conditions

gen ind_livingcond =(ind_floor==1&ind_roof==1&ind_wall==1)
replace ind_livingcond=. if ind_floor==. & ind_roof==. & ind_wall==.

*Electricity

gen ind_electric=inlist( s11q37, 1, 6)

*Cooking fuel

gen ind_cleanfuel=(s11q52__4==1)
replace ind_cleanfuel=1 if s11q52__5==1

*Household Assest

*Radio
gen ind_radio=(s12q0219==1)
*Phone
gen ind_phone=(s12q0234==1)

*Cell
gen cell_new=(s12q0235==1)

*Television
gen ind_tv=(s12q0220==1) 

*Computer
gen ind_computer=(s12q0237==1)

*Refrig
gen ind_refrig=(s12q0216==1)

*Motorcycle
gen ind_motorcycle=(s12q0229==1)

*Bike
gen ind_bike=(s12q0230==1)

*Autos
gen ind_autos=(s12q0228==1)

*Assests

egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_autos ind_computer ind_bike ind_motorcycle)


*Water

gen ind_water = inlist(s11q26a, 1,2,3,4,7,8,9,10,11,14,15)
replace ind_water = 1 if inlist(s11q26b, 1,2,3,4,7,8,9,10,11,14,15)

*Sanitation

gen toilet_use=inlist(s11q54, 1, 2, 3, 4, 5, 6, 7, 8)
replace toilet_use=. if s11q54==.

gen ind_toilet=(toilet_use==1 & s11q55==2 )

*Food insure

gen food_insecure=( s08aq01==1 | s08aq02==1 | s08aq03==1 | s08aq04 ==1 | s08aq05 ==1 | s08aq06 ==1 | s08aq07 ==1 | s08aq08 ==1 )
replace food_insecure=. if (s08aq01>=98 & s08aq02>=98 & s08aq03>=98 & s08aq04>=98 & s08aq05>=98 & s08aq06>=98 & s08aq07>=98 & s08aq08>=98)
replace food_insecure=. if (s08aq01==. & s08aq02==. & s08aq03==. & s08aq04==. & s08aq05==. & s08aq06==. & s08aq07==. & s08aq08==.)

*Shock any

gen shock_any = 0
local shockvars s14bq02101 s14bq02102 s14bq02103 s14bq02104 s14bq02105 ///
               s14bq02106 s14bq02107 s14bq02108 s14bq02109 s14bq02110 ///
               s14bq02111 s14bq02112 s14bq02113 s14bq02114 s14bq02115 ///
               s14bq02116 s14bq02117 s14bq02118 s14bq02119 s14bq02120 ///
               s14bq02121 s14bq02122

foreach var of local shockvars {
    replace shock_any = 1 if `var' == 1
	replace shock_any = . if `var' == .
}

gen health_exp_hh=( health_exp /total_exp)

*health insurance

gen health_insurance=(s03q32==1)
replace health_insurance=. if s03q32==.

*social protection

gen social_prot=inlist(1, s15q021, s15q022, s15q023, s15q024, s15q025, s15q026, s15q027, s15q028, s15q029, s15q0210, s15q0211)
replace social_prot=. if inlist(., s15q021, s15q022, s15q023, s15q024, s15q025, s15q026, s15q027, s15q028, s15q029, s15q0210, s15q0211)

*alone

	gen alone=(hh_size==1)

*Multidimensional poverty 	
*if observation has labor information labor_tag==1, otherwise ==0
gen labor_tag=1 if ind_emp!=.
replace labor_tag=0 if ind_emp==.

gen deprive_educ=cond(mi(ind_atleastprimary_all),.,cond(ind_atleastprimary_all==0,0.33,0)) if labor_tag==0
replace deprive_educ=cond(mi(ind_atleastprimary_all),.,cond(ind_atleastprimary_all==0,0.25,0))  if labor_tag==1

gen deprive_work=.	if	labor_tag==0
replace deprive_work=cond(mi(ind_emp),.,cond(ind_emp==0,0.25,0))  if labor_tag==1		

gen deprive_health_water=cond(mi(ind_water),.,cond(ind_water==0,1,0))
	
gen deprive_health_sanitation=cond(mi(ind_toilet),.,cond(ind_toilet==0,1,0))

gen deprive_sl_electricity=cond(mi(ind_electric),.,cond(ind_electric ==0,1,0))

gen deprive_sl_fuel=cond(mi(ind_cleanfuel),.,cond(ind_cleanfuel==0,1,0))

gen deprive_sl_housing=cond(mi(ind_livingcond),.,cond(ind_livingcond==0,1,0))

gen deprive_sl_asset = 0
replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle) < 2) & ind_autos==0
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
replace deprive_health=(1/missing_health)*0.25*health_temp if labor_tag==1 

gen deprive_sl=(1/missing_sl)*0.33*sl_temp if  labor_tag==0
replace deprive_sl=(1/missing_sl)*0.25*sl_temp if  labor_tag==1 

gen mdp_score=cond(mi(deprive_educ)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_health+deprive_sl) if  labor_tag==0
replace mdp_score=cond(mi(deprive_educ)|mi(deprive_work)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_work+deprive_health+deprive_sl) if  labor_tag==1 


gen ind_mdp=cond(mi(mdp_score),.,cond((labor_tag==1 &mdp_score>0.25)|(labor_tag==0 &mdp_score>0.33),1,0))


save "Mali_LSMS_2021.dta",replace 


egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new cognitive_diff_new mobility_diff_new selfcare_diff_new comm_diff_new)
*change domain
gen ind_func_diff_missing= (func_diff_missing==6) 
*change domain
egen disaggvar_missing = rowmiss(female age urban_new)

gen ind_disaggvar_missing = (disaggvar_missing >0) 

save "Mali_LSMS_2021 with missing.dta", replace

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

save "Mali_LSMS_2021_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

save "Mali_LSMS_2021_Cleaned_Household_Level_Data_Trimmed.dta", replace

su disability_any_hh disability_some_hh disability_atleast_hh

