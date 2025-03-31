;Penalty logic	
Penaltylist
	dc.w	$0000
PenEOP	equ	(*-Penaltylist)
	dc.w	PenDataEOP-Penaltylist
PenEOG	equ	(*-Penaltylist)
	dc.w	PenDataEOG-Penaltylist
PenGoal	=	(*-Penaltylist)
	dc.w	PenDataGoal-Penaltylist
PenIcing	equ	(*-Penaltylist)
	dc.w	PenDataice-Penaltylist
PenOffsides	equ	(*-Penaltylist)
	dc.w	PenDataoffsides-Penaltylist
PenOOP	=	(*-Penaltylist)
	dc.w	PenDataGhold-Penaltylist
PenGhold	equ	(*-Penaltylist)
	dc.w	PenDataGhold-Penaltylist
PenCharging	=	(*-Penaltylist)
	dc.w	PenDatacharge-Penaltylist
PenSlashing	=	(*-Penaltylist)
	dc.w	PenDataslash-Penaltylist
PenTripping	=	(*-Penaltylist)
	dc.w	PenDatatrip-Penaltylist
PenRoughing	=	(*-Penaltylist)
	dc.w	PenDatarough-Penaltylist
PenHooking	=	(*-Penaltylist)
	dc.w	PenDatahook-Penaltylist
PenCrossChk	=	(*-Penaltylist)
	dc.w	PenDatacross-Penaltylist
PenInterference	=	(*-Penaltylist)
	dc.w	PenDataint-Penaltylist
PenHolding	=	(*-Penaltylist)
	dc.w	PenDataHold-Penaltylist
PenFighting	=	(*-Penaltylist)
	dc.w	PenDatafight-Penaltylist
PenInst	=	(*-Penaltylist)
	dc.w	PenDataInst-Penaltylist
PenDelay	=	(*-Penaltylist)
	dc.w	PenDatadelay-Penaltylist
PenWhistle	=	(*-Penaltylist)
	dc.w	PenDatawhistle-Penaltylist

;format
;	dc.w	$ttmm	;tt=slow dnw time in half secs,mm=penalty min.
;	String	'penalty text'
;	dc.w	$ffdd,$ffdd,$ffdd,...	;ff = frame,dd=delay (neg for end)

PenDataEOP	dc.w	$0100
	String	'Period Over'
	dc.w	-$1f10
PenDataEOG	dc.w	$0100
	String	'Game Over'
	dc.w	$1f10,-$4030
PenDataGoal	dc.w	$0100
	String	'Goal!'
	dc.w	$1f0a,-$4010
PenDataice	dc.w	$0100
	String	'Icing'
	dc.w	$1802,$1901,-$1a06
PenDataoffsides	dc.w	$0100
	String	'Off-side'
	dc.w	$1802,$1d01,-$1e0f
PenDataghold	dc.w	$0100
	String	'Face Off'
	dc.w	-$1f0a
PenDatadelay	dc.w	$0000
	String	'Penalty'
	dc.w	$1803,$1d01,-$1e0f

PenDatawhistle	dc.w	$0000
	String	' '
	dc.w	-$1f0a


PenDatacharge	dc.w	$0402
	String	'  Charging  '
	dc.w	$0004,$0101,$1201,$1301,$1201,$1301,$1201,$1301,$1201,-$1301

PenDataslash	dc.w	$0402
	String	'  Slashing  '
	dc.w	$0004,$0101,$0201,$0301,$0201,$0301,$0201,$0301,$0201,-$0301

PenDatatrip	dc.w	$0402
	String	'  Tripping  '
	dc.w	$0004,$0401,$0501,$0401,$0501,$0401,$0501,$0401,-$0501

PenDatarough	dc.w	$0402
	String	'  Roughing  '
	dc.w	$0004,$1601,$1701,$1601,$1701,$1601,$1701,$1601,-$1701

PenDatahook	dc.w	$0402
	String	'  Hooking   '
	dc.w	$0004,$0101,$0b01,$0101,$0b01,$0101,$0b01,$0101,-$0b01

PenDatacross	dc.w	$0402
	String	' Cross Check'
	dc.w	$0004,$0601,$1001,$1101,$1001,$1101,$1001,$1101,$1001,-$1101

PenDataint	dc.w	$0402
	String	'Interference'
	dc.w	$0004,$0101,-$1506

PenDataHold	dc.w	$0402
	String	'  Holding '
	dc.w	$0004,$0101,-$0b06

PenDatafight	dc.w	$2805
	String	'  Fighting  '
	dc.w	$0004,$1601,$1701,$1601,$1701,$1601,$1701,$1601,-$1701
PenDataInst	dc.w	$2802
	String	'  Fight Instigator  '
	dc.w	$0004,$1601,$1701,$1601,$1701,$1601,$1701,$1601,-$1701

AddPenalty
;d0 = penalty number (from above)
;a3 = player or player on penalized team
	btst	#gmclock,gmode
	bne	rtss
	cmp	#PenIcing,d0
	beq	Addpenalty2
	tst	OptPen
	beq	rtss	;penalties off
	btst	#gmoffs,gmode
	bne	AddPenalty2
	cmp	#PenOffsides,d0
	beq	rtss

AddPenalty2	;forced penalties like face off and game over
;d0 = penalty number (from above)
;a3 = player or player on penalized team
	btst	#sfhor,sflags
	bne	rtss
	movem.l	a0-a1/d1,-(a7)
	move	#PenBuf,a1
	moveq	#MaxPen-1,d1
.0	tst	(a1)+
	dbeq	d1,.0
	bne	.noplayer
	move.b	SCnum+1(a3),-(a1)
	move.b	d0,-(a1)
	move.l	#Penaltylist,a0
	add	0(a0,d0),a0
	tst.b	1(a0)
	beq	.noplayer
	bset	#pf2pen,pflags2(a3)
	beq	.noplayer
	clr	(a1)
.noplayer
	movem.l	(a7)+,a0-a1/d1
	rts

PenaltyManager
;called periodically
;d7 = elapse time since last call
	bsr	updatepentime
	bsr	checkfornewpen
	bsr	chkprogress
	bra	updatepa

chkprogress
;control progress of ref and game control thru penalty events
	btst	#gmpen,gmode
	beq	rtss
	tst	PenCntDwn
	bmi	InProgress
	sub	d7,Pencntdwn
	bpl	rtss
	bclr	#gmpendel,gmode
	move	#PenBuf,a0
	tst	2(a0)
	bne	.hor
	clr	d0
	move.b	(a0),d0
	move.l	#Penaltylist,a0
	add	0(a0,d0),a0
	tst.b	1(a0)
	beq	rtss
