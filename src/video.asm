VBlank	;main vblank code for game play
	movem.l	d0-d7/a0-a6,-(a7)
	btst	#dfng,disflags
	bne	.nograph	;don't screw with vchip cause I'm using it

	bclr	#dfok,disflags
	beq	.01
	bsr	DumpSprites
.01
	bsr	cramfade
.nograph
	btst	#sfpz,sflags
	bne	.c

	btst	#gmclock,gmode	;game clock stopped!
	bne	.c
	tst	gameclock
	beq	.c
	sub	#jiffy,gameclock+2
	bcc	.c
	bset	#dfclock,disflags
	subq	#1,gameclock
	cmp	#61,gameclock
	bgt	.c
	cmp	#60,gameclock
	blt	.c
	move	#SFXbeep2,-(a7)
	bsr	sfx
.c
	addq	#1,Vcount
	jsr	p_music_vblank
	movem.l	(a7)+,d0-d7/a0-a6
	rte

vb2	;vblank used for palfades only no dmas
	movem.l	d0-d7/a0-a6,-(a7)
	btst	#dfng,disflags
	bne	.nograph
	bsr	cramfade
.nograph	addq	#1,Vcount
	jsr	p_music_vblank
	movem.l	(a7)+,d0-d7/a0-a6
	rte

VBcount	;vblank with counter only
	addq	#1,Vcount
	rte

;------------------------------------
DumpSprites
	;transfer (by dma) scroll stuff, sprite table, vram data in dmalist
	bsr	DoScroller
DumpSprites2
	move	#Satt,a0	;transfer sprite table
	move	Sattsize,d0
	move	VSPRITES,d1
	bsr	DoDMA
dodmalist
	move.l	DMAlistend,a6	;transfer data from dmalist
	cmp.l	#DMAList,a6
	beq	rtss

.0	move	-(a6),d1
	move	-(a6),d0
	move.l	-(a6),a0
	bsr	DoDMA
	cmp.l	#DMAList,a6
	bne	.0
	rts

DoScroller	;take care of the map scrolling transfers
	bsr	SetScroll2
	move	#tempmap,a0
	move	(a0)+,d1
	bmi	rtss
.0
	add	VmMap2,d1
	moveq	#48,d0		;words to transfer
	bsr	DoDMA
	add	#48*2,a0
	move	(a0)+,d1
	bpl	.0
	st	tempmap
	rts

SetScroll2
	move	VSCRLPM,d0
	add	#2,d0
	bsr	Vmaddr
	move	Hscroll,(a0)

	move.l	#$40020010,4(a0)
	move	Vscroll,(a0)
	rts

SetScroll1
	move	VSCRLPM,d0
	bsr	Vmaddr
	move	Hscroll,(a0)

	move.l	#$40000010,4(a0)
	move	Vscroll,(a0)
	rts

setvideo	;this is not vblank code but sets up ram for vblank transfers
	movem.l	d0-d7/a0-a6,-(a7)
.p	btst	#dfok,disflags
	bne	.p
	bsr	updatescroll

	move	#DMAList,a5	;dma transfer list
	move	#Satt,a6	;sprite attribute table area
	moveq	#1,d6	;link counter
	bsr	checkfo
	bsr	checksso
	bsr	setsortcords
	bsr	setffo
	bsr	showclock
	bsr	showzam
	bsr	showcrowd
	bsr	showref

	cmp	#Satt,a6
	bne	.n
	clr.l	(a6)+
	clr.l	(a6)+
.n	clr.b	3-8(a6)	;end sprite list
	move.l	a6,d0
	sub.l	#Satt,d0
	move	d0,Sattsize
	move.l	a5,DMAlistend
	bset	#dfok,disflags
	movem.l	(a7)+,d0-d7/a0-a6
	rts

showref	;draw ref graphics
	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter
.refx	=	2
.refy	=	2
	bclr	#sf2refref,sflags2
	beq	rtss
	move	#RefRamMap,a0
	move	#VmMap1,a1
	move	2(a1),d2
	moveq	#2,d0
	btst	#sfhor,sflags
	beq	.1
	moveq	#15,d0	;y pos in sb screen
.1
	asl	d2,d0
	moveq	#2,d1
	asl	d2,d1
	add	#2,d0
	btst	#sfhor,sflags
	beq	.2
	add	#11,d0
