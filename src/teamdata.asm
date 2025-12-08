TeamList
	dc.l	Boston
	dc.l	Buffalo
	dc.l	Calgary
	dc.l	Chicago
	dc.l	Detroit
	dc.l	Edmonton
	dc.l	Hartford
	dc.l	LosAngeles
	dc.l	Minnesota
	dc.l	Montreal
	dc.l	NewJersey
	dc.l	NewYorkI
	dc.l	NewYorkR
	dc.l	Philadelphia
	dc.l	Pittsburgh
	dc.l	Quebec
	dc.l	SanJose
	dc.l	StLouis
	dc.l	Toronto
	dc.l	Utah
	dc.l	Vancouver
	dc.l	Washington
	dc.l	Winnipeg
	dc.l	Campbell
	dc.l	Wales	

NumofTeams	=	(*-TeamList)/4
Playerdata	=	0
Palettedata	=	2
Teamname	=	4
ScoutReport	=	6
LineSets	=	8
ScoreOdds	=	10

Boston
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	3,4

.pad
	incbin Graphics\Pals\Bruinsh.pal
	incbin Graphics\Pals\Bruinsv.pal

.ls
	;goalie,defl,defr,wingl,center,wingr
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,08,0	;line 3
	dc.b	01,04,05,06,08,07,03,0	;line 4
	dc.b	01,14,19,20,03,22,08,0	;line 5
	dc.b	01,05,10,21,18,07,03,0	;line 6
	dc.b	01,19,09,16,13,12,03,0	;line 7
;------------------------
;u - uniform # x10
;n - uniform # x1
;w - weight
;l - leg power

;s - speed
;o - offensive awareness
;d - defensive awareness
;p - shot power / NA for goalie

;c - checking strength / NA
;h - shooting hand / glove hand
;g - stickhandling / glove left saves
;a - shooting accuracy / glove right saves

;e - endurance / stick right saves
;y - shot/pass decision / stick left saves
;t - passing accuracy / consistency
;m - aggressiveness (PIM) / NA
;------------------------
.pld	;	unwl,sodp,chga,eytm
     hex2  351d,daa0,01cc,ccf0
     hex2  0117,4550,0188,6690
     hex2  235c,cda6,31fc,a7c0
     hex2  779f,fdef,f1f3,fff7
     hex2  2666,c769,61c3,aab7
     hex2  2736,6989,60cb,f944
     hex2  089f,feec,f06c,ff98
     hex2  1079,ca99,909e,a871
     hex2  3696,6573,6162,a5a6
     hex2  3219,9379,6194,a456
     hex2  123c,c6c6,6168,a734
     hex2  182c,c749,6094,aa61
     hex2  207c,c899,c1c7,a579
     hex2  2859,c569,9192,f797
     hex2  419c,61b3,6163,a138
     hex2  1449,9596,6164,a646
     hex2  3089,6586,f038,f33e
     hex2  195f,f8a9,c198,5862
     hex2  21a9,9276,9061,5447
     hex2  115c,f77f,c199,5841
     hex2  312c,c216,c1c3,5416
     hex2  1666,6213,3066,5400
.tn	
	String	'Boston Bruins'
.sr


Buffalo
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	3,4

.pad
	incbin Graphics\Pals\sabresh.pal
	incbin Graphics\Pals\sabresv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,09,06,08,07,03,0	;line 4
	dc.b	01,05,19,20,03,12,08,0	;line 5
	dc.b	01,05,10,11,13,22,03,0	;line 6
	dc.b	01,19,14,20,18,21,03,0	;line 7
.pld
     hex2  3188,8880,0088,88a0
     hex2  3058,6990,0188,8cc0
     hex2  104b,bc6e,518a,aaa3
     hex2  04d5,58a5,8055,f8c6
     hex2  0358,87ae,5154,a8b4
     hex2  25a5,5a95,50b9,ac73
     hex2  223b,899b,b0ba,a967
     hex2  778e,8ca8,51eb,a992
     hex2  087b,8635,5181,aab5
     hex2  0558,83a5,8184,a464
     hex2  895b,bca8,51b9,ad91
     hex2  194b,b678,5154,a765
     hex2  216b,b848,b1b6,a978
     hex2  2688,8272,b025,a149
     hex2  2495,5002,e151,a217
     hex2  3292,2335,b129,a21f
     hex2  1555,5262,b124,a025
     hex2  3338,8848,5188,5766
     hex2  074b,b5e2,21b1,58b1
     hex2  426b,b558,81bf,5312
     hex2  1258,8548,5089,5531
     hex2  1815,5435,2154,5633
.tn	
	String	'Buffalo Sabres'
.sr

Calgary
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	0,4

.pad
	incbin Graphics\Pals\flamesh.pal
	incbin Graphics\Pals\flamesv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,16,03,07,08,0	;line 4
	dc.b	01,10,14,22,18,12,03,0	;line 5
	dc.b	01,10,20,11,03,07,08,0	;line 6
	dc.b	01,09,21,23,08,24,03,0	;line 7
.pld
     hex2  3018,8770,0188,8860
     hex2  3149,7990,01aa,aa40
     hex2  256c,ccb9,f1fc,ab83
     hex2  0266,ceff,9095,fff8
     hex2  205f,fbdc,f1f2,fde8
     hex2  105c,c9a9,f1ca,a66d
     hex2  140f,cefc,c0fd,acaa
     hex2  394c,6cd6,c1c9,a7ba
     hex2  0696,9456,6093,a586
     hex2  347f,f3d6,f163,a667
     hex2  1236,6659,6166,a743
     hex2  422f,fcac,61ff,a4a4
     hex2  29b6,9759,f06a,a54b
     hex2  0389,c496,9195,a37b
     hex2  049c,92b9,6190,a17a
     hex2  27a6,c6bf,916a,a445
     hex2  2243,3213,c133,a31c
     hex2  338c,c619,60c8,5551
     hex2  264c,c8b9,3168,5851
     hex2  214c,c6b3,61c5,53a4
     hex2  0543,3143,6161,5344
     hex2  2866,faf6,3067,5b70
     hex2  0736,6566,313a,5330
     hex2  235c,c6a9,9137,5548