.hor
	tst	OptPen
	beq	rtss	;penalties off
	bset	#sf2drec,sflags2	;switch to horizontal mode for player to enter penalty box
	move	Vcount,-(a7)
	bsr	forceblack
	move	(a7)+,Vcount
	bsr	SetHor
	bsr	NewTicker
	st	puckc
	move.l	#puckx,a3
	moveq	#pnothing,d0
	bsr	assinsert
	move	#120*60,temp1(a3)

	st	RefStep
	clr	RefCnt
	bsr	UpdatePA
	move	#50,RefCnt
	move	#24,palcount
	rts

InProgress
	;ref in progress-- update graphics and stats and penalty information
	tst	RefCnt
	bpl	rtss	;animation in progress
	tst	RefStep
	bpl	rtss
	movem.l	d0/a0-a3,-(a7)
.top	move	#PenBuf,a0
	tst	(a0)+
	beq	.exit
.0	tst	(a0)+
	bne	.0
	sub	#4,a0
	bclr	#7,1(a0)	;player who is guilty
	bne	.Sa
	move.l	a3,-(a7)
	clr	d1
	move.b	1(a0),d1
	asl	#scsize,d1
	move	#SortCords,a3
	add	d1,a3
	tst	position(a3)
	move.l	(a7)+,a3
	bpl	.ex
.clr	clr	(a0)
	bra	.ex

.Sa
	clr	d0
	move.b	(a0),d0
	move.l	#PenaltyList,a1
	add	0(a1,d0),a1
	clr	d2
	move.b	1(a1),d2	;penalty minutes
	beq	.sa2	;no player involved
	tst	OptPen
	beq	.clr
	movem.l	d0-d1/a1-a3,-(a7)
	clr	d1
	move.b	1(a0),d1
	asl	#scsize,d1
	move.l	#SortCords,a3
	add	d1,a3
	move.l	#tmstruct,a2
	lea	tmsize(a2),a1
	btst	#pfteam,pflags(a3)
	beq	.sa1
	exg	a1,a2
.sa1	add	#1,tmpenalties(a2)
	add	d2,tmpenmin(a2)
	clr	d0
	move.b	Pnum(a3),d0
	asl	#1,d0
	ext	d2
	mulu	#60,d2
	move	d2,tmpdst(a2,d0)
	bsr	coinsearch
	
	move	#apenalty,d0
	bsr	assreplace	
	movem.l	(a7)+,d0-d1/a1-a3
	bsr	SetPA
	bsr	USboard
	bra	.ex
.sa2
	clr	(a0)
	btst	#sfhor,sflags
	bne	.top
	bsr	SetPA
	bra	.ex

.exit
	move.l	#tmstruct,a2
	bsr	.ap
	add	#tmsize,a2
	bsr	.ap
	
	bclr	#gmpen,gmode
	move.l	#puckx,a3
	move	#pfaceoff,d0
	bsr	assreplace
.ex	movem.l	(a7)+,d0/a0-a3
	rts

.ap	bsr	getlowestpen
	moveq	#6,d1
	moveq	#(MaxRos-1)*2,d0
.aptop	tst	tmpdst(a2,d0)
	ble	.nap
	btst	#6,tmpdst(a2,d0)
	bne	.nap
	sub	#1,d1
	cmp.b	2(a0),d0
	beq	.nap
	cmp.b	1(a0),d0
	beq	.nap
	add	#1,d1
	bset	#6,tmpdst(a2,d0)	;set delayed pen.
	bset	#5,tmpdst(a2,d0)	;don't count down
.nap	sub	#2,d0
	bpl	.aptop
	move	d1,tmap(a2)
	rts

coinsearch	;look for coincidental penalties
;a1 = other team
;a2 = penalized team
;d0 = player who is penalized
;d2 = penalty called
	moveq	#(MaxRos-1)*2,d1
.top	cmp	tmpdst(a1,d1),d2
	beq	.coin
	sub	#2,d1
	bpl	.top
	rts
.coin	bset	#6,tmpdst(a1,d1)
	bset	#6,tmpdst(a2,d0)
	rts

checkfornewpen
	;look for new penalty (entered thru addpenalty(2))
	btst	#sfhor,sflags
	bne	rtss
	move	#PenBuf,a0
.next	tst	(a0)+
	beq	rtss
	btst	#gmpen,gmode
	bne	.iscalled
	clr	d0
	move.b	-2(a0),d0
	move.l	#PenaltyList,a1
	add	0(a1,d0),a1
	tst.b	1(a1)	;time for penalty
	beq	.callit
	move	puckc,d0
	bmi	.dc
	sub	#6,d0
	move.b	-1(a0),d1	;player penalized
	ext	d1
	sub	#6,d1
	eor	d1,d0
	bmi	.dc	;delayed penalty call

.callit	bsr	Stop4Pen

.iscalled	bset	#7,-1(a0)
	bne	.next
	clr	d0
	move.b	-2(a0),d0	;penalty called
	move.l	#PenaltyList,a1
	add	0(a1,d0),a1
	clr	d1
	move.b	0(a1),d1	;delay for stopping action
	asl	#5,d1
	cmp	Pencntdwn,d1
	ble	.next
	move	d1,Pencntdwn
	bra	.next

.dc	bset	#gmpendel,gmode
	bne	.next	
	move	#PenDelay,d0
	bsr	SetPA
	bra	.next

Stop4Pen	;a0 = penaltylist penalty +2
	bset	#gmclock,gmode
	bne	.skipfo
	clr	d0
	clr	d1
	cmp.b	#PenGoal,-2(a0)
	beq	.noticing
	move	ltx,d0
	move	lty,d1
	cmp.b	#PenOOP,-2(a0)
	beq	.noticing
	move	puckx,d0
	move	pucky,d1
	cmp.b	#PenIcing,-2(a0)
	bne	.noticing
	move.l	a3,-(a7)
	move	#SortCords,a3
	move.b	-1(a0),d1
	ext	d1
	asl	#scsize,d1
	add	d1,a3
	move	#600,d1
	btst	#pfgoal,pflags(a3)
	move.l	(a7)+,a3
	beq	.noticing
	neg	d1
.noticing
.xspot	=	70
.yspot	=	206
.ygive	=	40
	movem	d0-d1,-(a7)
	cmp	#.xspot,d0
	blt	.0
	move	#.xspot,d0
.0	cmp	#-.xspot,d0
	bgt	.1
	move	#-.xspot,d0
.1	cmp	#.yspot-.ygive,d1
	blt	.2
	move	#.yspot,d1
	move	#.xspot,d0
	tst	(a7)
	bpl	.2
	neg	d0
.2	cmp	#-.yspot+.ygive,d1
	bgt	.3
	move	#-.yspot,d1	
	move	#.xspot,d0
	tst	(a7)
	bpl	.3
	neg	d0
.3	move	d0,fox
	move	d1,foy
	add	#4,a7
	bsr	limitfo

.skipfo	clr	PenCntDwn
	bset	#gmpen,gmode
	move	#SFXwhistle,-(a7)
	bsr	sfx
	move	#PenWhistle,d0
	bra	SetPA