.2
	asl	#1,d0
	add	(a1),d0
	moveq	#refheight-1,d2
.0	move.l	a0,(a5)+
	move	#refwidth,(a5)+
	move	d0,(a5)+
	add	#refwidth*2,a0
	add	d1,d0
	dbf	d2,.0
	rts


checkfo	;check for face off sprites
	btst	#sfpz,sflags
	bne	rtss
	btst	#sf2faceoff,sflags2
	beq	rtss

	move	#fofdata,a3
	moveq	#2,d0
checkfo2	;face off graphics
	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter
.top	move	(a3),d5
	bmi	.next
	beq	.next
	asl	#2,d5
	move	#FaceOffframelist,a2
	move.l	-4(a2,d5),a2
	move	SprStrnum(a2),d5	;number of sprites in frame
	add	#SprStrdat,a2
	
.sloop	move	(a2),d2
	add	#128,d2
	add	fodropy,d2
	move	d2,(a6)	;y global
	move	6(a2),d2	;x global
	btst	#3,2(a3)	;x flip
	beq	.noxflip
	move.b	2(a2),d2
	and	#%1100,d2
	add	#%0100,d2
	asl	#1,d2
	neg	d2
	sub	6(a2),d2
.noxflip	add	#128,d2
	add	fodropx,d2
	move	d2,6(a6)
	move.b	2(a2),2(a6)
	move.b	d6,3(a6)
	move	4(a2),d2
	move	2(a3),d1
	and	#$f800,d1
	eor	d1,d2
	add	faceoffvrcset,d2
	move	d2,4(a6)
	add	#1,d6
	add	#8,a6
	add	#8,a2
	dbf	d5,.sloop
	add	#4,a3
.next	dbf	d0,.top
	rts

showzam	;zamboni
	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter
	move	zamx,d0
	bmi	rtss

	move	#ZamFrameList,a0
	lsr	#2,d0
	move	#128+200,d1
	moveq	#1,d2	;frame
	move	ExtraChars,d3

SetSframe
	;a0 = framelist
	;d0/d1 = x/y cords
	;d2 = frame to setup
	;d3 = start char in vram

	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter
	cmp	#MaxSprites,d6
	bge	rtss
	movem.l	d0-d5,-(a7)
	asl	#2,d2
	move.l	-4(a0,d2),a0
	move	SprStrnum(a0),d4	;number of sprites in frame
	add	#SprStrdat,a0
.loop	move	(a0),(a6)
	add	d1,(a6)+
	move.b	2(a0),(a6)+
	move.b	d6,(a6)+
	move	4(a0),(a6)
	add	d3,(a6)+
	move	6(a0),(a6)
	add	d0,(a6)+
	add	#1,d6
	cmp	#MaxSprites,d6
	beq	.ex
.next	add	#8,a0
	dbf	d4,.loop
.ex	movem.l	(a7)+,d0-d5
	rts

showcrowd
	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter
	move	#CrowdFrameList,a1
	move	Hpos,d4
	move	Vpos,d5
	btst	#sfhor,sflags
	beq	.v
	moveq	#-64,d4
	move.l	#256,d5
	add	#4*31,a1
.v
	clr	d0
	move.b	PBnum,d2
	moveq	#26,d3
	bsr	.pb
	move.b	PBnum,d2
	lsr	#4,d2
	moveq	#29,d3
	bsr	.pb

	move.b	crowdframe,d0
	bsr	.sc
	move.b	crowdframe+1,d0
	bra	.sc

.pb	and	#$0f,d2
	cmp	#3,d2
	bls	.pb0
	moveq	#3,d2
.pb0	bra	.nextpb
.pbt	move	d3,d0
	add	d2,d0
	bsr	.sc
.nextpb	dbf	d2,.pbt
	rts

.sc
	ext	d0
	beq	rtss
	cmp	#MaxSprites,d6
	bge	rtss
	movem.l	d0-d5,-(a7)
	asl	#2,d0
	move.l	a1,a0
	move.l	-4(a0,d0),a0
	move	SprStrnum(a0),-(a7)	;number of sprites in frame
	add	#SprStrdat,a0

	move	d4,d0
	add	#192,d0
	move	d0,d1
	sub	#128+16,d0
	add	#128,d1
	move	#368,d2
	sub	d5,d2
	move	d2,d3
	sub	#112+16,d2
	add	#112,d3

	move	(a7)+,d4