.tn	
	String	'Calgary Flames'
.sr

Chicago
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	3,7

.pad
	incbin Graphics\Pals\blackhawksh.pal
	incbin Graphics\Pals\blackhawksv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,08,0	;line 3
	dc.b	01,05,15,11,03,07,08,0	;line 4
	dc.b	01,04,09,21,18,12,03,0	;line 5
	dc.b	01,05,04,22,03,23,08,0	;line 6
	dc.b	01,19,20,21,18,24,03,0	;line 7
.pld
     hex2  301e,edd0,01ee,eef0
     hex2  3115,3440,0155,5500
     hex2  271f,fde6,c09d,faa7
     hex2  075f,cacc,c0c3,faec
     hex2  245f,fafc,f1c4,add3
     hex2  324c,ca9f,9165,ab8a
     hex2  2859,9dec,919b,fba7
     hex2  1969,c6ac,f066,a756
     hex2  0866,6389,9163,a277
     hex2  0649,9473,31c1,a693
     hex2  11a6,970c,6168,a954
     hex2  1666,9bdc,61ca,aa96
     hex2  1266,6313,c132,a33a
     hex2  2569,6089,c033,a21a
     hex2  038c,95bc,f195,a97c
     hex2  44c6,6159,c13d,a00f
     hex2  173c,c699,6066,a849
     hex2  2299,6966,91ca,577a
     hex2  0469,c3ac,c090,5685
     hex2  056f,c196,9190,5554
     hex2  1469,9486,c136,5535
     hex2  23b6,9049,9160,500b
     hex2  3376,6799,9097,5a47
     hex2  26a9,9249,f133,5519
.tn	
	String	'Chicago Blackhawks'
.sr

Detroit
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	4,3

.pad
	incbin Graphics\Pals\Redwingsh.pal
	incbin Graphics\Pals\Redwingsv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,06,03,07,08,0	;line 4
	dc.b	01,14,22,11,18,17,03,0	;line 5
	dc.b	01,22,09,24,19,07,03,0	;line 6
	dc.b	01,21,23,16,20,25,03,0	;line 7
.pld
     hex2  3226,3660,0166,6270
     hex2  0145,1aa0,00aa,6a70
     hex2  194f,de5f,d0ba,ffa3
     hex2  3954,4614,4154,a5b4
     hex2  3344,4964,1183,a9e3
     hex2  113a,a8aa,a127,a969
     hex2  226a,47b7,a02b,a555
     hex2  9167,7c9a,4197,ada6
     hex2  0464,7454,a023,a285
     hex2  05ba,a391,1153,a072
     hex2  2151,1847,1129,a962
     hex2  146a,a7c7,102e,a343
     hex2  5541,1321,7115,a038
     hex2  0387,766a,a171,aab7
     hex2  0277,d284,a170,a177
     hex2  1744,4897,d177,a769
     hex2  24a4,4954,d1ab,a67f
     hex2  104a,797d,70a7,5b63
     hex2  254a,a524,107a,5422
     hex2  2334,4954,414a,5866
     hex2  20b1,1021,71a1,5223
     hex2  3624,4641,11a0,52c1
     hex2  0847,7181,1112,5321
     hex2  1544,4757,114c,5451
     hex2  2941,1111,a012,502b
.tn	
	String	'Detroit Red Wings'
.sr

Edmonton
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	4,4

.pad
	incbin Graphics\Pals\oilersh.pal
	incbin Graphics\Pals\oilersv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,21,03,12,08,0	;line 4
	dc.b	01,09,20,22,18,07,03,0	;line 5
	dc.b	01,10,15,11,18,07,03,0	;line 6
	dc.b	01,20,19,23,08,17,03,0	;line 7
.pld
     hex2  3019,9990,018c,8880
     hex2  315a,7aa0,00bb,99e0
     hex2  119f,fdc5,b1e6,f9c3
     hex2  05a8,89a8,e086,a5dc
     hex2  2298,877b,51b3,a7c3
     hex2  107b,bbcb,b1b6,ac97
     hex2  085b,8a6b,b18b,a773
     hex2  133e,b8b5,b1e8,a298
     hex2  0298,8672,50b4,a6a5
     hex2  255b,52a8,5150,a375
     hex2  855e,ebde,81bc,ac79
     hex2  095e,f94b,e187,aa75
     hex2  1278,b41b,b1b3,a64a
     hex2  06a8,5182,b053,a13a
     hex2  0468,5235,8183,a169
     hex2  1685,5042,b123,a20b
     hex2  3282,2132,5025,a00b
     hex2  1465,b568,8159,5537
     hex2  2875,5195,8150,5137
     hex2  3638,8472,2184,5481
     hex2  1868,5948,80ed,5866
     hex2  206b,b748,51ba,5743
     hex2  195b,b7c8,2159,5742
.tn	
	String	'Edmonton Oilers'
.sr

Hartford
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	5,4

.pad
	incbin Graphics\Pals\whalersh.pal
	incbin Graphics\Pals\whalersv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,06,03,07,08,0	;line 4
	dc.b	01,09,10,11,13,20,03,0	;line 5
	dc.b	01,05,09,18,08,12,03,0	;line 6
	dc.b	01,14,15,16,13,19,03,0	;line 7