limitfo	;limit face off to 5-20 feet from walls of rink
.nux	=	70
.nuy	=	65
	movem.l	d0-d1/a0-a1,-(a7)
	move	#PenBuf,a0
.loop	bsr	.lf
	add	#2,a0
	tst	(a0)
	bne	.loop
	movem.l	(a7)+,d0-d1/a0-a1
	rts

.lf	move.b	1(a0),d0
	and	#$7f,d0
	asl	#scsize,d0
	move	#SortCords,a1
	move	blueline,d1
	btst	#pfgoal,pflags(a1,d0)
	bne	.0
	neg	d1
	cmp	foy,d1
	blt	rtss
	move	#-.nuy,foy
	bra	.sx
.0	cmp	foy,d1
	bgt	rtss
	move	#.nuy,foy
.sx	move	#.nux,d0
	tst	fox
	bpl	.1
	neg	d0
.1	move	d0,fox
	rts

UpdatePA	;animate ref in ref window
	tst	RefCnt
	bmi	rtss
	sub	d7,RefCnt
	bmi	SetPA2
	rts

SetPA	;start ref animation 
	;d0 = animaiton (penalty number)
	move	d0,RefPen
	clr	RefStep
	bsr	prefmes

SetPA2	;update animation for ref 
	movem.l	d0-d2/a0-a1,-(a7)
	move	#$40,d0
	tst	RefStep
	bmi	.pr
	move	RefStep,d0
	add	#2,RefStep
	move	RefPen,d1
	move.l	#PenaltyList,a0
	add	0(a0,d1),a0
	add	#2,a0
	add	(a0),a0
	move	0(a0,d0),d0
	bpl	.0
	neg	d0
	st	RefStep	
.0	clr	d1
	move.b	d0,d1
	asl	#3,d1
	move	d1,RefCnt
	lsr	#8,d0
.pr	bsr	PushRef
	movem.l	(a7)+,d0-d2/a0-a1
	rts

PushRef	;tell vblank what to display
	movem.l	d0-d2/a0-a1,-(a7)
	cmp	#$40,d0
	beq	.clearit
	mulu	#refwidth*refheight*2,d0
	move.l	#RefsMap,a0
	add.l	4(a0),a0
	add	#4,a0
	add	d0,a0
	move.l	#RefRamMap,a1
	move	ExtraChars,d2
	btst	#sfhor,sflags
	bne	.4
	or	#$8000,d2
.4	moveq	#(refheight*refwidth)-1,d0
.1	move	(a0)+,(a1)
	add	d2,(a1)+
	dbf	d0,.1
	bset	#sf2refref,sflags2
	bra	.ex

.clearit
	move.l	#RefRamMap,a1
	moveq	#(refheight*refwidth)-1,d0
.2	move	#1,(a1)+
	dbf	d0,.2
	bset	#sf2refref,sflags2
	moveq	#-1,d0	;clear line
	bsr	prefmes

.ex	movem.l	(a7)+,d0-d2/a0-a1
	rts

prefmes	;print message for penalty
	movem.l	d0-d2/a1,-(a7)
	btst	#sfhor,sflags
	bne	.hor
	tst	d0
	bpl	.noblank
	bsr	printz
	String	-$41,0,10
	moveq	#13,d0
	moveq	#3,d1
	moveq	#1,d2
	bsr	eraser
	bra	.ex

.noblank	bsr	printz
	String	-$41,6,10
	move.l	#PenaltyList,a1
	add	0(a1,d0),a1
	add	#2,a1
	move	(a1),d0
	cmp	#4,d0
	bls	.ex
	lsr	#1,d0
	sub	d0,printx
	bpl	.nb0
	clr	printx
.nb0	move	(a1),d0
	tst.b	-1(a1,d0)
	bne	.nb1
	sub	#1,d0
.nb1	moveq	#3,d1
	bsr	framer
	sub	#2,printy
	add	#1,printx
	bsr	print
	bra	.ex

.hor	tst	d0
	bpl	.noblankh
	bsr	printz
	String	-$41,8,11,'                '
	bra	.ex
.noblankh	bsr	printz
	String	-$41,17,11
.0	move.l	#PenaltyList,a1
	add	0(a1,d0),a1
	add	#2,a1
	move	(a1),d0
	lsr	#1,d0
	sub	d0,printx
	bsr	print
.ex	movem.l	(a7)+,d0-d2/a1
	rts

PenGoalStuff
	;do this stuff after a goal
	movem.l	d0-d2/a0-a2,-(a7)
	move	#tmstruct,a2
	lea	0(a2,d0),a1	;scoring team
	eor	#tmsize,d0
	lea	0(a2,d0),a2

	moveq	#maxpen-1,d0
	move	#PenBuf,a0
.0	clr	(a0)+
	dbf	d0,.0

	move	tmap(a1),d2	;end p.killing by scored on team
	cmp	tmap(a2),d2
	ble	.ex
	bsr	GetLowestPen
	clr	d0
	move.b	2(a0),d0
	bmi	.ex
	add	#1,tmPwrGoals(a1)
	add	#1,tmap(a2)
	bset	#tmflcc,tmstruct+tmflags
	bset	#tmflcc,tmstruct+tmsize+tmflags
	clr	tmpdst(a2,d0)
.ex	movem.l	(a7)+,d0-d2/a0-a2
	rts

updatepentime
	;update the time remaining on all penalized players
	;a2 = team struct
	btst	#gmclock,gmode
	bne	rtss
	sub	d7,Penaltytimer
	bpl	rtss
	add	#jps,Penaltytimer
	bsr	chkatop
	move.l	#tmstruct,a2
	bsr	.ut
	add	#tmsize,a2
.ut
	moveq	#(MaxRos-1)*2,d0
.2	tst	tmpdst(a2,d0)
	ble	.next2
	btst	#6,tmpdst(a2,d0)
	bne	.coinpen
	sub	d7,tmpdst(a2,d0)
	cmp	#5,tmpdst(a2,d0)
	bgt	.next2
	move	#SFXbeep1,-(a7)
	tst	tmpdst(a2,d0)
	bgt	.snd
	clr	tmpdst(a2,d0)
	bsr	releasepl
	move	#SFXbeep2,(a7)
.snd	bsr	sfx
	bra	.next2
.coinpen	btst	#5,tmpdst(a2,d0)
	bne	.next2	;delayed penalty
	sub	d7,tmpdst(a2,d0)
	btst	#6,tmpdst(a2,d0)
	bne	.next2
	clr	tmpdst(a2,d0)
.next2	sub	#2,d0
	bpl	.2
	rts

chkatop	;attack time of possession stat update
	moveq	#0,d1
	move	pucky,d0
	cmp	blueline,d0
	bgt	.1
	move.l	#tmsize,d1
	neg	d0
	cmp	blueline,d0
	blt	rtss
.1	btst	#gmdir,gmode
	beq	.0
	eor	#tmsize,d1
