;	player logic code
doinput	;process controller input
	;d0 = dpad
	;d1 = new buttons
	;d2 = changed buttons
	;d3 = held buttons
	;d4 = controller 0/2
	bsr	setpads	;set cordinates for stars
	btst	#sbut,d1	;start button
	beq	.0
	tst	d4
	beq	startpause1
	bra	startpause2
.0
	btst	#sfhor,sflags	;is screen in horizontal mode
	beq	.nhor
	btst	#3,d0
	bne	.nhor
	add	#2,d0	;add 90 degrees if in horizontal mode
	and	#7,d0
.nhor	
	btst	#sf2faceoff,sflags2
	bne	faceoffinput
	btst	#pf2lcm,pflags2(a3)
	bne	lineinput	;line change interface on
	btst	#pfjoycon,pflags(a3)
	beq	rtss	;no joystick cont so exit
	btst	#pfalock,pflags(a3)
	bne	.islocked
	btst	#pf2fight,pflags2(a3)
	bne	fightinput	;fighting in progress
	move	puckc,d5
	cmp	SCnum(a3),d5
	beq	.ispc	;player is puck carrier
	btst	#abut,d1
	bne	HoldPlayer	;hold button
	btst	#bbut,d1	;is not puck c
	bne	changeplayer	;switch players
	tst	position(a3)
	beq	rtss	;goalie can't check
	btst	#cbut,d1
	bne	burst	;burst/check
	bra	doplayeracc	;no button, just dpad input

.ispc	;player is puck handler
	bsr	checkob
	btst	#sfspdir,sflags
	bne	passmode
	btst	#sfssdir,sflags
	bne	shotmode
	btst	#bbut,d1
	bne	SetPassMode
	btst	#abut,d1
	bne	SetLCmode
	tst	position(a3)
	beq	rtss	;exit if goalie
	btst	#cbut,d1
	bne	SetShotMode
	bra	doplayeracc

.islocked	;animation is locked /don't interupt it/
	move	puckc,d5
	cmp	SCnum(a3),d5
	beq	rtss
	btst	#bbut,d1	;is not puck handler
	bne	changeplayer
	rts

faceoffinput
	;controller processing for faceoff
	move	assnum(a3),d4
	cmp.b	#afaceoffpl,asslist(a3,d4)
	bne	rtss	;exit if this is not a faceoff player
	move	#fodir1,a0	;faceoff direction of puck controll variable
	btst	#pfgoal,pflags(a3)
	beq	.2
	move	#fodir2,a0
.2	move	d0,(a0)	;store dpad for faceoff pull

	btst	#pf2aip,pflags2(a3)
	bne	rtss
	btst	#bbut,d1
	beq	.1
	move	#SPAfaceoff,d1
	bset	#pf2aip,pflags2(a3)
	bra	SetSPA
.1	move	#SPAfaceoffr,d1
	bra	SetSPA

fightinput	;controller processing for fighting
	tst	temp3(a3)
	bmi	rtss	;exit if fight is over
	tst	PenCntDwn
	bmi	rtss	;exit if fight is over
	cmp	#SPAfight,SPA(a3)
	beq	rtss	;exit if this player is not in ready position

	move	d0,d2	;dpad input
	move	d1,-(a7)	;new button presses
	btst	#3,d2
	bne	.noa
	and	#7,d2
	bsr	playeracc
.noa
	moveq	#12,d0	;keep the players face to face and in range of xc1
	cmp	#2,facedir(a3)
	bne	.0
	neg	d0
.0	add	Xc1,d0
	sub	Xpos(a3),d0
	move	Xvel(a3),d1
	eor	d0,d1
	bpl	.ind
	tst	d0
	bpl	.1
	neg	d0
.1	muls	Xvel(a3),d0
	asr.l	#4,d0
	sub	d0,Xvel(a3)
.ind	move	(a7)+,d1

	bset	#pf2aip,pflags2(a3)
	bne	rtss
	move	d1,d2
	move	#SPAfhigh,d1
	btst	#cbut,d2
	bne	SetSPA	;if abut then start hit high anim.

	move	#SPAflow,d1
	btst	#bbut,d2
	bne	SetSPA	;if bbut then start hit low anim.

	move	#SPAfgrab,d1
	btst	#abut,d2
	bne	SetSPA	;if abut then start grab anim.

	bclr	#pf2aip,pflags2(a3)	;clear anim in prog if none
	rts

SetLCmode	;initiate line change option if available
	tst	OptLine
	bne	rtss	;exit if line changes off
	move	#tmstruct+tmsize,a2
	btst	#pfteam,pflags(a3)
	bne	.0
	sub	#tmsize,a2
.0	move.l	tmsort(a2),a0
	moveq	#5,d0	;don't allow teamates both to line change
.1	btst	#pf2lcm,pflags2(a0)
	add	#SCstruct,a0
	dbne	d0,.1
	bne	rtss	;exit if team mate already in lc mode

SetLCmode2	;a2 = team struct for lc
	bsr	setlccords	;set screen cords for this teams lc box
	cmp	#23,printy
	bne	.nollcm
	bset	#sf3llcs,sflags3	;flag for lower (on screen) line change
.nollcm
	bsr	framer	;frame lc box
	sub	#4,printy
	add	#1,printx
	bclr	#sfspdir,sflags	;terminate passing by this player
	bclr	#sfssdir,sflags	;same with shooting
	bset	#pf2lcm,pflags2(a3)	;this player in lc mode
	moveq	#2,d4	;loop 3 times
	move	printx,-(a7)
.loop
	move	(a7),printx
	moveq	#2,d0
	sub	d4,d0
	bsr	getlchoice
	tst	d0
	bmi	.blank
	move	d0,-(a7)
	move	#mesarea,a1
	move	#4,(a1)
	move.b	#'C',2(a1)
	sub.b	d4,2(a1)
	clr.b	3(a1)
	bsr	print
	add	#2,printx
	move	(a7),d0
	move.l	#linelist,a0
.pl0	move.l	a0,a1
	add	(a0),a0
	dbf	d0,.pl0
.pp	bsr	print
	move	(a7)+,d0
	bsr	linebar
	bra	.next
.blank	bsr	printz
	String	'        '
.next	add	#1,printy
	dbf	d4,.loop
	add	#2,a7
	rts

setlccords	;set printx/y to cords for lc box on team a2
	;set d0/d1 for framer box size
	clr	d0
	cmp	#tmstruct,a2
	bne	.0
	eor	#1,d0
.0	btst	#sfhor,sflags
	bne	.hor
	bsr	printz
	string	-$41,22,0
	btst	#gmdir,gmode
	beq	.noflip
	eor	#1,d0
.noflip	mulu	#23,d0
	add	d0,printy
	bra	.ex

.hor	bsr	printz
	String	-$41,6,13
	mulu	#12,d0
	add	d0,printx
.ex	moveq	#10,d0
	moveq	#5,d1
	rts

getlchoice	;d0 = 0-2
	;return d0 = possible line number or -1 for none in this position
	movem.l	a1-a2,-(a7)
	move	#tmstruct,a2
	lea	tmsize(a2),a1
	btst	#pfteam,pflags(a3)
	beq	.0
	exg	a2,a1
.0	
	bsr	getlchoice2
	movem.l	(a7)+,a1-a2
	rts

getlchoice2	;a2 = team for choice
	;a1 = other team
	;d0 = choice position 0-2
	;returns d0 = line number or -1
	movem.l	d2/a0-a2,-(a7)
	move	tmap(a1),d2
	sub	tmap(a2),d2	;d2= number I'm short
	beq	.1
	add	#3*7,d0
	tst	d2
	bmi	.1
	add	#3*7,d0
.1	move	tmline(a2),d1
	add	d1,d0
	add	d1,d0
	add	d1,d0
	move.l	#.tab,a0
	move.b	0(a0,d0),d0
	ext	d0
	movem.l	(a7)+,d2/a0-a2
	rts
	
.tab
;offset = 0 no power play
	dc.b	0,1,2	;line 0
	dc.b	1,2,0	;line 1
	dc.b	2,0,1	;line 2
	dc.b	0,1,2	;line 3
	dc.b	0,1,2	;line 4
	dc.b	0,1,2	;line 5
	dc.b	0,1,2	;line 6
;offset = 3/4 penalty killing
	dc.b	3,4,-1	;line 0
	dc.b	3,4,-1	;line 1
	dc.b	3,4,-1	;line 2
	dc.b	3,4,-1	;line 3
	dc.b	4,3,-1	;line 4
	dc.b	3,4,-1	;line 5
	dc.b	3,4,-1	;line 6
;offset = 5/6 power play
	dc.b	5,6,-1	;line 0
	dc.b	5,6,-1	;line 1
	dc.b	5,6,-1	;line 2
	dc.b	5,6,-1	;line 3
	dc.b	5,6,-1	;line 4
	dc.b	5,6,-1	;line 5
	dc.b	6,5,-1	;line 6
	dc.b	$FF

lineinput	;process input for line changes
	;d1 = new button presses
	move	d1,-(a7)
	move	#tmstruct,a2
	btst	#pfteam,pflags(a3)
	beq	.0
	add	#tmsize,a2
.0	bclr	#tmflcc,tmflags(a2)	;flag to start lc mode
	beq	.1
	bsr	SetLCmode2	;start lc mode
.1	move	(a7)+,d1	;new presses
	clr	d2	;choice made index
	btst	#abut,d1
	bne	lcfound
	add	#1,d2
	btst	#bbut,d1
	bne	lcfound
	add	#1,d2
	btst	#cbut,d1
	bne	lcfound
	btst	#pf2fight,pflags2(a3)
	beq	doplayeracc	;skate with dpad if not fighting
	rts
lcfound	;d2 = choice made 0-2
	move	d2,d0
	bsr	getlchoice	;translate choice 0-2 into line number 0-6
	tst	d0
	bmi	rtss	;not an eligible choice
	bclr	#pf2lcm,pflags2(a3)
	bset	#pfjoycon,pflags(a3)
	move	#tmstruct,a2
	btst	#pfteam,pflags(a3)
	beq	.f0
	add	#tmsize,a2
.f0	cmp	d0,d1
	beq	.close
	move	d0,tmline(a2)	;if line is different then start line change
	bsr	setpersonel

.close	bsr	setlccords	;close lc box
	cmp	#23,printy
	bne	.nollcm
	bclr	#sf3llcs,sflags3
.nollcm	moveq	#1,d2
	bsr	eraser
	bra	printscores1

burst	;cbut press check/speed
	bsr	getpde	;get players energy
	tst	OptLine
	bne	.0
	sub	#$1000/20,d0
	bsr	setpde	;decrease players energy
.0	lsr	#7,d0
	move	d0,d1	;energy = speed increase (check violence)
	move	facedir(a3),d2
	asl	#2,d2
	move.l	#dirtab,a0
	muls	0(a0,d2),d0
	muls	2(a0,d2),d1
	add	d0,Xvel(a3)
	add	d1,Yvel(a3)
	bset	#pfalock,pflags(a3)	;lock in this animation
	move	#SPAburst,d1
	bra	SetSPA

Holdplayer	;abut press hold
	bset	#pfalock,pflags(a3)
	move	#SPAHold,d1
	bra	SetSPA

setpassmode	;initialize pass mode
	move	facedir(a3),passdir	;default pass dir.
	and	#%111,passdir
	bset	#sfspdir,sflags
	rts
passmode
	btst	#bbut,d2	;has bbut changed?
	bne	dopass	;yes
	btst	#3,d0	;look for dpad
	bne	rtss
	and	#%111,d0
	move	d0,passdir	;new pass dir
	bset	#3,d0
dopass
	movem.l	a0-a1/d0-d5,-(a7)

	move	#SFXpass,-(a7)
	bsr	sfx

	bclr	#sfspdir,sflags
	st	puckc	;player is not puck handler anymore
	move	#16,nopuck(a3)
	move	SCnum(a3),lastplayer

	clr	d0
	move.b	passacc(a3),d0
	asl	#2,d0
	add	#160,d0
	move	d0,passspeed

	moveq	#-1,d4	;look for closest and best player to pass to
	moveq	#5,d3
	move.l	#SortCords,a1
	cmp	#6,SCnum(a3)
	blt	.0
	add	#6*SCstruct,a1
.0	cmp.l	a1,a3
	beq	.next	;don't pass to yourself
	tst	position(a1)
	beq	.next	;don't pass to goalie
	btst	#pf2unav,pflags2(a1)
	bne	.next	;player is unavailable
	move	Xpos(a1),d0
	sub	puckx,d0
	move	Ypos(a1),d1
	sub	pucky,d1
	movem	d0-d1,-(a7)
	bsr	vtoa
	movem	(a7)+,d1-d2
	sub	passdir,d0	;
	and	#7,d0
	asl.b	#5,d0
	ext	d0
	asl	#3,d0
	muls	d0,d0
	;cmp.l	#256^2,d0
	cmpi.l   #(256*256),d0  
	bhi	.next
	muls	d1,d1
	muls	d2,d2
	add.l	d1,d2
	add.l	d0,d2
	cmp.l	d4,d2
	bhi	.next
	move.l	d2,d4
	move.l	a1,a0
.next	add	#SCstruct,a1
	dbf	d3,.0
	tst.l	d4
	bmi	.nopp	;skip if no player to pass to
	bsr	passtoa0
	bra	.exit
.nopp	;just hit puck in pass direction not to any player
	move	passdir,d0
	asl	#2,d0
	move.l	#dirtab,a0
	move	2(a0,d0),d1	;y INC
	muls	passspeed,d1
	moveq	#10,d2
	asl.l	d2,d1
	divs	#runspeed*15,d1
	add	Yvel(a3),d1
	move	d1,puckvy
	move	0(a0,d0),d1	;x inc
	muls	passspeed,d1
	asl.l	d2,d1
	divs	#runspeed*15,d1
	add	Xvel(a3),d1
	move	d1,puckvx
	move	#$1000,d0
	bsr	randomd0
	move	d0,puckvz
.exit	;start animation for player passing
	tst	position(a3)
	bne	.notgoalie
	tst	puckvy
	btst	#pfgoal,pflags(a3)
	beq	.g0
	bmi	.nvy
	bra	.notgoalie
.g0	bmi	.notgoalie
.nvy	neg	puckvy
.notgoalie
	move	puckvx,d0
	move	puckvy,d1
	bsr	vtoa
	move	#SPAgswing,d1
	tst	position(a3)
	beq	.e1	;goalie anim
	move	#SPApassf,d1
	bsr	Findhittype
	beq	.e1
	move	#SPApassb,d1
.e1	bsr	SetSPA
	bset	#pfalock,pflags(a3)
	movem.l	(a7)+,a0-a1/d0-d5
	rts