.pld
     hex2  3035,4660,0155,5540
     hex2  3126,2990,0188,8870
     hex2  155e,8e5b,e0eb,fbc8
     hex2  3218,8632,20e1,a7b3
     hex2  038e,e98b,51b5,a9d6
     hex2  2495,575b,8157,a949
     hex2  1668,ec65,b08a,ac8d
     hex2  1238,8545,5154,a35b
     hex2  214b,b315,5052,a951
     hex2  0668,5248,8182,a356
     hex2  173b,8568,5186,a638
     hex2  0445,5a48,818b,a78a
     hex2  3842,2332,2022,a330
     hex2  2755,5132,5051,a357
     hex2  29b5,5032,5121,a119
     hex2  1842,2548,8125,a739
     hex2  22a2,5035,b028,a00c
     hex2  2888,5335,8126,5315
     hex2  1168,8a1b,b086,5b88
     hex2  2688,b678,5057,564b
.tn	
	String	'Hartford Whalers'
.sr

LosAngeles
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	0,5

.pad
	incbin Graphics\Pals\Kingsh.pal
	incbin Graphics\Pals\Kingsv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,06,03,07,08,0	;line 4
	dc.b	01,09,14,11,08,17,03,0	;line 5
	dc.b	01,14,20,21,18,12,03,0	;line 6
	dc.b	01,15,19,22,13,23,03,0	;line 7
.pld
     hex2  323d,dbb0,01ce,ecd0
     hex2  360a,a990,01aa,aa80
     hex2  991f,cfec,61fc,fbf1
     hex2  0476,687c,90c4,a9c9
     hex2  286c,fabf,61c7,a9d6
     hex2  2059,6dd6,61cc,fca6
     hex2  078f,feef,c1cd,fda8
     hex2  0659,6ab9,61f8,a985
     hex2  024f,c6a6,91c3,a8b9
     hex2  19cc,c5d6,c1c0,a3a1
     hex2  2129,fbd9,c0c9,ac8a
     hex2  3779,9696,c06a,a824
     hex2  4419,9386,c19f,a01a
     hex2  33d6,98f6,f0c4,a6dc
     hex2  7796,62b3,c062,a34b
     hex2  2999,6496,c03e,a02d
     hex2  1856,69d9,c09b,a77a
     hex2  111c,957c,91c7,5353
     hex2  053c,6093,c190,5128
     hex2  227c,c1b3,c132,512a
     hex2  2776,9579,613a,5435
     hex2  476f,f5a9,919b,5235
     hex2  097c,c449,31c4,5532
.tn	
	String	'Los Angeles Kings'
.sr

Minnesota
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	5,4

.pad
	incbin Graphics\Pals\northstarsh.pal
	incbin Graphics\Pals\northstarsv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,06,03,07,08,0	;line 4
	dc.b	01,15,20,11,13,12,03,0	;line 5
	dc.b	01,09,10,21,18,23,03,0	;line 6
	dc.b	01,20,19,22,08,17,03,0	;line 7
.pld
     hex2  300a,a990,01cc,aac0
     hex2  012a,a880,01aa,aa80
     hex2  153c,9d99,c19b,fc99
     hex2  2496,6666,c163,a5bc
     hex2  0646,6456,9164,a757
     hex2  2369,6b3c,9096,ae84
     hex2  095c,ca66,61c7,ac86
     hex2  071f,cb56,31f4,aaa2
     hex2  023c,9276,f164,a154
     hex2  0476,6156,c133,a246
     hex2  165c,cb8c,6199,a995
     hex2  2266,6889,61ca,a940
     hex2  189c,c83f,6197,f675
     hex2  0556,6243,9061,a369
     hex2  0859,9286,c160,a479
     hex2  1783,6023,9161,a30c
     hex2  2779,9063,c033,a20e
     hex2  2159,c459,6069,5512
     hex2  2679,9179,9190,5832
     hex2  0353,3023,9131,5129
     hex2  142f,c446,9164,5634
     hex2  107c,c376,c165,5511
     hex2  2033,3416,3038,5613
.tn	
	String	'Minnesota North Stars'
.sr

Montreal
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	4,5

.pad
	incbin Graphics\Pals\canadiensh.pal
	incbin Graphics\Pals\canadiensv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,06,08,12,03,0	;line 4
	dc.b	01,10,20,16,18,07,03,0	;line 5
	dc.b	01,10,09,16,03,21,08,0	;line 6
	dc.b	01,20,14,11,18,17,03,0	;line 7
.pld
     hex2  334f,fcc0,01cc,eef0
     hex2  4009,9990,01aa,aa80
     hex2  182f,fa5c,60f9,fb85
     hex2  251c,c686,91c3,a3b5
     hex2  0839,9689,6163,aa96
     hex2  2729,9996,c198,aa6a
     hex2  063c,fb7c,c095,aea3
     hex2  4739,9979,60cc,a572
     hex2  2879,9586,30c3,a892
     hex2  0359,9526,9193,a493
     hex2  3579,998c,c16b,a855
     hex2  447f,fa6f,60f8,ac65
     hex2  3959,c8a6,916d,f457
     hex2  3499,9383,6093,a185
     hex2  2499,9093,c130,a00d
     hex2  3183,3436,3136,a533
     hex2  36a9,6293,903e,a00a
     hex2  213f,f769,c0c9,5756
     hex2  057c,c2c3,3090,5272
     hex2  4846,6553,31c2,55a3
     hex2  1226,6676,9067,5655
.tn	
	String	'Montreal Canadiens'
.sr

NewJersey
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	4,4

.pad
	incbin Graphics\Pals\devilsh.pal
	incbin Graphics\Pals\devilsv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,15,06,03,07,08,0	;line 4
	dc.b	01,10,19,11,08,23,03,0	;line 5
	dc.b	01,19,14,20,13,22,03,0	;line 6
	dc.b	01,15,05,21,18,23,03,0	;line 7
