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

**********Vietnam 2009 Labels for admins*************/

label define admin1 ///
1 "Ha Noi" ///
2 "Ha Giang" ///
3 "Cao Bang" ///
6 "Bac Kan" ///
8 "Tuyen Quang" ///
10 "Lao Cai" ///
11 "Dien Bien" ///
12 "Lai Chau" ///
14 "Son La" ///
15 "Yen Bai" ///
17 "Hoa Binh" ///
19 "Thai Nguyen" ///
20 "Lang Son" ///
22 "Quang Ninh" ///
24 "Bac Giang" ///
25 "Phu Tho" ///
26 "Vinh Phuc" ///
27 "Bac Ninh" ///
30 "Hai Duong" ///
31 "Hai Phong city" ///
33 "Hung Yen" ///
34 "Thai Binh" ///
35 "Ha Nam" ///
36 "Nam Dinh" ///
37 "Ninh Binh" ///
38 "Thanh Hoa" ///
40 "Nghe An" ///
42 "Ha Tinh" ///
44 "Quang Binh" ///
45 "Quang Tri" ///
46 "Thua Thien Hue" ///
48 "Da Nang city" ///
49 "Quang Nam" ///
51 "Quang Ngai" ///
52 "Binh Dinh" ///
54 "Phu Yen" ///
56 "Khanh Hoa" ///
58 "Ninh Thuan" ///
60 "Binh Thuan" ///
62 "Kon Tum" ///
64 "Gia Lai" ///
66 "Dak Lak" ///
67 "Dak Nong" ///
68 "Lam Dong" ///
70 "Binh Phuoc" ///
72 "Tay Ninh" ///
74 "Binh Duong" ///
75 "Dong Nai" ///
77 "Ba Ria - Vung Tau" ///
79 "Ho Chi Minh city" ///
80 "Long An" ///
82 "Tien Giang" ///
83 "Ben Tre" ///
84 "Tra Vinh" ///
86 "Vinh Long" ///
87 "Dong Thap" ///
89 "An Giang" ///
91 "Kien Giang" ///
92 "Can Tho city" ///
93 "Hau Giang" ///
94 "Soc Trang" ///
95 "Bac Lieu" ///
96 "Ca Mau"
label value admin1 admin1

