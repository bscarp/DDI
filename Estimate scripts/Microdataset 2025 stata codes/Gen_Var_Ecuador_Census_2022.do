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
gl dta "/Users/gustavoco36/Library/CloudStorage/Dropbox/Investigaciones/Proyectos/CODS/DDI/Ecuador" // Ruta de gc
}

else if "`c(username)'"=="monica"{
	gl dta "D:\Dropbox\Dropbox\Ecuador" // Ruta de Monica
}

else {
	gl dta "D:\Dropbox\Investigaciones\Proyectos\CODS\DDI\Ecuador" // Ruta de servidor
}
*/
glo dta_work "D:\Dropbox\Dropbox\Ecuador/dta/work"
glo dta_raw "C:\Users\Dell\Dropbox\Ecuador/dta/raw/BDD_CPV_2022_NACIONAL_CSV"
glo dta_tmp "C:\Users\Dell\Dropbox\Ecuador/dta/tmp"

glo results "C:\Users\Dell\Dropbox\Ecuador/code/results"

/*
use "D:\Dropbox\Dropbox\Ecuador\dta\work\mortalidad.dta", replace
keep m00 m0202 m03 id_hog
gen death=1
replace m0202=. if m0202==9999
replace death=0 if m0202<=2021 & m0202!=.
bys id_hog : egen hh_death = max(death)
destring m03, replace
gen child_death= m03<18 if m03<999
bys id_hog : egen hh_childdeath= max( child_death)
collapse hh_death hh_childdeath, by( id_hog)
rename id_hog hh_id
save "D:\Dropbox\Dropbox\Ecuador\dta\raw\mortality2.dta"

use "$dta_work/Censo_2022", replace 

drop if v0201>2 
*Household Id
gen hh_id=i01+ i02 +i03+ i04 +i05 +i10 +inh  

*Individual Id
gen ind_id=i01+ i02 +i03+ i04 +i05 +i10 +inh +p00

*** Merge 
merge m:1 hh_id using"D:\Dropbox\Dropbox\Ecuador\dta\raw\mortality2.dta", force

drop _merge
save "$dta_work/Censo_2022", replace
*/
use "$dta_work/Censo_2022", clear 

*Country name
gen country_name="Ecuador"

*Country abbreviation
gen country_abrev="ECU"

*Country Dataset year
gen country_dataset_year="Ecuador_Census_2022"

*Adminlevel 3 Parroguiq
gen admin3 = i01+i02+i03

*Adminlevel 2 Canton 
gen admin2 = i01+i02
destring admin2,replace

*Adminlevel 1 Provincia
clonevar admin1=i01

destring admin1, replace
label def admin1 01"Azuay" 02"Bolivar" 03"Canar" 04"Carchi" 05"Cotopaxi" 06"Chimborazo" 07"El Oro" 08"Esmeraldas" 09"Guayas" 10"Imbabura" 11"Loja" 12"Los Rios" 13"Manabi" 14"Morona Santiago" 15"Napo" 16"Pastaza" 17"Pichicha" 18"Tungurahua" 19"Zamora Chinchipe" 20"Galapagos" 21"Sucumbios" 22"Orellana" 23"Santo Domingo de" 24"Santa Elena"
label val admin1 admin1
tab   admin1 

