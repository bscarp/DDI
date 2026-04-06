/*
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/

Reference to appendix and paper:

For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).

Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478

Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com

Author: Monica Pinilla-Roncancio

Suggested citation: Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478
*/

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

/*
if  "`c(username)'"=="gustavoco36"{
gl dta "/Users/gustavoco36/Dropbox/Investigaciones/Proyectos/CODS/DDI/Colombia" // Ruta de gc
}
else if "`c(username)'"=="monica"{
	gl dta "" // Ruta de Monica
}
else {
	gl dta "D:\Dropbox\Investigaciones\Proyectos\CODS\DDI\Colombia" // Ruta de servidor
}

glo dta_work "C:\Users\Dell\Dropbox\Colombia/dta/work"
glo dta_raw "C:\Users\Dell\Dropbox\Colombia/dta/raw/2023"
glo dta_tmp "C:\Users\Dell\Dropbox\Colombia/dta/tmp"


glo results "C:\Users\Dell\Dropbox\Colombia/code/results"
*/

glo dta_work "D:\Dropbox\Dropbox\Colombia\dta\work"
glo dta_raw "CD:\Dropbox\Dropbox\Colombia\dta/raw/2023"
glo dta_tmp "D:\Dropbox\Dropbox\Colombia\dta\/tmp"


glo results "D:\Dropbox\Dropbox\Colombia\code/results"


use "${dta_work}/GEIH2023.DTA", replace

*Country name
gen country_name="Colombia"

*Country abbreviation
gen country_abrev="COL"

*Country Dataset year
gen country_dataset_year="Colombia_GEIH_2023"


*Adminlevel 1
destring DPTO, replace
gen REGION=.
replace REGION=6 if DPTO==91 // Amazonas
replace REGION=6 if DPTO==86 // Putumayo
replace REGION=6 if DPTO==97 // Vaupes
replace REGION=6 if DPTO==94 // Guaviare
replace REGION=6 if DPTO==95 // Guainia
replace REGION=6 if DPTO==99 // Vichada
replace REGION=6 if DPTO==85 // Casanare
replace REGION=6 if DPTO==81 // Arauca
replace REGION=6 if DPTO==88 // San Andres

replace REGION=5 if DPTO==11 // Bogota 

replace REGION=1 if DPTO==8 // Atlantico 
replace REGION=1 if DPTO==23 // Cordoba 
replace REGION=1 if DPTO==70 // Sucre 
replace REGION=1 if DPTO==13 // Bolivar 
replace REGION=1 if DPTO==20 // Cesar 
replace REGION=1 if DPTO==47 // Magdalena 
replace REGION=1 if DPTO==44 // La Guajira 

replace REGION=2 if DPTO==15 // Boyaca
replace REGION=2 if DPTO==25 // Cundinamarca
replace REGION=2 if DPTO==50 // Meta
replace REGION=2 if DPTO==54 // Norte de Santander
replace REGION=2 if DPTO==68 // Santander 

replace REGION=3 if DPTO==17 // Caldas
replace REGION=3 if DPTO==18 // Caqueta
replace REGION=3 if DPTO==41 // Huila
replace REGION=3 if DPTO==63 // Quindio
replace REGION=3 if DPTO==66 // Risaralda
replace REGION=3 if DPTO==73 // Tolima
replace REGION=3 if DPTO==5 // Antioquia

replace REGION=4 if DPTO==19 // Cauca
replace REGION=4 if DPTO==27 // Choco
replace REGION=4 if DPTO==52 // Nariño
replace REGION=4 if DPTO==76 // Valle del Cauca


rename REGION admin1

label def admin1 1"Caribe" 2"Oriental" 3"Central" 4"Pacifica" 5"Bogota" 6"Amazonas, Orinoqua e Insular", replace
label values admin1 admin1

*Adminlevel 2
*rename DPTO admin2

*Adminlevel 3
*replace AREA=AREA+"001" if AREA!=""

