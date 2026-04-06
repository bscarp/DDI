/*
This do file was written to code variables to generate estimates for the Disability Statistics – Estimates database, available at https://www.ds-e.disabilitydatainitiative.org/

Reference to appendix and paper:

For more information on indicators, see the appendices on the website above as well as Carpenter et al (2024).

Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478

Questions or comments can be sent to: disabilitydatainitiative.help@gmail.com

Author: Kaviyarasan Patchaiappan

Suggested citation: Carpenter, B., Kamalakannan, S., Patchaiappan, K., Theiss, K., Yap, J., Hanass-Hancock, J., Murthy, G., Pinilla-Roncancio, M., Rivas Velarde, M. and Mitra, S. (2024) "Data Resource Profile: The Disability Statistics - Estimates Database (DS-E Database). An innovative database of internationally comparable statistics on disability inequalities", International Journal of Population Data Science, 8(6). doi: 10.23889/ijpds.v8i6.2478
*/

cd "D:\DDI\Indonesia"

use "D:\DDI\Indonesia\SAK02025\sak202502_15_p1.dta", clear

label variable KODE_PROV "Province Code"
label variable KLASIFIKAS "Urban-Rural Classification"
label variable PSU "Primary Sampling Unit"
label variable SSU "Secondary Sampling Unit"
label variable STRATA "Strata"
label variable JMLART "NUMBER OF HOUSEHOLD MEMBERS"
label variable JML_ART5 "NUMBER OF HOUSEHOLD MEMBERS AGED 5 YEARS AND OLDER"
label variable PPNO "201. Household Member Serial Number"
label variable DEM_SEX "204. Gender"
label variable DEM_REL "207. Relationship to Head of Household"
label variable DEM_BTH_D "208d. Date of Birth"
label variable DEM_BTH_M "208m. Month of Birth"
label variable DEM_BTH_Y "208y. Year of Birth"
label variable DEM_AGE "209. Age"
label variable DEM_MRT "210. Marital Status"
label variable DEM_SKLH "301. ​​School Participation"
label variable DEM_EDL "302. Highest Level of Education Completed"
label variable DEM_PNYLGR "303. Provider of Highest Level of Education Completed"
label variable DEM_EDF_KD "304. Field of Study/Major Code"
label variable DEM_LLS_M "305m. Month of Highest Level of Education Graduated"
label variable DEM_LLS_Y "305y. Year of graduation from school/college with highest level of education"
label variable DEM_TRN "306. Attended training/courses/training"
label variable DEM_SERT "307. Obtained certificates from said training/courses/training"
label variable DEM_P1TH "308. Certified and uncertified training conducted in the last year"
label variable DEM_JMLP "309. Number of training/courses/trainings attended in the last year"
label variable DEM_KDPL1 "310_1. Code for first training in the last year"
label variable DEM_PL4MG1 "311_1. First training conducted in the last 4 weeks"
label variable DEM_KDPL2 "310_2. Code for second training in the last year"
label variable DEM_PL4MG2 "311_2. Second training conducted in the last 4 weeks"
label variable DEM_KDPL3 "310_3. Third training code in the last year"
label variable DEM_PL4MG3 "311_3. Third training conducted in the last 4 weeks"
label variable DEM_SDGPL "312. Currently attending training/courses/training (not necessarily certified)"
label variable DEM_MG "313. Have participated in an Internship/Field Work Practice (PKL) Program"
label variable DEM_MGSERT "314. Obtained a certificate from the Internship/Field Work Practice (PKL) Program"
label variable DEM_IBU_NO "401. Mother's birth number"
label variable MIG_BTH "402. Place of birth"
label variable MIG_PROV "403. Province of birth"
label variable MIG_KAB "404. Regency/City of birth"
label variable MIG_NEG "405. Country of birth"
label variable MIG_LARR_M "406m. Month of arrival in Indonesia"
label variable MIG_LARR_Y "406y. Year of Arrival in Indonesia"
label variable MIG_5TH "407. Residence in February 2020 (5 years ago)"
label variable MIG_5_PROV "408. Province of Residence in February 2020 (5 years ago)"
label variable MIG_5_KAB "409. Regency/City of Residence in February 2020 (5 years ago)"
label variable MIG_5_NEG "410. Country of Residence in February 2020 (5 years ago)"
label variable MIG_REAS "411. Main Reason for Moving to Indonesia"
label variable MIG_CTZ "412. Citizenship"
label variable MIG_CTZ_N "413. Citizenship Code (Foreigner)"
label variable DIF_SIGHT "501. Difficulty seeing even with glasses?"
label variable DIF_HEAR "502. Difficulty hearing even with a hearing aid?"
label variable DIF_MOBI "503. Difficulty walking or climbing stairs?"
label variable DIF_HAND "504. Difficulty using/moving your hands/fingers?"
label variable DIF_CONC "505. Difficulty remembering or concentrating?"
label variable DIF_CARE "506. Difficulty with self-care such as grooming/dressing"
label variable DIF_COMM "507. Difficulty communicating"
label variable DIF_EMOSI "508. Behavioral/Emotional Disorders"
label variable TIK_HP "601. Owns/Controls a Cell Phone/Smartphone"
label variable TIK_A "602a. Used a Computer in the Last 3 Months"
label variable TIK_B "602b. Used a Smartphone in the Last 3 Months"
label variable TIK_C "602c. Used Other Digital Technology in the Last 3 Months"
label variable TIK_D "602d. Used the Internet in the Last 3 Months"
label variable TIK_E "602e. Did Not Use Digital Technology in the Last 3 Months"
label variable TIK_INET_A "603a. Used the Internet for Communication in the Last 3 Months"
label variable TIK_INET_B "603b. Used the Internet for Information Access in the Last 3 Months"
label variable TIK_INET_C "603c. Used the Internet for Selling Goods or Services in the Last 3 Months"
label variable TIK_INET_D "603d. Used the Internet for Purchasing Goods or Services in the Last 3 Months"
label variable TIK_INET_E "603e. Used the Internet for Internet Banking in the Last 3 Months"
label variable TIK_INET_F "603f. Internet for other purposes in the last 3 months"
label variable ATW_PAY "701. Working for pay/wages/salary for at least one hour in the last week"
label variable ATW_PFT "702. Running a business/farming/other activities to earn profit/income for at least one hour in the last week"
label variable ATW_FAM "703. Helping with other family/relatives' business/work for at least one hour in the last week"
label variable ABS_JOB "801. Actually having a job/business activity, but not working/not running the business in the last week"
label variable ABS_WHY "802. Main reason for being temporarily unemployed during the last week"
label variable ABS_SEA ""
label variable ABS_DUR "804. Will return to the same job/business within 3 months or less from the time of temporary absence"
label variable ABS_PAY "805. Continues to receive pay during the temporary absence"
label variable AGF_CHK_A "901a. Food crop agriculture"
label variable AGF_CHK_B "901b. Non-food crop agriculture"
label variable AGF_CHK_C "901c. Livestock raising"
label variable AGF_CHK_D "901d. Fisheries"
label variable AGF_CHK_E "901e. Work in other fields"
label variable AGF_ANY_A "902a. Conducted any food crop farming activities in the past week"
label variable AGF_ANY_B "902b. Conducted any non-food crop farming activities in the past week"
label variable AGF_ANY_C "902c. Conducted any livestock raising activities in the past week"
label variable AGF_ANY_D "902d. Conducted any fisheries activities in the past week"
label variable AGF_ANY_E "902e. Performing any other activities in the past week"
label variable AGF_MKT "903. Using goods/products resulting from work in that field"
label variable AGF_HIR "904. Employed by others to perform work/activities"
label variable MJJ_MULT "1001. Usually having more than one job/business"
label variable MJJ_EMPREL "1005. Main employment status"
label variable MJJ_KATEGO "1006. Business Field 17 KBLI Category 2020"
label variable MJJ_KATE_A "1006. Business Field 17 KBLI Category 2015"
label variable MJJ_KBJI20 "1007. Type of work KBJI 2014 (1 digit)"
label variable MJJ_KBJI19 "1007. Type of work KJI 1982 (1 digit)"
label variable MJJ_CFWCHK "1008. Who usually makes decisions about managing the family/household business"
label variable MJJ_CFWINC "1009. Who usually decides how the income earned from this business will be used"
label variable MJJ_HIRESA ""
label variable MJJ_HIRESB "1010b. Family businesses employ workers/employees/staff who are paid regularly."
label variable MJJ_JMLBRH "1011. Number of paid permanent workers/employees/staff."
label variable MJJ_PTT "1012. This business employs casual workers/family workers."
label variable MJJ_JPTT "1013. Number of paid casual workers."
label variable MJJ_REM_TA "1014a. Salary as payment for primary work in the past month."
label variable MJJ_REM_TB "1014b. Piecework as payment for primary work in the past month."
label variable MJJ_REM_TC "1014c. Commission as payment for primary work in the past month."
label variable MJJ_REM_TD "1014d. Tip as payment for primary work in the past month."
label variable MJJ_REM_TE "1014e. Service fees as payment for primary work in the past month."
label variable MJJ_REM_TF "1014f. Food/accommodation as payment for primary work in the past month."
label variable MJJ_REM_TG "1014g. Products/goods as payment for primary work in the past month."
label variable MJJ_REM_TH "1014h. Piecework as payment for primary work in the past month."
label variable MJJ_REM_TI "1014i. Other cash as payment for primary work in the past month."
label variable MJJ_REM_TJ "1014j. Unpaid from primary employment in the past month"
label variable MJJ_P_UPH "1015. Pay period/wage usually at primary employment"
label variable MJJ_UPAH_U "1016u. Net salary/wages received from primary employment during the past month"
label variable MJJ_UPAH_B "1016b. Net salary/wages received from primary employment during the past month"
label variable MJJ_LABA_U "1017u. Cash profit earned during the past month from this primary business activity"
label variable MJJ_LABA_B "1017b. Cash profit earned during the past month from this primary business activity"
label variable MJJ_TI_A "1018a. Using a computer in primary employment"
label variable MJJ_TI_B "1018b. Using a mobile phone/smartphone in primary employment"
label variable MJJ_TI_C "1018c. Using other digital technology in primary employment"
label variable MJJ_TI_D "1018d. Using the internet in primary employment"
label variable MJJ_INET_A "1019a. Internet for communication in primary employment"
label variable MJJ_INET_B "1019b. Internet for promotion in primary employment"
label variable MJJ_INET_C "1019c. Internet for accessing information in primary employment"
label variable MJJ_INET_D "1019d. Internet for selling goods and services on social media in primary employment"
label variable MJJ_INET_E "1019e. Internet for selling goods and services in marketplaces in primary employment"
label variable MJJ_INET_F "1019f. Internet for purchasing goods and services on social media in primary employment"
label variable MJJ_INET_G "1019g. Internet for purchasing goods and services in marketplaces in primary employment"
label variable MJJ_INET_H "1019h. Internet for internet banking in the marketplace at primary job"
label variable MJJ_INET_I "1019i. Other internet at primary job"
label variable WKT_SEN_U "1020. Monday main working hours"
label variable WKT_SEL_U "1020. Tuesday main working hours"
label variable WKT_RAB_U "1020. Wednesday main working hours"
label variable WKT_KAM_U "1020. Thursday main working hours"
label variable WKT_JUM_U "1020. Friday main working hours"
label variable WKT_SAB_U "1020. Saturday main working hours"
label variable WKT_MNG_U "1020. Sunday main working hours"
label variable WKT_JML_U "1020. Number of main working hours"
label variable WKT_BLT_U "1020. (Rounded) number of hours worked per week at main job"
label variable WKT_MJJ "1021. Number of hours usually worked per week at this main job/business"
label variable MJU_INS_VA "1101. Type of agency/institution/institution at the workplace/business"
label variable MJU_SIZ "1102. Total number of people working at the workplace, including employers and respondents"
label variable MJU_PLC "1103. Place of usual work"
label variable MJU_KOMU "1104. Commuting to and from home/residence to the office/workplace"
label variable MJU_LOKASI "1105. Place of work at the main job in the past week"
label variable MJU_PROV "1106. Province of work"
label variable MJU_KAB "1107. Regency/city of work"
label variable MJU_NEG "1108. Country of work"
label variable MJU_MODA_A "1109a. Private/official car/employee bus"
label variable MJU_MODA_B "1109b. Private/official motorcycle"
label variable MJU_MODA_C "1109c. Other private vehicles"
label variable MJU_MODA_D "1109d. Public transportation"
label variable MJU_MODA_E "1109e. Online transportation"
label variable MJU_MODA_F "1109f. Other transportation"
label variable MJU_MODA_G "1109g. Walking/No other means of transportation"
label variable MJU_MODA_U "1110. Main mode of transportation to work"
label variable MJT_SYR_M "1201m. Month of starting employment at this job or business"
label variable MJT_SYR_Y "1201y. Year of starting employment at this job or business"
label variable MJT_LAMA "1202. Length of time to find work/prepare a business at this job, if working since February 2024"
label variable MJT_UPAH "1203. Amount of first net monthly wage/salary (either in cash or in kind)"
label variable MJC_CONTRA "1301. Have an employment agreement/contract"
label variable MJC_CONOP "1302. Period of the employment contract or agreement"
label variable MJC_TOTAL "1303. Estimated length of employment in this job"
label variable MJC_DUR "1304. Total length of the employment contract or agreement"
label variable MJC_PKJ "1305. Have had more than one employer/employer in the past month"
label variable MCD_TASKSE "1306. Work is seasonal"
label variable MCD_CH "1307. Employment contract or agreement specifies/agreed upon number of working hours"
label variable MCD_CH_NUM "1308. Working hours agreed upon in the employment contract/agreement"
label variable MCD_CM_A "1309a. Employment contract guarantees minimum number of hours or amount of work"
label variable MCD_CM_B "1309b. Have minimum number of hours or work agreed upon with employer/company"
label variable MCD_SP "1310. Registered as a member of a trade union"
label variable MCD_ANK_KD "1311. Have experienced a work-related health hazard in the past 12 months"
label variable MCD_ANK_LK "1312. Work in an unsafe or unhealthy environment"
label variable MCD_ANK_KF "1313kf. Have experienced physical violence in the workplace"
label variable MCD_ANK_KE "1313k. Have experienced emotional/psychological violence in the workplace"
label variable MCD_ANK_KS "1313ks. Have experienced sexual violence in the workplace?"
label variable MIE_SOC_A "1401a. The workplace provides health insurance."
label variable MIE_SOC_B "1401b. The workplace provides work-related accident insurance."
label variable MIE_SOC_C "1401c. The workplace provides death insurance."
label variable MIE_SOC_D "1401d. The workplace provides old-age insurance."
label variable MIE_SOC_E "1401e. The workplace provides pension insurance."
label variable MIE_SOC_F "1401f. The workplace provides unemployment insurance."
label variable MIE_SOC_G "1401g. The workplace provides annual leave without deducting basic salary."
label variable MIE_SOC_H "1401h. The workplace provides maternity leave without deducting basic salary."
label variable MIE_SOC_I "1401i. The workplace provides sick leave without deducting basic salary."
label variable MIE_SELF_A "1402a. Pays for own health insurance."
label variable MIE_SELF_B "1402b. Pays for own work accident insurance."
label variable MIE_SELF_C "1402c. Pays for own death insurance."
label variable MIE_SELF_D "1402d. Pays for own old-age insurance."
label variable MIE_SELF_E "1402e. Pays for own pension insurance."
label variable MIE_SELF_F "1402f. Pays for own unemployment insurance."
label variable MJD_SINGLE "1501. The majority of the business/activity income comes from the source."
label variable MJD_SOURCE "1502. Obtains customers/consumers/buyers through other parties."
label variable MJD_SELL_A "1503a. Makes products or provides services for only one company."
label variable MJD_SELL_B "1503b. Sells products or services from only one company."
label variable MJD_SELL_C "1503c. Works with materials or equipment provided by only one company."
label variable MJD_SELL_D "1503d. Does not provide services/receive assistance from one company."
label variable MJD_CONT_A "1504a. The company/intermediary/person sets the price of the product or service offered"
label variable MJD_CONT_B "1504b. The company/intermediary/person determines the minimum number of sales or tasks that must be completed."
label variable MJD_CONT_C "1504c. The company/intermediary/person determines the location, route, or area where the work will be carried out."
label variable MJD_CONT_D "1504d. The company/intermediary/person decides how to organize the work."
label variable MJD_CONT_E "1504e. The company/intermediary/person decides which suppliers to use."
label variable MJD_CONT_F "1504f. The company/intermediary/person provides the location or machinery used."
label variable MJD_CONT_G "1504g. The company/intermediary/person does not determine the operational area."
label variable MJL_REGI "1601. The business/company is registered in the licensing system."
label variable MJL_CORP "1602. The business is a legal entity."
label variable MJL_WKT_M "1603m. The month of registration in the licensing system."
label variable MJL_WKT_Y "1603y. Year registered in the licensing system"
label variable MJL_REGP "1604. Registered as a taxpayer"
label variable MIS_BOOK "1605. Place of work where financial records are kept"
label variable SJB_TEXT "1701. Has other additional work/business activities"
label variable SJJ_EMPREL "1705. Additional employment status"
label variable SJJ_KATEGO "1706. KBLI 2020 additional work"
label variable SJJ_KATE_A "1706. KBLI 2015 additional work"
label variable SJJ_KBJI20 "1707. KBJI 2014 additional work"
label variable SJJ_KBJI19 "1707. KJI 1982 additional work"
label variable SJJ_HIRES "1708. Regularly employ paid laborers/employees/staff in the main additional business?"
label variable SJJ_PTT "1709. Employ casual workers/family members in the main additional business"
label variable SJJ_REGI "1710. Is this main additional business registered in the licensing system?"
label variable WKT_SEN_T "1711. Monday main additional work hours"
label variable WKT_SEL_T "1711. Tuesday main additional work hours"
label variable WKT_RAB_T "1711. Wednesday main additional work hours"
label variable WKT_KAM_T "1711. Thursday main additional work hours"
label variable WKT_JUM_T "1711. Friday main additional work hours"
label variable WKT_SAB_T "1711. Saturday main extra work hours"
label variable WKT_MNG_T "1711. Sunday main extra work hours"
label variable WKT_JML_T "1711. Number of main extra work hours"
label variable WKT_BLT_T "1711. (Rounded) number of main extra work hours"
label variable WKT_SJJ "1712. Typical number of main extra work hours"
label variable SJD_REM_TA "1801a. Wages as payment for main extra work received in the last month"
label variable SJD_REM_TB "1801b. Per unit of work as payment for main extra work received in the last month"
label variable SJD_REM_TC "1801c. Commission as payment for main extra work received in the last month"
label variable SJD_REM_TD "1801d. Tips as payment for main extra work received in the last month"
label variable SJD_REM_TE "1801e. Service fees as payment for main extra work received in the last month"
label variable SJD_REM_TF "1801f. Food/accommodation as payment for main extra work received in the last month"
label variable SJD_REM_TG "1801g. Products/goods as payment for main extra work received in the last month"
label variable SJD_REM_TH "1801h. Contract work as payment for main extra work received in the last month"
label variable SJD_REM_TI "1801i. Other cash payments received from the main additional job in the past month"
label variable SJD_REM_TJ "1801j. Unpaid payments received from the main additional job in the past month"
label variable SJD_SOC_A "1802a. The additional job provides health insurance"
label variable SJD_SOC_B "1802b. The additional job provides work-related accident insurance"
label variable SJD_SOC_C "1802c. The additional job provides death insurance"
label variable SJD_SOC_D "1802d. The additional job provides old-age insurance"
label variable SJD_SOC_E "1802e. The additional job provides pension insurance"
label variable SJD_SOC_F "1802f. The additional job provides unemployment insurance"
label variable SJD_SOC_G "1802g. The additional job provides annual leave without deducting basic salary"
label variable SJD_SOC_H "1802h. The additional job provides maternity leave without deducting basic salary"
label variable SJD_SOC_I "1802i. The additional job provides sick leave without deducting basic salary"
label variable SJD_SINGLE "1803. Most of the business/activity's income comes from"
label variable SJD_SOURCE "1804. Acquiring customers/consumers/buyers through other parties"
label variable SJD_CONT_A "1805a. Intermediaries set the price of the products or services offered"
label variable SJD_CONT_B "1805b. The intermediary determines where, when, or how the work should be done"
label variable SJD_CONT_C "1805c. The intermediary determines other than those mentioned above"
/*label variable SJD_SELF_A "1806a. Self-pay for work-related health insurance"
label variable SJD_SELF_B "1806b. Self-pay for work-related accident insurance"
label variable SJD_SELF_C "1806c. Self-pay for work-related death insurance"
label variable SJD_SELF_D "1806d. Self-pay for work-related old-age insurance"
label variable SJD_SELF_E "1806e. Self-pay for work-related pension insurance"
label variable SJD_SELF_F "1806f. Self-pay for work-related unemployment insurance"
label variable WKT_SEN_S "1901. Monday hours"
label variable WKT_SEL_S "1901. Tuesday hours"
label variable WKT_RAB_S "1901. Wednesday hours"
label variable WKT_KAM_S "1901. Thursday hours"
label variable WKT_JUM_S "1901. Friday hours"
label variable WKT_SAB_S "1901. Saturday hours"
label variable WKT_MNG_S "1901. Sunday hours"
label variable WKT_JML_S "1901. Total number of hours worked"
label variable WKT_BLT_S "1901. (Rounded) total number of hours worked"
label variable WKT_USS "1902. Usual number of hours worked"
label variable WKT_SRHOJB "1903. Looking for additional work/other income for the past four weeks until yesterday"
label variable WKT_WNTMRH "1904. Wanting to work more hours per week than usual to increase income"
label variable WKT_JK "1905. Main reason for not wanting to work more hours"
label variable WKT_AVLMRH "1906. Ready/willing to work more hours in the next two weeks"
label variable WKT_NUMMRH "1907. Hours that can be added to work per week"
label variable WKT_PNWRN "1908. If offered a job, willing to accept, within the past week"
label variable WKI_INAD "1909. Wanting to change current main job conditions"
label variable WKI_RES "1910. Main reason for wanting to change current job conditions"
label variable SRH_KERJA "2001. Looking for a job in the past week"
label variable SRH_USAHA "2002. Preparing a new business in the past week"
label variable SRH_LAMA_Y "2003y. Years of looking for a job/preparing a business"
label variable SRH_LAMA_M "2003m. Months spent looking for work/preparing a business"
label variable SRH_ALSN "2004. Main reasons for not looking for work and starting a business in the past week"
label variable SRH_JOB "2005. Actively looking for work in the past month"
label variable SRH_BUS "2006. Preparing a new business in the past month"
label variable SRH_MTD "2007. Main efforts to find work/prepare a business in the past month"
label variable SRH_ACT "2008. Things other than reading job advertisements to find work"
label variable SRH_DUR "2009. Length of time unemployed and trying to find work/start a business"
label variable SRH_YER "2010. Looking for work/preparing a business in the past year"
label variable SRH_DES "2011. Wanting a job"
label variable SRH_DWY "2012. Main reasons for not looking for work/not starting a business in the past month"
label variable SRH_FTR "2013. How long have you expected to start working in this new job or business?"
label variable SRH_FAN "2014. Could you start working within the last week if the decision is up to the respondent?"
label variable SRH_AVN "2015. Ready/willing to start working/business within the next week if job/business opportunities become available?"
label variable SRH_AVL "2016. Ready/willing to start working/business within the next 2 weeks?"
label variable SRH_NAR "2017. Reason for not being ready/willing to start working/business within the next 2 weeks?"
label variable SRH_MAC "2018. Statement that best describes your current primary activity?"
label variable MPK_MULAI "2101. When did you get a job/start a business after graduating from your highest level of education?"
label variable MPK_WKT_M "2102. Months of employment after graduating from your highest level of education?"
label variable MPK_WKT_Y "2102. Years of employment after graduating from your highest level of education?"
label variable MPK_PERNAH "2103. Have had a previous job/business?"
label variable MPK_HENTI "2104. Resigned from that job within the last year."
label variable MPK_WKT_HM "2105m. Month of Retirement"
label variable MPK_WKT_HY "2105y. Year of Retirement"
label variable MPK_STATUS "2109. Employment Status in Retired Job"
label variable MPK_KATEGO "2110. Business Field 17 KBLI Category 2020"
label variable MPK_KATE_A "2110. Business Field 17 KBLI Category 2015"
label variable MPK_KBJI20 "2111. KBJI 2014 occupation"
label variable MPK_KBJI19 "2111. KJI 1982"
label variable MPK_ALSN "2112. Main Reason for Retirement"
label variable MKL_SKLH "2201. Attending School in the Last Week"
label variable MKL_RUTA "2202. Taking Care of the Household in the Last Week"
label variable MKL_LAIN "2203. Other Activities in the Last Week"
label variable MKL_UTAMA "2204. Activities Using the Most Time in the Last Week"
label variable OPC_HCROP "2301. Planting Food Crops Mainly for Home Consumption in the Last Week"
label variable OPC_HDAY "2302. Number of Days Performed This Task in the Last Week"
label variable OPC_HHRS "2303. Hours Per Day Spent Performing This Task in the Last Week"
label variable OPF_HF_AA "2401aa. Raising or Caring for Livestock in the Last Week"
label variable OPF_HF_AB "2401ab. Fishing, Collecting Shellfish, or Fish Farming in the Last Week"
label variable OPF_HF_AC "2401ac. Gathering wild foods in the past week"
label variable OPF_HF_AD "2401ad. Hunting in the past week"
label variable OPF_HF_AE "2401ae. Preparing preserved food/drinks for storage in the past week"
label variable OPF_HF_AF "2401af. Not engaging in any of the above activities"
label variable OPF_HF_BA "2401ba. Gathering wild foods in the past week primarily for household consumption"
label variable OPF_HF_BB "2401bb. Hunting in the past week primarily for household consumption"
label variable OPF_HF_BC "2401bc. Preserving food and beverages for storage in the past week, primarily for household consumption."
label variable OPF_HF_BD "2401bd. Not gathering wild foods or hunting, and preserving food primarily for household consumption."
label variable OPF_HDAY "2402. Number of days in the past week engaged in these activities."
label variable OPF_HHRS "2403. Average hours per day in the past week engaged in these activities."
label variable PKLN_PERGI "2501. Ever traveled abroad to work as a laborer/employee/staff."
label variable PKLN_WKT_Y "2502y. Year of traveling abroad to work."
label variable PKLN_WKT_M "2502m. Month of departure abroad for work"
label variable PKLN_NEG "2503. Country of employment at last departure"
label variable PKLN_KATEG "2507. Business Field 17 KBLI Category 2020"
label variable PKLN_KAT_A "2507. Business Field 17 KBLI Category 2015"
label variable PKLN_KBJI2 "2508. KBJI 2014"
label variable PKLN_KBJI1 "2508. KJI 1982"
label variable PKLN_CARA "2509. Method of obtaining the job"
label variable PKLN_MASUK "2510. Method of entry to the last country to obtain the job"
label variable PKLN_BIAYA "2511. Costs paid to obtain the first job in the country"
label variable PKLN_UPAH "2512. Average monthly wage/salary earned in the first year of work"
label variable JENISKEGIA "Type of Activity"
label variable STATUS_PEK "Employment Status"*/