passtoa0	;pass puck to player a0
	move	passspeed,d5	;in pix/sec
	asr	#2,d5

	exg.l	a0,a3	;tell pass rec to get puck
	move.l	#apassrec,d0
	bsr	assinsert
	exg.l	a0,a3

	move.l	a0,-(a7)	;this routine uses passspeed
	bsr	GetHot	;and player's a0 x/y speed to determine
	add	Xpos(a0),d0	;the x/y velocity of the puck so it will
	sub	puckx,d0	;meet player a0
	add	Ypos(a0),d1
	sub	pucky,d1
	movem	d0-d1,-(a7)

	movem	(a7),d2-d3
	asr	#2,d2
	asr	#2,d3

	move	Xvel(a0),d0
	muls	#(16*60)/4,d0	;x pix/(1/4)sec
	swap	d0

	move	Yvel(a0),d1
	muls	#(16*60)/4,d1
	swap	d1

	movem	d0-d1,-(a7)
	muls	d2,d0
	muls	d3,d1
	add	d1,d0
	asl	#1,d0
	move	d0,d4		;j
	movem	(a7),d0-d1

	muls	d0,d0
	muls	d1,d1
	muls	d5,d5
	neg.l	d5
	add.l	d0,d5
	add.l	d1,d5		;k

	muls	d2,d2
	muls	d3,d3
	add.l	d2,d3		;a^2

	muls	d5,d3
	asl.l	#2,d3
	move	d4,d0
	muls	d0,d0
	sub.l	d3,d0
	bsr	sroot

	moveq	#1,d3	;limit inf. loop
	asr	#2,d5
	bne	.0
	moveq	#1,d5	;no div by zero
.0	move	d0,d2
	neg	d0
	sub	d4,d2
	ext.l	d2
	divs	d5,d2
	dbpl	d3,.0
	bne	.1
	add	#1,d2	;can't be zero
.1
	cmp	#24,d2	;limit to 3 sec.
	bls	.2
	moveq	#24,d2
.2			;d2 = time in 1/8 sec to intersection
	move.b	d2,puckvz
	cmp	#12,d2
	blt	.3
	move.b	#12,puckvz
.3
	move	d2,d0
	asl	#3,d0
	sub	#6,d0
	move.b	d0,temp2(a0)
	sub	#10,d0
	move	d0,puckx+nopuck

	movem	(a7)+,d0-d1
	muls	d2,d0
	asr.l	#1,d0
	add	(a7)+,d0	;x distance

	muls	d2,d1
	asr.l	#1,d1
	add	(a7)+,d1	;y distance

	mulu	#60*2,d2

	swap	d0
	divs	d2,d0
	move	d0,puckvx

	swap	d1
	divs	d2,d1
	move	d1,puckvy
	rts

changeplayer
	;d4 = controller 0/2
	movem.l	a0-a1/d0-d6,-(a7)
	move	puckvx,d0	;lead puck slightly
	asr	#8,d0
	add	puckx,d0
	move	puckvy,d1
	asr	#8,d1
	add	pucky,d1
	movem	d0-d1,-(a7)
	moveq	#5,d2
	move	d4,d3
	eor	#2,d3	;other controller
	moveq	#-1,d5
	move.l	#Sortcords,a0	;start of search
	move.l	#cont1team,a1
	cmp	#1,0(a1,d4)
	beq	.t1
	add	#6*SCstruct,a0	;controller is on other team
.t1	move.l	#c1playernum,a1
.top	
	tst	position(a0)
	ble	.next	;can't switch to goalie
	btst	#pf2unav,pflags2(a0)
	bne	.next	;this player is unavailable for some reason
	btst	#pfalock,pflags(a0)
	bne	.next	;this player is locked
	movem	(a7),d0-d1
	sub	Xpos(a0),d0
	muls	d0,d0
	sub	Ypos(a0),d1
	muls	d1,d1
	add.l	d1,d0
	cmp.l	d5,d0
	bhi	.next
	move	SCnum(a0),d1
	cmp	0(a1,d3),d1
	beq	.next	;this is current player
	move.l	d0,d5
	move	d1,d6
.next
	add	#SCstruct,a0
	dbf	d2,.top
	add	#4,a7
	
	pea	.ex
	cmp	0(a1,d4),d6
	beq	Sweepcheck	;player is same so sweep check
	move	d6,d0
	tst	d4
	beq	setc1player
	bra	setc2player

.ex	movem.l	(a7)+,a0-a1/d0-d6
	rts

Sweepcheck	;start sweep check on player a3
	bset	#pfalock,pflags(a3)
	move	#SPAsweepchk,d1
	bra	SetSPA

setc1player	;restore old player and switch to new d0 player on cont. 1
	cmp	c1playernum,d0
	beq	rtss
	movem.l	a0-a1/d1,-(a7)
	move	c1playernum,d1
	bsr	restorepl
	move	d0,c1playernum
	movem.l	(a7)+,a0-a1/d1
	rts

setc2player	;restore old player and switch to new d0 player on cont. 2
	cmp	c2playernum,d0
	beq	rtss
	movem.l	a0-a1/d1,-(a7)
	move	c2playernum,d1
	bsr	restorepl
	move	d0,c2playernum
	movem.l	(a7)+,a0-a1/d1
	rts

restorepl	;restore old joy controlled player
	cmp	#0,d1
	blt	.spd
	cmp	#11,d1
	bgt	.spd
	move.l	#sortcords,a0
	asl	#scsize,d1
	add	d1,a0
	bclr	#pfjoycon,pflags(a0)
	bset	#pfna,pflags(a0)
.spd
	cmp	#0,d0
	blt	rtss
	cmp	#11,d0
	bgt	rtss
	movem.l	a0-a3/d0-d3,-(a7)
	move.l	#sortcords,a3
	asl	#scsize,d0
	add	d0,a3
	bset	#pfjoycon,pflags(a3)
	movem.l	(a7)+,a0-a3/d0-d3
	rts	
MissingCode	;This code is missing from the original source code	
	dc.b $EE, $49       ; Equivalent to `link a7, #-0xB7`?
	dc.b $30, $01       ; Equivalent to `move.w d1, (a0)`?
	dc.b $4E, $75       ; Equivalent to `rts`

Findhittype	;look for type of swing (forhand or backhand)
;input d0 = launch dir
;ouput	beq	forhand
;	bne	backhand
	neg	d0
	add	facedir(a3),d0
	and	#7,d0
	btst	#3,attribute(a3)
	beq	.1
	btst	d0,#%11110000
	rts
.1
	btst	d0,#%00011110
	rts

SetShotMode	;initiate shot by player a3
	move	#8,passdir	;default shot direction
	bset	#sfssdir,sflags
	clr	d0	;find dx/dy for shot
	move	#296,d1
	btst	#pfgoal,pflags(a3)
	bne	.ck0
	neg	d1
.ck0	sub	Xpos(a3),d0
	sub	Ypos(a3),d1
	bsr	vtoa
	move	#15,passspeed
	move	#SPAshotf,d1
	bsr	Findhittype
	beq	.ck1
	move	#SPAshotb,d1
	move	#15,passspeed	;minimum shot speed
.ck1	bsr	SetSPA
	rts

ShotMode    ;shot input
    cmp     #7*4,SPAnum(a3)
    bge     doshot          ;end of animation so shoot
    btst    #3,d0
    bne     .ss0
    and     #7,d0
    move    d0,passdir      ;set shot direction
.ss0
    ; Add check for pass button press to fake shot
    btst    #bbut,d1        ;check if pass button is pressed
    bne     .fakeshot
    
    cmp     #4*4,SPAnum(a3)
    bge     rtss            ;past full windup so no more passspeed
    add     d7,passspeed
    btst    #cbut,d2
    beq     rtss            ;button hasn't changed so continue windup
    neg     SPAnum(a3)      ;end wind and swing thru
    add     #7*4,SPAnum(a3)
    rts

.fakeshot
    ; Player pressed pass button during shot windup - cancel shot
    bclr    #sfssdir,sflags ;exit shot mode
    move    #SFXshotwiff,-(a7) ;play wiff sound for the fake
    bsr     sfx
    ; Transition to pass mode if you want a fake shot to be a pass
    ;bset    #sfspdir,sflags ;enter pass mode
    ;move    facedir(a3),passdir ;default pass dir.
    ;and     #%111,passdir
    rts

doshot	;stick is at puck so launch puck toward goal
	movem.l	d0-d7/a0-a3,-(a7)
	move	#SFXshotwiff,-(a7)	;sound effect

	move	SCnum(a3),shotplayer
	bclr	#sfssdir,sflags
	bset	#pfalock,pflags(a3)
	move	puckc,d0
	cmp	SCnum(a3),d0
	bne	.ex	;wiffed shot 

	move	#SFXshotfh,(a7)
	bset	#sf2shot,sflags2
	cmp	#SPAshotb,SPA(a3)
	bne	.nbh
	move	#SFXshotbh,(a7)
	move	passspeed,d0
	lsr	#2,d0	;sub 25% for backhand shots
	sub	d0,passspeed
.nbh
	move.b	shotspd(a3),d0
	move.l	a3,a0
	bsr	makepde
	add	#20,d0
	mulu	passspeed,d0	;shot speed ranged by energy level
	mulu	#$4000*45/35,d0
	swap	d0
	move	d0,passspeed
	st	puckc
	move	#16,nopuck(a3)
	move	SCnum(a3),lastplayer
	move	blueline,d1
	add	#goalline,d1

	btst	#pfgoal,pflags(a3)
	bne	.0
	neg	d1
.0
	move	passdir,d2
	asl	#2,d2
	move.l	#.shotsets,a0	;table of shot directions
	move	0(a0,d2),d0	;x offset
	move	2(a0,d2),d2	;z offset
	sub	puckx,d0
	sub	pucky,d1
	movem	d0-d2,-(a7)
	muls	d0,d0
	muls	d1,d1
	add.l	d1,d0
	bsr	sroot
	tst	d0	;distance in pix to goal
	bne	.1
	add	#1,d0
.1
	move	d0,d3
	btst	#gmhl,gmode
	bne	.perf
	cmp	#200,d3
	bhi	.notperf	;too far away for perfect shot
	moveq	#16,d0
	add.b	shotacc(a3),d0
	bsr	randomd0
	cmp	#14,d0	;chance of perfect shot
	bgt	.perf	;is perfect
.notperf
	move	passspeed,d0
	lsr	#4,d0
	sub.b	shotacc(a3),d0
	add.b	#16,d0

	mulu	d3,d0
	lsr	#7,d0	;shot accuracy adjust
	move	d0,-(a7)
	bsr	randomd0s
	add	d0,2(a7)	;x dist
	move	(a7),d0
	bsr	randomd0s
	add	d0,4(a7)	;y dist
	move	(a7)+,d0
	lsr	#1,d0
	bsr	randomd0
	add	d0,4(a7)
.perf
	move	passspeed,d2	;shot speed
	muls	#1024/15,d2
	muls	(a7)+,d2
	divs	d3,d2
	move	d2,puckvx
	move	passspeed,d2
	muls	#1024/15,d2
	muls	(a7)+,d2
	divs	d3,d2
	move	d2,puckvy

	move	(a7)+,d1	;pix height in goal
	beq	.ex
	mulu	passspeed,d1
	mulu	#1024/15,d1
	divu	d3,d1

	mulu	#(1024*42)/15,d3
	divu	passspeed,d3
	add	d1,d3
	cmp	#$1800,d3
	bls	.noup
	move	#$1800,d3
.noup
	move	d3,puckvz
.ex
	bsr	sfx
	movem.l	(a7)+,d0-d7/a0-a3
	rts

.shotsets	;offsets for different directions on the shot
	dc.w	00,12,16,12,16,06,16,00
	dc.w	00,00,-16,00,-16,06,-16,12
	dc.w	00,06

setpads	;copy info into pad cont so graphics knows which player/number
	move	d0,-(a7)
	move.l	#padcont,a0
	move.b	SCnum+1(a3),2(a0,d4)
	move.b	rostnum(a3),d0
	cmp.b	3(a0,d4),d0
	beq	.ex
	bset	#6,2(a0,d4)	;flag for new roster number
	move.b	d0,3(a0,d4)
.ex	move	(a7)+,d0
	rts

asstab	;jump table of all the player logic assignments
	dc.l	rtss

adefo	=	(*-asstab)/4
	dc.l	assdefo
adefd	=	(*-asstab)/4
	dc.l	assdefd
awingd	=	(*-asstab)/4
	dc.l	asswingd
awingo	=	(*-asstab)/4
	dc.l	asswingo
acenterd	=	(*-asstab)/4
	dc.l	asscenterd
acentero	=	(*-asstab)/4
	dc.l	asscentero

anothing	=	(*-asstab)/4
	dc.l	assnothing
ascore	equ	(*-asstab)/4
	dc.l	assscore
astanley	equ	(*-asstab)/4
	dc.l	assstanley
aeben	=	(*-asstab)/4
	dc.l	asseben
aepen	=	(*-asstab)/4
	dc.l	assepen
abench	=	(*-asstab)/4
	dc.l	assbench
apenalty	=	(*-asstab)/4
	dc.l	asspenalty
adopen	=	(*-asstab)/4
	dc.l	assdopen


agoalie	=	(*-asstab)/4
	dc.l	assgoalie
apuckc	=	(*-asstab)/4
	dc.l	asspuckc
anearest	=	(*-asstab)/4
	dc.l	assnearest
ashoot	=	(*-asstab)/4
	dc.l	assshoot
apassrec	equ	(*-asstab)/4
	dc.l	asspassrec
afight	=	(*-asstab)/4
	dc.l	assfight
afwatch	=	(*-asstab)/4
	dc.l	assfwatch
afaceoff	=	(*-asstab)/4
	dc.l	assfaceoff
afaceoffpl	equ	(*-asstab)/4
	dc.l	assfaceoffpl


pnorm	=	(*-asstab)/4
	dc.l	pucknorm
pshad	=	(*-asstab)/4
	dc.l	puckshadow
pnothing	=	(*-asstab)/4
	dc.l	pucknothing
pfaceoff	equ	(*-asstab)/4
	dc.l	puckfaceoff
pfaceoff2	=	(*-asstab)/4
	dc.l	puckfaceoff2


check4bench	;check if player a3 should go to bench
	btst	#pfjoycon,pflags(a3)
	bne	rtss	;if joy cont don't go to bench
	btst	#pf2pen,pflags2(a3)
	bne	rtss	;player can't escape his penalty
	tst.b	newpos(a3)
	bpl	.b
	tst.b	newpnum(a3)
	bmi	rtss	;no bench requested
.b
	move.b	newpnum(a3),d0
	cmp.b	pnum(a3),d0
	beq	.samepl	;same player just different position
	move	assnum(a3),d0
	cmp.b	#abench,asslist(a3,d0)
	beq	rtss	;exit if already going to bench
	move	SCnum(a3),d0
	cmp	puckc,d0
	beq	rtss	;exit if puck handling
	add	#4,a7	;don't return to calling routing
	bset	#pf2unav,pflags2(a3)	;player is now unavailable
	clr	temp1(a3)
	moveq	#abench,d0
	bra	assreplace

.samepl	;player should just change positions
	add	#4,a7	;don't return to calling routing
	bclr	#pf2unav,pflags2(a3)
	bclr	#pfnc,pflags(a3)
	st	newpnum(a3)
	st	newpos(a3)
	move	position(a3),d0
	tst.b	newpos(a3)
	bmi	Setplass
	move.b	newpos(a3),d0
	ext	d0
	move	d0,position(a3)
	bra	Setplass

assbench	;player a3 should goto bench
	cmp	#100,temp1(a3)	;flag
	beq	.done
	btst	#gmpen,gmode
	bne	donothing
	bsr	check4bench
	btst	#pf2pen,pflags2(a3)
	bne	assexit
	bclr	#pfna,pflags(a3)
	beq	.nna
	move	#8,temp2(a3)
	moveq	#80,d0
	btst	#pfteam,pflags(a3)
	bne	.0
	neg	d0
