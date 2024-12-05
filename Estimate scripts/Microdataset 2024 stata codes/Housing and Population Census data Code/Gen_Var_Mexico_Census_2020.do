/*******************************************************************************
******************Mexico Census 2020 ********************************************
********************************************************************************
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/
Reference to appendix and paper:
For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).
Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, GVS, Pinilla-Roncancio, M.,  Rivas Velarde, M., Teodoro, D.,  and Mitra, S. (2024). The Disability Statistics – Estimates Database: an innovative database of internationally comparable statistics on disability inequalities. International Journal of Population Data Science.
Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com
Author: Monica Pinilla-Roncancio
Suggested citation: DDI. Disability Statistics Database - Estimates (DS-E Database)). Disability Data Initiative collective. Fordham University: New York, USA. 2024.
*******************************************************************************/
*===============================================================================*

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


if  "`c(username)'"=="gustavoco36"{
	gl dta "/Users/gustavoco36/Dropbox/Investigaciones/Proyectos/CODS/DDI/Census Mexico Analysis" // Ruta de mi computador
}

else {
	gl dta "D:\Dropbox\Dropbox\ANDES\CODS\Fordham Disability\2023\Census Mexico Analysis" // Ruta de ustedes
}

**** DATA


gl results "${dta}/Code/results"
gl dta_work "${dta}/dta/work"
gl dta_raw "${dta}/dta/raw"

use "${dta_raw}/MEXICO_Census_2020_NotClean.dta", replace

******* Country information 

gen country_name="Mexico"
lab var country_name "Country name"
gen     country_abrev="MX"
lab var country_abrev "Country abbreviation"
gen     country_dataset_year="Mexico_2020"
la var  country_dataset_year "Country Data and year"

*** Strata Variables

rename estrato sample_strata
rename upm psu
rename factor ind_weight

**** Administrative Levels 

***Admin 1 
destring ent, gen (ent2)
rename ent entorg
rename ent2 ent

gen     admin1 = 1 if (ent==003 | ent==002 | ent==008 | ent==010 | ent==026 | ent==025)
replace admin1 = 2 if (ent==005 | ent==019 | ent==028)
replace admin1 = 3 if (ent==006 | ent==014 | ent==018 | ent==016 )
replace admin1 = 4 if (ent==013 | ent==021 | ent==029 | ent==030 )
replace admin1 = 5 if (ent==001 | ent==011 | ent==022 | ent==024| ent==032 )
replace admin1 = 6 if (ent==007 | ent==012 | ent==020 )
replace admin1 = 7 if (ent==015 | ent==009 | ent==017 )
replace admin1 = 8 if (ent==004 | ent==023 | ent==027 | ent==031)

label  def admin1 1 "Región Noroeste" 2"Región Noreste" 3"Región Occidente" 4"Región Oriente" 5"Región Centronorte"  6"Región Centrosur" 7"Región Suroeste" 8"Región Sureste"
label  val admin1 admin1
tab    admin1, m 

rename ID_PERSONA ind_id 
rename ID_VIV hh_id
rename ent admin2
rename mun district 

la var admin1 "Admin 1 Level"
rename district admin3
la var admin2 "Admin 2 Level"

label  def admin2 1 "Aguascalientes" 2"Baja California" 3"Baja California Sur" 4"Campeche" 5"Coahuila de Zaragoza"  6"Colima" 7"Chiapas" 8"Chihuahua" ///
			9"Ciudad de Mexico" 10"Durango" 11"Guanajuato" 12"Guerrero" 13"Hidalgo" 14"Jalisco" 15"Mexico" 16"Michoacan de Ocampo" 17"Morelos" ///
			18"Nayarit" 19"Nuevo Leon" 20"Oaxaca" 21"Puebla" 22"Queretaro" 23"Quintana Roo" 24"San Luis Potosi" 25"Sinaloa" 26"Sonora" 27"Tabasco" ///
			28"Tamaulipas" 29"Tlaxcala" 30"Veracruz de Ignacio de la Llave" 31"Yucatan" 32"Zacatecas"

label  val admin2 admin2


**Age

tab     edad, m
gen     age_group=.
replace age_group=1 if edad<30
replace age_group=2 if edad>=30 & edad<45
replace age_group=3 if edad>=45 & edad<65
replace age_group=4 if edad>=65 & edad!=. 
label   def age_group 1 "15 to 29" 2 "30 to 44" 3 " 45 to 64" 4 "65 or more"
label   val age_group age_group
label   var age_group "Age group"
tab     age_group, m 
rename  edad age 
la var age_group "Age Group"