* Define value labels for province codes
label define lbl_kode_prov ///
    11 "Aceh" ///
    12 "Sumatera Utara" ///
    13 "Sumatera Barat" ///
    14 "Riau" ///
    15 "Jambi" ///
    16 "Sumatera Selatan" ///
    17 "Bengkulu" ///
    18 "Lampung" ///
    19 "Bangka-Belitung" ///
    21 "Kepulauan Riau" ///
    31 "DKI Jakarta" ///
    32 "Jawa Barat" ///
    33 "Jawa Tengah" ///
    34 "DI Yogyakarta" ///
    35 "Jawa Timur" ///
    36 "Banten" ///
    51 "Bali" ///
    52 "Nusa Tenggara Barat" ///
    53 "Nusa Tenggara Timur" ///
    61 "Kalimantan Barat" ///
    62 "Kalimantan Tengah" ///
    63 "Kalimantan Selatan" ///
    64 "Kalimantan Timur" ///
    65 "Kalimantan Utara" ///
    71 "Sulawesi Utara" ///
    72 "Sulawesi Tengah" ///
    73 "Sulawesi Selatan" ///
    74 "Sulawesi Tenggara" ///
    75 "Gorontalo" ///
    76 "Sulawesi Barat" ///
    81 "Maluku" ///
    82 "Maluku Utara" ///
    91 "Papua Barat" ///
    92 "Papua Barat Daya" ///
    94 "Papua" ///
    95 "Papua Selatan" ///
    96 "Papua Tengah" ///
    97 "Papua Pegunungan"
