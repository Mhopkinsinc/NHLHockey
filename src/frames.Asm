
;This is a data table for animating the graphics in Sprites.anim
;This list equates the sections of the alice animation file Sprites.anim

SPFskatewp	=	1
SPFskate	=	SPFskatewp+40
SPFturnl	=	SPFskate+40
SPFturnr	=	SPFturnl+8
SPFswing	=	SPFturnr+8
SPFstop	=	SPFswing+48
SPFskateb	=	SPFstop+16
SPFcelebrate	=	SPFskateb+24
SPFpump	=	SPFcelebrate+16
SPFcup	=	SPFpump+16
SPFhipl	=	SPFcup+8
SPFhipr	=	SPFhipl+8
SPFshoulderl	=	SPFhipr+8
SPFshoulderr	=	SPFshoulderl+8
SPFsweep	=	SPFshoulderr+8

SPFfallback	=	SPFsweep+16
SPFfallfwd	=	SPFfallback+32
SPFduck	=	SPFfallfwd+32
SPFHold	=	SPFduck+8

SPFgloves	=	SPFHold+8
SPFfight	=	SPFgloves+1
SPFPen	=	SPFfight+17

SPFarrow	=	SPFpen+7
SPFpad	=	SPFarrow+6
SPFpuck	=	SPFpad+3
SPFgoal	=	SPFpuck+11
SPFGoalie	=	SPFgoal+2
SPFLogos	=	SPFGoalie+80+32
SPFSiren	=	SPFLogos+25	

SPAlist
	dc.w	0

SPAgready	=	*-SPAlist	;goalie in ready position
SPAgready_table:
.t
	dc.w	.0-.t	;offset to each direction of animation (0-7)
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0	;flags for this animation

.a	=	SPFGoalie
.off	=	3
.0	dc.w	.a,-8	;frame,time  (last entry indicated by neg. time)
.a	set	.a+.off
.1	dc.w	.a,-8
.a	set	.a+.off
.2	dc.w	.a,-8
.a	set	.a+.off
.3	dc.w	.a,-8
.a	set	.a+.off
.4	dc.w	.a,-8
.a	set	.a+.off
.5	dc.w	.a,-8
.a	set	.a+.off
.6	dc.w	.a,-8
.a	set	.a+.off
.7	dc.w	.a,-8

SPAgglover	=	*-SPAlist	;goalie does glove save right
SPAgglover_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFGoalie+1
.off	=	3
.0	dc.w	.a,-32
.a	set	.a+.off
.1	dc.w	.a,-32
.a	set	.a+.off
.2	dc.w	.a,-32
.a	set	.a+.off
.3	dc.w	.a,-32
.a	set	.a+.off
.4	dc.w	.a,-32
.a	set	.a+.off
.5	dc.w	.a,-32
.a	set	.a+.off
.6	dc.w	.a,-32
.a	set	.a+.off
.7	dc.w	.a,-32

SPAgglovel	=	*-SPAlist	;goalie does glove save left
SPAgglovel_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFGoalie+2
.off	=	3
.0	dc.w	.a,-32
.a	set	.a+.off
.1	dc.w	.a,-32
.a	set	.a+.off
.2	dc.w	.a,-32
.a	set	.a+.off
.3	dc.w	.a,-32
.a	set	.a+.off
.4	dc.w	.a,-32
.a	set	.a+.off
.5	dc.w	.a,-32
.a	set	.a+.off
.6	dc.w	.a,-32
.a	set	.a+.off
.7	dc.w	.a,-32

SPAgstickr	=	*-SPAlist	;goalie stick save right
SPAgstickr_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFGoalie+64
.off	=	2
.0	dc.w	.a,-32
.a	set	.a+.off
.1	dc.w	.a,-32
.a	set	.a+.off
.2	dc.w	.a,-32
.a	set	.a+.off
.3	dc.w	.a,-32
.a	set	.a+.off
.4	dc.w	.a,-32
.a	set	.a+.off
.5	dc.w	.a,-32
.a	set	.a+.off
.6	dc.w	.a,-32
.a	set	.a+.off
.7	dc.w	.a,-32