** Sex
destring sexo, replace
codebook sexo, tab(10)

gen   female =(sexo==3)
label def female 1 "female" 0 "male"  
label val female female
tab   female, m 
la var female "Female or Male"


*** Rural/Urban

destring tamloc,replace
codebook tamloc, tab(30)
recode tamloc (1=1) (2/5=0)  // all areas larger than 2500 habitants are urban according to national definitions 
gen urban_new=(tamloc==0)
label def urban_new 1 "Rural" 0 "Urban"
label val urban_new urban_new
label var urban_new "Rural/Urban"
tab   urban_new, m   


**** Discapacidad

destring DIS_*,replace

recode DIS_* (8/9=.)

*****Disability*****
clonevar seeing_diff_new=DIS_VER
clonevar hearing_diff_new=DIS_OIR
clonevar mobility_diff_new =DIS_CAMINAR
clonevar cognition_diff_new =DIS_RECORDAR
clonevar selfcare_diff_new =DIS_BANARSE
clonevar comm_diff_new =DIS_HABLAR 

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognition_diff_new selfcare_diff_new comm_diff_new)

*Disability levels for any domain 
gen    disability_any = (func_difficulty>=2)
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

gen cognition_any = (cognition_diff_new>=2)  
replace cognition_any=. if cognition_diff_new ==.

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

gen cognition_some = (cognition_diff_new==2) 
replace cognition_some=. if cognition_diff_new ==.

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

gen cognition_atleast_alot = (cognition_diff_new>=3) 
replace cognition_atleast_alot=. if cognition_diff_new ==.

gen selfcare_atleast_alot = (selfcare_diff_new>=3) 
replace selfcare_atleast_alot=. if selfcare_diff_new ==.

gen communicating_atleast_alot = (comm_diff_new>=3) 
replace communicating_atleast_alot=. if comm_diff_new ==.


*Household level Disability 
egen    func_difficulty_hh=max(func_difficulty), by(hh_id)
lab var func_difficulty_hh "Max Difficulty in HH"

gen     disability_any_hh=1 if func_difficulty_hh>1
replace disability_any_hh=0 if func_difficulty_hh==1
replace disability_any_hh=. if func_difficulty_hh==.

lab var disability_any_hh "P3 Any difficulty in Any Domain for any adult in the hh"

gen     disability_some_hh=1 if func_difficulty_hh==2
replace disability_some_hh=0 if func_difficulty_hh!=2
replace disability_some_hh=. if func_difficulty_hh==.

lab var disability_some_hh "P3 Some difficulty in Any Domain for any adult in the hh"

gen     disability_atleast_hh=1 if func_difficulty_hh>2
replace disability_atleast_hh=0 if func_difficulty_hh<3
replace disability_atleast_hh=. if func_difficulty_hh==.

lab var disability_atleast_hh "P3 At least a lot of difficulty in Any Domain for any adult in the hh"

****** Education  
tab nivacad 

** Ever attend school 

gen     everattended_new=(nivacad!="00" | asisten=="1") 
replace everattended_new =. if  nivacad=="99" & asisten=="9" 
lab var everattended_new "E1_Ever_attended_school binary"
tab     everattended_new

*variable for ages 15+ used for the deprivation variable for multidimensional poverty
gen     ind_atleastprimary_all = ( escoacum_new>=6)  if  escoacum_new!=.

** Adults ages 25+ who have completed primary school or higher 
codebook escoacum , tab(39)
replace escoacum=. if escoacum==99
gen     escoacum_new=escoacum

gen     ind_atleastprimary =( escoacum_new>=6)  if  escoacum_new!=.   // Primary education 6 years
replace ind_atleastprimary  =. if age<25
tab     ind_atleastprimary if age>25, m 
label var ind_atleastprimary "Adults ages 25+ who have completed primary school or higher "


** Adults ages 25+ who have completed upper secondary  school or higher  // Secundary 3 years 

gen     ind_atleastsecondary  =( escoacum_new>=12)  if  escoacum_new!=. 
replace ind_atleastsecondary  =. if age<25
tab     ind_atleastsecondary if age>25, m 
label var ind_atleastsecondary "Adults ages 25+ who have completed upper secondary  school or higher "


** Literacy
destring alfabet, replace
codebook alfabet, tab(20)
gen      lit_new =  (alfabet==1) if alfabet!=9
tab      lit_new, m 
lab var  lit_new  "E5_literate binary"


