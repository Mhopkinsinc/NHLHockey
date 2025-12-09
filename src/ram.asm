;Variables
Asound	=	$c00011 	;analog sound
Vdata	=	$c00000	;video ports
Vctrl	=	Vdata+4

MaxSprites	=	64	;max sprites during game (64 because 32 col mode)

refwidth	=	7	;width of ref.map frames
refheight	=	8	;height of ref.map frames

Joy1	=	$a10003	;controller ports
Joy2	=	$a10005
Stack	=	$fffffdf0	;stack goes below sound Ram		

;joystick button equates
ubut	=	0	;up
dbut	=	1	;down
lbut	=	2	;left
rbut	=	3	;right
bbut	=	4	;b button
cbut	=	5	;c button
abut	=	6	;a button
sbut	=	7	;start button
HVcount	=	$c00008	;Video port

osflag	=	20000	;flag for off screen graphic

SngTitle	=	1	;Title song
SngEOP	=	0	;End of Period song
SngEOG	=	3	;End of Game song
SngPO	=	4	;playoffs music

;sfx????? sound effects equates for Rob's sound file
SFXskatestop	=	-1

SFXsiren	=	0
SFXbeep1	=	1
SFXbeep2	=	2
SFXwhistle	=	10
SFXhorn	=	24
SFXpass	=	11
SFXshotbh	=	12
SFXshotfh	=	13
SFXshotwiff	=	14

SFXstdef	=	5	;stick hits puck deflect
SFXpuckget	=	8
SFXpuckbody	=	5
SFXpuckwall1	=	7
SFXpuckwall2	=	29
SFXpuckwall3	=	30
SFXpuckice	=	8
SFXplayerwall	=	15
SFXpuckpost	=	9

SFXcheck	=	18
SFXcheck2	=	3
SFXhithigh	=	21
SFXhitlow	=	23

SFXcrowdcheer	=	25
SFXcrowdboo	=	26
SFXoooh	=	31

goalline	=	176	;distance from blue line to goalline

replaystart	=	$ffff0000	;start of ram area for replay frames
varstart	=	$ffffb000	;start of variable space (end of replay)

replaysize	=	84	;number of bytes per replay frame
replaynum	=	((varstart-replaystart)/replaysize)-1	;number of frames for replay
replayend	=	replaystart+(replaynum*replaysize)	;end of replay ram

Sortobjs	=	16	;number of sorted graphics objects- these are arranged so sprites lower on the screen are of higher priority
scsize	=	7	;2 to this power indicates ram needed for each sortobj
SCstruct	=	1<<scsize	;ram for each sortobj
RAMSTART = varstart
	RSSET   varstart	
;vram mapping variables...
VSCRLPM	rs.w	1	;location in vram of scroll parameters
VSPRITES	rs.w	1	;location in vram of sprite attributes
VmMAP1	rs.w	1	;location in vram of playfield 1
Map1col	rs.w	1	;2 to this power = width in char of playfield 1
VmMAP2	rs.w	1	;location in vram of playfield 2
Map2col	rs.w	1	;2 to this power = width in char of playfield 2
VmMAP3	rs.w	1	;location in vram of playfield 3
Map3col	rs.w	1	;2 to this power = width in char of playfield 3

BigFontchars	rs.w	1	;vram tiles for BigFont.map
smallfontchars	rs.w	1	;vram tiles for SmallFont.map
rinkvrcset	rs.w	1	;vram tiles for IceRink.map
crowdvrcset	rs.w	1	;vram tiles for Crowd.map
faceoffvrcset	rs.w	1	;vram tiles for FaceOff graphics
framercset	rs.w	1	;vram tiles for framer.map
SmallLogoscset	rs.w	1	;vram tiles for small logos
EASNcset	rs.w	1	;vram tiles for EASN.map

ExtraChars	rs.w	1	;vram tiles for extra graphics

printx	rs.w	1	;x cordinate for printing
printy	rs.w	1	;y cordinate for printing
printa	rs.w	1	;attribute for print characters
printm	rs.w	1	;map to use (0 = map 1, 4 = map 2, 8 = map 3)

fodropx	rs.w	1	;face off drop spot x/y
fodropy	rs.w	1

recbpr	rs.l	1	;record buffer pointer

VBint	rs.l	1	;address of vblank interupt code

Vcount 	rs.w	1	;counter for vblank
OldVcount	rs.w	1

asv	rs.w	1	;analog sound volume (crowd noise)

;the following are equates for several structures allocated below them
Xcord	=	0
Ycord	=	2

Xpos	=	0
attribute	=	4	;frame attribute switch bits

frame	=	attribute+2	;alice frame number
oldframe	=	frame+2	;last frame
VRoffs	=	oldframe+2	;offsets to find each sprites start char. (max of 6 sprites / frame)
VRsize	=	VRoffs+6	;vram size in chars allocated for this graphic 
VRchar	=	VRsize+2	;vram char for graphic