SPAgstickl	=	*-SPAlist	;goalie stick save left
SPAgstickl_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFGoalie+65
.off	=	2
.0	dc.w	.a,-32
.a	set	.a+.off
.1	dc.w	.a,-32
.a	set	.a+.off
.2	dc.w	.a,-32
.a	set	.a+.off
.3	dc.w	.a,-32
.a	set	.a+.off
.4	dc.w	.a,-32
.a	set	.a+.off
.5	dc.w	.a,-32
.a	set	.a+.off
.6	dc.w	.a,-32
.a	set	.a+.off
.7	dc.w	.a,-32

SPAgstackr	=	*-SPAlist	;goalie stack right
SPAgstackr_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFGoalie+40
.off	=	2
.0	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.1	dc.w	.a,8,.a+1,-32
.2	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.3	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.4	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.5	dc.w	.a,8,.a+1,-32
.6	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.7	dc.w	.a,8,.a+1,-32

SPAgstackl	=	*-SPAlist	;goalie stack left
SPAgstackl_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFGoalie+52
.off	=	2
.0	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.1	dc.w	.a,8,.a+1,-32
.2	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.3	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.4	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.5	dc.w	.a,8,.a+1,-32
.6	dc.w	.a,8,.a+1,-32
.a	set	.a+.off
.7	dc.w	.a,8,.a+1,-32

SPAgswing	=	*-SPAlist	;goalie passes puck
SPAgswing_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFGoalie+24
.off	=	2
.0	dc.w	.a,5,.a+1,8,.a,-16
.a	set	.a+.off
.1	dc.w	.a,5,.a+1,8,.a,-16
.a	set	.a+.off
.2	dc.w	.a,5,.a+1,8,.a,-16
.a	set	.a+.off
.3	dc.w	.a,5,.a+1,8,.a,-16
.a	set	.a+.off
.4	dc.w	.a,5,.a+1,8,.a,-16
.a	set	.a+.off
.5	dc.w	.a,5,.a+1,8,.a,-16
.a	set	.a+.off
.6	dc.w	.a,5,.a+1,8,.a,-16
.a	set	.a+.off
.7	dc.w	.a,5,.a+1,8,.a,-16
	
SPAgskate	=	*-SPAlist	;goalie skates
SPAgskate_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	1<<0

.a	=	SPFGoalie+80
.off	=	4
.0	dc.w	.a,10,.a+1,10,.a+2,10,.a+3,-15
.a	set	.a+.off
.1	dc.w	.a,10,.a+1,10,.a+2,10,.a+3,-15
.a	set	.a+.off
.2	dc.w	.a,10,.a+1,10,.a+2,10,.a+3,-15
.a	set	.a+.off
.3	dc.w	.a,10,.a+1,10,.a+2,10,.a+3,-15
.a	set	.a+.off
.4	dc.w	.a,10,.a+1,10,.a+2,10,.a+3,-15
.a	set	.a+.off
.5	dc.w	.a,10,.a+1,10,.a+2,10,.a+3,-15
.a	set	.a+.off
.6	dc.w	.a,10,.a+1,10,.a+2,10,.a+3,-15
.a	set	.a+.off
.7	dc.w	.a,10,.a+1,10,.a+2,10,.a+3,-15

SPApflip	=	*-SPAlist	;puck animation
SPApflip_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	1<<0	;flag for repeat animation

.a	=	SPFpuck+1

.0	dc.w	.a+1,4,.a+2,4,.a+3,4,.a+4,4,.a+5,4,.a+2,4,.a+6,4,.a+0,-4
.1	dc.w	.a+8,2,.a+0,2,.a+7,2,.a+4,2,.a+9,2,.a+4,2,.a+7,2,.a+0,-2
.2	dc.w	.a+3,2,.a+2,2,.a+1,2,.a+0,2,.a+6,2,.a+2,2,.a+5,2,.a+4,-2
.3	dc.w	.a+7,4,.a+0,4,.a+8,4,.a+0,4,.a+7,4,.a+4,4,.a+9,4,.a+4,-4
.4	dc.w	.a+0,-$1000
.5	dc.w	.a+0,-$1000
.6	dc.w	.a+4,-$1000
.7	dc.w	.a+4,-$1000

