/*******************************************************************************
******************IPUMS-Internatinal********************************************
********************************************************************************
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/
Reference to appendix and paper:
For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).
Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, GVS, Pinilla-Roncancio, M.,  Rivas Velarde, M., Teodoro, D.,  and Mitra, S. (2024). The Disability Statistics – Estimates Database: an innovative database of internationally comparable statistics on disability inequalities. International Journal of Population Data Science.
Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com
Author: Kaviayarasan Patchaiappan
Suggested citation: DDI. Disability Statistics Database - Estimates (DS-E Database)). Disability Data Initiative collective. Fordham University: New York, USA. 2024.
*********Country Code********/
/*
Cambodia 116
Mauritius	480
Morocco	504
Myanmar	104
Senegal	686
South-Africa 710
Suriname 740
Tanzania	834
Uganda	800
Uruguay	858
Vietnam	704
*/ 

**********Sample Code*******
/*
Morocco-2014	504201401
Myanmar-2014	104201401
Mauritius-2011	480201101
Senegal-2013	686201301
South-Africa-2011	710201101
South-Africa-2016	710201601
Suriname-2012	740201201
Uganda-2014	800201401
Uruguay-2011	858201102
Vietnam-2009	704200901
Tanzania-2012	834201201
*/
         
use "D:\DDI\ipumsi_00055.dta\ipumsi_00055.dta",clear

********************************************************************************
*keep only households

keep if gq==10 | gq==29
tab sample

*Dropping below 15 years age 

drop if age<15
tab sample
replace age=. if age==999

*Dropping observation if all domains are missing 

drop if wgcare>=8 & wgcogn>=8 & wgcomm>=8 & wghear>=8 & wgmobil>=8 & wgvision>=8
tab sample 

******************************Variable Generation*******************************
********Country Name****************
gen country_name=country
label define country_name 104 "Myanmar" 480 "Mauritius" 504 "Morocco" 686 "Senegal" 704 "Vietnam" 710 "South Africa" 740 "Suriname" 800 "Uganda" 834 "Tanzania" 858 "Uruguay"
label value country_name country_name
********Country Abrevation*********
gen country_abrev="KHM" if country==116
replace country_abrev="MUS" if country==480
replace country_abrev="MAR" if country==504
replace country_abrev="MMR" if country==104
replace country_abrev="SEN" if country==686
replace country_abrev="SUR" if country==740
replace country_abrev="TZA" if country==834
replace country_abrev="UGA" if country==800
replace country_abrev="URY" if country==858
replace country_abrev="ZAF" if sample==710201101
replace country_abrev="ZAF1" if sample==710201601
replace country_abrev="VNM" if sample==704200901
replace country_abrev="VNM1" if sample==704201901

*********Country_dataset_year*******
gen country_dataset_year=11601 if country==116
replace country_dataset_year=48001 if country==480
replace country_dataset_year=50401 if country==504
replace country_dataset_year=10401 if country==104
replace country_dataset_year=68601 if country==686
replace country_dataset_year=74001 if country==740
replace country_dataset_year=83401 if country==834
replace country_dataset_year=80001 if country==800
replace country_dataset_year=85801 if country==858
replace country_dataset_year=71001 if sample==710201101
replace country_dataset_year=71002 if sample==710201601
replace country_dataset_year=70401 if sample==704200901
replace country_dataset_year=70402 if sample==704201901

label define country_dataset_year 11601 "Cambodia IPUMS 2019" 10401 "Myanmar IPUMS 2014" 48001 "Mauritius IPUMS 2011" 50401 "Morocco IPUMS 2014" 68601 "Senegal IPUMS 2013" 70401 "Vietnam IPUMS 2009" 70402 "Vietnam IPUMS 2019" 71001 "South Africa IPUMS 2011" 71002 "South Africa IPUMS 2016" 74001 "Suriname IPUMS 2012" 80001 "Uganda IPUMS 2014" 83401 "Tanzania IPUMS 2012" 85801 "Uruguay IPUMS 2011"
label value country_dataset_year country_dataset_year

***Household Weight***

gen hh_weight= hhwt

***Individual Weight***

gen ind_weight=perwt

*****Household and Individual Ids***********

