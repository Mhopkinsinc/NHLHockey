
	include	Main.Asm		;EA provided code for startup and EA logo
	include	TeamData.Asm
	include	Frames.Asm		;graphics data table for Sprites.anim
	include	Ram.Asm			;ram allocation and some equates	

Begin		
	move	#$2700,SR	
	move.l	#Stack,sp	
	move.l	#varstart,a0	;clear out ram
.0	clr.l	(a0)+
	cmp.l	#varend2,a0
	blt	.0	

	jsr	ResetPassWord	
	jsr	DefaultMenus		;set initial menu choices
	jsr	orjoy				;clear any previous button presses
	jsr	p_initialZ80		;sound stuff
	jsr	p_turnoff			;sound stuff
	jsr	p_music_vblank		;sound stuff
	jsr	KillCrowd	
	jmp	Opening				;goto title screen and options etc.
;----------------------------------------------------

StartGame
	clr.b	gmode
	cmp	#1,OptPen
	bne	.0
	bset	#gmoffs,gmode	;offsides pen. is active
.0
	jsr	setteams
	clr	gsp
	bsr	restoreteams
	bsr	InitScores
	bsr	UpdateScores
	bra	StartPer

restoreteams
	move	#tmstruct,a2	;team 1
	bsr	.r
	add	#tmsize,a2	;team 2
.r	move	#6,tmap(a2)	;no players in pen. box
	moveq	#(MaxRos-1)*2,d0
.0	move	#-2,tmpdst(a2,d0)	;all players on bench
	subq	#2,d0
	bpl	.0
	rts

reenergizeteam	;set all players to max energy on team a2
	moveq	#(MaxRos-1)*2,d0
.0	move	#$1000,tmpde(a2,d0)
	subq	#2,d0
	bpl	.0
	rts

ResetClock	;set period length and stop clock
	move	OptPerlen,d0
	asl	#1,d0
	move.l	#.timetab,a0
	move	0(a0,d0),gameclock
	bset	#gmclock,gmode
	rts
.timetab	dc.w	5*60,10*60,20*60,30

StartPer
	move.l	#Stack,a7
	move.l	#tmstruct,a2
	bsr	reenergizeteam
	add	#tmsize,a2
	bsr	reenergizeteam

	jsr	p_turnoff
	jsr	setupice

	bsr	ResetClock
	st	c1playernum
	st	c2playernum
	move.l	#puckx,a3
	clr	fox
	clr	foy
	move.l	#pfaceoff,d0
	bsr	assreplace	;face off starts period

	move.w	Vcount,OldVcount
	bset	#sf2drec,sflags	;don't record
	bclr	#sfwrap,sflags	;reset replay stuff
	move	#-1,lastsfx
	move.l	#replaystart,recbpr
	bra	GameLoop

Gameloop	;main loop for game
.0	move	Vcount,d7
	sub	OldVcount,d7	;number of frames since last loop
	beq	.0
	move	Vcount,OldVcount
	bsr	DoGameFrame
	bsr	demoread	;check if demo mode
	btst	#sfpz,sflags
	beq	Gameloop
	bsr	PauseMode
	bra	Gameloop

DoGameFrame
	bsr	periodicevents
	bsr	updateplayers
	bsr	checkwindow
	bsr	updatereplay	
	bra	setvideo

periodicevents	;called every time thru game loop with d7 = elapsed frames
	bsr	PenaltyManager
	bsr	updatecrowdf
	jsr	updatesound
	bsr	clockcont
	btst	#sfhor,sflags
	bne	rtss	;exit if in horizontal mode
	sub.b	d7,lldisp	;count down for screen updates
	bpl	rtss
	add.b	#jps,lldisp	;only update once per second
	bchg	#0,lldisp+1
	bsr	ChkGoalies
	bsr	updatepwrplay
	tst	OptLine
	bne	rtss	;exit if line changes are off
	move	#tmstruct,a2	;draw power bars and flash if line change in progress
	lea	tmsize(a2),a3
	btst	#gmdir,gmode
	bne	.noflip
	exg	a2,a3
.noflip
	bsr	printz
	string	-$41,18,1
	bsr	.bl

	exg	a2,a3
	bsr	printz
	string	-$41,18,26
.bl
	moveq	#5,d0	;check for players leaving ice
	move.l	tmsort(a2),a0
.bl1	tst	position(a0)
	bmi	.nbl
	tst.b	newpnum(a0)
.nbl	
	add	#SCstruct,a0
	dbpl	d0,.bl1
	bmi	.notinprog
	btst	#0,lldisp+1
	beq	.notinprog
	bsr	printz	;blank out power bar area for flashing
	String	'@@@@'	
	sub	#11,printx
	bsr	printz
	String	'@@@@'
	rts
.notinprog
	moveq	#(MaxRos-1)*2,d0
.b0	cmp	#-1,tmpdst(a2,d0)
	beq	.next
	add	#9,tmpde(a2,d0)
	cmp	#$1000,tmpde(a2,d0)
	blt	.next
	move	#$1000,tmpde(a2,d0)
.next	
	subQ	#2,d0
	bpl	.b0
	bsr	AvgCline
	clr	d1
	cmp	#tmstruct,a2
	beq	.1
	moveq	#9,d1
.1	bra	dodbar

updatecrowdf	;this is called every game loop with d7 = elapsed frames
	;this will update the current frame of crowd animation
	sub	d7,crowdlevel
	bpl	.0
	clr	crowdlevel
.0	sub	d7,crowdcnt
	bpl	.cf
	move	crowdlevel,d0
	lsr	#1,d0
	cmp #127,d0
	bls	.1
	moveq	#127,d0
.1	and	#%01100000,d0
	addq.w	#2,crowdstep
	and	#%00011110,crowdstep
	add	crowdstep,d0
	move.l	#.cd0,a0
	move.b	0(a0,d0),crowdframe+1
	clr	d1
	move.b	1(a0,d0),d1
	move	HVcount,d2
	and	d1,d2
	add	d2,d1
	move	d1,crowdcnt
.cf	clr.b	crowdframe
	cmp	#280,crowdlevel
	bls	rtss
	move	HVcount,d0
	and	#127,d0
	cmpi.w	#19,d0	
	blt	rtss
	cmpi.w	#25,d0
	bgt	rtss
	move.b	d0,crowdframe
	rts

.cd0	;$fftt = frame/time for various levels of crowd excitement
	dc.w	$010c,$020c,$030c,$040c,$050c,$0a0c,$090c,$080c
	dc.w	$060c,$070c,$080c,$090c,$0a0c,$050c,$040c,$030c

	dc.w	$0107,$0207,$0307,$0407,$0507,$0b07,$0c07,$0d07
	dc.w	$0607,$0707,$0807,$0907,$0a07,$0b07,$0c07,$0d07

	dc.w	$0e07,$0f07,$1007,$1107,$1207,$0b07,$0c07,$0d07
	dc.w	$1207,$1107,$1007,$0f07,$0e07,$0d07,$0c07,$0b07

	dc.w	$0e03,$0f03,$1003,$1103,$1203,$0b03,$0c03,$0d03
	dc.w	$1203,$1103,$1003,$0f03,$0e03,$0d03,$0c03,$0b03

clockcont	;monitor period clock and initiate various clock activated events
	btst	#gmclock,gmode
	bne	rtss
	tst	gameclock
	bne	rtss

	move	#SFXhorn,-(a7)
	bsr	sfx
	bsr	freezewindow
	movea	#SortCords,a3
	cmp	#2,gsp
	blt	.eop
	move.l	#ascore,d0
	cmp	#3,gamelevel
	bne	.t3
	cmp	#7,bosgames
	beq	.sc

	moveq	#gssize,d3
	mulu	gamenum,d3
	move	#gstruct,a0
	add	d3,a0
	clr	d3
	btst	#gsftf,gsflags(a0)
	beq	.nf
	eor	#gspobwins-gspotwins,d3
.nf	move	tmstruct+tmscore,d1
	sub	tmstruct+tmscore+tmsize,d1
	bpl	.ns1
	eor	#gspobwins-gspotwins,d3
.ns1	cmp	#3,gspotwins(a0,d3)
	bne	.t3

.sc	move.l	#astanley,d0
	moveq	#11,d2
.t0	bclr	#pfjoycon,pflags(a3)
	add	#SCstruct,a3
	dbf	d2,.t0
	move	#SortCords,a3
.t3	moveq	#5,d2
	move	tmstruct+tmscore,d1
	sub	tmstruct+tmsize+tmscore,d1
	beq	.eop
	bpl	.t2
	add	#6*SCstruct,a3
.t2	tst	position(a3)
	beq	.n2
	bsr	assinsert
	move.l	#ascore,d0
.n2	add	#SCstruct,a3
	dbf	d2,.t2
	add	#1000,crowdlevel
	move	#PenEOG,d0
	bra	addpenalty2

.eop	move	#PenEOP,d0
	bra	addpenalty2

updatereplay	;called every frame to save replay events, d7 = elapsed frames
	btst	#sf2drec,sflags2
	bne	rtss	;exit if replay off
updatereplay2
	move.l	recbpr,a0
	move.b	puckz+1,64(a0)
	move.b	puckz+1+SCstruct,65(a0)

	move	Hpos,66(a0)
	move	Vpos,68(a0)
	move.b	d7,70(a0)
	btst	#gmclock,gmode
	bne	.0
	neg.b	70(a0)
.0
	move.b	lastsfx+1,71(a0)	;sound effect cue
	bset	#7,lastsfx+1
	move.l	padcont,72(a0)
	move	padcont+4,76(a0)
	move	crowdframe,78(a0)
	move.b	PBnum,80(a0)
;	move.b	???,81(a0)	;extra bytes
	move	glovecords,82(a0)

	add.l	#replaysize,recbpr
	cmp.l	#replayend,recbpr
	bne	rtss
	bset	#sfwrap,sflags
	move.l	#replaystart,recbpr
	rts

demoread	;monitor joystick if in demo mode
	tst	cont1team
	bne	rtss	;not demo
	tst	cont2team
	bne	rtss	;not demo
	bsr	readjoy1
	btst	#sbut,d1
	bne	.0
	bsr	readjoy2
	btst	#sbut,d1
	beq	rtss
.0	jmp	Opening


startpause1	;pause intiated by cont 1
	bclr	#sfpj,sflags
	bra	startpause
startpause2	;pause intiated by cont 2
	bset	#sfpj,sflags
startpause
	bset	#sfpz,sflags
	rts

Pausemode	;game is in pause mode now
	jsr	p_turnoff	;shut off sound
	move	sflags,-(a7)
	bsr	forceblack	;fade screen to black

.pall	move.l	#Vdata,a0
	move	#$9100,4(a0)	;playfield 3 width
	move	#$921c,4(a0)	;playfield 3 height
	bsr	SetHor
	bsr	SetVideo
	jsr	KillCrowd

.top	clr	psitem	;menu item on pause select screen

	bsr	printz	;erase playfield 3
	String	-$03,0,0
	moveq	#32,d0
	moveq	#28,d1
	moveq	#1,d2
	bsr	eraser

	bsr	printbigz
	String	-$43,11,2,'PAUSE',-$43,5,12
	moveq	#22,d0
	moveq	#7,d1
	bsr	framer
	move	#24,palcount

.gj	bsr	.Pmenu
	bsr	.rjoy
	btst	#sbut,d1
	bne	PauseExit
	btst	#dbut,d1
	beq	.1
	addq.w	#1,psitem	;next lower menu item
	cmpi.w	#.maxmenu,psitem.l
	bne	.gj
	sub	#1,psitem
	bra	.gj
.1	btst	#ubut,d1
	beq	.2
	sub	#1,psitem	;next higher menu item
	bpl	.gj
	clr	psitem
	bra	.gj
.2	move	psitem,d0
	asl	#2,d0
	move.l	#.jump,a0
	move.l	0(a0,d0),a0
	jmp	(a0)	;goto routine for current menu item

.rm	btst	#cbut,d1	;replay mode hilited
	beq	.gj
	bsr	ReplayMode
	bra	.top

.sr	btst	#cbut,d1	;stats report hilited
	beq	.gj
	move	#$400,d0
	move	VmMap3,d1
	moveq	#1,d2
	bsr	doFill
	bsr	StatsReport
	bra	.pall

.go	bsr	.seta2	;goalie change hilited
	moveq	#1,d2
	btst	#cbut,d1
	bne	.go0
	btst	#rbut,d1
	bne	.go0
	neg	d2
	btst	#lbut,d1
	beq	.gj

.go0	add	d2,tmgoalie(a2)
	bpl	.go1
	move	#2,tmgoalie(a2)
.go1	cmp	#3,tmgoalie(a2)
	bne	.go2
	clr	tmgoalie(a2)
.go2	jsr	Setpersonel
	bra	.gj
.exit
	jmp GameOver	

.maxmenu	equ	5	;number of menu items
.jump
	dc.l	PauseExit
	dc.l	.rm
	dc.l	.sr
	dc.l	.go
	dc.l	.exit

.rjoy	move	vcount,d1	;wait for vblank and read controller
.rj0	cmp	vcount,d1
	beq	.rj0
	bsr	GetPzJoy
	bsr	NoDiag	;disallow diagonal presses
	tst.b	d1
	beq	.rjoy
	rts

.Pmenu	;print menu text including goalie number
	bsr	printz
	String	-$43,6,13
	clr	d0
	move.l	#.mlist,a1
	move	printx,-(a7)
.pm0	move	(a7),printx
	move	#$a000,printa
	cmp	psitem,d0
	bne	.pm1
	move	#$8000,printa
.pm1	bsr	print
	bsr	.gnum
	addq.w	#1,printy
	addq.w	#1,d0
	cmp	#.maxmenu,d0
	bne	.pm0
	addq.w	#2,a7
	rts

.gnum	cmp	#3,d0	;print goalie number or none /d0 = menu item
	bne	rtss
	move.l	a1,-(a7)
	sub	#6,printx
	bsr	.seta2
	cmp	#2,tmgoalie(a2)
	beq	.gnum1
	move.l	tmdata(a2),a1
	add	playerdata(a1),a1
	tst	tmgoalie(a2)
	beq	.gnum0
	addq.w	#8,a1
.gnum0	move.b	(a1),d1
	move	#mesarea,a1
	move	#4,(a1)
	move	d1,-(a7)
	lsr	#4,d1
	and	#$f,d1
	add	#'0',d1
	move.b	d1,2(a1)
	move	(a7)+,d1
	and	#$f,d1
	add	#'0',d1
	move.b	d1,3(a1)
	bsr	print
	bra	.ex
.gnum1	sub	#1,printx
	bsr	printz
	String	'Bench'
.ex	move.l	(a7)+,a1
	rts

.seta2	;set a2 to tmstruct of pause joystick
	move	#tmstruct,a2
	btst	#sfpj,sflags
	beq	.seta20
	cmp	#1,cont2team
	bra	.seta21
.seta20	cmp	#1,cont1team
.seta21	beq	rtss
	add	#tmsize,a2
	rts

.mlist
	String	'    Resume Game     '
	String	'   Instant Replay   '
	String	'    Stats Report    '
	String	'    Goalie - #00    '
	String	'    Exit Game       '

PauseExit	;restore graphics and return from pause mode
	bsr	forceblack
	move	(a7)+,sflags
	btst	#sfhor,sflags
	bne	.hor
	bsr	ClrHor
.hor
	move.l	#Vdata,a0
	move	#$9100,4(a0)
	move	#$9200,4(a0)

	bset	#dfclock,disflags
	bclr	#sfpz,sflags
	bsr	printscores1
	bsr	SetVideo
	move	#24,palcount

.wait	tst	palcount
	bpl	.wait
	move	vcount,oldvcount
	rts	

ReplayMode	;this is instant replay play-back control and display code
	bsr	forceblack
	move	disflags,-(a7)

	bset	#sf2replay,sflags2	;flag that replay is on
	bsr	ClrHor	;goto vertical icerink
	move	#$400,d0
	move	VmMap3,d1
	moveq	#1,d2
	bsr	doFill	;clear map 3

	bsr	printz
	String	-$43,2,2
	moveq	#32,d0
	moveq	#85,d1
	moveq	#8,d2
	moveq	#4,d3
	move	rinkvrcset,d4
	move	#%0000,d5
	move.l	#IceRinkMap,a1
	add.l	4(a1),a1
	movea.l	#null,a2
	bsr	DoBitMap	;display replay icon

	bclr	#sfscrl,sflags	;manual scroll is off
	move	Vpos,-(a7)
	move	Hpos,-(a7)
	move.l	recbpr,a4	;record buffer pointer (current frame)
	btst	#sf2drec,sflags2
	beq	.p0
	bsr	updatereplay2	;if record is off then record current frame so it can be restored
	bsr	suba4
.p0
.rwd	bsr	suba4	;rewind to first frame
	tst	d7
	bne	.rwd
	jsr	SprSort
	bsr	setvideo
	bclr	#sf3rmplay,sflags3	;play mode is off
	move	#24,palcount	;fade in colors now/graphics are ready
	moveq	#1,d7
.top	move	vcount,d0
	sub	oldvcount,d0
	cmp	d0,d7
	bhi	.top
	move	vcount,oldvcount
	moveq	#1,d7
	bsr	getpzjoy

	btst	#3,d0
	bne	.nomans	;no d-pad input
	and	#7,d0
	bset	#sfscrl,sflags	;manual scrolling is on
	asl	#2,d0
	move.l	#.stab,a0
	move	0(a0,d0),d1
	add	Hpos,d1
	cmp	#64,d1
	bgt	.nox
	cmp	#-64,d1
	blt	.nox
	move	d1,Hpos
.nox
	move	2(a0,d0),d1
	add	Vpos,d1
	cmp	#256,d1
	bgt	.noy
	cmp	#-201,d1
	blt	.noy
	move	d1,Vpos
.noy
	bsr	setvideo
	bra	.top
.stab	dc.w	0,1,1,1,1,0,1,-1,0,-1,-1,-1,-1,0,-1,1

.nomans	btst	#cbut,d1
	beq	.00
	bchg	#sf3rmplay,sflags3	;switch play mode

.00	btst	#abut,d3
	beq	.0
	bsr	suba4	;fast rewind
	bsr	suba4
	bsr	suba4
	bsr	suba4
	jsr	SprSort
	bsr	setvideo
	moveq	#1,d7
	bclr	#sf3rmplay,sflags3	;turn off play mode
.0
	btst	#bbut,d3
	beq	.1
	btst	#abut,d3
	beq	.f1
	bclr	#sfscrl,sflags	;a+b but = manual scroll off (hidden feature)
	bra	.top
.f1
	bsr	adda4	;advance 1 frame
	jsr	SprSort
	bsr	setvideo
	asl	#1,d7	;double delay time between frames = 1/2 speed slow motion
	bclr	#sf3rmplay,sflags3	;turn off play mode
.1
	btst	#sf3rmplay,sflags3
	beq	.noplay
	st	lastsfx	;play mode is on = advance one frame at original speed
	bsr	adda4
	move	lastsfx,-(a7)	;play sound effects
	bsr	sfx
	jsr	SprSort
	bsr	setvideo
.noplay
	btst	#sbut,d1
	beq	.top	;no exit yet

	bsr	forceblack
.ff	bsr	adda4	;go to end of record buffer
	tst	d7
	bne	.ff

	btst	#sf2drec,sflags2
	beq	.nodr
	move.l	a4,-(a7)
	bsr	adda42	;advance 1 extra frame if record mode was disabled
	move.l	(a7)+,recbpr
.nodr
	move	(a7)+,Hpos
	move	(a7)+,Vpos

	bclr	#sf2replay,sflags2
	move	(a7)+,disflags
	bsr	SetHor
	bsr	SetVideo	;restore old video
	move	#24,palcount
	rts	;exit replay mode

getpzjoy	btst	#sfpj,sflags
	bne	readjoy2
	bra	readjoy1

suba4	;a4 = address in replay buffer of current frame
	;back up 1 frame and set video parameters for display
	;d7 will be set to delay between frames or zero if at the end of replay
	clr	d7
	cmp.l	#replaystart,a4
	bne	.1
	btst	#sfwrap,sflags
	beq	rtss
	move.l	#replayend,a4