.pld
     hex2  3105,5990,0177,9960
     hex2  0193,2660,0166,4440
     hex2  2645,5a68,8159,a695
     hex2  234b,8898,51b2,abc6
     hex2  079b,b7c5,81b4,a6b7
     hex2  0985,5b68,8185,aba7
     hex2  1575,8c8f,5059,fe7a
     hex2  177e,b885,51ba,a574
     hex2  028e,837e,51b2,a386
     hex2  0598,8692,51b2,a4c4
     hex2  3358,8775,2155,a760
     hex2  1185,5b75,5059,aa8a
     hex2  1645,5368,8157,a417
     hex2  0398,5332,b152,a47d
     hex2  2878,5485,8155,a46a
     hex2  0888,8495,5127,a33a
     hex2  25a2,2135,b027,a10b
     hex2  202b,b7a5,205d,5263
     hex2  0678,5462,5181,5594
     hex2  325b,b4a5,2126,5232
     hex2  1062,2132,b129,520b
     hex2  243b,87c8,2056,5940
     hex2  2295,884e,8056,5e38
.tn	
	String	'New Jersey Devils'
.sr

NewYorkI
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	6,3

.pad
	incbin Graphics\Pals\islandersh.pal
	incbin Graphics\Pals\islandersv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,10,20,03,07,08,0	;line 4
	dc.b	01,15,19,06,13,22,08,0	;line 5
	dc.b	01,04,09,20,08,22,03,0	;line 6
	dc.b	01,19,05,21,18,17,03,0	;line 7
.pld
     hex2  3525,7aa0,0199,7760
     hex2  0121,0660,0144,4430
     hex2  163d,fd4d,40ab,ac94
     hex2  0867,a817,41a1,a8d1
     hex2  3697,7447,7140,a598
     hex2  254d,a937,4145,ac75
     hex2  2674,7a54,7049,aa87
     hex2  2134,4947,7146,aa74
     hex2  17b4,4114,a140,a137
     hex2  0641,1501,4173,a794
     hex2  2784,4964,4179,a864
     hex2  15a1,1511,1045,a252
     hex2  334d,d734,41ac,a546
     hex2  4784,4024,d111,a01a
     hex2  29aa,a4b1,7172,a388
     hex2  2471,4021,a111,a00e
     hex2  1264,4021,7012,a10d
     hex2  393a,a314,4147,5210
     hex2  0251,1011,4114,5005
     hex2  1164,a734,7177,5a34
     hex2  0454,4454,4115,5426
     hex2  1461,1321,1114,5512
.tn	
	String	'New York Islanders'
.sr

NewYorkR
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	3,4

.pad
	incbin Graphics\Pals\rangersh.pal
	incbin Graphics\Pals\rangersv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,06,08,07,03,0	;line 4
	dc.b	01,14,19,21,18,23,03,0	;line 5
	dc.b	01,09,15,21,08,23,03,0	;line 6
	dc.b	01,19,20,16,18,22,03,0	;line 7
.pld
     hex2  354c,bbb0,01bb,bbc0
     hex2  3438,6990,01aa,6aa0
     hex2  0945,5c7e,e0e9,aaa8
     hex2  024e,ec68,51e4,faf4
     hex2  036f,fa5e,b0e4,a8e5
     hex2  259b,b9ab,8187,ad50
     hex2  225e,eb4e,b0bb,ad45
     hex2  084e,eb58,b1e7,ab93
     hex2  2788,818b,8081,a147
     hex2  057b,b3a2,b185,a153
     hex2  1298,8468,e156,a63a
     hex2  193e,8a98,51b6,aa94
     hex2  1565,5355,815c,a11b
     hex2  249b,85ab,8082,a4ab
     hex2  1882,2305,5052,a569
     hex2  1655,8448,e187,a42d
     hex2  2665,8138,b084,a40e
     hex2  1135,8978,b0bc,5565
     hex2  0655,5372,2182,5370
     hex2  1468,b06b,81b0,5227
     hex2  207e,86b5,81ea,5160
     hex2  217b,b378,2085,5420
     hex2  2338,8a9b,208b,5961
.tn	
	String	'New York Rangers'
.sr

Philadelphia
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	5,4

.pad
	incbin Graphics\Pals\flyersh.pal
	incbin Graphics\Pals\flyersv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,15,06,18,07,03,0	;line 4
	dc.b	01,10,20,11,03,23,08,0	;line 5
	dc.b	01,05,09,22,13,17,03,0	;line 6
	dc.b	01,20,14,21,19,23,03,0	;line 7
.pld
     hex2  2769,8990,0177,99c0
     hex2  3563,1550,0135,5330
     hex2  092e,8b55,21e8,a7a1
     hex2  0355,b748,b083,aab5
     hex2  28eb,8578,b055,a487
     hex2  324b,ba58,51b6,a9a5
     hex2  2288,bc7b,f0bb,fc7a
     hex2  1435,8768,e056,a868
     hex2  115b,b708,81b3,a6c0
     hex2  0895,5358,b185,a446
     hex2  4145,5645,2157,a442
     hex2  2085,5568,80b7,a443
     hex2  2515,b638,b156,a65a
     hex2  06a5,5172,e050,a158
     hex2  29a5,8525,b154,a4ac
     hex2  1785,8345,b12a,a11f
     hex2  1985,b785,b087,a95a
     hex2  1858,883b,81ba,5756
     hex2  2645,5362,2122,5431
     hex2  3968,8162,2121,5233
     hex2  1065,8355,b187,532c
     hex2  24ab,b468,e126,5513
     hex2  12d5,8b15,8088,5b90