egen hh_id= concat(sample serial), format(%25.0g) punct(_)
egen ind_id= concat(sample serial pernum), format(%25.0g) punct(_)

*Urban/Rural

gen urban_new=1 if urban==1
replace urban_new=0 if urban==2
replace urban_new=. if urban==9

***Strata****

*This is based on sampling design that has been created by DDI for Survey design command

gen sample_strata= strata
replace sample_strata= geolev1 if sample==504201401
replace sample_strata= geolev1 if sample==104201401
replace sample_strata= geo3_za2016 if sample==710201601
replace sample_strata=vn2019a_strata if sample==704201901

*Gender

gen female= 1 if ( sex ==2)
replace female=0 if ( sex ==1)

*Age group

gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65
replace age_group =. if age==.

*Difficulties

clonevar seeing_diff_new= wgvision if wgvision<8
clonevar hearing_diff_new= wghear if wghear<8
clonevar mobility_diff_new= wgmobil if wgmobil<8
clonevar cognitive_diff_new= wgcogn if wgcogn<8
clonevar selfcare_diff_new= wgcare if wgcare<8
clonevar comm_diff_new= wgcomm if wgcomm<8 

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

***Disability levels for any domain***
 
gen disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

gen disability_none = (disability_any==0)

gen disability_nonesome = (disability_none==1|disability_some==1)


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

*Lit

gen lit_new=1 if lit==2
replace lit_new=0 if lit==1
replace lit_new=. if lit==0 | lit==9

*Everattended School

gen everattended_new=inlist(edattaind, 120, 211, 212, 221, 222, 311, 312, 321, 322, 400)
replace everattended_new=. if inlist(edattaind, 0, 999)

*Education - completed primary school
*This variable was created for computing multidimensional poverty
gen ind_atleastprimary_all = (edattain>=2)
replace ind_atleastprimary_all =. if (edattain==0 | edattain==9)

*Atleastprimary education

gen ind_atleastprimary = (edattain>=2) if age>=25
replace ind_atleastprimary =. if (edattain==0 | edattain==9)

*Atleastsecondary education

gen ind_atleastsecondary = (edattain>=3) if age>=25
replace ind_atleastsecondary =. if (edattain==0 | edattain==9)

*Employment Status

gen ind_emp=.
replace ind_emp=1 if empstat==1
replace ind_emp=0 if empstat==2 | empstat==3

*Female at Managerial Work

gen work_managerial=cond(mi(occisco),.,cond(occisco==1,1,0))
replace work_managerial= 0 if ind_emp==0 | ind_emp==.
replace work_managerial= . if female==0 | inlist(country, 710, 858, 800)

*Manufacturing Worker

gen work_manufacturing=cond(mi(indgen),.,cond(indgen==30,1,0))
replace work_manufacturing=. if ind_emp==0 | inlist(country, 710, 858, 800)

*Informal Work

gen work_informal=cond(mi(classwkd),.,cond(inlist(classwkd, 100, 101, 120, 121, 122, 124, 208, 230, 300, 320, 310, 350, 400, 208, 220),1,0))

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & work_managerial==1 & female==1
replace work_managerial2= . if ind_emp==. & work_managerial==. 
replace work_managerial2= . if country==800

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & work_informal==1
replace work_informal2=. if ind_emp==. & work_informal==.
replace work_informal2=. if country==104

*Not in schools
gen school_new=(school==1)
replace school_new=. if (school==0| school==9)

* Youth idle

gen youth_idle=1 if (school_new==0 & ind_emp==0)
replace youth_idle=0 if (school_new==1 | ind_emp==1)
replace youth_idle=. if (school_new==. & ind_emp==.)
replace youth_idle=. if age>24


*Electricity