.0	move	#tmstruct,a2
	add	#1,tmatop(a2,d1)
	rts

releasepl	;player's penalty time is up so let him out (if appropriate)
	movem.l	d0-d3/a0-a3,-(a7)
	moveq	#(MaxRos-1)*2,d3
.top	tst	tmpdst(a2,d3)
	ble	.next
	bclr	#5,tmpdst(a2,d3)
	bne	.done
.next	sub	#2,d3
	bpl	.top
.done
	move.l	tmsort(a2),a3
	sub	#SCstruct,a3
.0	add	#SCstruct,a3
	tst	position(a3)
	bpl	.0

	move	d0,d3
	lsr	#1,d3
	move	tmap(a2),d1
	add	#1,tmap(a2)
	bset	#tmflcc,tmstruct+tmflags
	bset	#tmflcc,tmstruct+tmsize+tmflags
	move.l	#priolist,a0
	cmp	#2,tmgoalie(a2)
	bne	.gin
	add	#1,a0
.gin
	clr	position(a3)
	move.b	0(a0,d1),position+1(a3)
	bsr	setplass
	bsr	SetPlayer
	bset	#pf2unav,pflags2(a3)
	movem.l	(a7)+,d0-d3/a0-a3
	rts

updatepwrplay
	;show graphic and time remaining for power plays
	move	#tmstruct,a2
	lea	tmsize(a2),a3
	move	tmap(a2),d0
	sub	tmap(a3),d0
	beq	.clrpwrplay
	bpl	.t0
	neg	d0
	btst	#sf2pwrtm,sflags2
	bne	.upp
	bsr	.clrpwrplay
	bset	#sf2pwrtm,sflags2
	bra	.upp

.t0	exg	a2,a3
	btst	#sf2pwrtm,sflags2
	beq	.upp
	bsr	.clrpwrplay
	bclr	#sf2pwrtm,sflags2

.upp	bset	#sf2pwrplay,sflags2
	bne	.uppt
	add	#1,tmpwrplays(a3)
.uppt
	move	d0,-(a7)
	bsr	GetLowestPen
	move.l	#pllist+3,a0
	sub	(a7)+,a0
	clr	d0
	move.b	(a0),d0
	bmi	rtss

	bsr	printz
	;String	-$41,1,25,'   ',22,23,24,25,-$41,1,26,'   '	
	;dc.b  $19,$BF,$01,$1A,$20,$20    ; Write 6 bytes directly
	dc.b $00,$12,$BF,$01,$19,$20,$20,$20,$16,$17,$18,$19,$BF,$01,$1A,$20,$20,$20

	move	tmpdst(a2,d0),d2	;penalty time
	move.l	#mesarea+2,a1
	bsr	pplpen
	bsr	Printz
	String	-$41,1,25
	move	SmallLogoscset,d3
	btst	#sf2pwrtm,sflags2
	beq	DoSmallLogo
	add	#4,d3
	bra	DoSmallLogo

.clrpwrplay
	bclr	#sf2pwrplay,sflags2
	beq	rtss
	bra	EASNLogo

ClrHor
	;revert the graphics back to vetical ice rink mode
	movem.l	d0-d7/a0-a6,-(a7)
	bclr	#sfhor,sflags
	move	#1000,Oldrow

	bsr	SprSort

	move	SmallFontChars,d1
	move.l	#SmallFontMap,a0
	add	#8,a0
	move	(a0)+,d0
	asl	#4,d0
	asl	#5,d1
	move.l	#.sfmap,a1
	bsr	ReMap

	move	BigFontChars,d1
	move.l	#BigFontMap,a0
	add	#8,a0
	move	(a0)+,d0
	asl	#4,d0
	asl	#5,d1
	move.l	#.bfmap,a1
	bsr	ReMap

	btst	#sfpz,sflags
	bne	.0
	bsr	printz
	String	-$01,0,0
	moveq	#32,d0
	moveq	#28,d1
	moveq	#1,d2
	bsr	eraser
	bsr	PrintScores1
.0

.ex	movem.l	(a7)+,d0-d7/a0-a6
	rts

.bfmap	dc.b	4,3,4,3
.sfmap	dc.b	4,3,4,9,12,2


SetHor
	;switch graphics to horizontal ice rink graphics mode
	movem.l	d0-d7/a0-a6,-(a7)
	bset	#sfhor,sflags

.p	btst	#dfok,disflags
	bne	.p

	clr	hscroll
	clr	vscroll
	bsr	SprSort

	bsr	printz
	string	-$02,0,0
	move.l	#IceRinkMap,a1
	add.l	4(a1),a1
	move.l	#null,a2
	clr	d0
	moveq	#85,d1
	moveq	#32,d2
	moveq	#28,d3
	move	rinkvrcset,d4
	moveq	#%0000,d5
	bsr	dobitmap

	move	SmallFontChars,d1
	move.l	#SmallFontMap,a0
	add	#8,a0
	move	(a0)+,d0
	asl	#4,d0
	asl	#5,d1
	move.l	#.sfmap,a1
	bsr	ReMap

	move	BigFontChars,d1
	move.l	#BigFontMap,a0
	add	#8,a0
	move	(a0)+,d0
	asl	#4,d0
	asl	#5,d1
	move.l	#.bfmap,a1
	bsr	ReMap

	bsr	USBoard
	btst	#sfpz,sflags
	bne	.ex
	move	#$1000,d0
	move	VmMap1,d1
	moveq	#1,d2
	bsr	doFill

.ex	movem.l	(a7)+,d0-d7/a0-a6
	rts

.bfmap
.sfmap	dc.b	4,3,4,3,3,3,3,3,3,3,3,3,3,3,3,3

printscores1
	;draw scoreboard for horizontal ice rink display
	movem.l	d0-d2/a0-a3,-(a7)
	btst	#sfhor,sflags
	bne	.sbscreen

	bsr	printz
	String	-$41,0,23
	moveq	#9,d0
	moveq	#5,d1
	bsr	framer

	bset	#dfclock,disflags

	bsr	printz
	String	-$41,1,24
	bsr	.pp

	bsr	EASNLogo

	btst	#sf3llcs,sflags3
	bne	.nsc

	bsr	printz
	String	-$41,24,23
	moveq	#8,d0
	moveq	#5,d1
	bsr	framer

	bsr	printbigz
	String	-$41,29,24
	move	#tmstruct,a2
	lea	tmscore(a2),a0
	move	SmallLogoscset,d3
	bsr	.ps

	bsr	printbigz
	String	-$41,25,24	
	add	#tmsize,a2
	lea	tmscore(a2),a0
	move	SmallLogoscset,d3
	add	#4,d3
	bsr	.ps
.nsc
	move	#tmstruct,a2
	lea	tmsize(a2),a3
	btst	#gmdir,gmode
	bne	.noflip
	exg	a2,a3