label def admin2 101 "CUENCA"	102 "GIRÓN"	103 "GUALACEO"	104 "NABÓN"	105 "PAUTE"	106 "PUCARÁ"	107 "SAN FERNANDO"	108 "SANTA ISABEL"	109 "SIGSIG"	110 "OÑA"	111 "CHORDELEG"	112 "EL PAN"	113 "SEVILLA DE ORO"	114 "GUACHAPALA"	115 "CAMILO PONCE ENRÍQUEZ"	201 "GUARANDA"	202 "CHILLANES"	203 "CHIMBO"	204 "ECHEANDIA"	205 "SAN MIGUEL"	206 "CALUMA"	207 "LAS NAVES"	301 "AZOQUES"	302 "BIBLIAN"	303 "CAÑAR"	304 "LA TRONCAL"	305 "EL TAMBO"	306 "DELEG"	307 "SUSCAL"	401 "TULCÁN"	402 "BOLÍVAR"	403 "ESPEJO"	404 "MIRA"	405 "MONTÚFAR"	406 "SAN PEDRO DE HUACA"	501 "LATACUNGA"	502 "LA MANÁ"	503 "PANGUA"	504 "PUJILÍ"	505 "SALCEDO"	506 "SAQUISILÍ"	507 "SIGCHOS"	601 "RIOBAMBA"	602 "ALAUSÍ"	603 "COLTA"	604 "CHAMBO"	605 "CHUNCHI"	606 "GUAMOTE"	607 "GUANO"	608 "PALLATANGA"	609 "PENÍPE"	610 "CUMANDÁ"	701 "MACHALA"	702 "ARENILLAS"	703 "ATAHUALPA"	704 "BALSAS"	705 "CHILLA"	706 "EL GUABO"	707 "HUAQUILLAS"	708 "MARCABELÍ"	709 "PASAJE"	710 "PIÑAS"	711 "PORTOVELO"	712 "SANTA ROSA"	713 "ZARUMA"	714 "LAS LAJAS"	801 "ESMERALDAS"	802 "ELOY ALFARO"	803 "MUISNE"	804 "QUININDE"	805 "SAN LORENZO"	806 "ATACAMES"	807 "RÍOVERDE"	901 "GUAYAQUIL"	902 "ALFREDO BAQUERIZO MORENO"	903 "BALAO"	904 "BALZAR"	905 "COLIMES"	906 "DAULE"	907 "DURÁN"	908 "EMPALME"	909 "EL TRIUNFO"	910 "MILAGRO"	911 "NARANJAL"	912 "NARANJITO"	913 "PALESTINA"	914 "PEDRO CARBO"	916 "SAMBORONDÓN"	918 "SANTA LUCIA"	919 "SALITRE"	920 "SAN JACINTO DE YAGUACHI"	921 "PLAYAS"	922 "SIMÓN BOLÍVAR"	923 "CRNEL. MARCELINO MARIDUEÑA"	924 "LOMAS DE SARGENTILLO"	925 "NOBOL"	927 "GNRAL. ANTONIO ELIZALDE"	928 "ISIDRO AYORA"	1001 "IBARRA"	1002 "ANTONIO ANTE"	1003 "COTACAHI"	1004 "OTAVALO"	1005 "PIMAMPIRO"	1006 "SAN MIGUEL DE URCUQUI"	1101 "LOJA"	1102 "CALVAS"	1103 "CATAMAYO"	1104 "CÉLICA"	1105 "CHAGUARPAMBA"	1106 "ESPÍNDOLA"	1107 "GONZANAMÁ"	1108 "MACARÁ"	1109 "PALTAS"	1110 "PUYANGO"	1111 "SARAGURO"	1112 "SOZORANGA"	1113 "ZAPOTILLO"	1114 "PINDAL"	1115 "QUILANGA"	1116 "OLEMDO"	1201 "BABAHOYO"	1202 "BABA"	1203 "MONTALVO"	1204 "PUEBLOVIEJO"	1205 "QUEVEDO"	1206 "URDANETA"	1207 "VENTANAS"	1208 "VINCES"	1209 "PALENQUE"	1210 "BUENA FÉ"	1211 "VALENCIA"	1212 "MOCACHE"	1213 "QUINSALOMA"	1301 "PORTOVIEJO"	1302 "BOLÍVAR"	1303 "CHONE"	1304 "EL CARMEN"	1305 "FLAVIO ALFARO"	1306 "JIPIJAPA"	1307 "JUNÍN"	1308 "MANTA"	1309 "MONTECRISTI"	1310 "PAJÁN"	1311 "PICHINCHA"	1312 "ROCAFUERTE"	1313 "SANTA ANA"	1314 "SUCRE"	1315 "TOSAGUA"	1316 "24 DE MAYO"	1317 "PEDERNALES"	1318 "OLMEDO"	1319 "PUERTO LÓPEZ"	1320 "JAMA"	1321 "JARAMIJÓ"	1322 "SAN VICENTE"	1401 "MORONA"	1402 "GUALAQUIZA"	1403 "LIMÓN INDANZA"	1404 "PALORA"	1405 "SANTIAGO"	1406 "SUCÚA"	1407 "HUAMBOYA"	1408 "SAN JUAN BOSCO"	1409 "TAISHA"	1410 "LOGROÑO"	1411 "PABLO SEXTO"	1412 "TIWINTZA"	1501 "TENA"	1503 "ARCHIDONA"	1504 "EL CHACO"	1507 "QUIJOS"	1509 "CARLOS JULIO ARROSEMENA TOLA"	1601 "PASTAZA"	1602 "MERA"	1603 "SANTA CLARA"	1604 "ARAJUNO"	1701 "QUITO"	1702 "CAYAMBE"	1703 "MEJÍA"	1704 "PEDRO MONCAYO"	1705 "RUMIÑAHUI"	1707 "SAN MIGUEL DE LOS BANCOS"	1708 "PEDRO VICENTE MALDONADO"	1709 "PUERTO QUITO"	1801 "AMBATO"	1802 "BAÑOS DE AGUA SANTA"	1803 "CEVALLOS"	1804 "MOCHA"	1805 "PATATE"	1806 "QUERO"	1807 "SAN PEDRO DE PELILEO"	1808 "SANTIAGO DE PILLARO"	1809 "TISALEO"	1901 "ZAMORA"	1902 "CHINCHIPE"	1903 "NANGARITZA"	1904 "YACUAMBI"	1905 "YANTZAZA"	1906 "EL PANGUI"	1907 "CENTINELA DEL CÓNDOR"	1908 "PALANDA"	1909 "PAQUISHA"	2001 "SAN CRISTOBAL"	2002 "ISABELA"	2003 "SANTA CRUZ"	2101 "LAGO AGRIO"	2102 "GONZALO PIZARRO"	2103 "PUTUMAYO"	2104 "SHUSHUFINDI"	2105 "SUCUMBIOS"	2106 "CASCALES"	2107 "CUYABENO"	2201 "ORELLANA"	2202 "AGUARICO"	2203 "LA JOYA DE LOS SACHAS"	2204 "LORETO"	2301 "SANTO DOMINGO"	2302 "LA CONDORDÍA"	2401 "SANTA ELENA"	2402 "LA LIBERTAD"	2403 "SALINAS"
label val admin2 admin2