gen ind_electric=.
replace ind_electric=1 if country==116 &  kh2019a_light==1
replace ind_electric=0 if country==116 &  inlist( kh2019a_light, 2, 3, 4, 5, 6, 7)
replace ind_electric=1 if country==504 &  inlist( ma2014a_light, 1, 2, 5)
replace ind_electric=0 if country==504 &  inlist( ma2014a_light, 3, 4, 6, 7)
replace ind_electric=1 if country==686 &  inlist( sn2013a_light , 1, 2)
replace ind_electric=0 if country==686 &  inrange( sn2013a_light , 3, 10)
replace ind_electric=1 if country==104 &  inlist( mm2014a_light , 1, 7)
replace ind_electric=0 if country==104 &  inlist( mm2014a_light , 2, 3, 4, 5, 6, 8)
replace ind_electric=1 if country==740 &  inlist( sr2012a_light , 1, 2)
replace ind_electric=0 if country==740 &  inrange( sr2012a_light , 3, 7)
replace ind_electric=1 if sample==710201601 &  inlist( za2016a_light , 1, 9)
replace ind_electric=0 if sample==710201601 &  inlist( za2016a_light , 2, 3, 4, 7, 10, 11)
replace ind_electric=1 if sample==710201101 &  inlist( za2011a_fuellght , 1, 8)
replace ind_electric=0 if sample==710201101 &  inlist( za2011a_fuellght , 2, 3, 6)
replace ind_electric=1 if country==834 & inlist( tz2012a_light , 1, 2)
replace ind_electric=0 if country==834 & inrange( tz2012a_light , 3, 12)
replace ind_electric=1 if country==800 &  inlist( ug2014a_light , 10, 12, 14)
replace ind_electric=0 if country==800 &  inlist( ug2014a_light , 13, 15, 16, 17, 18, 19, 20, 21, 22, 23)
replace ind_electric=1 if country==858 &  uy2011a_electrc==1
replace ind_electric=0 if country==858 &  inrange( uy2011a_electrc, 2, 6)
replace ind_electric=1 if sample==704200901 &  vn2009a_light==1
replace ind_electric=0 if sample==704200901 &  inrange(vn2009a_light, 2, 5)
replace ind_electric=1 if sample==704201901 &  vn2019a_light==1
replace ind_electric=0 if sample==704201901 &  inrange(vn2019a_light, 2, 5)

*Cooking fuel

gen ind_cleanfuel=inlist(fuelcook, 20, 30, 31, 33, 34, 72, 76)
replace ind_cleanfuel=. if fuelcook==99 | fuelcook==0 |fuelcook==.

*Water

gen ind_water = .
replace ind_water = 1 if country == 116 & inlist(kh2019a_water, 1, 2, 3, 4, 5, 7, 9, 13)
replace ind_water = 0 if country == 116 & inlist(kh2019a_water, 6, 8, 11, 12, 14)
replace ind_water = 1 if country == 504 & (ma2014a_watsrc == 1 | ma2014a_watsrc == 4 | ma2014a_watsrc == 2)
replace ind_water = 0 if country == 504 & inlist(ma2014a_watsrc, 3, 5, 6, 7)
replace ind_water = 1 if country == 104 & inlist( mm2014a_watdrnk , 1, 2, 3, 8)
replace ind_water = 0 if country == 104 & inlist( mm2014a_watdrnk , 4, 5, 6, 7, 9, 10)
replace ind_water = 1 if country == 686 & inlist( sn2013a_watsrc , 11, 12, 13, 21, 31, 41, 81)
replace ind_water = 0 if country == 686 & inlist( sn2013a_watsrc , 32, 42, 51, 61, 71)
replace ind_water = 1 if sample == 710201101 & inlist( za2011a_watsrc , 1, 2, 4, 7)
replace ind_water = 0 if sample == 710201101 & inlist( za2011a_watsrc , 3, 5, 6, 8, 9)
replace ind_water = 1 if sample == 710201601 & inlist( za2016a_watsrc , 1, 2, 3, 4, 5, 6, 7, 9)
replace ind_water = 0 if sample == 710201601 & inlist( za2016a_watsrc , 8, 10, 11, 12, 13)
replace ind_water = 1 if country == 834 & inlist( tz2012a_watsup , 1, 2, 3, 4, 5, 7, 9, 10)
replace ind_water = 0 if country == 834 & inlist( tz2012a_watsup , 6, 8, 11, 12, 13)
replace ind_water = 1 if country == 800 & inlist( ug2014a_watsrc , 10, 11, 12, 13, 14, 15, 18, 22, 21)
replace ind_water = 0 if country == 800 & inlist( ug2014a_watsrc , 16, 17, 19, 20, 23)
replace ind_water = 1 if country == 740 & inlist( sr2012a_watsrc , 1, 2, 3, 4, 8)
replace ind_water = 0 if country == 740 & inlist( sr2012a_watsrc , 5, 6, 7, 9)
replace ind_water = 1 if country == 858 & inlist( uy2011a_watsrc , 1, 2, 4, 5)
replace ind_water = 0 if country == 858 & inlist( uy2011a_watsrc , 3, 6, 7)
replace ind_water = 1 if sample == 704200901 & inlist( vn2009a_watsrc , 1, 2, 4, 6, 8)
replace ind_water = 0 if sample == 704200901& inlist( vn2009a_watsrc , 3, 5, 7)
replace ind_water = 1 if sample == 704201901 & inlist( vn2019a_watsrc, 1,2,3,4,6,8)
replace ind_water = 0 if sample == 704201901& inlist( vn2019a_watsrc , 9, 5, 7)

