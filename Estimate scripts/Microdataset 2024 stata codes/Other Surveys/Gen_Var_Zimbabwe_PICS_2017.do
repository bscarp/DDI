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
use "individual_final.dta" ,clear
merge m:1  hid  using "household_final_1.dta", gen(merge_household)
merge m:1    hid  using "household_final_3_nonfoodexp.dta", gen(merge_exp_nonfood)
merge m:1    hid  using "household_final_4_poverty.dta", gen(merge_poverty)	

save "Zimbabwe_PICS_2017_NotClean", replace
**************************************
use  "Zimbabwe_PICS_2017_NotClean", clear


gen country_name="Zimbabwe"
gen country_abrev="ZW"

gen hh_id = string(hid, "%05.0f")
gen ind_id= hh_id + string(line_no, "%02.0f")

gen country_dataset_year = 2017
clonevar admin1 = province
clonevar admin2 = district
gen hh_weight = wt
gen ind_weight = wt
 
gen sample_strata = district
gen psu = group(wt)

 
gen female = 1 if hhc_003  == 2 
replace female = 0 if hhc_003  ==1
tab hhc_003  female, m

*age - it's not a discrete variable, some ages are averages, 
gen age = hhc_004


*area of residence -

fre  urban
clonevar urban_new = urban
tab urban urban_new, m




drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65 & !mi(age)


clonevar seeing_diff_new = hea_087
clonevar hearing_diff_new = hea_089

gen  mobility_diff_new = hea_086
recode mobility_diff_new (3=2) (4=3) (5=4)
tab hea_086 mobility_diff_new,m

clonevar cognitive_diff_new = hea_090
clonevar selfcare_diff_new = hea_095
clonevar comm_diff_new = hea_088


fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new comm_diff_new selfcare_diff_new

*no selfcare_diff_new
egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new  comm_diff_new selfcare_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m

count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  
* ~.5%


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
gen everattended_new = (edu_020 ==2 | edu_020 ==3) if !mi(edu_020)
tab edu_020 everattended_new , m
 
*lit new


tab edu_020 edu_021,m
*school_new
gen school_new=1 if edu_021==1 
replace school_new=0 if edu_021	==2
replace school_new=0 if (edu_020==1 |edu_020==3) //those who never attended school AND left school
tab school_new everattended_new, m

fre edu_023
fre edu_039

*collapsed
*assume that primary 1-7 is completed
gen edattain_new = 1 if everattended_new==0 |edu_039 ==1 |edu_039 ==2
replace edattain_new = 1 if edu_020==2 & (edu_023==1 | edu_023==2)

replace edattain_new = 2 if edu_039==3 |edu_039==4 
replace edattain_new = 2 if edu_020==2 & edu_023==3 //in school

replace edattain_new = 3 if edu_039==5
replace edattain_new = 3 if edu_020==2 & edu_023==5 //in school

replace edattain_new = 4 if edu_039==6 //completed



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
gen ind_emp = (emp_044==1|emp_045==1|emp_046==1|emp_047==1)
replace ind_emp = . if mi(emp_044) & mi(emp_045) & mi(emp_046) & mi(emp_047)


*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24



*work_manufacturing=1 if manufacturing =0 otherwise 
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if emp_061==3 & ind_emp==1
replace work_manufacturing=. if ind_emp==0


* women in managerial work
/*
Senior and middle management correspond to sub-major groups
*/
*included managers and supervisors, legislative officials, leaders
fre emp_053
gen work_managerial = 0 if female==1 // denominator - all women
replace work_managerial = (inlist(emp_053,11,12,13,14))  if ind_emp==1 & female==1
replace work_managerial = . if female==0 | emp_053==97 //not economically active



*informal
*The numerator includes adults who are informal workers. 
*The denominator includes all adults age 15 and above.
*Informal workers include the self-employed, those who work for a microenterprise of five or fewer employees or in a firm that is unregistered, and those who have no written contract with their employers. Workers who produce goods for own and/or family consumption are included as informal workers. Additionally, family workers without pay are included as informal workers.
*However, unlike in SDG 8.3.1, we use all adults as a denominator as many individuals with disabilities are not employed (out of the labor force) and would otherwise not be captured in the denominator which would then be very small. 
gen work_informal = 0
replace work_informal = 1 if emp_046 ==1 | emp_047 ==1 // worked on own or family farm / worked unpaid for household
replace work_informal = 1 if inlist(emp_055, 2, 4, 5, 6)
replace work_informal = 1 if (emp_056 ==2 | emp_056==3) //oral or no contract
replace work_informal = 1 if emp_065==2 //less than 10 employees in establishment
replace work_informal = 1 if emp_066==4 // neither licensed nor unregistered
tab work_informal

*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water

gen ind_water= (inlist(hse_128a, 1, 2, 3, 4)) if !mi(hse_128a)
tab hse_128a ind_water, m

