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

use hhid  q02_09 food_coping attain hhid q02* q05_02_38 q05_02_13 q05_02_15 q05_02_03 q05_02_20 q05_02_09 q05_02_18 q05_02_19 q05_02_04 q05_02_01 q05_02_05 q05_02_02 q02_04 q02_03 q02_02 q02_07 q02_09 q02_10 q02_16 g* using "$PATH\raw\ Household_level_2015_16.dta", clear
save "$PATH\namibia_hh", replace

*no long lat data

use "$PATH\ind_level_tab.dta" , clear

merge m:1 hhid using  "namibia_hh.dta", gen(merge_hh)
drop if merge_hh==1

save "Namibia_HIES_2015_NotClean.dta", replace

********************************************

use "Namibia_HIES_2015_NotClean.dta", clear




***************
*IDs
***************
clonevar ind_weight = wgt_ind 
clonevar hh_weight = wgt_hh
gen hh_id = hhid
gen ind_id= hh_id + string(i_ln, "%02.0f")

gen country_dataset_year = 2015
gen sample_strata = stratum


gen country_name="Namibia"
gen country_abrev="NA"



*********************
label define REGION 1 "Karas" 2 "Erongo" 3 "Hardap" 4 "Kavango East" 5 "Kavango West" 6 "Khomas" 7 "Kunene" 8 "Ohangwena" 9 "Omaheke" 10 "Omusati" 11 "Oshana" 12 "Oshikoto" 13 "Otjozondjupa" 14 "Zambezi", replace

replace region = . if region ==14.5

clonevar admin1 = region
clonevar admin2 = constituency

gen female = 1 if q01_02==1
replace female = 0 if q01_02==2
tab q01_02 female

*area of residence
fre urbrur
gen urban_new = 1 if urbrur==1
replace urban_new = 0 if urbrur!=1 & !mi(urbrur)

label define URBAN 0 "Rural" 1 "Urban"
label val urban_new URBAN

tab urbrur urban_new, m 

clonevar age = q01_06_y
tab age

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65

fre q04_01 q04_02 q04_03 q04_04 q04_05 q04_06



clonevar seeing_diff_new = q04_01
clonevar hearing_diff_new = q04_02
clonevar mobility_diff_new = q04_03
clonevar cognitive_diff_new = q04_04
clonevar selfcare_diff_new = q04_05
clonevar comm_diff_new = q04_06

fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new
replace seeing_diff_new=. if !inlist(seeing_diff_new,1,2,3,4)
replace  cognitive_diff_new=.  if !inlist(cognitive_diff_new,1,2,3,4)
replace  selfcare_diff_new=.  if !inlist(selfcare_diff_new,1,2,3,4)
fre seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

tab func_difficulty,m
gen missing_func_difficulty = 1 if mi(func_difficulty)
replace missing_func_difficulty = 0 if !mi(func_difficulty) 

tab func_difficulty missing_func_difficulty , m

drop if age<15
fre age
fre urban_new



*overall
count
count if mi(func_difficulty) | mi(age) | mi(female) | mi(urban_new)  
*19 ~ <0.1%


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
gen everattended_new = 1 if q03_02==1
replace everattended_new = 0 if q03_02==2 
tab everattended_new q03_02, m
 
*literacy
fre q03_01
gen lit_new =  1 if q03_01==1
replace lit_new = 0 if q03_01==2
tab q03_01 lit_new,m

*school_new
gen school_new=1 if q03_03==1 
replace school_new=0 if q03_03==2
replace school_new=0 if q03_02==2 //those who never attended school coded as NOT IN SCHOOL
bro everattended_new school_new  q03_03 q03_04_mj age

*edattain
/*
edattain_new= coded 0 for niu, 9 for unknown 
=1 for less than primary  completed
=2 for primary completed
=3 for secondary completed
=4 for university completed
*/
tab q03_04_mn q03_04_mj 
fre q03_04_mn
gen edattain_new=1 if everattended_new==0 | q03_04_mj==1 |q03_04_mj==2 | (q03_04_mj==3 & q03_04_mn<23 )
replace edattain_new=2 if (q03_04_mj==3 & q03_04_mn==23) | q03_04_mj ==4 | (q03_04_mj==5 & q03_04_mn<33 )
replace edattain_new=3 if  (q03_04_mj==5 & q03_04_mn==33) | q03_04_mj == 6
replace edattain_new=4 if  q03_04_mj == 7 | q03_04_mj == 8 | q03_04_mj==9
tab edattain_new q03_04_mj,m