*Sanitation

gen toilet_use=.
replace toilet_use= 1 if country==116 & inlist(kh2019a_toilet, 2, 3, 4, 5)
replace toilet_use= 0 if country==116 & inlist(kh2019a_toilet, 1, 6, 7, 8)
replace toilet_use= 1 if country==104 & inlist(mm2014a_toilet, 1, 2)
replace toilet_use= 0 if country==104 & inlist(mm2014a_toilet, 3, 4, 5, 6)
replace toilet_use= 1 if country==504 & inlist( ma2014a_toilshar, 1)
replace toilet_use= 0 if country==504 & inlist(ma2014a_toilshar, 2, 3)
replace toilet_use= 1 if country==686 & inlist( sn2013a_toilet , 11, 12, 21, 23)
replace toilet_use= 0 if country==686 & inlist( sn2013a_toilet , 22, 31, 41, 51)
replace toilet_use= 1 if sample==710201601 & inlist( za2016a_toilet , 1, 2, 4, 6)
replace toilet_use= 0 if sample==710201601 & inlist( za2016a_toilet, 3, 5, 7, 8, 9, 10)
replace toilet_use= 1 if sample==710201101 & inlist( za2011a_toilet , 1, 2, 4)
replace toilet_use= 0 if sample==710201101 & inlist( za2011a_toilet , 0, 3, 5, 6, 7)
replace toilet_use= 1 if country==740 & sr2012a_toilet==1
replace toilet_use= 0 if country==740 & inlist( sr2012a_toilet , 2, 3, 4, 5, 6)
replace toilet_use= 1 if country==834 & inlist(tz2012a_toilet, 1, 2, 3, 5, 6, 7, 8, 10)
replace toilet_use= 0 if country==834 & inlist(tz2012a_toilet, 4, 9, 11, 12)
replace toilet_use= 1 if country==800 & inlist(ug2014a_toilet, 10, 11, 12, 16, 14)
replace toilet_use= 0 if country==800 & inlist(ug2014a_toilet, 13, 15, 17, 18)
replace toilet_use= 1 if country== 858 & inlist(toilet, 20, 21)
replace toilet_use= 0 if country== 858 & inlist(toilet, 10, 22, 23)
replace toilet_use= 1 if sample== 704200901 & inlist(vn2009a_toilet, 2, 1)
replace toilet_use= 0 if sample== 704200901 & inlist(vn2009a_toilet, 3, 4)
replace toilet_use= 1 if sample== 704201901 & inlist( vn2019a_toilet, 1,2)
replace toilet_use= 0 if sample== 704201901 & inlist(vn2019a_toilet, 3, 4)

clonevar ind_toilet=toilet_use if country == 504 | country == 104 | country == 686 | country == 834 | country == 858 | country == 740 | sample == 704200901 | sample == 704201901
replace ind_toilet=toilet_use if sample == 710201101
replace ind_toilet=1 if country==116 & toilet_use==1 & kh2019a_toiletsh == 2
replace ind_toilet=0 if country==116 & toilet_use==1 & kh2019a_toiletsh==1
replace ind_toilet=1 if country==800 & toilet_use==1 & ug2014a_toilshar==2
replace ind_toilet=0 if country==800 & toilet_use==1 & ug2014a_toilshar==1
replace ind_toilet=1 if sample==710201601 & toilet_use==1 & za2016a_toilshar ==2
replace ind_toilet=0 if sample==710201601 & toilet_use==1 & za2016a_toilshar ==1