label define admin2 ///  
1001 "Ba Dinh" ///
1002 "Hoan Kiem" ///
1003 "Tay Ho" ///
1004 "Long Bien" ///
1005 "Cau Giay" ///
1006 "Dong Da" ///
1007 "Hai Ba Trung" ///
1008 "Hoang Mai" ///
1009 "Thanh Xuan" ///
1016 "Soc Son" ///
1017 "Dong Anh" ///
1018 "Gia Lam" ///
1019 "Tu Liem" ///
1020 "Thanh Tri" ///
1250 "Me Linh" ///
1268 "Ha Dong" ///
1269 "Son Tay" ///
1271 "Ba Vi" ///
1272 "Phuc Tho" ///
1273 "Dan Phuong" ///
1274 "Hoai Duc" ///
1275 "Quoc Oai" ///
1276 "Thach That" ///
1277 "Chuong My" ///
1278 "Thanh Oai" ///
1279 "Thuong Tin" ///
1280 "Phu Xuyen" ///
1281 "ung Hoa" ///
1282 "My Duc" ///
2024 "Ha Giang" ///
2026 "Dong Van" ///
2027 "Meo Vac" ///
2028 "Yen Minh" ///
2029 "Quan Ba" ///
2030 "Vi Xuyen" ///
2031 "Bac Me" ///
2032 "Hoang Su Phi" ///
2033 "Xin Man" ///
2034 "Bac Quang" ///
2035 "Quang Binh" ///
4040 "Cao Bang" ///
4042 "Bao Lam" ///
4043 "Bao Lac" ///
4044 "Thong Nong" ///
4045 "Ha Quang" ///
4046 "Tra Linh" ///
4047 "Trung Khanh" ///
4048 "Ha Lang" ///
4049 "Quang Uyen" ///
4050 "Phuc Hoa" ///
4051 "Hoa An" ///
4052 "Nguyen Binh" ///
4053 "Thach An" ///
6058 "Bac Kan" ///
6060 "Pac Nam" ///
6061 "Ba Be" ///
6062 "Ngan Son" ///
6063 "Bach Thong" ///
6064 "Cho Don" ///
6065 "Cho Moi" ///
6066 "Na Ri" ///
8070 "Tuyen Quang" ///
8072 "Na Hang" ///
8073 "Chiem Hoa" ///
8074 "Ham Yen" ///
8075 "Yen Son" ///
8076 "Son Duong" ///
10080 "Thanh pho Lao Cai" ///
10082 "Bat Xat" ///
10083 "Muong Khuong" ///
10084 "Si Ma Cai" ///
10085 "Bac Ha" ///
10086 "Bao Thang" ///
10087 "Bao Yen" ///
10088 "Sa Pa" ///
10089 "Van Ban" ///
11094 "Thanh pho Dien Bien Phu" ///
11096 "Muong Nhe" ///
11097 "Muong Cha" ///
11095 "Muong Lay" ///
11098 "Tua Chua" ///
11099 "Tuan Giao" ///
11100 "Dien Bien" ///
11101 "Dien Bien Dong" ///
11102 "Muong ang" ///
12105 "Lai Chau" ///
12106 "Tam Duong" ///
12107 "Muong Te" ///
12108 "Sin Ho" ///
12109 "Phong Tho" ///
12110 "Than Uyen" ///
12111 "Tan Uyen" ///
14116 "Son La" ///
14118 "Quynh Nhai" ///
14119 "Thuan Chau" ///
14120 "Muong La" ///
14121 "Bac Yen" ///
14122 "Phu Yen" ///
14123 "Moc Chau" ///
14124 "Yen Chau" ///
14125 "Mai Son" ///
14126 "Song Ma" ///
14127 "Sop Cop" ///
15132 "Thanh pho Yen Bai" ///
15133 "Nghia Lo" ///
15135 "Luc Yen" ///
15136 "Van Yen" ///
15137 "Mu Cang Chai" ///
15138 "Tran Yen" ///
15139 "Tram Tau" ///
15140 "Van Chan" ///
15141 "Yen Binh" ///
17148 "Thanh pho Hoa Binh" ///
17150 "Da Bac" ///
17151 "Ky Son" ///
17152 "Luong Son" ///
17153 "Kim Boi" ///
17154 "Cao Phong" ///
17155 "Tan Lac" ///
17156 "Mai Chau" ///
17157 "Lac Son" ///
17158 "Yen Thuy" ///
17159 "Lac Thuy" ///
19164 "Thanh pho Thai Nguyen" ///
19165 "Song Cong" ///
19167 "Dinh Hoa" ///
19168 "Phu Luong" ///
19169 "Dong Hy" ///
19170 "Vo Nhai" ///
19171 "Dai Tu" ///
19172 "Pho Yen" ///
19173 "Phu Binh" ///
20178 "Thanh pho Lang Son" ///
20180 "Trang Dinh" ///
20181 "Binh Gia" ///
20182 "Van Lang" ///
20183 "Cao Loc" ///
20184 "Van Quan" ///
20185 "Bac Son" ///
20186 "Huu Lung" ///
20187 "Chi Lang" ///
20188 "Loc Binh" ///
20189 "Dinh Lap" ///
22193 "Thanh pho Ha Long" ///
22194 "Mong Cai" ///
22195 "Cam Pha" ///
22196 "Uong Bi" ///
22198 "Binh Lieu" ///
22199 "Tien Yen" ///
22200 "Dam Ha" ///
22201 "Hai Ha" ///
22202 "Ba Che" ///
22203 "Van Don" ///
22207 "Co To" ///
22204 "Hoanh Bo" ///
22205 "Dong Trieu" ///
22206 "Yen Hung" ///
24213 "Thanh pho Bac Giang" ///
24215 "Yen The" ///
24216 "Tan Yen" ///
24217 "Lang Giang" ///
24218 "Luc Nam" ///
24219 "Luc Ngan" ///
24220 "Son Dong" ///
24221 "Yen Dung" ///
24222 "Viet Yen" ///
24223 "Hiep Hoa" ///
25227 "Thanh pho Viet Tri" ///
25228 "Phu Tho" ///
25230 "Doan Hung" ///
25231 "Ha Hoa" ///
25232 "Thanh Ba" ///
25233 "Phu Ninh" ///
25234 "Yen Lap" ///
25235 "Cam Khe" ///
25236 "Tam Nong" ///
25237 "Lam Thao" ///
25238 "Thanh Son" ///
25239 "Thanh Thuy" ///
25240 "Tan Son" ///
26243 "Thanh pho Vinh Yen" ///
26244 "Phuc Yen" ///
26246 "Lap Thach" ///
26247 "Tam Duong" ///
26248 "Tam Dao" ///
26249 "Binh Xuyen" ///
26251 "Yen Lac" ///
26252 "Vinh Tuong" ///
26253 "Song Lo" ///
27256 "Thanh pho Bac Ninh" ///
27258 "Yen Phong" ///
27259 "Que Vo" ///
27260 "Tien Du" ///
27261 "Tu Son" ///
27262 "Thuan Thanh" ///
27263 "Gia Binh" ///
27264 "Luong Tai" ///
30288 "Thanh pho Hai Duong" ///
30290 "Chi Linh" ///
30291 "Nam Sach" ///
30292 "Kinh Mon" ///
30293 "Kim Thanh" ///
30294 "Thanh Ha" ///
30295 "Cam Giang" ///
30296 "Binh Giang" ///
30297 "Gia Loc" ///
30298 "Tu Ky" ///
30299 "Ninh Giang" ///
30300 "Thanh Mien" ///
31303 "Hong Bang" ///
31304 "Ngo Quyen" ///
31305 "Le Chan" ///
31306 "Hai An" ///
31307 "Kien An" ///
31308 "Do Son" ///
31309 "Duong Kinh" ///
31311 "Thuy Nguyen" ///
31312 "An Duong" ///
31313 "An Lao" ///
31314 "Kien Thuy" ///
31315 "Tien Lang" ///
31316 "Vinh Bao" ///
31317 "Cat Hai" ///
31318 "Bach Long Vi" ///
33323 "Hung Yen" ///
33325 "Van Lam" ///
33326 "Van Giang" ///
33327 "Yen My" ///
33328 "My Hao" ///
33329 "An Thi" ///
33330 "Khoai Chau" ///
33331 "Kim Dong" ///
33332 "Tien Lu" ///
33333 "Phu Cu" ///
34336 "Thanh pho Thai Binh" ///
34338 "Quynh Phu" ///
34339 "Hung Ha" ///
34340 "Dong Hung" ///
34341 "Thai Thuy" ///
34342 "Tien Hai" ///
34343 "Kien Xuong" ///
34344 "Vu Thu" ///
35347 "Thanh pho Phu Ly" ///
35349 "Duy Tien" ///
35350 "Kim Bang" ///
35351 "Thanh Liem" ///
35352 "Binh Luc" ///
35353 "Ly Nhan" ///
36356 "Thanh pho Nam Dinh" ///
36358 "My Loc" ///
36359 "Vu Ban" ///
36360 "y Yen" ///
36361 "Nghia Hung" ///
36362 "Nam Truc" ///
36363 "Truc Ninh" ///
36364 "Xuan Truong" ///
36365 "Giao Thuy" ///
36366 "Hai Hau" ///
37369 "Thanh pho Ninh Binh" ///
37370 "Tam Diep" ///
37372 "Nho Quan" ///
37373 "Gia Vien" ///
37374 "Hoa Lu" ///
37375 "Yen Khanh" ///
37376 "Kim Son" ///
37377 "Yen Mo" ///
38380 "Thanh pho Thanh Hoa" ///
38381 "Bim Son" ///
38382 "Sam Son" ///
38384 "Muong Lat" ///
38385 "Quan Hoa" ///
38386 "Ba Thuoc" ///
38387 "Quan Son" ///
38388 "Lang Chanh" ///
38389 "Ngoc Lac" ///
38390 "Cam Thuy" ///
38391 "Thach Thanh" ///
38392 "Ha Trung" ///
38393 "Vinh Loc" ///
38394 "Yen Dinh" ///
38395 "Tho Xuan" ///
38396 "Thuong Xuan" ///
38397 "Trieu Son" ///
38398 "Thieu Hoa" ///
38399 "Hoang Hoa" ///
38400 "Hau Loc" ///
38401 "Nga Son" ///
38402 "Nhu Xuan" ///
38403 "Nhu Thanh" ///
38404 "Nong Cong" ///
38405 "Dong Son" ///
38406 "Quang Xuong" ///
38407 "Tinh Gia" ///
40412 "Thanh pho Vinh" ///
40413 "Cua Lo" ///
40414 "Thai Hoa" ///
40415 "Que Phong" ///
40416 "Quy Chau" ///
40417 "Ky Son" ///
40418 "Tuong Duong" ///
40419 "Nghia Dan" ///
40420 "Quy Hop" ///
40421 "Quynh Luu" ///
40422 "Con Cuong" ///
40423 "Tan Ky" ///
40424 "Anh Son" ///
40425 "Dien Chau" ///
40426 "Yen Thanh" ///
40427 "Do Luong" ///
40428 "Thanh Chuong" ///
40429 "Nghi Loc" ///
40430 "Nam Dan" ///
40431 "Hung Nguyen" ///
42436 "Thanh pho Ha Tinh" ///
42437 "Hong Linh" ///
42439 "Huong Son" ///
42440 "Duc Tho" ///
42441 "Vu Quang" ///
42442 "Nghi Xuan" ///
42443 "Can Loc" ///
42444 "Huong Khe" ///
42445 "Thach Ha" ///
42446 "Cam Xuyen" ///
42447 "Ky Anh" ///
42448 "Loc Ha" ///
44450 "Thanh Pho Dong Hoi" ///
44452 "Minh Hoa" ///
44453 "Tuyen Hoa" ///
44454 "Quang Trach" ///
44455 "Bo Trach" ///
44456 "Quang Ninh" ///
44457 "Le Thuy" ///
45461 "Dong Ha" ///
45462 "Quang Tri" ///
45464 "Vinh Linh" ///
45471 "Con Co" ///
45465 "Huong Hoa" ///
45466 "Gio Linh" ///
45467 "Da Krong" ///
45468 "Cam Lo" ///
45469 "Trieu Phong" ///
45470 "Hai Lang" ///
46474 "Thanh pho Hue" ///
46476 "Phong Dien" ///
46477 "Quang Dien" ///
46478 "Phu Vang" ///
46479 "Huong Thuy" ///
46480 "Huong Tra" ///
46481 "A Luoi" ///
46482 "Phu Loc" ///
46483 "Nam Dong" ///
48490 "Lien Chieu" ///
48491 "Thanh Khe" ///
48492 "Hai Chau" ///
48493 "Son Tra" ///
48494 "Ngu Hanh Son" ///
48495 "Cam Le" ///
48497 "Hoa Vang" ///
48498 "Hoang Sa" ///
49502 "Thanh Pho Tam Ky" ///
49503 "Thanh pho Hoi An" ///
49505 "Dong Giang" ///
49504 "Tay Giang" ///
49506 "Dai Loc" ///
49507 "Dien Ban" ///
49508 "Duy Xuyen" ///
49509 "Que Son" ///
49510 "Nam Giang" ///
49511 "Phuoc Son" ///
49512 "Hiep Duc" ///
49513 "Thang Binh" ///
49514 "Tien Phuoc" ///
49515 "Bac Tra My" ///
49516 "Nam Tra My" ///
49517 "Nui Thanh" ///
49518 "Phu Ninh" ///
49519 "Nong Son" ///
51522 "Thanh pho Quang Ngai" ///
51524 "Binh Son" ///
51525 "Tra Bong" ///
51526 "Tay Tra" ///
51527 "Son Tinh" ///
51528 "Tu Nghia" ///
51529 "Son Ha" ///
51530 "Son Tay" ///
51532 "Nghia Hanh" ///
51531 "Minh Long" ///
51533 "Mo Duc" ///
51534 "Duc Pho" ///
51535 "Ba To" ///
51536 "Ly Son" ///
52540 "Thanh pho Qui Nhon" ///
52542 "An Lao" ///
52543 "Hoai Nhon" ///
52544 "Hoai An" ///
52545 "Phu My" ///
52546 "Vinh Thanh" ///
52547 "Tay Son" ///
52548 "Phu Cat" ///
52549 "An Nhon" ///
52550 "Tuy Ph?oc" ///
52551 "Van Canh" ///
54555 "Thanh pho Tuy Hoa" ///
54557 "Song Cau" ///
54558 "Dong Xuan" ///
54559 "Tuy An" ///
54560 "Son Hoa" ///
54561 "Song Hinh" ///
54562 "Tay Hoa" ///
54563 "Phu Hoa" ///
54564 "Dong Hoa" ///
56568 "Thanh pho Nha Trang" ///
56569 "Cam Ranh" ///
56570 "Cam Lam" ///
56571 "Van Ninh" ///
56572 "Ninh Hoa" ///
56573 "Khanh Vinh" ///
56574 "Dien Khanh" ///
56575 "Khanh Son" ///
56576 "Truong Sa" ///
58582 "Thanh pho Phan Rang-Thap Cham" ///
58584 "Bac ai" ///
58585 "Ninh Son" ///
58586 "Ninh Hai" ///
58587 "Ninh Phuoc" ///
58588 "Thuan Bac" ///
60593 "Thanh pho Phan Thiet" ///
60594 "La Gi" ///
60595 "Tuy Phong" ///
60596 "Bac Binh" ///
60597 "Ham Thuan Bac" ///
60598 "Ham Thuan Nam" ///
60599 "Tanh Linh" ///
60600 "Duc Linh" ///
60601 "Ham Tan" ///
60602 "Phu Qui" ///
62608 "Kon Tum" ///
62610 "Dak Glei" ///
62611 "Ngoc Hoi" ///
62612 "Dak To" ///
62613 "Kon Plong" ///
62614 "Kon Ray" ///
62615 "Dak Ha" ///
62616 "Sa Thay" ///
62617 "Tu Mo Rong" ///
64622 "Thanh pho Pleiku" ///
64623 "An Khe" ///
64624 "Ayun Pa" ///
64625 "KBang" ///
64626 "Dak Doa" ///
64627 "Chu Pah" ///
64628 "Ia Grai" ///
64629 "Mang Yang" ///
64630 "Kong Chro" ///
64631 "Duc Co" ///
64632 "Chu Prong" ///
64633 "Chu Se" ///
64634 "Dak Po" ///
64635 "Ia Pa" ///
64637 "Krong Pa" ///
64638 "Phu Thien" ///
66643 "Thanh pho Buon Ma Thuot" ///
66645 "Ea H'leo" ///
66646 "Ea Sup" ///
66647 "Buon Don" ///
66648 "Cu M'gar" ///
66649 "Krong Buk" ///
66644 "Buon Ho" ///
66650 "Krong Nang" ///
66651 "Ea Kar" ///
66652 "M'Drak" ///
66653 "Krong Bong" ///
66654 "Krong Pac" ///
66655 "Krong A Na" ///
66656 "Lak" ///
66657 "Cu Kuin" ///
67660 "Gia Nghia" ///
67661 "Dak Glong" ///
67662 "Cu Jut" ///
67663 "Dak Mil" ///
67664 "Krong No" ///
67665 "Dak Song" ///
67666 "Dak R'Lap" ///
67667 "Tuy Duc" ///
68672 "Thanh pho Da Lat" ///
68673 "Bao Loc" ///
68674 "Dam Rong" ///
68675 "Lac Duong" ///
68676 "Lam Ha" ///
68677 "Don Duong" ///
68678 "Duc Trong" ///
68679 "Di Linh" ///
68680 "Bao Lam" ///
68681 "Da Huoai" ///
68682 "Da Teh" ///
68683 "Cat Tien" ///
70689 "Dong Xoai" ///
70691 "Phuoc Long" ///
70692 "Loc Ninh" ///
70693 "Bu Dop" ///
70694 "Binh Long" ///
70695 "Dong Phu" ///
70696 "Bu Dang" ///
70697 "Chon Thanh" ///
72703 "Tay Ninh" ///
72705 "Tan Bien" ///
72706 "Tan Chau" ///
72707 "Duong Minh Chau" ///
72708 "Chau Thanh" ///
72709 "Hoa Thanh" ///
72710 "Go Dau" ///
72711 "Ben Cau" ///
72712 "Trang Bang" ///
74718 "Thu Dau Mot" ///
74720 "Dau Tieng" ///
74721 "Ben Cat" ///
74722 "Phu Giao" ///
74723 "Tan Uyen" ///
74724 "Di An" ///
74725 "Thuan An" ///
75731 "Thanh pho Bien Hoa" ///
75732 "Long Khanh" ///
75734 "Tan Phu" ///
75735 "Vinh Cuu" ///
75736 "Dinh Quan" ///
75737 "Trang Bom" ///
75738 "Thong Nhat" ///
75739 "Cam My" ///
75740 "Long Thanh" ///
75741 "Xuan Loc" ///
75742 "Nhon Trach" ///
77747 "Thanh pho Vung Tau" ///
77755 "Con Dao" ///
77748 "Ba Ria" ///
77750 "Chau Duc" ///
77751 "Xuyen Moc" ///
77752 "Long Dien" ///
77753 "Dat Do" ///
77754 "Tan Thanh" ///
79760 "HCMC, District 1" ///
79761 "HCMC, District 12" ///
79762 "Thu Duc" ///
79763 "HCMC, District 9" ///
79764 "Go Vap" ///
79765 "Binh Thanh" ///
79766 "Tan Binh" ///
79767 "Tan Phu" ///
79768 "Phu Nhuan" ///
79769 "HCMC, District 2" ///
79770 "HCMC, District 3" ///
79771 "HCMC, District 10" ///
79772 "HCMC, District 11" ///
79773 "HCMC, District 4" ///
79774 "HCMC, District 5" ///
79775 "HCMC, District 6" ///
79776 "HCMC, District 8" ///
79777 "Binh Tan" ///
79778 "HCMC, District 7" ///
79783 "Cu Chi" ///
79784 "Hoc Mon" ///
79785 "Binh Chanh" ///
79786 "Nha Be" ///
79787 "Can Gio" ///
80794 "Tan An" ///
80796 "Tan Hung" ///
80797 "Vinh Hung" ///
80798 "Moc Hoa" ///
80799 "Tan Thanh" ///
80800 "Thanh Hoa" ///
80801 "Duc Hue" ///
80802 "Duc Hoa" ///
80803 "Ben Luc" ///
80804 "Thu Thua" ///
80805 "Tan Tru" ///
80806 "Can Duoc" ///
80807 "Can Giuoc" ///
80808 "Chau Thanh" ///
82815 "Thanh pho My Tho" ///
82816 "Go Cong" ///
82818 "Tan Phuoc" ///
82819 "Cai Be" ///
82820 "Cai Lay" ///
82821 "Chau Thanh" ///
82822 "Cho Gao" ///
82823 "Go Cong Tay" ///
82824 "Go Cong Dong" ///
82825 "Tan Phu Dong" ///
83829 "Ben Tre" ///
83831 "Chau Thanh" ///
83832 "Cho Lach" ///
83833 "Mo Cay" ///
83834 "Giong Trom" ///
83835 "Binh Dai" ///
83836 "Ba Tri" ///
83837 "Thanh Phu" ///
84842 "Tra Vinh" ///
84844 "Cang Long" ///
84845 "Cau Ke" ///
84846 "Tieu Can" ///
84847 "Chau Thanh" ///
84848 "Cau Ngang" ///
84849 "Tra Cu" ///
84850 "Duyen Hai" ///
86855 "Vinh Long" ///
86857 "Long Ho" ///
86858 "Mang Thit" ///
86859 "Vung Liem" ///
86860 "Tam Binh" ///
86861 "Binh Minh" ///
86862 "Tra On" ///
86863 "Binh Tan" ///
87866 "Thanh pho Cao Lanh" ///
87867 "Sa Dec" ///
87869 "Tan Hong" ///
87870 "Hong Ngu" ///
87868 "~" ///
87871 "Tam Nong" ///
87872 "Thap Muoi" ///
87873 "Cao Lanh" ///
87874 "Thanh Binh" ///
87875 "Lap Vo" ///
87876 "Lai Vung" ///
87877 "Chau Thanh" ///
89883 "Thanh pho Long Xuyen" ///
89884 "Chau Doc" ///
89886 "An Phu" ///
89887 "Tan Chau" ///
89888 "Phu Tan" ///
89889 "Chau Phu" ///
89890 "Tinh Bien" ///
89891 "Tri Ton" ///
89892 "Chau Thanh" ///
89893 "Cho Moi" ///
89894 "Thoai Son" ///
91899 "Thanh pho Rach Gia" ///
91900 "Ha Tien" ///
91902 "Kien Luong" ///
91903 "Hon Dat" ///
91904 "Tan Hiep" ///
91905 "Chau Thanh" ///
91906 "Giong Rieng" ///
91907 "Go Quao" ///
91908 "An Bien" ///
91909 "An Minh" ///
91910 "Vinh Thuan" ///
91911 "Phu Quoc" ///
91912 "Kien Hai" ///
91913 "U Minh Thuong" ///
92916 "Ninh Kieu" ///
92917 "O Mon" ///
92918 "Binh Thuy" ///
92919 "Cai Rang" ///
92923 "Thot Not" ///
92924 "Vinh Thanh" ///
92925 "Co Do" ///
92926 "Phong Dien" ///
92927 "Thoi Lai" ///
93930 "Vi Thanh" ///
93931 "Nga Bay" ///
93932 "Chau Thanh A" ///
93933 "Chau Thanh" ///
93934 "Phung Hiep" ///
93935 "Vi Thuy" ///
93936 "Long My" ///
94941 "Thanh pho Soc Trang" ///
94942 "Chau Thanh" ///
94943 "Ke Sach" ///
94944 "My Tu" ///
94945 "Cu Lao Dung" ///
94946 "Long Phu" ///
94947 "My Xuyen" ///
94948 "Nga Nam" ///
94949 "Thanh Tri" ///
94950 "Vinh Chau" ///
95954 "Bac Lieu" ///
95956 "Hong Dan" ///
95957 "Phuoc Long" ///
95958 "Vinh Loi" ///
95959 "Gia Rai" ///
95960 "Dong Hai" ///
95961 "Hoa Binh" ///
96964 "Thanh pho Ca Mau" ///
96966 "U Minh" ///
96967 "Thoi Binh" ///
96968 "Tran Van Thoi" ///
96969 "Cai Nuoc" ///
96970 "Dam Doi" ///
96971 "Nam Can" ///
96972 "Phu Tan" ///
96973 "Ngoc Hien" 
label value admin2 admin2
