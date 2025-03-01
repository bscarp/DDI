/*******************************************************************************
********************************DHS*********************************************
********************************************************************************
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/
Reference to appendix and paper:
For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).
Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, GVS, Pinilla-Roncancio, M.,  Rivas Velarde, M., Teodoro, D.,  and Mitra, S. (2024). The Disability Statistics – Estimates Database: an innovative database of internationally comparable statistics on disability inequalities. International Journal of Population Data Science.
Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com
Author: Katherine Theiss
Suggested citation: DDI. Disability Statistics Database - Estimates (DS-E Database)). Disability Data Initiative collective. Fordham University: New York, USA. 2024.
*******************************************************************************/
********************************************************************************
*Globals 
********************************************************************************
global survey_data D:\DDI\DHS
*\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data
global clean_data D:\DDI\DHS\_Clean Data
*\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Clean Data
global combined_data D:\DDI\DHS\_Combined Data
*\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\DHS_country_data\_Combined Data


global tonga_data C:\Users\16313\Dropbox\Apporto - Fordham\Disability Project\DDI 2023 Report\Cleaning Do-files\5. TON_PHC_2016\Datasets\2023 Report Clean Data
*\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\Cleaning Do-files\5. TON_PHC_2016\Datasets\2023 Report Clean Data

cd "D:\DDI\DHS"
*"\\apporto.com\dfs\FORDHAM\Users\ktheiss_fordham\Documents\DDI 2023 Report\Cleaning Do-files\8. World Bank Collaboration\Output - Spring 2024"


*Append individual level data
********************************************************************************
use "${combined_data}\\DHS_Cross_Country_Data.dta", clear

*append using "${tonga_data}\Tonga_Cleaned_Individual_Data_Trimmed.dta", force

la var admin2 "Admin 2 level"
la var psu "PSU"
la var school_new "Currently attending school"
la var edattain_new "Educational Attainment"
la var computer "Individual uses computer"
la var youth_idle "Individual uses computer"
la var work_manufacturing "In manufacturing"
la var work_managerial "Women in managerial position"
la var work_informal "Informal work"
la var fp_demsat_mod "Women with family planning needs met"
la var health_insurance "Adults with a health insurance coverage"
la var social_prot "Adults in households receiving social protection"
la var food_insecure "Adults in food insecure households"
la var shock_any "Adults in households that experienced a shock recently"
la var health_exp_hh "Household health expenditures out of total consumption expenditures"
la var dv_weight "DHS Domestic Violence sample weight"
la var ind2_weight "DHS Individual sample weight"

*Change DHS individual survey variables to missing for individuals ages above 45
replace ind_emp=. if age>=45
replace lit_new=. if age>=45
replace internet=. if age>=45
replace mobile_own=. if age>=45
replace fp_demsat_mod=. if age>=45
replace anyviolence_byh_12m=. if age>=45

gen ssu = country_dataset_year+ hh_id if country_abrev!="MR"
replace ssu = country_dataset_year+cluster_id if country_abrev=="MR"

gen tsu = country_dataset_year+cluster_id+ hh_id if country_abrev=="MR"
replace tsu = "" if country_abrev!="MR"

replace admin1 = "azad jammu and Kashmir" if admin1=="ajk"&country_abrev=="PK"
replace admin1 = "gilgit baltistan" if admin1=="gb"&country_abrev=="PK"
replace admin1 = "islamabad capital territory" if admin1=="ict"&country_abrev=="PK"
replace admin1 = "khyber pakhtunkhwa" if admin1=="kpk"&country_abrev=="PK"
replace admin1 = "federally administered tribal areas" if admin1=="fata"&country_abrev=="PK"

gen admin_alt = admin1 if country_abrev=="MV"|country_abrev=="MR"|country_abrev=="HT"|country_abrev=="PK"

replace admin1 = sample_strata if country_abrev=="MV"
replace admin1 = "inchiri" if (sample_strata == "inchiri - rural" | sample_strata == "inchiri - urban")&country_abrev=="MR"
replace admin1 = "rest-ouest" if admin1 =="aire metropolitaine"&country_abrev=="HT"
replace admin1 = "khyber pakhtunkhwa" if admin1=="federally administered tribal areas"&country_abrev=="PK"