label value KODE_PROV lbl_kode_prov

label define KLASIFIKAS 1 "Urban" 2"Rural"
label value KLASIFIKAS KLASIFIKAS

label define DEM_SEX 1 "Male" 2 "Female"
label value DEM_SEX DEM_SEX

label define lbl_dem_sklh ///
    1 "HAVE NOT BEEN TO SCHOOL" ///
	2 "STILL AT SCHOOL" ///
	3 "NO LONGER GOING TO SCHOOL"

label values DEM_SKLH lbl_dem_sklh
label define lbl_dem_edl ///
    1  "NOT/NOT FINISHED ELEMENTARY SCHOOL" ///
    2  "ELEMENTARY SCHOOL/MI/SDLB/PACKAGE A" ///
    3  "JUNIOR HIGH SCHOOL/MTS/SMPLB/PACKAGE B" ///
    4  "JUNIOR HIGH SCHOOL/MA/SMLB/PACKAGE C" ///
    5  "VOCATORIAL HIGH SCHOOL" ///
    6  "VOCATORIAL HIGH SCHOOL" ///
    7  "DIPLOMA I/II/III" ///
    8  "DIPLOMA IV" ///
    9  "S1" ///
    10 "S2" ///
    11 "APPLIED S2" ///
    12 "S3"