.loop	cmp	(a0),d2
	bgt	.next
	cmp	(a0),d3
	blt	.next
	cmp	6(a0),d0
	bgt	.next
	cmp	6(a0),d1
	blt	.next
	move	(a0),d5
	add	#128-16,d5
	sub	d2,d5
	move	d5,(a6)+
	move.b	2(a0),(a6)+
	move.b	d6,(a6)+
	move	crowdvrcset,d5
	add	4(a0),d5
	move	d5,(a6)+
	move	6(a0),d5
	add	#128-16,d5
	sub	d0,d5
	move	d5,(a6)+
	add	#1,d6
	cmp	#MaxSprites,d6
	beq	.ex
.next	add	#8,a0
	dbf	d4,.loop
.ex	movem.l	(a7)+,d0-d5
	rts

showclock	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter
	bclr	#dfclock,disflags
	beq	rtss
	move	#clockram+(5*2),a0
	move.l	#smallfontmap,a1
	add.l	4(a1),a1

	move	4+(':'*2)(a1),d0
	add	smallfontchars,d0
	or	#$8000,d0
	move	d0,clockram+(2*2)

	move	gameclock,d0
	ext.l	d0
	divu	#10,d0
	bsr	.char
	divu	#6,d0
	bsr	.char
	sub	#2,a0
	divu	#10,d0
	bsr	.char
	swap	d0
	tst.l	d0
	bne	.0
	moveq	#' '-'0',d0
	swap	d0
.0	bsr	.char
	move.l	a0,(a5)+
	move	#5,(a5)+	;words to transfer

.clockx	=	3
.clocky	=	1

.clockx2	=	13
.clocky2	=	4
	move	#VmMap1,a1
	moveq	#.clocky,d0
	moveq	#.clockx,d2
	btst	#sfhor,sflags
	beq	.cv
	move	#VmMap2,a1
	moveq	#.clocky2,d0
	moveq	#.clockx2,d2
.cv
	move	2(a1),d1
	asl	d1,d0
	add	d2,d0
	asl	#1,d0
	add	(a1),d0
	move	d0,(a5)+	;vram destination
	rts

.char
	swap	d0
	asl	#1,d0
	move	4+('0'*2)(a1,d0),d0
	add	smallfontchars,d0
	or	#$8000,d0
	move	d0,-(a0)
	swap	d0
	ext.l	d0
	rts

checksso	;do graphics for sso structure
	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter
	move	#pads+ffosize,a0
	move	#sso,a3
	move	#SPFarrow,d3
	bsr	.ca
	add	#ffosize,a0
	add	#ssosize,a3
	move	#SPFarrow+3,d3
	bsr	.ca

	btst	#sfhor,sflags
	beq	rtss

	move	#ssonum-2,d5
	bra	.next
.top	move	Xcord(a3),d0
	add	#$80+128,d0
	move	Ycord(a3),d1
	add	#$80+112,d1
	bsr	addframe2
.next	add	#ssosize,a3
	dbf	d5,.top
	rts

.ca
	tst	Zpos(a0)
	bmi	rtss
	st	frame(a3)

	move	Xpos(a0),d0
	move	Ypos(a0),d1
	btst	#sfhor,sflags
	beq	.nhor
	exg	d0,d1
	neg	d0
	sub	#horoff,d1
	bra	.hord
.nhor	sub	Hpos,d0
	sub	Vpos,d1

.xoff	=	116
.yoff	=	100

.hord	clr	d2
	cmp	#.xoff,d0
	blt	.0
	bset	#rbut,d2
.0	cmp	#-.xoff,d0
	bgt	.1
	bset	#lbut,d2
.1	cmp	#.yoff,d1
	blt	.2
	bset	#ubut,d2
.2	cmp	#-.yoff,d1
	bgt	.3
	bset	#dbut,d2
.3	tst	d2
	beq	rtss
	move.l	#jdtab,a1
	move.b	0(a1,d2),d2
	asl	#3,d2
	move.l	#.tab,a1

	move	0(a1,d2),d4
	beq	.4
	move	d4,d0
.4	add	#128+128,d0
	move	d0,Xcord(a3)

	move	2(a1,d2),d4
	beq	.5
	move	d4,d1