replace admin1="theis" if country_abrev=="SN" & admin1=="thi?s"
replace admin1="abuja federal capital territory" if country_abrev=="NG" & admin1=="fct abuja"
/*replace admin1="pemba north" if country_abrev=="TZ" & admin1=="kaskazini pemba"
replace admin1="zanzibar north" if country_abrev=="TZ" & admin1=="kaskazini unguja"
replace admin1="pemba south" if country_abrev=="TZ" & admin1=="kusini pemba"
replace admin1="zanzibar south" if country_abrev=="TZ" & admin1=="kusini unguja"
replace admin1="zanzibar town/west" if country_abrev=="TZ" & admin1=="mjini magharibi"
replace admin1="mbeya" if country_abrev=="TZ" & admin1=="songwe"*/

replace admin1="Eastern Province" if country_abrev=="RW" & admin1=="east" 
replace admin1="Kigali City" if country_abrev=="RW" & admin1=="kigali" 
replace admin1="Northern Province" if country_abrev=="RW" & admin1=="north" 
replace admin1="Southern Province" if country_abrev=="RW" & admin1=="south" 
replace admin1="Western Province" if country_abrev=="RW" & admin1=="west"

replace admin1="battambang & pailin" if country_abrev=="KH2" & inlist(admin1, "battambang", "pailin")
replace admin1="mondul kiri & rattanak kiri" if country_abrev=="KH2" & inlist(admin1, "mondul kiri", "ratanak kiri")
replace admin1="kampot & kep" if country_abrev=="KH2" & inlist(admin1, "kampot", "kep")
replace admin1="preah sihanouk & kaoh kong" if country_abrev=="KH2" & inlist(admin1, "preah sihanouk", "koh kong")
replace admin1="preah vihear & steung treng" if country_abrev=="KH2" & inlist(admin1, "preah vihear", "stung treng")
replace admin1="siem reap" if country_abrev=="KH2" & inlist(admin1, "siemreap")
replace admin1="kampong cham" if country_abrev=="KH2" & inlist(admin1, "tboung khmum")
replace admin1="banteay mean chey" if country_abrev=="KH2" & admin1=="banteay meanchey"
replace admin1="otdar mean chey" if country_abrev=="KH2" & admin1=="otdar meanchey"
replace admin1="mondol kiri & rattanak kiri" if country_abrev=="KH2" & admin1=="mondul kiri & rattanak kiri"


replace admin1="nairobi city" if country_abrev=="KE" & admin1=="nairobi"
replace admin1="Taita/Taveta" if country_abrev=="KE" & admin1=="taita taveta"
replace admin1="homabay" if country_abrev=="KE" & admin1=="homa bay"

replace admin1="Central" if  country_abrev=="UG" & inlist(admin1, "south buganda", "north buganda", "kampala")
replace admin1="Western" if country_abrev=="UG" & inlist(admin1, "bunyoro", "tooro", "ankole", "kigezi")
replace admin1="Estern" if country_abrev=="UG" & inlist(admin1, "west nile", "acholi", "lango", "karamoja")
replace admin1="Northern" if country_abrev=="UG" & inlist(admin1, "busoga", "bukedi", "bugisu", "teso")

save "${combined_data}\Final_Individual_DHS_only.dta", replace

*Append household level data
********************************************************************************
use "${combined_data}\\DHS_Cross_Country_HH_Data.dta", clear

*append using "${tonga_data}\Tonga_Cleaned_Household_Level_Data_Trimmed.dta", force

la var admin2 "Admin 2 level"
la var psu "PSU"
la var school_new "Currently attending school"
la var edattain_new "Educational Attainment"
la var computer "Individual uses computer"
la var youth_idle "Individual uses computer"
la var work_manufacturing "In manufacturing"
la var work_managerial "Women in managerial position"
la var work_informal "Informal work"
la var fp_demsat_mod "Women with family planning needs met"
la var health_insurance "Adults with a health insurance coverage"
la var social_prot "Adults in households receiving social protection"
la var food_insecure "Adults in food insecure households"
la var shock_any "Adults in households that experienced a shock recently"
la var health_exp_hh "Household health expenditures out of total consumption expenditures"
la var dv_weight "DHS Domestic Violence sample weight"
la var ind2_weight "DHS Individual sample weight"

*Change DHS individual survey variables to missing for individuals ages above 45
replace ind_emp=. if age>=45
replace lit_new=. if age>=45
replace internet=. if age>=45
replace mobile_own=. if age>=45
replace fp_demsat_mod=. if age>=45
replace anyviolence_byh_12m=. if age>=45

gen ssu = country_dataset_year+ hh_id if country_abrev!="MR"
replace ssu = country_dataset_year+cluster_id if country_abrev=="MR"