label values DEM_EDL lbl_dem_edl

label define lbl_dif ///
    1 "NO DIFFICULTY / IMPAIRMENT" ///
    2 "YES, SOME DIFFICULTY" ///
    3 "YES, A LOT OF DIFFICULTY" ///
    4 "UNABLE TO DO AT ALL"

label values DIF_SIGHT lbl_dif
label values DIF_HEAR  lbl_dif
label values DIF_MOBI  lbl_dif
label values DIF_CONC  lbl_dif
label values DIF_CARE  lbl_dif
label values DIF_COMM  lbl_dif

label define lbl_yes_no 1 "Yes" 2 "No"

label values  TIK_HP  lbl_yes_no
label values  TIK_A  lbl_yes_no
label values  TIK_B  lbl_yes_no
label values  TIK_C  lbl_yes_no
label values  TIK_D  lbl_yes_no
label values  TIK_E  lbl_yes_no
label values  TIK_INET_A  lbl_yes_no
label values  TIK_INET_B  lbl_yes_no
label values  TIK_INET_C  lbl_yes_no
label values  TIK_INET_D  lbl_yes_no
label values  TIK_INET_E  lbl_yes_no
label values  TIK_INET_F  lbl_yes_no
label values  ATW_PAY  lbl_yes_no
label values  ATW_PFT  lbl_yes_no
label values  ATW_FAM  lbl_yes_no
label values  ABS_JOB  lbl_yes_no
label values  ABS_SEA  lbl_yes_no
label values  ABS_DUR  lbl_yes_no
label values  ABS_PAY  lbl_yes_no
label values  AGF_CHK_A  lbl_yes_no
label values  AGF_CHK_B  lbl_yes_no
label values  AGF_CHK_C  lbl_yes_no
label values  AGF_CHK_D  lbl_yes_no
label values  AGF_CHK_E  lbl_yes_no
label values  AGF_ANY_A  lbl_yes_no
label values  AGF_ANY_B  lbl_yes_no
label values  AGF_ANY_C  lbl_yes_no
label values  AGF_ANY_D  lbl_yes_no
label values  AGF_ANY_E  lbl_yes_no

