/*******************************************************************************
******************Bangladesh HIES 2016 ********************************************
********************************************************************************
Author: Jaclyn Yap
Reference: DSE
Website:
*******************************************************************************/
global PATH "C:\Users\Jaclyn Yap\Desktop\WB_2024\Bangladesh\Bangladesh\BGD_2016_HIES_v01_M_Stata\" 
global CLEAN "C:\Users\Jaclyn Yap\Desktop\WB_2024\Clean"

cd "$PATH"

/*

*HH_SEC_1A.dta
indid hhid hhwgt 
stratum
psu

adm1 division_code
 adm2 zila_code
 

*HH_SEC_1B.dta
s1bq03 s1bq01 s4aq07 s4aq08

*HH_SEC_1C.dta
s1cq01

* HH_SEC_2A.dta
s2aq03 s2aq04

* HH_SEC_2B.dta
s2bq01 s2bq08q

* HH_SEC_4: only keep the first activity!!
activity s4aq01a s4aq01b s4aq01c


* HH_SEC_6A.dta
s4aq01b s4aq01c

* HH_SEC_6B.dta
* Did you experience [shock] during the past 12 months?
s6bq02

*HH_SEC_9E.dta
s9eq00 s9eq01b
*/

use "HH_SEC_1A.dta", clear
unique hhid indid
bys hhid indid: gen dup_ind1 = (_n>1) //indicator which tells which one is the duplicate record
*20 duplicate ids 
*individually inspected that relevant variables are the same
drop if indid==.
drop if dup_ind1 ==1 // duplicates
drop dup_ind1
unique hhid indid


*Note: this dataset has more respondents than those in the roster in HH_SEC_1A with functional difficulty. 
*exclude those in HH_SEC_1B that is not in the roster

merge 1:1 hhid indid using "HH_SEC_1B", keepusing(s1bq01 s1bq02 s1bq03 s1bq04) gen(merge_1b)
/*
  Result                           # of obs.
    -----------------------------------------
    not matched                            73
        from master                        51  (merge_1b==1)
        from using                         22  (merge_1b==2)

    matched                           185,997  (merge_1b==3)
    -----------------------------------------


*/

drop if merge_1b ==2

merge m:1 hhid using "BD_social_prot.dta", gen(merge_socialprot_1C)

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                            85
        from master                        85  (merge_socialprot_1C==1)
        from using                          0  (merge_socialprot_1C==2)

    matched                           185,963  (merge_socialprot_1C==3)
    -----------------------------------------


*/

merge 1:1 hhid indid using "BD_education", gen(merge_education_2A2B)
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                        17,919
        from master                    17,916  (merge_education_2A2B==1)
        from using                          3  (merge_education_2A2B==2)

    matched                           168,132  (merge_education_2A2B==3)
    ----------------------------------

*/
drop if merge_education_2A2B==2

merge 1:1 hhid indid using "BD_labor", gen(merge_labor)
/*


    Result                           # of obs.
    -----------------------------------------
    not matched                       129,896
        from master                   129,845  (merge_labor==1)
        from using                         51  (merge_labor==2)

    matched                            56,206  (merge_labor==3)
    -----------------------------------------
*/

drop if merge_labor==2


merge m:1 hhid using "HH_SEC_6A", gen(merge_6a)
/*
 
    Result                           # of obs.
    -----------------------------------------
    not matched                             7
        from master                         0  (merge_6a==1)
        from using                          7  (merge_6a==2)

    matched                           186,048  (merge_6a==3)
    --------------------------------------
 
*/

drop if merge_6a==2

merge m:1 hhid using BD_shock, gen(merge_BD_shock)
/*


    Result                           # of obs.
    -----------------------------------------
    not matched                             7
        from master                         0  (merge_BD_shock==1)
        from using                          7  (merge_BD_shock==2)

    matched                           186,048  (merge_BD_shock==3)
    -----------------------------------------



*/
drop if merge_BD_shock==2