****** Personal activities (including work)

** Computer
destring computadora, replace
recode   computadora (1=1) (2=0) (9=.), gen(computer)
lab var  computer "P2_Adults who used a computer last 3 months"   // The question is about having a computer, laptop or tablet not about use

** Internet
destring internet, replace
rename   internet intern_org
recode   intern_org (7=1) (8=0) (9=.), gen(internet)
lab var  internet "P2_Adults who used a internet last 3 months"  // Ask about having internet in the household, not about use

** Cell phone
destring celular, replace
recode   celular (5=1) (6=0) (9=.), gen(mobile_own)
lab var  mobile_own "P2_Adults who owns a cell"


** Employed 
destring conact, replace
codebook conact, tab(30)
gen     acivity_labour=1 if inlist(conact,10,13,18, 19, 20) // working or not working but in employment 
replace acivity_labour=2 if conact==30  // searching for a job
replace acivity_labour=3 if (conact>=14 & conact<18 | conact ==40 | conact ==50 | conact ==60 | conact ==70 | conact ==80) // outside labour force
replace acivity_labour=. if conact==99
tab     acivity_labour

gen     ind_emp= (acivity_labour==1)  if acivity_labour!=.
lab var ind_emp "W1_employed"
tab     ind_emp, m 

** Youth Idle Rate 
destring asisten ,replace
recode   asisten (9=.)

gen     d_age_15_24 = (age>14 & age<25) if age!=.
gen     youth_idle  = (ind_emp==0 & asisten==3) if d_age_15_24==1
replace youth_idle =. if asisten ==. & ind_emp==.
lab     var youth_idle "W2_youth idle binary"

tab youth_idle if d_age_15_24==1 , m
 
** Working Individulas in Manufacturing

gen      id_ocupacion=substr(OCUPACION_C,1,1)
destring id_ocupacion, replace
gen     work_manufacturing= (id_ocupacion==7 | id_ocupacion==8) if acivity_labour==1  // including Trabajadores artesanales, en la construcción y otros ofi cios and Operadores de maquinaria industrial, ensambladores, choferes y conductores de transporte
replace work_manufacturing =. if acivity_labour==. 
tab     work_manufacturing if acivity_labour==1, m 
lab     var work_manufacturing "W3_worker in manufacturing binary"


** Women in Managerial Positions

gen work_managerial= inlist(id_ocupacion,1) if (female==1)  & acivity_labour==1  
replace work_managerial=. if acivity_labour==. 
tab work_managerial if sex==1 &  acivity_labour==1 , m  
lab var work_managerial "W4_woman worker in managerial position binary"


*** Informality 
destring SAR_AFORE , replace   // No contribution to pensions
recode  SAR_AFORE (9=.)
gen     work_informal = (SAR_AFORE==4) if SAR_AFORE!=. & acivity_labour==1  
replace work_informal =. if acivity_labour==. 
lab var work_informal "W5_Adults who work in the informal labour market"
tab work_informal if acivity_labour==1, m 

*work_managerial is a binary for women in managerial work among all women while work_managerial2 code  women in managerial work among working women only. We use  work_managerial2  to generate the  women in managerial work   indicator for the DS-E database.

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if (ind_emp==. & work_managerial==.) 

*work_informal is a binary variable for informal work status among all adults while work_informal2 codes informal work among workers only. We use work_informal2 to generate the informal work indicator for the DS-E database.

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.

****** Health

** Drinking water
*** Public service, communitary or private well, rain water
destring ABA_AGUA_ENTU , replace
recode   ABA_AGUA_ENTU  (1/4=1) (5=0) (6=1) (7=0) (9=.) , gen(ind_water)
lab var  ind_water "H1_Water"

** Sanitation services

destring drenaje, replace
recode   drenaje (1/2=1) (3/5=0) (9=.), gen(ind_toilet)
destring usoexc, replace
replace  ind_toilet=0 if usoexc==1


****** Standard of Living

** Electricity

destring electricidad, replace
recode   electricidad (1=1) (3=0) (9=.), gen(ind_electric)
lab var  ind_electric "S1_Electricity"


** Cooking Fuel
destring combustible, replace
recode   combustible (1=0) (2=1) (3=1) (4=0) (5=1) (9=.), gen(ind_cleanfuel)  // no cooking is considered as clean
lab var  ind_cleanfuel "S2_Clean_fuel"