** Adequate housing
*Floor 

gen ind_floor= inlist(floor, 201, 202, 203, 204, 205, 208, 212, 215, 219, 222, 231, 234)
replace ind_floor=. if floor==0 | floor==.
replace ind_floor=. if inlist(country, 704, 740, 480, 116) /*floor variable not avaiable for south africa 2011, Vietnam, Mauritius*/
replace ind_floor=. if sample==710201101
*Roof 

gen ind_roof= inlist(roof, 10, 11, 12, 14, 16, 19, 31, 34, 36, 38, 26)
replace ind_roof=. if roof==0 | roof==99 | roof==.
replace ind_roof=. if inlist(country, 480, 116) /*roof variable not avaiable for Mauritius and Cambodia*/
replace ind_roof= 1 if ( vn2019a_roof ==1) & sample==704201901
replace ind_roof=0 if ( vn2019a_roof ==2) & sample==704201901
*Wall

gen ind_wall= inlist(wall, 501, 502, 505, 507, 510, 512, 516, 518, 519, 520, 521, 522, 523)
replace ind_wall=. if wall==0 | wall==999 | wall==.
replace ind_wall=. if inlist(country, 480, 116) /*wall variable not avaiable for Mauritius and Cambodia*/
replace ind_wall=1 if vn2019a_walls==1 & sample==704201901
replace ind_wall=0 if vn2019a_walls==2 & sample==704201901

*Note: The label value for wall floor roof will be changing in IPUMS website, so see the current label value for your data

*Housing Condition

gen ind_livingcond =.
replace ind_livingcond=(ind_floor==1&ind_roof==1&ind_wall==1) if inlist(country , 104, 504, 686, 834, 800, 858)
replace ind_livingcond=. if inlist(country , 104, 504, 686, 834, 800, 858) & (ind_floor==.&ind_roof==.& ind_wall==.)
replace ind_livingcond=(ind_roof==1&ind_wall==1) if inlist(country, 704, 740)
replace ind_livingcond=. if inlist(country, 704, 740) & (ind_roof==.& ind_wall==.)
replace ind_livingcond=(ind_roof==1&ind_wall==1) if sample==710201101 
replace ind_livingcond=. if inlist(sample, 710201101) & (ind_roof==.& ind_wall==.)

*Household Assest

*Radio
gen ind_radio= ( radio==2 )
replace ind_radio=. if radio==0 | radio==9| radio==.

*Phone
gen ind_phone=(phone==2)
replace ind_phone=. if phone==0 | phone==9| phone==.

*Cell
gen cell_new=(cell==1)
replace cell_new=. if cell==.|cell==0|cell==9

*Television
gen ind_tv= ( tv >=20)
replace ind_tv=. if tv==.|tv==0|tv==99

*Computer
gen ind_computer=( computer ==2)
replace ind_computer=. if computer ==.| computer ==0|computer ==9

*Refrig
gen ind_refrig=( refrig ==2)
replace ind_refrig=. if refrig ==.| refrig ==0| refrig ==9

*Motorcycle
gen ind_motorcycle=.
replace ind_motorcycle=1 if kh2019a_motorcyc>=1 & country==116
replace ind_motorcycle=0 if kh2019a_motorcyc==0 & country==116
replace ind_motorcycle=1 if ma2014a_motorcyc==1 | ma2014a_motorcyc==2 & country==504
replace ind_motorcycle=0 if ma2014a_motorcyc==0 & country==504
replace ind_motorcycle=1 if mm2014a_motorcyc==1 & country==104
replace ind_motorcycle=0 if mm2014a_motorcyc==2 & country==104
replace ind_motorcycle=1 if sn2013a_motorcyc==1 & country==686
replace ind_motorcycle=0 if sn2013a_motorcyc==0 & country==686
replace ind_motorcycle=1 if tz2012a_motorcyc==1 & country==834
replace ind_motorcycle=0 if tz2012a_motorcyc==2 & country==834
replace ind_motorcycle=1 if ug2014a_motorcyc >=1 & country==800
replace ind_motorcycle=0 if ug2014a_motorcyc==0 & country==800
replace ind_motorcycle=1 if vn2009a_moto==1 & sample==704200901
replace ind_motorcycle=0 if vn2009a_moto==2 & sample==704200901
replace ind_motorcycle=1 if vn2019a_motorcyc==1 & sample==704201901
replace ind_motorcycle=0 if vn2019a_motorcyc==2 & sample==704201901
replace ind_motorcycle=1 if sr2012a_motorcyc==1 & country==740
replace ind_motorcycle=0 if sr2012a_motorcyc==2 & country==740
replace ind_motorcycle=1 if uy2011a_motorc<=6 & country==858
replace ind_motorcycle=0 if uy2011a_motorc==0 & country==858