.5	neg	d1
	add	#112+128,d1
	move	d1,Ycord(a3)

	add	4(a1,d2),d3
	move	d3,frame(a3)
	move	6(a1,d2),attribute(a3)
	bra	addframe2

.xspot	=	116
.yspot	=	100

.tab	dc.w	0,.yspot,0,$0000
	dc.w	.xspot,.yspot,1,$0000
	dc.w	.xspot,0,2,$0000
	dc.w	.xspot,-.yspot,1,$1000
	dc.w	0,-.yspot,0,$1000
	dc.w	-.xspot,-.yspot,1,$1800
	dc.w	-.xspot,0,2,$0800
	dc.w	-.xspot,.yspot,1,$0800	


setsortcords	;setup sort cord graphics
	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter
	move	#OOlist,a4
	move	#sortobjs-1,d0
.top
	clr	d1
	move.b	(a4)+,d1
	asl	#scsize-1,d1
	move	#SortCords,a3
	add	d1,a3
	bsr	addframe
	dbf	d0,.top
	rts

setffo	bsr	uppads
	move	#ffonum-1,d0
	move	#ffo,a3
.top	bsr	addframe
	add	#ffosize,a3
	dbf	d0,.top
	rts

uppads	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter
	move	#ffo+(4*ffosize),a0
	st	Zpos(a0)
	move.b	glovecords,d0
	beq	.nogloves
	move.b	glovecords+1,d1
	ext	d0
	asl	#2,d0
	move	d0,Xpos(a0)
	ext	d1
	asl	#2,d1
	move	d1,Ypos(a0)
	clr	Zpos(a0)
.nogloves
	moveq	#2,d4
	move	#pads,a0
	move	#padcont,a1
	move	#SortCords,a2
	move.l	#SmallFontMap,a3
.top	st	Zpos(a0)
	tst.b	(a1)
	bmi	.next
	bclr	#6,(a1)
	beq	.cords

	move.b	1(a1),d2
	and	#$00f0,d2
	lsr	#3,d2
	clr	d3
	bsr	.pd
	move.b	1(a1),d2
	and	#$000f,d2
	asl	#1,d2
	moveq	#1,d3
	bsr	.pd

.cords	move.b	(a1),d1
	and	#$0f,d1
	asl	#scsize,d1
	move	Xpos(a2,d1),Xpos(a0)
	move	Ypos(a2,d1),Ypos(a0)
	clr	Zpos(a0)
.next	add	#ffosize,a0
	add	#2,a1
	dbf	d4,.top
	rts

.pd	move.l	a3,-(a7)
	add.l	4(a3),a3
	move	4+('0'*2)(a3,d2),d2
	and	#$7ff,d2
	asl	#5,d2
	move.l	(a7),a3
	lea	10(a3,d2),a3
	move.l	a3,(a5)+
	move	#16,(a5)+
	add	VRchar(a0),d3
	asl	#5,d3
	move	d3,(a5)+
	move.l	(a7)+,a3
	rts

addframe
;a3 = cords.l frame/oldframe VRsize VRchar
;a5 = dma trans
;a6/d6 = sprite att
	movem.l	d0-d2,-(a7)
	move	Xpos(a3),d0
	move	Ypos(a3),d1
	move	Zpos(a3),d2
	bmi	.exit
	bsr	find3d
	cmp	#osflag,d1
	beq	.exit
	bsr	addframe2
.exit
	movem.l	(a7)+,d0-d2
	rts

addframe2
;d0/d1 = x/y coordinates on screen
	;a5 = dma list
	;a6 = sprite table
	;d6 = link counter

	movem.l	d0-d5/a0-a2,-(a7)
	move	frame(a3),d5
	bmi	.exit
	beq	.exit
	asl	#2,d5
	move	#framelist,a2
	move.l	-4(a2,d5),a2
	move	SprStrnum(a2),d5	;number of sprites in frame
	add	#SprStrdat,a2
	clr	d3
	clr	d4
.sloop
	move	d0,-(a7)
	move	frame(a3),d0
	cmp	oldframe(a3),d0
	beq	.noref

	tst	d5
	bne	.nn
	move	d0,oldframe(a3)