.1
	sub	#replaysize,a4
	cmp.l	recbpr,a4
	bne	.0
	add	#replaysize,a4
	rts
.0
	bsr	SetRcords
	move.b	70(a4),d7
	bpl	nonshift
	neg.b	d7
	bra	nonshift

adda4	;a4 = address in replay buffer of current frame
	;step forward 1 frame and set video parameters for display
	;d7 will be set to delay between frames or zero if at the end of replay
	clr	d7
	btst	#sf2drec,sflags2
	beq	adda42
	move.l	a4,-(a7)
	bsr	adda43
	cmp.l	recbpr,a4
	move.l	(a7)+,a4
	beq	rtss
adda42
	cmp.l	recbpr,a4
	beq	rtss
	bsr	SetRCords
	move.b	70(a4),d7
	bpl	.1
	neg.b	d7
.1	bsr	nonshift

adda43	add	#replaysize,a4
	cmp.l	#replayend,a4
	bne	rtss
	move.l	#replaystart,a4
	rts

SetRCords	;a4 = current replay frame address to convert into normal cordinates
	movem.l	d0-d2,-(a7)
	moveq	#15,d1	;16 objects to convert (12 players/puck/shadow/2 goal nets)
	movea.l	#sortcords,a3
.top	move	SCnum(a3),d0
	asl	#2,d0
	bsr	.sr
	add	#SCstruct,a3
	dbf	d1,.top
	movem.l	(a7)+,d0-d2
	rts

.sr	move	2(a4,d0),d2
	and	#$03ff,d2
	btst	#9,d2
	beq	.p
	or	#$fc00,d2
.p	move	d2,Xpos(a3)
	move.l	0(a4,d0),d2
	asr.l	#4,d2
	asr	#6,d2
	btst	#9,d2
	beq	.p1
	or	#$fc00,d2
.p1	move	d2,Ypos(a3)
	move	0(a4,d0),d2
	asr	#4,d2
	and	#$03ff,d2
	move	d2,frame(a3)
	move	0(a4,d0),d2
	asr	#3,d2
	and	#$1800,d2
	and	#$e7ff,attribute(a3)
	or	d2,attribute(a3)
	rts

nonshift	;set other replay variables needed
	move.b	64(a4),d0
	ext	d0
	move	d0,puckz	;puck z cord
	move.b	65(a4),d0
	ext	d0
	move	d0,puckz+SCstruct	;puck shadow zcord

	move.b	71(a4),d0
	ext	d0
	move	d0,lastsfx

	clr	d0
	move	#padcont,a0
.lp	move	72(a4,d0),0(a0,d0)
	bset	#6,0(a0,d0)
	addq.w	#2,d0
	cmp	#6,d0
	bne	.lp

	move	78(a4),crowdframe
	move.b	80(a4),PBnum
;	move.b	81(a4),???
	move	82(a4),glovecords

	btst	#sfscrl,sflags
	bne	rtss
	move	66(a4),Hpos
	move	68(a4),Vpos
	rts

updateplayers
	;this routine calls all collision/animation/assignment code for all the players
	;d7 = elapse frames since last call
	btst	#sfhor,sflags
	bne	.u0
	bset	#7,padcont
.u0
	move.l	#SortCords,a3
.top
	move.l	Xpos(a3),OldXpos(a3)
	move.l	Ypos(a3),OldYpos(a3)
	move.l	Zpos(a3),OldZpos(a3)
	tst	position(a3)
	bmi	.nf1	;player is not on ice

	bsr	updateanim
	sub	d7,nopuck(a3)	;puck control
	bpl	.np
	clr	nopuck(a3)
.np
	btst	#pf3oside,pflags3(a3)	;look for offsides
	beq	.notoside
	move	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
	bne	.os1
	neg	d0
.os1	sub	#10,d0
	cmp	blueline,d0
	bgt	.notoside
	bclr	#pf3oside,pflags3(a3)
.notoside
;----------------------------------	now update velocity
	move	d7,d4
	asl	#4,d4
	tst	Zpos(a3)
	bne	.y2	;no deceleration
	moveq	#6,d2
	btst	#pfdoff,pflags(a3)
	beq	.off
	moveq	#9,d2
.off
	move	Xvel(a3),d0
	beq	.x2
	asr	d2,d0
	bne	.x1
	moveq	#1,d0
.x1	sub	d0,Xvel(a3)
.x2
	move	Yvel(a3),d0
	beq	.y2
	asr	d2,d0
	bne	.y1
	moveq	#1,d0
.y1	sub	d0,Yvel(a3)
.y2
	move	Xvel(a3),d0
	beq	.x3
	muls	d4,d0
	add.l	d0,Xpos(a3)
.x3
	move	Yvel(a3),d0
	beq	.y3
	muls	d4,d0
	add.l	d0,Ypos(a3)
.y3
	tst	Zpos(a3)
	bmi	.done
	bne	.z1
	tst	Zvel(a3)
	beq	.done
.z1
	asl	#1,d4	;*32	gravity
	sub	d4,Zvel(a3)
	asl	#1,d4	;*64
	sub	d4,Zvel(a3)
	lsr	#2,d4
	move	Zvel(a3),d0
	muls	d4,d0
	add.l	d0,Zpos(a3)
	bpl	.done
	clr.l	Zpos(a3)
	neg	Zvel(a3)
	;lsr	#1,Zvel(a3)
	dc.w    $E2EB       ; LSR opcode
    dc.w    $002C       ; Zvel offset
	cmp	#$200,Zvel(a3)
	blt	.done
	move	#SFXpuckice,-(a7)
	bsr	sfx
.done
	move	SCnum(a3),d6
	cmp	puckc,d6
	bne	.tp	;not puck carrier
	btst	#pf2fight,pflags2(a3)
	bne	.tp
	btst	#sfhor,sflags
	bne	.tp
	moveq	#-2,d4	;pad index for puck carrier
	bsr	Setpads
.tp
	cmp	c1playernum,d6
	bne	.t0
	bsr	readjoy1
	clr	d4	;pad index for cont 1 player
	bsr	doinput
	bra	.t1
.t0
	cmp	c2playernum,d6
	bne	.t1
	bsr	readjoy2
	moveq	#2,d4	;pad index for cont 2 player
	bsr	doinput
.t1
	btst	#pfalock,pflags(a3)
	bne	.noass	;no assignment if animation lock is on

	move	assnum(a3),d0
	clr	d1
	move.b	asslist(a3,d0),d1
	asl	#2,d1
	move.l	#asstab,a0
	move.l	0(a0,d1),a0
	jsr	(a0)	;call assignment for this player
.noass
	move	Xpos(a3),d2
	move	Ypos(a3),d3
	cmp	OldXpos(a3),d2
	bne	.cc
	cmp	OldYpos(a3),d3
	beq	.nf
.cc	bsr	checkcoll	;check for coll if moved by at least 1 pix
.nf
	move	d7,d0
	asl	#1,d0
	sub	d0,impact(a3)	;reduce impact at constant rate
	bpl	.nf1
	clr	impact(a3)
.nf1
	move	impact(a3),limpact(a3)
	bsr	record

	add	#SCstruct,a3
	cmp	#Sortobjs-1,SCnum-SCstruct(a3)
	blt	.top	;loop for all Sort objects
	rts

record	;record information about struct a3 into record buffer
	move.l	recbpr,a0
	move	SCnum(a3),d0
	asl	#2,d0

	clr.l	0(a0,d0)
	move	Xpos(a3),d1
	and	#$03ff,d1
	move	d1,2(a0,d0)
	clr.l	d1
	move	Ypos(a3),d1
	asl	#6,d1
	asl.l	#4,d1
	or.l	d1,0(a0,d0)
	move	frame(a3),d1
	asl	#4,d1
	or	d1,0(a0,d0)
	move	attribute(a3),d1
	and	#$1800,d1
	asl	#3,d1
	or	d1,0(a0,d0)
	rts

updateanim	;frame switch control on struct a3
	tst	SPA(a3)
	bne	.ia
	bclr	#pfalock,pflags(a3)
	bclr	#pf2aip,pflags2(a3)
	rts
.ia
	move.l	#SPAlist,a0	;animation data tables (frames.asm)
	add	SPA(a3),a0
	move	16(a0),d1	;attributes for anim
	move	facedir(a3),d0
	btst	#sfhor,sflags
	beq	.nhor
	cmp	#12,SCnum(a3)
	bge	.nhor
	sub	#2,d0	;direction adj for horizontal rink
	and	#7,d0
.nhor
	btst	#3,attribute(a3)	;x flip flag
	beq	.nox
	neg	d0
	add	#8,d0
	andi #7,d0
.nox
	asl	#1,d0
	add	0(a0,d0),a0
	move	SPAnum(a3),d0
	move	0(a0,d0),d2	;new frame

	tst	SPAcnt(a3)
	bmi	.1
	sub	d7,SPAcnt(a3)
	bpl	.cframe
	add	#4,SPAnum(a3)
	add	#4,d0
	tst	-2(a0,d0)
	bpl	.1
	clr	d0
	clr	SPAnum(a3)
	bclr	#pfalock,pflags(a3)
	bclr	#pf2aip,pflags2(a3)
	btst	#0,d1
	bne	.1	;looper
	clr	SPA(a3)
.1
	move	2(a0,d0),d0
	bpl	.0
	neg	d0
.0	move	d0,SPAcnt(a3)

.cframe	sub.b	d7,glitch(a3)	;limit minimum time between frame switches
	bpl	rtss
	clr.b	glitch(a3)
	cmp	frame(a3),d2
	beq	rtss
	move	d2,frame(a3)
	move.b	#4,glitch(a3)	;/60 sec min frame switch time
	rts

	include	Logic.Asm
	include	middle.asm
	include	Penalty.Asm

collrad	=	8

checkcoll
	;d2 = new x cord
	;d3 = new y cord
	;a3 = struct of object

	clr	collflag
	btst	#sfhor,sflags
	beq	.nhor1
	exg	d2,d3
.nhor1
	clr	wallcos(a3)
	clr	wallsin(a3)
	btst	#pfnc,pflags(a3)
	bne	.ex

	movem.l	d0-d7,-(a7)
	move	Xpos(a3),d2
	move	Ypos(a3),d3	;check coll around hot spot with wall
	move	radiusx(a3),wcradiusx	;wall coll radius x
	move	radiusy(a3),wcradiusy	;wall coll radius y
	bsr	checkwallcoll
	move	wallcos(a3),d0
	or	wallsin(a3),d0
	bne	.xx	;coll did happen
	cmp	#11,SCnum(a3)
	bgt	.xx	;not a player
	movem.l	(a7),d0-d7
	move.l	a3,-(a7)
	bsr	GetHot
	move	Xpos(a3),d2
	move	Ypos(a3),d3
	add	d0,d2
	add	d1,d3	;check coll around end of stick with wall
	move	#1,wcradiusx
	move	#1,wcradiusy
	bsr	checkwallcoll
.xx
	movem.l	(a7)+,d0-d7

	bsr	checkplcoll	;check coll with other players

;now check order of sprites
.ex
	tst	collflag
	bne	.restoreold
	move	SCnum(a3),d0
	asl	#1,d0		;current object number
	move.l	#OOlistpos,a0
	move.l	#OOlist,a1
	move.l	#Ylist,a2
	move	0(a0,d0),d1	 ;current objects pos in OOlist
.2	cmp	#Sortobjs-1,d1
	beq	.cl2		;it is top sprite on screen
	clr	d4
	move.b	1(a1,d1),d4	;next higher object number
	cmp	0(a2,d4),d3	;y pos of next higher object
	ble	.cl2

	addq	#1,0(a0,d0)
	subq	#1,0(a0,d4)

	move.b	d4,0(a1,d1)
	move.b	d0,1(a1,d1)

	addq	#1,d1
	bra	.2

.cl2	move	0(a0,d0),d1	;current objects pos in OOlist
	beq	.ex2
.3	clr	d4
	move.b	-1(a1,d1),d4	;next lower object number
	cmp	0(a2,d4),d3	;y pos of next lower object
	bge	.ex2

	subq	#1,0(a0,d0)
	addq	#1,0(a0,d4)

	move.b	d4,0(a1,d1)
	move.b	d0,-1(a1,d1)

	subq	#1,d1
	bne	.3
.ex2
	move	d3,0(a2,d0)	;update Ylist
	rts
.restoreold
	move	OldXpos(a3),Xpos(a3)
	move	OldYpos(a3),Ypos(a3)
	rts

checkplcoll
	;d2/d3 = x/y cords
	;a3 = struct
	btst	#pf2npc,pflags2(a3)
	bne	.ex
	cmp	#11,SCnum(a3)
	bgt	.ex
;	cmp	#puckSCnum,SCnum(a3)
;	beq	.ex
	move	SCnum(a3),d0
	asl	#1,d0		;current object number
	move.l	#OOlistpos,a0
	move.l	#OOlist,a1
	move.l	#Ylist,a2
	move	0(a0,d0),d1	;current objects pos in OOlist
.0	cmp	#sortobjs-1,d1
	beq	.cl		;it is top sprite on screen
	clr	d4
	move.b	1(a1,d1),d4	;next higher object number
	move	0(a2,d4),d5	;y pos of next higher object
	sub	d3,d5
	cmp	#collrad*2,d5
	bgt	.cl		;no higher sprite coll
	bsr	checkcx
	addq	#1,d1
	bra	.0

.cl	move	0(a0,d0),d1
	beq	.ex
.1	clr	d4
	move.b	-1(a1,d1),d4	;next lower object number
	move	d3,d5
	sub	0(a2,d4),d5	;y pos of next lower object
	cmp	#collrad*2,d5
	bgt	.ex
	bsr	checkcx
	subq	#1,d1
	bne	.1
.ex	rts

checkcx	;a4 = obj. # * 2 for possible coll so check x range and distance for coll
	movem.l	d0-d7/a0-a3,-(a7)
	asl	#scsize-1,d4
	move.l	#SortCords,a2
	add	d4,a2

	btst	#pfnc,pflags(a2)
	bne	.exit		;object has no coll mode on
	btst	#pf2npc,pflags2(a2)
	bne	.exit
	cmp	#11,SCnum(a2)
	bgt	.exit	;not a player

	move	Xpos(a2),d0
	btst	#sfhor,sflags
	beq	.nhor
	move	Ypos(a2),d0
.nhor
	sub	d2,d0		;delta x
	cmp	#-collrad*2,d0
	blt	.exit
	cmp	#collrad*2,d0
	bgt	.exit
	muls	d5,d5	; delta y^2
	muls	d0,d0	; delta x^2
	add.l	d5,d0
	cmp.l	#(collrad*2)*(collrad*2),d0
	bgt	.exit	;outside of radius

	move	#0,evalue
	move.b	pflags(a3),d6
	move.b	pflags(a2),d0
	eor.b	d0,d6

;now do momentum transfer from object a3 to object a2

	move	Xvel(a3),d0
	sub	Xvel(a2),d0	;Vx
	move	Yvel(a3),d1
	sub	Yvel(a2),d1	;Vy

	move	Xpos(a3),d2
	sub	Xpos(a2),d2	;
	neg	d2	;Dx
	move	Ypos(a3),d3
	sub	Ypos(a2),d3	;
	neg	d3	;Dy

	movem	d0-d1,-(a7)
	muls	d3,d1	;Vy*Dy
	muls	d2,d0	;Vx*Dx
	add.l	d0,d1	;(Vy*Dy)+(Vx*Dx)
	bmi	.exit4	;no col if v1n < 0
	asr.l	#4,d1
;	divs	#collrad*2,d1	;((Vy*Dy)+(Vx*Dx))/hyp

	btst	#pfteam,d6
	beq	.not		;players are on same team
	move	d1,d4
	lsr	#8,d4
	cmp	#5,d4
	bgt	.g40
	moveq	#5,d4		;minimum impact value
.g40
	add	d4,impact(a3)
	add	d4,impact(a2)
	btst	#pf2fight,pflags2(a2)
	bne	.if
	move	SCnum(a3),impactp(a2)
.if
	btst	#pf2fight,pflags2(a3)
	bne	.if2
	move	SCnum(a2),impactp(a3)
.if2
	cmp	#20,d4
	blt	.n1
	move	puckc,d0
	cmp	SCnum(a3),d0
	beq	.nc
	cmp	SCnum(a2),d0
	bne	.n1
.nc	bsr	newcheck

.n1
	bsr	checkint
	bsr	checkcheck
	bsr	checkfight
.not
	move	d1,d4		;V1n

	movem	(a7)+,d0-d1
	tst	collflag
	bmi	.exit

	muls	d2,d1		;Vy*Dx
	muls	d3,d0		;Vx*Dy
	sub.l	d1,d0		;(Vx*Dy)-(Vy*Dx)
	asr.l	#4,d0
;	divs	#collrad*2,d0	;((Vx*Dy)-(Vy*Dx))/hyp
	move	d0,d5		;V1t

	clr	d0
	move.b	weight(a3),d0	;m1
	add	#140,d0
	clr	d1
	move.b	weight(a2),d1	;m2
	add	#140,d1
	move	evalue,d7		;e*16 value (0-16)
	mulu	d1,d7
	lsr	#4,d7		;m2*e
	add	d0,d1		;m1+m2
	sub	d7,d0		;(m1-m2*e)
	muls	d4,d0		;V1n*(m1-m2*e)
	divs	d1,d0		;V1n'=(V1n*(m1-m2*e))/(m1+m2)

	move	evalue,d1
	muls	d4,d1		;V1n*e
	asr	#4,d1
	add	d0,d1		;V2n'=V1n'+V1n*e

	movem	d2-d3,-(a7)		;save Dx,Dy
	muls	d5,d3		;V1t'*Dy
	muls	d0,d2		;V1n'*Dx
	add.l	d2,d3		;V1t'*Dy+V1n'*Dx
	asr.l	#4,d3
;	divs	#collrad*2,d3
	add	Xvel(a2),d3
	move	d3,Xvel(a3)

	movem	(a7),d2-d3		;restore Dx,Dy
	muls	d5,d2		;V1t'*Dx
	muls	d0,d3		;V1n'*Dy
	sub.l	d2,d3		;V1n'*Dy-V1t'*Dx
	asr.l	#4,d3
;	divs	#collrad*2,d3
	add	Yvel(a2),d3
	move	d3,Yvel(a3)

	movem	(a7)+,d2-d3
	muls	d1,d2		;V2n'*Dx
	asr.l	#4,d2
;	divs	#collrad*2,d2	;(V2n'*Dx)/(hyp)
	add	d2,Xvel(a2)

	muls	d1,d3		;V2n'*Dy
	asr.l	#4,d3
;	divs	#collrad*2,d3	;(V2n'*Dy)/(hyp)
	add	d3,Yvel(a2)

	st	collflag

.exit	movem.l	(a7)+,d0-d7/a0-a3
	rts

.exit4
	addq	#4,a7
	bra	.exit

newcheck	;start a new check sound
	move.l	d0,-(a7)
	moveq	#4,d0
	bsr	randomd0
	addq	#1,d0
	add	ltack,d0
	cmp	#4,d0
	bls	.no5
	subq	#5,d0
.no5	move	d0,ltack
	cmp	#3,d0
	blt	.0
	sub	#3+SFXcheck-SFXcheck2,d0
.0	add	#SFXcheck,d0
	move	d0,-(a7)
	bsr	sfx		;tackle sound
	move.l	(a7)+,d0
	rts

checkint	;check for interference penalty
	;player a2 interferes with a3 or vice-versa
	;goalie is only player who cause an interference call
	move.l	d0,-(a7)
	bsr	.ci
	exg	a2,a3
	bsr	.ci
	exg	a2,a3
	move.l	(a7)+,d0
	rts