label define lbl_mjj_katego ///
    1  "A Agriculture, Forestry & Fisheries" ///
    2  "B Mining & Quarrying" ///
    3  "C Manufacturing" ///
    4  "D Electricity, Gas, Steam/Hot Water & Cold Air Supply" ///
    5  "E Water Treatment, Wastewater Treatment, Waste Material Treatment & Recovery, & Remediation Activities" ///
    6  "F Construction" ///
    7  "G Wholesale & Retail Trade; Automobile & Motorcycle Repair & Maintenance" ///
    8  "H Transportation & Warehousing" ///
    9  "I Accommodation & Food & Beverage Provision" ///
    10 "J Information & Communication" ///
    11 "K Finance & Insurance Activities" ///
    12 "L Real Estate" ///
    13 "M,N Professional & Corporate Services" ///
    14 "O Government Administration, Defense & Mandatory Social Security" ///
    15 "P Education" ///
    16 "Q Human Health & Social Activities" ///
    17 "R,S,T,U Other Services"
label values MJJ_KATEGO lbl_mjj_katego


label define lbl_mjj_kate_a ///
    1  "A Agriculture, Forestry & Fisheries" ///
    2  "B Mining & Quarrying" ///
    3  "C Manufacturing" ///
    4  "D Electricity, Gas, Steam/Hot Water & Cold Air Supply" ///
    5  "E Water Treatment, Wastewater Treatment, Waste Material Treatment & Recovery, & Remediation Activities" ///
    6  "F Construction" ///
    7  "G Wholesale & Retail Trade; Automobile & Motorcycle Repair & Maintenance" ///
    8  "H Transportation & Warehousing" ///
    9  "I Accommodation & Food & Beverage Provision" ///
    10 "J Information & Communication" ///
    11 "K Finance & Insurance Activities" ///
    12 "L Real Estate" ///
    13 "M,N Professional & Corporate Services" ///
    14 "O Government Administration, Defense & Mandatory Social Security" ///
    15 "P Education" ///
    16 "Q Human Health & Social Activities" ///
    17 "R,S,T,U Other Services"