*Household weight
gen hh_weight=1

* Individual weight
gen ind_weight=1

*Age_Group  
tab      p03, m  
clonevar age=p03
gen     age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65
replace age_group = . if age==.

drop if age<15

*Gender
tab     p02, m 
gen     female=1 if p02==2
replace female=0 if p02==1
replace female=. if p02==. 
tab     female, m 

*Urban
tab    aur, m 
gen    urban_new=aur
recode urban_new (0=2)

recode p0701 p0702 p0703 p0704 p0705 p0706 (9=.) // Se ignora

clonevar seeing_diff_new=p0705
clonevar hearing_diff_new=p0704
clonevar mobility_diff_new =p0701
clonevar cognitive_diff_new =p0706
clonevar selfcare_diff_new =p0702
clonevar comm_diff_new =p0703 


*Functional_Difficulty
egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)
tab  func_difficulty, m 

*Disability levels 
gen disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

gen disability_none = (func_difficulty==1)
replace disability_none = . if func_difficulty==.

gen     disability_alot = (func_difficulty==3)
replace disability_alot = . if func_difficulty==.

gen     disability_unable = (func_difficulty==4)
replace disability_unable = . if func_difficulty==.

gen     disability_nonesome = (func_difficulty>=1 & func_difficulty<3)
replace disability_nonesome = . if func_difficulty==.