.ci	tst	position(a2)
	bne	rtss
	btst	#pfalock,pflags(a3)
	bne	rtss
	btst	#gmclock,gmode
	bne	rtss	;no fall downs during celebrate
	cmp	#10,impact(a2)
	ble	rtss
	exg	a2,a3
	bsr	FallDown
	exg	a2,a3
	cmp	#30,impact(a2)
	ble	rtss
	btst	#pf2pen,pflags2(a3)
	bne	rtss	;no double minor
	btst	#gmhl,gmode
	bne	rtss
	moveq	#PenInterference,d0
	bra	AddPenalty

checkcheck	;player is in contact look for various contact events
	movem.l	d0-d4/a0-a3,-(a7)
	bsr	.cc
	exg.l	a2,a3
	bsr	.cc
	movem.l	(a7)+,d0-d4/a0-a3
	rts

.cc	cmp	#SPAHold,SPA(a2)
	beq	holdcheck	;if in hold animation
	cmp	#SPAburst,SPA(a3)
	bne	rtss	;if not in cbut burst anim exit
	btst	#gmclock,gmode
	beq	.nofight
	move	#$100,impact(a3)	;increased fight chance after clock stops
	move	#$100,impact(a2)
.nofight
	move	Xpos(a2),d0
	sub	Xpos(a3),d0
	move	Ypos(a2),d1
	sub	Ypos(a3),d1
	bsr	vtoa
	sub	facedir(a3),d0
	and	#7,d0
	btst	#3,attribute(a3)	;xflip?
	beq	.0
	neg	d0
	add	#8,d0
	and	#7,d0
.0	asl	#1,d0
	move.l	#.list,a0
	move	0(a0,d0),d1
	bset	#pfalock,pflags(a3)
	bsr	SetSPA

	tst	position(a2)	;goalie doesn't fall
	beq	rtss
	cmp	#20,d4
	blt	rtss
	moveq	#60,d0
	sub.b	weight(a3),d0
	add.b	weight(a2),d0
	sub	impact(a2),d0
	beq	.down
	bmi	.down
	bsr	randomd0
	cmp.b	aggress(a3),d0
	ble	.down
	moveq	#63,d1
	btst	#pfjoycon,pflags(a3)
	beq	.nojoy1
	lsr	#2,d1
.nojoy1	move	HVcount,d0
	and	d0,d1
	bne	rtss
	btst	#gmhl,gmode
	bne	rtss
	move.b	HVcount,d0
	and	#2,d0
	add	#PenCharging,d0	;random penalty called
	bra	AddPenalty
.down
	moveq	#15,d1
	btst	#pfjoycon,pflags(a3)
	beq	.nojoy2
	lsr	#2,d1
.nojoy2
	move	HVcount,d0
	and	d0,d1
	bne	.dn2
	btst	#gmhl,gmode
	bne	.dn2
	move.b	HVcount,d0
	and	#%110,d0
	add	#PenTripping,d0
	bsr	addpenalty
.dn2	bra	FallDown

.list	dc.w	SPAshoulderchkl
	dc.w	SPAshoulderchkr
	dc.w	SPAhipchkr
	dc.w	SPAhipchkr
	dc.w	SPAhipchkr
	dc.w	SPAhipchkl
	dc.w	SPAhipchkl
	dc.w	SPAshoulderchkl

holdcheck	;player a2 is in hold animation looking to hold opponent a3
	btst	#pfalock,pflags(a3)
	bne	rtss
	tst	position(a3)
	beq	rtss	;no hold on goalies
	btst	#pf2fight,pflags2(a3)
	bne	rtss	;no hold on fighters
	move	Xvel(a3),d0
	add	Xvel(a2),d0
	asr	#1,d0
	move	d0,Xvel(a3)
	move	d0,Xvel(a2)
	move	yvel(a3),d0
	add	yvel(a2),d0
	asr	#1,d0
	move	d0,yvel(a3)
	move	d0,yvel(a2)
	bset	#pfalock,pflags(a3)
	move	#SPAFlail,d1
	bsr	SetSPA
	exg	a2,a3
	bset	#pfalock,pflags(a3)
	move	#SPAHold2,d1
	bsr	SetSPA
	moveq	#6,d0
	bsr	randomd0
	tst	d0
	bne	.ex
	move	#PenHolding,d0
	bsr	AddPenalty
.ex	exg	a2,a3
	st	collflag
	rts

FallDown	;player a2 falls down
	;player a3 is the hitting player
	cmp	#11,SCnum(a2)
	bgt	rtss	;not a player
	btst	#pf2fight,pflags2(a2)
	bne	rtss
	move	Xpos(a3),d0
	sub	Xpos(a2),d0
	move	Ypos(a3),d1
	sub	Ypos(a2),d1
	bsr	vtoa
	move	#120,nopuck(a2)
	move	#SPAfallfwd,d1
	sub	facedir(a2),d0
	add	#1,d0
	and	#7,d0
	cmp	#2,d0
	bhi	.2
	move	#SPAfallback,d1
.2	exg.l	a2,a3
	bset	#pfalock,pflags(a3)
	bsr	SetSPA
	exg.l	a2,a3

	add	#300,crowdlevel

	move	puckc,d0
	bmi	newcheck
	cmp	SCnum(a2),d0
	bne	newcheck
	st	puckc
	move	#SFXcrowdcheer,-(a7)
	btst	#pfteam,pflags(a2)
	bne	.3
	move	#SFXcrowdboo,(a7)
.3	bsr	SFX
	rts

checkfight	;look for start of fight between players a2 & a3
	btst	#pf2pen,pflags2(a3)
	bne	rtss
	btst	#pf2pen,pflags2(a2)
	bne	rtss

;	btst	#pfalock,pflags(a3)
;	bne	rtss
;	btst	#pfalock,pflags(a2)
;	bne	rtss

	movem.l	d0-d4/a0-a3,-(a7)

	move	position(a3),d0
	and	position(a2),d0
	beq	.ex	;no fights with goalies

	btst	#gmhl,gmode
	bne	.ex

	btst	#pf2fight,puckx+pflags2
	bne	.ex
	move	#puckx,a0
	move	assnum(a0),d0
	cmp.b	#pfaceoff,asslist(a0,d0)
	beq	.ex

	moveq	#40,d0
	sub.b	aggress(a3),d0
	sub.b	aggress(a2),d0
	asl	#7,d0
	bsr	randomd0
	add	#64,d0
	move	impact(a3),d1
	add	impact(a2),d1

;	asl	#3,d1	;for fight testing

	cmp	d1,d0
	bhi	.ex

	add	#1000,crowdlevel

	bclr	#sfspdir,sflags
	bclr	#sfssdir,sflags
	bset	#pf2fight,pflags2(a3)
	bset	#pf2fight,pflags2(a2)

	move	SCnum(a3),puckc

	move	Xpos(a3),d0
	add	Xpos(a2),d0
	asr	#1,d0
	cmp	#90,d0
	blt	.o1
	move	#90,d0
.o1	cmp	#-90,d0
	bgt	.o2
	move	#-90,d0
.o2	move	d0,xc1
	move	Ypos(a3),d1
	add	Ypos(a2),d1
	asr	#1,d1
	move	d1,yc1

	bset	#sfslock,sflags

	moveq	#2,d1
	move	Xpos(a3),d0
	cmp	Xpos(a2),d0
	blt	.1
	eor	#7,d1
.1	move	d1,facedir(a3)
	eor	#7,d1
	move	d1,facedir(a2)

	move.l	a3,-(a7)
	bsr	.sf
	exg	a2,a3
	bsr	.sf
	move.l	#SortCords,a3
	moveq	#afwatch,d0	;other player watch fight
	moveq	#11,d1
.0	btst	#pf2fight,pflags2(a3)
	bne	.next
	tst	position(a3)
	beq	.next
	btst	#pf2unav,pflags2(a3)
	bne	.next
	bsr	assinsert
.next	add	#SCstruct,a3
	dbf	d1,.0
	move.l	#puckx,a3
	bset	#pf2fight,pflags2(a3)
	moveq	#pnothing,d0
	bsr	assinsert

	st	collflag

	move.l	(a7)+,a3

.ex	movem.l	(a7)+,d0-d4/a0-a3
	rts

.sf
	bsr	SetInst
	move	SCnum(a2),impactp(a3)
	moveq	#PenFighting,d0
	bsr	AddPenalty2
	move	SCnum(a3),d0
	bsr	setd0player
	moveq	#afight,d0
	bsr	assinsert
	bclr	#3,attribute(a3)
	move	#-$400,d1
	cmp	#2,facedir(a3)
	beq	.sf2
	bset	#3,attribute(a3)
	neg	d1
.sf2	move	d1,Xvel(a3)
	bset	#pf2unav,pflags2(a3)
	bset	#pf2aip,pflags2(a3)
	bset	#pf2npc,pflags2(a3)
	bclr	#pfalock,pflags(a3)
	move	#SPAfight,d1
	bra	SetSPA

SetInst	;look to see if player a3 instigated this fight
	cmp	#SPAshoulderchkl,SPA(a3)
	beq	.0
	cmp	#SPAshoulderchkr,SPA(a3)
	bne	rtss
.0	move.l	a3,a4
	moveq	#5,d0
	move	#SortCords,a3
	btst	#pfteam,pflags(a4)
	beq	.1
	add	#6*SCstruct,a3
.1	cmp	a3,a4
	beq	.next
	tst	position(a3)
	ble	.next
	btst	#pf2pen,pflags2(a3)
	bne	.next
	btst	#pf2unav,pflags2(a3)
	bne	.next
	move	#PenInst,d0
	bsr	AddPenalty2
	move.l	a4,a3
	rts
.next	add	#SCstruct,a3
	dbf	d0,.1
	move.l	a4,a3
	rts

checkwallcoll
.ywall	=	210	;distance from blueline to end of rink in pixels
.radius	=	64	;radius of corners on ice rink

	move	sideline,d4
	sub	wcradiusx,d4
	move	blueline,d5
	add	#.ywall,d5
	sub	wcradiusy,d5

	movem	d2-d5,-(a7)
	neg	d4
	neg	d5
	add	#.radius,d4
	add	#.radius,d5
	cmp	d5,d3
	bgt	.ctc
	cmp	d4,d2
	blt	.circle
	neg	d4
	cmp	d4,d2
	bgt	.circle
	move	#SortCords+(13*SCstruct),a2
	bsr	checkgoal
	bra	.exit

.ctc	neg	d5
	cmp	d5,d3
	blt	.exit
	cmp	d4,d2
	blt	.circle
	neg	d4
	cmp	d4,d2
	bgt	.circle
	move	#SortCords+(12*SCstruct),a2
	bsr	checkgoal
	bra	.exit

.circle
	sub	d4,d2
	sub	d5,d3
	move	d3,d0	;cos0 = dy/r
	move	d2,d1	;sin0 =-dx/r
	neg	d1

	muls	d3,d3
	muls	d2,d2
	add.l	d2,d3	;dist from dot
	;cmp.l	#.radius^2,d3
	cmpi.l  #(.radius*.radius),d3   ; Calculate multiplication
	bls	.exit
	exg.l	d0,d3
	bsr	sroot
	exg.l	d0,d3
	ext.l	d0
	asl.l	#8,d0
	divs	d3,d0
	ext.l	d1
	asl.l	#8,d1
	divs	d3,d1
	bsr	wallcollb

.exit	movem	(a7)+,d2-d5

	move	wallcos(a3),d0
	or	wallsin(a3),d0
	bne	rtss
	move	#256,d0	;now check side walls
	clr	d1
  	cmp	d5,d3
	bge	wallcollb
	neg	d5
	neg	d0
	cmp	d5,d3
	ble	wallcollb

	exg	d0,d1
	cmp	d4,d2
	bge	wallcollb
	neg	d4
	neg	d1
	cmp	d4,d2
	ble	wallcollb
	rts

checkgoal	;look for coll with goal/net
.zside	=	13	;height of goal (for puck only)
	cmp	#.zside,Zpos(a3)
	bgt	rtss	;over goal
	cmp	#puckSCnum,SCnum(a3)
	bne	checkgoalp	;coll with player not puck
.xside	=	16	;width of goal/2
.yside	=	2	;depth of goal/2
	sub	Xpos(a2),d2
	move	#.xside,d4
	add	wcradiusx,d4
	cmp	d4,d2
	bgt	rtss
	neg	d4
	cmp	d4,d2
	blt	rtss
	sub	Ypos(a2),d3
	move	#.yside,d5
	add	wcradiusy,d5
	cmp	d5,d3
	bgt	rtss
	neg	d5
	cmp	d5,d3
	blt	rtss
;inside goal area now
	st	collflag
	cmp	#.zside,OldZpos(a3)
	blt	.nod
	move	OldZpos(a3),Zpos(a3)
	bra	.deflectz
.nod
	bclr	#pfgoal,pflags(a3)
	move	puckc,d0
	bmi	.nocon
	st	puckc
	asl	#scsize,d0
	move	#SortCords,a0
	move	#8,nopuck(a0,d0)
	move	pucky,d1
	btst	#pfgoal,pflags(a0,d0)
	bne	.an
	neg	d1
.an	tst	d1
	bpl	.nocon
	bset	#pfgoal,pflags(a3)
.nocon	move	#-256,d0

	move.l	Ypos(a3),d1
	sub.l	OldYpos(a3),d1
	asr.l	#8,d1
	beq	.sideentry
	bmi	.0
	neg	d0	;check top entry
	neg	d5
.0
	add	d3,d5	;dy

	move.l	Xpos(a3),d3
	sub.l	OldXpos(a3),d3
	asr.l	#8,d3

	muls	d3,d5
	divs	d1,d5
	bvs	.sideentry
	sub	d5,d2
	cmp	d4,d2
	blt	.sideentry
	neg	d4
	cmp	d4,d2
	bgt	.sideentry
	clr	d1
	move	Ypos(a3),d3
	eor	d0,d3
	bmi	wallcoll
	neg	d0
	btst	#pfgoal,pflags(a3)
	bne	wallcoll

	cmp	#.zside,Zpos(a3)
	beq	.deflectsf
	sub	#5,d4
	cmp	d4,d2
	bgt	.deflectsf
	neg	d4
	cmp	d4,d2
	bge	goal

.deflectsf
	bsr	chkshotstat

	move	#SFXpuckpost,-(a7)
	bsr	sfx
	move	#SFXoooh,-(a7)
	bsr	sfx
	add	#300,crowdlevel

	move	#$1000,d0
	bsr	randomd0
	tst	Ypos(a3)
	bmi	.df0
	neg	d0
.df0
	move	d0,Yvel(a3)
	
	move	#$1000,d0
	bsr	randomd0s
	move	d0,Xvel(a3)

	move	#$1000,d0
	bsr	randomd0s
	move	d0,Zvel(a3)

	bra	puckflip

.deflectz
	neg	Zvel(a3)
	bpl	rtss
	neg	Zvel(a3)
	rts

.sideentry
	clr	d0
	move	#256,d1
	move	Xpos(a3),d2
	sub	OldXpos(a3),d2
	bmi	wallcoll
	neg	d1
	bra	wallcoll

Goal	;puck in goal
	btst	#gmclock,gmode
	bne	rtss

	bsr	chkshotstat

	move	#SFXsiren,-(a7)
	bsr	sfx

	bsr	freezewindow
	add	#800,crowdlevel

	clr	d0
	tst	Ypos(a3)
	bpl	.g0
	eor	#tmsize,d0
.g0	btst	#gmdir,gmode
	beq	.g1
	eor	#tmsize,d0
.g1	bsr	PenGoalStuff
	move	d0,-(a7)
	move	#tmstruct,a0
	add	#1,tmscore(a0,d0)
	bsr	printscores1

	move	(a7)+,d2
	bne	.nocheer
	move	#SFXcrowdcheer,-(a7)
	bsr	SFX
.nocheer
	moveq	#ascore,d0
	bsr	.setass
;	eor	#tmsize,d2
;	moveq	#anothing,d0
;	bsr	.setass
	clr	collflag
	clr	Xvel(a3)
	clr	Yvel(a3)
	moveq	#6,d0
	tst	Xpos(a3)
	bpl	.1
	neg	d0
.1	move	d0,Xpos(a3)
	move	blueline,d0
	add	#goalline+8,d0
	tst	Ypos(a3)
	bpl	.0
	neg	d0
.0	move	d0,Ypos(a3)

	move	#$600,Zvel(a3)
	clr	Zpos(a3)
	st	puckcross+2
	st	puckcross+6
	bset	#pfnc,pflags(a3)
	move	#pnothing,d0
	bsr	assreplace
	move.l	a3,-(a7)
	add	#SCstruct,a3
	move	#SPAsiren,d1
	bsr	SetSPA
	move.l	(a7)+,a3

	moveq	#PenGoal,d0
	bra	addpenalty2

.setass	move.l	a3,-(a7)
	move.l	tmsort(a0,d2),a3
	moveq	#5,d3
.loop	tst	position(a3)
	ble	.nl
;	bclr	#pfalock,pflags(a3)
	btst	#pf2fight,pflags2(a3)
	bne	.nl
	bclr	#pfnc,pflags(a3)
	bsr	assinsert
.nl	add	#SCstruct,a3
	dbf	d3,.loop
	move.l	(a7)+,a3
	rts

checkgoalp
	;check for player a3 collision with goal/net
.radiusx	=	32	;oval goal
.radiusy	=	11
	btst	#pf2npc,pflags2(a3)
	bne	rtss
	cmp	#10,Zpos(a3)
	bgt	rtss
	cmp	#11,SCnum(a3)
	bgt	rtss
	movem	d2-d3,-(a7)
	sub	Ypos(a2),d3
	move	d3,d0	;cos0 =-dy/r
	sub	Xpos(a2),d2
	move	d2,d1	;sin0 = dx/r
	neg	d0

	asl	#4,d2
	muls	d2,d2
	;divu	#.radiusx^2,d2	
	divu  #(.radiusx*.radiusx),d2   ; Calculate multiplication
	cmp	#256,d2
	bhi	.exit

	asl	#4,d3
	muls	d3,d3
	;divu	#.radiusy^2,d3
	divu  #(.radiusy*.radiusy),d3   ; Calculate multiplication
	add	d2,d3
	cmp	#256,d3
	bhi	.exit

	movem	(a7)+,d2-d3
	bsr	CheckBump
	movem	d2-d3,-(a7)

	movem	d0-d1,-(a7)
	muls	d0,d0
	muls	d1,d1
	add.l	d1,d0
	bsr	sroot
	move	d0,d2
	movem	(a7)+,d0-d1
	add	#1,d2
	asl.l	#8,d0
	divs	d2,d0
	asl.l	#8,d1
	divs	d2,d1

	bsr	wallcoll
.exit	movem	(a7)+,d2-d3
	rts

CheckBump	;supply minimum separation velocity for coll with walls/goal/net
.minv	=	$2000
	movem.l	d0-d1,-(a7)
	move	HVcount,d0
	and	#$000f,d0
	bne	.ex
	move	pucky,d0
	sub	Ypos(a2),d0
	cmp	#40,d0
	bgt	.ex
	cmp	#-40,d0
	blt	.ex
	move	Xvel(a3),d0
	move	Yvel(a3),d1
	cmp	#.minv,d0
	bgt	.bb
	cmp	#-.minv,d0
	blt	.bb
	cmp	#.minv,d1
	bgt	.bb
	cmp	#-.minv,d1
	blt	.bb
.ex	movem.l	(a7)+,d0-d1
	rts
.bb	add	#8+4,a7
	asr	#2,d0
	asr	#2,d1
	move	d0,Xvel(a2)
	move	d1,Yvel(a2)
	clr	Xvel(a3)
	clr	Yvel(a3)
	bset	#sfslock,sflags
	btst	#gmclock,gmode
	bne	rtss
	moveq	#Penghold,d0
	bra	AddPenalty2

wallcollb	;check for puck over wall
	cmp	#puckSCnum,SCnum(a3)
	bne	wallcoll	;not puck so wall coll
	cmp	#12*8/3,Zpos(a3)
	bgt	.0
	cmp	#274,Ypos(a3)
	bgt	wallcoll
	cmp	#8*8/3,Zpos(a3)
	bls	wallcoll