** Adequate housing

* Floor
destring pisos, replace
recode pisos (1=0) (2/3=1) (9=.), gen(ind_floor)
lab var ind_floor "Individual in a house with quality floor materials"

* Roof
destring techos, replace
recode techos (1/4=0) (5=1) (6/7=0) (8/10=1) (99=.), gen(ind_roof)
lab var ind_roof "Individual in a house with quality roof materials"

* Walls
destring paredes, replace
recode paredes (1/7=0) (8=1) (9=.) , gen(ind_wall)
lab var ind_wall "Individual in a house with quality wall materials"

gen     ind_livingcond=(ind_floor==1 & ind_roof==1 & ind_wall==1) 
replace ind_livingcond=. if ind_floor==. & ind_roof==. & ind_wall==.
lab var ind_livingcond "S3_Individual in a house with  adequate housing (quality floor, quality roof, quality wall materials)"
tab     ind_livingcond, m

** Owing Assets:  radio, TV, telephone, bike, or motorbike or fridge); and the household does not own a car (or truck).
**The percentage of assets owned by an individual’s household is the percentage of the following assets that the adult’s household owns: //
*  a radio, TV, telephone, mobile phone, bike, motorbike, refrigerator, car (or truck) and computer.
destring radio televisor refrigerador bicicleta computadora celular motocicleta telefono  autoprop , replace
recode   radio televisor refrigerador bicicleta computadora celular motocicleta autoprop (1=1) (2=0) (5=1) (6=0) (7=1) (8=0) (.=.) (9=.)
recode bicicleta telefono (3=1) (4=0) (9=.) 
egen   ind_asset_ownership=rowmean(radio televisor refrigerador bicicleta computadora motocicleta telefono celular autoprop ) 
tab    ind_asset_ownership, m 

** Radio
gen ind_radio=(radio==1) if radio!=. 
lab var ind_radio "Individual in a household that owns radio"

** TV
gen ind_tv=(televisor==1) if televisor!=. 
lab var ind_tv "Individual in a household that owns tv"

** Refrigerator
gen ind_refrig=(refrigerador==1) if refrigerador!=. 
lab var ind_refrig "Individual in a household that owns refrigerator"

** Bike 
gen ind_bike=(bicicleta==1) if bicicleta!=. 
lab var ind_bike "Individual in a household that owns bike"


** Motorcycle
gen ind_motorcycle=(motocicleta==1) if motocicleta!=. 
lab var ind_motorcycle "Individual in a household that owns motorbike"

** Autos
gen ind_autos=(autoprop==1) if autoprop!=.
lab var ind_autos "Individual in a household that owns autos"

** Computer
gen ind_computer=(computadora==1) if computadora!=. 
lab var ind_computer "Individual in a household that owns computer"

*** Phone 
gen ind_phone=(telefono==1) if telefono!=. 
lab var ind_phone "Individual in a household that owns phone"

*** Mobile phone  
gen cell_new=(celular==1) if celular!=. 
lab var cell_new "Individual in a household that owns cell phone"

**** Insecurity

*** Health Insurance

destring DHSERSAL1  , replace
recode   DHSERSAL1  (1/8=1) (9=0) (99=.), gen(health_insurance)


****** Multidimensional Poverty 


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
	

gen     deprive_sl_asset = 0
replace deprive_sl_asset = 1 if (( ind_radio + ind_tv + ind_phone + ind_refrig + ind_bike + ind_motorcycle < 2) & ind_autos==0)
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
						
gen deprive_health=(1/missing_health)*0.33*health_temp 
gen deprive_sl=(1/missing_sl)*0.33*sl_temp 
replace deprive_health=(1/missing_health)*0.25*health_temp 
replace deprive_sl=(1/missing_sl)*0.25*sl_temp 

gen mdp_score=cond(mi(deprive_educ)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_health+deprive_sl) 
replace mdp_score=cond(mi(deprive_educ)|mi(deprive_work)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_work+deprive_health+deprive_sl) 

gen ind_mdp=cond(mi(mdp_score),.,cond((mdp_score>0.33),1,0))

lab var mdp_score "Multidemensional Poverty Score"
lab var ind_mdp "M1_Multidemensional Poverty status"



egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new comm_diff_new cognition_diff_new mobility_diff_new selfcare_diff_new)
gen ind_func_diff_missing= (func_diff_missing==6)

egen disaggvar_missing = rowmiss(female age urban_new)