SPAglide	=	*-SPAlist	;player gliding with stick down
SPAglide_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFskatewp
.off	=	5
.0	dc.w	.a,-8
.a	set	.a+.off
.1	dc.w	.a,-8
.a	set	.a+.off
.2	dc.w	.a,-8
.a	set	.a+.off
.3	dc.w	.a,-8
.a	set	.a+.off
.4	dc.w	.a,-8
.a	set	.a+.off
.5	dc.w	.a,-8
.a	set	.a+.off
.6	dc.w	.a,-8
.a	set	.a+.off
.7	dc.w	.a,-8

SPAskatewp	=	*-SPAlist	;player skating with stick down
SPAskatewp_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFskatewp
.off	=	5
.0	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a,-15
.a	set	.a+.off
.1	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a,-15
.a	set	.a+.off
.2	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a,-15
.a	set	.a+.off
.3	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a,-15
.a	set	.a+.off
.4	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a,-15
.a	set	.a+.off
.5	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a,-15
.a	set	.a+.off
.6	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a,-15
.a	set	.a+.off
.7	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a,-15

SPAskate	=	*-SPAlist	;player skating with stick up
SPAskate_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFskate
.off	=	5
.0	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a+0,-15
.a	set	.a+.off
.1	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a+0,-15
.a	set	.a+.off
.2	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a+0,-15
.a	set	.a+.off
.3	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a+0,-15
.a	set	.a+.off
.4	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a+0,-15
.a	set	.a+.off
.5	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a+0,-15
.a	set	.a+.off
.6	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a+0,-15
.a	set	.a+.off
.7	dc.w	.a+1,10,.a+2,10,.a+3,10,.a+4,10,.a+0,-15

SPAturnl	=	*-SPAlist	;player turning left
SPAturnl_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFturnl
.0	dc.w	.a+0,-18
.1	dc.w	.a+1,-18
.2	dc.w	.a+2,-18
.3	dc.w	.a+3,-18
.4	dc.w	.a+4,-18
.5	dc.w	.a+5,-18
.6	dc.w	.a+6,-18
.7	dc.w	.a+7,-18

SPAturnr	=	*-SPAlist	;player turning right
SPAturnr_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFturnr
.0	dc.w	.a+0,-18
.1	dc.w	.a+1,-18
.2	dc.w	.a+2,-18
.3	dc.w	.a+3,-18
.4	dc.w	.a+4,-18
.5	dc.w	.a+5,-18
.6	dc.w	.a+6,-18
.7	dc.w	.a+7,-18

SPAstop	=	*-SPAlist	;player scrape stopping
SPAstop_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	1<<0	;repeating animation

.a	=	SPFstop
.off	=	2
.0	dc.w	.a+0,4,.a+1,-4
.a	set	.a+.off
.1	dc.w	.a+0,4,.a+1,-4
.a	set	.a+.off
.2	dc.w	.a+0,4,.a+1,-4
.a	set	.a+.off
.3	dc.w	.a+0,4,.a+1,-4
.a	set	.a+.off
.4	dc.w	.a+0,4,.a+1,-4
.a	set	.a+.off
.5	dc.w	.a+0,4,.a+1,-4
.a	set	.a+.off
.6	dc.w	.a+0,4,.a+1,-4
.a	set	.a+.off
.7	dc.w	.a+0,4,.a+1,-4

SPApassf	=	*-SPAlist	;forward pass swing
SPApassf_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFswing
.off	=	6
.0	dc.w	.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.1	dc.w	.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.2	dc.w	.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.3	dc.w	.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.4	dc.w	.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.5	dc.w	.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.6	dc.w	.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.7	dc.w	.a+3,4,.a+4,4,.a+5,-20

SPApassb	=	*-SPAlist	;back hand pass swing
SPApassb_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFswing
.off	=	6
.0	dc.w	.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.1	dc.w	.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.2	dc.w	.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.3	dc.w	.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.4	dc.w	.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.5	dc.w	.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.6	dc.w	.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.7	dc.w	.a+3,4,.a+2,4,.a+1,-20