.0	bset	#sfslock,sflags
	bset	#pfnc,pflags(a3)
	tst	Ypos(a3)
	bpl	.1
	or	#$8000,attribute(a3)
.1	clr	frame+SCstruct(a3)
	btst	#gmclock,gmode
	bne	rtss
	move.l	a3,-(a7)
	move	ltplayer,d0
	asl	#scsize,d0
	move	#sortcords,a3
	add	d0,a3
	moveq	#PenOOP,d0
	bsr	AddPenalty2
	move.l	(a7)+,a3
	rts

wallcoll
	;d0 = cosine of angle of incidence with wall
	;d1 = sine of angle of incidence with wall
	move	d0,wallcos(a3)
	move	d1,wallsin(a3)
	movem.l	d2-d3,-(a7)
	movem	d0-d1,-(a7)
	muls	Yvel(a3),d0
	muls	Xvel(a3),d1
	sub.l	d1,d0
	asr.l	#8,d0	
	move	d0,d2	;v1n

	movem	(a7),d0-d1
	muls	Xvel(a3),d0
	muls	Yvel(a3),d1
	add.l	d1,d0
	asr.l	#8,d0
	move	d0,d3	;v1t

	neg	d2
	cmp	#puckSCnum,SCnum(a3)
	bne	.player

	bclr	#sf2shot,sflags2
	tst	d2
	bpl	.nocoll
	asr	#2,d2	;reduce normal speed on puck
	cmp	#-$400,d2
	bgt	.pok
	move	#$800,d0
	bsr	randomd0
	neg	d0
	move	d0,Zvel(a3)
	bsr	puckflip

	move	#SFXpuckwall1,-(a7)
	cmp	#-$1200,d2
	blt	.sf0
	move	#SFXpuckwall2,(a7)
	cmp	#-$800,d2
	blt	.sf0
	move	#SFXpuckwall3,(a7)
.sf0	bsr	sfx
.pok
	move	d3,d0	;reduce tangent speed on puck
	asr	#6,d0
	sub	d0,d3
	asr	#1,d0
	sub	d0,d3
	bra	.noadd
.player
	cmp	#1000,d2
	bgt	.nocoll

	cmp	#-$1000,d2
	bgt	.nosfx
	cmp	#10,impact(a3)
	blt	.nosfx
	move	#SFXplayerwall,-(a7)
	bsr	sfx
.nosfx
	asr	#2,d2
	cmp	#-900,d2
	blt	.noadd
	move	#-1000,d2
.noadd
	movem	(a7),d0-d1
	movem	d2-d3,-(a7)
	muls	d0,d3
	muls	d1,d2
	sub.l	d2,d3
	asr.l	#8,d3
	move	d3,Xvel(a3)
	movem	(a7)+,d2-d3
	movem	(a7),d0-d1
	muls	d1,d3
	muls	d0,d2
	add.l	d2,d3
	asr.l	#8,d3
	move	d3,Yvel(a3)

	tst	Zvel(a3)
	bmi	.nocoll
	clr	Zvel(a3)
.nocoll
	add	#4,a7
	movem.l	(a7)+,d2-d3
	rts
;-----------------------------------------------------------
checkpuckcoll	;look for puck coll with players
.cbody	=	8
.cstick	=	14
	cmp	#6*8/3,Zpos(a3)	;feet in air
	bgt	rtss	
	move	SCnum(a3),d0
	asl	#1,d0		;current object number
	move.l	#OOlistpos,a0
	move.l	#OOlist,a1
	move.l	#Ylist,a2
	move	0(a0,d0),d1	 ;current objects pos in OOlist
.0	cmp	#sortobjs-1,d1
	beq	.cl		;it is top sprite on screen
	clr	d4
	move.b	1(a1,d1),d4	;next higher object number
	move	0(a2,d4),d5	;y pos of next higher object
	sub	Ypos(a3),d5
	cmp	#.cbody+.cstick,d5
	bgt	.cl		;no higher sprite coll
	bsr	.ccx
	addq	#1,d1
	bra	.0

.cl	move	0(a0,d0),d1
	beq	.ex
.1	clr	d4
	move.b	-1(a1,d1),d4	;next lower object number
	move	Ypos(a3),d5
	sub	0(a2,d4),d5	;y pos of next lower object
	cmp	#.cbody+.cstick,d5
	bgt	.ex
	bsr	.ccx
	subq	#1,d1
	bne	.1
.ex	rts

.ccx	;
	movem.l	d0-d7/a0-a3,-(a7)
	lsr	#1,d4
	cmp	puckc,d4
	beq	.exit
	cmp	#11,d4
	bgt	.exit
	asl	#scsize,d4
	move.l	#SortCords,a2
	add	d4,a2
	btst	#pfnc,pflags(a2)
	bne	.exit		;object has no coll mode on
	tst	nopuck(a2)
	bne	.exit

	btst	#pf2unav,pflags2(a2)
	bne	.chkbody
	cmp	#2*8/3,Zpos(a3)
	bgt	.chkbody
	cmp	#$100,Zvel(a3)
	bgt	.chkbody
	move.l	a2,-(a7)
	bsr	GetHot
	add	Xpos(a2),d0
	sub	Xpos(a3),d0
	cmp	#.cstick,d0
	bgt	.chkbody
	cmp	#-.cstick,d0
	blt	.chkbody
	add	Ypos(a2),d1
	sub	Ypos(a3),d1
	cmp	#.cstick,d1
	bgt	.chkbody
	cmp	#-.cstick,d1
	blt	.chkbody
	muls	d0,d0
	muls	d1,d1
	add.l	d1,d0
	;move.l	#.cstick^2,d1
	move.l	#(.cstick*.cstick),d1	
	tst	nopuck(a3)	;puck is not ready to be caught
	ble	.lo
	lsr	#2,d1
.lo
	cmp.l	d1,d0
	bhi	.chkbody
	bsr	puckstick
	bra	.exit

.chkbody
	tst	position(a2)
	beq	.chkgoalie	
	move	Xpos(a2),d0
	sub	Xpos(a3),d0
	cmp	#.cbody,d0
	bgt	.exit
	cmp	#-.cbody,d0
	blt	.exit
	move	Ypos(a2),d1
	sub	Ypos(a3),d1
	cmp	#.cbody,d1
	bgt	.exit
	cmp	#-.cbody,d1
	blt	.exit
	muls	d0,d0
	muls	d1,d1
	add.l	d1,d0
	cmp.l	#.cbody*.cbody,d0
	bhi	.exit
	bsr	puckbody
.exit	movem.l	(a7)+,d0-d7/a0-a3
	rts

.chkgoalie
.cbg	=	12
	move	Xpos(a2),d0
	sub	Xpos(a3),d0
	cmp	#.cbg,d0
	bgt	.exit
	cmp	#-.cbg,d0
	blt	.exit
	move	Ypos(a2),d1
	sub	Ypos(a3),d1
	cmp	#.cbg,d1
	bgt	.exit
	cmp	#-.cbg,d1
	blt	.exit
	movem	d0-d1,-(a7)
	muls	d0,d0
	muls	d1,d1
	add.l	d1,d0
	cmp.l	#.cbg*.cbg,d0
	movem	(a7)+,d0-d1
	bhi	.exit
	bsr	puckgoalie
	bra	.exit

puckstick	;puck collides with stick
;a2	= player who collided
;a3	= puck
	tst	position(a2)
	bne	.0
	btst	#gmhl,gmode
	bne	rtss
.0
	bclr	#pfdoff,pflags(a2)
	move	puckc,d1
	bmi	.nosteal
	;cmp.l	#6^2,d0
	cmpi.l	#(6*6),d0
	bhi	rtss	;smaller range for stealing puck
	asl	#scsize,d1
	move.l	#SortCords,a0
	add	d1,a0
	tst	position(a0)
	beq	rtss	;no steal from goalie
	move.b	pflags(a0),d1
	move.b	pflags(a2),d2
	eor	d1,d2
	btst	#pfteam,d2
	beq	rtss	;no steal from team member

	move	puckvy,d0
	or	puckvx,d0
	beq	.steal

	move.b	stickhand(a0),d0
	bsr	makepde
	move	d0,-(a7)
	exg.l	a0,a2
	move.b	stickhand(a0),d0
	bsr	makepde
	exg.l	a0,a2
	neg	d0
	add	(a7)+,d0
	add	#36,d0
	bsr	randomd0
	cmp	#2,d0
	bhi	rtss
.steal	move.b	stickhand(a0),d0
	bsr	makepde
	add	#20,d0
	move	d0,nopuck(a0)
	exg.l	a0,a2
	move.b	stickhand(a0),d0
	bsr	makepde
	add	#20,d0
	move	d0,nopuck(a0)
	exg.l	a0,a2
	move	SCnum(a0),lastplayer
	bclr	#sfspdir,sflags
	bclr	#sfssdir,sflags
.stdef	move	#SFXstdef,-(a7)
	bsr	sfx
	bsr	a2touchpuck
	bra	deflect

.nosteal
	move	puckvx,d0
	asr	#6,d0
	muls	d0,d0
	move	puckvy,d1
	asr	#6,d1
	muls	d1,d1
	add.l	d1,d0
	;cmp.l	#320^2,d0
	cmp.l	#(320*320),d0
	bls	.glue
	move	#8,nopuck(a2)
	bra	.stdef

.glue	move	#SFXpuckget,-(a7)
	bsr	sfx
	move	SCnum(a2),d0
	move	d0,puckc
	bclr	#sfspdir,sflags
	bclr	#sfssdir,sflags
	tst	position(a2)
	bne	setd0player
	bsr	chkshotstat
	move	#120,temp5(a2)	;count down for faceoff
setd0player
	cmp	c1playernum,d0
	beq	rtss
	cmp	c2playernum,d0
	beq	rtss
	cmp	#6,d0
	slt	d1
	ext	d1
	add	#2,d1
	move	lastplayer,d2
	cmp	c2playernum,d2
	beq	.1
	cmp	cont1team,d1
	beq	setc1player
.1	cmp	cont2team,d1
	beq	setc2player
	cmp	cont1team,d1
	beq	setc1player
	rts

puckbody	;puck hits player a2
	cmp	#3*8/3,Zpos(a3)
	bgt	.hit
	move	d0,d1
	and	#15,d1	;radius^2 from center
	bne	rtss
.hit
	bsr	a2touchpuck
	move	#SFXpuckbody,-(a7)
	bsr	sfx

	clr	Zvel(a3)
	move	#8,nopuck(a2)
	move	Xpos(a3),d0
	sub	Xpos(a2),d0
	move	Ypos(a3),d1
	sub	Ypos(a2),d1
	bne	.0
	move.l	a2,-(a7)
	bsr	GetHot
.0	move.b	d0,Xvel(a3)
	move.b	d1,Yvel(a3)
	bsr	puckflip
	cmp	#12,Zpos(a3)
	bgt	FallDown
	rts

puckgoalie	;puck hits goalie a2
	btst	#gmhl,gmode
	bne	rtss

	clr	d2	;puck region
	cmp	#3*8/3,Zpos(a3)
	bgt	.1
	add	#2,d2
.1
	neg	d0
	neg	d1
	bsr	vtoa
	sub	facedir(a2),d0
	and	#7,d0
;0 puck straight in front of goalie
;1-3 puck to goalies right
;4 puck straight behind goalie
;5-7 puck to goalies left
	move	d0,d1
	and	#3,d1
	bne	.2
	move	HVcount,d0	;just for random bit
.2	and	#4,d0
	lsr	#2,d0
	eor	#1,d0
	add	d0,d2
	add	d2,d2
	move.l	#.list,a0
	move	0(a0,d2),d0
	moveq	#15,d1
	add.b	0(a2,d0),d1	;save odds

	move.l	#.list2,a0
	btst	#3,attribute(a2)	;x flip?
	beq	.3
	eor	#2,d2
.3
	move	frame(a2),d0
	sub	#SPFgoalie,d0
	move.b	0(a0,d0),d0
	lsr	d2,d0
	and	#3,d0

	mulu	d1,d0
	beq	rtss

	bsr	randomd0
	cmp	#8,d0
	blt	rtss

	bsr	ChkShotStat
	bsr	a2touchpuck
	move	#SFXpuckbody,-(a7)
	bsr	sfx

	clr	Zvel(a3)
	move	#8,nopuck(a2)
	move	Xpos(a3),d0
	sub	Xpos(a2),d0
	move	Ypos(a3),d1
	sub	Ypos(a2),d1
	bne	.0
	move.l	a2,-(a7)
	bsr	GetHot
.0	move.b	d0,Xvel(a3)
	move.b	d1,Yvel(a3)
	bra	puckflip


.list	dc.w	GGSleft,GGSright
	dc.w	GSSleft,GSSright

.list2	;odds for stopping puck in each quadrant for each possible goalie frame
	pix	1111,2131,1213	;ready/glover/glovel
	pix	1111,2131,1213
	pix	1111,2131,1213
	pix	1111,2131,1213
	pix	1111,2131,1213
	pix	1111,2131,1213
	pix	1111,2131,1213
	pix	1111,2131,1213

	pix	1111,1111	;goalie swing
	pix	1111,1111
	pix	1111,1111
	pix	1111,1111
	pix	1111,1111
	pix	1111,1111
	pix	1111,1111
	pix	1111,1111

	pix	1111,3300	;goalie stack right
	pix	1111,3300
	pix	1111,3300
	pix	1111,3300
	pix	1111,3300
	pix	1111,3300
	pix	1111,3300
	pix	1111,3300

	pix	1111,3300	;goalie stack left
	pix	1111,3300
	pix	1111,3300
	pix	1111,3300
	pix	1111,3300
	pix	1111,3300
	pix	1111,3300

	pix	3111,1311	;goalie stick right/left
	pix	3111,1311
	pix	3111,1311
	pix	3111,1311
	pix	3111,1311
	pix	3111,1311
	pix	3111,1311
	pix	3111,1311

	; dc.b    $55,$9D,$67,$55,$9D,$67,$55,$9D,$67,$55,$9D,$67
   	; dc.b    $55,$9D,$67,$55,$9D,$67,$55,$9D,$67,$55,$9D,$67
   	; dc.b    $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
   	; dc.b    $55,$55,$55,$55
   	; dc.b    $55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0
   	; dc.b    $55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0
   	; dc.b    $55,$F0,$55,$F0,$55,$F0
   	; dc.b    $D5,$75,$D5,$75,$D5,$75,$D5,$75,$D5,$75,$D5,$75
   	; dc.b    $D5,$75,$D5,$75

deflect	;random puck direction on deflection puck = a3
	st	puckc
	move	#$1000,d0
	bsr	randomd0s
	move	d0,Yvel(a3)
	
	move	#$1000,d0
	bsr	randomd0s
	move	d0,Xvel(a3)

	move	#$1000,d0
	bsr	randomd0
	move	d0,Zvel(a3)
	bra	puckflip

freezewindow	;lock scrolling to current position
	move	Vpos,yc1
	move	Hpos,xc1
	bset	#sfslock,sflags
	rts

checkwindow	;set hpos and vpos according to how screen should follow puck

.ylim	=	10	;window limits
.xlim	=	40
.yslimu	=	256
.yslimd	=	-200
.xslim	=	60
.maxy	=	6
.maxx	=	5

	move	yc1,d2
	move	xc1,d3	;if locked, use these cordinates
	btst	#sfslock,sflags
	bne	.dd
	move.l	#puckx,a3
	move	puckc,d0
	bmi	.ok
	asl	#scsize,d0
	move.l	#SortCords,a3
	add	d0,a3
	move	d7,d0
	add	d0,d0
	btst	#pfgoal,pflags(a3)
	beq	.gd
.ylmax	=	50
	add	d0,yleader
	cmp	#.ylmax,yleader
	blt	.ok
	move	#.ylmax,yleader
	bra	.ok
.gd	sub	d0,yleader
	cmp	#-.ylmax,yleader
	bgt	.ok
	move	#-.ylmax,yleader

.ok	move	Yvel(a3),d2
	asr	#7,d2
	add	Ypos(a3),d2
	add	yleader,d2

	move	Xpos(a3),d3
	move	d2,yc1
	move	d3,xc1
.dd
	move	d2,d0
	sub	Vpos,d0
	cmp	#-.ylim,d0
	bge	.1
	move	d2,d1
	sub	#-.ylim,d1
	cmp	#.yslimd,d1
	bgt	.2
	move	#.yslimd,d1
	bra	.2

.1	cmp	#.ylim,d0
	ble	.2x
	move	d2,d1
	sub	#.ylim,d1
	cmp	#.yslimu,d1
	blt	.2
	move	#.yslimu,d1
.2
	sub	Vpos,d1
	beq	.2x
	asr	#4,d1
	bne	.v2
	add	#1,d1

.v2
	add	d1,Vpos
.2x
	move	d3,d0
	sub	Hpos,d0
	cmp	#-.xlim,d0
	bge	.3
	move	d3,d1
	sub	#-.xlim,d1
	cmp	#-.xslim,d1
	bge	.4
	move	#-.xslim,d1
	bra	.4

.3	cmp	#.xlim,d0
	ble	rtss
	move	d3,d1
	sub	#.xlim,d1
	cmp	#.xslim,d1
	ble	.4
	move	#.xslim,d1
.4
	sub	Hpos,d1
	beq	rtss
	asr	#4,d1
	bne	.h2
	add	#1,d1
.h2
	add	d1,Hpos
	rts

updatescroll
	;using hpos and vpos set scroll cords and flags
	;also set up map transfer if new rows of characters are needed by
	;vertical scrolling
	btst	#sfhor,sflags
	bne	rtss
	moveq	#-192+128,d0
	sub	Hpos,d0
	move	Vpos,d1
	move	d0,Hscroll
	move	d1,Vscroll
	neg	Vscroll

	move.l	#tempmap,a1
	move	Oldrow,d4
	asr	#3,d1
	move	d1,Oldrow

	st	(a1)
	moveq	#31,d3	;max lines to update

	move	rinkvrcset,d2	;char set for field
	cmp	d4,d1
	beq	rtss
	blt	.su

.sd	move	d1,d0
	neg	d0
	add	#30,d0
	and	#31,d0
	asl	#7,d0	;chars per row screen format
	move	d0,(a1)+	;map memory
	moveq	#60-30,d0
	sub	d1,d0
	add	Voffset,d0
	mulu	#48*2,d0	;chars per row in map
	move.l	#IceRinkMap,a0
	add.l	4(a0),a0
	add	#4,a0
	add	d0,a0
	moveq	#47,d0
.sd0	move	(a0)+,(a1)
	add	d2,(a1)+
	dbf	d0,.sd0
	subq	#1,d1
	cmp	d4,d1
	dbeq	d3,.sd
	st	(a1)
	rts

.su	move	d1,d0
	neg	d0
	add	#29,d0
	and	#31,d0
	asl	#7,d0	;64 chars per line screen format
	move	d0,(a1)+	;map memory
	moveq	#60+1,d0
	sub	d1,d0
	add	Voffset,d0
	mulu	#48*2,d0	;chars per row in map
	move.l	#IceRinkMap,a0
	add.l	4(a0),a0
	add	#4,a0
	add	d0,a0
	moveq	#47,d0
.su0	move	(a0)+,(a1)
	add	d2,(a1)+
	dbf	d0,.su0
	addq	#1,d1
	cmp	d4,d1
	dbeq	d3,.su
	st	(a1)
rtss	rts	
;--------------------------------------END OF GAME LOGIC
	include	Video.asm