label values MJJ_KATE_A lbl_mjj_kate_a

label define lbl_mjj_emprel ///
    1 "Workers (laborers/employees/staff/freelancers)" ///
    2 "Running a business" ///
    3 "Helping with family or household businesses" ///
    4 "As an intern/paid work experience" ///
    5 "Helping family members who work for others"

label values MJJ_EMPREL lbl_mjj_emprel

label define lbl_mju_siz ///
    1 "1-2" ///
    2 "3-4" ///
    3 "5-9" ///
    4 "10-22" ///
    5 "23-26" ///
    6 "27-49"

label values MJU_SIZ lbl_mju_siz

label define lbl_mjc_contra ///
    1  "YES, WRITTEN CONTRACT/DECISION LETTER" ///
    2  "YES, ORAL AGREEMENT" ///
    3  "THERE IS NO AGREEMENT" ///
    97 "DON'T KNOW"

label values MJC_CONTRA lbl_mjc_contra

* ===============================
* MJJ_KBJI20 – Occupation (KBJI 2020)
* ===============================
label define MJJ_KBJI20_lbl ///
0 "0 Indonesian National Armed Forces (TNI) and Indonesian National Police (POLRI)" ///
1 "1 Managers" ///
2 "2 Professionals" ///
3 "3 Technicians and Professional Assistants" ///
4 "4 Administrative Staff" ///
5 "5 Service Business Personnel and Sales Personnel" ///
6 "6 Skilled Agricultural, Forestry, and Fisheries Workers" ///
7 "7 Processing, Craft, and Non-Formal Workers" ///
8 "8 Machine Operators and Assemblers" ///
9 "9 Manual Laborers"