.0	move	d0,temp4(a3)
	move	sideline,temp3(a3)
	neg	temp3(a3)
	sub	#8,temp3(a3)
	clr	temp1(a3)
.nna
	move.b	newpnum(a3),d0
	cmp.b	pnum(a3),d0
	beq	.nobench

	sub	d7,temp1(a3)
	bpl	.nodec
	add	#8,temp1(a3)
	move	Ypos(a3),d0
	sub	temp4(a3),d0
	cmp	#40,d0
	bgt	.nodec
	cmp	#-40,d0
	blt	.nodec
	move	Xpos(a3),d0
	sub	temp3(a3),d0
	cmp	#32,d0
	bgt	.nodec
	move	#SPAglide,d1
	tst	position(a3)
	bne	.gli
	move	#SPAgready,d1
.gli	bsr	SetSPA
	bset	#pfnc,pflags(a3)
	cmp	#4,facedir(a3)
	beq	.ok
	add	#1,facedir(a3)
	and	#7,facedir(a3)
.ok
	clr	Yvel(a3)
	move	#-$800,Xvel(a3)
	cmp	#16,d0
	bgt	rtss
	clr	Xvel(a3)
	cmp	#4,facedir(a3)
	bne	rtss

	move	#-$800,Xvel(a3)
	move	#2,facedir(a3)
	move	#SPAwallleft,d1
	bsr	SetSPA
	bset	#pfalock,pflags(a3)
	move	#100,temp1(a3)
	rts
.done
	clr	frame(a3)
	clr	d0
	move.b	pnum(a3),d0
	add	d0,d0
	move.l	#tmstruct,a0
	btst	#pfteam,pflags(a3)
	beq	.t0
	add	#tmsize,a0
.t0	move	#-2,tmpdst(a0,d0)	;put used player on bench
	move.b	newpnum(a3),d3
	bsr	.nobench2
	bra	setplayer

.nodec	btst	#pfnc,pflags(a3)
	bne	rtss
	move	temp3(a3),d0
	move	temp4(a3),d1
	move.l	#EvadePC,a0
	bra	skateto

.nobench
	bclr	#pf2unav,pflags2(a3)
.nobench2
	move.b	newpos(a3),d0
	ext	d0
	move	d0,position(a3)
	bsr	Setplass
	st	newpnum(a3)
	st	newpos(a3)
	rts

asseben	;player a3 should exit bench area
	bclr	#pfna,pflags(a3)
	beq	.nna
	clr	Xvel(a3)
	clr	Yvel(a3)
	move	SCnum(a3),d0
	sub	#6,d0
	bmi	.0
	add	#1,d0
.0	muls	#14,d0
	move	d0,Ypos(a3)
	move	sideline,Xpos(a3)
	neg	Xpos(a3)
	move	#2,facedir(a3)
	bset	#pfalock,pflags(a3)
	move	#SPAwallright,d1
	bra	SetSPA
.nna	move	#4,facedir(a3)
	bclr	#pfnc,pflags(a3)
	bclr	#pf2npc,pflags2(a3)
	bclr	#pf2unav,pflags2(a3)
	clr	SPA(a3)
	move	#$1000,Xvel(a3)
	bra	assexit

asspenalty	;player a3 should goto penalty box
	bclr	#pfna,pflags(a3)
	beq	.nna
	bset	#pf2unav,pflags2(a3)
	bsr	.clrplayer
	moveq	#-2,d4
	bsr	Setpads	;put number on player leaving
	move	#8,temp2(a3)
	move.b	PBnum,d1
	moveq	#55,d0
	btst	#pfteam,pflags(a3)
	bne	.0
	lsr	#4,d1
	sub	#86,d0
.0	and	#$0f,d1
	cmp	#2,d1
	bls	.1
	moveq	#2,d1
.1
	mulu	#10,d1
	sub	d1,d0
	move	d0,temp4(a3)
	move	sideline,temp3(a3)
	clr	temp1(a3)
	bset	#pf2npc,pflags2(a3)	;no player coll.
	clr	wallcos(a3)
	clr	wallsin(a3)
.nna
	move	Ypos(a3),d0
	sub	temp4(a3),d0
	cmp	#12,d0
	bgt	.st
	cmp	#-12,d0
	blt	.st
	move	Xpos(a3),d0
	sub	temp3(a3),d0
	cmp	#-24,d0
	blt	.st
	sub	d7,temp1(a3)
	bpl	rtss
	add	#8,temp1(a3)

	bset	#pfnc,pflags(a3)
	move	#SPAglide,d1
	bsr	SetSPA
	moveq	#6,d2
	tst.b	handed(a3)
	beq	.left
	moveq	#2,d2
.left
	cmp	facedir(a3),d2
	beq	.ok
	add	#1,facedir(a3)
	and	#7,facedir(a3)
.ok
	clr	Yvel(a3)
	move	#$1000,Xvel(a3)
	cmp	#-8,d0
	blt	rtss
	clr	Xvel(a3)
	cmp	facedir(a3),d2
	bne	rtss
	bset	#pfalock,pflags(a3)
	move	#2,facedir(a3)
	move	#SPAwallright,d1
	bsr	SetSPA
	bclr	#pf2pen,pflags2(a3)
	moveq	#adopen,d0
	bra	assreplace

.st	move	temp3(a3),d0
	move	temp4(a3),d1
	move.l	#rtss,a0
	bra	skateto

.clrplayer
	btst	#pfjoycon,pflags(a3)
	beq	rtss
	clr	d4
	move	SCnum(a3),d0
	cmp	c1playernum,d0
	beq	changeplayer
	moveq	#2,d4
	bra	changeplayer

assdopen	;add player a3 to penalty box
	moveq	#16,d0
	btst	#pfteam,pflags(a3)
	beq	.1
	moveq	#1,d0
.1	add.b	d0,PBnum	;players in Penalty box
	st	position(a3)
	clr	frame(a3)
	rts

assepen	;player a3 should exit penalty area
	bclr	#pfna,pflags(a3)
	beq	.nna
	moveq	#16,d0
	btst	#pfteam,pflags(a3)
	beq	.1
	moveq	#1,d0
.1	sub.b	d0,PBnum	;players in Penalty box
	clr	Xvel(a3)
	clr	Yvel(a3)
	moveq	#60,d0
	btst	#pfteam,pflags(a3)
	bne	.0
	neg	d0
.0	move	d0,Ypos(a3)
	move	sideline,Xpos(a3)
	move	#2,facedir(a3)
	bset	#pfalock,pflags(a3)
	move	#SPAwallleft,d1
	bsr	SetSPA
	bra	SprSort
.nna	move	#4,facedir(a3)
	st	newpnum(a3)
	st	newpos(a3)
	bclr	#pfjoycon,pflags(a3)
	bclr	#pfnc,pflags(a3)
	bclr	#pf2npc,pflags2(a3)
	bclr	#pf2unav,pflags2(a3)
	move	#-$1000,Xvel(a3)
	bra	assexit

assfaceoff	;players do nothing until faceoff is over
	btst	#sf2faceoff,sflags2
	beq	assexit	;exit once faceoff is over
	rts

assfaceoffpl	;assignment for players actually participating in faceoff
	;a3 = player
	btst	#sf2faceoff,sflags2
	beq	.exit
	bclr	#pfna,pflags(a3)
	beq	.nna
	clr	temp1(a3)
.nna
	move.l	#fofdata,a0
	btst	#pfteam,pflags(a3)
	beq	.0
	add	#4,a0
.0
	move	SPAnum(a3),d0
	lsr	#2,d0
	add	#1,d0
	tst.b	handed(a3)
	bne	.lefty
	add	#3,d0
.lefty	move	d0,(a0)

	btst	#pfjoycon,pflags(a3)
	bne	rtss
	bset	#pf2aip,pflags2(a3)
	bne	rtss

	move	#SPAfaceoff,d1
	cmp	#16,puckx+temp1
	bls	.d
	moveq	#8,d0
	bsr	randomd0
	tst	d0
	beq	.d
	move	#SPAfaceoffr,d1
.d	bset	#pf2aip,pflags(a3)
	bra	SetSPA

.exit	move	#20,nopuck(a3)
	bra	assexit

assfight	;fighting logic
	;a3 = player
	tst	PenCntDwn
	bmi	DoNothing
	bclr	#pfna,pflags(a3)
	beq	.nna
	bsr	getpde
	move.b	aggress(a3),d1
	ext	d1
	mulu	d1,d0
	lsr	#8,d0
	lsr	#4,d0
	move	d0,temp3(a3)	;strength
	clr	temp2(a3)
.nna
	tst	temp3(a3)
	bmi	rtss
	btst	#pfjoycon,pflags(a3)
	bne	.j
	bset	#pf2aip,pflags2(a3)
	bne	.j
	moveq	#3,d0
	bsr	randomd0
	asl	#1,d0
	move.l	#.al,a0
	move	0(a0,d0),d1
	bsr	SetSPA
.j
	bsr	chkhit
	cmp	#SPAfheld,SPA(a3)
	beq	.njc
	cmp	#SPAfight,SPA(a3)
	beq	.jc
	btst	#pfjoycon,pflags(a3)
	bne	.jc
.njc
	moveq	#10,d0
	cmp	#2,facedir(a3)
	bne	.0
	neg	d0
.0	add	xc1,d0
	sub	Xpos(a3),d0
	asl	#8,d0
	cmp	#$1000,d0
	blt	.x1
	move	#$1000,d0
.x1
	cmp	#-$1000,d0
	bgt	.x2
	move	#-$1000,d0
.x2
	move	d0,Xvel(a3)
.jc
	move	yc1,d1
	sub	Ypos(a3),d1
	asl	#8,d1
	cmp	#$1000,d1
	blt	.y1
	move	#$1000,d1
.y1	cmp	#-$1000,d1
	bgt	.y2
	move	#-$1000,d1
.y2	move	d1,Yvel(a3)
	rts

.al	dc.w	SPAfgrab
	dc.w	SPAfhigh
	dc.w	SPAflow

chkhit	;part of fight to see if player is hit
	;a3 = player
	movem.l	a0-a3/d0,-(a7)
	move	impactp(a3),d0
	asl	#scsize,d0
	move.l	#SortCords,a0
	add	d0,a0
	move	frame(a3),d0
	cmp	oldframe(a3),d0
	beq	.ex
	cmp	#SPFfight+2,d0
	beq	.dropped
	move	Xpos(a3),d0
	sub	Xpos(a0),d0
	cmp	#22,d0
	bgt	.ex
	cmp	#-22,d0
	blt	.ex
	move	Ypos(a3),d0
	sub	Ypos(a0),d0
	cmp	#8,d0	
	bgt	.ex
	cmp	#-8,d0
	blt	.ex
	move	frame(a3),d0
	cmp	#SPFfight+6,d0
	beq	.hithigh
	cmp	#SPFfight+6+5,d0
	beq	.hithigh
	cmp	#SPFfight+7,d0
	beq	.hitlow
	cmp	#SPFfight+7+5,d0
	beq	.hitlow
	cmp	#SPFfight+4,d0
	beq	.grab
	cmp	#SPFfight+4+5,d0
	beq	.grab
.ex	movem.l	(a7)+,a0-a3/d0
	rts
.dropped
	bclr	#pf2npc,pflags2(a3)
	move	xc1,d0
	asr	#2,d0
	bne	.dr0
	add	#1,d0
.dr0	move.b	d0,glovecords
	move	yc1,d0
	asr	#2,d0
	move.b	d0,glovecords+1
	bra	.ex
.grab
	cmp	#SPAfgrab,SPA(a3)
	exg	a0,a3
	bset	#pf2aip,pflags2(a3)
	move	#SPAfheld,d1
	bsr	SetSPA
	bra	.ex
.hithigh
	exg	a0,a3
	bset	#pf2aip,pflags2(a3)
	sub	#1,temp3(a3)
	bmi	.fall
	move	#SPAfhith,d1
	bsr	SetSPA
	move	#SFXhithigh,-(a7)
	bsr	sfx
	bra	.ex	
.hitlow
	exg	a0,a3
	bset	#pf2aip,pflags2(a3)
	sub	#1,temp3(a3)
	bmi	.fall
	move	#SPAfhitl,d1
	bsr	SetSPA
	move	#SFXhitlow,-(a7)
	bsr	sfx
	bra	.ex

.fall	move	#60,PenCntDwn
	move	#SPAffall,d1
	bsr	SetSPA
	exg	a0,a3
	move	#-1,temp3(a3)
	moveq	#1,d0
	moveq	#tmFightsWon,d1
	bsr	AddStat

;	bsr	newcheck

	add	#600,crowdlevel
	move	#SFXcrowdcheer,-(a7)
	btst	#pfteam,pflags(a0)
	bne	.3
	move	#SFXcrowdboo,(a7)
.3	bsr	SFX

	bra	.ex

assfwatch	;for player who is watching fight
	;a3 = player
;	bsr	check4bench

	btst	#pfjoycon,pflags(a3)
	bne	rtss
	bclr	#pfna,pflags(a3)
	beq	.nna
	move	#150,temp1(a3)
	move	#8,temp2(a3)
	
	move	Xpos(a3),d0
	sub	xc1,d0
	move	Ypos(a3),d1
	sub	yc1,d1
	movem	d0-d1,-(a7)
	muls	d0,d0
	muls	d1,d1
	add.l	d1,d0
	bsr	sroot
	move	d0,d2
	movem	(a7)+,d0-d1
	muls	#80,d0
	divs	d2,d0
	add	xc1,d0
	move	d0,temp3(a3)
	muls	#80,d1
	divs	d2,d1
	add	yc1,d1
	move	d1,temp4(a3)
.nna
	moveq	#8,d0
	sub	d7,temp1(a3)
	bmi	doplayeracc
	move	temp3(a3),d0
	move	temp4(a3),d1
	move.l	#rtss,a0
	bra	skateto

assnothing	;player should do nothing
donothing
;	bsr	check4bench
	btst	#pfjoycon,pflags(a3)
	bne	rtss
	moveq	#8,d0
	bra	doplayeracc

assstanley	;player a3 skates with stanley cup overhead
	bclr	#pfna,pflags(a3)
	beq	.nna
	move	#90,temp3(a3)
	tst	Hpos
	bpl	.0
	neg	temp3(a3)
.0
	move	Vpos,temp4(a3)
	move	#SPAStanley,d1
	bsr	SetSPA
.nna
	move	temp3(a3),d0
	sub	Xpos(a3),d0
	move	temp4(a3),d1
	sub	Ypos(a3),d1
	bsr	vtoa
	cmp	#7,d0
	bgt	rtss
	move	d0,d2
	move	d2,facedir(a3)
	bra	playeracc

assscore	;player a3 celebrates, if scoring player then do arm pump
	bclr	#pfna,pflags(a3)
	beq	.nna
	bsr	.1
	move	#8,temp2(a3)
	move	#90,temp3(a3)
	tst	Hpos
	bpl	.0
	neg	temp3(a3)
.0
	move	Vpos,temp4(a3)
.nna
	move.l	#rtss,a0
	move	temp3(a3),d0
	move	temp4(a3),d1
	sub	d7,temp1(a3)
	bpl	.chkcon
	bset	#pfalock,pflags(a3)
	move	#SPAcelebrate,d1
	move	shotplayer,d0
	cmp	SCnum(a3),d0
	bne	.nopump
	move	#SPApump,d1