*Household Id
tostring DIRECTORIO SECUENCIA_P ORDEN HOGAR, replace
gen hh_id= DIRECTORIO+SECUENCIA_P+HOGAR

*Individual Id
gen ind_id = hh_id + ORDEN

*Household weight
clonevar hh_weight=FEX_C18

* Individual weight
gen ind_weight=1

*Age_Group
clonevar age=P6040
gen     age_group = 1 if P6040 <=29
replace age_group = 2 if P6040>=30&P6040<=44
replace age_group = 3 if P6040>=45&P6040<=64
replace age_group = 4 if P6040>=65
replace age_group =. if P6040==.

keep if age>14 

count
*Gender
gen     female=1 if P3271==2
replace female=0 if P3271==1
replace female=. if P3271==.

*Urban
destring CLASE, replace
gen    urban_new=CLASE
recode urban_new (2=0)

*** Functional Difficulties 
clonevar seeing_diff_new=P1906S3
clonevar hearing_diff_new=P1906S1
clonevar mobility_diff_new =P1906S4
clonevar cognitive_diff_new =P1906S6
clonevar selfcare_diff_new =P1906S7
clonevar comm_diff_new =P1906S2

* Recode Difficulty 
recode seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new (1=4) (2=3) (3=2) (4=1)

*Functional_Difficulty
egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

**Disability levels 
gen     disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

gen disability_none = (func_difficulty==1)
replace disability_none = . if func_difficulty==.

gen disability_alot = (func_difficulty==3)
replace disability_alot = . if func_difficulty==.

gen disability_unable = (func_difficulty==4)
replace disability_unable = . if func_difficulty==.

gen disability_nonesome = (func_difficulty>=1 & func_difficulty<3)
replace disability_nonesome = . if func_difficulty==.


*Any difficulty 
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

*Some difficulty 
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

*At least a lot of difficulty 
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


* At lot of difficulty

gen seeing_alot = (seeing_diff_new==3) 
replace seeing_alot=. if seeing_diff_new ==.

gen hearing_alot = (hearing_diff_new==3) 
replace hearing_alot=. if hearing_diff_new ==.

gen mobile_alot = (mobility_diff_new==3) 
replace mobile_alot=. if mobility_diff_new ==.

gen cognition_alot = (cognitive_diff_new==3) 
replace cognition_alot=. if cognitive_diff_new ==.

gen selfcare__alot = (selfcare_diff_new==3) 
replace selfcare__alot=. if selfcare_diff_new ==.

gen communicating_alot = (comm_diff_new==3) 
replace communicating_alot=. if comm_diff_new ==.


* Unable

gen seeing_unable = (seeing_diff_new==4) 
replace seeing_unable=. if seeing_diff_new ==.

gen hearing_unable = (hearing_diff_new==4) 
replace hearing_unable=. if hearing_diff_new ==.

gen mobile_unable = (mobility_diff_new==4) 
replace mobile_unable=. if mobility_diff_new ==.

gen cognition_unable = (cognitive_diff_new==4) 
replace cognition_unable=. if cognitive_diff_new ==.

gen selfcare_unable = (selfcare_diff_new==4) 
replace selfcare_unable=. if selfcare_diff_new ==.

gen communicating_unable = (comm_diff_new==4) 
replace communicating_unable=. if comm_diff_new ==.


*Household level prevalence
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


gen disability_alot_hh=1 if func_difficulty_hh==3
replace disability_alot_hh=0 if func_difficulty_hh<3
replace disability_alot_hh=. if func_difficulty_hh==.
lab var disability_alot_hh "P3 At least a lot of difficulty in a lot Domain for any adult in the hh"



gen disability_unable_hh=1 if func_difficulty_hh==4
replace disability_unable_hh=0 if func_difficulty_hh<4
replace disability_unable_hh=. if func_difficulty_hh==.
lab var disability_unable_hh "P3 At least a lot of difficulty in unable Domain for any adult in the hh"