SPAshotf	=	*-SPAlist	;player shoots forhand
SPAshotf_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFswing
.off	=	6
.0	dc.w	.a+3,4,.a+2,4,.a+1,4,.a+0,4,.a+1,4,.a+2,4,.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.1	dc.w	.a+3,4,.a+2,4,.a+1,4,.a+0,4,.a+1,4,.a+2,4,.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.2	dc.w	.a+3,4,.a+2,4,.a+1,4,.a+0,4,.a+1,4,.a+2,4,.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.3	dc.w	.a+3,4,.a+2,4,.a+1,4,.a+0,4,.a+1,4,.a+2,4,.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.4	dc.w	.a+3,4,.a+2,4,.a+1,4,.a+0,4,.a+1,4,.a+2,4,.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.5	dc.w	.a+3,4,.a+2,4,.a+1,4,.a+0,4,.a+1,4,.a+2,4,.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.6	dc.w	.a+3,4,.a+2,4,.a+1,4,.a+0,4,.a+1,4,.a+2,4,.a+3,4,.a+4,4,.a+5,-20
.a	set	.a+.off
.7	dc.w	.a+3,4,.a+2,4,.a+1,4,.a+0,4,.a+1,4,.a+2,4,.a+3,4,.a+4,4,.a+5,-20

SPAshotb	=	*-SPAlist	;player shoots backhand
SPAshotb_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFswing
.off	=	6
.0	dc.w	.a+3,4,.a+4,4,.a+5,4,.a+5,4,.a+5,4,.a+4,4,.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.1	dc.w	.a+3,4,.a+4,4,.a+5,4,.a+5,4,.a+5,4,.a+4,4,.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.2	dc.w	.a+3,4,.a+4,4,.a+5,4,.a+5,4,.a+5,4,.a+4,4,.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.3	dc.w	.a+3,4,.a+4,4,.a+5,4,.a+5,4,.a+5,4,.a+4,4,.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.4	dc.w	.a+3,4,.a+4,4,.a+5,4,.a+5,4,.a+5,4,.a+4,4,.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.5	dc.w	.a+3,4,.a+4,4,.a+5,4,.a+5,4,.a+5,4,.a+4,4,.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.6	dc.w	.a+3,4,.a+4,4,.a+5,4,.a+5,4,.a+5,4,.a+4,4,.a+3,4,.a+2,4,.a+1,-20
.a	set	.a+.off
.7	dc.w	.a+3,4,.a+4,4,.a+5,4,.a+5,4,.a+5,4,.a+4,4,.a+3,4,.a+2,4,.a+1,-20

SPAglideback	=	*-SPAlist	;player gliding backwards
SPAglideback_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFskateb
.off	=	3
.0	dc.w	.a,-8
.a	set	.a+.off
.1	dc.w	.a,-8
.a	set	.a+.off
.2	dc.w	.a,-8
.a	set	.a+.off
.3	dc.w	.a,-8
.a	set	.a+.off
.4	dc.w	.a,-8
.a	set	.a+.off
.5	dc.w	.a,-8
.a	set	.a+.off
.6	dc.w	.a,-8
.a	set	.a+.off
.7	dc.w	.a,-8

SPAskateback	=	*-SPAlist	;player skating backwards
SPAskateback_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFskateb
.off	=	3
.0	dc.w	.a,10,.a+1,10,.a,10,.a+2,-10
.a	set	.a+.off
.1	dc.w	.a,10,.a+1,10,.a,10,.a+2,-10
.a	set	.a+.off
.2	dc.w	.a,10,.a+1,10,.a,10,.a+2,-10
.a	set	.a+.off
.3	dc.w	.a,10,.a+1,10,.a,10,.a+2,-10
.a	set	.a+.off
.4	dc.w	.a,10,.a+1,10,.a,10,.a+2,-10
.a	set	.a+.off
.5	dc.w	.a,10,.a+1,10,.a,10,.a+2,-10
.a	set	.a+.off
.6	dc.w	.a,10,.a+1,10,.a,10,.a+2,-10
.a	set	.a+.off
.7	dc.w	.a,10,.a+1,10,.a,10,.a+2,-10