replace edattain_new = 1 if school_new == 1 & q03_09_mj==3
replace edattain_new = 2 if school_new == 1 & (q03_09_mj ==4|q03_09_mj==5)
replace edattain_new = 3 if school_new == 1 & (q03_09_mj ==6 | q03_09_mj == 7)
replace edattain_new = 4 if school_new ==1 & q03_09_mj ==8 | q03_09_mj==9

tab edattain_new, m

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

*epr
*In the past 7 days, did you do any work for pay or any payment in-kind (including paid domestic work) for at least one hour?
*In the past 7 days, did you do any kind of business or self-employed activity, big or small, for yourself or with  partners, or for a business owned by the household or any member, for at least one hour? 
*Even though you did not do any kind of work in the past 7 days, did you have work (not including farming), from which you were temporarily absent because of vacation, illness, layoff,  etc., and to which you will definitely return?
*In the past 7 days,  did you do any agricultural work on your own or household farm/ plot/ garden/ cattle post or kral, or help in growing farm produce or take care of your own or household livestock?
fre q06_02 q06_03 q06_04 

gen ind_emp = ( q06_02==1 | q06_03==1 | q06_04==1 )
replace ind_emp = 1 if q06_08 ==1 & (q06_09 ==3 | q06_09==4)
replace ind_emp = . if mi(q06_02) & mi(q06_03) & mi(q06_04)


*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24


*work_manufacturing=1 if manufacturing =0 otherwise 
*Seems like per ISIC classification - looking for documentation
*C= Manufacturing
*q06_27_mj1_1 codes =C  manufacturing as per the ISIC classifiction
*check q06_27_mj1_1 q06_27_mj2_1
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if q06_27_mj1_1=="C" & ind_emp==1
replace work_manufacturing=. if ind_emp==0


* women in managerial work
/*
Senior and middle management correspond to sub-major groups
11, 12 and 13 in ISCO-08 and sub-major groups 11 and 12 in ISCO-88. If statistics are not available disaggregated at the sub-major group level (two-digit level of ISCO), then major group 1 of ISCO-88 and ISCO-08 can be used as a proxy and the indicator would then refer only to total management (including
junior management).
*/
gen work_managerial = 0 if female==1 // denominator - all women
replace work_managerial = (inlist(q06_26_mj1_1,11,12,13))  if ind_emp==1 & female==1
replace work_managerial = . if female==0 

bro q06_26_mj1_1 work_managerial female q06_26_mj1_1 if female==1
*informal
*The numerator includes adults who are informal workers. 
*The denominator includes all adults age 15 and above.
*Informal workers include the self-employed, those who work for a microenterprise of five or fewer employees or in a firm that is unregistered, and those who have no written contract with their employers. Workers who produce goods for own and/or family consumption are included as informal workers. Additionally, family workers without pay are included as informal workers.
*However, unlike in SDG 8.3.1, we use all adults as a denominator as many individuals with disabilities are not employed (out of the labor force) and would otherwise not be captured in the denominator which would then be very small. 
gen work_informal = 0
replace work_informal = 1 if q06_03 ==1 | q06_04 ==1
*assumes that paid work is formal and self-employed or family business is informal, and other productive activities (trader, selling in the market, collecting wood or dung to sell, making handicrafts for sale, etc.?)

*social protection
*Did ..[NAME] receive any social welfare pensions or allowances in the past 12 months?
gen social_prot = 1 if q10_08==1
replace social_prot = 0 if q10_08==2



*ind_water (see description below) =1 with drink water  / piped water =0 no drink water / no piped water
gen ind_water= 1 if inlist(q02_10,1,2,3,4,5,6,8,10,15)
replace ind_water = 0 if inlist(q02_10,7,9,11,12,13,14)
tab q02_10 ind_water, m