.tn	
	String	'Philadelphia Flyers'
.sr

Pittsburgh
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	0,2

.pad
	incbin Graphics\Pals\penguinsh.pal
	incbin Graphics\Pals\penguinsv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,06,03,07,08,0	;line 4
	dc.b	01,09,20,16,08,22,03,0	;line 5
	dc.b	01,10,14,16,13,17,03,0	;line 6
	dc.b	01,20,19,21,18,22,03,0	;line 7
.pld
     hex2  359d,caa0,00af,aa50
     hex2  4047,4770,0199,9950
     hex2  669f,ffcf,90fd,fec3
     hex2  777f,fd1f,61f6,fdfa
     hex2  5599,c74c,90c2,aac6
     hex2  25b9,fc66,916a,ad9a
     hex2  084f,9f6c,91fe,fac4
     hex2  097f,cc5f,61f8,a9b6
     hex2  226c,949c,c094,a384
     hex2  2869,63bc,c167,a077
     hex2  123c,f796,6169,a749
     hex2  6899,995c,90cc,a764
     hex2  1556,c47c,9168,a615
     hex2  056c,c4a3,f191,a69c
     hex2  3276,62c9,c194,a158
     hex2  2999,c686,c1ca,a628
     hex2  345c,c749,60c4,ab54
     hex2  1969,9786,9168,5462
     hex2  2356,6146,c068,5013
     hex2  03b3,3123,6133,5149
     hex2  249c,c5b6,9038,5337
     hex2  073f,9aaf,f0cc,5780
.tn	
	String	'Pittsburgh Penguins'
.sr

Quebec
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	6,0

.pad
	incbin Graphics\Pals\nordiquesh.pal
	incbin Graphics\Pals\nordiquesv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,19,11,03,07,08,0	;line 4
	dc.b	01,10,20,06,08,21,03,0	;line 5
	dc.b	01,05,14,16,03,12,08,0	;line 6
	dc.b	01,19,20,11,18,22,03,0	;line 7
.pld
     hex2  0102,0880,0195,5570
     hex2  3212,0880,0155,7750
     hex2  194a,ae0a,41ac,fcb2
     hex2  437a,a917,4175,aac2
     hex2  0684,1337,4142,a558
     hex2  2241,1424,7019,a608
     hex2  1341,191a,4179,a885
     hex2  400a,7914,1177,a781
     hex2  2774,4114,4112,a044
     hex2  3747,7571,11a4,a5a1
     hex2  2181,1401,1117,a424
     hex2  1864,4747,7147,a759
     hex2  2527,7a97,117d,a493
     hex2  2971,4304,7143,a46c
     hex2  1541,1031,7010,a008
     hex2  1781,1001,1110,a303
     hex2  1161,1211,7013,a229
     hex2  2047,7481,1117,5230
     hex2  0787,7207,4172,5344
     hex2  0541,1441,1175,5380
     hex2  1044,7624,1078,f640
     hex2  1474,4284,a044,5317
.tn	
	String	'Quebec Nordiques'
.sr

SanJose
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	6,1

.pad
	incbin Graphics\Pals\Sharksh.pal
	incbin Graphics\Pals\Sharksv.pal
.ls
	dc.b	01,05,14,19,03,17,11,0	;line 1
	dc.b	01,09,06,18,11,12,03,0	;line 2
	dc.b	01,10,15,22,13,16,17,0	;line 3
	dc.b	01,07,14,19,13,17,03,0	;line 4
	dc.b	01,15,05,18,11,21,17,0	;line 5
	dc.b	01,07,10,08,20,21,03,0	;line 6
	dc.b	01,15,09,04,03,12,17,0	;line 7
.pld
     hex2  0142,0aa0,0088,4870	;1
     hex2  3061,0220,0101,0070	;2
     hex2  2514,a527,a145,a65a	;3
     hex2  1784,7234,a119,a11f	;4
     hex2  4845,5442,21b1,55a3	;5
     hex2  29a9,93a0,6161,a388	;6
     hex2  2867,419a,a146,a077	;7
     hex2  249a,a394,7016,5337	;8
     hex2  2673,3003,3101,a044	;9
     hex2  445a,a194,a070,a277	;10
     hex2  1834,4444,4143,5565	;11
     hex2  1971,1234,c019,a20b	;12
     hex2  2383,3543,603a,5444	;13
     hex2  2294,7507,1075,5793	;14
     hex2  3696,6573,6162,a5a6	;15
     hex2  1555,5262,b124,a025	;16
     hex2  1257,7437,4078,5531	;17
     hex2  27a4,a49d,7148,a445	;18
     hex2  11a4,750a,4146,a954	;19
     hex2  2148,8302,0058,5422	;20
     hex2  097a,a227,11a2,5532	;21
     hex2  2097,4274,a01c,a02d	;22
.tn	
	String	'San Jose Sharks'
.sr

StLouis
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	2,5

.pad
	incbin Graphics\Pals\bluesh.pal
	incbin Graphics\Pals\bluesv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,05,10,16,08,07,03,0	;line 4
	dc.b	01,04,14,11,18,21,03,0	;line 5
	dc.b	01,09,15,06,18,12,03,0	;line 6
	dc.b	01,19,20,11,13,21,03,0	;line 7
.pld
     hex2  304a,a990,01d9,9970
     hex2  3149,aaa0,01bb,bb90
     hex2  1246,9fb9,60fb,fae3
     hex2  02af,c8cc,f1c1,f9da
     hex2  218c,cb7f,60f4,abe4
     hex2  1029,96b6,c169,a64b
     hex2  1659,cfcf,609e,ff92
     hex2  073f,ca09,61c7,aa86
     hex2  445c,c3b6,c091,a277
     hex2  147c,c7c9,f195,a7b8
     hex2  17a9,c676,f163,a767
     hex2  2349,6479,c037,a729
     hex2  284c,c5a9,c038,a63b
     hex2  0576,6329,6064,a26e
     hex2  36bc,c4c6,c195,a27c
     hex2  197c,c86c,f196,a978
     hex2  2946,6153,c036,a01d
     hex2  1836,6666,6165,5565
     hex2  205c,c3a3,3064,5460
     hex2  2799,9073,f161,5125
     hex2  1589,665f,90c6,5552