Ypos	=	VRchar+2
Zpos	=	Ypos+4

OldXpos	=	Zpos+4
OldYpos	=	OldXpos+4
OldZpos	=	OldYpos+4

Xvel	=	OldZpos+4
Yvel	=	Xvel+2
Zvel	=	Yvel+2

impactp	=	Zvel+2	;last player to cause impact
limpact	=	impactp+2	;last impact value
impact	=	limpact+2	;impact value

position	=	impact+2	;player's position (0=goalie,1=l.def,2=r.def,3=l.wing,4=center,5=r.wing)
assnum	=	position+2	;index to current assignment
asslist	=	assnum+2	;list of assignments in order of execution

temp1	=	asslist+(8*1)
temp2	=	temp1+2
temp3	=	temp2+2
temp4	=	temp3+2
temp5	=	temp4+2

radiusx	=	temp5+2	;width of this graphic
radiusy	=	radiusx+2	;height of this graphic
Wallcos	=	radiusy+2	;cos of angle of last collision
Wallsin	=	Wallcos+2	;sin of angle of last collision

SCnum	=	Wallsin+2	;index number for this struct
facedir	=	SCnum+2	;direction of facing

SPA	=	facedir+4	;animation
SPAnum	=	SPA+2	;index into animation
SPAcnt	=	SPAnum+2	;count down to next frame of animation

nopuck	=	SPAcnt+2	;no puck coll until zero

newpos	=	nopuck+2	;requested next position of this player
newpnum	=	newpos+1	;requested next player (from roster) for this player

pflags	=	newpnum+1
pfdoff	=	0	;bit0-deceleration off
pfna	=	1	;bit1-new assignment
pfnc	=	2	;bit2-no collision mode
pfjoycon	=	3	;is player joystick controlled 
pfrev	=	4	;skating backwards
pfalock	=	5	;lock out until anim is done
pfteam	=	6	;0-home(sprite0-5)/1-visitors(sprite6-11)
pfgoal	=	7	;0=bottom, 1=top (to shoot at)

pflags2	=	pflags+1
pf2fight	=	0	;player is fighting
pf2aip	=	1	;animation in progress wait
pf2dw	=	2	;double weight flag for oomph
pf2np	=	3	;no joystick pad
pf2unav	=	4	;player is unavailable for play (going to/from bench/penaly)
pf2lcm	=	5	;line change mode
pf2pen	=	6	;player has caused a penalty
pf2npc	=	7	;no player coll

pflags3	=	pflags2+1
pf3oside	=	0	;player is offsides
pf3finst	=	1	;instigator

glitch	=	pflags3+1	;counter to eliminate quick frame changes (de-glitch graphics)
pnum	=	glitch+1	;player's team location number 0-22
weight	=	pnum+1
legstr	=	weight+1
legspd	=	legstr+1
aioff	=	legspd+1
aidef	=	aioff+1
shotspd	=	aidef+1
shotacc	=	shotspd+1
GGSright	=	shotacc
passacc	=	shotacc+1
rostnum	=	passacc+1
spodds	=	rostnum+1
GSSleft	=	spodds
stickhand	=	spodds+1
GGSleft	=	stickhand
endurance	=	stickhand+1
GSSright	=	endurance
aggress	=	endurance+1
handed	=	aggress+1	;bit0 set is left handed

SortCords	rs.b	Sortobjs*SCstruct
puckscnum	=	14	;puck is sort obj number 14
puckx	=	SortCords+(puckscnum*SCstruct)+Xpos
puckvx 	=	SortCords+(puckscnum*SCstruct)+Xvel
pucky	=	SortCords+(puckscnum*SCstruct)+Ypos
puckvy 	=	SortCords+(puckscnum*SCstruct)+Yvel
puckz	=	SortCords+(puckscnum*SCstruct)+Zpos
puckvz 	=	SortCords+(puckscnum*SCstruct)+Zvel
puckc	=	SortCords+(puckscnum*SCstruct)+newpos

Ylist	rs.w	Sortobjs	;list of y cords for each sortobj
OOlistpos	rs.w	Sortobjs	;objects pos in OOlist
OOlist 	rs.b	Sortobjs	;object order list for sort objs

SprStratt	=	2+8	;equates for building frame lists from alice files
SprStrhot	=	SprStratt+2
SprStrnum	=	SprStrhot+24
SprStrdat	=	SprStrnum+2

FrameList	rs.l	550	;max number of frames
Spritetiles	rs.l	1

