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

use "Labourforcesurvey_2018.dta", clear


save "C:\Users\Jaclyn Yap\Desktop\WB_2024\Rwanda_LFS\Rwanda_LFS_2018_NotClean.dta"

*geographical var
cd "$PATH"
use "Rwanda_LFS_2018_NotClean.dta", clear


***************
*IDs
***************
gen country_name="Rwanda"
gen country_abrev="RW"
gen country_dataset_year = 2018
tostring pid, replace
tostring phase, gen(round)
gen hh_id = substr(pid, 1, (strlen(pid)-2)) + "0" +round
tostring PID, gen(ln_no) format(%2.0f)
gen ind_id = hh_id + substr(pid, -2, 2)
gen ind_weight = weight2
gen hh_weight = weight2
gen psu = PSU_NO
egen sample_strata = strata2 = group(code_dis ur)
clonevar admin1 = province
clonevar admin2 = code_dis


unique ind_id

fre female
tab A01 female
bro hh_id ind_id pid

*area of residence
gen urban_new = 1 if RESIDENCEA=="U"
replace urban_new = 0 if RESIDENCEA=="R"

label define URBAN 0 "Rural" 1 "Urban"
label val urban_new URBAN

gen age = A04
drop if age<15

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30 & age<=44
replace age_group = 3 if age>=45 & age<=64
replace age_group = 4 if age>=65


 
*impute missing data (code from Rwanda LFS statistician) - see pdf of email:
*begin
bro A06-A11
		*Disability
		cap drop tempdis
		egen tempdis = anymatch(A06-A11), val(2,3,4)
		replace tempdis = . if A04<5

		cap drop temp2
		gen temp2 = 1 if A06 ==1 & A07 ==1 & A08==1 & A09==1 &  A10==1 &  A11==1
		replace temp2 = . if A04<5

		 *HH WITHOUT DISABLITY
		cap drop HHnodis
		bysort HHID: egen HHnodis = sum(tempdis)
		foreach var of varlist (A06-A11){
		recode `var'(.=1) if HHnodis==0
		}

		tab A06

		* replace to missing value functional difficulty among those under age five
		foreach var of varlist (A06-A11){
		replace `var'=. if A04<5
		}

		 
		*If there are some individual with disablity in the HH, the answer on questions of disability for the remaining members without disability
		*is not automaticaly filled in

		*Correction of this issues
		foreach var of varlist (A06-A11){
		replace `var'=1 if A04>=5 & tempdis==0 & HHnodis!=0 & `var'==.
		}

*end impute

*FUNCTIONAL DIFFICULTY VARIABLES
fre A06 A07 A08 A09 A10 A11
clonevar seeing_diff_new=A06
clonevar hearing_diff_new=A07
clonevar mobility_diff_new =A08
clonevar cognitive_diff_new =A09
clonevar selfcare_diff_new =A10
clonevar comm_diff_new =A11


egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

count if  mi(func_difficulty) 
count if  mi(age) 
count if  mi(female) 
count if mi(urban_new)

count if mi(urban_new) | mi(func_difficulty) 
*23,548
 keep if !mi(urban_new) & !mi(func_difficulty) 
 


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

* everattended_new 	=1 if ever attended school=0 no schooling
gen everattended_new=1 if B02A>1
replace everattended_new=0 if B02A==1
replace everattended_new=. if mi(B02A)
tab everattended_new B02A

gen edattain_new = 1 if B02A ==1 | B02A == 2 | (B02A==3 & B02B <6)
replace edattain_new = 2 if (B02A==3 & B02B >=6) | B02A==4 | (B02A==5 & B02B <3) //there are a handful Primary educ with (yr 7 or 8)
replace edattain_new = 3 if (B02A==5 & B02B >=3)  //there are a handful with year 4
replace edattain_new = 4 if B02A ==6 //some tertiary and completed tertiary

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



*school_new=0 if currently not in school =1 if currently in school
gen school_new=B01
recode school_new (2=0)
tab B01 school_new,m

*Literacy
gen lit_new = 1 if B06==1
replace lit_new = 0 if B06==2

*no info on recent use of computer, internet on individual level
*no info on mobile phone on individual level
*no info internet

*Employment

*redefined empstat_new
gen ind_emp = (C01==1 | C02==1 | C03 ==1)
gen help_home_only = (C01==2 & C02==2 & C03 ==1)
replace ind_emp = 0 if help_home_only ==1  & (C05==3 | C05 == 4) // recode to 0 if activity produced goods that is mainly OR only for family use


*youth_idle
gen youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle = . if ind_emp==. & school_new==.
replace youth_idle=. if age>24


*using ISIC codes 
*denominator is only among those employed
gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if ind_emp==1 & inrange(isic2d, 10, 32) 
replace work_manufacturing=. if ind_emp==0 | isic2d==.

*variable labelled as ISCO code, but no label on values. - 3 digit and 4 digit codes
*description in local language Kinyarwanda
*https://www.ilo.org/wcmsp5/groups/public/---dgreports/---dcomm/---publ/documents/publication/wcms_172572.pdf
gen work_managerial = 0 if female==1 // denominator - all women
replace work_managerial = 1 if (D01B2 >=  110 & D01B2<= 143)  & female==1 //no 2 digit, only 3 digit, 4 digit ISCO code
replace work_managerial = 1 if (D01B2 >= 1111 & D01B2 <= 1439) & female==1 
replace work_managerial = . if female==0