merge m:1 hhid using BD_assets, gen(merge_BD_assets)
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                           696
        from master                       695  (merge_BD_assets==1)
        from using                          1  (merge_BD_assets==2)

    matched                           185,353  (merge_BD_assets==3)
    -----------------------------------------

*/

drop if merge_BD_assets==2

merge m:1 hhid using "poverty_indicators2016.dta", keepusing(member fexp hsvalhh nfexp2 consexp2 pcexp) gen(merge_expenditures)
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           933
        from master                       933  (_merge==1)
        from using                          0  (_merge==2)

    matched                           185,115  (_merge==3)
    -----------------------------------------

*/

merge m:1 hhid using BD_healthexpense, gen(merge_health_expense)
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                           243
        from master                       243  (merge_health_expense==1)
        from using                          0  (merge_health_expense==2)

    matched                           185,805  (merge_health_expense==3)
    -----------------------------------------

*/

save "Bangladesh_HIES_2016_NotClean.dta", replace

**************************

use "Bangladesh_HIES_2016_NotClean.dta", clear

gen country_name="Bangladesh"
gen country_abrev="BD"
tostring(hhid), gen(hh_id)
gen  ind_id = string(hhid*100+indid, "%10.0g")
gen country_dataset_year = 2016
gen admin1 = division_code
gen admin2 = zila_code

gen hh_weight = hhwgt 
gen ind_weight = hhwgt 
gen sample_strata = stratum
*********************

gen female = 1 if s1aq01 == 2 
replace female = 0 if s1aq01 ==1
tab s1aq01 female,m

clonevar age = s1aq03
tab age

*area of residence
gen urban_new = 1 if  urbrural  ==2 
replace urban_new  = 0 if urbrural   ==1
tab urbrural urban_new, m

label define URBAN 0 "Rural" 1 "Urban"
label val urban_new URBAN

tab urbrur urban_new, m 


drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65

*functional difficulty
fre s1aq12 s1aq13 s1aq14 s1aq15 s1aq16 s1aq17



clonevar seeing_diff_new = s1aq12
clonevar hearing_diff_new = s1aq13
clonevar mobility_diff_new = s1aq14
clonevar cognitive_diff_new = s1aq15
clonevar selfcare_diff_new = s1aq16
clonevar comm_diff_new = s1aq17


fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new
replace hearing_diff_new = . if hearing_diff_new ==5

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m

count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  
*15 ~ <0.01%



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




*everattended_new
gen everattended_new = 1 if s2aq03==1
replace everattended_new = 0 if s2aq03==2 
tab everattended_new s2aq03, m

*lit_new
fre s2aq02 s2aq01

gen lit_new = (s2aq01==1 & s2aq02==1)
replace lit_new = . if s2aq01==0 |s2aq02 ==0 |s2aq01==.|s2aq02==.
tab2 lit_new  s2aq01 s2aq02,m

*school_new
gen school_new = 1 if s2bq01 ==1 
replace school_new =0 if s2bq01 ==2
replace school_new =0 if everattended_new==0
tab s2bq01 school_new ,m


*edattain
*s2aq04 is missing if ever attended school is NO -  43,095 observations
fre s2aq04
gen edattain_new=1 if everattended_new==0 | s2aq04<5  //class 1 to 5
replace edattain_new=2 if s2aq04 ==5 | ( s2aq04>5 & s2aq04<11 ) //6 to 11
replace edattain_new=3 if  s2aq04 ==11 | s2aq04 ==12
replace edattain_new=4 if  s2aq04>12 & s2aq04<.
replace edattain_new = . if s2aq04 ==19 //others specify
tab s2aq04 edattain_new ,m


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

*Employment
*redefined empstat_new

gen ind_emp = (s1bq01==1)
replace ind_emp = . if s1bq01==. | s1bq01==0 // ==0 is a typo
tab s1bq01 ind_emp,m

*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24

recode shock_any (2=0)