setupice	;set all variables
	;send non purgeable graphics
	;build sprite frame lists for ice rink

	movem.l	d0-d7/a0-a6,-(a7)
	bset	#df32c,disflags
	move	#$0000,VSCRLPM	;horizontal scroll address
	move	#$c000,VmMap2	;map 2 address
	move	#6,Map2col		;map 2 width
	move	#$dc00,VSPRITES	;sprites address
	move	#$e000,VmMap1	;map 1 address
	move	#6,Map1col		;map 1 width (same as 2 always)
	move	#$f800,VmMap3	;map 3 address
	move	#5,Map3col		;map 3 width (dependent on df32c mode)

	move	#$000,d0	;color to fade to
	bsr	setvram
	bclr	#sfpz,sflags

	move	disflags,-(a7)
	bset	#dfng,disflags

	clr	Hpos
	clr	Vpos
	move	#2000,Oldrow
	st	tempmap	;redraw all in updatescroll routine

	st	zamx

	move	#$1000,d0
	move	VmMap1,d1
	moveq	#1,d2
	bsr	doFill	;erase map 1

	move.l	#framelist,a0
	move.l	#Sprites,a1
	bsr	Buildframelist
	add	#2,a0
	move.l	a0,Spritetiles	;address in rom of sprite tiles

	moveq	#2,d4
	move	d4,rinkvrcset	;1st vram char for rink map tiles
	move	d4,d1
	move.l	#IceRinkMap+8,a0
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMA	;transfer tiles to vram

	move	d4,EASNcset	;1st vram char for easn logo tiles
	move	d4,d1
	move.l	#EASNmap+8,a0
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	move.l	#.EASNmap,a1
	bsr	ReMap

	move	d4,Crowdvrcset	;1st vram char for crowd animation tiles
	move.l	#Crowdframelist,a0
	move.l	#Crowdsprites,a1
	bsr	Buildframelist
	move	d4,d1
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMA

	bsr	defaultsprites

	move.l	#IceRinkMap,a0	;transfer pal 0&1
	add.l	(a0),a0
	moveq	#15,d0
	move.l	#palfadenew,a2
	move.l	a2,a1
.ipal	move.l	(a0)+,(a2)+
	dbf	d0,.ipal

	move	#88,blueline
	move	#136,sideline
	clr	Voffset
	move	d4,d1
	move	d1,BigFontChars	;1st vram char for Bigfont tiles
	move.l	#BigFontMap+8,a0
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	move.l	#.bfmap,a1	;remap to this data
	bsr	ReMap

	move	d4,d1
	move	d1,FramerCset	;1st vram char for Framer tiles
	move.l	#FramerMap+8,a0
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	move.l	#.frmap,a1	;remap to this data
	bsr	ReMap

	move	d4,d1
	move	d1,SmallFontChars	;1st vram char for smallfont tiles
	move.l	#SmallFontMap+8,a0
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	move.l	#.sfmap,a1	;remap to this data
	bsr	ReMap

	bsr	SetSLogos	;setup small logos (for score board)

	move	d4,ExtraChars	;char space for extra graphics

	btst	#gmdir,gmode
	beq	.gok
	move.l	#SortCords,a3
	moveq	#11,d0
.l01	bchg	#pfgoal,pflags(a3)
	add	#SCstruct,a3
	dbf	d0,.l01
.gok
	bsr	SetTeamColors

	clr.l	padcont
	clr	padcont+4
	st	c1playernum
	bset	#7,padcont+2
	st	c2playernum
	bset	#7,padcont+4

	move.l	#DMAList,a5	;dump pad sprites so numbers
	move.l	#Satt,a6		;aren't written over later.
	moveq	#1,d6
	move.l	#pads,a3
	clr	d0
	clr	d1
	bsr	addframe2
	add	#ffosize,a3
	bsr	addframe2
	add	#ffosize,a3
	bsr	addframe2
	move.l	a5,DMAlistend
	bsr	DoDMAlist

	move	#28,palcount	;fade in new graphics now
	move	(a7)+,disflags

	move.l	#Vblank,Vbint
	bclr	#dfok,disflags
	bclr	#dfng,disflags
	move	#$2300,sr

	movem.l	(a7)+,d0-d7/a0-a6
	rts

.bfmap
.sfmap	dc.b	0,3,4,3	;remap data
.frmap	dc.b	0,3,4,3
.EASNmap	dc.b	7,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

SetSLogos	;d4 = char area for data
	;transfer tiles for small logos for score board
	move	d4,d2
	move	d4,SmallLogoscset
	add	#8,d4
	move	HomeTeam,d0
	bsr	.getsl
	move	VisTeam,d0

.getsl
	move.l	#TeamBlocksMap,a2
	lea	10(a2),a3
	add.l	4(a2),a2
	mulu	(a2),d0
	asl	#2,d0
	lea	4(a2,d0),a2
	move	(a2),d0
	bsr	.chr
	move	2(a2),d0
	bsr	.chr
	move	26(a2),d0
	bsr	.chr
	move	28(a2),d0

.chr	and	#$07ff,d0
	asl	#5,d0
	lea	0(a3,d0),a0
	moveq	#16,d0
	move	d2,d1
	add	#1,d2
	asl	#5,d1
	bra	DoDMA

defaultsprites
	;d4 = char area for data
	;allocate vram and assign char area for graphic structures
	move.l	#.listsso,a2
	move.l	#sso,a3
	moveq	#ssonum-1,d0
.ssotop	;screen objects not locked to scroll of screen
	move	#-1,oldframe(a3)
	move	(a2)+,Xcord(a3)
	move	(a2)+,Ycord(a3)
	move	(a2)+,frame(a3)
	move	(a2)+,attribute(a3)
	move	d4,VRchar(a3)
	add	(a2),d4
	move	(a2)+,VRsize(a3)
	add	#ssosize,a3
	dbf	d0,.ssotop

	move.l	#.listffo,a2
	move.l	#ffo,a3
	moveq	#ffonum-1,d0
.ffotop	;objects tied to screen scrolling (not players/net/puck)
	st	oldframe(a3)
	move	(a2)+,Xpos(a3)
	move	(a2)+,Ypos(a3)
	move	(a2)+,Zpos(a3)
	move	(a2)+,frame(a3)
	move	(a2)+,attribute(a3)
	move	d4,VRchar(a3)
	add	(a2),d4
	move	(a2)+,VRsize(a3)
	add	#ffosize,a3
	dbf	d0,.ffotop

	clr	d6
	move.l	#OOlist,a1
	move.l	#.list,a2
	move.l	#SortCords,a3
	move.l	#OOlistpos,a4
.0	;objects which are tied to screen scrolling and have velocity relative to icerink
	;also set some variables in the structure to default settings
	moveq	#(SCstruct/4)-1,d0
	move.l	a3,a0
.1	clr.l	(a0)+
	dbf	d0,.1

	move	d6,SCnum(a3)
	st	oldframe(a3)
	st	pnum(a3)
	move	(a2)+,Xpos(a3)
	move	(a2)+,Ypos(a3)
	move	(a2)+,Zpos(a3)
	move	(a2)+,frame(a3)
	move	(a2)+,attribute(a3)
	move	d4,VRchar(a3)
	add	(a2),d4
	move	(a2)+,VRsize(a3)
	move	(a2)+,radiusx(a3)
	move	(a2)+,radiusy(a3)
	add	#1,a2
	move.b	(a2)+,asslist(a3)
	add	#1,a2
	move.b	(a2)+,pflags(a3)

	add	#SCstruct,a3
	asl	#1,d6
	move.b	d6,(a1)+	;OOlist seed
	lsr	#1,d6
	move	d6,(a4)+	;OOlistpos
	addq	#1,d6
	cmp	#Sortobjs,d6
	bne	.0
	bra	SprSort

.listsso	;xcord,ycord,frame,attribute,vram char size
	dc.w	0,0,0,$0000,9
	dc.w	0,0,0,$0000,9
	dc.w	64,-92,SPFLogos,$8000,12
	dc.w	-64,-92,SPFLogos,$8000,12

.listffo	;xcord,ycord,zpos,frame,attribute,vram char size
	dc.w	0,0,-1,SPFpad+2,$0000,6
	dc.w	0,0,-1,SPFpad+0,$0000,6
	dc.w	0,0,-1,SPFpad+1,$0000,6
	dc.w	0,0,0,SPFLogos,$0000,12
	dc.w	0,0,-1,SPFgloves,$0000,5
.list
;xcord,ycord,zcord,frame,att,vrsize,radx,rady,asslist,pflags
	dc.w	-200,-120,0,1,$0000,20,8,4,0,(1<<pfgoal)	;home team
	dc.w	-200,-100,0,1,$0000,20,8,4,0,(1<<pfgoal)
	dc.w	-200,-80,0,1,$0000,20,8,4,0,(1<<pfgoal)
	dc.w	-200,-60,0,1,$0000,20,8,4,0,(1<<pfgoal)
	dc.w	-200,-40,0,1,$0000,20,8,4,0,(1<<pfgoal)
	dc.w	-200,-20,0,1,$0000,20,8,4,0,(1<<pfgoal)

	dc.w	-200,20,0,1,$0001,20,8,4,0,(1<<pfteam)	;visitor team
	dc.w	-200,40,0,1,$0001,20,8,4,0,(1<<pfteam)
	dc.w	-200,60,0,1,$0001,20,8,4,0,(1<<pfteam)
	dc.w	-200,80,0,1,$0001,20,8,4,0,(1<<pfteam)
	dc.w	-200,100,0,1,$0001,20,8,4,0,(1<<pfteam)
	dc.w	-200,120,0,1,$0001,20,8,4,0,(1<<pfteam)

	dc.w	0,268,0,SPFgoal,$0000,11,20,6,0,0	;(1<<pfnc)	;goal net
	dc.w	0,-268,0,SPFgoal+1,$0000,17,20,6,0,0	;(1<<pfnc)

	dc.w	0,0,0,SPFpuck+1,$0000,1,5,5,pnorm,(1<<pfdoff)	;puck
  	dc.w	0,0,0,SPFpuck,$0000,4,3,3,pshad,(1<<pfnc)

SprSort	;sort objects in struct SortObj and set corresponding tables for keeping them sorted later
	movem.l	a0-a2/d0-d4,-(a7)
	move.l	#OOlistpos,a2
	move.l	#Ylist,a1
	move.l	#SortCords,a0
	move	#Sortobjs-1,d3
.loop0
	move	Ypos(a0),d4
	btst	#sfhor,sflags
	beq	.l01
	move	Xpos(a0),d4
.l01	move	d4,(a1)+		;update ylist
	add	#SCstruct,a0
	dbf	d3,.loop0

	move.l	#Ylist,a1
.loop
	clr	d4
	move.l	#OOlist,a0
	move	#Sortobjs-2,d3
	clr	d0
	clr	d1
.0	move.b	(a0)+,d0	;object number *2
	move.b	(a0),d1
	move	0(a1,d0),d2	;pos of sup lower sprite
	cmp	0(a1,d1),d2
	ble	.1
	move.b	d0,(a0)
	move.b	d1,-1(a0)

	move.l	a0,d2
	sub.l	#OOlist,d2
	move	d2,0(a2,d0)
	subq	#1,d2
	move	d2,0(a2,d1)

	st	d4	;flag for incomplete sort
.1	dbf	d3,.0
	tst	d4
	bne	.loop
	movem.l	(a7)+,a0-a2/d0-d4
	rts

resetplstuff	;reset team variables/and players on both teams
	movem.l	a0-a3/d0-d2,-(a7)
	move	#tmstruct,a2
	bsr	.top
	move	#tmstruct+tmsize,a2
	bsr	.top
	movem.l	(a7)+,a0-a3/d0-d2
	rts
.top
	moveq	#5,d2
	move.l	tmsort(a2),a3
.loop
	clr.b	pflags2(a3)
	clr.b	pflags3(a3)
	tst	position(a3)
	bmi	.next
	move	#SPAglide,d1
	bsr	SetSPA
	clr	impact(a3)
	clr	nopuck(a3)
	;and.b	#(2^pfteam)+(2^pfgoal)+(2^pfna),pflags(a3)
	and.b   #((1<<pfteam)+(1<<pfgoal)+(1<<pfna)),pflags(a3)
.next	add	#SCstruct,a3
	dbf	d2,.loop
	rts

setteams	;use hometeam/visteam to set team structures
	move.l	#tmsize-1,d0
	move	#tmstruct,a0
.0	clr	(a0)+
	dbf	d0,.0

	move.l	#teamlist,a0
	move	HomeTeam,d0
	asl	#2,d0
	move.l	0(a0,d0),tmstruct+tmdata
	move.l	#SortCords,tmstruct+tmsort
	move	VisTeam,d1
	asl	#2,d1
	move.l	0(a0,d1),tmstruct+tmsize+tmdata
	move.l	#SortCords+(6*SCstruct),tmstruct+tmsize+tmsort
	rts

SetTeamColors
	;bad name for this/it really just sets the frame for each teams logo
	move	#SPFLogos,d0
	add	HomeTeam,d0
	move	d0,ffo+(3*ffosize)+frame
	move	d0,sso+(2*ssosize)+frame
	move	#SPFLogos,d0
	add	VisTeam,d0
	move	d0,sso+(3*ssosize)+frame

setplayercolors
	;copy in correct color data for each team
	clr	d1
	move.l	#tmstruct,a0
	bsr	.sp
	moveq	#32,d1
	add	#tmsize,a0
.sp
	move.l	tmdata(a0),a2
	add	Palettedata(a2),a2
	add	d1,a2
	move.l	#palfadenew+$40,a1
	add	d1,a1
	moveq	#7,d0
.5	move.l	(a2)+,(a1)+
	dbf	d0,.5
	rts
;-----------------------------------------------------------
makepde	;pass d0 as value to be scaled by player a3's energy level
	;return d0 as result
	ext	d0
	move	d0,-(a7)
	movem.l	d1/a2-a3,-(a7)
	move.l	a0,a3
	bsr	getpde
	movem.l	(a7)+,d1/a2-a3
	muls	(a7)+,d0
	asl.l	#4,d0
	swap	d0
	ext.l	d0
	rts

getpde	;get player a3's energy level into d0
	move.l	#tmstruct,a2
	btst	#pfteam,pflags(a3)
	beq	.0
	add	#tmsize,a2
.0	move.b	pnum(a3),d1
	ext	d1
	add	d1,d1
	move	tmpde(a2,d1),d0
	rts

setpde	;d1 = rostnum of player
	;d0 = new energy level
	tst	d1
	bmi	rtss
	cmp	#(MaxRos-1)*2,d1
	bhi	rtss
	tst	d0
	bpl	.0
	clr	d0
.0	move	d0,tmpde(a2,d1)
	rts

setpersonel	;this will set personel on team a2 according to team a2's registers
	movem.l	d0-d5/a0-a4,-(a7)
	move.l	tmsort(a2),a3
	moveq	#5,d4
.l0	st	newpos(a3)
	st	newpnum(a3)
	add	#SCstruct,a3
	dbf	d4,.l0

	bsr	SetPlList

	moveq	#5,d4
	move.l	#PlList,a4	;list of players we want on ice
.1	clr	d5
	move.b	0(a4,d4),d5
	beq	.next
	sub	#1,d5
	moveq	#5,d3
	move.l	tmsort(a2),a3
	sub	#SCstruct,a3
.2	add	#SCstruct,a3
	cmp.b	pnum(a3),d5
	dbeq	d3,.2
	bne	.next
	move.b	6(a4,d4),newpos(a3)
	move.b	d5,newpnum(a3)
	clr.b	0(a4,d4)
.next	dbf	d4,.1

	moveq	#5,d4
	move.l	#PlList,a4
.3	clr	d5
	move.b	0(a4,d4),d5
	beq	.next2
	sub	#1,d5
	moveq	#5,d3
	move.l	tmsort(a2),a3
	sub	#SCstruct,a3
.4	add	#SCstruct,a3
	tst.b	newpnum(a3)
	dbmi	d3,.4
	move.b	6(a4,d4),newpos(a3)
	move.b	d5,newpnum(a3)
	clr.b	0(a4,d4)
.next2	dbf	d4,.3
	movem.l	(a7)+,d0-d5/a0-a4
	rts

;-------------------------------------------------------------
SetPlList	;create list (PlList) of players who we want on the ice now
	;a2 = team struct
	move	#PlList,a4
	clr.l	(a4)
	clr	4(a4)
	move.l	#priolist,a0
	cmp	#2,tmgoalie(a2)
	bne	.gin
	add	#1,a0
.gin	move.l	tmdata(a2),a1
	add	LineSets(a1),a1
	move	tmline(a2),d0
	asl	#3,d0
	add	d0,a1
	move	tmap(a2),d4	;active players 4-6
	bra	.next
.0	clr	d5
	move.b	0(a0,d4),d5	;position
	move.b	0(a1,d5),0(a4,d4)	;,0(a4,d5)	;player number
	move.b	d5,6(a4,d4)
	bne	.next
	cmp	#1,tmgoalie(a2)
	bne	.next
	add.b	#1,0(a4,d4)	;2nd goalie
.next	dbf	d4,.0

	moveq	#5,d4	;now check to see if player is avail
.1	move.b	0(a4,d4),d3
	beq	.next1
	ext	d3
	sub	#1,d3
	add	d3,d3
	tst	tmpdst(a2,d3)
	ble	.next1	;player is ok
;now find player of similar position who is available
	move.l	tmdata(a2),a1
	add	LineSets(a1),a1
	move.b	6(a4,d4),d0	;position
	ext	d0
	asl	#2,d0
	move.l	#sublist,a0
	move.l	0(a0,d0),a0
.s1	clr	d0
	move.b	(a0)+,d0
	bmi	.next1	;error all players in penalty
	move.b	0(a1,d0),d0
	move	d0,d1
	sub	#1,d0
	add	d0,d0
	tst	tmpdst(a2,d0)
	bgt	.s1

	moveq	#5,d0
.s2	cmp.b	0(a4,d0),d1
	dbeq	d0,.s2
	beq	.s1
	move.b	d1,0(a4,d4)

.next1	dbf	d4,.1
	rts

sublist
	dc.l	.goalie
	dc.l	.defl
	dc.l	.defr
	dc.l	.wingl
	dc.l	.center
	dc.l	.wingr
	dc.l	.center

.goalie
.defl
.defr	dc.b	0+1,8+1,16+1,24+1,32+1,40+1,48+1	;list of players in there lines/each line = 8 bytes
	dc.b	0+2,8+2,16+2,24+2,32+2,40+2,48+2
.wingl
.wingr
.center
	dc.b	0+3,8+3,16+3,24+3,32+3,40+3,48+3
	dc.b	0+4,8+4,16+4,24+4,32+4,40+4,48+4
	dc.b	0+5,8+5,16+5,24+5,32+5,40+5,48+5
	dc.b	-1

priolist	dc.b	0,1,2,4,3,5,6	;positions in order of importance

	dc.b $FF
;--------------------------------------------------------------

forcepldata	;no skating on/off force players to correct data (for faceoffs only)
	;a2 = team struct
	movem.l	d0-d4/a0-a3,-(a7)
	move.l	tmsort(a2),a3
	moveq	#5,d4
.top	move.b	newpos(a3),d0
	ext	d0
	move	d0,position(a3)
	bmi	.next
	bsr	Setplass
	cmp	#4,position(a3)
	bne	.notnear
	moveq	#anearest,d0
	bsr	assinsert
.notnear	clr	d3
	move.b	newpnum(a3),d3
	add	d3,d3
	move	#-1,tmpdst(a2,d3)	;put player on the ice
	lsr	#1,d3
	bsr	setplayer
.next	st	newpnum(a3)
	st	newpos(a3)
	add	#SCstruct,a3
	dbf	d4,.top
	movem.l	(a7)+,d0-d4/a0-a3
	rts

ResetBench	;remove all players from penalty box/ put all players on their own bench
	clr.b	PBnum
	moveq	#16,d1
	move	#tmstruct,a0
	bsr	.rb
	moveq	#1,d1
	add	#tmsize,a0
.rb	moveq	#(MaxRos-1)*2,d0
.rb1	add.b	d1,PBnum
	tst	tmpdst(a0,d0)
	bgt	.next
	sub.b	d1,PBnum
	move	#-2,tmpdst(a0,d0)
.next	sub	#2,d0
	bpl	.rb1
	rts

Setplass	;set players (a3) initial assignment 
	move	position(a3),d0
	bmi	rtss
	move.l	#.alist,a0
	move.b	0(a0,d0),d0
	bra	assreplace