*Everattended School
codebook P3042, tab(40)
recode   P3042 (99=.)
gen     everattended_new =(P3042!=1 | P6170==1)
replace everattended_new=. if P3042==. & P6170==. 
tab     everattended_new, m


*school_new=0 if currently not in school =1 if currently in school
gen school_new=P6170
recode school_new (2=0)


*** Educación 

gen escolaridad=.
replace escolaridad=0 if P3042==1 | P3042==2
replace escolaridad= P3042S1 if P3042==3 
replace escolaridad= P3042S1 + 5 if  P3042==4
replace escolaridad= P3042S1 + 9 if  P3042==5 |P3042==6
replace escolaridad= P3042S1 + 11 if  P3042>=7 & P3042<=10
replace escolaridad = P3042S1 +15 if P3042>=11 & P3042<=13
tab     escolaridad P3042S1, m


*Atleastprimary education
gen     ind_atleastprimary = (escolaridad>=5)
replace ind_atleastprimary =. if escolaridad==.
tab     ind_atleastprimary, m 
gen ind_atleastprimary_all =  ind_atleastprimary
replace ind_atleastprimary =. if age<25

*Atleastsecondary education
gen     ind_atleastsecondary = (escolaridad>9)
replace ind_atleastsecondary =. if escolaridad==.
replace ind_atleastsecondary =. if age<25

* Literacy
gen lit_new= P6160==1 if P6160!=.
tab lit_new, m

* Note [20250217 GC]: No Internet Variable in GEIH

* Note [20250217 GC]: No Celphone Variable in GEIH

*Employment Status
gen     ind_emp = (OCI==1) if PET==1
replace ind_emp = . if PET==.
tab     ind_emp, m
 
*Manufacturing Worker

gen      id_ocupacion=substr(RAMA4D_R4,1,1)
destring id_ocupacion, replace

/*
gen      id_ocupacion=substr(RAMA4D_R4,1,1)
destring id_ocupacion, replace
gen     work_manufacturing=cond(mi(ind_emp),.,cond(id_ocupacion==7 | id_ocupacion==8,1,0))
replace work_manufacturing=. if ind_emp==0
tab     work_manufacturing, m 
*/

gen     work_manufacturing=RAMA4D_D_R4>="1011" & RAMA4D_D_R4<= "3320"
replace work_manufacturing=. if  RAMA4D_D_R4=="."
tab     work_manufacturing, m 

*Female at Managerial Work
gen     work_managerial =cond(mi(ind_emp),.,cond(id_ocupacion==1,1,0))
replace work_managerial = 0 if ind_emp==0
replace work_managerial = . if female==0
gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if (ind_emp==. & work_managerial==.)

*Informal Work
gen     work_informal = (P6430==3 | P6430==4| P6430==5 | P6430==6 |  P6430==7 | P6430==8) if  P6430!=.
replace work_informal=. if ind_emp==.
tab  P6430 work_informal 


gen     work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.


/*
gen work_informal= (P6920==2) if ind_emp==1
replace work_informal=. if ind_emp==.
tab P6920 work_informal
gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.
*/


*Youth Idle
gen     youth_idle = (ind_emp==0&school_new==0)
replace youth_idle=. if ind_emp==. & school_new==.
tab     youth_idle, m 
replace youth_idle=. if age>24

*Living alone
clonevar hhsize=P6008
gen alone=( hhsize==1)
replace alone=. if hhsize==.

*** Health Insurance 

gen health_insurance= P6090==1 if P6090!=. 
tab health_insurance, m 

*Water
tab P5050, m
gen ind_water= cond(mi(P5050),.,cond(inlist(P5050,1,2),1,0))

*Electricity
gen ind_electric= P4030S1==2 if P4030S1!=. 
tab ind_electric, m

*Cooking fuel 
gen ind_cleanfuel=cond(mi(P5080),.,cond(inlist(P5080 ,1,3,4),1,0))
replace ind_cleanfuel=1 if P5070==6
tab  ind_cleanfuel, m