*Bike
gen ind_bike=.
replace ind_bike=1 if kh2019a_bike>=1 & country==116
replace ind_bike=1 if mm2014a_bike==1 & country==104
replace ind_bike=1 if sn2013a_bike==1 & country==686
replace ind_bike=1 if tz2012a_bike==1 & country==834
replace ind_bike=1 if ug2014a_bike>=1 & country==800
replace ind_bike=1 if sr2012a_bike==1 & country==740
replace ind_bike=1 if vn2019a_bike==1 & sample==704201901
replace ind_bike=0 if kh2019a_bike==0 & country==116
replace ind_bike=0 if mm2014a_bike==2 & country==104
replace ind_bike=0 if sn2013a_bike==0 & country==686
replace ind_bike=0 if tz2012a_bike==2 & country==834
replace ind_bike=0 if ug2014a_bike==0 & country==800
replace ind_bike=0 if sr2012a_bike==2 & country==740
replace ind_bike=0 if vn2019a_bike==2 & sample==704201901
*Autos
gen ind_autos=.
replace ind_autos=0 if autos==0
replace ind_autos=1 if inlist( autos, 1,2,3,4,5,6,7)

*Assests

egen ind_asset_ownership=rowmean(ind_radio ind_tv ind_refrig ind_phone cell_new ind_autos ind_computer ind_bike ind_motorcycle)


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

rename computer computer_hh
rename internet internet_hh

*(Note: The variable computer and internet in IPUMS data are Household level. the variable renamed becasue we use the same name to standarise)


*******Missing********
egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new cognitive_diff_new mobility_diff_new selfcare_diff_new comm_diff_new)

gen ind_func_diff_missing= (func_diff_missing==6) 

egen disaggvar_missing = rowmiss(female age urban_new)

gen ind_disaggvar_missing = (disaggvar_missing >0) if inlist(country, 104, 834, 800, 704, 480, 504, 710, 686, 116)
replace ind_disaggvar_missing = (female==. | age==.) if inlist(country, 740, 800)

save "D:\DDI\IPUMS_with missing.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1
drop if geolev1==504099
*This is drop the area name is unknown (390 observations deleted)
save "D:\DDI\IPUMS.dta", replace

***Spliting the dataset countrywise and adding the admin variables***

global combined_data D:\DDI\

cd "D:\DDI\IPUMS"

*Set using data 
global using_data IPUMS

global country_label IPUMS_Cleaned

global country_list KHM MAR MMR MUS SEN SUR TZA UGA URY VNM VNM1 ZAF ZAF1