SPAsweepchk	=	*-SPAlist	;player stick (sweep) checking
SPAsweepchk_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFsweep
.off	=	2
.0	dc.w	.a,4,.a+1,8,.a,-4
.a	set	.a+.off
.1	dc.w	.a,4,.a+1,8,.a,-4
.a	set	.a+.off
.2	dc.w	.a,4,.a+1,8,.a,-4
.a	set	.a+.off
.3	dc.w	.a,4,.a+1,8,.a,-4
.a	set	.a+.off
.4	dc.w	.a,4,.a+1,8,.a,-4
.a	set	.a+.off
.5	dc.w	.a,4,.a+1,8,.a,-4
.a	set	.a+.off
.6	dc.w	.a,4,.a+1,8,.a,-4
.a	set	.a+.off
.7	dc.w	.a,4,.a+1,8,.a,-4

SPAshoulderchkl	=	*-SPAlist	;player shoulder checking left
SPAshoulderchkl_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFshoulderl
.off	=	1
.0	dc.w	.a,-24
.a	set	.a+.off
.1	dc.w	.a,-24
.a	set	.a+.off
.2	dc.w	.a,-24
.a	set	.a+.off
.3	dc.w	.a,-24
.a	set	.a+.off
.4	dc.w	.a,-24
.a	set	.a+.off
.5	dc.w	.a,-24
.a	set	.a+.off
.6	dc.w	.a,-24
.a	set	.a+.off
.7	dc.w	.a,-24

SPAshoulderchkr	=	*-SPAlist	;player shoulder checking right
SPAshoulderchkr_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFshoulderr
.off	=	1
.0	dc.w	.a,-24
.a	set	.a+.off
.1	dc.w	.a,-24
.a	set	.a+.off
.2	dc.w	.a,-24
.a	set	.a+.off
.3	dc.w	.a,-24
.a	set	.a+.off
.4	dc.w	.a,-24
.a	set	.a+.off
.5	dc.w	.a,-24
.a	set	.a+.off
.6	dc.w	.a,-24
.a	set	.a+.off
.7	dc.w	.a,-24

SPAhipchkl	=	*-SPAlist	;player hip checking left
SPAhipchkl_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFhipl
.off	=	1
.0	dc.w	.a,-24
.a	set	.a+.off
.1	dc.w	.a,-24
.a	set	.a+.off
.2	dc.w	.a,-24
.a	set	.a+.off
.3	dc.w	.a,-24
.a	set	.a+.off
.4	dc.w	.a,-24
.a	set	.a+.off
.5	dc.w	.a,-24
.a	set	.a+.off
.6	dc.w	.a,-24
.a	set	.a+.off
.7	dc.w	.a,-24

SPAhipchkr	=	*-SPAlist	;player hip checking right
SPAhipchkr_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFhipr
.off	=	1
.0	dc.w	.a,-24
.a	set	.a+.off
.1	dc.w	.a,-24
.a	set	.a+.off
.2	dc.w	.a,-24
.a	set	.a+.off
.3	dc.w	.a,-24
.a	set	.a+.off
.4	dc.w	.a,-24
.a	set	.a+.off
.5	dc.w	.a,-24
.a	set	.a+.off
.6	dc.w	.a,-24
.a	set	.a+.off
.7	dc.w	.a,-24

SPAburst	=	*-SPAlist	;player doing c button (speed/no check)
SPAburst_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFskate
.off	=	5
.0	dc.w	.a,-24
.a	set	.a+.off
.1	dc.w	.a,-24
.a	set	.a+.off
.2	dc.w	.a,-24
.a	set	.a+.off
.3	dc.w	.a,-24
.a	set	.a+.off
.4	dc.w	.a,-24
.a	set	.a+.off
.5	dc.w	.a,-24
.a	set	.a+.off
.6	dc.w	.a,-24
.a	set	.a+.off
.7	dc.w	.a,-24

SPAHold	=	*-SPAlist	;player trying to hold
SPAHold_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFhold
.off	=	1
.0	dc.w	.a,-30
.a	set	.a+.off
.1	dc.w	.a,-30
.a	set	.a+.off
.2	dc.w	.a,-30
.a	set	.a+.off
.3	dc.w	.a,-30
.a	set	.a+.off
.4	dc.w	.a,-30
.a	set	.a+.off
.5	dc.w	.a,-30
.a	set	.a+.off
.6	dc.w	.a,-30
.a	set	.a+.off
.7	dc.w	.a,-30