.nopump	bsr	SetSPA
.1	moveq	#120,d0
	bsr	randomd0
	move	d0,temp1(a3)
	rts
.chkcon
	btst	#pfjoycon,pflags(a3)
	beq	skateto
	rts

assdefo	;player a3 is defensive player on offense
	btst	#gmclock,gmode
	bne	donothing
	bsr	check4bench
	btst	#pfjoycon,pflags(a3)
	bne	rtss
	bclr	#pfna,pflags(a3)
	beq	.nna
	clr	temp1(a3)
	move	#8,temp2(a3)
.nna
	sub.b	d7,temp1(a3)
	bpl	.nodec
	move.b	aioff(a3),temp1(a3)
	
	moveq	#adefd,d0
	move	pucky,d1
	btst	#pfgoal,pflags(a3)
	bne	.de1
	neg	d1
.de1	cmp	blueline,d1
	blt	assreplace
	move	puckc,d1
	bmi	.de0
	sub	#6,d1
	move	SCnum(a3),d2
	sub	#6,d2
	eor	d2,d1
	bmi	assreplace
.de0

.nodec
	move.l	#Evadepc,a0
	move	#80,d0
	cmp	#2,position(a3)
	beq	.1
	neg	d0
.1
	move	blueline,d1
	add	#10,d1
	btst	#pfgoal,pflags(a3)
	bne	.0
	neg	d0
	neg	d1
.0
	move	puckx,d2
	eor	d0,d2
	bmi	.2
	move	puckx,d0
	bra	skateto
.2
	move	puckx,d2
	asr	#1,d2
	add	d2,d0	
	bra	skateto

assdefd	;player a3 is defensive player on defense
	btst	#gmclock,gmode
	bne	donothing
	bsr	check4bench
	btst	#pfjoycon,pflags(a3)
	bne	rtss
	bclr	#pfna,pflags(a3)
	beq	.nna
	clr	temp1(a3)
	move	#8,temp2(a3)
.nna
	sub.b	d7,temp1(a3)
	bpl	.nodec
	move.b	aidef(a3),temp1(a3)

	move	pucky,d1
	move	puckvy,d3
	asr	#6,d3
	add	d1,d3
	btst	#pfgoal,pflags(a3)
	bne	.de00
	neg	d1
	neg	d3
.de00	cmp	blueline,d3
	blt	.de0

	move	puckc,d1
	bmi	.de0
	moveq	#adefo,d0
	sub	#6,d1
	move	SCnum(a3),d2
	sub	#6,d2
	eor	d2,d1
	bpl	assreplace
.de0
	move	#65,temp3(a3)
	cmp	#2,position(a3)
	beq	.de1
	neg	temp3(a3)
.de1	move.l	#SortCords,a0
	cmp	#6,SCnum(a3)
	bge	.de2
	add	#6*SCstruct,a0
.de2	moveq	#5,d2
	move	#-1000,d0
	btst	#pfgoal,pflags(a3)
	beq	.gdwn

	neg	d0
.gup	btst	#pf2unav,pflags2(a0)
	bne	.gu0
	tst	position(a0)
	bmi	.gu0
	move	Yvel(a0),d1
	bmi	.gu2
	clr	d1
.gu2
	asr	#5,d1	
	add	Ypos(a0),d1
	cmp	d0,d1
	bgt	.gu0
	move	d1,d0
.gu0	add	#SCstruct,a0
	dbf	d2,.gup
	cmp	#-190,d0
	bgt	.gu1
	move	#-220,d0
.gu1
;	sub	#20,d0
	move	d0,temp4(a3)
	move	puckx,d0
	move	temp3(a3),d1
	eor	d0,d1
	bpl	.de3
	clr	temp3(a3)
;	add	#20,temp4(a3)
	bra	.de3

.gdwn	btst	#pf2unav,pflags2(a0)
	bne	.gd0
	tst	position(a0)
	bmi	.gd0
	move	Yvel(a0),d1
	bpl	.gd2
	clr	d1
.gd2
	asr	#5,d1
	add	Ypos(a0),d1
	cmp	d0,d1
	blt	.gd0
	move	d1,d0
.gd0	add	#SCstruct,a0
	dbf	d2,.gdwn
	cmp	#190,d0
	blt	.gd1
	move	#220,d0
.gd1
;	add	#20,d0
	move	d0,temp4(a3)
	neg	temp3(a3)
	move	puckx,d0
	move	temp3(a3),d1
	eor	d0,d1
	bpl	.de3
	clr	temp3(a3)
;	sub	#20,temp4(a3)
.de3

.nodec
	move	temp3(a3),d0
	move	temp4(a3),d1
	move.l	#Evadepc,a0
	bsr	skateto
	bra	check4check


asswingd	;player a3 is winger on defense
	btst	#gmclock,gmode
	bne	donothing
	bsr	check4bench
	btst	#pfjoycon,pflags(a3)
	bne	rtss
	bclr	#pfna,pflags(a3)
	beq	.nna
	clr	temp1(a3)
	move	#8,temp2(a3)
.nna
	sub.b	d7,temp1(a3)
	bpl	.nodec
	move.b	aidef(a3),temp1(a3)

	move	puckc,d1
	bmi	.de0
	moveq	#awingo,d0
	sub	#6,d1
	move	SCnum(a3),d2
	sub	#6,d2
	eor	d2,d1
	bpl	assreplace
.de0

.nodec
	moveq	#100,d0
	cmp	#5,position(a3)
	bne	.1
	neg	d0
.1
	move	blueline,d1
	add	#70,d1
	btst	#pfgoal,pflags(a3)
	beq	.0
	neg	d0
	neg	d1
	move	blueline,d2
	neg	d2
	cmp	pucky,d2
	bgt	.ug1
	move	pucky,d1
;	asl	#3,d0
	bra	.z1
.ug1	sub	#goalline,d2
	cmp	pucky,d2
	blt	.z1
;	asl	#3,d0	;wing behind own goal line
	move	d2,d1
	bra	.z1
.0
	move	blueline,d2
	cmp	pucky,d2
	blt	.dg1
	move	pucky,d1
;	asl	#3,d0
	bra	.z1
.dg1	add	#goalline,d2
	cmp	pucky,d2
	bgt	.z1
;	asl	#3,d0
	move	d2,d1

.z1
	move.l	#rtss,a0
	move	puckx,d2
	eor	d0,d2
	bmi	skateto
	move	puckx,d0
	bra	skateto
	
asswingo	;player a3 is winger on offense
	btst	#gmclock,gmode
	bne	donothing
	bsr	check4bench
	btst	#pfjoycon,pflags(a3)
	bne	rtss
	bclr	#pfna,pflags(a3)
	beq	.nna
	st	temp5(a3)	;old zone number
	clr	temp1(a3)
	move	#8,temp2(a3)
.nna
	sub.b	d7,temp1(a3)
	bpl	.nodec
	move.b	aidef(a3),temp1(a3)

	moveq	#awingd,d0
	move	puckc,d1
	bmi	.de0
	sub	#6,d1
	move	SCnum(a3),d2
	sub	#6,d2
	eor	d2,d1
	bmi	assreplace
.de0
	move	pucky,d0
	move	puckvy,d3
	asr	#6,d3
	add	d0,d3
	btst	#pfgoal,pflags(a3)
	bne	.de1
	neg	d0
	neg	d3
.de1
	clr	d2	;set zone number
	move	blueline,d1
	neg	d1
	cmp	d1,d3
	blt	.de2
	add	#8,d2
	neg	d1
	cmp	d1,d0
	blt	.de2
	add	#8,d2
	add	#goalline,d1
	cmp	d1,d3
	blt	.de2
	add	#8,d2
.de2	cmp	temp5(a3),d2
	bne	.de3
	move	#200,d0
	bsr	randomd0
	tst	d0
	bne	.nodec
.de3	move	d2,temp5(a3)
	move.l	#.dedata,a0
	move	2(a0,d2),d0
	bsr	randomd0s
	add	(a0,d2),d0
	move	d0,temp3(a3)
	move	6(a0,d2),d0
	bsr	randomd0s
	add	4(a0,d2),d0
	move	d0,temp4(a3)
	bra	.nodec
.dedata
	dc.w	80,20,-70,10	;in own zone
	dc.w	100,20,60,10	;center ice area
	dc.w	60,50,230,20	;opp zone
	dc.w	80,30,250,20	;past goalline
.nodec
	move	temp3(a3),d0
	cmp	#5,position(a3)
	beq	.1
	neg	d0
.1
	move	temp4(a3),d1
	btst	#pfgoal,pflags(a3)
	bne	.0
	neg	d0
	neg	d1
.0
	move.l	#EvadePC,a0
	bra	skateto

asscenterd	;player a3 is center on defense
	btst	#gmclock,gmode
	bne	donothing
	bsr	check4bench
	btst	#pfjoycon,pflags(a3)
	bne	rtss
	bclr	#pfna,pflags(a3)
	beq	.nna
	clr	temp1(a3)
	move	#8,temp2(a3)
.nna
	sub.b	d7,temp1(a3)
	bpl	.nodec
	move.b	aidef(a3),temp1(a3)

	move	puckc,d1
	bmi	.de0
	moveq	#acentero,d0
	sub	#6,d1
	move	SCnum(a3),d2
	sub	#6,d2
	eor	d2,d1
	bpl	assreplace
.de0
.nodec
	move	puckx,d0
	asr	#1,d0
	move	blueline,d1
	add	#40,d1
	btst	#pfgoal,pflags(a3)
	beq	.0
	neg	d1
	move	blueline,d2
	neg	d2
	cmp	pucky,d2
	bgt	.z1
	add	pucky,d1
	asr	#1,d1
	bra	.z1
.0
	move	blueline,d2
	cmp	pucky,d2
	blt	.z1
	add	pucky,d1
	asr	#1,d1

.z1	move.l	#rtss,a0
	bra	skateto


asscentero	;player a3 is center on offense
	btst	#gmclock,gmode
	bne	donothing
	bsr	check4bench
	btst	#pfjoycon,pflags(a3)
	bne	rtss
	bclr	#pfna,pflags(a3)
	beq	.nna
	st	temp5(a3)	;old zone number
	clr	temp1(a3)
	move	#8,temp2(a3)
.nna
	sub.b	d7,temp1(a3)
	bpl	.nodec
	move.b	aidef(a3),temp1(a3)

	move	puckc,d1
	bmi	.de0
	moveq	#acenterd,d0
	sub	#6,d1
	move	SCnum(a3),d2
	sub	#6,d2
	eor	d2,d1
	bmi	assreplace
.de0
	move	pucky,d0
	btst	#pfgoal,pflags(a3)
	bne	.de1
	neg	d0
.de1	move	blueline,d1
	neg	d1
	clr	d2	;set zone number
	cmp	d1,d0
	blt	.de2
	add	#8,d2
	neg	d1
	cmp	d1,d0
	blt	.de2
	add	#8,d2
	add	#goalline,d1
	cmp	d1,d0
	blt	.de2
	add	#8,d2
.de2	cmp	temp5(a3),d2
	bne	.de3
	move	#200,d0
	bsr	randomd0
	tst	d0
	bne	.nodec
.de3	move	d2,temp5(a3)
	move.l	#.dedata,a0
	move	2(a0,d2),d0
	bsr	randomd0s
	add	(a0,d2),d0
	move	d0,temp3(a3)
	move	6(a0,d2),d0
	bsr	randomd0s
	add	4(a0,d2),d0
	move	d0,temp4(a3)
	bra	.nodec
.dedata
	dc.w	00,60,-70,10
	dc.w	00,60,60,10
	dc.w	00,40,170,30
	dc.w	00,80,170,20
.nodec
	move	temp3(a3),d0
	move	temp4(a3),d1
	btst	#pfgoal,pflags(a3)
	bne	.0
	neg	d1
.0
	move.l	#EvadePC,a0
	bra	skateto

assgoalie	;player a3 is goalie
	bsr	check4bench
	bclr	#pfna,pflags(a3)
	beq	.nna
	clr	temp1(a3)
	move	#8,temp2(a3)
	move	#-1,temp5(a3)
.nna
	cmp	#200,Ypos(a3)
	bgt	.noskate
	cmp	#-200,Ypos(a3)
	blt	.noskate
	move.l	#rtss,a0
	clr	d0
	move	#250,d1
	btst	#pfgoal,pflags(a3)
	beq	skateto
	neg	d1
	bra	skateto
.noskate
	btst	#pf2aip,pflags2(a3)
	bne	rtss
	move	#SPAgready,d1
	bsr	SetSPA
	btst	#gmclock,gmode
	bne	rtss

	tst	temp5(a3)
	bmi	.nofo
	move	SCnum(a3),d0
	cmp	puckc,d0
	beq	.mbfo
	st	temp5(a3)
	bra	.nofo
.mbfo
	sub	d7,temp5(a3)
	bpl	.nofo
	move.l	#PenGhold,d0
	bsr	AddPenalty2
.nofo
	sub.b	d7,temp1(a3)
	bpl	.nodec
	move.b	aidef(a3),d0
	lsr.b	#1,d0
	move.b	d0,temp1(a3)

	btst	#pfjoycon,pflags(a3)
	bne	.de1

	move	SCnum(a3),d0
	cmp	puckc,d0
	bne	.de1
	move	HVcount,d0
	and	#7,d0
	bne	.de1
	move	#1,threat
	bsr	chk4pass
.de1
	move	#puckcross,a0
	move	pucky,d2
	move	puckc,d3
	cmp	ScNum(a3),d3
	bne	.denpc
	asr	#1,d2
.denpc
	move	blueline,d3
	add	#goalline,d3
	btst	#pfgoal,pflags(a3)
	beq	.de2
	add	#4,a0
	add	d3,d2	;do bottom goalie
	bpl	.de10
	clr	d2
.de10
	move	d2,d1
	asr	#3,d2
	sub	d3,d2
	add	#5,d2
	neg	d3
	cmp	Ypos(a3),d3
	blt	.de3
	add	#60,d2
	bra	.de3

.de2
	sub	d3,d2	;do top goalie
	bmi	.de20
	clr	d2
.de20
	move	d2,d1
	asr	#3,d2
	add	d3,d2
	sub	#5,d2
	cmp	Ypos(a3),d3
	bgt	.de3
	sub	#60,d2
.de3
	move	puckx,d0
	bsr	vtoa
	cmp	#7,d0
	bgt	.de4
	move	d0,facedir(a3)
.de4
	move	puckvx,d0
	asr	#8,d0
	add	puckx,d0
	asr	#2,d0
	cmp	#40,2(a0)	;frames til crossing
	bhi	.de5
	cmp	#24,(a0)
	bgt	.de5
	cmp	#-24,(a0)
	blt	.de5

	cmp	#15,2(a0)
	bhi	.de8
	bset	#pf2aip,pflags2(a3)
	bne	.de8

	move	(a0),d0
	sub	Xpos(a3),d0
	move	d3,d1	;goalline
	sub	Ypos(a3),d1
	bsr	vtoa
	sub	facedir(a3),d0
	and	#7,d0
	lsr	#2,d0	;glove
	btst	#3,attribute(a3)
	beq	.noflip
	eor	#1,d0