*Any difficulty 
gen     seeing_any = (seeing_diff_new>=2) 
replace seeing_any=. if seeing_diff_new ==.

gen     hearing_any = (hearing_diff_new>=2) 
replace hearing_any=. if hearing_diff_new ==.

gen     mobile_any = (mobility_diff_new>=2) 
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

gen selfcare_alot = (selfcare_diff_new==3) 
replace selfcare_alot=. if selfcare_diff_new ==.

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
replace selfcare_alot=. if selfcare_diff_new ==.

gen communicating_unable = (comm_diff_new==4) 
replace communicating_unable=. if comm_diff_new ==.


*Household level prevalence
egen func_difficulty_hh=max(func_difficulty), by(hh_id)
lab var func_difficulty_hh "Max Difficulty in HH"

gen     disability_any_hh=1 if func_difficulty_hh>1
replace disability_any_hh=0 if func_difficulty_hh==1
replace disability_any_hh=. if func_difficulty_hh==.
lab var disability_any_hh "P3 Any difficulty in Any Domain for any adult in the hh"

gen     disability_some_hh=1 if func_difficulty_hh==2
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
tab p17r , m
replace p18r="." if p18r=="NA"
destring p18r, replace
  

gen     years_schooling=.
replace years_schooling=0 if inlist(p17r,1,2,3) /* Sin educacion, guarderia, educacion inicial */
replace years_schooling=p18r if p17r==4 /* años realizados en alfabetizacion y post */
replace years_schooling=p18r if p17r==5 /* años en educacion general basica */
replace years_schooling=p18r +10 if p17r==6 /* años en bachillerato */
replace years_schooling=p18r +13 if p17r==7 /* años ciclo post bachillerato */
replace years_schooling=p18r +13 if p17r==8 /* años educacion tecnica y tecnologica */
replace years_schooling=p18r +13 if p17r==9 /* años educacion superior */
replace years_schooling=p18r +18 if p17r==10 /* años maestria */
replace years_schooling=p18r +20 if p17r==11 /* años Doctorado */
tab     years_schooling, m 

gen     everattended_new=(p17r!=1 | p15==1) 
replace everattended_new =. if  p17r==. & p15==.
tab     everattended_new,  m 


*school_new=0 if currently not in school =1 if currently in school
gen    school_new=p15 if p15!=. 
recode school_new (2=0)
tab    school_new, m 

*Atleastprimary education
gen      ind_atleastprimary = (years_schooling>=6) 
replace  ind_atleastprimary =. if years_schooling==.
clonevar ind_atleastprimary_all= ind_atleastprimary
replace  ind_atleastprimary =. if age<25

tab  ind_atleastprimary p17r, m  

*Atleastsecondary education
gen     ind_atleastsecondary = (years_schooling>=10)  // Secundary school is 10 years
replace ind_atleastsecondary =. if years_schooling==.
replace ind_atleastsecondary =. if age<25

tab  ind_atleastsecondary p17r if age>=25, m  

* Literacy
tab p19, m 
*replace p19=1 if years_schooling>9 & years_schooling!=. 
gen lit_new = p18==1 if p18!=. 
tab lit_new, m 

*Internet
tab h1004, m 
gen     internet=1 if h1004==1 
replace internet=0 if h1004==2
replace internet=. if h1004==.
tab     internet, m 

lab var internet "Adult in hh with internet"

*Mobile own
gen     mobile_own = 1 if h1002==5
replace mobile_own = 0 if h1002==2
replace mobile_own = . if h1002==.

lab var mobile_own "Adult owns mobile phone"


*Employment Status
gen     ind_emp = (condact1==2)  if condact1!=. 
replace ind_emp = . if condact1==.
tab     ind_emp, m 

*Manufacturing Worker
tab      p28,m 
replace  p28=. if p28==9999
tostring p28, replace
replace  p28="0"+p28 if length(p28)==3