.tn	
	String	'St. Louis Blues'
.sr

Toronto
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	5,1

.pad
	incbin Graphics\Pals\mapleleafsh.pal
	incbin Graphics\Pals\mapleleafsv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,06,20,07,03,0	;line 4
	dc.b	01,09,14,16,19,12,03,0	;line 5
	dc.b	01,04,05,11,03,22,08,0	;line 6
	dc.b	01,10,15,21,18,17,03,0	;line 7
.pld
     hex2  0104,1880,0166,6670
     hex2  3512,0550,0133,3340
     hex2  267a,d86a,41aa,a565
     hex2  228a,7704,a045,a7ab
     hex2  0477,a84a,71a3,aac7
     hex2  1044,7b07,41d6,fc96
     hex2  3257,a52a,40d8,a819
     hex2  441d,7837,40a5,a676
     hex2  2894,4614,40a6,a3a7
     hex2  2334,7451,71a0,a499
     hex2  1484,4537,4148,a631
     hex2  112a,a70a,70a7,aa34
     hex2  0944,4634,7149,a357
     hex2  087a,4567,a043,a99b
     hex2  02a4,4107,a170,a23d
     hex2  1764,474a,a145,ab4a
     hex2  1871,1234,d01a,a20b
     hex2  2784,4654,704b,5444
     hex2  1247,7a84,107e,5670
     hex2  256a,aa07,41af,5761
     hex2  3441,1321,1016,5121
     hex2  7164,4467,d048,5429
.tn	
	String	'Toronto Maple Leafs'
.sr

UTAH
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	0,0

.pad
	incbin Graphics\Pals\Utahh.pal
	incbin Graphics\Pals\Utahv.pal
.ls
	dc.b	01,20,06,15,21,07,09,0	;line
	dc.b	01,05,03,16,14,09,07,0	;line
	dc.b	01,17,04,12,10,18,07,0	;line
	dc.b	01,20,06,12,21,07,09,0	;line
	dc.b	01,17,05,16,13,11,07,0	;line
	dc.b	01,04,03,12,19,11,07,0	;line
	dc.b	01,17,05,15,08,09,07,0	;line
.pld
	hex2	334e,ecc0,01dd,eef0	;1
	hex2	351b,baa0,01bb,bbf0	;2
	hex2	024e,ec68,51e4,faf4	;3
	hex2	04ae,bb35,b085,add6	;4
	hex2	05d5,58a5,8055,f8c6	;5
	hex2	077f,fd1f,61f6,fdfa	;6
	hex2	089f,feec,f06c,ff98	;7
	hex2	094e,eb58,b1e7,ab93	;8
	hex2	104f,9f6c,91fe,fac4	;9
	hex2	115e,8e5b,e0eb,fbc8	;10
	hex2	1575,8c8f,5059,fe7a	;11
	hex2	1668,ec65,b08a,ac8d	;12
	hex2	173d,fd4d,40ab,ac94	;13
	hex2	194a,ae0a,41ac,fcb2	;14
	hex2	2288,bc7b,f0bb,fc7a	;15
	hex2	25b9,fc66,916a,ad9a	;16
	hex2	2859,c569,9192,f797	;17
	hex2	3089,6586,f038,f33e	;18
	hex2	3959,c8a6,916d,f457	;19
	hex2	779f,fdef,f1f3,fff7	;20
    hex2  	669f,ffcf,90fd,fec3	;21
.tn	
	String	'Utah Hockey Club'
.sr

Vancouver
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	5,2

.pad
	incbin Graphics\Pals\canucksh.pal
	incbin Graphics\Pals\canucksv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,09,06,03,07,08,0	;line 4
	dc.b	01,05,19,23,18,17,03,0	;line 5
	dc.b	01,19,10,21,08,07,03,0	;line 6
	dc.b	01,14,20,22,18,24,03,0	;line 7
.pld
     hex2  3561,1770,0155,5560
     hex2  0142,0550,0166,4450
     hex2  072d,a967,117a,a870
     hex2  037a,7654,4072,a9b7
     hex2  215a,a524,4141,a8a5
     hex2  1067,aaaa,7147,ae76
     hex2  1677,7a14,7078,fb86
     hex2  1804,4754,107c,a351
     hex2  248a,a80a,1172,a8d3
     hex2  1551,1301,4171,a576
     hex2  0844,4a47,4178,ab70
     hex2  2341,1404,4016,a636
     hex2  4481,1111,711f,a008
     hex2  0494,724a,d042,a658
     hex2  2244,4041,a014,a019
     hex2  2941,1234,a01a,a20f
     hex2  25b4,420d,4044,a619
     hex2  1931,1304,1116,5611
     hex2  067a,a224,4041,5546
     hex2  0574,701a,7141,5513
     hex2  5821,1537,1045,5641
     hex2  2774,77a7,41a8,575b
     hex2  2854,4967,117a,5484
     hex2  3387,7677,101b,5631
.tn	
	String	'Vancouver Canucks'
.sr

Washington
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	5,5

.pad
	incbin Graphics\Pals\capitalsh.pal
	incbin Graphics\Pals\capitalsv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,10,06,13,07,03,0	;line 4
	dc.b	01,05,14,11,08,21,03,0	;line 5
	dc.b	01,04,14,06,03,21,08,0	;line 6
	dc.b	01,05,19,20,18,17,03,0	;line 7