.noflip
	cmp	#5,puckz
	bgt	.de7
	cmp	#$800,puckvz
	bgt	.de7
	add	#2,d0	;stack
	cmp	#10,2(a0)
	bhi	.de7
	add	#2,d0	;stick
.de7	asl	#1,d0
	move.l	#.list,a1
	move	0(a1,d0),d1
	bsr	SetSPA
	add	#150,crowdlevel
.de8
	move.b	puckvx,d0
	ext	d0
	neg	d0
	asr	#2,d0
	add	(a0),d0
.de5
	move	d2,d1

	movem	d0-d1,-(a7)
	move	Xvel(a3),d0
	asr	#8,d0
	neg	d0
	add	(a7)+,d0
	sub	Xpos(a3),d0
	move	Yvel(a3),d1
	asr	#8,d1
	neg	d1
	add	(a7)+,d1
	sub	Ypos(a3),d1

	cmp	#5,d0
	bgt	.vt
	cmp	#-5,d0
	blt	.vt
	cmp	#5,d1
	bgt	.vt
	cmp	#-5,d1
	blt	.vt
	clr	d0
	clr	d1
.vt	bsr	vtoa
	move.b	d0,temp2+1(a3)

.nodec
	move.b	temp2+1(a3),d2
	ext	d2
	cmp	#7,d2
	ble	playeracc
	bra	stopna

.list	dc.w	SPAgglover
	dc.w	SPAgglovel
	dc.w	SPAgstackr
	dc.w	SPAgstackl
	dc.w	SPAgstickr
	dc.w	SPAgstickl

asspuckc	;player a3 is puck handler
	btst	#gmclock,gmode
	bne	donothing
	btst	#pfjoycon,pflags(a3)
	bne	assexit
	bclr	#pfna,pflags(a3)
	beq	.nna
	moveq	#4,d0
	bsr	randomd0
	move	d0,temp3(a3)
	clr	temp1(a3)
	move	#8,temp2(a3)
;	bra	.nna
.nna
	move	puckc,d0
	cmp	SCnum(a3),d0
	bne	assexit

	sub.b	d7,temp1(a3)
	bpl	.nodec
	move.b	aioff(a3),temp1(a3)

	bsr	checkob
	bsr	chk4lc
	bsr	chk4shot
	bsr	chk4pass
.de0

.nodec
	btst	#sf2offsig,sflags2
	beq	.onside
	move.l	#.postab2,a0
	move	position(a3),d0	;someone is over the line
	sub	#1,d0
	bra	.nd1

.onside	move	position(a3),d0
	sub	#1,d0	;not for goalie
	asl	#2,d0
	add	temp3(a3),d0
	move.l	#.postab,a0
.nd1
	asl	#2,d0
	move	2(a0,d0),d1
	move	0(a0,d0),d0
	btst	#pfgoal,pflags(a3)
	bne	.nd0
	neg	d0
	neg	d1
.nd0
	move.l	#.chkdir,a0
	bra	skateto

.chkdir
	ext	d0
	move.b	Xvel(a3),d2
	ext	d2
	add	puckx,d2
	move.b	Yvel(a3),d3
	ext	d3
	add	pucky,d3
	
	clr	threat
	moveq	#5,d4
	move.l	#SortCords,a0
	cmp	#6,SCnum(a3)
	bge	.cd0
	add	#6*SCstruct,a0
.cd0	move.b	Xvel(a0),d1
	ext	d1
	add	Xpos(a0),d1
	sub	d2,d1
	cmp	#20,d1
	bgt	.next
	cmp	#-20,d1
	blt	.next
	move.b	Yvel(a0),d1
	ext	d1
	add	Ypos(a0),d1
	sub	d3,d1
	cmp	#20,d1
	bgt	.next
	cmp	#-20,d1
	blt	.next
	add	#1,threat

	move	Xpos(a3),d0
	sub	Xpos(a0),d0
	move	Ypos(a3),d1
	sub	Ypos(a0),d1
	bsr	vtoa
	move	facedir(a3),d1
	eor	#4,d1
	cmp	d0,d1
	bne	.next
	add	#1,d0
	and	#7,d0
	
.next	add	#SCstruct,a0
	dbf	d4,.cd0
	rts

.postab
	dc.w	-40,250,-20,240,20,240,40,250
	dc.w	-40,250,-20,240,20,240,40,250
	dc.w	-40,250,-20,240,20,240,40,250
	dc.w	-40,250,-20,240,20,240,40,250
	dc.w	-40,250,-20,240,20,240,40,250
	dc.w	-40,250,-20,240,20,240,40,250

	
	dc.w	-110,110,-90,110,-70,110,-20,110	;left def
	dc.w	110,110,90,110,70,110,20,110	;right def
	dc.w	-110,250,-90,200,-70,220,-20,150	;left wing
	dc.w	-60,150,-10,220,30,220,60,180	;center
	dc.w	110,250,90,200,70,220,20,150	;right wing
	dc.w	-60,150,-10,220,30,220,60,180	;center

.postab2
	dc.w	-100,-20,100,-20
	dc.w	-120,40,20,40,120,40,-20,40

chk4lc	;see if computer should call line change
	move	pucky,d0
	btst	#pfgoal,pflags(a3)
	bne	.gu
	neg	d0
.gu	tst	d0
	bmi	rtss
	cmp	blueline,d0
	bgt	rtss

	move	HVcount,d0
	and	#3,d0
	bne	rtss
	btst	#pf2lcm,pflags2(a3)
	bne	rtss

	move	#tmstruct,a2
	lea	tmsize(a2),a1
	btst	#pfteam,pflags(a3)
	beq	.0
	exg	a2,a1
.0
	bsr	AvgCline
	cmp	#$c00,d0
	bhi	rtss
	bsr	CompLine
	bsr	setpersonel
	bsr	printscores1
	bra	CompShoot

chkpk	;return z flag set if killing penalty
	;return z flag clr if not
	btst	#sf2pwrplay,sflags2
	beq	rtss
chkpk2	btst	#sf2pwrtm,sflags2
	move	sr,d0
	btst	#pfteam,pflags(a3)
	move	sr,d1
	eor	d1,d0
	bchg	#2,d0
	move	d0,ccr
	rts

chk4shot	;player a3 looks for shot (computer controlled)
	bsr	chkpk
	beq	.npk	;not pkilling
	tst	threat
	beq	.npk	;no threat
	move	HVcount,d0
	and	#3,d0
	beq	CompShoot	;clear puck (no icing if pkilling)

.npk	moveq	#32,d4
	sub.b	spodds(a3),d4	;shot/pass odds
	asl	#4,d4

	move	blueline,d1
	add	#goalline,d1
	btst	#pfgoal,pflags(a3)
	bne	.c0
	neg	d1
.c0
	sub	pucky,d1
	move	puckx,d0
	neg	d0
	movem	d0-d1,-(a7)
	muls	d0,d0
	muls	d1,d1
	add.l	d0,d1	;distance from goal squared
	;cmp.l	#100^2,d1
	cmpi.l  #(100*100),d1 ; Calculate value
	movem	(a7)+,d0-d1
	bhi	.no1
	lsr	#4,d4
	bsr	vtoa
	move	d0,d5
	moveq	#5,d3
	move.l	#SortCords,a1
	cmp	#6,SCnum(a3)
	bge	.co0
	add	#6*SCstruct,a1
.co0	move	Xpos(a1),d0
	sub	puckx,d0
	move	Ypos(a1),d1
	sub	pucky,d1
	bsr	vtoa
	cmp	d5,d0
	bne	.co1
	asl	#1,d4
.co1	add	#SCstruct,a1
	dbf	d3,.co0

.no1	move	d4,d0
	bsr	randomd0
	cmp	#8,d0
	bgt	rtss

	move	pucky,d0
	btst	#pfgoal,pflags(a3)
	bne	.ds0
	neg	d0
.ds0	tst	d0
	bmi	rtss	;don't shoot from behind center line
	move	blueline,d1
	add	#goalline,d1
	sub	d0,d1
	bmi	rtss
	btst	#sf2offsig,sflags2
	bne	rtss	;player is offsides
CompShoot	;player a3 shoots (computer controlled player)
	add	#4,a7	;don't return

	move	pucky,d0
	btst	#pfgoal,pflags(a3)
	bne	.ds0
	neg	d0
.ds0	move	blueline,d1
	add	#goalline,d1
	sub	d0,d1
	lsr	#3,d1
	cmp	#20,d1
	blt	.lt
	moveq	#20,d1
.lt	move	d1,temp2(a3)	;swing time

	moveq	#8,d0
	moveq	#5,d1
	move	#SortCords-SCstruct,a0
	btst	#pfteam,pflags(a3)
	bne	.0
	add	#6*SCstruct,a0
.0	add	#SCstruct,a0
	tst	position(a0)
	dbeq	d1,.0
	bne	.f
	moveq	#2,d0
	cmp	#-8,Xpos(a0)
	blt	.f
	moveq	#6,d0
	cmp	#8,Xpos(a0)
	bgt	.f
	moveq	#9,d0
	bsr	randomd0
.f	move	d0,temp1(a3)
.nogoalie	moveq	#ashoot,d0
	bra	assreplace

chk4pass	;player a3 looks for good pass (computer controlled)
	tst	threat
	bne	.dp0
	moveq	#16,d0
	add.b	spodds(a3),d0
	bsr	randomd0
	cmp	#8,d0	
	bgt	rtss
.dp0
	moveq	#6,d0	;set up pass assignment
	bsr	randomd0
	cmp	#6,SCnum(a3)
	blt	.dp1
	add	#6,d0
.dp1
	cmp	SCnum(a3),d0
	beq	rtss	;don't pass to yourself
	asl	#scsize,d0
	move.l	#SortCords,a0
	add	d0,a0
	tst	position(a0)
	beq	rtss	;don't pass to goalie
	bmi	rtss	;don't pass to illegal player
	btst	#pf2unav,pflags2(a0)
	bne	rtss
	btst	#pfalock,pflags(a0)
	bne	rtss	;don't pass to locked player
;check for pass across blue line
	move	Ypos(a0),d0
	move	Ypos(a3),d1
	btst	#pfgoal,pflags(a3)
	bne	.f0
	neg	d0
	neg	d1
.f0	btst	#gmoffs,gmode
	beq	.oko
	movem	d0-d1,-(a7)
	sub	blueline,d0
	sub	blueline,d1
	eor	d0,d1
	movem	(a7)+,d0-d1
	bmi	rtss

.oko	cmp	blueline,d0
	bgt	.ok
	sub	d1,d0
	cmp	#-15,d0
	blt	rtss
.ok
	move	Xpos(a0),d0
	sub	puckx,d0
	move	Ypos(a0),d1
	sub	pucky,d1
	movem	d0-d1,-(a7)
	bsr	vtoa
	move	d0,passdir
	movem	(a7)+,d1-d2
	muls	d1,d1
	muls	d2,d2
	add.l	d1,d2

	moveq	#5,d3
	move.l	#SortCords,a1
	cmp	#6,SCnum(a3)
	bge	.co0
	add	#6*SCstruct,a1
.co0	move	Xpos(a1),d0
	sub	puckx,d0
	move	Ypos(a1),d1
	sub	pucky,d1
	movem	d0-d1,-(a7)
	muls	d0,d0
	muls	d1,d1
	add.l	d0,d1
	cmp.l	d2,d1
	movem	(a7)+,d0-d1
	bhi	.co1
	bsr	vtoa
	cmp	passdir,d0
	beq	rtss
.co1	add	#SCstruct,a1
	dbf	d3,.co0

	bsr	dopass
	tst	position(a3)
	beq	rtss
	add	#4,a7
	bra	assexit

EvadePC	;player a3 should avoid the puck carrier if he's on my team
	tst	puckc
	bmi	rtss	;no puck handler

	move.b	Xvel(a3),d2
	sub.b	puckvx,d2
	ext	d2
	add	Xpos(a3),d2
	sub	puckx,d2
	cmp	#40,d2
	bgt	rtss
	cmp	#-40,d2
	blt	rtss
	move.b	Yvel(a3),d1
	sub.b	puckvy,d1
	ext	d1
	add	Ypos(a3),d1
	sub	pucky,d1
	cmp	#40,d1
	bgt	rtss
	cmp	#-40,d1
	blt	rtss
	move	Xpos(a3),d0
	sub	puckx,d0
	move	Ypos(a3),d1
	sub	pucky,d1
;	move	d2,d0
	bra	vtoa

checkob	;bring up little warning ref if a player on your team is over blue line
	btst	#gmoffs,gmode
	beq	rtss
	movem.l	d0-d1/a0,-(a7)
	moveq	#5,d0
	move.l	#SortCords,a0
	cmp	#6,SCnum(a3)
	blt	.0
	add	#6*SCstruct,a0
.0	move	blueline,d1
	btst	#pfgoal,pflags(a3)
	bne	.top
	neg	d1
	cmp	pucky,d1
	bgt	.nob
.bottom
	tst	position(a0)
	bmi	.bn
	cmp	Ypos(a0),d1
	bgt	.ob
.bn	add	#SCstruct,a0
	dbf	d0,.bottom
.nob	moveq	#$40,d0
	bclr	#sf2offsig,sflags2
	bne	.dref
.ex	movem.l	(a7)+,d0-d1/a0
	rts

.ob	moveq	#32,d0
	bset	#sf2offsig,sflags2
	bne	.ex
.dref	tst	RefCnt
	bpl	.ex
	bsr	pushref
	bra	.ex

.top	cmp	pucky,d1
	blt	.nob
.top1
	tst	position(a0)
	bmi	.tn
	cmp	Ypos(a0),d1
	blt	.ob
.tn	add	#SCstruct,a0
	dbf	d0,.top1
	bra	.nob

assnearest	;this is a special assignment used for the player who is nearest the puck but doesn't have it
	bclr	#pfna,pflags(a3)
	beq	.nna
	clr	temp3(a3)
	move	#8,temp2(a3)
	clr	temp1(a3)
.nna
	moveq	#apuckc,d0
	move	SCnum(a3),d1
	cmp	puckc,d1
	bne	.nopc
	tst	position(a3)
	beq	assgoalie
	btst	#pfjoycon,pflags(a3)
	beq	assinsert
	rts
.nopc
	sub.b	d7,temp1(a3)
	bpl	.nodec
	move.b	aioff(a3),temp1(a3)

	move	puckc,d1
	bmi	.np
	asl	#scsize,d1
	move.l	#SortCords,a1
	add	d1,a1
	move.b	pflags(a1),d0
	move.b	pflags(a3),d1
	eor.b	d0,d1
	btst	#pfteam,d1
	beq	.switch

.np	moveq	#-1,d2
	moveq	#5,d4
	move.l	#SortCords,a0
	cmp	#6,SCnum(a3)
	blt	.de0
	add	#6*SCstruct,a0
.de0
	tst	position(a0)
	ble	.next
	tst	nopuck(a0)
	bne	.next
	btst	#pf2unav,pflags2(a0)
	bne	.next
	move.l	a0,-(a7)
	bsr	GetHot
	add	Xpos(a0),d0
	sub	puckx,d0
	tst	puckc
	bmi	.nvelx
	move	puckvx,d3
	asr	#6,d3
	sub	d3,d0
.nvelx
	muls	d0,d0
	add	Ypos(a0),d1
	sub	pucky,d1
	tst	puckc
	bmi	.nvely
	move	puckvy,d3
	asr	#6,d3
	sub	d3,d1