.alist
	dc.b	agoalie
	dc.b	adefd
	dc.b	adefd
	dc.b	awingd
	dc.b	acenterd
	dc.b	awingd
	dc.b	acenterd
	dc.b	$FF

setplayer	;bring player onto the ice and set his stats
;d3 = player number
;a3 = sortcord of player
	move.l	#tmstruct,a0
	btst	#pfteam,pflags(a3)
	beq	.0
	add	#tmsize,a0
.0
	move.b	d3,pnum(a3)
	moveq	#aepen,d0
	ext	d3
	asl	#1,d3
	move	tmpdst(a0,d3),d1
	bpl	.da
	moveq	#aeben,d0
	cmp	#-2,d1
	bne	.nda
.da	bsr	assinsert
	bclr	#pfalock,pflags(a3)
	clr	SPA(a3)
.nda
	asl	#2,d3
	move.l	tmdata(a0),a0
	add	Playerdata(a0),a0
	add	d3,a0

	move.b	(a0),rostnum(a3)

	move.b	1(a0),d3
	and	#$f0,d3
	move.b	d3,weight(a3)

	move.b	1(a0),d3
	and.b	#$0f,d3
	move.b	d3,legstr(a3)

	move.b	2(a0),d3
	lsr.b	#4,d3
	move.b	d3,legspd(a3)

	move.b	2(a0),d3
	and.b	#$0f,d3
	eor.b	#$0f,d3
	add.b	#$0f,d3 	;frames to skip
	lsr.b	#1,d3
	move.b	d3,aioff(a3)

	move.b	3(a0),d3
	lsr.b	#4,d3
	eor.b	#$0f,d3
	add.b	#$0f,d3 	;frames to skip
	lsr.b	#1,d3
	move.b	d3,aidef(a3)

	move.b	3(a0),shotspd(a3)
	and.b	#$0f,shotspd(a3)

	move.b	4(a0),handed(a3)
	and.b	#$0f,handed(a3)	;bit 0 set is left handed
	bclr	#3,attribute(a3)
	btst	#0,handed(a3)
	bne	.ha
	bset	#3,attribute(a3)
.ha
	move.b	5(a0),d3
	lsr.b	#4,d3
	move.b	d3,stickhand(a3)

	move.b	5(a0),shotacc(a3)
	and.b	#$0f,shotacc(a3)

	move.b	6(a0),d3
	lsr.b	#4,d3
	move.b	d3,endurance(a3)

	move.b	6(a0),spodds(a3)
	and.b	#$0f,spodds(a3)

	move.b	7(a0),d3
	lsr.b	#4,d3
	move.b	d3,passacc(a3)

	move.b	7(a0),aggress(a3)
	and.b	#$0f,aggress(a3)
	rts
null	dc.l	0
	
VBjsr
	move.l	vbint,-(a7)
	rts
PeriodOver	;what to do if period over
	bsr	forceblack
	add	#1,gsp	;period number
	bchg	#gmdir,gmode
	cmp	#3,gsp
	blt	.sp
	beq	.nop
	move	#3,gsp
	tst	OptPlayMode
	bne	.nop
	move	#4,gsp
.nop	move	tmstruct+tmscore,d0
	sub	tmstruct+tmsize+tmscore,d0
	beq	.sp
	move	#4,gsp
.sp	jsr	ResetClock
	bsr	SetHor
	bsr	SetVideo
	move	#24,palcount
	move	#SngEOG,-(a7)
	bsr	song
	bsr	UpdateScores
	bsr	Intermission
	cmp	#4,gsp
	beq	GameOver
	jmp	StartPer

GameOver
	bsr	EncodePW
	bsr	PlayoffScreen
	cmp	#1,OptPlayMode
	bne	Opening2
	tst	gamenum
	bmi	Opening2
	bclr	#7,PassWord
	bsr	DecodePW
	bsr	MakeTree
	bclr	#sf3alttree,sflags3	;flag for tree with final game count
	bne	Opening3
	bra	Opening4

Opening	
	bsr	KillCrowd	
	bsr	TitleScreen	

Opening2	move	#$2700,SR
	move	#Stack,sp
	move	#varstart,a0
.0	clr.l	(a0)+
	cmp	#varend,a0
	blt	.0
	move.l	#vb2,vbint
	move	#$2500,sr
	bsr	setoptions
Opening3	bsr	PlayoffScreen
Opening4	bsr	ScoutingReport
	jmp	startgame

PlayoffScreen
	;bring up playoff screen if in playoff mode
	tst	OptPlayMode
	beq	rtss

	move.l	#vb2,vbint
	bclr	#df32c,disflags
	move	#$0000,VSCRLPM
	move	#$bc00,VSPRITES
	move	#$b000,VmMap3
	move	#6,Map3col
	move	#$c000,VmMap2
	move	#7,Map2col
	move	#$e000,VmMap1
	move	#7,Map1col	;128 col mode
	move	#$000,d0	;fade to color
	bsr	setvram

	bsr	printz
	String	-$01,0,0
	move.l	#128,d0
	moveq	#28,d1
	moveq	#1,d2
	bsr	eraser

	bsr	printz
	String	-$02,0,0
	move.l	#128,d0
	moveq	#28,d1
	moveq	#1,d2
	bsr	eraser

	bsr	printz
	String	-$03,0,0
	moveq	#40,d0
	moveq	#2,d1
	moveq	#1,d2
	bsr	eraser

	bsr	AddTeamBlock

	move	d4,d1
	move	d1,SmallFontChars
	move.l	#SmallFontMap+8,a0
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	move.l	#.sfmap,a1
	bsr	ReMap

	move	d4,d1
	move	d1,FramerCset
	move.l	#FramerMap+8,a0
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	move.l	#.frmap,a1
	bsr	ReMap

	move.l	#Arrowsmap,a0
	add	#8,a0
	move	d4,extrachars
	move	d4,d1
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMA

	bsr	printz
	string	-$01,60,4
	move.l	#StanleyMap,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	(a2)+,a0
	add.l	(a2)+,a1
	clr	d0
	clr	d1
	moveq	#8,d2
	moveq	#18,d3
	moveq	#%1001,d5
	bsr	dobitmap
	add	(a2),d4

	bsr	printz
	String	-$11,56,26
	bsr	PWprint

	move.l	#Vctrl,a0
	move	#$9202,(a0)

	bsr	printz
	String	-$01,0,0

	move	#potree,a1
	move.l	#.setup,a0
	move	gamelevel,d0
	asl	#1,d0
	add	0(a0,d0),a0
	bsr	getshifter
	add	gamenum,d2
	add	d2,d2
	clr	d4
	move.b	(a0)+,d4
.top	sub	#1,d2
	bpl	.dt0
	cmp	#-2,d2
	beq	.dt1
	clr.l	d3
	move.b	(a0),d3
	swap	d3
	move.b	1(a0),d3
	bra	.dt0
.dt1	sub	#1,d3
	move	d3,printy
	clr	d1
	move.b	1(a0),d1
	sub	d3,d1
	add	#3,d1
	swap	d3
	sub	#1,d3
	move	d3,printx
	clr	d0
	move.b	(a0),d0
	sub	d3,d0
	add	#14,d0
	move	printm,-(a7)
	move	printa,-(a7)
	move	#4,printm
	move	#$6000,printa
	bsr	framer
	move	(a7)+,printa
	move	(a7)+,printm
.dt0	move.b	(a0)+,printx+1
	move.b	(a0)+,printy+1
	clr	d1
	move.b	(a1)+,d1
	add	d1,d1
	bsr	.doteam
	dbf	d4,.top

	clr	d4
	move.b	(a0)+,d4
.top2	move.b	(a0)+,printx+1
	move	#2,printy
	clr	d0
	move.b	(a0)+,d0
	bsr	.doarrow
	dbf	d4,.top2

	bsr	printz
	String	-$11,0,0
	cmp	#7,bosgames
	beq	.noscr
	clr	d4
	move.b	(a0)+,d4
	bmi	.noscr
	move	#gstruct,a2
.top3	move.b	(a0)+,printx+1
	move.b	(a0)+,printy+1
	bsr	.doscores
	add	#gssize,a2
	dbf	d4,.top3
.noscr
	cmp	#4,gamelevel
	bne	.nosharks
	tst	pojoy
	bne	.nosharks
	cmp.b	#16,potree+16+8+4+2
	bne	.nosharks
	bsr	printz
	String	-$11,64-14,26,'The Fierce Fish Win the Cup!'
.nosharks
	move	#24,palcount
	move	#SngPO,-(a7)
	bsr	song

	clr	d0
	clr	d4
	move	#-44*8,d5
	bsr	.scrup

.input	bsr	Waitxc1
	bsr	.jin
	bra	.input

.jin	btst	#sbut,d1
	bne	.exit
	moveq	#1,d0
	btst	#rbut,d1
	bne	.scrup
	neg	d0
	btst	#lbut,d1
	beq	.nope
.scrup
	add	d4,d0
	cmp	gamelevel,d0
	bgt	.nope
	neg	d0
	cmp	gamelevel,d0
	bgt	.nope
	neg	d0
	cmp	#3,d0
	bgt	.nope
	cmp	#-3,d0
	blt	.nope
	move	d0,d4
	bsr	.pmore
.nope
	move	d4,d0
	asl	#1,d0
	move.l	#.slimit+6,a0
	add	d0,a0

	moveq	#2,d1
	cmp	(a0),d5
	beq	.zero
	blt	.z0
	neg	d1
.z0	add	d1,d5
.zero

	move	disflags,-(a7)
	bset	#dfng,disflags
	move	VSCRLPM,d0
	bsr	Vmaddr
	move	d5,(a0)
	move	d5,(a0)
	move	(a7)+,disflags
	rts

.exit	add	#4,a7
	rts

	;possible scroll ending points based on playoff level
.slimit	dc.w	-(44-44)*8,-(44-30)*8,-(44-15)*8,-44*8,-(44+15)*8,-(44+30)*8,-(44+44)*8

.pmore	bsr	printz
	String	-$13,20,1
	clr	d1
	tst	gamelevel
	beq	.px
	move	d4,d0
.p0	add	#1,d1
	cmp	gamelevel,d0
	beq	.px
	cmp	#3,d0
	beq	.px
	neg	d0
	cmp	#2,d1
	bne	.p0
	add	#1,d1
.px	move.l	#.pli,a1
.px0	add	(a1),a1
	dbf	d1,.px0
	move	(a1),d0
	lsr	#1,d0
	sub	d0,printx
	bra	print

.pli
    ;String	
	String $D4 ; Had to pass $D4 as a parameter to the String macro to match orignal rom						
	String	'                    '
	String	'  Press [ to page   '
	String	'  Press ] to page   '
	String	'Press [ or ] to page'	


.doscores
	move	#mesarea,a1
	move	#6,(a1)+
	move	gspotwins(a2),d0
	add	#'0',d0
	move.b	d0,(a1)+
	move.b	#'-',(a1)+
	move	gspobwins(a2),d0
	add	#'0',d0
	move.b	d0,(a1)+
	clr.b	(a1)+
	move	#mesarea,a1
	bra	print

.doarrow	movem.l	d0-d7/a0-a3,-(a7)
	move.l	#Arrowsmap,a0
	move.l	a0,a1
	add.l	(a0),a0
	add.l	4(a1),a1
	move.l	#null,a2
	clr	d1
	moveq	#2,d2
	moveq	#23,d3
	move	extrachars,d4
	moveq	#%0100,d5
	bsr	dobitmap
	movem.l	(a7)+,d0-d7/a0-a3
	rts

.doteam	movem.l	d0-d7/a0-a3,-(a7)
	move.l	#TeamBlocksmap,a0
	move.l	a0,a1
	add.l	(a0),a0
	add.l	4(a1),a1
	move.l	#null,a2
	clr	d0
	moveq	#13,d2
	moveq	#2,d3
	moveq	#2,d4
	moveq	#%0010,d5
	bsr	dobitmap
	movem.l	(a7)+,d0-d7/a0-a3
	rts

.frmap	dc.b	0,2,1,0
.sfmap	dc.b	0,1,7,0

.setup
	dc.w	.l0-.setup
	dc.w	.l1-.setup
	dc.w	.l2-.setup
	dc.w	.l3-.setup
	dc.w	.l4-.setup

	;tree graphics for level 0
.l0	dc.b	16-1
	dc.b	45,2,45,5,45,8,45,11,45,14,45,17,45,20,45,23
	dc.b	70,2,70,5,70,8,70,11,70,14,70,17,70,20,70,23
	dc.b	1,58,0,68,10
	dc.b	7,50,4,50,10,50,16,50,22,75,4,75,10,75,16,75,22

	;tree graphics for level 1
.l1	dc.b	16+8-1	
	dc.b	30,2,30,5,30,8,30,11,30,14,30,17,30,20,30,23
	dc.b	85,2,85,5,85,8,85,11,85,14,85,17,85,20,85,23
	dc.b	45,4,45,10,45,15,45,21
	dc.b	70,4,70,10,70,15,70,21
	dc.b	3,43,0,58,2,68,8,83,10
	dc.b	3,50,8,50,18,75,8,75,18

	;tree graphics for level 2
.l2	dc.b	16+8+4-1	
	dc.b	15,2,15,5,15,8,15,11,15,14,15,17,15,20,15,23
	dc.b	100,2,100,5,100,8,100,11,100,14,100,17,100,20,100,23
	dc.b	30,4,30,10,30,15,30,21
	dc.b	85,4,85,10,85,15,85,21
	dc.b	45,7,45,18
	dc.b	70,7,70,18
	dc.b	5,28,0,43,2,58,4,68,6,83,8,98,10
	dc.b	1,50,13,75,13

	;tree graphics for level 3
.l3	dc.b	16+8+4+2-1	
	dc.b	0,2,0,5,0,8,0,11,0,14,0,17,0,20,0,23
	dc.b	115,2,115,5,115,8,115,11,115,14,115,17,115,20,115,23
	dc.b	15,4,15,10,15,15,15,21
	dc.b	100,4,100,10,100,15,100,21
	dc.b	30,7,30,18
	dc.b	85,7,85,18
	dc.b	45,12
	dc.b	70,12
	dc.b	5,13,0,28,2,43,4,83,6,98,8,113,10
	dc.b	0,62,23

	;tree graphics for level 4
.l4	dc.b	16+8+4+2+1-1	
	dc.b	0,2,0,5,0,8,0,11,0,14,0,17,0,20,0,23
	dc.b	115,2,115,5,115,8,115,11,115,14,115,17,115,20,115,23
	dc.b	15,4,15,10,15,15,15,21
	dc.b	100,4,100,10,100,15,100,21
	dc.b	30,7,30,18
	dc.b	85,7,85,18
	dc.b	45,12
	dc.b	70,12
	dc.b	58,23
	dc.b	5,13,0,28,2,43,4,83,6,98,8,113,10
	dc.b	-1
	dc.b	$FF

ScoutingReport
	;bring up graphic for scouting report screen
	bsr	SetTeams

	bclr	#df32c,disflags
	move	#6,map1col
	move	#6,map2col
	move	#$000,d0	;fade to color
	bsr	setvram

	move.l	#Vdata,a0
	move	#$9011,4(a0)

	bsr	AddTeamBlock
	bsr	AddSmallFont

	bsr	printz
	string	-$02,0,0
	move.l	#ScoutMap,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	(a2)+,a0
	add.l	(a2)+,a1
	clr	d0
	clr	d1
	moveq	#40,d2
	moveq	#28,d3
	moveq	#%1111,d5
	bsr	dobitmap
	add	(a2),d4

	bsr	printz
	String	-$01,3,6
	move	VisTeam,d1
	bsr	DoTb

	bsr	printz
	String	-$01,24,6
	move	HomeTeam,d1
	bsr	DoTb

	bsr	printz
	String	-$21,21,8
	bsr	.checks

	bsr	printz
	String	-$21,21,8
	move.l	#.pnm,a1
.pl	move	(a1),d0
	asr	#1,d0
	neg	d0
	add	#21,d0
	move	d0,printx
	bsr	print
	add	#1,printy
	tst	2(a1)
	bpl	.pl

	move	#-32*8,Vscroll
	clr	Hscroll
	move	#24,palcount
	move.l	#vb2,vbint
	move	#$2500,sr

.top	bsr	.wait
	bsr	SetScroll1
	add	#1,Vscroll
	cmp	#1,Vscroll
	bne	.top
	move	#40*60,d0
	bra	waitx

.wait	movem.l	d0-d7,-(a7)
	move	vcount,d0
.0	cmp	vcount,d0
	beq	.0
	bsr	orjoy
	btst	#sbut,d1
	movem.l	(a7)+,d0-d7
	beq	rtss
	add	#4,a7
	rts

.checks
	move.l	#.weights,a2
.ctop	clr	d0	;line number *8
	move	VisTeam,d1
	bsr	.addup
	move	d3,-(a7)
	clr	d0
	move	HomeTeam,d1
	bsr	.addup
	sub	(a7)+,d3
	bsr	.dp

	add	#22,a2
	tst	(a2)
	bpl	.ctop

	moveq	#16,d0
	move	VisTeam,d1
	bsr	.addup
	move	d3,-(a7)
	moveq	#8,d0
	move	VisTeam,d1
	bsr	.addup
	add	d3,(a7)
	moveq	#16,d0
	move	HomeTeam,d1
	bsr	.addup
	sub	d3,(a7)
	moveq	#8,d0
	move	HomeTeam,d1
	bsr	.addup
	sub	(a7)+,d3

.dp	move.l	#.clist,a1
	clr	d1
	move	2(a2),d0
.c1	cmp	d0,d3
	bgt	.dc
	neg	d0
	add	#1,d1
	cmp	d0,d3
	blt	.dc
	move	4(a2),d0
	add	#1,d1
	cmp	#2,d1
	beq	.c1
	bra	.dc
.dc0	add	(a1),a1
.dc	dbf	d1,.dc0
	move	(a1),d0
	lsr	#1,d0
	neg	d0
	add	#21,d0
	move	d0,printx
	bsr	print
	add	#1,printy
	rts

.addup	asl	#2,d1
	move.l	#TeamList,a1
	move.l	0(a1,d1),a1
	move.l	a1,a3
	add	PlayerData(a3),a3
	add	LineSets(a1),a1
	add	d0,a1
	clr	d3
	move	(a2),d4
	bpl	.au0
	moveq	#5,d4
.au0	clr	d0
	move.b	0(a1,d4),d0
	asl	#3,d0
	lea	-8(a3,d0),a0
	moveq	#15,d1
.topc	clr	d2
	move.b	6(a2,d1),d2
	beq	.nextc
	move	d1,d0
	lsr	#1,d0
	move.b	(a0,d0),d0
	btst	#0,d1
	bne	.c0
	lsr	#4,d0
.c0	and	#$f,d0
	mulu	d2,d0
	add	d0,d3
.nextc	dbf	d1,.topc
	tst	(a2)
	bpl	rtss
	dbf	d4,.au0
	rts

.weights	;position,double check limit,check limit,...weight per nibble...
	dc.w	0,80,20,$0000,$0303,$0000,$0000,$0001,$0101,$0101,$0100
	dc.w	4,100,25,$0000,$0003,$0302,$0102,$0100,$0202,$0001,$0100
	dc.w	3,90,20,$0000,$0002,$0202,$0102,$0100,$0102,$0001,$0200
	dc.w	5,90,20,$0000,$0002,$0202,$0102,$0100,$0102,$0001,$0200
	dc.w	1,115,35,$0000,$0103,$0301,$0201,$0300,$0201,$0001,$0201
	dc.w	2,115,35,$0000,$0103,$0301,$0201,$0300,$0201,$0001,$0201

	dc.w	-1,500,200,$0000,$0003,$0301,$0101,$0200,$0201,$0001,$0200

.pnm	String	'Goalie'
	String	'Center'
	String	'Left Wing'
	String	'Right Wing'
	String	'Left Defenseman'
	String	'Right Defenseman'
	String	'Line Depth'
	String	-1

.clist	;* = check mark graphic
	String	'                    **'
	String	'**                    '
	String	'                     *'
	String	'*                     '
	String	'*                    *'