*informal
*The numerator includes adults who are informal workers. 
*The denominator includes all adults age 15 and above.
*Informal workers include the self-employed, those who work for a microenterprise of five or fewer employees or in a firm that is unregistered, and those who have no written contract with their employers. Workers who produce goods for own and/or family consumption are included as informal workers. Additionally, family workers without pay are included as informal workers.
*However, unlike in SDG 8.3.1, we use all adults as a denominator as many individuals with disabilities are not employed (out of the labor force) and would otherwise not be captured in the denominator which would then be very small. 
gen work_informal = 0
replace work_informal = 1 if s4aq06 ==1  & inlist(s4aq07,1,2) //agriculture and day laborer or self-employed *formal if employer or employee
replace work_informal  = 1 if s4aq06==2 & inlist(s4aq07,1,2) //non-ag and day laborer or self-employed *formal if employer or employee
replace work_informal  = 1 if s4bq06==8 | s4bq06==9 //work for household or other(specify) regardless if agriculture or non-ag
tab work_informal ind_emp,m 

*asset Whether name has a mobile
gen mobile_own = 1 if s1aq10 == 1
replace mobile_own = 0 if s1aq10 == 2
tab s1aq10 mobile_own, m

egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_motorcycle ind_autos ind_computer ind_bike)


gen ind_electric= (s6aq17==1 ) if !mi(s6aq17)
replace ind_electric = . if s6aq17==3
tab s6aq17 ind_electric ,m

gen ind_cleanfuel= .

gen ind_floor = .


gen ind_roof = (inlist(s6aq08,2,3,4)) if !mi(s6aq08)
replace ind_roof = . if s6aq08==6 |s6aq08==9
tab s6aq08 ind_roof, m

gen ind_wall = (s6aq07==5) if !mi(s6aq07)
replace ind_wall = . if s6aq07==7
tab s6aq07 ind_wall, m

gen ind_livingcond = (ind_floor==. & ind_roof==1)
replace ind_livingcond = . if (ind_floor==. & ind_roof==.)


fre s6aq12 


*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water
gen ind_water= (inlist(s6aq12,1,2)) if !mi(s6aq12)
tab s6aq12 ind_water, m
*since well is not specified whether it is protected or unprotected, it is assumed as unprotected. 

*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet
*kancha == mud - alternatively, it seems, it is called kutcha (mud built). In the journal article, kancha (mud) toilet is negative response - so i'm assuming this is not sanitary
*https://bmcwomenshealth.biomedcentral.com/articles/10.1186/s12905-022-01665-6
*from IPUMS international, bangladesh census, categories are as follows, so water and non-water sealed are considered as sanitary options
/*
Bangladesh 2011 — source variable BD2011A_TOILET — Toilet facilities
Questionnaire form view entire document:  text  image

9. Toilet facilities
[] Sanitary (with water seal)
[] Sanitary (no water seal)
[] Non-sanitary
[] None
*/
gen ind_toilet = 1 if inlist(s6aq10,1,2,3) 
replace  ind_toilet = 0 if s6aq10 ==4 | s6aq10==5 | s6aq10==6 
replace ind_toilet = 1 if s6aq11 ==2 & ind_toilet==1 //facility is improved and not shared
replace ind_toilet = 0 if s6aq11==1 // whether or not the facility is improved, recategorize as not improved (=0) if toilet is shared
tab s6aq11 ind_toilet, m 
tab s6aq10 ind_toilet if s6aq11==2 , m 





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

replace deprive_sl_asset = 1 if ( (ind_radio + ind_tv + ind_refrig + ind_bike + ind_motorcycle <2) & ind_autos==0)

replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.


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


**************
replace health_exp_hh= 0  if health_exp_hh<0
*3 changes
bys hhid: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)



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


order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ind_weight hh_weight sample_strata psu /* demographics*/ female urban_new age  age_group /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty	disability_any disability_some disability_atleast disability_none disability_nonesome	seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any 		seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some 		seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot 	/*education*/	everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 



save "${CLEAN}\Bangladesh_HIES_2016_Clean.dta" , replace