gen      id_ocupacion=substr(p28,1,2)
destring id_ocupacion, replace

/*
tab      p28,m 
replace  p28=. if p28==9999
tostring p28, replace
replace  p28="0"+p28 if length(p28)==3

gen     work_manufacturing = .
replace work_manufacturing = 1 if id_ocupacion >= 10 & id_ocupacion <= 33 & condact1 == 2
replace work_manufacturing = 0 if (id_ocupacion < 10 | id_ocupacion > 33) & condact1 == 2
tab     work_manufacturing, m 
*/
*Female at Managerial Work
gen     work_managerial =cond(mi(ind_emp),.,cond(inrange(id_ocupacion, 11, 14),1,0))
replace work_managerial = 0 if ind_emp==0
replace work_managerial = . if female==0

gen     work_managerial2= 0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if (ind_emp==. & work_managerial==.)

*Informal Work
tab     p29, m 
recode  p29 (9=.)
gen     work_informal = (p29==3 | p29==4 | p29==6 | p29==8) if p29!=. & condact1==2 
replace work_informal =. if condact1==. 
tab     work_informal p29, m 

gen     work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.


/*
recode  p30 (9=.)
gen     work_informal = (p30==7) if p30!=. & condact1==2 
replace work_informal =. if condact1==. 
gen     work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.
*/

*Youth Idle
gen     youth_idle = (ind_emp==0 & school_new==0)
replace youth_idle =. if ind_emp==. & school_new==.
replace youth_idle=. if age>24
tab     youth_idle if age<25


*Living alone
tab      h1303, m 
clonevar hhsize=h1303
gen alone=( hhsize==1)
replace alone=. if hhsize==.

*Water
tab v09, m 
gen      ind_water= cond(mi(v09),.,cond(inlist(v09,1,2,3),1,0))
replace  ind_water= 0 if v10==4  | v10==5 
replace  ind_water=. if v09==. 
tab      ind_water, m

*Electricity
gen ind_electric= v12==2 if v12!=. 
tab ind_electric v12, m 

*Cooking fuel 
gen ind_cleanfuel=cond(mi(h05),.,cond(inlist(h05 ,1,2,3,4, 7),1,0))  // No cooking in the household is considered ok
tab h05 ind_cleanfuel, m 

*Sanitation
gen      ind_toilet=cond(mi(v11),., cond(inlist(v11,1,2,3,4),1,0))
replace  ind_toilet=0 if h03==2 & ind_toilet==1 // Share sanitation with other household
tab      v11 ind_toilet, m


*Housing
tab v07
gen ind_floor = cond(inlist(v07,1,2,3,4,5),1,0)
tab v07 ind_floor, m 

tab v03, m
gen ind_roof =  cond(inlist(v03,1,2,3,4),1,0)


gen ind_wall = cond(inlist(v05,1,2,3),1,0)


*Housing Condition
gen     ind_livingcond = (ind_floor==1&ind_roof==1&ind_wall==1)
replace ind_livingcond = . if (ind_floor==.&ind_roof==.&ind_wall==.)

*Household goods
*radio

/*
* Note [20250217 GC]: No radio Variable in Census

*/
* TV
*ind_tv	=1  =0

/*
* Note [20250217 GC]: No TV Variable in Census
*/

* Bike
/*
* Note [20250217 GC]: No bike Variable in Census
*/

* Motorcycle
*ind_motorcycle	=1 =0
clonevar  ind_motorcycle=h1012
recode     ind_motorcycle (2=0)

/*
* Note [20250217 GC]: No phone Variable in Census
*/

* Refrigerator
*ind_refrig	=1 =0
clonevar ind_refrig=h1006
recode   ind_refrig (2=0)

*cell_new 	=1 =0
clonevar cell_new=h1002
recode   cell_new (2=0) (5=1)


* Computer
gen ind_computer=h1005==1 if h1005!=. 
tab ind_computer, m 