.noflip
	bsr	printz
	String	-$41,15,1
	bsr	.pl
	exg	a2,a3
	bsr	printz
	String	-$41,15,26
	bsr	.pl

.ex	movem.l	(a7)+,d0-d2/a0-a3
	rts

.sbscreen
	bsr	printz
	String	-$42,14,5
	bsr	.pp

	bsr	printz
	string	-$42,23,4
	move.l	#tmstruct,a2
	lea	tmscore(a2),a0
	move	(a0),d0
	bsr	PushNumber
	bsr	PrintBig

	bsr	printz
	string	-$42,7,4
	add	#tmsize,a2
	lea	tmscore(a2),a0
	move	(a0),d0
	bsr	PushNumber
	bsr	PrintBig
	bra	.ex

.pp	move	gsp,d0
	move.l	#PerLabels,a0
.00	move.l	a0,a1
	add	(a0),a0
	dbf	d0,.00
	bra	print

.ps
	bsr	DoSmallLogo

	move	#mesarea,a1
	move	#4,(a1)
	move.b	#' ',2(a1)
	clr.l	d0
	move	(a0),d0
	divu	#10,d0
	beq	.ps2
	add	#'0',d0
	move.b	d0,2(a1)
.ps2	swap	d0
	add	#'0',d0
	move.b	d0,3(a1)
	bra	Print

.pl	tst	OptLine
	bne	rtss
	move	tmline(a2),d0
	move.l	#linelist,a0
.pl0	move.l	a0,a1
	add	(a0),a0
	dbf	d0,.pl0
	bra	print

linelist	String	'Sc1'	;text list for line choices
	String	'Sc2'
	String	'Chk'
	String	'Pw1'
	String	'Pw2'
	String	'PK1'
	String	'PK2'

PerLabels	String	'1',18	;text list for periods
	String	'2',19
	String	'3',20
	String	'OT'
	String	'Final'


DoSmallLogo
	;draw small logo at printx/y/m
	;d3 = char area for small logo to display
	movem.l	d0-d3/a0,-(a7)
	bsr	xyVmMap
	or	#$a000,d3
	move	d3,(a0)
	add	#1,d3
	move	d3,(a0)
	add	#1,printy
	bsr	xyVmMap
	add	#1,d3
	move	d3,(a0)
	add	#1,d3
	move	d3,(a0)
	add	#1,printy
	movem.l	(a7)+,d0-d3/a0
	rts

EASNLogo	;draw easn.map (on vertical ice rink if no power play)
	btst	#sf2pwrplay,sflags2
	bne	rtss
	bsr	printz
	String	-$41,1,25
	moveq	#0,d0
	clr	d1
	moveq	#7,d2
	moveq	#2,d3
	move	EASNcset,d4
	clr	d5
	move.l	#EASNmap,a1
	add.l	4(a1),a1
	move.l	#null,a2
	bsr	DoBitMap
	rts

DebugWindow
    ; Draw a new framer window beside the EASN logo for debug purposes    
	bsr    printz
    String -$41,9,23   ; Y-position to match EASN logo
    moveq  #8,d0       ; Width of the window 
    moveq  #5,d1       ; Height to match EASN logo
    bsr    framer      ; Draw the frame
    
    ; Clear the previous content first
    bsr    printz
    String -$41,10,24  ; Position for text
    bsr    printz
    String 'DEBUG'   ; Clear line with spaces
    
    ; Calculate puck speed (magnitude of velocity vector)
    move    puckvx,d0
    muls    d0,d0      ; vx²
    move    puckvy,d1
    muls    d1,d1      ; vy²
    add.l   d1,d0      ; vx² + vy²
    move    puckvz,d1
    muls    d1,d1      ; vz²
    add.l   d1,d0      ; vx² + vy² + vz²
    
    ; Square root calculation
    bsr     Sroot      ; d0 now contains √(vx² + vy² + vz²)

	move.w  d0,d1        ; Copy lower 16 bits of d0 (value in 0–30000)
    mulu    #240,d1      ; 16-bit unsigned multiply, result in d1.l
    lsr.l   #8,d1        ; Shift right 8 bits
    lsr.l   #8,d1        ; Shift right another 8 bits (total 16)
    move.w  d1,d0        ; d0 now has integer MPH value
    
    ; Display raw speed value
    bsr    printz
    String -$41,10,25  ; Center in the framer window
    bsr    PushNumber
    move.l  a1,a3      ; Save pointer to the number string
    
    ; Append " MPH" text to the number
    ;bsr     appendz
    ;String  " MPH"
    
    ; Now a3 contains the complete string with number and "MPH"
    move.l  a3,a1
    bsr     print
    
    rts

USBoard	;update score board
	;including penalties and time remaining
	movem.l	d0-d7/a0-a3,-(a7)
	bset	#dfclock,disflags
	bsr	printscores1

	bsr	printz
	String	-$42,20,8
	move.l	#tmstruct,a2
	bsr	.dispen
	bsr	printz
	String	-$42,5,8
	move.l	#tmstruct+tmsize,a2
	bsr	.dispen
	movem.l	(a7)+,d0-d7/a0-a3
	rts

.dispen	bsr	GetLowestPen

	moveq	#2,d3
.loop3	clr	d0
	move.b	0(a0,d3),d0
	bmi	rtss
	move	tmpdst(a2,d0),d2	;penalty time
	and	#$0fff,d2
	move.l	tmdata(a2),a1
	add	playerdata(a1),a1
	asl	#2,d0
	move.b	0(a1,d0),d0	;player number
	move.l	#mesarea+2,a1
	asl	#4,d0
	lsr.b	#4,d0
	add	#'00',d0
	move	d0,(a1)+
	move.b	#' ',(a1)+
	move	printx,-(a7)
	bsr	pplpen
	move	(a7)+,printx
	add	#1,printy
	dbf	d3,.loop3
	rts

pplpen	;print time remaining (d2)
	ext.l	d2
	divu	#60,d2
	add.b	#'0',d2
	move.b	d2,(a1)+
	move.b	#':',(a1)+
	swap	d2
	ext.l	d2
	divu	#10,d2
	add.b	#'0',d2
	move.b	d2,(a1)+
	swap	d2
	add.b	#'0',d2
	move.b	d2,(a1)+
.p	clr.b	(a1)+
	move.l	a1,d0
	move	#mesarea,a1
	sub.l	a1,d0
	move	d0,(a1)
	bra	print

GetLowestPen
	;a2 = team
	;return PlList = a0 list of players in order of release from p.box 
	move	#PlList,a0
	move.l	#-1,(a0)
	moveq	#2,d2
.loop2	moveq	#(MaxRos-1)*2,d0
	move	#$7fff,d1
.loop1	tst	tmpdst(a2,d0)
	ble	.next
	cmp	tmpdst(a2,d0),d1
	blt	.next
	cmp.b	2(a0),d0
	beq	.next
	cmp.b	1(a0),d0
	beq	.next
	move.b	d0,0(a0,d2)
	move	tmpdst(a2,d0),d1