.nvely
	muls	d1,d1
	add.l	d1,d0
	cmp.l	d2,d0
	bhi	.next
	move.l	d0,d2
	move.l	a0,a1
.next	add	#SCstruct,a0
	dbf	d4,.de0
	tst.l	d2
	bmi	.de1

.switch	cmp.l	a1,a3
	beq	.de1
	btst	#gmclock,gmode
	bne	.de1
	btst	#pf2unav,pflags2(a1)
	bne	.de1

	exg.l	a1,a3
	bclr	#pfdoff,pflags(a3)
	moveq	#anearest,d0
	bsr	assinsert
	exg.l	a1,a3
	bra	assexit
.de1
	tst	position(a3)
	beq	rtss

;	clr	d1
;	cmp	#20^2,d2
;	bls	.nfar
	moveq	#2,d1
.nfar
	btst	#sf2pwrplay,sflags2
	beq	.x
	clr	d1
	bsr	chkpk2
	beq	.x	;is pwr play
	moveq	#4,d1

.x	moveq	#20,d0
	sub.b	aggress(a3),d0
	asl	d1,d0
	bsr	randomd0
	cmp	#2,d0
	bhi	.nodec
	move	#240,temp3(a3)
.nodec
	tst	position(a3)
	beq	rtss

	btst	#gmclock,gmode
	bne	donothing

	btst	#pfjoycon,pflags(a3)
	bne	rtss

	tst	puckc
	bmi	.topuck
	sub	d7,temp3(a3)
	bpl	.topuck
	clr	temp3(a3)

	move	blueline,d1
	add	#goalline-20,d1
	btst	#pfgoal,pflags(a3)
	bne	.nd0
	neg	d1
.nd0	add	pucky,d1
	asr	#2,d1
	neg	d1
	add	pucky,d1
	move	puckx,d0
	asr	#2,d0
	neg	d0
	add	puckx,d0	
	move.l	#rtss,a0
	bsr	skateto
	bra	check4check

.topuck	bsr	skatetopuck

check4check	;look for good opportunity for checking opponent
	moveq	#20,d0
	sub.b	aggress(a3),d0
	tst	optPen
	beq	.nopen
	asl	#1,d0
.nopen
	bsr	randomd0
	tst	d0
	bne	rtss
	moveq	#5,d2
	move.l	#SortCords,a0
	cmp	#6,SCnum(a3)
	bge	.0
	add	#6*SCstruct,a0
.0
	tst	position(a0)
	beq	.next
	move	Xpos(a0),d0
	sub	Xpos(a3),d0
	cmp	#30,d0
	bgt	.next
	cmp	#-30,d0
	blt	.next
	move	Ypos(a0),d1
	sub	Ypos(a3),d1
	cmp	#30,d1
	bgt	.next
	cmp	#-30,d1
	blt	.next
	bsr	vtoa
	cmp	facedir(a3),d0
	beq	burst
.next	add	#SCstruct,a0
	dbf	d2,.0
	rts

asspassrec	;assignment for catching pass
	btst	#gmclock,gmode
	bne	donothing
	btst	#pfjoycon,pflags(a3)
	bne	assexit
	bclr	#pfna,pflags(a3)
	beq	.nna
	bset	#pfdoff,pflags(a3)
	move.b	#8,temp2+1(a3)
.nna
	tst	puckc
	bmi	skatetopuck
	bclr	#pfdoff,pflags(a3)
	bra	assexit

assshoot	;assignment for computer shooting
	bclr	#pfna,pflags(a3)
	beq	.nna
	bra	SetShotMode
.nna
	btst	#sfssdir,sflags
	beq	assexit
	move	temp1(a3),d0
	clr	d2
	sub	d7,temp2(a3)
	bpl	ShotMode
	bset	#cbut,d2
	bra	ShotMode

pucknothing	;puck just slides along
	bra	puckunflip

puckfaceoff	;this is where the action starts
	bclr	#pfna,pflags(a3)
	beq	.nna
	tst	gameclock
	beq	PeriodOver
	cmp	#3,gsp
	bne	.npo
	move	tmstruct+tmscore,d0
	cmp	tmstruct+tmscore+tmsize,d0
	bne	PeriodOver
.npo	btst	#gmpendel,gmode
	bne	Stop4Pen
	bsr	returngoalies
	st	temp1(a3)
	st	temp2(a3)
	tst	OptLine
	bne	.nna
	move	cont1team,d0
	or	cont2team,d0
	beq	.nohor
	btst	#sfhor,sflags
	beq	.nohor
	bsr	forceblack
	bset	#sfslock,sflags
	bsr	clrhor
	move	#24,palcount
.nohor
	move	c1playernum,d0
	bmi	.nlp
	bsr	.slc
.nlp	move	c2playernum,d0
	bmi	.nlp2
	bsr	.slc
.nlp2	move	#tmstruct,a1
	lea	tmsize(a1),a2
	moveq	#2,d0
	bsr	.sclc
	bra	.nna

.sclc
	tst	OptLine
	bne	rtss
	cmp	cont1team,d0
	beq	rtss
	cmp	cont2team,d0
	beq	rtss
	bsr	CompLine
	bsr	setpersonel
	bra	printscores1

.slc	exg	a2,a3
	asl	#scsize,d0
	move	#SortCords,a3
	add	d0,a3
	bclr	#pf2lcm,pflags2(a3)
	move.l	a2,-(a7)
	bsr	SetLCmode
	move.l	(a7)+,a2
	btst	#pf2lcm,pflags2(a3)
	beq	.slcex
	btst	#pfteam,pflags(a3)
	beq	.t1
	move	#3*60,temp2(a2)
	move	SCnum(a3),temp4(a2)
	bra	.slcex
.t1	move	#5*60,temp1(a2)
	move	SCnum(a3),temp3(a2)
.slcex	exg	a2,a3
	rts
.nna	move	#temp1,d0
	bsr	.clc
	move	#temp2,d0
	bsr	.clc
	tst	temp1(a3)
	bpl	rtss
	tst	temp2(a3)
	bpl	rtss

	move	#tmstruct,a2
	lea	tmsize(a2),a1
	moveq	#1,d0
	bsr	.sclc
	move	#pfaceoff2,d0
	bra	assreplace

.clc	tst	0(a3,d0)
	bmi	rtss
	move	4(a3,d0),d1
	asl	#scsize,d1
	move.l	#sortcords,a0
	btst	#pf2lcm,pflags2(a0,d1)
	bne	.clnd
	st	0(a3,d0)
	rts
.clnd	sub	d7,0(a3,d0)
	bpl	rtss
	move.l	a3,-(a7)
	lea	0(a0,d1),a3
	btst	#pf2lcm,pflags2(a3)
	beq	.clcex
	clr	d2
	bsr	lcfound
.clcex	move.l	(a7)+,a3
	rts

ChkGoalies	;computer pulls goalie on delayed penalty
	move	#tmstruct,a2
	lea	tmsize(a2),a1
	moveq	#1,d0
	bsr	.CPG
	moveq	#2,d0
	exg	a1,a2
.CPG
	cmp	cont1team,d0
	beq	rtss
	cmp	cont2team,d0
	beq	rtss
	cmp	#2,tmgoalie(a2)
	beq	rtss
	move	puckc,d0
	bmi	rtss
	sub	#6,d0
	cmp	#tmstruct,a2
	beq	.0
	neg	d0
.0	tst	d0
	bpl	rtss
	move	pucky,d1
	btst	#gmpendel,gmode
	beq	CPgoalie
	move	#2,tmgoalie(a2)
	bra	SetPersonel

ReturnGoalies
	;if computer pulled goalie, look to see if computer should return him
	move	#tmstruct,a2
	lea	tmsize(a2),a1
	moveq	#1,d0
	bsr	.r
	moveq	#2,d0
	exg	a1,a2

.r	cmp	cont1team,d0
	beq	rtss
	cmp	cont2team,d0
	beq	rtss
	cmp	#2,tmgoalie(a2)
	bne	rtss
	clr	tmgoalie(a2)
	move	foy,d1
CPgoalie	;see if computer should pull his goalie
	cmp	#2,gsp
	bne	rtss	;exit if not 3rd per.
	move	tmscore(a1),d0
	sub	tmscore(a2),d0
	bmi	rtss	;exit if leading the game
	cmp	#2,d0
	bne	rtss	;exit if behind by more than 2
	cmp	#60,gameclock
	bgt	rtss	;exit if more than 1 min left
	move.l	a0,-(a7)
	move.l	tmsort(a2),a0
	btst	#pfgoal,pflags(a0)
	move.l	(a7)+,a0
	bne	.0
	neg	d1
.0	tst	d1
	bmi	rtss
	move	#2,tmgoalie(a2)
	bra	SetPersonel

CompLine	;find good line for comp to switch to
	movem.l	d0-d2/a0,-(a7)
	moveq	#3,d0
	move	tmap(a2),d1
	sub	tmap(a1),d1
	beq	.nopwr
	bpl	.0
	add	#2,d0
.0	move	d0,-(a7)	;find pk/pwr line
	bsr	getlinee
	move	d0,d1
	move	(a7),d0
	add	#1,d0
	bsr	getlinee
	cmp	d0,d1
	bge	.1
	add	#1,(a7)
.1	move	(a7)+,tmline(a2)
.ex	movem.l	(a7)+,d0-d2/a0
	rts

.nopwr	cmp	#tmstruct,a2	;find normal line
	bne	.away
	moveq	#2,d1
	move.l	#.hl1,a0
	cmp	#2,gsp
	bne	.h0
	move	tmscore(a2),d2
	cmp	tmscore(a1),d2
	beq	.h0
	add	#14,a0
	bgt	.a0
	add	#14,a0
.h0	move	tmline(a1),d1
	asl	#1,d1
	move	0(a0,d1),d0
	bsr	getlinee
	cmp	#3*$1000/4,d0
	bls	.away
	move	0(a0,d1),tmline(a2)
	bra	.ex

.hl1	dc.w	0,1,2,0,1,0,1
	dc.w	2,0,1,2,0,2,0
	dc.w	0,1,0,0,1,0,1

.away	moveq	#2,d1
	move.l	#.al1,a0
	cmp	#2,gsp
	bne	.a0
	move	tmscore(a2),d2
	cmp	tmscore(a1),d2
	beq	.a0
	add	#6,a0
	bgt	.a0
	add	#6,a0
.a0	move	(a0)+,d0
	bsr	getlinee
	cmp	#19*$1000/20,d0
	dbhi	d1,.a0
	move	-(a0),tmline(a2)
	bra	.ex

.al1	dc.w	0,1,2
	dc.w	0,2,1
	dc.w	0,1,0

puckfaceoff2	;face off control logic and general setup for action
	bclr	#pfna,pflags(a3)
	beq	.nna	;not first time thru

	movem.l	d0-d7/a0-a6,-(a7)
	bsr	forceblack

.p	btst	#dfok,disflags
	bne	.p	;wait for vblank

	cmp	#600,crowdlevel
	bls	.ntm
	move	#600,crowdlevel	;limit crowd level
.ntm
	bset	#dfclock,disflags	;stop clock
	bclr	#sfpz,sflags	;no pause
	bclr	#sf3llcs,sflags3	;no line changes
	clr	glovecords	;no fighting gloves
	clr.b	iflags	;no icing
	st	RefCnt	;no refs
	st	puckcross+2	;no goalie moes
	st	puckcross+6
	bclr	#sf2refref,sflags2
	bset	#sf2faceoff,sflags2
	bset	#sf2drec,sflags2	;don't record yet
	bsr	ClrHor	;vertical icerink
	clr	Vpos	;center h/v pos
	clr	Hpos
	move	fox,puckx
	move	foy,pucky
	st	puckz	;no visible puck
	clr	puckvx
	clr	puckvy
	clr	puckvz
	st	puckc

	move	#SortCords+(12*SCstruct),a0	;reposition goal nets
	clr	Xvel(a0)
	clr	Yvel(a0)
	clr	Xpos(a0)
	move	#268,Ypos(a0)
	add	#SCstruct,a0
	clr	Xvel(a0)
	clr	Yvel(a0)
	clr	Xpos(a0)
	move	#-268,Ypos(a0)

	move	#SortCords+((puckSCnum+1)*SCstruct),a0
	move	#SPFpuck,Frame(a0)
	clr	SPA(a0)
	clr	attribute(a0)
	clr	SortCords+(puckSCnum*SCstruct)+attribute

	bclr	#sfslock,sflags	;free up scrolling
	moveq	#100,d4
.cw	bsr	checkwindow	;scroll to faceoff spot
	dbf	d4,.cw
	move	#60,yleader

	bsr	ResetBench
	move	#tmstruct,a2
	bsr	setpersonel
	bsr	forcepldata
	add	#tmsize,a2
	bsr	setpersonel
	bsr	forcepldata
	bsr	resetplstuff

	move.l	a3,-(a7)
	move	#SortCords,a3
	moveq	#11,d2
.l0
	move	#-240,Xpos(a3)
	clr	Ypos(a3)
	clr	frame(a3)
	move	position(a3),d1
	bmi	.next
	beq	.goalie1
	moveq	#afaceoff,d0
	cmp	#4,d1
	bne	.l1
	moveq	#afaceoffpl,d0
.l1
	bsr	assinsert
.goalie1
	move	tmstruct+tmap,d4
	btst	#pfteam,pflags(a3)
	beq	.t0
	move	tmstruct+tmap+tmsize,d4
.t0	neg	d4
	add	#6,d4
	asl	#3,d4
	move.l	#.apl,a1
	add	d4,a1
	move.b	0(a1,d1),d4
	asl	#2,d4
	move.l	#.ptab,a1
	move	0(a1,d4),d0
	move	2(a1,d4),d1
	btst	#pfgoal,pflags(a3)
	bne	.f0
	neg	d0
	neg	d1
.f0	tst	position(a3)
	beq	.goalie2
	cmp	#2*4,d4
	bgt	.nodef
	move	fox,d3
	eor	d0,d3
	bpl	.notmid
	move	foy,d3
	asr	#3,d3
	sub	d3,d1
.notmid	move	fox,d3
	asr	#2,d3
	sub	d3,d0
.nodef
	add	fox,d0
	add	foy,d1
.goalie2
	move	d0,Xpos(a3)
	move	d1,Ypos(a3)
	clr	Xvel(a3)
	clr	Yvel(a3)
	sub	puckx,d0
	sub	pucky,d1
	neg	d0
	neg	d1
	bsr	vtoa
	move	d0,facedir(a3)
	bclr	#pf2unav,pflags2(a3)
	bclr	#pfalock,pflags(a3)
	move	#SPAglide,d1
	bsr	SetSPA	
.next	add	#SCstruct,a3
	dbf	d2,.l0
	bsr	SprSort
	move.l	(a7)+,a3

	move	#-1,c1playernum
	move	#-1,c2playernum
	tst	cont1team
	beq	.nt1
	clr	d4
	bsr	changeplayer
.nt1	tst	cont2team
	beq	.nt2
	moveq	#2,d4
	bsr	changeplayer
.nt2
	bsr	printz
	string	-$01,0,0
	moveq	#8+46,d0
	tst	fox
	bpl	.fok
	move	#(18*8)+46,d0