.pld
     hex2  330b,aaa0,01bb,7b30
     hex2  0166,2220,0114,1170
     hex2  1755,bb88,8089,a8a2
     hex2  04ae,bb35,b085,add6
     hex2  067b,b855,5085,a6d2
     hex2  1048,e89b,818a,a853
     hex2  1978,5975,8156,aa84
     hex2  207b,ba7b,21b6,a9a3
     hex2  05a5,51a2,8181,a042
     hex2  0345,5455,8083,a987
     hex2  2945,5958,205a,a861
     hex2  223e,b91b,50b6,ae56
     hex2  325b,8818,e159,a56c
     hex2  34bb,e628,51b5,a5ad
     hex2  084b,b2d2,8055,a059
     hex2  1672,2132,e023,a30e
     hex2  2138,8635,8054,a848
     hex2  1438,8325,2155,5322
     hex2  2668,8002,5120,5125
     hex2  0965,5355,b129,511c
     hex2  1242,2728,5057,5754
.tn	
	String	'Washington Capitals'
.sr

Winnipeg
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	5,3

.pad
	incbin Graphics\Pals\jetsh.pal
	incbin Graphics\Pals\jetsv.pal
.ls
	dc.b	01,04,05,06,03,07,08,0	;line 1
	dc.b	01,09,10,11,08,12,03,0	;line 2
	dc.b	01,14,15,16,13,17,03,0	;line 3
	dc.b	01,04,05,06,03,07,08,0	;line 4
	dc.b	01,09,20,22,08,17,03,0	;line 5
	dc.b	01,04,20,11,18,12,03,0	;line 6
	dc.b	01,15,21,22,19,23,03,0	;line 7
.pld
     hex2  3505,3aa0,0188,8880
     hex2  3141,1660,0144,4460
     hex2  1677,7b0a,71a8,ab97
     hex2  063a,ac37,41a6,fbe2
     hex2  047d,d71d,a0a4,aab2
     hex2  0797,a837,7176,a765
     hex2  1547,aa3d,707d,a876
     hex2  256a,ad57,71a9,a9b4
     hex2  275a,a524,1072,a8a3
     hex2  0874,4787,7176,a7b4
     hex2  1721,1437,411b,a225
     hex2  205a,a527,4078,a724
     hex2  1151,7434,a113,a437
     hex2  4491,1031,a011,a12b
     hex2  3481,4121,d015,a12e
     hex2  3944,4664,7145,a369
     hex2  2387,7744,d04a,a55a
     hex2  2451,1527,1017,5622
     hex2  3641,1221,7010,5337
     hex2  2294,7507,1075,5793
     hex2  0371,1121,7114,5228
     hex2  1284,a52a,7147,5636
     hex2  2151,1224,1016,5400
.tn	
	String	'Winnipeg Jets'
.sr

Campbell
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	0,0

.pad
	incbin Graphics\Pals\Campbellh.pal
	incbin Graphics\Pals\Campbellv.pal
.ls
	dc.b	01,03,07,17,20,13,10,0	;line
	dc.b	01,05,06,09,10,08,20,0	;line
	dc.b	01,04,16,12,15,19,13,0	;line
	dc.b	01,03,05,17,20,14,10,0	;line
	dc.b	01,04,16,15,15,11,20,0	;line
	dc.b	01,06,07,09,10,08,13,0	;line
	dc.b	01,04,05,18,12,11,10,0	;line
.pld
     	hex2  301d,a770,01aa,aa60	;1
	hex2  011b,9990,01ae,aa80	;2
	hex2  0266,ceff,9095,fff8	;3
	hex2  03af,c8cc,f1c1,f9da	;4
	hex2  05a8,89a8,e086,a5dc	;5
	hex2  063a,ac37,41a6,fbe2	;6
	hex2  075f,cacc,c0c3,faec	;7
	hex2  088f,feef,c1cd,fda8	;8
	hex2  1044,7b07,41d6,fc96	;9
	hex2  119f,fdc5,b1e6,f9c3	;10
	hex2  140f,cefc,c0fd,acaa	;11
	hex2  153a,7d97,a17b,fc99	;12
	hex2  1659,cfcf,609e,ff92	;13
	hex2  1777,7a14,7078,fb86	;14
	hex2  194f,de5f,d0da,ffa3	;15
	hex2  205f,fbdc,f1f2,fde8	;16
	hex2  2159,6dd6,61cc,fca6	;17
	hex2  271f,fde6,c09d,faa7	;18
	hex2  2859,9dec,919b,fba7	;19
	hex2  991f,cfec,61fc,fbf1	;20
.tn	
	String	'Campbell All Stars'
.sr

Wales
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.sr-.0
	dc.w	.ls-.0
	dc.w	.sodds-.0

.sodds	dc.b	0,0

.pad
	incbin Graphics\Pals\Walesh.pal
	incbin Graphics\Pals\Walesv.pal
.ls
	dc.b	01,20,06,15,21,07,09,0	;line
	dc.b	01,05,03,16,14,09,07,0	;line
	dc.b	01,17,04,12,10,18,07,0	;line
	dc.b	01,20,06,12,21,07,09,0	;line
	dc.b	01,17,05,16,13,11,07,0	;line
	dc.b	01,04,03,12,19,11,07,0	;line
	dc.b	01,17,05,15,08,09,07,0	;line