SPAHold2	=	*-SPAlist	;player holding opponent
SPAHold2_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFhold
.off	=	1
.0	dc.w	.a,-30
.a	set	.a+.off
.1	dc.w	.a,-30
.a	set	.a+.off
.2	dc.w	.a,-30
.a	set	.a+.off
.3	dc.w	.a,-30
.a	set	.a+.off
.4	dc.w	.a,-30
.a	set	.a+.off
.5	dc.w	.a,-30
.a	set	.a+.off
.6	dc.w	.a,-30
.a	set	.a+.off
.7	dc.w	.a,-30

SPAflail	=	*-SPAlist	;player being held by opponent
SPAflail_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFskate
.off	=	5
.0	dc.w	.a,-30
.a	set	.a+.off
.1	dc.w	.a,-30
.a	set	.a+.off
.2	dc.w	.a,-30
.a	set	.a+.off
.3	dc.w	.a,-30
.a	set	.a+.off
.4	dc.w	.a,-30
.a	set	.a+.off
.5	dc.w	.a,-30
.a	set	.a+.off
.6	dc.w	.a,-30
.a	set	.a+.off
.7	dc.w	.a,-30

SPAfallfwd	=	*-SPAlist	;player falling forward
SPAfallfwd_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfallfwd
.b	=	SPFduck
.off	=	4
.0	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.1	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.2	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.3	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.4	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.5	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.6	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.7	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8

SPAfallback	=	*-SPAlist	;player falling backward
SPAfallback_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfallback
.b	=	SPFduck
.off	=	4
.0	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.1	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.2	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.3	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.4	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.5	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.6	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8
.a	set	.a+.off
.b	set	.b+1
.7	dc.w	.a,6,.a+1,6,.a+2,100,.a+3,8,.b,-8

SPAcelebrate	=	*-SPAlist	;player raising stick/arms up
SPAcelebrate_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFcelebrate
.off	=	2
.0	dc.w	.a,12,.a+1,40,.a,-5
.a	set	.a+.off
.1	dc.w	.a,12,.a+1,40,.a,-5
.a	set	.a+.off
.2	dc.w	.a,12,.a+1,40,.a,-5
.a	set	.a+.off
.3	dc.w	.a,12,.a+1,40,.a,-5
.a	set	.a+.off
.4	dc.w	.a,12,.a+1,40,.a,-5
.a	set	.a+.off
.5	dc.w	.a,12,.a+1,40,.a,-5
.a	set	.a+.off
.6	dc.w	.a,12,.a+1,40,.a,-5
.a	set	.a+.off
.7	dc.w	.a,12,.a+1,40,.a,-5

SPApump	=	*-SPAlist	;player doing pump animation
SPApump_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFpump
.off	=	2
.0	dc.w	.a,8,.a+1,8,.a,-8
.a	set	.a+.off
.1	dc.w	.a,8,.a+1,8,.a,-8
.a	set	.a+.off
.2	dc.w	.a,8,.a+1,8,.a,-8
.a	set	.a+.off
.3	dc.w	.a,8,.a+1,8,.a,-8
.a	set	.a+.off
.4	dc.w	.a,8,.a+1,8,.a,-8
.a	set	.a+.off
.5	dc.w	.a,8,.a+1,8,.a,-8
.a	set	.a+.off
.6	dc.w	.a,8,.a+1,8,.a,-8
.a	set	.a+.off
.7	dc.w	.a,8,.a+1,8,.a,-8

SPAfight	=	*-SPAlist	;player throwing off gloves
SPAfight_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfight
.0
.1
.2	dc.w	.a,8,.a+1,8,.a+2,8,.a+3,-6
.3
.4
.5
.6
.7	dc.w	.a,8,.a+1,8,.a+2,8,.a+3+5,-6

SPAfgrab	=	*-SPAlist	;fighter grabbing
SPAfgrab_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfight+3
.0
.1
.2	dc.w	.a+1,28,.a,-4
.a	set	.a+5
.3
.4
.5
.6
.7	dc.w	.a+1,28,.a,-4

SPAfheld	=	*-SPAlist	;fighter holding
SPAfheld_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfight+3
.0
.1
.2	dc.w	.a+1,30,.a,-4
.a	set	.a+5
.3
.4
.5
.6
.7	dc.w	.a+1,30,.a,-4