*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet
fre  hse_142
gen ind_toilet = ( inlist(hse_139, 1, 2, 3, 4) ) if !mi(hse_139)
replace ind_toilet = 1 if  ind_toilet ==1 & hse_142==2 // not shared
replace ind_toilet = 0 if hse_142==1 //shared, regardless of facility
tab hse_139 ind_toilet, m 

*ind_electric	=1 if yes =0 otherwise
*among those who said they have access to electricity, only yes if they answered national, local grid, and solar home system
fre hse_118 hse_120
gen ind_electric=(hse_118==1) if !mi(hse_118)
replace ind_electric =0 if !inlist(hse_120, 1, 2, 4) & hse_118==1 & !mi(hse_120)
tab hse_118 ind_electric ,m


*ind_cleanfuel (see description below of clean fuel)	=1 if good - NOT organic material =0 if bad - organic (dung, coal, etc)
gen ind_cleanfuel= (inlist(hse_125,5, 13, 14,15)) if !mi(hse_125)
tab hse_125 ind_cleanfuel,m

*finsecure_new	-
*shock_new	- 



gen ind_wall = (inlist(hse_116, 8, 9, 10, 11, 12)) if !mi(hse_116)
replace ind_wall = . if hse_116==99
tab hse_116 ind_wall, m 

gen ind_roof = (inlist(hse_115, 7 ,8, 9, 10)) if !mi(hse_115)
replace ind_roof =. if hse_115==99
tab hse_115 ind_roof, m

gen ind_floor = (inlist(hse_114, 4, 5, 6 ,7 ,8)) if !mi(hse_114)
replace ind_floor = . if hse_114==99 | hse_114==0
tab hse_114 ind_floor, m



gen ind_livingcond = (ind_floor==1 & ind_roof==1 & ind_wall==1)
replace ind_livingcond = . if (ind_floor==. & ind_roof==. & ind_wall==.)



**Houshold goods


gen ind_radio = (hse_144_9==1) if !mi(hse_144_9)
tab hse_144_9 ind_radio,m 

gen ind_tv = (hse_144_5==1) if !mi(hse_144_5)
tab hse_144_5 ind_tv, m

gen ind_bike = (hse_144_4==1) if !mi(hse_144_4)
tab hse_144_4 ind_bike, m

gen ind_autos= (hse_144_1==1 ) if !mi(hse_144_1)
tab hse_144_1 ind_autos, m 

gen ind_motorcycle= (hse_144_2==1) if !mi(hse_144_2 )
tab hse_144_2 ind_motorcycle, m

gen cell_new = (hse_144_12==1) if !mi(hse_144_12)
tab hse_144_12 cell_new, m

gen ind_refrig= (hse_144_13==1) if !mi(hse_144_13) 
tab hse_144_13 ind_refrig, m 

gen ind_phone = (hse_144_11==1 ) if !mi(hse_144_11)
tab hse_144_11 ind_phone, m

gen ind_computer= (hse_144_10==1) if !mi(hse_144_10)
tab hse_144_10 ind_computer, m

	
egen ind_asset_ownership =rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer)


*Has anyone in the household during the (last) month received any incomes, transfers or remittances in cash or kind? Which person and how much
gen social_prot  =0
replace social_prot = 1 if i_723 >0 & i_723<.
replace social_prot = 1 if i_724 >0 & i_724<.
replace social_prot = 1 if i_725 >0 & i_725<.
replace social_prot = 1 if i_726 >0 & i_726<.
replace social_prot = 1 if i_727 >0 & i_727<.
replace social_prot = 1 if i_728 >0 & i_728<.	
replace social_prot = 1 if i_729 >0 & i_729<.

replace social_prot = 1 if i_730 >0 & i_730<.
replace social_prot = 1 if i_731 >0 & i_731<.
replace social_prot = 1 if i_732 >0 & i_732<.
replace social_prot = 1 if i_733 >0 & i_733<.
replace social_prot = 1 if i_734 >0 & i_734<.
replace social_prot = 1 if i_735 >0 & i_735<.
replace social_prot = 1 if i_736 >0 & i_736<.
replace social_prot = 1 if i_737 >0 & i_737<.
replace social_prot = 1 if i_738 >0 & i_738<.
replace social_prot = 1 if i_739 >0 & i_739<.

replace social_prot = 1 if i_740 >0 & i_740<.
replace social_prot = 1 if i_741 >0 & i_741<.
replace social_prot = 1 if i_742 >0 & i_742<.
replace social_prot = 1 if i_743 >0 & i_743<.
replace social_prot = 1 if i_744 >0 & i_744<.
replace social_prot = 1 if i_745 >0 & i_745<.
replace social_prot = 1 if i_746 >0 & i_746<.


tab social_prot





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


codebook pov_totcons pov_hlthexp

bro pov_hlthmed- pov_hlthoth pov_hlthexp
codebook pov_totcons pov_hlthexp

gen health_exp_hh = pov_hlthexp/pov_totcons
su health_exp_hh

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

save "${CLEAN}\Zimbabwe_PICS_2017_Clean.dta" , replace