.pld
	hex2	334e,ecc0,01dd,eef0	;1
	hex2	351b,baa0,01bb,bbf0	;2
	hex2	024e,ec68,51e4,faf4	;3
	hex2	04ae,bb35,b085,add6	;4
	hex2	05d5,58a5,8055,f8c6	;5
	hex2	077f,fd1f,61f6,fdfa	;6
	hex2	089f,feec,f06c,ff98	;7
	hex2	094e,eb58,b1e7,ab93	;8
	hex2	104f,9f6c,91fe,fac4	;9
	hex2	115e,8e5b,e0eb,fbc8	;10
	hex2	1575,8c8f,5059,fe7a	;11
	hex2	1668,ec65,b08a,ac8d	;12
	hex2	173d,fd4d,40ab,ac94	;13
	hex2	194a,ae0a,41ac,fcb2	;14
	hex2	2288,bc7b,f0bb,fc7a	;15
	hex2	25b9,fc66,916a,ad9a	;16
	hex2	2859,c569,9192,f797	;17
	hex2	3089,6586,f038,f33e	;18
	hex2	3959,c8a6,916d,f457	;19
	hex2	779f,fdef,f1f3,fff7	;20
     	hex2  	669f,ffcf,90fd,fec3	;21
.tn	
	String	'Wales All Stars'
.sr

playoffseats
	dc.b	3,8,17,4, 7,19,2,5, 0,6,9,1, 14,10,12,20
	dc.b	3,4,17,8, 7,5,2,16, 0,1,9,15, 14,20,12,10
	dc.b	3,8,17,4, 7,16,2,5, 0,15,9,6, 14,10,12,20
	dc.b	3,18,17,4, 7,19,2,16, 0,6,9,15, 14,13,12,20
	dc.b	3,4,17,18, 7,5,2,19, 0,1,9,6, 14,20,12,13
	dc.b	3,18,17,8, 7,19,2,5, 0,6,9,1, 14,13,12,10
	dc.b	3,8,17,18, 7,21,2,5, 0,15,9,1, 14,10,12,13
	dc.b	3,4,17,8, 7,5,2,21, 0,1,9,15, 14,11,12,10

	dc.b	3,8,17,4, 7,21,2,19, 0,15,9,6, 14,13,12,11
	dc.b	3,18,17,4, 7,19,2,21, 0,6,9,15, 14,11,12,13
	dc.b	3,4,17,18, 7,16,2,19, 0,1,9,6, 14,20,12,11
	dc.b	3,18,17,8, 7,21,2,16, 0,6,9,1, 14,11,12,20
	dc.b	3,8,17,18, 7,16,2,21, 0,15,9,1, 14,10,12,11
	dc.b	3,18,17,4, 7,19,2,16, 0,6,9,15, 14,13,12,20	;
	dc.b	3,8,17,18, 7,21,2,5, 0,15,9,1, 14,10,12,13	;
	dc.b	3,4,17,18, 7,16,2,19, 0,1,9,6, 14,20,12,11	;

	dc.b	8,3,4,17, 19,7,5,2, 6,0,1,9, 10,14,20,12
	dc.b	4,3,8,17, 5,7,16,2, 1,0,15,9, 20,14,10,12
	dc.b	8,3,4,17, 16,7,5,2, 15,0,6,9, 10,14,20,12
	dc.b	8,3,4,17, 19,7,16,2, 6,0,15,9, 13,14,20,12
	dc.b	4,3,18,17, 5,7,19,2, 1,0,6,9, 20,14,13,12
	dc.b	18,3,8,17, 19,7,5,2, 6,0,1,9, 13,14,10,12
	dc.b	8,3,18,17, 21,7,5,2, 15,0,1,9, 10,14,13,12
	dc.b	4,3,8,17, 5,7,21,2, 1,0,15,9, 11,14,10,12

	dc.b	8,3,4,17, 21,7,19,2, 15,0,6,9, 13,14,11,12
	dc.b	18,3,4,17, 19,7,21,2, 6,0,15,9, 11,14,13,12
	dc.b	4,3,18,17, 16,7,19,2, 1,0,6,9, 20,14,11,12
	dc.b	18,3,8,17, 21,7,16,2, 6,0,1,9, 11,14,20,12
	dc.b	8,3,18,17, 16,7,21,2, 15,0,1,9, 10,14,11,12
	dc.b	18,3,4,17, 19,7,16,2, 6,0,15,9, 13,14,20,12	;
	dc.b	8,3,18,17, 21,7,5,2, 15,0,1,9, 10,14,13,12	;
	dc.b	4,3,18,17, 16,7,19,2, 1,0,6,9, 20,14,11,12	;


Credits
	String	'Team names and logos'
	String	'depicted are Officially'
	String	'Licensed Trademarks of the'
	String	'National Hockey League'
	String	'$ NHL 1991'
	String	-1

	String	'Designed by'
	String	'Scott Orr'
	String	'Richard Hilleman'
	String	'Michael Brook'
	String	'Jim Simmons'
	String	-1

	String	'Developed by'
	String	'Park Place Production Team'
	String	-1

	String	'Programmed by'
	String	'Jim Simmons'
	String	-1

	String	'Graphics Design by'
	String	'Brian O''Hara'
	String	'Steve Quinn'
	String	'Curt Toumanian'
	String	-1

	String	'Production Assistance by'
	String	'Michael Knox'
	String	'Troy Lyndon'
	String	'Jim Haldy'
	String	'for Park Place Production Team'
	String	-1

	String	'Music and Sound by'
	String	'Rob Hubbard'
	String	-1

	String	'Executive Producer'
	String	'Richard Hilleman'
	String	-1

	String	'Produced by'
	String	'Michael Brook'
	String	-1

	String	'Technical Director'
	String	'Scott Cronce'
	String	-1

	String	'Assistant Producer'
	String	'Ed Gwynn'
	String	-1

	String	'Special Thanks to'
	String	'Mark Hughes and Scooter Henson'
	String	'of the San Diego Gulls'

	String	''
	String	-1
	String	-1