*ind_toilet (see description below)	=1 with toilet (pit latrine, etc) =0 no toilet

gen ind_toilet = 1 if inlist(q02_16, 1, 2, 3, 6, 7)
replace ind_toilet = 0 if inlist(q02_16, 4, 5, 8, 9, 10, 11)
replace ind_toilet = 1 if q02_17==2 & ind_toilet==1 // not shared
replace ind_toilet = 0 if q02_17==1 //shared, regardless of facility
tab q02_16 ind_toilet, m 

*ind_electric	=1 if yes =0 otherwise
fre q02_09
gen ind_electric= (q02_09==1 | q02_09==9) if !mi(q02_09)
tab q02_09 ind_electric ,m

gen food_insecure = (q02_61==1) if !mi(q02_61)

*ind_cleanfuel (see description below of clean fuel)	=1 if good - NOT organic material =0 if bad - organic (dung, coal, etc)
gen ind_cleanfuel= (inlist(q02_07,1,2,3,9)) if !mi(q02_07)
tab q02_07 ind_cleanfuel,m

gen ind_floor = (q02_04 == 2 |  q02_04 == 7) if !mi(q02_04)
tab q02_04 ind_floor, m 

gen ind_roof = (inlist(q02_02,1,2,3,7,8,10)) if !mi(q02_02)
tab q02_02 ind_roof, m

gen ind_wall = (inlist(q02_03,1, 2, 7, 8)) if !mi(q02_03)
tab q02_03 ind_wall, m



gen ind_livingcond = (ind_floor==1 & ind_roof==1 & ind_wall==1)
replace ind_livingcond = . if (ind_floor==. & ind_roof==. & ind_wall==.)

**Houshold goods


gen ind_radio = (q05_02_13 > 0 & q05_02_13 <.) if !mi(q05_02_13)
replace ind_radio =. if q05_02_13==4800 | q05_02_13==31 //seems like typos
tab q05_02_13 ind_radio,m 

gen ind_tv = (q05_02_15 > 0 & q05_02_15 <.) if !mi(q05_02_15)
tab q05_02_15 ind_tv, m

gen ind_bike = (q05_02_05 > 0 &  q05_02_05 <. ) if !mi(q05_02_05)
tab q05_02_05 ind_bike, m

gen ind_autos= ((q05_02_01 > 0 & q05_02_01 <.) | (q05_02_03 > 0 &  q05_02_03 <.) ) if !mi(q05_02_01) | !mi(q05_02_03)
tab q05_02_01 ind_autos, m 

gen ind_motorcycle= (q05_02_04 > 0 & q05_02_04 <.) if !mi(q05_02_04 )
tab q05_02_04 ind_motorcycle, m

gen cell_new = (q05_02_19> 0 & q05_02_19<80 ) if !mi(q05_02_19) //seems like an outlier beyond 18 - only 0.10%)
tab q05_02_19 cell_new, m

gen ind_refrig= (q05_02_09 > 0 & q05_02_09 <.) if !mi(q05_02_09) 
replace  ind_refrig=. if q05_02_09==1800
tab q05_02_09 ind_refrig, m 

gen ind_phone = (q05_02_18 > 0 & q05_02_18<. ) if !mi(q05_02_18)
replace ind_phone =. if q05_02_18>5 //outliers
tab q05_02_18 ind_phone, m

gen ind_computer= ( q05_02_20 > 0 & q05_02_20 <.) if !mi(q05_02_20)
replace ind_computer = . if q05_02_20>7 //outliers
tab q05_02_20 ind_computer, m

	
egen ind_asset_ownership =rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer)



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

bys hhid: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)

*consumption -household level variable
egen total_consumption_yr = rowtotal(g01_food g02_tobacco g03_clothing g04_housing g05_furnishings g06_health g07_transport g08_communication g09_recreation)
sort hhid

gen health_exp_hh = g06_health / total_consumption_yr





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


replace admin1=. if admin1>14

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

save "${CLEAN}\Namibia_HIES_2015_Clean.dta" , replace
