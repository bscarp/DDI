/*
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/

Reference to appendix and paper:

For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).

Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478

Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com

Author: Kaviyarasan Patchaiappan

Suggested citation: Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478
*/

clear all

global PATH "G:\My Drive\3 Work\Misc\Zimbabwe PICS 2017\"
global CLEAN "C:\Users\Jaclyn Yap\Desktop\WB_2024\Clean"

cd "$PATH"
use "individual_final.dta" ,clear
merge m:1  hid  using "household_final_1.dta", gen(merge_household)



/*
 
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                           136,770  (merge_household==3)
    -----------------------------------------

*/

	
merge m:1    hid  using "household_final_3_nonfoodexp.dta", gen(merge_exp_nonfood)

/*
   Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                           136,770  (merge_exp_nonfood==3)
    -----------------------------------------

*/
merge m:1    hid  using "household_final_4_poverty.dta", gen(merge_poverty)	

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                           136,770  (merge_poverty==3)
    -----------------------------------------

*/


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
 
 
gen female = 1 if hhc_003  == 2 
replace female = 0 if hhc_003  ==1
tab hhc_003  female, m

*age - it's not a discrete variable, some ages are averages, 
gen age = hhc_004


*area of residence -

fre  urban
clonevar urban_new = urban
tab urban urban_new, m

gen sample_strata = district
gen psu = group(wt)


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

	gen disability_alot=(func_difficulty==3)
	replace disability_alot=. if func_difficulty==.

	gen disability_unable=(func_difficulty==4)
	replace disability_unable=. if func_difficulty==.

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

replace edattain_new = 2 if edu_039==3 
replace edattain_new = 2 if edu_020==2 & edu_023==3 //in school

replace edattain_new = 3 if edu_039==4 | edu_039==5
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
*fre hh_e19b
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
*tab q05_02_15 ind_tv, m

gen ind_bike = (hse_144_4==1) if !mi(hse_144_4)
tab hse_144_4 ind_bike, m

gen ind_autos= (hse_144_1==1 ) if !mi(hse_144_1)
tab hse_144_1 ind_autos, m 

gen ind_motorcycle= (hse_144_2==1) if !mi(hse_144_2 )
*tab q05_02_04 ind_motorcycle, m

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
replace social_prot = 1 if i_745 >0 & i_745<.


tab social_prot

/*gen social_prot  =0
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
replace social_prot = 1 if i_746 >0 & i_746<.*/


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
gen disability_none_hh = (disability_any_hh==0 ) if !mi(func_difficulty_hh)

	gen disability_nonesome_hh = (disability_none_hh==1|disability_some_hh==1)
	
	gen disability_alot_hh=(func_difficulty_hh==3)
	replace disability_alot_hh=. if func_difficulty_hh==.
	
	gen disability_unable_hh=(func_difficulty_hh==4)
	replace disability_unable_hh=. if func_difficulty_hh==.

codebook pov_totcons pov_hlthexp

bro pov_hlthmed- pov_hlthoth pov_hlthexp
codebook pov_totcons pov_hlthexp

gen health_exp_hh = pov_hlthexp/pov_totcons
su health_exp_hh



*bysort hh_id: gen hh_size= _N
gen overcrowd=hhsize/hse_117
gen alone=(hhsize==1)
replace alone=. if hhsize==.
gen not_owned_hh=( hse_112>=3)
replace not_owned_hh=. if hse_112==.
*save "D:\DDI\New Indicator\Zimbabwe\Zimbabwe_PICS_2017_NotClean.dta", replace

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


save "D:\DDI\New Indicator\Zimbabwe_PICS_2017_Clean.dta",replace
duplicates drop hh_id, force
save "D:\DDI\New Indicator\ZW_HH.dta",replace


*save "${CLEAN}\Zimbabwe_PICS_2017_Clean.dta" , replace