.next	sub	#2,d0
	bpl	.loop1
	dbf	d2,.loop2
	rts

linebar
;d0 = line number
;a2 = tmstruct	
	movem.l	d0,-(a7)
	bsr	getlinee
	clr	d1
	cmp	#tmstruct,a2
	beq	.1
	moveq	#9,d1
.1	bsr	dobar
	movem.l	(a7)+,d0
	rts

getlinee	;d0 = line number
	;a2 = team struct
	;return d0 = energy level of this line
	movem.l	d1-d5/a0-a3,-(a7)
	move.l	tmsort(a2),a3
	move.l	tmdata(a2),a1
	add	LineSets(a1),a1
	asl	#3,d0
	add	d0,a1
	clr.l	d0
	clr	d1
	move.l	#priolist,a0
	move	tmap(a2),d4
	bra	.next
.loop
	clr	d5
	move.b	0(a0,d4),d5	;position
	beq	.next	;goalie energy doesn't count
	clr	d3
	move.b	0(a1,d5),d3	;player number
	asl	#1,d3
	add	#1,d1
	add	tmpde-2(a2,d3),d0
.next	dbf	d4,.loop
	divu	d1,d0
	movem.l	(a7)+,d1-d5/a0-a3
	rts

dobar	;draw energy bar for energy level d0
	;d1 = bar choice 0/9
	movem.l	d0-d3/a1,-(a7)
	ext.l	d0
	divu	#4096/16,d0
	cmp	#15,d0
	bls	.ok
	moveq	#15,d0
.ok
	move	#mesarea,a1
	move	#4,(a1)+
	moveq	#1,d3
.top	moveq	#-1,d2
	tst	d0
	bmi	.ok1
	move	d0,d2
	cmp	#7,d2
	ble	.ok1
	moveq	#7,d2
.ok1	add	#1,d2
	add	d1,d2
	move.b	d2,(a1)+
	bne	.ok2
	move.b	#' ',-1(a1)
.ok2
	sub	#8,d0
	dbf	d3,.top
	clr.b	(a1)
	move	printa,-(a7)
	tst	d1
	beq	.1
	or	#$6000,printa
.1	move	#mesarea,a1
	bsr	print

	sub	#7,printx
	eor	#$800,printa
	move	#mesarea,a1
	move.b	3(a1),d0
	move.b	2(a1),3(a1)
	move.b	d0,2(a1)
	bsr	print
	move	(a7)+,printa

	movem.l	(a7)+,d0-d3/a1
	rts

dodbar	;draw double width energy bar for energy level d0
	;d1 = bar choice 0/9
	movem.l	d0-d3/a1,-(a7)
	ext.l	d0
	divu	#4096/32,d0
	cmp	#31,d0
	bls	.ok
	moveq	#31,d0
.ok
	move	#mesarea,a1
	move	#6,(a1)+
	moveq	#3,d3
.top	moveq	#-1,d2
	tst	d0
	bmi	.ok1
	move	d0,d2
	cmp	#7,d2
	ble	.ok1
	moveq	#7,d2
.ok1	add	#1,d2
	add	d1,d2
	move.b	d2,(a1)+
	bne	.ok2
	move.b	#' ',-1(a1)
.ok2
	sub	#8,d0
	dbf	d3,.top

	tst	d1
	beq	.1
	or	#$6000,printa
.1	move	#mesarea,a1
	bsr	print
	sub	#11,printx
	eor	#$800,printa
	move	#mesarea,a1
	move.b	5(a1),d0
	move.b	2(a1),5(a1)
	move.b	d0,2(a1)
	move.b	4(a1),d0
	move.b	3(a1),4(a1)
	move.b	d0,3(a1)
	bsr	print
	eor	#$800,printa

	movem.l	(a7)+,d0-d3/a1
	rts

AvgCline	;return d0 = average energy of current line on team a2
	movem.l	d1-d3/a0,-(a7)
	clr.l	d0
	clr	d1
	moveq	#5,d2
	move.l	tmsort(a2),a0
.l0	tst	position(a0)
	ble	.next
	clr	d3
	move.b	pnum(a0),d3
	add	d3,d3
	add	tmpde(a2,d3),d0
	add	#1,d1
.next	add	#SCstruct,a0
	dbf	d2,.l0
	tst	d1
	beq	.ex
	divu	d1,d0
.ex	movem.l	(a7)+,d1-d3/a0
	rts

ChkShotStat	;add to shot stat if conditions agree
	;a2 = team struct
	bclr	#sf2shot,sflags2
	beq	rtss
	movem.l	d0-d1/a3,-(a7)
	move	shotplayer,d0
	asl	#scsize,d0
	move.l	#SortCords,a3
	add	d0,a3
	moveq	#1,d0
	moveq	#tmshots,d1
	bsr	addstat
	movem.l	(a7)+,d0-d1/a3
	rts

AddStat
	;add d0 to stat d1 on player a3's team
	move.l	a2,-(a7)
	move.l	#tmstruct,a2
	btst	#pfteam,pflags(a3)
	beq	.0
	add	#tmsize,a2
.0	add	d0,0(a2,d1)
	move.l	(a7)+,a2
	rts

Intermission
	;end of period junk (zamboni/stats)
	moveq	#15,d0
	move	#SortCords,a0
.0	clr	Xpos(a0)
	add	#SCstruct,a0
	dbf	d0,.0

	move	ExtraChars,d4
	move.l	#Zamframelist,a0
	move.l	#Zamsprites,a1
	bsr	Buildframelist
	move	d4,d1
	move	(a0)+,d0
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMA
	move	#320,zamx
	bclr	#sfpz,sflags

StatsReport
	;draw stats and wait while zamboni crosses screen
	;also show ticker scores from other games
	bsr	DisplayStats

	bsr	.gt
	move	TickerNum,d6
.top	move	#480,d0
	bsr	waitxsr
	btst	#sbut,d1
	bne	.clrh
	bsr	.gt
	cmp	TickerNum,d6
	bne	.top
	bra	.doh
.clrh	bset	#sf3sbut,sflags3
.doh	bsr	Dohilights
	bclr	#sf3sbut,sflags3
	bne	.clrz
	move	#480,d0
	bsr	waitxsr
.clrz	st	zamx
	rts

.gt	tst	TickerNum
	bmi	.gt0
	tst	TickerNum
	bne	NewTicker2
	tst	GameNum
	bne	NewTicker2
.gt0	bsr	getshifter
	move	d1,TickerNum
	bmi	rtss
	bra	NewTicker2