gen tsu = country_dataset_year+cluster_id+ hh_id if country_abrev=="MR"
replace tsu = "" if country_abrev!="MR"

replace admin1 = "azad jammu and Kashmir" if admin1=="ajk"&country_abrev=="PK"
replace admin1 = "gilgit baltistan" if admin1=="gb"&country_abrev=="PK"
replace admin1 = "islamabad capital territory" if admin1=="ict"&country_abrev=="PK"
replace admin1 = "khyber pakhtunkhwa" if admin1=="kpk"&country_abrev=="PK"
replace admin1 = "federally administered tribal areas" if admin1=="fata"&country_abrev=="PK"

gen admin_alt = admin1 if country_abrev=="MV"|country_abrev=="MR"|country_abrev=="HT"|country_abrev=="PK"

replace admin1 = sample_strata if country_abrev=="MV"
replace admin1 = "inchiri" if (sample_strata == "inchiri - rural" | sample_strata == "inchiri - urban")&country_abrev=="MR"
replace admin1 = "rest-ouest" if admin1 =="aire metropolitaine"&country_abrev=="HT"
replace admin1 = "khyber pakhtunkhwa" if admin1=="federally administered tribal areas"&country_abrev=="PK"

replace admin1="theis" if country_abrev=="SN" & admin1=="thi?s"
replace admin1="abuja federal capital territory" if country_abrev=="NG" & admin1=="fct abuja"

/*replace admin1="pemba north" if country_abrev=="TZ" & admin1=="kaskazini pemba"
replace admin1="zanzibar north" if country_abrev=="TZ" & admin1=="kaskazini unguja"
replace admin1="pemba south" if country_abrev=="TZ" & admin1=="kusini pemba"
replace admin1="zanzibar south" if country_abrev=="TZ" & admin1=="kusini unguja"
replace admin1="zanzibar town/west" if country_abrev=="TZ" & admin1=="mjini magharibi"
replace admin1="mbeya" if country_abrev=="TZ" & admin1=="songwe"*/

replace admin1="Eastern Province" if country_abrev=="RW" & admin1=="east" 
replace admin1="Kigali City" if country_abrev=="RW" & admin1=="kigali" 
replace admin1="Northern Province" if country_abrev=="RW" & admin1=="north" 
replace admin1="Southern Province" if country_abrev=="RW" & admin1=="south" 
replace admin1="Western Province" if country_abrev=="RW" & admin1=="west"

replace admin1="battambang & pailin" if country_abrev=="KH2" & inlist(admin1, "battambang", "pailin")
replace admin1="mondul kiri & rattanak kiri" if country_abrev=="KH2" & inlist(admin1, "mondul kiri", "ratanak kiri")
replace admin1="kampot & kep" if country_abrev=="KH2" & inlist(admin1, "kampot", "kep")
replace admin1="preah sihanouk & kaoh kong" if country_abrev=="KH2" & inlist(admin1, "preah sihanouk", "koh kong")
replace admin1="preah vihear & steung treng" if country_abrev=="KH2" & inlist(admin1, "preah vihear", "stung treng")
replace admin1="siem reap" if country_abrev=="KH2" & inlist(admin1, "siemreap")
replace admin1="kampong cham" if country_abrev=="KH2" & inlist(admin1, "tboung khmum")
replace admin1="banteay mean chey" if country_abrev=="KH2" & admin1=="banteay meanchey"
replace admin1="otdar mean chey" if country_abrev=="KH2" & admin1=="otdar meanchey"
replace admin1="mondol kiri & rattanak kiri" if country_abrev=="KH2" & admin1=="mondul kiri & rattanak kiri"

replace admin1="nairobi city" if country_abrev=="KE" & admin1=="nairobi"
replace admin1="Taita/Taveta" if country_abrev=="KE" & admin1=="taita taveta"
replace admin1="homabay" if country_abrev=="KE" & admin1=="homa bay"

replace admin1="Central" if  country_abrev=="UG" & inlist(admin1, "south buganda", "north buganda", "kampala")
replace admin1="Western" if country_abrev=="UG" & inlist(admin1, "bunyoro", "tooro", "ankole", "kigezi")
replace admin1="Estern" if country_abrev=="UG" & inlist(admin1, "west nile", "acholi", "lango", "karamoja")
replace admin1="Northern" if country_abrev=="UG" & inlist(admin1, "busoga", "bukedi", "bugisu", "teso")

save "${combined_data}\Final_Household_DHS_only.dta", replace