foreach x of global country_list {
	use "${combined_data}\\${using_data}.dta", clear

keep if country_abrev=="`x'"
if country==116{
clonevar admin1= geo1_kh2019
clonevar admin2= geo2_kh2019
}
if country==480{
clonevar admin1=geo1_mu2011
clonevar admin2=geo2_mu2011
}
if country==504{
clonevar admin1=geolev1
label define geolev1 504001"Tanger-Tétouan-Al Hoceïma",add
label define geolev1 504002"Oriental",add
label define geolev1 504003"Fès-Meknès",add
label define geolev1 504004"Rabat-Salé-Kénitra",add
label define geolev1 504005"Béni Mellal-Khénifra",add
label define geolev1 504006"Casablanca-Settat",add
label define geolev1 504007"Marrakech-Safi",add
label define geolev1 504008"Drâa-Tafilalet",add
label define geolev1 504009"Souss-Massa",add
label define geolev1 504010"Guelmim-Oued Noun",add
label define geolev1 504011"Laâyoune-Sakia El Hamra",add
label define geolev1 504012"Dakhla-Oued Ed-Dahab",add
label value admin1 geolev1

clonevar admin2=geolev2
label define geolev2 504001051 "Al Hoceïma"
label define geolev2 504001151"Chefchaouen",add
label define geolev2 504001227"Fahs-Anjra",add
label define geolev2 504001331"Larache",add
label define geolev2 504001405"Ouezzane",add
label define geolev2 504001511"Tanger-Assilah",add
label define geolev2 504001571"Tétouan",add
label define geolev2 504001573"M'Diq-Fnideq",add
label define geolev2 504001999"Tanger-Tétouan-Al Hoceïma region, province unknown",add
label define geolev2 504002113"Berkane",add
label define geolev2 504002167"Driouch",add
label define geolev2 504002251"Figuig",add
label define geolev2 504002265"Guercif",add
label define geolev2 504002275"Jerada",add
label define geolev2 504002381"Nador",add
label define geolev2 504002411"Oujda-Angad",add
label define geolev2 504002533"Taourirt",add
label define geolev2 504002999"Oriental region, province unknown",add
label define geolev2 504003061"Meknès",add
label define geolev2 504003131"Boulemane",add
label define geolev2 504003171"El Hajeb",add
label define geolev2 504003231"Fès",add
label define geolev2 504003271"Ifrane",add
label define geolev2 504003451"Sefrou",add
label define geolev2 504003531"Taounate",add
label define geolev2 504003561"Taza",add
label define geolev2 504003591"Moulay Yacoub",add
label define geolev2 504003999"Fès-Meknès region, province unknown",add
label define geolev2 504004281"Kénitra",add
label define geolev2 504004291"Khémisset",add
label define geolev2 504004421"Rabat",add
label define geolev2 504004441"Salé",add
label define geolev2 504004481"Sidi Kacem",add
label define geolev2 504004491"Sidi Slimane",add
label define geolev2 504004501"Skhirate-Témara",add
label define geolev2 504004999"Rabat-Salé-Kénitra region, province unknown",add
label define geolev2 504005081"Azilal",add
label define geolev2 504005091"Béni Mellal",add
label define geolev2 504005255"Fquih Ben Salah",add
label define geolev2 504005301"Khénifra",add
label define geolev2 504005311"Khouribga",add
label define geolev2 504005999"Béni Mellal-Khénifra region, province unknown",add
label define geolev2 504006111"Benslimane",add
label define geolev2 504006117"Berrechid",add
label define geolev2 504006141"Casablanca",add
label define geolev2 504006181"El Jadida",add
label define geolev2 504006355"Médiouna",add
label define geolev2 504006371"Mohammadia",add
label define geolev2 504006385"Nouaceur",add
label define geolev2 504006461"Settat",add
label define geolev2 504006467"Sidi Bennour",add
label define geolev2 504006999"Casablanca-Settat region, province unknown",add
label define geolev2 504007041"Al Haouz",add
label define geolev2 504007161"Chichaoua",add
label define geolev2 504007191"El Kelâa des Sraghna",add
label define geolev2 504007211"Essaouira",add
label define geolev2 504007351"Marrakech",add
label define geolev2 504007427"Rehamna",add
label define geolev2 504007431"Safi",add
label define geolev2 504007585"Youssoufia",add
label define geolev2 504007999"Marrakech-Safi region, province unknown",add
label define geolev2 504008201"Errachidia",add
label define geolev2 504008363"Midelt",add
label define geolev2 504008401"Ouarzazate",add
label define geolev2 504008577"Tinghir",add
label define geolev2 504008587"Zagora",add
label define geolev2 504008999"Drâa-Tafilalet region, province unknown",add
label define geolev2 504009001"Agadir-Ida-Ou-Tanane",add
label define geolev2 504009163"Chtouka-Ait Baha",add
label define geolev2 504009273"Inezgane-Ait Melloul",add
label define geolev2 504009541"Taroudannt",add
label define geolev2 504009551"Tata",add
label define geolev2 504009581"Tiznit",add
label define geolev2 504009999"Souss-Massa region, province unknown",add
label define geolev2 504010261"Guelmim",add
label define geolev2 504010473"Sidi Ifni",add
label define geolev2 504010996"Tan-Tan, Assa-Zag",add
label define geolev2 504010999"Guelmim-Oued Noun region, province unknown",add
label define geolev2 504011121"Boujdour",add
label define geolev2 504011321"Laâyoune",add
label define geolev2 504011997"Es-Semara, Tarfaya",add
label define geolev2 504011999"Laâyoune-Sakia El Hamra region, province unknown",add
label define geolev2 504012391"Oued Ed-Dahab, Aousserd",add
label define geolev2 504099099"Unknown",add
label value admin2 geolev2
}
if country==104{
clonevar admin1=geo1_mm2014
clonevar admin2=geo2_mm2014
clonevar admin3=geo3_mm2014

}
if country==686{
clonevar admin1=geo1_sn2013
clonevar admin2=geo2_sn2013
clonevar admin3=geo3_sn2013
}
if sample==710201101{
clonevar admin1=geo1_za2011
clonevar admin2=geo2_za2011
clonevar admin3=geo3_za2011
}
if sample==710201601{
clonevar admin1=geo1_za2016
clonevar admin2=geo2_za2016
clonevar admin3=geo3_za2016
}
if country==740{
clonevar admin1=geo1_sr2012
}
if country==800{
clonevar admin1=geo1_ug2014
clonevar admin2=geo2_ug2014
clonevar admin3=geo3_ug2014
clonevar admin_alt=regnug
}
if country==834{
clonevar admin1=geo1_tz2012
clonevar admin2=geo2_tz2012
}
if country==858{
clonevar admin1=geo1_uy2011
clonevar admin2=geo2_uy2011
}
if sample==704200901{
clonevar admin1=geo1_vn2009
clonevar admin2=geo2_vn2009
}
if sample==704201901{
clonevar admin1=geo1_vn2019
clonevar admin2=geo2_vn2019
}
ta country_abrev

*Run this to check if variable exists. if not, it will automatically generate variable with missing values
local variable_tocheck "country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin3 admin_alt ind_weight hh_weight dv_weight sample_strata psu   female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary   computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh"

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
lab var ind_weight "Individaul Sample weight"
lab var hh_weight "Household Sample weight"
lab var dv_weight "DHS Domestic Violence sample weight"
lab var sample_strata "Strata weight"
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
lab var work_managerial "Women in managerial position"
lab var work_informal "Informal work"
lab var ind_water "Safely managed water source"
lab var ind_toilet "Safely managed sanitation"
lab var fp_demsat_mod "H3_Family_planning"
lab var anyviolence_byh_12m "Experienced any violence last 12 months"
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

 
keep country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin3 admin_alt ind_weight hh_weight dv_weight sample_strata psu female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel  deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

order country_name country_abrev country_dataset_year ind_id hh_id  admin1 admin2 admin3 admin_alt ind_weight hh_weight dv_weight sample_strata psu female urban_new age  age_group seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new func_difficulty disability_any disability_some disability_atleast disability_none disability_nonesome seeing_any hearing_any mobile_any cognition_any selfcare_any communicating_any seeing_some hearing_some mobile_some cognition_some selfcare_some communicating_some seeing_atleast_alot hearing_atleast_alot mobile_atleast_alot cognition_atleast_alot selfcare_atleast_alot communicating_atleast_alot everattended_new lit_new school_new edattain_new ind_atleastprimary ind_atleastprimary_all ind_atleastsecondary computer internet mobile_own ind_emp youth_idle work_manufacturing  work_managerial  work_informal work_managerial2  work_informal2 ind_water ind_toilet fp_demsat_mod anyviolence_byh_12m ind_electric ind_cleanfuel ind_floor ind_wall ind_roof ind_livingcond ind_radio ind_tv ind_refrig ind_bike ind_motorcycle ind_phone ind_computer ind_autos cell_new ind_asset_ownership health_insurance social_prot food_insecure shock_any health_exp_hh deprive_educ  deprive_health_water  deprive_health_sanitation  deprive_work deprive_sl_electricity deprive_sl_fuel deprive_sl_housing  deprive_sl_asset mdp_score ind_mdp func_difficulty_hh disability_any_hh disability_some_hh disability_atleast_hh 

compress


save "${combined_data}\\`x'_IPUMS_Cleaned_Individual_Data.dta", replace

duplicates drop hh_id, force

save "${combined_data}\\`x'_IPUMS_Cleaned_Household_Level_Data_Trimmed.dta", replace
}