DisplayStats
	;draw stats
	bsr	KillCrowd
	bsr	printbigz
	String	-$42,11,2,'STATS'

	bsr	printz
	String	-$42,5,7
	moveq	#22,d0
	moveq	#5,d1
	move	smallfontchars,d2
	bsr	eraser

	bsr	printz
	String	-$42,13,7,'Shots'
	bsr	printz
	String	-$42,11,8,'Power Play'
	bsr	printz
	String	-$42,11,9,'Penalties'
	bsr	printz
	String	-$42,11,10,'Fights Won'
	bsr	printz
	String	-$42,11,11,'AttackZone'

	bsr	printz
	String	-$42,26,7
	move.l	#tmstruct,a2
	bsr	.ss
	bsr	printz
	String	-$42,9,7
	add	#tmsize,a2
;	bsr	.ss

.ss	move.l	#.sslist,a0
.sstop	move	(a0)+,d1
	bmi	.atz
	move	printx,-(a7)
	move	0(a2,d1),d0
	bsr	pushnumber
	move	(a0)+,d1
	bmi	.nextss
	move	#mesarea,a3
	move	#2,(a3)
	bsr	appstring
	bsr	appendz
	String	'/'
	move	0(a2,d1),d0
	bsr	pushnumber
	bsr	appstring
	move.l	a3,a1
.nextss	move	(a1),d0
	lsr	#1,d0
	sub	d0,printx
	bsr	print
	move	(a7)+,printx
	add	#1,printy
	bra	.sstop

.atz	move	tmATOP(a2),d0
	bsr	pushtime
	move	(a1),d0
	lsr	#1,d0
	sub	d0,printx
	bra	print

.sslist	dc.w	tmshots,-1
	dc.w	tmPwrGoals,tmPwrPlays
	dc.w	tmPenalties,tmPenMin
	dc.w	tmFightsWon,-1
	dc.w	-1,-1

InitScores
	;initialize other games scores/period in playoffs
	tst	OptPlayMode
	beq	rtss
	cmp	#1,gamelevel
	bgt	rtss
	bsr	GetShifter
	move	#gstruct,a0
	moveq	#gssize,d0
	mulu	d1,d0
	add	d0,a0
.top	cmp	gamenum,d1
	beq	.next
	btst	#gsfso,gsflags(a0)
	bne	.next
	clr	gsper(a0)
	moveq	#3,d0
	bsr	randomd0
	bra	.1
.0	bsr	SetScore
.1	dbf	d0,.0
.next	sub	#gssize,a0
	dbf	d1,.top
	rts

UpdateScores
	;update ticker score values
	bsr	GetShifter
	move	d1,TickerNum
	move	#gstruct,a0
	moveq	#gssize,d0
	mulu	d1,d0
	add	d0,a0
.top	cmp	gamenum,d1
	beq	.next
	bclr	#gsfhl,gsflags(a0)
	btst	#gsfso,gsflags(a0)
	bne	.next
	bsr	SetScore
.next	sub	#gssize,a0
	dbf	d1,.top
	rts

SetScore	;add to score for game in a0
	cmp	#4,gsper(a0)
	bge	rtss
	movem.l	d0-d1/a0-a1,-(a7)
	cmp	#3,gsper(a0)
	bne	.0
	move	#5,gsper(a0)
	move	gss1(a0),d0
	sub	gss2(a0),d0
	cmp	#1,d0
	bgt	.ex
	cmp	#-1,d0
	blt	.ex
	move	#3,gsper(a0)
	bset	#gsfhl,gsflags(a0)
	bra	.ex

.0	add	#1,gsper(a0)
	move	gst1(a0),d0
	bsr	.getscore
	add	d1,gss1(a0)
	move	gst2(a0),d0
	bsr	.getscore
	add	d1,gss2(a0)
.ex	movem.l	(a7)+,d0-d1/a0-a1
	rts

.getscore	asl	#2,d0
	move.l	#TeamList,a1
	move.l	0(a1,d0),a1
	add	ScoreOdds(a1),a1
	clr	d0
	move.b	(a1),d0
	asl	#2,d0
	move.l	#.sctab,a1
	add	d0,a1

	moveq	#100,d0
	bsr	randomd0
	moveq	#3,d1
.1	sub.b	0(a1,d1),d0
	dbmi	d1,.1
	rts

.sctab	dc.b	15,38,32,15
	dc.b	19,38,31,12
	dc.b	22,37,31,10
	dc.b	26,36,30,8

	dc.b	30,34,30,6
	dc.b	35,33,26,6
	dc.b	39,32,24,5
	dc.b	43,30,23,4

NewTicker
	cmp	#480,gameclock
	bgt	rtss
NewTicker2	;goto next ticker
	tst	OptPlayMode
	beq	rtss
	move	TickerNum,d3
	bmi	rtss
	sub	#1,TickerNum
	cmp	GameNum,d3	;don't show current game as ticker
	beq	NewTicker2

NewTicker3	;display ticker score for team d3
	moveq	#gssize,d0
	mulu	d3,d0
	move	#gstruct,a0
	add	d0,a0
	btst	#gsfhl,gsflags(a0)
	bne	NewTicker2	;don't show if hilite coming up
	btst	#gsfso,gsflags(a0)
	bne	NewTicker2	;don't show if the series is over for this game

	bsr	printz
	String	-$43,2,23
	btst	#sfpz,sflags
	bne	.1
	bsr	printz
	String	-$41,2,23
.1	btst	#sfhor,sflags
	bne	.0
	sub	#5,printy
.0
	moveq	#28,d0
	moveq	#5,d1
	bsr	framer
	add	#1,printx
	sub	#4,printy
	move	printx,-(a7)
	bsr	getshifter
	move	#$a000,printa
	bsr	printz
	String	'                          '
	move	(a7),printx
	move	d3,d0
	add	d2,d0
	move.l	#GameLabels,a1
	bsr	Fprint

	move	(a7),printx
	add	#21,printx
	move	gsper(a0),d0
	sub	#1,d0
	move.l	#PerLabels,a1
	bsr	Fprint
	move	#$8000,printa

	move	gst1(a0),d0
	move	gss1(a0),d1
	bsr	.tn
	move	gst2(a0),d0
	move	gss2(a0),d1
	bsr	.tn
	add	#2,a7
	rts

.tn
	move	4(a7),printx
	add	#1,printy
	move.l	#TeamList,a1
	asl	#2,d0
	move.l	0(a1,d0),a1
	add	TeamName(a1),a1
	bsr	print
	move	4(a7),printx
	add	#23,printx
	move	d1,d0
	bsr	pushnumber
	bra	print

Fprint	;special print which advances thru list of strings and prints string number d0
	bra	.1
.0	add	(a1),a1
.1	dbf	d0,.0
	bra	print

GameLabels
	String	'Norris Semifinals'
	String	'Norris Semifinals'
	String	'Smythe Semifinals'
	String	'Smythe Semifinals'
	String	'Adams Semifinals'
	String	'Adams Semifinals'
	String	'Patrick Semifinals'
	String	'Patrick Semifinals'

	String	'Norris Finals'
	String	'Smythe Finals'
	String	'Adams Finals'
	String	'Patrick Finals'

	String	'Campbell Finals'
	String	'Wales Finals'

	String	'Stanley Cup'