*Sanitation
gen ind_toilet=cond(mi(P5020),., cond(inlist(P5020,1,2),1,0))
replace ind_toilet=0 if P5030==2 // Share sanitation with other household
tab ind_toilet, m

*Housing
gen ind_floor = cond(inlist(P4020,2,4,5,6,7),1,0)
tab P4020 ind_floor, m 


* Note [20250217 GC]: No Roof Variable in GEIH

gen ind_wall = cond(inlist(P4010,1,2),1,0)
tab P4010 ind_wall, m 


*Housing Condition
gen ind_livingcond = (ind_floor==1 & ind_wall==1)
replace ind_livingcond = . if (ind_floor==.& ind_wall==.)
tab     ind_livingcond, m


*Household goods

** No information on radio, TV, bike, motorcycle, fridge, phone, computer, or cars

/*
* Note [20250217 GC]: No ASSETS Variable in GEIH
*Assets
egen asset_miss_num=rowmiss(ind_radio ind_tv ind_refrig ind_phone cell_new ind_bike ind_motorcycle ind_autos ind_computer)
*/

*Note: We remove the binary for asset ownership as it is not needed in the output.

*Multidimensional poverty 
*if observation has employment information labor_tag==1, otherwise ==0
gen     labor_tag=1 if ind_emp!=.
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

/*
* NEW CODE FOR DEPRIVE_SL_ASSET added Jan 18th 2024
gen deprive_sl_asset = 0
replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle) < 2) & ind_autos==0
replace deprive_sl_asset = . if ind_radio==. & ind_tv==. & ind_phone==. & ind_refrig==. & ind_bike==. & ind_motorcycle==. & ind_autos==.

*/

gen deprive_sl_asset=. // Missing values for this dimension

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


*Variable exists

*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin3 admin_alt  ind_weight hh_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some seeing_alot hearing_alot mobile_alot cognition_alot selfcare_alot communicating_alot seeing_unable hearing_unable mobile_unable cognition_unable selfcare_unable communicating_unable hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary   computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m bmi overweight_obese  child_died healthcare_prob death_hh alone   ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh disability_none_hh dv_weight  disability_alot disability_unable disability_alot_hh disability_unable_hh"

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
 
*Labels
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

*keep
keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  admin3 admin_alt ///
ind_weight hh_weight sample_strata psu female urban_new age  age_group seeing_diff_new hearing_diff_new ///
mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any ///
disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any ///
cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some ///
selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot ///
cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new ///
school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary computer ///
internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial2  work_informal2 ind_water ///
ind_toilet fp_demsat_mod anyviolence_byh_12m bmi overweight_obese  child_died healthcare_prob ///
death_hh alone  ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ///
ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership ///
health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  ///
deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  ///
deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh ///
disability_atleast_hh disability_none_hh seeing_alot hearing_alot mobile_alot cognition_alot selfcare_alot ///
 communicating_alot seeing_unable hearing_unable mobile_unable cognition_unable selfcare_unable communicating_unable dv_weight ///
 disability_alot disability_unable disability_alot_hh disability_unable_hh


*Order
order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  admin3 admin_alt ///
ind_weight hh_weight sample_strata psu female urban_new age  age_group seeing_diff_new hearing_diff_new ///
mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any ///
disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any ///
cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some ///
selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot ///
cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new ///
school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary computer ///
internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial2  work_informal2 ind_water ///
ind_toilet fp_demsat_mod anyviolence_byh_12m bmi overweight_obese  child_died healthcare_prob ///
death_hh alone  ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ///
ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership ///
health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  ///
deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  ///
deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh ///
disability_atleast_hh disability_none_hh seeing_alot hearing_alot mobile_alot cognition_alot selfcare_alot ///
 communicating_alot seeing_unable hearing_unable mobile_unable cognition_unable selfcare_unable communicating_unable dv_weight ///
 disability_alot disability_unable disability_alot_hh disability_unable_hh


save "${dta_work}/Colombia_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

save "${dta_work}/Colombia_Cleaned_Household_Level_Data_Trimmed.dta", replace