.fok
	move	d0,fodropx
	sub	#46,d0
	asr	#3,d0
	move	d0,printx
	moveq	#(3*8)+68,d0
	move	d0,fodropy
	sub	#68,d0
	asr	#3,d0
	move	d0,printy
	move	ExtraChars,d4	;space for faceoff map
	move.l	#FaceOffMap,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	(a2)+,a0
	add.l	(a2)+,a1
	clr	d0
	clr	d1
	moveq	#12,d2
	moveq	#10,d3
	moveq	#%0000,d5
	bsr	dobitmap

	add	(a2),d4
	move	d4,faceoffvrcset	;space for faceoff sprites
	move.l	#FaceOffframelist,a0
	move.l	#FaceOffsprites,a1
	bsr	Buildframelist
	move	d4,d1
	move	(a0)+,d0
	add	d0,d4
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMA

	move	#120,d0
	bsr	randomd0
	add	#180,d0
	move	d0,temp1(a3)	;time for puck drop
	move	#24,palcount
	move.l	#fofdata,a0
	move	#1,(a0)
	move	#$8000,2(a0)
	move	#4,4(a0)
	move	#$a800,6(a0)
	move	#7,8(a0)	;frame of ref
	move	#$8000,10(a0)
	btst	#gmdir,gmode
	bne	.nfl
	eor	#$0800,2(a0)
	eor	#$0800,6(a0)
.nfl	move	#-1,fodir1
	move	#-1,fodir2
	movem.l	(a7)+,d0-d7/a0-a6
	rts
.nna
	sub	d7,temp1(a3)
	bpl	updatefaceoff
	bra	Endfaceoff

.apl
	dc.b	0,1,2,3,4,5,6,0
	dc.b	0,1,5,3,4,2,0,0
	dc.b	0,3,5,1,4,0,0,0
.ptab
	dc.w	0,-250
	dc.w	-35,-50
	dc.w	35,-50
	dc.w	-50,-10
	dc.w	0,-15
	dc.w	50,-10
	dc.w	0,-60

updatefaceoff
	;a3 = puck
	move	temp1(a3),d0
	add	#6,d0
	lsr	#3,d0
	cmp	#2,d0
	bgt	rtss
	neg	d0
	add	#10,d0
	move	d0,fofdata+8
	rts

Endfaceoff
	move	#SFXpuckice,-(a7)
	bsr	sfx
	bclr	#sf2faceoff,sflags2
	bsr	printz
	string	-$41,0,0
	move	fodropx,d0
	sub	#46,d0
	asr	#3,d0
	move	d0,printx
	moveq	#(4*8)+68,d0
	move	fodropy,d0
	sub	#68,d0
	asr	#3,d0
	move	d0,printy
	moveq	#12,d0
	moveq	#10,d1
	moveq	#1,d2
	bsr	eraser

	move	ExtraChars,d1
	move.l	#RefsMap+8,a0
	move	(a0)+,d0
	asl	#4,d0
	asl	#5,d1
	bsr	DoDMAPro	;ref cam chars

	bclr	#sf2drec,sflags2
	bclr	#gmclock,gmode
	bclr	#pf2fight,pflags2(a3)

	move	fodir1,d3	;figure out who won face off
	move	#$800,d4
	move.l	#.ftab,a0
	move	#fofdata,a1
	moveq	#16,d2
	move	(a1),d1
	sub.b	-1(a0,d1),d2
	move	4(a1),d1
	add.b	-1(a0,d1),d2
	moveq	#33,d0
	bsr	randomd0
	cmp.b	d0,d2
	bls	.p1won
	add	#4,a1
.p1won	btst	#3,2(a1)
	beq	.pos
	move	fodir2,d3
	neg	d4
.pos	move	d3,d0
	btst	#3,d0
	bne	.nojoy
	and	#7,d0
	move	hvcount,d1
	and	#3,d1
	bne	.nj2
.nojoy	moveq	#5,d0
	bsr	randomd0
	sub	#2,d0
	and	#7,d0
	tst	d4
	bmi	.nj2
	eor	#4,d0
.nj2	asl	#2,d0
	move.l	#dirtab,a0
	move	0(a0,d0),d1
	asl	#5,d1
	move	d1,Xvel(a3)
	move	2(a0,d0),d1
	asl	#5,d1
	add	d4,d1
	move	d1,Yvel(a3)
	move	#$800,d0
	bsr	randomd0
	move	d0,Zvel(a3)
	clr	puckz
	bclr	#pfnc,pflags(a3)
	moveq	#pnorm,d0
	bra	assreplace

.ftab
	dc.b	0,8,16,0,8,16

pucknorm	;assignment for puck most of the time
	;a3 = puck
	;d7 = elapse frames since last call
	bclr	#pfna,pflags(a3)
	beq	.nna
	clr	temp1(a3)
.nna
	move.l	#puckcross,a1	;table for puck crossing lines
	sub	d7,2(a1)	;sub elapse frames from time til crossing
	sub	d7,6(a1)
	sub	d7,temp1(a3)
	bpl	.0
	add	#5,temp1(a3)
	bsr	findpc
.0
	move	puckc,d0
	bmi	.nothandled
	asl	#scsize,d0
	move.l	#sortcords,a2
	add	d0,a2
	bsr	a2touchpuck
	move.l	a2,-(a7)
	bsr	GetHot
	add	Xpos(a2),d0	;bunjy the puck towards the hot spot on player a2
	sub	Xpos(a3),d0
	asr	#2,d0
	add	d0,Xpos(a3)
	add	Ypos(a2),d1
	sub	Ypos(a3),d1
	asr	#2,d1
	add	d1,Ypos(a3)
	move	Xvel(a2),Xvel(a3)
	move	Yvel(a2),Yvel(a3)

.nothandled
	bsr	PuckIChk
	bsr	ChkOffsides
	tst.b	Zvel(a3)
	bne	checkpuckcoll
	tst	Zpos(a3)
	bne	checkpuckcoll
	bsr	puckunflip
	bra	checkpuckcoll

ChkOffsides	;check for offsides penalty
	;a3 = puck
	move	blueline,d0
	sub	#4,d0
	cmp	Ypos(a3),d0
	bgt	.neg
	cmp	OldYpos(a3),d0
	ble	rtss
	add	#10,d0
	bsr	.setsort
.0	cmp	Ypos(a0,d1),d0
	bge	.1
	bset	#pf3oside,pflags3(a0,d1)
.1	add	#SCstruct,a0
	dbf	d2,.0
	rts

.neg	neg	d0
	cmp	Ypos(a3),d0
	blt	rtss
	cmp	OldYpos(a3),d0
	bge	rtss
	sub	#10,d0
	bsr	.setsort
	eor	#6*SCstruct,d1
.2	cmp	Ypos(a0,d1),d0
	ble	.3
	bset	#pf3oside,pflags3(a0,d1)
.3	add	#SCstruct,a0
	dbf	d2,.2
	rts

.setsort
	moveq	#5,d2
	move.l	#SortCords,a0
	clr	d1
	btst	#gmdir,gmode
	beq	rtss
	move	#6*SCstruct,d1
	rts

a2offsides
	move	pucky,d0
	btst	#pfgoal,pflags(a2)
	bne	.0
	neg	d0
.0	cmp	blueline,d0
	blt	rtss
	moveq	#5,d0
	move.l	#SortCords,a0
	btst	#pfteam,pflags(a2)
	beq	.1
	add	#6*SCstruct,a0
.1	btst	#pf3oside,pflags3(a0)
	add	#SCstruct,a0
	dbne	d0,.1
	beq	rtss
	btst	#gmhl,gmode
	bne	rtss
	exg	a2,a3
	move.l	#PenOffsides,d0
	bsr	AddPenalty
	exg	a2,a3
	rts

a2touchpuck	;player a2 touches puck
	;look for penalties/offsides/other junk
	move	Xpos(a2),ltx
	move	Ypos(a2),lty
	move	SCnum(a2),ltplayer
	bclr	#sf2shot,sflags2
	bsr	a2Offsides
	btst	#ifok,iflags
	beq	.notice
	btst	#ifcgl,iflags
	beq	.notice
	tst	position(a2)
	beq	.notice
	btst	#ifdir,iflags
	bne	.up
	btst	#pfgoal,pflags(a2)
	beq	.notice
.icing	clr	d0
	move.b	iflags+1,d0
	asl	#scsize,d0
	move.l	a3,-(a7)
	move.l	#SortCords,a3
	add	d0,a3
	move	#PenIcing,d0
	bsr	AddPenalty
	move.l	(a7)+,a3
	rts
.up	btst	#pfgoal,pflags(a2)
	beq	.icing
.notice	clr.b	iflags
	move.b	Scnum+1(a2),iflags+1
	move	pucky,d0
	btst	#pfgoal,pflags(a2)
	beq	.0
	bset	#ifdir,iflags
	neg	d0
.0	bmi	rtss
	move	tmstruct+tmap,d0
	sub	tmstruct+tmap+tmsize,d0
	btst	#pfteam,pflags(a2)
	beq	.1
	neg	d0
.1	bmi	rtss
	bset	#ifok,iflags
	rts

PuckIChk	;check for icing of puck penalty
	btst	#ifok,iflags
	beq	rtss
	btst	#ifcgl,iflags
	bne	rtss
	tst	puckc
	bpl	rtss

	move	blueline,d0
	add	#goalline,d0
	btst	#ifdir,iflags
	bne	.0
	neg	d0
	cmp	pucky,d0
	bgt	.set
	rts
.0
	cmp	pucky,d0
	bgt	rtss
.set	bset	#ifcgl,iflags
	rts

puckunflip	;stop spinning puck
	;a3 = puck
	cmp	#2*4,SPAnum(a3)
	blt	.k
	cmp	#6*4,SPAnum(a3)
	bge	.k
	eor	#2,facedir(a3)
.k	or	#4,facedir(a3)
	clr	SPAnum(a3)
	st	SPAcnt(a3)
	rts		

puckflip	;start puck spinning
	;a3 = puck
	and	#1,d0
	eor	d0,facedir(a3)
	and	#3,facedir(a3)
	st	SPAcnt(a3)
	move	#SPApflip,d1
	bra	SetSPA

puckshadow	;assignment for puck shadow
	;a3 = puck shadow
	cmp	#SPFpuck,Frame(a3)
	bne	.siren	;shadow turns into siren on goals
	move	Xpos-SCstruct(a3),Xpos(a3)
	move	Ypos-SCstruct(a3),Ypos(a3)
	clr	Zpos(a3)
	moveq	#Ypos,d0
	btst	#sfhor,sflags
	beq	.nhor
	moveq	#Xpos,d0
.nhor	add	#1,0(a3,d0)
	rts

.siren	tst	frame(a3)
	beq	rtss
	clr	Xpos(a3)
	move	#300,Ypos(a3)
	move	#14,Zpos(a3)
	tst	Ypos-SCstruct(a3)
	bpl	.s0
	move	#$8000,attribute(a3)
	neg	Ypos(a3)
	sub	#1,Zpos(a3)
.s0	rts

findpc	;find puck crossing lines
	;calculate when puck will cross goalline (if at all)
	movem.l	d0-d4/a1-a2,-(a7)
	move.l	#puckcross,a1
	move	sideline,d1

	move	blueline,d4
	add	#goalline,d4
	bsr	.calc
	neg	d4
	bsr	.calc
	movem.l	(a7)+,d0-d4/a1-a2
	rts
.calc
	move	d4,d0
	sub	pucky,d0
	tst	puckvy
	beq	.nocross
	move	d0,d2
	swap	d2
	clr	d2
	asr.l	#4,d2
	divs	puckvy,d2
	bmi	.nocross
	move	d2,2(a1)	;time until crossing in frames

	muls	puckvx,d0
	divs	puckvy,d0
	bvs	.nocross
	add	puckx,d0
	cmp	d1,d0
	blt	.o1
	neg	d0
	add	d1,d0
	add	d1,d0
	add	d1,d0
.o1	neg	d1
	cmp	d1,d0
	bgt	.o2
	neg	d0
	add	d1,d0
	add	d1,d0
	add	d1,d0
.o2	neg	d1
	move	d0,(a1)
	bra	.next
.nocross
	move	#-1,2(a1)
.next	add	#4,a1
	rts

skateto
	;a0 = extra routine for collision avoidance
	;d0/d1 = x/y cord to skate to
	;d7 = elapse frames
	sub.b	d7,temp2(a3)
	bpl	.ex
	add.b	#12,temp2(a3)	;only execute every 12/60 sec.
	bsr	avdgoal
	move	deltax,d2
	or	deltay,d2
	beq	.norm
	sub	Xpos(a3),d0
	sub	Ypos(a3),d1
	bra	.vt
.norm
	movem	d0-d1,-(a7)
	move	Xvel(a3),d0
	asr	#8,d0
	neg	d0
	add	(a7)+,d0
	sub	Xpos(a3),d0
	move	Yvel(a3),d1
	asr	#8,d1
	neg	d1
	add	(a7)+,d1
	sub	Ypos(a3),d1

	cmp	#12,d0
	bgt	.vt
	cmp	#-12,d0
	blt	.vt
	cmp	#12,d1
	bgt	.vt
	cmp	#-12,d1
	blt	.vt
	moveq	#9,d0
	bra	.nvt
.vt	bsr	vtoa
.nvt
	jsr	(a0)
	move.b	d0,temp2+1(a3)
	cmp	#7,d0
	ble	.ex
	move	Xvel(a3),d0
	or	Yvel(a3),d0
	bne	.ex
	move	puckx,d0
	move	pucky,d1
	btst	#pf2fight,puckx+pflags2
	beq	.nf
	move	xc1,d0
	move	yc1,d1
.nf	sub	Xpos(a3),d0
	sub	Ypos(a3),d1	;face towards puck
	bsr	vtoa
	sub	facedir(a3),d0
	beq	.ex
	neg	d0
	and	#4,d0
	lsr	#1,d0
	sub	#1,d0
	add	facedir(a3),d0
	and	#7,d0
	move	d0,facedir(a3)

.ex	clr	d0
	move.b	temp2+1(a3),d0
	bra	doplayeracc

avdgoal
	;don't try to skate thru goal
	;if d0/d1 cords intersect thru goal then provide new d0/d1 cords
	;a3 = player
.xr	=	80
.yr	=	30
.ye	=	30
.gl	=	258
	clr	deltax
	clr	deltay
	tst	position(a3)
	beq	rtss
	move	Xpos(a3),d2
	eor	d0,d2
	bpl	.chbar
	move	d1,d2
	sub	Ypos(a3),d2
	move	Xpos(a3),d3
	muls	d3,d2
	sub	d0,d3
	divs	d3,d2
	add	Ypos(a3),d2

	cmp	#.gl+.yr,d2
	bgt	.chbar
	cmp	#.gl-.yr,d2
	blt	.lower
	move	#.gl+.yr+.ye,d3
	cmp	#.gl,d2
	bgt	.2
	blt	.1
	cmp	#.gl,Ypos(a3)
	bgt	.2
.1	move	#.gl-.yr-.ye,d3
.2	sub	d2,d3
	move	d3,deltay
	bra	.chbar

.lower	cmp	#-.gl+.yr,d2
	bgt	.chbar
	cmp	#-.gl-.yr,d2
	blt	.chbar
	move	#-.gl+.yr+.ye,d3
	cmp	#-.gl,d2
	bgt	.4
	blt	.3
	cmp	#-.gl,Ypos(a3)
	bgt	.4