label values MJJ_KBJI20 MJJ_KBJI20_lbl


* ===============================
* MJJ_KBJI19 – Occupation (KBJI 2019)
* ===============================
label define MJJ_KBJI19_lbl ///
1 "1 Professional, Technical, and Other Personnel" ///
2 "2 Leadership and Administrative Personnel" ///
3 "3 Executive Officials, Administrative Personnel, and Other Personnel" ///
4 "4 Sales Personnel" ///
5 "5 Service Personnel" ///
6 "6 Farming, Gardening, Livestock, Fishing, Forestry, and Hunting Personnel" ///
7 "7/8/9 Production Personnel, Transportation Equipment Operations, and Manual Laborers" ///
8 "X/00 Others (TNI, POLRI, and other Defense Elements)"

label values MJJ_KBJI19 MJJ_KBJI19_lbl


drop if DEM_AGE<15
********Country Name****************
gen country_name="Indonesia"
********Country Abrevation*********
gen country_abrev="ID" 

*********Country_dataset_year*******
gen country_dataset_year="Indonesia LFS 2025"


***Household Weight***

gen hh_weight= WEIGHT

***Individual Weight***

gen ind_weight=WEIGHT

*****Household and Individual Ids***********

egen hh_id= concat(KODE_PROV KLASIFIKAS PSU SSU), format(%25.0g) punct(_)
egen ind_id= concat(KODE_PROV KLASIFIKAS PSU SSU PPNO), format(%25.0g) punct(_)

gen sample_strata=STRATA
gen psu=PSU
*Urban/Rural

gen urban_new=1 if KLASIFIKAS==1
replace urban_new=0 if KLASIFIKAS==2


clonevar admin1=KODE_PROV
*clonevar admin2=departement  