;.frmap	dc.b	0,15,8,0
.sfmap	dc.b	0,1,2,0	;remap data for colors

TitleScreen
	;bring up title screen and credits	
	move.l	#vb2,vbint
	bset	#df32c,disflags	
	move	#$0000,VSCRLPM
	move	#$b400,VSPRITES
	move	#$b800,VmMap3
	move	#5,Map3col
	move	#$c000,VmMap2
	move	#7,Map2col
	move	#$e000,VmMap1
	move	#7,Map1col

	move	#$000,d0	;fade to color		
	bsr	setvram
	
	bsr	printz
	String	-$01,0,0
	move.l	#128,d0
	moveq	#32,d1
	moveq	#1,d2
	bsr	eraser

	bsr	printz
	String	-$03,0,0
	moveq	#32,d0
	moveq	#32,d1
	moveq	#1,d2
	bsr	eraser

	moveq	#2,d4
	move	#framelist,a0
	move.l	#PuckSprites,a1
	bsr	Buildframelist
	move	d4,d1
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMA

	bsr	AddSmallFont

	bsr	printz
	string	-$02,0,0
	move.l	#Title1Map,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	(a2)+,a0
	add.l	(a2)+,a1
	clr	d0
	clr	d1
	moveq	#32,d2
	moveq	#28,d3
	moveq	#%1111,d5
	bsr	dobitmap
	add	(a2),d4

	bsr	printz
	String	-$01,1,14
	move.l	#Title2Map,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	(a2)+,a0
	add.l	(a2)+,a1
	clr	d0
	clr	d1
	moveq	#30,d2
	moveq	#8,d3
	moveq	#%0000,d5
	movem.l	d0-d5/a1,-(a7)
	bsr	dobitmap
	bsr	printz
	String	-$03,1,14
	movem.l	(a7)+,d0-d5/a1
	move	(a2),-(a7)
	move.l	#null,a2
	bsr	dobitmap
	add	(a7)+,d4

	bsr	printz
	String	-$31,44,24,'$ 1991 Electronic Arts',-$31,50,25,'Licensed by',-$31,45,26,'Sega Enterprises Ltd.'

	move	d4,d1
	move.l	#NHLSpinMap+8,a0
	move	(a0)+,d0
;	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMA

	move	#SngTitle,-(a7)
	bsr	Song

	move.l	#Vdata,a0
	move	#$9100,4(a0)
	move	#$920d,4(a0)
	clr	Vscroll
	move	#-40*8,Hscroll
	bsr	SetScroll1

	move	#24,palcount
	move.l	#vb2,vbint
	move	#$2500,sr

	move	#128+340,puckx
	move	#128+24,pucky

	clr	Deltax
	move	#16,Deltay
	clr	fox
.top1	bsr	.wait	;slide puck left and start spinner
	sub	#3,puckx
	bsr	.SetPuck
	cmp	#128+30,puckx
	bgt	.top1
	bsr	.setspinner
	cmp	#128-60,puckx
	bgt	.top1

	move	#3*60,d5
.tops	bsr	.wait
	bsr	.setspinner
	dbf	d5,.tops

	move	#128+(14*8),pucky
.top2	bsr	.wait	;slide puck right with HOCKEY
	bsr	.SetSpinner
	bsr	.SetPuck
	add	#3,puckx
	add	#3,Hscroll
	bsr	SetScroll1
	tst	Hscroll
	blt	.top2

	move.l	#Vdata,a0
	move	#$9200+22,4(a0)
	clr	Hscroll
	clr	Vscroll

	move	#6*60,d0
.top3	bsr	.wait
	tst	fox
	beq	.next
	bsr	.setspinner
.next	dbf	d0,.top3

	move	#palfadenew,a0
	moveq	#3*16-1,d0
.p0	clr	(a0)+
	dbf	d0,.p0
	move	#6,palcount

	bsr	printz
	String	-$31,0,0
	move.l	#Credits,a1
.top4	move	Vscroll,d0
	asr	#3,d0
	add	#28,d0
	and	#31,d0
	move	d0,printy
	move	d0,-(a7)
	clr	printx
	moveq	#32,d0
	moveq	#6,d1
	moveq	#1,d2
	bsr	eraser
	move	(a7)+,printy

.top4x	move	(a1),d0
	asr	#1,d0
	neg	d0
	add	#16,d0
	move	d0,printx
	bsr	print
	add	#1,printy
	and	#31,printy
	tst	2(a1)
	bpl	.top4x
	add	(a1),a1

	moveq	#6*8-1,d4
.top5	bsr	.wait
	bsr	.wait
	add	#1,Vscroll
	bsr	SetScroll1
	dbf	d4,.top5
	move.l	#4*60,d4
.top6	bsr	.wait
	dbf	d4,.top6
	tst	2(a1)
	bpl	.top4
	rts

.setspinner	sub	#16,Deltax
	bpl	rtss
	move	Deltay,d1
	add	d1,Deltax
	add	#1,Deltay
	add	#1,fox
	cmp	#8,fox
	blt	.sets0
	clr	fox
.sets0	movem.l	d0-d7,-(a7)
	bsr	printz
	String	-$03,1,1
	clr	d0
	moveq	#12,d1
	mulu	fox,d1
	moveq	#11,d2
	moveq	#12,d3
	moveq	#%0000,d5
	move.l	#NHLSpinMap,a1
	add.l	4(a1),a1
	move.l	#null,a2
	bsr	DoBitMap
	movem.l	(a7)+,d0-d7
	rts

.SetPuck	
	move.l	#Satt,a6
	moveq	#1,d6	;link counter
	move	#FrameList,a0
	move	puckx,d0
	move	pucky,d1
	moveq	#1,d2
	moveq	#2,d3
	bsr	SetSFrame

	clr.b	3-8(a6)	;end sprite list
	move.l	a6,d0
	move.l	#Satt,a0
	sub.l	a0,d0
	move	VSPRITES,d1
	bra	DoDMAPro

.wait	movem.l	d0-d7,-(a7)
	move	vcount,d0
.0	cmp	vcount,d0
	beq	.0
	bsr	orjoy
	btst	#sbut,d1
	movem.l	(a7)+,d0-d7
	beq	rtss
	add	#4,a7
	rts

setoptions
	;options screen display and input
	move	#$2500,sr
	move.l	#vb2,vbint
	bset	#dfng,disflags
	bclr	#df32c,disflags
	move	#$0000,VSCRLPM
	move	#$b400,VSPRITES
	move	#$b800,VmMap3
	move	#5,Map3col
	move	#$c000,VmMap2
	move	#6,Map2col
	move	#$e000,VmMap1
	move	#6,Map1col
	move	#$000,d0	;fade to color
	bsr	setvram

	bsr	orjoy

	bsr	AddTeamBlock
	bsr	AddFramer
	bsr	AddSmallFont

	bsr	printz
	string	-$02,0,0
	moveq	#40,d0
	moveq	#28,d1
	moveq	#1,d2
	bsr	eraser

	bsr	printz
	string	-$01,0,0
	move.l	#GameSetUpMap,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	(a2)+,a0
	add.l	(a2)+,a1
	clr	d0
	clr	d1
	moveq	#40,d2
	moveq	#28,d3
	moveq	#%1101,d5
	bsr	dobitmap
	add	(a2),d4

	move	d4,faceoffvrcset	;face off players used on game setup screen
	move.l	#FaceOffframelist,a0
	move.l	#FaceOffsprites,a1
	bsr	Buildframelist
	move	d4,d1
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMA

	move.l	#Satt,a6
	moveq	#1,d6	;link counter
	clr	d0
	move	#90,fodropx
	move	#60,fodropy
	move.l	#fofdata,a3
	move	#2,(a3)
	move	#$a000,2(a3)
	bsr	checkfo2
	clr	d0
	move	#230,fodropx
	move	#2,(a3)
	move	#$8800,2(a3)
	bsr	checkfo2

	clr.b	3-8(a6)	;end sprite list
	move.l	a6,d0
	move.l	#Satt,a0
	sub.l	a0,d0
	move	VSPRITES,d1
	bsr	DoDMA

	move.l	#.text,a1	;options static text
.textlp	bsr	print
	tst.b	2(a1)
	bne	.textlp

	st	demoflag
	cmp	#2,OptPlayMode
	blt	.nopo
	bsr	NewPO
.nopo	clr	d7
	clr	d0
	bsr	.nms
	bsr	.ps
	move	#24,palcount
	bsr	forcefade
	bclr	#dfng,disflags	;fade in graphics now
;----------
.top	;loop wait for input
	move	#40*60,d0	;delay after last button press for demo
	bsr	waitx
	tst	d1
	beq	.demo
	bsr	NoDiag
	bra	.nd

.demo	clr	demoflag
	move	HVcount,seed
	move	HVcount,seed+2

.newdemo	clr	OptPlayMode
	clr	OptNOP
.ex
	move	OptNOP,POJoy
	sub	#5,POJoy
	move	HVcount,seed	;random seed hopefully
	move	HVcount,seed+2
	cmp	#1,OptPlayMode
	bne	.ex2
	bsr	GetPassWord
.ex2	bset	#7,PassWord	;don't show password on playoff tree
	bra	MakeTree

.nd
	btst	#sbut,d1
	bne	.ex
	btst	#dbut,d1
	beq	.2
	moveq	#2,d0
	bsr	.nms	;new menu line selected
	bsr	.ps	;print screen
	bra	.top

.2	btst	#ubut,d1
	beq	.3
	moveq	#-2,d0
	bsr	.nms	;new menu line
	bsr	.ps	;print screen
	bra	.top
.3
	moveq	#1,d2
	btst	#rbut,d1
	bne	.4
	btst	#lbut,d1
	beq	.top
	moveq	#-1,d2
.4	bsr	.IncItem	;change item
	bsr	.ps	;print screen
	bra	.top

.IncItem	;add d2 to current item
	move	#optionsmenu,a2
	move.l	#.pslim,a3
	clr	d5
	move	0(a3,d7),d4
	move	0(a2,d7),d3
	cmp	#2,OptPlayMode
	blt	.ii0
	cmp	#4,d7
	bne	.ii0
	moveq	#NumOfTeams-2,d4
.ii0	cmp	#2,d7
	bne	.ii1
	moveq	#5,d5
	tst	OptPlayMode
	bne	.ii1
	clr	d5
	moveq	#5,d4
.ii1	bsr	.iilimit
	move	d3,0(a2,d7)
	tst	d2
	beq	rtss
	cmp	#2,OptPlayMode
	blt	rtss
	tst	d7
	beq	NewPo
	cmp	#4,d7
	beq	NewPo
	rts

.iilimit	add	d2,d3
	cmp	d5,d3
	bge	.iil1
	move	d4,d3
	subq	#1,d3
.iil1	cmp	d4,d3
	blt	rtss
	move	d5,d3
	rts

.ps	;print choices and show team icons/colors
	move	d7,d6
	moveq	#-2,d7
.pstop
	add	#2,d7
	clr	d2
	bsr	.IncItem
	bsr	.psd
	cmp	#(menuitems-1)*2,d7
	bne	.pstop
	move	d6,d7
	bra	TeamIcons
.psd
	bsr	printz
	String	-$01,16,11
	add	d7,printy
	move.l	#.blank,a1
	bsr	print
	move	#16,printx
	bsr	.cpo
	cmp	#4,d7
	beq	.psdtp
	cmp	#6,d7
	beq	.psdtp
	move.l	#optionsmenu,a0
	move	0(a0,d7),d3
	move.l	#.pl,a0
	add	0(a0,d7),a0
.psd3	move.l	a0,a1
	add	(a0),a0
	dbf	d3,.psd3
	bra	print
.psdtp
	move.l	#optionsmenu,a1
	move	0(a1,d7),d3
	move.l	#TeamList,a1
	asl	#2,d3
	move.l	0(a1,d3),a1
	lsr	#2,d3
	add	TeamName(a1),a1
	bra	print

.cpo	;continue playoffs
	cmp	#1,OptPlayMode
	bne	rtss
	tst	d7
	beq	rtss
	cmp	#6,d7
	bhi	rtss
	add	#4,a7
	bsr	printz
	String	'Playoffs'
	move.l	#Palfadenew+$20,a0
	moveq	#$30-1,d0
	move	-$2(a0),d1
.cpo0	move	d1,(a0)+
	dbf	d0,.cpo0
	rts

.nms	;next menu by d0
	move	d7,d3
.nms0	add	d0,d7
	bpl	.nms1
	clr	d7
.nms1	cmp	#menuitems*2,d7
	blt	.nms2
	sub	d0,d7
.nms2	cmp	#1,OptPlayMode
	bne	.nms3
	tst	d7
	beq	.nms3
	cmp	#6,d7
	bls	.nms0
.nms3	cmp	#2,OptPlayMode
	blt	.nms4
	cmp	#6,d7
	beq	.nms0
.nms4
	bsr	.setrect
	moveq	#1,d2
	bsr	eraser
	move	d7,d3
	bsr	.setrect
	bra	framer

.setrect	;set rectangle cords for framing
	move	#$0000,printa
	move	#4,printm
	move	#15,printx
	move	#10,printy
	add	d3,printy
	moveq	#24,d0
	moveq	#3,d1
	cmp	#2,OptPlayMode
	blt	rtss
	cmp	#4,d3
	bne	rtss
	moveq	#5,d1
	rts

.blank
	string	'                      '
;limit of each item
	dc.w	0
.pslim	dc.w	4,8,NumofTeams,NumofTeams,3,3,2

;menu item names
.pl
	dc.w	.pl0-.pl
	dc.w	.pl1-.pl
	dc.w	.pl2-.pl
	dc.w	.pl3-.pl
	dc.w	.pl4-.pl
	dc.w	.pl5-.pl
	dc.w	.pl6-.pl	

.pl0	STRING	'Regular Season'
	STRING	'Continue Playoffs'
	String	'New Playoffs'
	String	'New Playoffs/Best of 7'

.pl1
	String	'Demo'
	String	'One - Home'
	String	'One - Visitor'
	String	'Two - Teammates'
	String	'Two - Head to Head'

	String	'One'
	String	'Two - Teammates'
	String	'Two - Head to Head'
.pl2
.pl3
.pl4	STRING	'5 Minutes'
	STRING	'10 Minutes'
	STRING	'20 Minutes'       
	STRING	'30 Seconds'
       
.pl5
	String	'Off'
	String	'On'
	String	'On, Except Off-sides'
.pl6
	STRING	'On'
	STRING	'Off'

.text	;static text
	STRING	-$01,2,11,'Play Mode'
	STRING	-$01,2,13,'Players'
	String	-$01,2,15,'Team 1'
	String	-$01,2,17,'Team 2'
	String	-$01,2,19,'Per. Length'
	STRING	-$01,2,21,'Penalties'
	STRING	-$01,2,23,'Line Changes'	
	String	0

TeamIcons	;draw team name bars and set colors
	movem.l	d0-d7/a0-a2,-(a7)
	tst	OptPlayMode
	bne	.0
	move	Opt1Team,HomeTeam
	move	Opt2Team,VisTeam
.0	cmp	#1,OptPlayMode
	beq	.ex
	bsr	printz
	String	-$02,3,8
	move	VisTeam,d1
	bsr	dotb
	bsr	printz
	String	-$02,24,8
	move	HomeTeam,d1
	bsr	dotb
	bsr	setteams
	bsr	setplayercolors
.ex	move	#24,palcount
	movem.l	(a7)+,d0-d7/a0-a2
	rts

dotb	;draw team name bar d1 = team number
	clr	d0
	asl	#1,d1
	move.l	#TeamBlocksmap,a0
	move.l	a0,a1
	add.l	(a0),a0
	add.l	4(a1),a1
	move.l	#null,a2
	moveq	#13,d2
	moveq	#2,d3
	move	#$8002,d4
	moveq	#%0010,d5
	bra	dobitmap

DefaultMenus	;set default menu choices for beginning of game
	move.l	#optionsmenu,a0
	move.l	#.defom,a1
	move	#menuitems-1,d0
.1	move	(a1)+,(a0)+
	dbf	d0,.1
	rts
.defom	dc.w	0,1,14,8,1,0,1

NewPO	;new playoff generates tree with same team 1 
	moveq	#32,d0
	bsr	randomd0
.top	add	#1,d0
	and	#31,d0
	asl	#4,d0
	move.l	#playoffseats,a0
	add	d0,a0
	lsr	#4,d0
	moveq	#15,d1
	move	Opt1Team,d2
	cmp	#NumOfTeams-3,d2
	bls	.loop
	moveq	#NumOfTeams-3,d2
.loop	cmp.b	(a0)+,d2
	dbeq	d1,.loop
	bne	.top
	eor	#15,d1
	move	d1,potreeteam
	move	d0,postarts
	clr	gamelevel
	move	#7,bosgames
	cmp	#2,OptPlayMode
	beq	.n0
	clr	bosgames
	moveq	#7,d0	;clr games won
	move	#gstruct,a0
.cg	clr	gspotwins(a0)
	clr	gspobwins(a0)
	add	#gssize,a0
	dbf	d0,.cg
.n0
;	bra	maketree

MakeTree	;make playoff tree (potree) from playoffseats/winbits
	movem.l	d0-d4/a0-a3,-(a7)
	move	postarts,d1
	asl	#4,d1
	move	#potree,a0
	move.l	#playoffseats,a1
	add	d1,a1
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)
	move.l	12(a1),12(a0)
	lea	16(a0),a1
	moveq	#14,d2
	move	WinBits,d0
.0	move	d0,d1
	and	#1,d1
	move.b	0(a0,d1),(a1)+
	add	#2,a0
	lsr	#1,d0
	dbf	d2,.0

	bsr	GetShifter
	tst	d1
	bmi	.nogames
	move	#potree,a0
	add	d2,a0
	add	d2,a0
	move	#gstruct,a1
.2	clr	gss1(a1)
	clr	gss2(a1)
	clr	gsper(a1)
	bclr	#gsfhl,gsflags(a1)
	bsr	.sett
	add	#gssize,a1
	dbf	d1,.2
	bsr	FigureJoy
.nogames	movem.l	(a7)+,d0-d4/a0-a3
	rts

.sett	cmp	#2,bosgames
	beq	.flip
	cmp	#3,bosgames
	beq	.flip
	cmp	#5,bosgames
	beq	.flip
	bset	#gsftf,gsflags(a1)
	move.b	(a0)+,gst2+1(a1)
	move.b	(a0)+,gst1+1(a1)
	rts
.flip	bclr	#gsftf,gsflags(a1)
	move.b	(a0)+,gst1+1(a1)
	move.b	(a0)+,gst2+1(a1)
	rts

FigureJoy	;set cont1team/cont2team appropriately
	clr	cont1team
	clr	cont2team
	tst	demoflag
	beq	rtss
	tst	OptPlaymode
	beq	.fjnpo
	bsr	GetShifter
	move	#potree,a0
	move	potreeteam,d2
	move.b	0(a0,d2),d2	;po team
	move	#gstruct,a1
	moveq	#gssize,d4
	mulu	d1,d4
	add	d4,a1
	st	gamenum
	clr	d0
.f0	cmp	gst1(a1),d2
	beq	.it1
	cmp	gst2(a1),d2
	beq	.it2
	sub	#gssize,a1
	dbf	d1,.f0
	rts	;po team not in playoffs

.it2	moveq	#4,d0
	move	gst1(a1),Opt2team
	bra	.itx
.it1	clr	d0
	move	gst2(a1),Opt2team
.itx	add	pojoy,d0
	move	d1,gamenum
	move	gst1(a1),HomeTeam
	move	gst2(a1),VisTeam
	asl	#2,d0
	move.l	#.pojoylist,a0
	move	0(a0,d0),cont1team
	move	2(a0,d0),cont2team
	rts

.pojoylist	dc.w	1,0
	dc.w	1,1
	dc.w	1,2
	dc.w	2,1

	dc.w	2,0
	dc.w	2,2
	dc.w	2,1
	dc.w	1,2