gen ind_autos = h1011==1 if h1011!=.
tab ind_autos, m

*Assets
egen asset_miss_num=rowmiss(ind_refrig cell_new  ind_motorcycle ind_autos ind_computer)

*** Households with recent death 
*Percentage of hoiseholds experienced a death recently (in the last 12 months)

tab hh_death

rename hh_death  death_hh

*** Households with child death 
** The percentage of households who ever experiened child death 

tab hh_childdeath
rename  hh_childdeath child_died

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


* NEW CODE FOR DEPRIVE_SL_ASSET added Jan 18th 2024
gen     deprive_sl_asset = 0
replace deprive_sl_asset = 1 if (( /*ind_radio + ind_tv + ind_phone + */ ind_refrig /*+ ind_bike*/ + ind_motorcycle) < 2) & ind_autos==0
replace deprive_sl_asset = . if /*ind_radio==. & ind_tv==. & ind_phone==. &*/ ind_refrig==. /*& ind_bike==.*/ & ind_motorcycle==. & ind_autos==.



lab var deprive_educ "Deprived if less than primary school completion"
lab var deprive_work "Deprived in work binary"
lab var deprive_health_water "Deprived in water binary"
lab var deprive_health_sanitation "Deprived in terms of sanitation binary"
lab var deprive_sl_electricity "Deprived for electricity binary"
lab var deprive_sl_fuel "Deprived in terms of clean fuel binary"
lab var deprive_sl_housing "Deprived in terms of housing binary"
lab var deprive_sl_asset "Deprived in terms of asset ownership binary"


*we assume that dimensions can not be missing but indicators inside can be missing. The dimension weights remain the same but the indicators weights should change
egen    missing_health=rowmiss(deprive_health_water deprive_health_sanitation)
replace missing_health=2-missing_health
egen    health_temp=rowtotal(deprive_health_water deprive_health_sanitation)			
egen    missing_sl=rowmiss(deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset)
replace missing_sl=4-missing_sl
egen    sl_temp=rowtotal(deprive_sl_electricity deprive_sl_fuel deprive_sl_housing deprive_sl_asset)						
gen     deprive_health=(1/missing_health)*0.33*health_temp if  labor_tag==0
gen     deprive_sl=(1/missing_sl)*0.33*sl_temp if  labor_tag==0	
replace deprive_health=(1/missing_health)*0.25*health_temp if labor_tag==1 
replace deprive_sl=(1/missing_sl)*0.25*sl_temp if  labor_tag==1 
gen     mdp_score=cond(mi(deprive_educ)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_health+deprive_sl) if  labor_tag==0
replace mdp_score=cond(mi(deprive_educ)|mi(deprive_work)|mi(deprive_health)|mi(deprive_sl),.,deprive_educ+deprive_work+deprive_health+deprive_sl) if  labor_tag==1 
gen     ind_mdp=cond(mi(mdp_score),.,cond((labor_tag==1 &mdp_score>0.25)|(labor_tag==0 &mdp_score>0.33),1,0))


*Variable exists

*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin3 admin_alt  ind_weight hh_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some seeing_alot hearing_alot mobile_alot cognition_alot selfcare_alot communicating_alot seeing_unable hearing_unable mobile_unable cognition_unable selfcare_unable communicating_unable hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary   computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m bmi overweight_obese  child_died healthcare_prob death_hh alone   ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh disability_none_hh dv_weight disability_alot disability_unable disability_alot_hh disability_unable_hh child_died death_hh"

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
lab var death_hh "Death househols"
lab var child_died "Child died household"


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
 disability_alot disability_unable disability_alot_hh disability_unable_hh child_died death_hh

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
 disability_alot disability_unable disability_alot_hh disability_unable_hh child_died death_hh

 
 compress
save "${dta_work}/Ecuador_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

compress
save "${dta_work}/Ecuador_Cleaned_Household_Level_Data_Trimmed.dta", replace