DoHiLights	;hilites logic
	;search for hilite game and show hilite
	tst	OptPlayMode
	beq	rtss
	bsr	GetShifter
	moveq	#gssize,d3
	mulu	d1,d3
	move	#gstruct,a0
	add	d3,a0
.top	btst	#gsfso,gsflags(a0)
	bne	.next
	bclr	#gsfhl,gsflags(a0)
	beq	.next
	bsr	starthl
.next	sub	#gssize,a0
	dbf	d1,.top
	rts

StartHL	movem.l	d0-d7/a0-a6,-(a7)
StartHL2	;play hilite for game a0
	btst	#sf3sbut,sflags3
	bne	.nhl0

	bsr	.sv

	move	d1,d3
	bsr	NewTicker3	;show score from hilight game

	btst	#sf3sbut,sflags3
	bne	.nhl1
	move	#4,printx
	sub	#6,printy
	moveq	#24,d0
	moveq	#3,d1
	bsr	framer
	add	#1,printx
	sub	#2,printy
	bsr	printz
	String	'Highlight from game:'

	move	#180,d0
	bsr	waitxsr
	btst	#sbut,d1
	bne	.nhl1
	st	zamx

	move	gst1(a0),HomeTeam	;set up teams for game in a0
	move	gst2(a0),VisTeam
	move.l	a0,-(a7)
	bsr	SetTeams
	bsr	RestoreTeams
	move.l	#tmstruct,a2
	bsr	reenergizeteam
	add	#tmsize,a2
	bsr	reenergizeteam
	st	c1playernum
	st	c2playernum
	clr	cont1team
	clr	cont2team
	move.l	#ReplayStart+(gstruct-gmode)+4,recbpr
	moveq	#120,d0
	bsr	randomd0
	add	#60,d0
	move	d0,gameclock
	move.l	(a7),a0
	move	gsper(a0),gsp
	sub	#1,gsp
	move	gss1(a0),tmstruct+tmscore
	move	gss2(a0),tmstruct+tmsize+tmscore
	;move.b	#2^gmhl,gmode
	move.b  #(1<<gmhl),gmode    ; 1 shifted left 4 times = 16
	btst	#0,gsp+1
	beq	.ndi
	bset	#gmdir,gmode
.ndi
	clr.b	sflags
	;move.b	#2^sf2drec,sflags2
	move.b  #(1<<sf2drec),sflags2    ; 1 shifted left 4 times = 16
	clr.b	sflags3

	bset	#dfclock,disflags
	clr	glovecords
	clr.b	iflags
	st	RefCnt
	st	puckcross+2
	st	puckcross+6
	jsr	p_turnoff
	bsr	SetupIce

	move	ExtraChars,d1
	move.l	#RefsMap+8,a0
	move	(a0)+,d0
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMAPro	;ref cam chars

	bsr	ClrHor
	clr	Vpos
	clr	Hpos

	bsr	ResetBench
	move.l	#tmstruct,a2
	bsr	setpersonel
	bsr	forcepldata
	add	#tmsize,a2
	bsr	setpersonel
	bsr	forcepldata
	bsr	resetplstuff

	moveq	#11,d0
	move.l	#.postab,a0
	move	#SortCords,a1
.ploop	move	Position(a1),d1
	btst	#pfgoal,pflags(a1)
	bne	.pl0
	add	#6,d1
.pl0	asl	#2,d1
	move	(a0,d1),Xpos(a1)
	move	2(a0,d1),Ypos(a1)
	clr	Xvel(a1)
	clr	Yvel(a1)
	add	#SCstruct,a1
	dbf	d0,.ploop
	bsr	SprSort

	move	#24,palcount
	move	Vcount,OldVcount
	move	#180,-(a7)
.0	move	Vcount,d7
	sub	OldVcount,d7	;number of frames since last loop
	beq	.0
	move	Vcount,OldVcount
	bsr	DoGameFrame
	btst	#gmclock,gmode
	beq	.1
	sub	#1,(a7)
	bmi	.endhl
.1	bsr	orjoy
	btst	#cbut,d1
	bne	.eh
	btst	#sbut,d1
	beq	.0
.eh	move	tmstruct+tmscore,d0
	cmp	tmstruct+tmsize+tmscore,d0
	bne	.endhl
	move	hvcount,d0
	and	#1,d0
	add	d0,tmstruct+tmscore
	eor	#1,d0
	add	d0,tmstruct+tmsize+tmscore
.endhl	add	#2,a7
	move.l	(a7)+,a0
	movem.l	d1/a0,-(a7)
	jsr	KillCrowd
	jsr	p_turnoff
	movem.l	(a7)+,d1/a0
	move	tmstruct+tmscore,gss1(a0)
	move	tmstruct+tmsize+tmscore,gss2(a0)
	btst	#sbut,d1
	bne	.nhl1
	bsr	forceblack
	bsr	.lo
	bsr	SetTeamColors
	bsr	SetHor
	bsr	SetVideo
	bsr	DisplayStats
	move	#24,palcount

	movem.l	(a7),d0-d7/a0-a6
	move	#4,gsper(a0)
	move	gss1(a0),d0
	cmp	gss2(a0),d0
	beq	StartHL2
	move	#5,gsper(a0)
	move	d1,d3
	bsr	NewTicker3
	move	#180,d0
	bsr	waitxsr
	btst	#sbut,d1
	beq	.exit
.exit2	bset	#sf3sbut,sflags3
.exit	movem.l	(a7)+,d0-d7/a0-a6
	rts

.nhl1	bsr	.lo
	bsr	.ranres
	bra	.exit2

.nhl0	bsr	.ranres
	bra	.exit

.ranres	;random resolve of game (if tied = random score)
	move	gss1(a0),d0
	cmp	gss2(a0),d0
	bne	.rr0
	move	hvcount,d0
	and	#1,d0
	add	d0,gss1(a0)
	eor	#1,d0
	add	d0,gss2(a0)
.rr0	move	#5,gsper(a0)
	rts

.sv	move	#((gstruct-gmode)/2)-1,d0
	move	#gmode,a1
	move.l	#ReplayStart,a2
.sv1	move	(a1)+,(a2)+
	dbf	d0,.sv1
	rts

.lo	move	#((gstruct-gmode)/2)-1,d0
	move	#gmode,a2
	move.l	#ReplayStart,a1
.lo1	move	(a1)+,(a2)+
	dbf	d0,.lo1
	rts

.postab
	dc.w	0,-240
	dc.w	-70,-140
	dc.w	20,-110
	dc.w	-100,-60
	dc.w	25,-40
	dc.w	70,-80

	dc.w	0,240
	dc.w	34,90
	dc.w	-55,80
	dc.w	100,40
	dc.w	-10,10
	dc.w	-50,0