.nn
	movem	d0-d4,-(a7)
	move	4(a2),d2
	and	#$7ff,d2
	move	2(a2),d4
	and	#$f000,d4
	lsr	#1,d4
	or	d4,d2	;full 15 bits of data pointer

	move.b	2(a2),d4
	and	#$f,d4
	move.l	#sizetab,a0
	move.b	0(a0,d4),d4	;chars used in this sprite
	cmp	8(a7),d4
	bgt	.nodup	;more data in prev sprite so no dup
	cmp	4(a7),d2
	blt	.nodup
	move	4(a7),d0
	add	8(a7),d0	;end of last data
	sub	d2,d0
	sub	d4,d0	
	bmi	.nodup
	movem	(a7)+,d0-d1
	add	#6,a7
	bra	.dup

.nodup	add	8(a7),d3
	movem	(a7)+,d0-d1
	add	#6,a7

	movem	d0-d4,-(a7)
	add	VRchar(a3),d3
	move.l	Spritetiles,a0
	ext.l	d2
	asl.l	#5,d2
	add.l	d2,a0
	asl	#4,d4
	asl	#5,d3
	move.l	a0,(a5)+
	move	d4,(a5)+	;words to transfer
	move	d3,(a5)+	;vram destination
	movem	(a7)+,d0-d4
.dup
	move.b	d3,VRoffs(a3,d5)
.noref
	move	(a7)+,d0
	movem	d0-d2,-(a7)	;write sprite att
	move	(a2),d2	;y global
	btst	#4,attribute(a3)	;y flip
	beq	.noyflip
	move.b	2(a2),d2
	and	#%0011,d2
	add	#1,d2
	asl	#3,d2
	neg	d2
	sub	(a2),d2
.noyflip	add	d2,d1
	move	d1,(a6)

	move	6(a2),d2	;x global
	btst	#3,attribute(a3)	;x flip
	beq	.noxflip
	move.b	2(a2),d2
	and	#%1100,d2
	add	#%0100,d2
	asl	#1,d2
	neg	d2
	sub	6(a2),d2
.noxflip	add	d2,d0
	move	d0,6(a6)
	move.b	2(a2),2(a6)
	move.b	d6,3(a6)
	move	4(a2),d2
	move	attribute(a3),d0
	eor	d0,d2
	and	#$f800,d2
	btst	#0,attribute+1(a3)
	beq	.nospec
	btst	#14,d2
	beq	.nospec
	bset	#13,d2	;team 2 color
.nospec	or.b	VRoffs(a3,d5),d2
	add	VRchar(a3),d2
	move	d2,4(a6)
	movem	(a7)+,d0-d2

	add	#1,d6
	add	#8,a6
	add	#8,a2
	dbf	d5,.sloop
.exit
	movem.l	(a7)+,d0-d5/a0-a2
	rts

sizetab
	dc.b	1,2,3,4,2,4,6,8,3,6,9,12,4,8,12,16
;-------------------------------------------------
horoff	equ	197
find3d	;input - d0=xfield,d1=yfield,d2=height off field
	;output - d0=xscreen,d1=yscreen

	btst	#sfhor,sflags
	beq	.nhor

	exg	d0,d1
	neg	d0
	sub	#horoff,d1
	bra	.crange

.nhor	sub	Hpos,d0
	sub	Vpos,d1
.crange	cmp	#128+16,d0
	bgt	.offscr
	cmp	#-(128+16),d0
	blt	.offscr
	add	#128+128,d0
	add	d2,d1
	asr	#1,d2
	add	d2,d1
	cmp	#112+32,d1
	bgt	.offscr
	cmp	#-(112+32),d1
	blt	.offscr
	neg	d1
	add	#112+128,d1
	rts
.offscr	move	#osflag,d1
	rts

updatesound
	move	Crowdlevel,d0
	asl	#3,d0
	add	#$0400,d0
	cmp	#$0eff,d0
	bls	.ip
	move	#$0eff,d0

.ip	moveq	#40,d2
	sub	asv,d0
	cmp	d2,d0
	bgt	.iasv
	neg	d2
	cmp	d2,d0
	bge	.non
.iasv	add	d2,asv
	bpl	.non
	clr	asv
.non
	move.b	#$c8,asound
	move.b	#$01,asound
	move.b	asv,d0
	eor.b	#$0f,d0
	or.b	#$f0,d0
	move.b	d0,asound
	rts

KillCrowd
	move.b	#$e7,asound
	move.b	#$df,asound
	move.b	#$c8,asound
	move.b	#$01,asound
	move.b	#$ff,asound
	rts