Crowdframelist	rs.l	64	;area for frame list on crowd.anim
Crowdframe	rs.w	1	;current crowd frame number
Crowdlevel	rs.w	1	;level of crowd excitement
Crowdstep	rs.w	1	;animation step for crowd
Crowdcnt	rs.w	1	;count down to next step

Zamx	rs.w	1	;zamboni x cord
ZamFrameList	rs.l	4	;frame list for zamboni

FaceOffframelist	rs.l	10	;frame list for face off graphics

DMAList	rs.l	2*140	;dma transfer list

Vpos	rs.w	1	;ice rink vertical position
Oldrow 	rs.w	1	;last row (used in vertical scrolling of the map data)
Hpos	rs.w	1	;ice rink horizontal position

Hscroll	rs.w	1	;horizontal scroll value
Vscroll	rs.w	1	;vertical scroll value

Voffset	rs.w	1	;85 for small rink
Blueline	rs.w	1	;distance (in pix) from center line to blueline
Sideline	rs.w	1	;distance from center to side boards

wcradiusx	rs.w	1	;variables used in wall collisions
wcradiusy	rs.w	1

tempmap	rs.w	49*32+2	;area to transfer map data from (during vertical scrolling)
var1 = tempmap

palcount	rs.w	1	;counter for fading in color palettes
palfadenew	rs.w	16*4	;palettes to fade into

fofdata	rs.l	3	;data for frame/att of big face off sprites

ffonum	=	5	;5 objects tied to icerink scrolling (3 pads + center ice logo + gloves/stick)
ffosize	=	OldXpos	  
ffo	rs.b	ffonum*ffosize  ;field objects
pads	=	ffo
padcont	rs.w	3

ssonum	=	4	;4 objects not tied to icerink scrolling (2 arrows for off screen players + 2 large team logos on scoreboard)
ssosize	=	Ypos
sso	rs.b	ssonum*ssosize

shotplayer	rs.w	1	;player who shot last
lastplayer	rs.w	1	;last player who touched puck

passdir	rs.w	1	;direction for pass/shot
passspeed	rs.w	1	;speed of pass/shot

glovecords	rs.w	1	;cordinates of glove/sticks (fighting)

threat	rs.w	1	;direction of threat on puck handler

puckcross	rs.w	4	;xcord/frames top to bottom (for goalies to react to)

lj1	rs.w	1	;used in joystick debounce
lj2	rs.w	1

disflags	rs.w	1	;display flags
dfok	=	0	;graphics are ready for transfer
df32c	=	1	;32 column mode on
dfng	=	2	;don't int graphics
dfclock	=	3	;clock needs update

ltplayer	rs.w	1	;last touch player
ltx	rs.w	1	;last touch x cord
lty	rs.w	1	;last touch y cord

iflags	rs.w	1	;icing
ifcgl	=	0	;crossed goalline
ifdir	=	1	;1=must cross top line
ifok	=	2

jps	=	24	;jiffys per second
jiffy	=	$10000/jps
clockram	rs.w	5	;ram for dma transfer of clock digits

xc1	rs.w	1	;scroll lock x cord
yc1	rs.w	1	;scroll lock y cord
yleader	rs.w	1	;lead distance on scrolling
fox	rs.w	1	;faceoff spot x/y
foy	rs.w	1

fodir1	rs.w	1	;pull directions for each player on face off
fodir2	rs.w	1

deltax	rs.w	1	;used lots of places for x/y stuff
deltay	rs.w	1

collflag	rs.w	1	;collision has occured

evalue 	rs.w	1	;elasticity value (parameter of collisions)

lldisp	rs.w	1	;line level disp update counter

mesarea	rs.b	100	;temp area for mes chars

ltack	rs.w	1	;last tackle sound
lastsfx	rs.w	1	;last sound played