SPAfhigh	=	*-SPAlist	;fighter throws high punch
SPAfhigh_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfight+3
.0
.1
.2	dc.w	.a+2,6,.a+3,16,.a+2,4,.a,-16
.a	set	.a+5
.3
.4
.5
.6
.7	dc.w	.a+2,6,.a+3,16,.a+2,4,.a,-16

SPAflow	=	*-SPAlist	;fighter throws low punch
SPAflow_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfight+3
.0
.1
.2	dc.w	.a+2,6,.a+4,16,.a+2,4,.a,-16
.a	set	.a+5
.3
.4
.5
.6
.7	dc.w	.a+2,6,.a+4,16,.a+2,4,.a,-16

SPAfhith	=	*-SPAlist	;fighter hit by high punch
SPAfhith_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfight+3
.0
.1
.2	dc.w	SPFfight+14,16,.a,-8
.a	set	.a+5
.3
.4
.5
.6
.7	dc.w	SPFfight+14,16,.a,-8

SPAfhitl	=	*-SPAlist	;fighter hit by low punch
SPAfhitl_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfight+3
.0
.1
.2	dc.w	SPFfight+13,16,.a,-8
.a	set	.a+5
.3
.4
.5
.6
.7	dc.w	SPFfight+13,16,.a,-8

SPAffall	=	*-SPAlist	;fighter falls down
SPAffall_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFfight+3+11
.0
.1
.2
.3
.4
.5
.6
.7	dc.w	.a,8,.a+1,8,.a+2,200,.a+2,-2

SPAwallright	=	*-SPAlist	;player jumps wall with legs to the right
SPAwallright_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFpen
.0	dc.w	.a+4,8,.a+5,8,.a+6,-8
.1
.2	dc.w	.a,8,.a+1,8,.a+2,8,.a+3,-8
.3
.4
.5
.6	dc.w	.a+3,8,.a+2,8,.a+1,8,.a,-8
.7

SPAwallleft	=	*-SPAlist	;player jumps wall with legs to the left
SPAwallleft_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.a	=	SPFpen
.0	dc.w	.a+6,8,.a+5,8,.a+4,-8
.1
.2	dc.w	.a+3,8,.a+2,8,.a+1,8,.a,-8
.3
.4
.5
.6	dc.w	.a,8,.a+1,8,.a+2,8,.a+3,-8
.7

SPAfaceoff	=	*-SPAlist	;player does faceoff stick check
SPAfaceoff_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	SPFskatewp,2,SPFsweep+1,10,SPFsweep,-6
.1
.2
.3
.4
.5
.6
.7	dc.w	SPFskatewp+20,2,SPFsweep+9,10,SPFsweep+8,-6

SPAfaceoffr	=	*-SPAlist	;ready position for faceoff
SPAfaceoffr_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	SPFskatewp,-5
.1
.2
.3
.4
.5
.6
.7	dc.w	SPFskatewp+20,-5

SPAsiren	=	*-SPAlist	;siren animation
SPAsiren_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	1

.0
.1
.2
.3
.4
.5
.6
.7	dc.w	SPFsiren,3
	dc.w	SPFsiren+1,3
	dc.w	SPFsiren+2,3
	dc.w	SPFsiren+3,3
	dc.w	SPFsiren+4,3
	dc.w	SPFsiren+5,3
	dc.w	SPFsiren+6,3
	dc.w	SPFsiren+7,3
	dc.w	SPFsiren+8,3
	dc.w	SPFsiren+9,3
	dc.w	SPFsiren+10,3
	dc.w	SPFsiren+11,3
	dc.w	SPFsiren+12,3
	dc.w	SPFsiren+13,-3

SPAstanley	=	*-SPAlist	;player skates with stanley cup over head
SPAstanley_table:
.t
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	1

.a	=	SPFcup
.off	=	1
.0	dc.w	.a,-30
.a	set	.a+.off
.1	dc.w	.a,-30
.a	set	.a+.off
.2	dc.w	.a,-30
.a	set	.a+.off
.3	dc.w	.a,-30
.a	set	.a+.off
.4	dc.w	.a,-30
.a	set	.a+.off
.5	dc.w	.a,-30
.a	set	.a+.off
.6	dc.w	.a,-30
.a	set	.a+.off
.7	dc.w	.a,-30