.3	move	#-.gl-.yr-.ye,d3
.4	sub	d2,d3
	move	d3,deltay

.chbar
	move	d1,d3
	sub	#.gl,d3
	move	Ypos(a3),d2
	sub	#.gl,d2
	bsr	.ch1
	move	d1,d3
	add	#.gl,d3
	move	Ypos(a3),d2
	add	#.gl,d2
	bsr	.ch1
	add	deltax,d0
	add	deltay,d1
	rts

.ch1
	move	d3,d4
	eor	d2,d4
	bpl	rtss
	move	d0,d4
	sub	Xpos(a3),d4
	muls	d2,d4
	sub	d3,d2
	divs	d2,d4
	add	Xpos(a3),d4
	cmp	#.xr,d4
	bgt	rtss
	cmp	#-.xr,d4
	blt	rtss
	moveq	#.xr,d3
	tst	d4
	bne	.ch2
	tst	Xpos(a3)
.ch2	bpl	.ch3
	neg	d3
.ch3	sub	d4,d3
	move	d3,deltax
	rts

skatetopuck	;player a3 should skate to puck
	move.b	puckvx,d0
	asr.b	#1,d0
	ext	d0
	add	puckx,d0
	move.b	puckvy,d1
	asr.b	#1,d1
	ext	d1
	add	pucky,d1

	sub.b	d7,temp2(a3)
	bpl	.ex
	add.b	#10,temp2(a3)
	bsr	avdgoal
	movem	d0-d1,-(a7)
	move.l	a3,-(a7)
	bsr	GetHot
	neg.b	d0
	neg.b	d1
	sub.b	Xvel(a3),d0
	ext	d0
	add	(a7)+,d0
	sub	Xpos(a3),d0
	sub.b	Yvel(a3),d1
	ext	d1
	add	(a7)+,d1
	sub	Ypos(a3),d1	

	bsr	vtoa

	move.b	d0,temp2+1(a3)
;	cmp	facedir(a3),d0
;	bne	.ex

	move	puckvx,d0
	move	puckvy,d1
	bsr	vtoa
	eor	#4,d0
	cmp	facedir(a3),d0
	beq	.ex	;puck is coming towards players

	move	puckx,d0
	sub	Xpos(a3),d0
	move	pucky,d1
	sub	Ypos(a3),d1
	movem	d0-d1,-(a7)
	bsr	vtoa
	cmp	facedir(a3),d0
	movem	(a7)+,d0-d1
	bne	.ex
	muls	d0,d0
	muls	d1,d1
	add.l	d1,d0
	;cmp.l	#30^2,d0
	cmpi.l  #(30*30),d0   ; Calculate multiplication
	bls	.ex
	;cmp.l	#38^2,d0
	cmpi.l  #(38*38),d0   ; Calculate multiplication
	bls	Sweepcheck

.ex	move.b	temp2+1(a3),d0
	bra	doplayeracc

assexit 	;exit current assignment on player a3
	add	#1,assnum(a3)
	and	#%111,assnum(a3)
	bset	#pfna,pflags(a3)    ;signal next assignment
	rts

assinsert	;insert new assignment on player a3
	sub	#1,assnum(a3)
	and	#%111,assnum(a3)
assreplace	;replace current assignment on player a3
	move.l	d1,-(a7)
	move	assnum(a3),d1
	move.b	d0,asslist(a3,d1)
	bset	#pfna,pflags(a3)
	move.l	(a7)+,d1
	rts	

vtoa	;d0/d1 are x/y distances which are converted into direction 0-7 and returned in d0
	movem.l	d2/a0,-(a7)
	move	d0,d2
	or	d1,d2
	beq	.nodir
	clr	d2
	tst	d0
	bpl	.0
	neg	d0
	bset	#0,d2
.0	tst	d1
	bpl	.1
	neg	d1
	bset	#1,d2
.1	asl	#1,d1
	cmp	d1,d0
	bhi	.2
	bset	#2,d2
.2	lsr	#1,d1
	asl	#1,d0
	cmp	d0,d1
	bhi	.3
	bset	#3,d2
.3
	move.l	#.dt,a0
	clr	d0
	move.b	0(a0,d2),d0
	movem.l	(a7)+,d2/a0
	rts

.nodir	moveq	#8,d0
	movem.l	(a7)+,d2/a0
	rts

.dt	dc.b	1,7,3,5,0,0,4,4
	dc.b	2,6,2,6,1,7,3,5

GetHot	;push long address of structure to get hot spot from
	;hot spot x/y returned in d0/d1
	movem.l	a0-a1,-(a7)
	move.l	12(a7),a0
	clr	d0
	clr	d1
	tst	frame(a0)
	ble	.ex
	move	frame(a0),d0
	asl	#2,d0
	move.l	#framelist,a1
	move.l	-4(a1,d0),a1
	move	SprStrHot+12(a1),d0
	move	SprStrHot+14(a1),d1
	btst	#3,attribute(a0)
	beq	.nox
	neg	d0
.nox	btst	#4,attribute(a0)
	bne	.noy
	neg	d1
.noy
	btst	#sfhor,sflags
	beq	.nhor
	exg	d0,d1
	neg	d1
.nhor
.ex	movem.l	(a7)+,a0-a1
	move.l	(a7)+,(a7)
	rts

SetSPA	;set sprite animation on struct a3
	;d1 = new animation
	cmp	SPA(a3),d1
	beq	rtss
	clr	SPAnum(a3)
	move	d1,SPA(a3)
	st	SPAcnt(a3)	;restart animation
	rts

doplayeracc		;player a3 gets acc. in d0 dir
	tst	position(a3)
	beq	goalieacc	;goalie is special
	move	#SPAglide,d1
	btst	#pfrev,pflags(a3)
	beq	.d0
	move	#SPAglideback,d1
.d0	and	#%1111,d0
	cmp	#7,d0
	ble	.d1
	cmp	#9,d0
	bne	.cgl
	move	Xvel(a3),d0
	or	Yvel(a3),d0
	bne	DoStop
.cgl	btst	#pf2aip,pflags2(a3)
	beq	SetSPA
	rts
.d1
	movem	d0-d1,-(a7)
	move	d0,d2
	move	SCnum(a3),d0
	cmp	puckc,d0
	beq	.clrrev
	move	puckx,d0
	sub	Xpos(a3),d0
	move	Ypos(a3),d3
	move	puckvy,d1
	asr	#7,d1
	add	pucky,d1
	sub	d3,d1
	btst	#pfgoal,pflags(a3)
	bne	.c1
	neg	d0
	neg	d1
	neg	d3
	eor	#4,d2
.c1	btst	#pfrev,pflags(a3)
	bne	.inrev
	tst	d3
	bpl	.fwd	;skate back in own zone only
	cmp	#4,d2
	bne	.fwd
	bsr	vtoa
	add	#1,d0
	and	#7,d0
	cmp	#2,d0
	bhi	.fwd
	bra	.rev
.inrev
	sub	#3,d2
	and	#7,d2
	cmp	#2,d2
	bhi	.fwd
	bsr	vtoa
	add	#2,d0
	and	#7,d0
	cmp	#4,d0
	bhi	.fwd

.rev	btst	#pfrev,pflags(a3)
	bne	.done
	move	Xvel(a3),d0
	or	Yvel(a3),d0
	beq	.setrev
	move	Xvel(a3),d0
	move	Yvel(a3),d1
	bsr	vtoa
	sub	(a7),d0
	add	#1,d0
	and	#7,d0
	cmp	#2,d0
	bhi	.done
.setrev	bset	#pfrev,pflags(a3)
	bra	.done

.fwd
.clrrev	bclr	#pfrev,pflags(a3)

.done	movem	(a7)+,d0-d1

	
	move	facedir(a3),d2
	sub	d2,d0
	and	#7,d0
	
	move.l	#.ftab,a0
	asl	#1,d0
	tst	0(a0,d0)
	beq	noturn0

	move	Xvel(a3),d4
	muls	d4,d4
	move	Yvel(a3),d3
	muls	d3,d3
	add.l	d4,d3
	swap	d3
	move	#$300,d4
	sub	d3,d4
	cmp	#$180,d4
	bge	.iok
	move	#$180,d4
.iok	
	muls	0(a0,d0),d4
	btst	#pfrev,pflags(a3)
	beq	.i0
	neg.l	d4
.i0
	add.l	d4,facedir(a3)
	and	#7,facedir(a3)
	move	facedir(a3),d2

	cmp	#20,d3
	bls	.s3

	clr	d1
	tst	0(a0,d0)
	bpl	.s1
	eor	#SPAturnl-SPAturnr,d1
.s1	btst	#3,attribute(a3)
	beq	.s2
	eor	#SPAturnl-SPAturnr,d1
.s2
	add	#SPAturnr,d1
	bset	#pf2aip,pflags2(a3)
.s3
	bsr	SetSPA

	cmp	#2,d3
	bhi	noturn
	rts

.ftab	dc.w	0,$10,$10,$10,$0,-$10,-$10,-$10

goalieacc	;goalie gets acc. in direction d0
	move	#SPAgready,d1
	and	#%1111,d0
	cmp	#7,d0
	ble	.d1
	cmp	#9,d0
	bne	.cgl
	move	Xvel(a3),d0
	or	Yvel(a3),d0
	bne	StopNA
.cgl	btst	#pf2aip,pflags2(a3)
	beq	SetSPA
	rts
.d1	move	d0,facedir(a3)
	move	#SPAgskate,d1
	bsr	SetSPA
	move	d0,d2
	bra	playeracc

noturn0
	moveq	#2,d4
	btst	#pfrev,pflags(a3)
	beq	.0
	add	#4,d4
	eor	#8,d0
.0	tst	d0
	beq	.nochg
	move	Xvel(a3),d0
	move	Yvel(a3),d1
	bsr	vtoa
	btst	#3,d0
	bne	.nostop
	sub	facedir(a3),d0
	add	d4,d0
	and	#7,d0
	cmp	#4,d0
	blt	dostop

.nostop	add	#1,facedir(a3)
	btst	#3,attribute(a3)
	beq	.nos0
	sub	#2,facedir(a3)
.nos0	and	#7,facedir(a3)
	move	#SPAglide,d1
	btst	#pfrev,pflags(a3)
	beq	SetSPA
	move	#SPAglideback,d1
	bra	SetSPA

.nochg
	move	#SPAskateback,d1
	btst	#pfrev,pflags(a3)
	bne	.ns
	move	#SPAskate,d1
	move	puckc,d4
	cmp	SCnum(a3),d4
	bne	.ns
	move	#SPAskatewp,d1
.ns
	btst	#pf2aip,pflags2(a3)
	bne	noturn
	bsr	SetSPA

noturn
	btst	#pfrev,pflags(a3)
	beq	playeracc
	eor	#4,d2

playeracc	;d2=direction of acc
	asl	#2,d2
	move.l	#dirtab,a0
	move	2(a0,d2),d1	;y INC
	move	0(a0,d2),d0	;x inc
;check acc dir and don't push wall
	move	wallsin(a3),d2
	beq	.nox
	eor	d0,d2
	bpl	.nox
	clr	d0
.nox	move	wallcos(a3),d2
	beq	.noy
	eor	d1,d2
	bmi	.noy
	clr	d1
.noy
	clr	d2
	move.b	weight(a3),d2
	lsr	#4,d2
	neg	d2
	add	#32,d2
	add.b	legstr(a3),d2

	muls	d2,d0
	muls	d2,d1
	asr.l	#5,d0
	asr.l	#5,d1

	muls	d7,d0
	muls	d7,d1
	add	Xvel(a3),d0
	add	Yvel(a3),d1
	move	d0,d2
	move	d1,d3
	muls	d2,d2
	muls	d3,d3
	add.l	d2,d3

	movem	d0-d1,-(a7)
	bsr	getpde
	clr	d2
	move.b	legspd(a3),d2
	mulu	d0,d2
	asl.l	#4,d2
	swap	d2
	asl	#2,d2
	move.l	#MaxSpeed,a2
	move.l	0(a2,d2),d2
	movem	(a7)+,d0-d1

	cmp.l	d2,d3 ;max speed check
	bhi	.sube
	move	d0,Xvel(a3)
	move	d1,Yvel(a3)

.sube	tst	OptLine
	bne	rtss
	move	HVcount,d0
	and	#127,d0
	bne	rtss
	bsr	getpde
	sub	#33,d0
	cmp	#$c00,d0
	blt	setpde
	move.b	endurance(a3),d2
	ext	d2
	add	d2,d0
	bra	setpde

MaxSpeed	;max speed values for each rating level 0-f
	dc.l	((20*250)*(20*250))  ; Full calculation
	dc.l    ((21*250)*(21*250))    ; (1+20)
    dc.l    ((22*250)*(22*250))    ; (2+20)
    dc.l    ((23*250)*(23*250))    ; (3+20)
    dc.l    ((24*250)*(24*250))    ; (4+20)
    dc.l    ((25*250)*(25*250))    ; (5+20)
    dc.l    ((26*250)*(26*250))    ; (6+20)
    dc.l    ((27*250)*(27*250))    ; (7+20)
    dc.l    ((28*250)*(28*250))    ; (8+20)
    dc.l    ((29*250)*(29*250))    ; (9+20)
    dc.l    ((30*250)*(30*250))    ; (10+20)
    dc.l    ((31*250)*(31*250))    ; (11+20)
    dc.l    ((32*250)*(32*250))    ; (12+20)
    dc.l    ((33*250)*(33*250))    ; (13+20)
    dc.l    ((34*250)*(34*250))    ; (14+20)
    dc.l    ((35*250)*(35*250))    ; (15+20)

dostop	;player a3 stops
.slim	=	$1000
	cmp	#.slim,Xvel(a3)
	bgt	.set
	cmp	#-.slim,Xvel(a3)
	blt	.set
	cmp	#.slim,Yvel(a3)
	bgt	.set
	cmp	#-.slim,Yvel(a3)
	blt	.set
	bra	stopna	;stop with no anim
.set
	move	#SPAglide,d1
	btst	#pfrev,pflags(a3)
	bne	.0
	bset	#pf2aip,pflags2(a3)
	move	#SPAstop,d1
.0	bsr	SetSPA
stopna
	tst	Xvel(a3)
	bpl	.xp
	add	#150,Xvel(a3)
	bmi	.y
	clr	Xvel(a3)
.xp	sub	#150,Xvel(a3)
	bpl	.y
	clr	Xvel(a3)
.y	tst	Yvel(a3)
	bpl	.yp
	add	#150,Yvel(a3)
	bmi	rtss
	clr	Yvel(a3)
.yp	sub	#150,Yvel(a3)
	bpl	rtss
	clr	Yvel(a3)
	rts

runspeed	equ	200	;acc speed equate for table below

dirtab	;x,y speed for each direction 0-7
	dc.w	0,runspeed
	dc.w	runspeed*1000/1414,runspeed*1000/1414
	dc.w	runspeed,0
	dc.w	runspeed*1000/1414,-runspeed*1000/1414
	dc.w	0,-runspeed
	dc.w	-runspeed*1000/1414,-runspeed*1000/1414
	dc.w	-runspeed,0
	dc.w	-runspeed*1000/1414,runspeed*1000/1414