gen ind_disaggvar_missing = (disaggvar_missing >0)

compress
save "${dta_work}/Mexico_Cleaned_Individual_Data_withmissing.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1

/*
gen     hh_weight=1
lab var hh_weight "Household Sample weight"
gen     ind_weight=1 
lab var ind_weight "Individual Sample weight"
*/

*drop ind_id person_num 
drop func_diff_missing ind_func_diff_missing disaggvar_missing ind_disaggvar_missing 

la var ind_emp "Employed"
la var youth_idle "Youth is idle"
la var work_managerial "Women in managerial position"
la var work_informal "Informal work"
la var ind_water "Safely managed water source "
la var ind_toilet "Safely managed sanitation"
la var ind_electric "Electricity"
la var ind_cleanfuel "Clean cooking fuel"
la var ind_floor "Floor quality"
la var ind_wall "Wall quality"
la var ind_roof "Roof quality"
la var ind_livingcond "Adequate housing"
la var ind_radio "Household has radio"
la var ind_tv "Household has television"
la var ind_refrig "Household has refrigerator"
la var ind_bike "Household has bike"
la var ind_motorcycle "Household has motocycle"
la var ind_phone "Household has telephone"
la var ind_computer "Household has computer"
la var ind_autos "Household has automobile"
la var cell_new "Household has mobile"
la var ind_asset_ownership "Share of  Assets"

la var disability_any "Any Difficulty"
la var seeing_any "Any Difficulty in seeing"
la var hearing_any "Any Difficulty in hearing"
la var mobile_any "Any Difficulty in walking"
la var cognition_any "Any Difficulty in cognition"
la var selfcare_any "Any Difficulty in selfcare"
la var communicating_any "Any Difficulty in communicating"

la var disability_some "Some Difficulty"
la var seeing_some "Some Difficulty in seeing"
la var hearing_some "Some Difficulty in hearing"
la var mobile_some "Some Difficulty in walking"
la var cognition_some "Some Difficulty in cognition"
la var selfcare_some "Some Difficulty in selfcare"
la var communicating_some "Some Difficulty in communicating"

la var disability_atleast "At least a lot  Difficulty"
la var seeing_atleast_alot "At least a lot  Difficulty in seeing"
la var hearing_atleast_alot "At least a lot  Difficulty in hearing"
la var mobile_atleast_alot "At least a lot  Difficulty in walking"
la var cognition_atleast_alot "At least a lot  Difficulty in cognition"
la var selfcare_atleast_alot "At least a lot  Difficulty in selfcare"
la var communicating_atleast_alot "At least a lot  Difficulty in communicating"

la var seeing_diff_new "Difficulty in seeing"
la var hearing_diff_new "Difficulty in hearing"
la var comm_diff_new "Difficulty in communicating"
la var cognition_diff_new "Difficulty in cognition"
la var mobility_diff_new "Difficulty in walking"

la var selfcare_diff_new "Difficulty in selfcare"
la var func_difficulty "Difficulty in Any Domain"

*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 ind_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognition_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary   computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh"

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

keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ///
ind_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group ///
 /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognition_diff_new selfcare_diff_new ///
 comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome ///
 seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some ///
 cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot ///
 selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ///
 ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle ///
 work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ///
 /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ///
 /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos ///
 cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh ///
 /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  ///
 deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh ///
 disability_some_hh disability_atleast_hh 

order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2  ///
ind_weight hh_weight dv_weight sample_strata psu /* demographics*/ female urban_new age  age_group ///
 /* functional difficulty*/ seeing_diff_new hearing_diff_new mobility_diff_new cognition_diff_new selfcare_diff_new ///
 comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome ///
 seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some ///
 cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot ///
 selfcare_atleast_alot communicating_atleast_alot /*education*/ everattended_new lit_new school_new edattain_new ind_atleastprimary ///
 ind_atleastprimary_all ind_atleastsecondary  /*personal activities*/ computer internet mobile_own /*employment*/ind_emp youth_idle ///
 work_manufacturing  work_managerial  work_informal /*health*/ ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ///
 /*standard of living*/ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ///
 /*asset*/ ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos ///
 cell_new ind_asset_ownership /*insecurity*/ health_insurance social_prot food_insecure shock_any health_exp_hh ///
 /*mdp*/ deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  ///
 deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp /* household indicator*/ func_difficulty_hh disability_any_hh ///
 disability_some_hh disability_atleast_hh 
 
 save "${dta_work}/Mexico_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