.fjnpo	move	OptNOP,d0
	asl	#2,d0
	move.l	#.Noplist,a0
	move	0(a0,d0),cont1team
	move	2(a0,d0),cont2team
	rts

.noplist
	dc.w	0,0
	dc.w	1,0
	dc.w	2,0
	dc.w	1,1
	dc.w	1,2

GetPassWord	;bring up password screen and get input
	bclr	#7,PassWord
	move	#$000,d0	;fade to color
	bsr	setvram

	bsr	orjoy

	moveq	#2,d4	;char allocation
	bsr	AddFramer
	bsr	AddSmallFont

	bsr	printz
	string	-$02,0,0
	moveq	#40,d0
	moveq	#28,d1
	moveq	#1,d2
	bsr	eraser

	bsr	printz
	string	-$01,0,0
	move.l	#GameSetUpMap,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	(a2)+,a0
	add.l	(a2)+,a1
	clr	d0
	clr	d1
	moveq	#40,d2
	moveq	#28,d3
	moveq	#%1101,d5
	bsr	dobitmap
	add	(a2),d4
	
	bsr	printz
	String	-$02,1,18
	moveq	#20,d0
	moveq	#5,d1
	bsr	framer

	move.l	#.text,a1
.textlp	bsr	print
	tst.b	2(a1)
	bne	.textlp

	move.l	#PasstoText,a0	;text chars used in password
	moveq	#4,d0	;number of rows
.top2	moveq	#5,d1	;number of columns
	move	#MesArea,a1
	move	#14,(a1)+
.top1	move.b	(a0)+,(a1)+
	move.b	#' ',(a1)+
	dbf	d1,.top1
	move	#MesArea,a1
	bsr	print
	add	#2,printy
	sub	#12,printx
	dbf	d0,.top2
	move	#24,palcount

	clr	d4
	clr	d5
	bsr	.setd4
	bsr	.setd5
	bsr	framer

.topx	bsr	printz
	String	-$01,3,19,'D Pad - Select'
	bsr	printz
	String	-$01,3,20,'    C - Next'
	bsr	printz
	String	-$01,3,21,'    A - Back'

.input	bsr	printz
	String	-$01,3,16
	bsr	PWprint
	bsr	WaitJoy
	btst	#sbut,d1
	bne	.exit
	moveq	#-1,d0
	btst	#abut,d1
	bne	.pwl
	neg	d0
	btst	#cbut,d1
	bne	.pwl
	btst	#rbut,d1
	bne	.pws
	neg	d0
	btst	#lbut,d1
	bne	.pws
	moveq	#6,d0
	btst	#dbut,d1
	bne	.pws
	neg	d0
	btst	#ubut,d1
	bne	.pws
	bra	.input

.pwl	add	d4,d0
	cmp	#PWlength-1,d0
	bhi	.input
	move	d0,d4
	bsr	.setd4
	move.l	#PassWord,a0
	clr	d0
	cmp.b	#pwrange-1,0(a0,d4)
	bhi	.pws
	move.b	0(a0,d4),d0
	ext	d0
	sub	d5,d0
.pws	add	d5,d0
	cmp	#pwrange-1,d0
	bhi	.input
	move	d0,-(a7)
	bsr	.setd5
	moveq	#1,d2
	bsr	eraser
	move	(a7)+,d5
	bsr	.setd5
	bsr	framer
	move.l	#PassWord,a0
	move.b	d5,0(a0,d4)
	bra	.input

.setd4	bsr	printz
	String	-$02,2,17
	add	d4,printx
	bsr	printz
	String	' < '	;underline char
	rts

.setd5	bsr	printz	;draw frame around char number d5
	String	-$02,21,11
	move	d5,d0
	ext.l	d0
	divu	#6,d0
	asl	#1,d0
	add	d0,printy
	swap	d0
	asl	#1,d0
	add	d0,printx
	moveq	#3,d0
	moveq	#3,d1
	rts

.exit	bsr	DecodePW
	tst	PoStarts
	bpl	rtss	;no error so exit

	bsr	printz
	String	-$01,3,19,'Invalid Password'
	bsr	printz
	String	-$01,3,20,'C - Retry     '
	bsr	printz
	String	-$01,3,21,'A - Set-Up Screen'
.notok	bsr	waitjoy
	btst	#abut,d1
	bne	Opening2
	btst	#cbut,d1
	beq	.notok
	
	bsr	printz
	String	-$01,1,18
	moveq	#20,d0
	moveq	#5,d1
	moveq	#1,d2
	bsr	eraser
	bra	.topx

.text
	STRING	-$01,3,14,'Password',-$01,22,12
	String	0

DecodePW	;translate char password in PassWord to variables used in game
	bsr	PWtoBits
;	bra	ReadPassBits
ReadPassBits
	move	#512,d0
	bsr	SuperDiv
	move	d0,-(a7)	;checksum

	clr	d7	;set gspobwins/gspotwins
	moveq	#7,d2
	move	#gstruct+(7*gssize),a1
.0	bclr	#gsfso,gsflags(a1)
	moveq	#5,d0
	bsr	.sd
	move	d0,gspobwins(a1)
	cmp	#4,d0
	bne	.nsf0
	bset	#gsfso,gsflags(a1)
.nsf0
	moveq	#5,d0
	bsr	.sd
	move	d0,gspotwins(a1)
	cmp	#4,d0
	bne	.nsf1
	bset	#gsfso,gsflags(a1)
.nsf1
	sub	#gssize,a1
	dbf	d2,.0

	;move	#2^14,d0	;set winbits
	move	#1<<14,d0	;set winbits
	bsr	.sd
	move	d0,WinBits

	moveq	#4,d0	;set POJoy
	bsr	.sd
	move	d0,POJoy

	moveq	#16,d0	;set POTressTeam
	bsr	.sd
	move	d0,POTreeTeam

	moveq	#4,d0	;set gamelevel
	bsr	.sd
	move	d0,gamelevel

	moveq	#8,d0	;set bosgames
	bsr	.sd
	move	d0,bosgames

	moveq	#32,d0	;set PoStarts
	bsr	.sd
	move	d0,PoStarts

	and	#511,d7	;check checksum
	cmp	(a7)+,d7
	beq	rtss
	st	PoStarts	;flag failed password
	rts

.sd	;get d0 range from passbits and add to checksum count
	bsr	SuperDiv
	add	d0,d7
	rts

EncodePW	;after playoff game compute winners and password if needed
	tst	OptPlayMode
	beq	rtss
	move	#1,OptPlayMode	;continue season

	bsr	ResolveGames
	bsr	maketree
	cmp	#4,gamelevel
	beq	.userwon	;finished playoffs
	tst	gamenum
	bpl	.nofail	;player 1 won
	cmp	#2,POJoy
	blt	.userfailed	;one player or teammates
	cmp	#1,gamelevel
	bne	.userfailed
	eor	#1,POTreeTeam	;switch teams if 2 player playoffs and cont 2 won first game
	eor	#1,POJoy
.nofail
	bsr	WritePassBits
	bsr	BitstoPW
	btst	#sf3alttree,sflags3
	beq	MakeTree
	move.l	tpassbits,passbits	;passbits befor all games resolved
	move.l	tpassbits+4,passbits+4
	move.l	tpassbits+8,passbits+8
	move.l	tpassbits+12,passbits+12
	bsr	ReadPassBits
	bra	MakeTree
.UserWon
	bsr	ResetPassWord
.UserFailed
	bset	#7,PassWord
	move	#2,OptPlayMode	;new playoffs
	cmp	#7,bosgames
	beq	rtss
	move	#3,OptPlayMode	;new playoffs best of 7
	rts

WritePassBits	;transfer game variables to passbits
	bsr	ClrPassBits
	clr	d7	;checksum counter
	move	PoStarts,d0
	moveq	#32,d1
	bsr	.pb

	move	bosgames,d0
	moveq	#8,d1
	bsr	.pb

	move	gamelevel,d0
	moveq	#4,d1
	bsr	.pb

	move	POTreeTeam,d0
	moveq	#16,d1
	bsr	.pb

	move	POJoy,d0
	moveq	#4,d1
	bsr	.pb

	move	WinBits,d0
	;move	#2^14,d1
	move	#1<<14,d1
	bsr	.pb

	moveq	#5,d1
	moveq	#7,d2
	move	#gstruct,a1
.0	move	gspotwins(a1),d0
	bsr	.pb
	move	gspobwins(a1),d0
	bsr	.pb
	add	#gssize,a1
	dbf	d2,.0

	move	d7,d0
	and	#511,d0
	move	#512,d1
	bsr	pushbits
	rts

.pb	;update checksum and pushbits
	add	d0,d7
	bra	pushbits

PushBits	;d1=range	2^1-2^15
	;d0=data
	movem.l	d0-d1,-(a7)
	exg	d0,d1
	bsr	SuperMult
	clr.l	d0
	move	d1,d0
	bsr	SuperAdd
	movem.l	(a7)+,d0-d1
	rts

PWtoBits	;convert password text into passbits
	bsr	ClrPassBits
	move	#PassWord,a0
	moveq	#pwlength-1,d2
.0	moveq	#PWrange,d0
	bsr	supermult
	clr.l	d0
	move.b	(a0)+,d0
	bsr	superadd
	dbf	d2,.0
	rts

BitstoPW	;convert passbits into password text
	move	#PassWord,a0
	add	#pwlength,a0
	moveq	#pwlength,d2
.0	moveq	#PWRange,d0
	bsr	superdiv
	move.b	d0,-(a0)
	dbf	d2,.0
	rts

ClrPassBits	;clr passbits
	clr.l	PassBits	
	clr.l	PassBits+4	
	clr.l	PassBits+8	
	clr.l	PassBits+12	
	rts

SuperAdd	;1 word (d0.L) added to 8 words at passbits
	movem.l	d1/a0,-(a7)
	move	#PassBits+16,a0
	moveq	#3,d1
	add.l	d0,-(a0)
	bra	.2
.1	add.l	#1,-(a0)
.2	dbcc	d1,.1
	movem.l	(a7)+,d1/a0
	rts

SuperMult	;1 word (d0) multiplied by 8 words at passbits
	movem.l	d1-d4/a0,-(a7)
	move	#PassBits,a0
	moveq	#7,d4
.0	move	(a0),-(a7)
	clr	(a0)+
	dbf	d4,.0
	moveq	#7,d4
.1	move	d0,d1
	mulu	(a7)+,d1
	move	d4,d2
	move	#PassBits+2,a0
	add	d2,a0
	add	d2,a0
	lsr	#1,d2
	add.l	d1,-(a0)
	bra	.3
.2	add.l	#1,-(a0)
.3	dbcc	d2,.2
	dbf	d4,.1
	movem.l	(a7)+,d1-d4/a0
	rts

SuperDiv	;8 words at passbits divided by 1 word (d0)
	;d0 = remainder on exit
	movem.l	d1-d2/a0,-(a7)
	move	#PassBits,a0
	moveq	#7,d1
	clr.l	d2
.0	move	(a0),d2
	divu	d0,d2
	move	d2,(a0)+
	dbf	d1,.0
	swap	d2
	move	d2,d0
	movem.l	(a7)+,d1-d2/a0
	rts

GetShifter	;returns:
	;d1 = number of games-1
	;d2 = first bit of WinBits
	move.l	d0,-(a7)
	moveq	#-16,d2
	moveq	#16,d1
	move	gamelevel,d0
.3	add	d1,d2
	lsr	#1,d1
	dbf	d0,.3
	sub	#1,d1
	move.l	(a7)+,d0
	rts

ResolveGames	;compute winners and losers for playoff matchups
	move	gamenum,d0
	mulu	#gssize,d0
	move	#gstruct,a0
	move	tmstruct+tmscore,gss1(a0,d0)	;copy score from played game into game structures
	move	tmstruct+tmscore+tmsize,gss2(a0,d0)

	bsr	GetShifter
	move	#gstruct,a0
	moveq	#gssize,d3
	mulu	d1,d3
	add	d3,a0
	cmp	#7,bosgames
	beq	.notbos	;not best of 7
.b0	cmp	#4,gspotwins(a0)
	beq	.b1
	cmp	#4,gspobwins(a0)
	beq	.b1
	clr	d3
	btst	#gsftf,gsflags(a0)
	beq	.nf
	eor	#gspobwins-gspotwins,d3
.nf	move	gss1(a0),d0
	sub	gss2(a0),d0
	bpl	.ns1
	eor	#gspobwins-gspotwins,d3
.ns1	add	#1,gspotwins(a0,d3)
.b1	sub	#gssize,a0
	dbf	d1,.b0
	add	#1,bosgames
	cmp	#7,bosgames
	beq	.nextround
	move	gamenum,d0
	mulu	#gssize,d0
	move	#gstruct,a0
	add	d0,a0
	cmp	#4,gspotwins(a0)
	beq	.cround
	cmp	#4,gspobwins(a0)
	bne	rtss
.cround	;finish off rest of round games here
	cmp	#3,gamelevel
	bge	.nextround
	bsr	GetShifter
	move	#gstruct,a0
	moveq	#gssize,d3
	mulu	d1,d3
	add	d3,a0
.cr0	cmp	gamenum,d1
	beq	.crn
	cmp	#4,gspotwins(a0)
	beq	.crn
	cmp	#4,gspobwins(a0)
	beq	.crn
	add	#1,gspotwins(a0)
	move.l	#200,d0
	bsr	randomd0
	and	#1,d0
	beq	.cr0
	sub	#1,gspotwins(a0)
	add	#1,gspobwins(a0)
	bra	.cr0
.crn	sub	#gssize,a0
	dbf	d1,.cr0
	bsr	WritePassBits
	move.l	passbits,tpassbits	;save passbits befor advancing to next round
	move.l	passbits+4,tpassbits+4
	move.l	passbits+8,tpassbits+8
	move.l	passbits+12,tpassbits+12
	bset	#sf3alttree,sflags3

.nextround	;advance to next round
	clr	bosgames
	bsr	GetShifter
	move	#gstruct,a0
	moveq	#gssize,d3
	mulu	d1,d3
	add	d3,a0
	clr	d3
.nr0	cmp	#4,gspotwins(a0)
	beq	.nr1
	bset	d1,d3
.nr1	clr	gspotwins(a0)
	clr	gspobwins(a0)
	sub	#gssize,a0
	dbf	d1,.nr0
	moveq	#1,d1
	asl	d2,d1
	sub	#1,d1
	and	d1,WinBits
	asl	d2,d3
	or	d3,WinBits
	add	#1,gamelevel
	rts

.notbos	;solve for no best of 7 playoffs (much simpler)
	clr	d3
.nb0	move	gss1(a0),d0
	cmp	gss2(a0),d0
	bhi	.nb1
	bset	d1,d3
.nb1	btst	#gsftf,gsflags(a0)
	beq	.nb2
	bchg	d1,d3
.nb2	sub	#gssize,a0
	dbf	d1,.nb0
	moveq	#1,d1
	asl	d2,d1
	sub	#1,d1
	and	d1,WinBits
	asl	d2,d3
	or	d3,WinBits
	add	#1,gamelevel
	rts

PWprint	;print pass word (from PassWord
	tst.b	PassWord
	bmi	rtss
	movem.l	d0-d1/a0-a2,-(a7)
	move.l	#PasstoText,a2
	move	#MesArea,a1
	move	#PassWord,a0
	move	#2+PWlength,(a1)+
	moveq	#PWlength-1,d1
.top	move.b	(a0)+,d0
	ext	d0
	move.b	0(a2,d0),(a1)+
	dbf	d1,.top
	move	#MesArea,a1
	bsr	print
	movem.l	(a7)+,d0-d1/a0-a2
	rts

PasstoText	;chars used in password text
	dc.b	'BCDFGHJKLMNPRSTVWXYZ0123456789-'
	dc.b $FF

ResetPassWord	;copy '-' char into password
	move.l	#PassWord,a0
	clr.b	(a0)+
	moveq	#PWlength-2,d0
.2	move.b	#PWrange,(a0)+
	dbf	d0,.2
	rts

BusError
	move	#$2700,sr
	bsr	printbigz
	String	-$43,0,0,'Bus Error'
	move.l	10(a7),d0
	move.l	2(a7),d1
	bra	crash

AddError
	move	#$2700,sr
	bsr	printbigz
	String	-$43,0,0,'Address Error'
	move.l	10(a7),d0
	move.l	2(a7),d1
	bra	crash

Illinst
	move	#$2700,sr
	bsr	printbigz
	String	-$43,0,0,'Illegal Instruction'
	move.l	2(a7),d0
	move.l	d0,d1
	bra	crash

ZeroDiv
	move	#$2700,sr
	bsr	printbigz
	String	-$43,0,0,'Division by zero'
	move.l	2(a7),d0
	move.l	d0,d1

crash
	move.l	#mesarea,a0
	move	#2+3+8+3+8,(a0)+
	
	move.b	#-$43,(a0)+
	move.b	#0,(a0)+
	move.b	#2,(a0)+
	move.l	d1,-(a7)
	bsr	.ri

	move.b	#-$43,(a0)+
	move.b	#0,(a0)+
	move.b	#4,(a0)+
	move.l	(a7)+,d0
	bsr	.ri

	move.l	#mesarea,a1
	bsr	printbig

	move.l	#Vdata,a0
	move	#$9100,4(a0)
	move	#$9206,4(a0)
	move	#$8f02,4(a0)
	move.l	#$c0060000,4(a0)
	move.l	#$0eee0000,(a0)

;	bclr	#sfpj,sflags
;	move	#$2500,sr
;.end	bsr	PauseMode
.end	bra.w	.end


.ri	
	moveq	#7,d2
.top
	rol.l	#4,d0
	move	d0,d1
	and	#$f,d1
	add	#'0',d1
	cmp	#'9',d1
	ble	.t1
	add	#'A'-'0'-10,d1
.t1	move.b	d1,(a0)+
	dbf	d2,.top
	rts
;-------------------------------
;p_music_vblank
;p_initialZ80
;p_initune
;p_turnoff
;p_initfx	rts	;disable all sound

p_music_vblank	equ	*
p_initialZ80	equ	(*+4)
p_initune	equ	(*+8)
p_turnoff	equ	(*+12)
p_initfx	equ	(*+16)
	incbin Sound\Hockey.snd
	even

GameSetUpMap
	incbin Graphics\GameSetUp.map.jim
	even
Title1Map
	incbin Graphics\Title1.map.jim
	even
Title2Map
	incbin Graphics\Title2.map.jim
	even
NHLSpinMap
	incbin Graphics\NHLSpin.map.jim
	even
PuckSprites
	incbin Graphics\Puck.anim
	even
ScoutMap
	incbin Graphics\Scouting.map.jim
	even
FramerMap
	incbin Graphics\Framer.map.jim
	even
FaceOffMap
	incbin Graphics\FaceOff.map.jim
	even	
IceRinkMap
	incbin Graphics\IceRink.map.jim
	even
RefsMap
	incbin Graphics\Refs.map.jim
	even
Sprites
	incbin Graphics\Sprites.anim
	even
CrowdSprites
	incbin Graphics\Crowd.anim
	even
FaceOffSprites
	incbin Graphics\FaceOff.anim
	even
ZamSprites
	incbin Graphics\Zam.anim
	even
BigFontMap
	incbin Graphics\BigFont.map.jim
	even
SmallFontMap
	incbin Graphics\SmallFont.map.jim
	even
Teamblocksmap
	incbin Graphics\TeamBlocks.map.jim
	even
Arrowsmap
	incbin Graphics\Arrows.map.jim
	even
Stanleymap
	incbin Graphics\Stanley.map.jim
	even
EASNmap
	incbin Graphics\EASN.map.jim
	even
endofcart
   	end

;Notes

;Vel*((16*60)/$10000)=pix/sec
;Vel*(15/1024)=pix/sec

;	.jim format
;.top
;	dc.l	.pal-.top
;	dc.l	.map-.top
;	dc.w	#of stamps
;	dc...	stamp data
;
;.pal	dc.b	128 bytes of pal data
;
;.map	dc.w	map width
;	dc.w	map height
;	dc...	map data