Satt	rs.l	180	;sprite attribute table (for dma transfer
Sattsize	rs.w	1	;size of transfer

DMAlistend	rs.l	1
gmode	rs.w	1	;game mode flag
gmclock 	=	0	;game clock is stopped
gmdir	=	1	;0 = home team goes up
gmpen	=	2	;penalty has been called
gmpendel	=	3	;delayed penalty has been called
gmhl	=	4	;hilight mode
gmoffs	=	5	;offsides on

sflags	rs.w	1
sfpz	=	0	;pause mode
sfpj	=	1	;pause cont (0 for cont 1)
sfspdir	=	2	;set pass dir mode
sfssdir	=	3	;set shot dir mode
sfwrap	=	4	;replay has wrapped around
sfscrl	=	5	;replay scroll is manual cont
sfslock	=	6	;scroll lock to xc1/yc1
sfhor	=	7	;screen is in horizontal mode

sflags2	rs.w	1
sf2faceoff	=	0	;face off in progress
sf2refref	=	1	;ref needs refresh
sf2drec	=	2	;disable replay record
sf2replay	=	3	;replay in progress
sf2shot	=	4	;shot was taken
sf2pwrplay	=	5	;power play in progress
sf2pwrtm	=	6	;0 for team 1 in power play
sf2offsig	=	7	;offsides little ref on

sflags3	rs.w	1
sf3llcs	=	0	;lower line change sel.
sf3rmplay	=	1	;play mode on for replay
sf3alttree	=	2	;alt. tree
sf3sbut	=	3	;flag for start button

c1playernum	rs.w	1	;player in control or neg for none
c2playernum	rs.w	1

cont1team	rs.w	1	;cont1 team 0=none 1=team1 2=team2
cont2team	rs.w	1

HomeTeam	rs.w	1	;number 0-24
VisTeam	rs.w	1

MaxPen	=	32
PenBuf	rs.w	MaxPen+1	;upto x penalties saved
PenCntDwn	rs.w	1
Penaltytimer	rs.w	1
PBnum	rs.w	1	;$HV00 h=home players in pb

RefCnt	rs.w	1	;ref graphics control
RefStep	rs.w	1
RefPen	rs.w	1
RefRamMap	rs.w	refwidth*refheight

gsp	rs.w	1	;game period
gameclock	rs.l	1	;game clock

;team variables
tmshots	=	0	;shots stat
tmPwrGoals	=	tmshots+2	;power play goals stat
tmPwrPlays	=	tmPwrGoals+2	;power plays stat
tmPenalties	=	tmPwrPlays+2	;penalties stat
tmPenmin	=	tmPenalties+2	;penalty min. stat
tmFightsWon	=	tmPenmin+2	;fights won stat
tmATOP	=	tmFightsWon+2	;attack time of possesion stat
tmdata	=	tmATOP+2	;team data address
tmsort	=	tmdata+4	;address of first sort obj
tmscore	=	tmsort+4	;score
tmline	=	tmscore+2	;current line
tmap	=	tmline+2	;active players on ice 4-6
tmgoalie	=	tmap+2	;goalie 1/2/none
tmflags	=	tmgoalie+2	;flags
tmflcc	=	0	;line change on
tmpde	=	tmflags+2	;energy level of each roster player
maxros	=	26
tmpdst	=	tmpde+(2*maxros)	;-2=bench/-1=ice/0+=penalty box
tmsize	=	tmpdst+(2*maxros)
tmstruct	rs.b	tmsize*2

;game structure variables
gst1	=	0	;team 1
gst2	=	gst1+2	;team 2
gspotwins	=	gst2+2	;play off top team (on tree) wins (for best of 7)
gspobwins	=	gspotwins+2	;play off bottom team (on tree) wins (for best of 7)
gsper	=	gspobwins+2	;period
gss1	=	gsper+2	;team 1 score
gss2	=	gss1+2	;team 2 score
gsflags	=	gss2+2	;flags
gsftf	=	0	;teams are flipped
gsfhl	=	1	;hilite requested
gsfso	=	2	;series over
gssize	=	gsflags+2
gstruct	rs.b	gssize*8

gamenum	rs.w	1	;index for current game in game struct

postarts	rs.w	1	;0-31 for which playoff tree to use as frame
bosgames	rs.w	1	;0-6 game of series or 7 if not in best of seven
gamelevel	rs.w	1	;0-3 for the depth into the play off tree
potreeteam	rs.w	1	;which team you are on the intial playoff tree
pojoy	rs.w	1	;playoff joystick indicator
WinBits	rs.w	1	;bits which indicat the continuing teams on the playoff tree

potree	rs.b	16+8+4+2+1+1	;team in the tree

PlList	rs.b	12	;list of players used differently

psitem	rs.w	1	;pause select item menu

TickerNum	rs.w	1

varend	rs.l	1	;end of variables for clearing purposes only

menuitems	=	7	;number of menu items

optionsmenu	rs.w	menuitems
OptPlayMode	=	optionsmenu+0	;play mode
OptNOP	=	optionsmenu+2	;number of players
Opt1team	=	optionsmenu+4	;team 1
Opt2team	=	optionsmenu+6	;team 2
Optperlen	=	optionsmenu+8	;period length
OptPen	=	optionsmenu+10	;penalties 1 for off
OptLine	=	optionsmenu+12	;line changes 0 for on

demoflag	rs.w	1	;demo flag
seed	rs.l	1	;seed for random generator
dmaram 	rs.l	1	;dma ram area

PWlength	=	16	;pass word length
PWrange	=	30	;pass word number of possible characters
password	rs.b	PWlength	;pass word ram

	rs.l	1
passbits	rs.l	4	;bits for decoded password

tpassbits	rs.l	4	;temporary storage of passbits

flipplayer	rs.w	1	;player who last flipped puck (-1 if not a flip)

varend2	rs.w	1