*Gender

gen female= 1 if ( DEM_SEX ==2)
replace female=0 if ( DEM_SEX ==1)

*Age group
 rename DEM_AGE age
gen age_group = 1 if age <=29
replace age_group = 2 if age>=30&age<=44
replace age_group = 3 if age>=45&age<=64
replace age_group = 4 if age>=65
replace age_group =. if age==.

*Difficulties

clonevar seeing_diff_new= DIF_SIGHT 
replace seeing_diff_new=. if DIF_SIGHT==.
clonevar hearing_diff_new= DIF_HEAR 
replace hearing_diff_new=. if DIF_HEAR==.
clonevar mobility_diff_new= DIF_MOBI 
replace mobility_diff_new=. if DIF_MOBI==.
clonevar cognitive_diff_new= DIF_CONC 
replace cognitive_diff_new=. if DIF_CONC==.
clonevar selfcare_diff_new= DIF_CARE 
replace selfcare_diff_new=. if DIF_CARE==.
clonevar comm_diff_new= DIF_COMM
replace comm_diff_new=. if DIF_COMM==.

egen func_difficulty = rowmax(seeing_diff_new hearing_diff_new mobility_diff_new cognitive_diff_new selfcare_diff_new comm_diff_new)

***Disability levels for any domain***
 
gen disability_any = (func_difficulty>=2)
replace disability_any = . if func_difficulty==.

gen disability_some = (func_difficulty==2)
replace disability_some = . if func_difficulty==.

gen disability_atleast = (func_difficulty>=3)
replace disability_atleast = . if func_difficulty==.

gen disability_none = (disability_any==0)
replace disability_none = . if func_difficulty==.

gen disability_nonesome = (disability_none==1|disability_some==1)
replace disability_nonesome = . if func_difficulty==.

gen disability_alot=(func_difficulty==3)
replace disability_alot=. if func_difficulty==.

gen disability_unable=(func_difficulty==4)
replace disability_unable=. if func_difficulty==.


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

gen disability_none_hh = (disability_any_hh==0)

gen disability_nonesome_hh = (disability_none_hh==1|disability_some_hh==1)

gen disability_alot_hh=(func_difficulty_hh==3)
replace disability_alot_hh=. if func_difficulty_hh==.
gen disability_unable_hh=(func_difficulty_hh==4)
replace disability_unable_hh=. if func_difficulty_hh==.



*Everattended School

gen everattended_new=(DEM_SKLH>1)
replace everattended_new=. if DEM_SKLH==.

*Education - completed primary school
*This variable was created for computing multidimensional poverty
gen ind_atleastprimary_all = (DEM_EDL>=3)
replace ind_atleastprimary_all =. if (DEM_EDL==.)

*Atleastprimary education

gen ind_atleastprimary = (DEM_EDL>=3) if age>=25
replace ind_atleastprimary =. if (DEM_EDL==.)

*Atleastsecondary education

gen ind_atleastsecondary = (DEM_EDL>=5) if age>=25
replace ind_atleastsecondary =. if (DEM_EDL==.)

*Mobile use
gen mobile_own=(TIK_HP==1)

*computer use
gen computer=(TIK_A==1)

*internet use
gen internet=(TIK_D==1)

*Employment
gen ind_emp=( ATW_PAY==1 |	ATW_PFT==1 |ATW_FAM==1)
replace ind_emp=. if ATW_PAY==. & ATW_PFT==. & ATW_FAM==. 

*Female at Managerial Work

gen work_managerial2=0 if ind_emp==1 & female==1
replace work_managerial2= 1 if ind_emp==1 & (MJJ_KBJI20==1) & female==1
replace work_managerial2= . if (ind_emp==. & MJJ_KBJI20==. ) 

*Manufacturing Worker

gen work_manufacturing=0 if ind_emp==1
replace work_manufacturing=1 if MJJ_KATEGO==3 & ind_emp==1
replace work_manufacturing=. if ind_emp==0 

*Informal Work

gen work_informal2=.
replace work_informal2=0 if ind_emp==1
replace work_informal2=1 if ind_emp==1 & inlist(MJJ_EMPREL, 3,5) 
replace work_informal2=1 if ind_emp==1 & inlist(MJC_CONTRA, 2,3) 


* Youth idle

gen school_new=(DEM_SKLH==2)
replace school_new=. if DEM_SKLH==.

gen youth_idle=1 if (school_new==0 & ind_emp==0)
replace youth_idle=0 if (school_new==1 | ind_emp==1)
replace youth_idle=. if (school_new==. & ind_emp==.)
replace youth_idle=. if age>24

gen alone=(JMLART==1)

save "Indonesia_LFS_2025.dta",replace 


egen func_diff_missing = rowmiss(seeing_diff_new hearing_diff_new cognitive_diff_new mobility_diff_new selfcare_diff_new comm_diff_new)
*change domain
gen ind_func_diff_missing= (func_diff_missing==6) 
*change domain
egen disaggvar_missing = rowmiss(female age urban_new)

gen ind_disaggvar_missing = (disaggvar_missing >0) 

save "Indonesia_LFS_2025 with missing.dta", replace

drop if ind_func_diff_missing==1 | ind_disaggvar_missing==1

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

save "Indonesia_LFS_2025_Cleaned_Individual_Data_Trimmed.dta", replace

duplicates drop hh_id, force

save "Indonesia_LFS_2025_Cleaned_Household_Level_Data_Trimmed.dta", replace

su disability_any_hh disability_some_hh disability_atleast_hh