*informal
*The numerator includes adults who are informal workers. 
*The denominator includes all adults age 15 and above.
*Informal workers include the self-employed, those who work for a microenterprise of five or fewer employees or in a firm that is unregistered, and those who have no written contract with their employers. Workers who produce goods for own and/or family consumption are included as informal workers. Additionally, family workers without pay are included as informal workers.
*However, unlike in SDG 8.3.1, we use all adults as a denominator as many individuals with disabilities are not employed (out of the labor force) and would otherwise not be captured in the denominator which would then be very small. 
gen work_informal = 0
replace work_informal = 1 if inlist(D05, 4, 6)
replace work_informal  = 1 if C02==1 & C01 !=1 & C03!=1
replace work_informal  = 1 if C03==1 & C01 !=1 & C02!=1
tab work_informal ind_emp,m 


*water [drinking]
gen ind_water=1 if inlist(I06A,1,2,3,4,5,7,9,12)
replace ind_water=0 if inlist(I06A,6,8,10,11,13) & !mi(I06A)
tab I06A ind_water

*toilet [no info on shared]
gen ind_toilet=1 if inlist(I03,1,2)
replace ind_toilet =0 if inlist(I03,3,4,5,6) 
tab  I03 ind_toilet


*Standard of Living
*electric_new
gen ind_electric=1 if I04==1|I04==8
replace ind_electric=0 if inlist(I04,2,3,4,5,6,7,9,10)
tab I04 ind_electric

*fuelcook_new
*Primary fuel used in cooking. If organic materials is used (dung, coal) then it is classified as bad/unsuitable. Otherwise it is good
gen ind_cleanfuel=1 if inlist(I05,3,4,5,6)
replace ind_cleanfuel=0 if inlist(I05,1,2,7,8,11)
replace ind_cleanfuel = . if I05==10 // doesn't cook
tab I05 ind_cleanfuel

/*

Quality floor conditions include laminates, cement, tiles, bricks, parquet. Poor floor conditions include earth, dung, stone, wood planks. 

Quality wall conditions include burnt bricks, concrete, cement. Poor wall conditions refer to no walls or walls made of natural or rudimentary materials (e.g. cane, palms, trunk, mud, dirt, grass, reeds, thatch, stone with mud, plywood, cardboard, carton/plastic, canvas, tent, unburnt bricks, reused wood. The unit of analysis is individual in household with adequate housing.

Quality roof conditions include burnt bricks concrete, cement. Poor roof conditions refer to no roof or roofs made of natural or rudimentary materials (e.g. asbestos, thatch, palm leaf, mud, earth, sod, grass, plastic, polythene sheeting, rustic mat, cardboard, canvas, tent, wood planks, reused wood, unburnt bricks). 
*/
gen ind_roof=1 if I01_A==1|I01_A==2|I01_A==3
replace ind_roof=0 if I01_A==4|I01_A==5
tab I01_A ind_roof

gen ind_wall =1 if I01_B==3|I01_B==4
replace ind_wall=0 if inlist(I01_B,1,2,5,6,7,8,10)
tab I01_B ind_wall

gen ind_floor = 1 if I01_C==4|I01_C==5|I01_C==6
replace ind_floor = 0 if inlist(I01_C,1,2,3,7)
tab I01_C ind_floor

gen ind_livingcond=0
replace ind_livingcond = 1 if ind_roof==1 & ind_wall==1 & ind_floor==1
replace ind_livingcond=. if mi(ind_roof) & mi(ind_wall) & mi(ind_floor)

*Assets ,Asset_TV Asset_Telephone Asset_Bike Asset_Motorbike Asset_Refrigerator Asset_Car Asset_Truck Asset_Computer Asset_Internet Asset_Cell
gen ind_radio = cond(mi(I07B),.,cond(I07B==1,1,0))
gen ind_tv = cond(mi(I07C),.,cond(I07C==1,1,0))
gen ind_refrig = cond(mi(I07A),., cond(I07A==1,1,0))
gen ind_bike = cond(mi(I07O),., cond(I07O==1,1,0))
gen ind_motorcycle = cond(mi(I07P),.,cond(I07P==1,1,0))
gen ind_phone = .
gen ind_computer = cond(mi(I07F),.,cond(I07F==1,1,0))
gen ind_autos = cond(mi(I07N),.,cond(I07N==1,1,0))
gen cell_new = cond(mi(I07M), ., cond(I07M==1,1,0))

	
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


***************************************
 
bys hh_id: egen func_difficulty_hh = max(func_difficulty)
gen disability_any_hh = (func_difficulty_hh>=2 ) if !mi(func_difficulty_hh)
gen disability_some_hh = (func_difficulty_hh==2) if !mi(func_difficulty_hh)
gen disability_atleast_hh = (func_difficulty_hh>=3) if !mi(func_difficulty_hh)


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

save "${CLEAN}\Rwanda_LFS_2018_Clean.dta", replace

