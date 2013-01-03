
;-------------------------------------------------------------------
;
;ATTACK OF THE MUTANT CAMELS
;
;


		include kms.inc			;PORT definitions file !


		opt d+					;enable downloading


;		object amc.com			;save out an executable


JOY_TIMEOUT	= 100

;=====================================================================
; The DATA segment. Must be before the code segment for the assume to
; work
;

data	segment	at 9000h


; blitter prog to produce solid-rectangle in colour BCOL
; at BLOX and BLOY, size given by BWID and BHIG
;
; screen seg put in SSEG

block	DB	0,0,0		; SOURCE: NOT USED
blox	db 	0		; block X co-ord
bloy	db 	0		; block Y-co-ord
sseg	db 	0		; screen segment base
bset	DB	062h		; MODE: byte per pixel and bit8 of inner
	DB	0C0h		; LFU and comp: dest <- source
bhig	DB	200		; OUTER: 200 lines deep
bwid	DB	0		; INNER: 256 (mode = bit8 of inner)
bstep	DB	0		; STEP: no step because treating as linear memory
bcol	DB	0		; PATTERN: colour 0
	DB	0		; NEXT COMMAND: stop

hline	db 0,0,0		;draw horizontal line
lix	db 0
liy	db 0			;XY line start
lseg	db 0
lset	db 020h
	db 0c0h
	db 1			;single line
llen	db 4			;line length
	db 0			;no Step
lcolr	db 0			;colour
	db 0			;no next cmd
pixel	db 0,0,0
pixx	db 0
pixy	db 0
pixp	db 0,20h,0c0h,2,2,254
pixc	db 0,0




;---------------------------------------------------------------
;Blitter program for getting the balls background, then plotting
;the ball IMMEDIATELY afterwards

do_plot
back_x	db 0				;source =on screen, coords poked in
back_y	db 0
	db 0				;seg of screen/1000h
;	dw ball_buff			;dest= background buffer
	db 9				;at seg 9000h
	db 020h				;MEDIUM res
	db 0c0h				;dest <- source (straight copy)
	db 34,136,120			;width and height
	db 0				;NOT used
	db 31h				;command for next blit = another copy
					;31h=	RUN (execute the blitter)
					;	DSTUP (destination is rectangle)
					;	SRCEN (read source)



;	dw huge_sprite+5
	db 9+16				;buffer seg/1000h and source to be used as source in comparator
ball_x	db 0				;X and Y positions set by the program
ball_y	db 0
	db 0				;screen seg/1000h and transparent to be used as dest in comparator
	db 020h				;MEDIUM res
	db 0c1h				;dest <- source (copy with source=inhibit on dest=source (transparent=source)
	db 34,136,120			;ball width and height
	db 0				;pattern: transparent colour
	db 0				;next command -STOP

;Blitter program to transfer sprite from data to screen
;Sprites laid out on 'virtual-screen' - 256 bytes/scnline,
;arbitrary depth - starting at 'sprites'

dsprite
srcex	db 0
srcey	db 0
srcep	db 9+16

;Before blitting, the X- and Y-co-ords of the desired sprite
;segment are added to the low-word of sprites' address.
;The '+16' sets the Source Address for use inspead of the Pattern Bytes.

dstx	db 0
dsty	db 0
dstp	db 0

;Straightforward dest-address co-ords. If comparator is being used
;then '+16' may have to be added to dest page.

	db 20h

;256-colour mode, no compare, inner loop never >255

	db 0c1h	

;Straight source-to-dest copy, CMPEQ set, inhibit colour-0 write

shig	db 0
swid	db 0

;Sprite height and width. Should be correctly set by the sprite-clip
;logic.

sstp	db 0

;Step register. Always (255-swid)+1

	db 0

;Pattern register - colour-zero (transparent)

	db 0

;Next command=STOP 



	
;---------------------------------------------------
;Blitter program for restoring the ball's background

;restore	dw ball_buff		;copy blit, from the ball's background buffer
	db 9			;buffer is at seg 9000h, so use 9 here
old_x	db 0			;program sets these coords
old_y	db 0
	db 0			;screen at seg 0000h, hence 0 here
	db 020h			;MEDIUM resolution screen
	db 0c0h			;dest <- source (straight copy)
	db 34,136,120		;width and height of destination, addon =256-width
	db 0			;NOT used
	db 0			;NO blitter program following so STOP


;---------------------------------------------------------------------
;Blitter for drawing a line. Modified by line routine before execution


line_blit
delta_12	db 39		;source= DELTA1/2
delta_1a	db 79		;DELTA1
x_sign		db 0
start_x		db 5		;Start X point
start_y		db 5		;Start Y point
y_sign		db 0
l_mode		db 8+32+128	;LINE draw and MED res and PATSEL
		db 0c0h		;dest <- source
		db 1		;OUTER: 1
delta_1b	db 79		;INNER: delta 1
delta_2		db 13		;STEP: delta 2
line_col	db 220		;PATTERN: colour
		db 0		;NEXT COMMAND: stop


;----------------------------------------
;Variable used to hold last random number

seed		dw 0



clist		dw offset rl1	;test rasta IRQ colour list

rl1		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


rl2		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

rl3		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

rl4		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


cline		dw 0
scrl		dw 0
;game constants here

sinfo		db 133,33,43,0,0,0,0,0	;sprite info for Big Rocket
		db 43,14,0,0,0,0,0,0	;small ship left
		db 43,14,0,14,0,0,0,0	;small ship right
		db 166,18,44,33,0,0,0,0	;llamasoft logo
		db 4,5,0,52,0,0,0,0	;<spc>  [Williams small]
		db 2,5,4,52,0,0,0,0	;!
		db 4,2,6,52,0,0,0,0	;"
		db 6,5,10,52,0,0,0,0	;<hash>ish
		db 5,5,16,52,0,0,0,0	;<quid>
		db 4,5,21,52,0,0,0,0	;%
		db 8,5,25,52,0,0,0,0	;&  s10
		db 2,2,33,52,0,0,0,0	;'
		db 3,5,35,52,0,0,0,0	;(
		db 3,5,38,52,0,0,0,0	;)
		db 6,5,41,52,0,0,0,0	;*
		db 6,5,47,52,0,0,0,0	;+
		db 3,6,53,52,0,0,0,0	;,
		db 5,3,56,52,0,0,0,0	;-
		db 2,5,61,52,0,0,0,0	;.
		db 4,5,63,52,0,0,0,0	;/
		db 4,5,67,52,0,0,0,0	;0  s20
		db 2,5,71,52,0,0,0,0	;1
		db 4,5,73,52,0,0,0,0	;2
		db 4,5,77,52,0,0,0,0	;3
		db 5,5,81,52,0,0,0,0	;4
		db 4,5,86,52,0,0,0,0	;5
		db 4,5,90,52,0,0,0,0	;6
		db 4,5,94,52,0,0,0,0	;7
		db 4,5,98,52,0,0,0,0	;8
		db 4,5,102,52,0,0,0,0	;9
		db 2,4,106,52,0,0,0,0	;:  s30
		db 3,6,108,52,0,0,0,0	;
		db 4,5,111,52,0,0,0,0	;<
		db 4,4,115,52,0,0,0,0	;=
		db 4,5,119,52,0,0,0,0	;>
		db 4,5,123,52,0,0,0,0	;?
		db 6,5,127,52,0,0,0,0	;@
		db 4,5,134,52,0,0,0,0	;a
		db 5,5,138,52,0,0,0,0	;b
		db 4,5,143,52,0,0,0,0	;c
		db 4,5,147,52,0,0,0,0	;d  s40
		db 4,5,151,52,0,0,0,0	;e
		db 4,5,155,52,0,0,0,0	;f
		db 4,5,159,52,0,0,0,0	;g
		db 4,5,163,52,0,0,0,0	;h
		db 2,5,167,52,0,0,0,0	;i
		db 3,6,169,52,0,0,0,0	;j
		db 5,5,172,52,0,0,0,0	;k
		db 4,5,177,52,0,0,0,0	;l
		db 6,5,181,52,0,0,0,0	;m
		db 4,5,187,52,0,0,0,0	;n  s50
		db 4,5,191,52,0,0,0,0	;o
		db 4,5,195,52,0,0,0,0	;p
		db 4,6,199,52,0,0,0,0	;q
		db 4,5,204,52,0,0,0,0	;r
		db 4,5,208,52,0,0,0,0	;s
		db 4,5,212,52,0,0,0,0	;t
		db 4,5,216,52,0,0,0,0	;u
		db 4,5,220,52,0,0,0,0	;v
		db 6,5,224,52,0,0,0,0	;w
		db 6,5,230,52,0,0,0,0	;x  s60
		db 4,5,236,52,0,0,0,0	;y
		db 4,5,240,52,0,0,0,0	;z
		db 16,35,0,58,0,0,0,0	;rl1
		db 14,35,16,58,0,0,0,0	;rl2
		db 12,35,30,58,0,0,0,0	;rl3
		db 12,35,42,58,0,0,0,0	;rl4
		db 17,35,54,58,0,0,0,0	;rl5
		db 20,35,71,58,0,0,0,0	;rl6
		db 16,35,91,58,0,0,0,0	;rl7
		db 14,33,107,58,0,0,0,0	;rl8 s70
		db 20,30,121,58,0,0,0,0	;rl9
		db 17,27,141,58,0,0,0,0	;rl10
		db 25,26,158,58,0,0,0,0	;rl11
		db 21,31,183,58,0,0,0,0	;rl12
		db 22,32,204,58,0,0,0,0	;rl13
		db 18,34,226,58,0,0,0,0	;rl14
		db 17,35,0,93,0,0,0,0	;rl15 
		db 23,34,17,93,0,0,0,0	;fl1
		db 22,34,40,93,0,0,0,0	;fl2
		db 19,34,62,93,0,0,0,0	;fl3 s80
		db 15,34,81,93,0,0,0,0	;fl4
		db 12,34,96,93,0,0,0,0	;fl5
		db 11,34,108,91,0,0,0,0	;fl6
		db 13,34,119,88,0,0,0,0	;fl7
		db 16,35,132,88,0,0,0,0	;fl8
		db 22,34,148,85,0,0,0,0	;fl9
		db 28,32,170,89,0,0,0,0	;fl10
		db 22,25,198,90,0,0,0,0	;fl11
		db 23,24,220,92,0,0,0,0	;fl12
		db 30,21,0,128,0,0,0,0	;fl13 s90
		db 29,28,30,127,0,0,0,0	;fl14
		db 23,34,59,127,0,0,0,0	;fl15
		db 27,34,82,127,0,0,0,0	;fl16
		db 48,41,109,125,0,0,0,0	;cbod
		db 18,21,157,121,0,0,0,0	;cnek1
		db 20,21,157,142,0,0,0,0	;cnek2
		db 21,21,178,121,0,0,0,0	;cnek3
		db 23,18,177,142,0,0,0,0	;cnek4
		db 14,19,199,120,0,0,0,0	;ched1
		db 7,20,210,139,0,0,0,0		;cta1  s100
		db 11,18,217,130,0,0,0,0	;cta2
		db 17,14,220,116,0,0,0,0	;cta3
		db 22,5,198,115,0,0,0,0		;cta4
		db 17,12,217,148,0,0,0,0	;cta5
		db 10,19,200,139,0,0,0,0	;cta6
		db 12,18,229,130,0,0,0,0	;cta7
		db 55,39,0,161,0,0,0,0	;pyramid
		db 201,7,55,193,0,0,0,0	;ground zero
		db 64,3,0,155,0,0,0,0	;l2 ground 1
		db 64,3,0,158,0,0,0,0	;l2 ground 2  s110
		db 27,15,137,178,0,0,0,0	;mosk
		db 31,16,164,177,0,0,0,0	;pyr
		db 9,5,195,188,0,0,0,0	;small camel 1
		db 9,5,195,183,0,0,0,0	;small camel2
		db 13,14,204,179,0,0,0,0	;palm
		db 16,8,217,185,0,0,0,0	;titchy pyr.
		db 22,28,55,165,0,0,0,0	;big palm
		db 9,29,77,163,0,0,0,0	;obeliskk
		db 51,29,86,164,0,0,0,0	;anubis
		db 26,5,137,173,0,0,0,0	;cloud 1 s120
		db 36,6,138,167,0,0,0,0	;cloud 2
		db 45,8,174,169,0,0,0,0	;cloud 3
		db 19,13,233,180,0,0,0,0	;cloud 4
		db 29,25,177,0,0,0,0,0	;sun
		db 21,19,206,0,0,0,0,0	;moon
		db 21,12,43,12,0,0,0,0	;ship
		db 12,14,64,0,0,0,0,0	;ship
		db 21,12,43,0,0,0,0,0	;ship
		db 20,7,0,36,0,0,0,0	;flame1
		db 32,8,0,28,0,0,0,0	;flame2 s130
		db 44,9,0,43,0,0,0,0	;flame3
		db 20,7,20,36,0,0,0,0	;flame4
		db 32,8,210,44,0,0,0,0	;flame5
		db 44,9,205,24,0,0,0,0	;flame6
		db 17,5,43,24,0,0,0,0	;bullet 1
		db 17,5,61,24,0,0,0,0	;bullet 2
		db 15,15,76,0,0,0,0,0	;exp 1
		db 15,15,91,0,0,0,0,0	;exp 2
		db 15,15,106,0,0,0,0,0	;exp 3
		db 5,5,210,33,0,0,0,0	;ball shot S140
		db 5,5,210,38,0,0,0,0	;ball shot
		db 41,1,150,30,0,0,0,0	;las 1
		db 80,1,109,29,0,0,0,0	;las2
		db 121,1,44,32,0,0,0,0	;las3
		db 41,1,109,30,0,0,0,0	;las4
		db 80,1,109,31,0,0,0,0	;las5
		db 121,1,87,51,0,0,0,0	;las6
		db 7,4,170,15,0,0,0,0	;orbital bullet
;		db 10,7,215,33,0,0,0,0	;chev <
;		db 10,7,225,33,0,0,0,0	;chev > s150
		db 11,15,154,0,0,0,0,0
		db 11,15,165,0,0,0,0,0
		db 6,40,244,55,0,0,0,0	;wide <
		db 6,40,250,55,0,0,0,0	;wide >
		db 12,18,244,129,0,0,0,0	;base bit [top]
		db 12,34,244,95,0,0,0,0	;base bit (bottom)
		db 17,18,239,147,0,0,0,0	;launch tube
		db 21,19,227,0,0,0,0,0		;Zzyax logo
		db 2,10,235,33,0,0,0,0	;scnner bracket [
		db 2,10,237,33,0,0,0,0	;scnner bracket ]
		db 11,12,218,160,0,0,0,0	;camel's shield indic
		db 11,11,239,34,0,0,0,0	;diamond 1
		db 5,11,250,34,0,0,0,0	;dia 2
		db 1,11,255,34,0,0,0,0	;dia 3
		db 5,11,250,34,0,0,0,0	;dia 4
		db 17,5,229,165,0,0,0,0	;500 bonus
;		db 6,5,64,14,0,0,0,0	;Enemy shot
		db 11,11,220,173,0,0,0,0
;		db 13,13,157,15,0,0,0,0
		db 19,13,78,15,0,0,0,0	;5000 bonus
		db 5,5,97,15,0,0,0,0	;Explosion fragments
		db 5,5,102,15,0,0,0,0
		db 5,5,107,15,0,0,0,0
		db 5,5,112,15,0,0,0,0
		db 5,5,117,15,0,0,0,0
		db 5,5,122,15,0,0,0,0
		db 5,5,127,15,0,0,0,0
		db 5,5,97,20,0,0,0,0
		db 5,5,102,20,0,0,0,0
		db 5,5,107,20,0,0,0,0
		db 5,5,112,20,0,0,0,0
		db 5,5,117,20,0,0,0,0
		db 5,5,122,20,0,0,0,0
		db 5,5,127,20,0,0,0,0
		db 5,5,97,25,0,0,0,0
		db 5,5,102,25,0,0,0,0
		db 11,5,121,0,0,0,0,0	;Hump turret opening
		db 11,5,132,0,0,0,0,0
		db 11,5,143,0,0,0,0,0
		db 11,5,121,5,0,0,0,0
		db 11,5,132,5,0,0,0,0
		db 11,5,143,5,0,0,0,0
		db 10,6,132,10,0,0,0,0	;Ass-mounted cannon
		db 19,5,132,16,0,0,0,0	;Front cannon		
		db 18,5,87,43,0,0,0,0	;Ass bullet
		db 17,5,132,24,0,0,0,0	;Front cannon bullet
		db 16,19,44,29,0,0,0,0	;Fucking great orb bullet <
		db 16,19,60,29,0,0,0,0	;Fucking great orb bullet >
		db 11,19,76,29,0,0,0,0	;Smartie bullet

		db 22,13,87,30,0,0,0,0	;Wee saucer
		db 17,17,110,32,0,0,0,0	;Power up token
		db 9,17,127,32,0,0,0,0
		db 2,17,136,32,0,0,0,0
		db 23,14,138,32,0,0,0,0	;smily-face
		db 25,9,161,32,0,0,0,0	;oval bullet
		db 13,11,157,15,0,0,0,0	;sinus orb
		db 13,11,161,41,0,0,0,0	;Neutronium pellet
		db 17,15,186,32,0,0,0,0	;Neutronium Bomb
		db 13,9,215,33,0,0,0,0	;Rezup centre bloc
		db 5,5,170,19,0,0,0,0	;Rez x
		db 5,5,170,24,0,0,0,0	;Rez +
		db 11,14,0,0,1,0,0,0	;Figure '0'
		db 11,14,11,0,1,0,0,0	;1
		db 11,15,22,0,1,0,0,0	;2
		db 11,16,33,0,1,0,0,0	;3
		db 11,14,44,0,1,0,0,0	;4
		db 11,15,55,0,1,0,0,0	;5
		db 11,14,66,0,1,0,0,0	;6
		db 11,16,77,0,1,0,0,0	;7
		db 11,16,88,0,1,0,0,0	;8
		db 11,16,99,0,1,0,0,0	;9
		db 116,12,0,16,1,0,0,0	;Weapons bar
		db 38,26,116,0,1,0,0,0	;'Score' plaque
		db 13,8,154,0,1,0,0,0	;miniship1
		db 17,8,154,8,1,0,0,0	;2
		db 19,8,154,16,1,0,0,0	;3
wbv		db 116,3,0,28,1,0,0,0	;Scale
		db 13,8,173,16,1,0,0,0	;miniship 4
		db 17,8,171,8,1,0,0,0	;5
		db 19,8,167,0,1,0,0,0	;6
		db 9,8,186,0,1,0,0,0	;7
		db 7,16,188,8,1,0,0,0	;vrocket
		
dumbuf		dw 0,0,0,0,0,0,0,0

fonts		dw 4
		db 6
cfb		db 4
cfv		dw 6
xf		dw 0
cff		dw 1
cfba		dw 10
irqvex		dw _game,_launch,_null,_null,_paws
irqmode		dw 2
txtx		dw 0
txty 		dw 0
txmax		dw 250
tymax		dw 190
retst		dw 0

xlo		dw 0
xhi 		dw 255
ylo		dw 0
yhi 		dw 120

fon		dw 0
fto		dw 0
ffrom		dw 0
fdel		dw 0
fstart		dw 0
fend		dw 0
fcur		dw 0
fstep		dw 0

w_mode		db 0
w_hite		db 90

t_addr		dw 0
t_src		dw 0
t_dstc		dw 0
t_cstp		db 0
t_tstp		db 0
t_shft		db 0
t_mode		db 0
t_rgen		dw 0
s_disabl	db 0
a_disabl	db 0

xcol		dw 0
dlist		dw offset rl2
glist		dw offset rl3
rcmd		dw 0
rip		dw 0
rnum		dw 0
rsteps		db 0
rshfts		db 0
rcstep		db 0
rasand		dw 0
rasxp		dw 0
rhit1		dw 0f00h,0,0f00h,0,0f00h,0,0f0fh,0f0fh,0f0fh,0,-1

eshit		dw 0fffh,0eeeh,0,-1
gshit		dw 0fffh,0000h,0fffh,0fffh,0000h,0fffh,0,0fffh,0
		dw 0,0,0,0fffh,0,0,0,0,0,0,0,0fffh,0,0,0fffh,0,-1

termf		dw 0fh,0,0f00h,0,0f0h,0,0f0fh,0,0ffh,0,0ff0h,0,0fffh,0,-1

rasbld
		dw 0ch,0cch
		db 8,3
		dw 0cch,0f0fh
		db 8,3
		dw 0f0fh,0ff0h
		db 9,3
		dw 0840h,0fc0h
		db 8,3
		dw -1

		dw 3,0ffh
		db 16,4
		dw 0ffh,0fffh
		db 8,3
		dw 0F0h,070h
		db 8,3
		dw -1

rasbl2
		dw 3,7
		db 8,3
		dw 7,0f00h
		db 8,3
		dw 0f00h,0840h
		db 9,3
		dw 0730h,0da0h
		db 8,3
		dw -1

		dw 3,508h
		db 16,4
		dw 508h,07fh
		db 8,3
		dw 0b0h,030h
		db 8,3
		dw -1


wra		dw 0
ppitch		dw 0
soux		dw 0
souy		dw 0
desx		dw 0
desy		dw 0
sizx		dw 0
sizy		dw 0

scx		dw 0
scx1		dw 0
scx2		dw 0
scx3		dw 0
scx4		dw 1
lbolt		dw 0,0,0,0,0,0,0
lboltd		db 0

menu_msg	db 'MENU : SELECT BLAH,BLAH,BLAH',0
tmsg
		db '\g',10,90,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 '
		db 'THE QUICK BROWN SHEEP JUMPED OVER '
		db 'THE LAZY GOAT\rGOAT\e'
twspr 		db 'MY EYEBALLS EXPLODE WITH DELIGHT!',0
tclau		db '--CAMEL LAUNCHED--',0
nfh		db 'ZARJAZ FLYING, ACE!!',0
txtadr		dw titxt
txtdur		dw 512

ascreen		dw 0100h
ascb		db 0

bscreen		dw 0100h
bscb		db 1

;these are the screen addresses, and segments, of both vscreens
;very tiny (256x120) at the moment coz of small chip RAM

sync		db 0

;flag for IRQ to tell foreg that screens have been swapped

ccol		dw 0

bptr		dw 0
		
;AMC-specific parameters

nfade		dw offset rasbl2
ofade 		dw offset rasbld
ngraf		dw 124
ograf		dw 125
gfade 		db 1
xd		db 1
ppos		dw 8000h
pspd 		dw 0

rleg		dw 0
fleg		dw 0
wdel		dw 4
wspd		dw 4
taph		dw 0
tflik		db 1
tdel		db 10
kcpos		dw 0
kfr		dw 0
kff		dw 0
ktp		dw 0

t_x		dw 0
t_y		dw 0
t_a		dw 0

orbit		dw 0
lazo		dw 0
shipx		dw 208
shipy		dw 64
shipp		db 4
shxt		db 1,126,127,128,2
tdell		db 4
tdir		db 0
fpha		db 0
fde		db 0
thron		db 0
camx		dw 0
camy		dw -1
camspd 		dw 16
shlev		dw 2
blowing		db 0

shoffs		db 0,0,0,0,6,2,0,10
lfo		db -43,-54,-67,-54,-2,-2,-3,-2,129,130,131,130
rfo		db 23,23,23,23,-2,-2,-3,-2,132,133,134,133
lego_r		dw -4,-4,-6,-8,-11,-13,-11,-8,-5,-4,-5,-5,-4,1,2,-1
		dw 0,0,0,0,0,0,0,0,-1,-1,-2,-1,0,0,0,0
lego		dw -4,-3,-4,-5,-4,-5,-8,-4,-12,-8,-1,-3,-3,-4,-3,-4
		dw 0,0,0,0,0,0,0,-1,1,0,-1,-1,-1,0,0,0
neko		dw 14,15,16,19,16,15,14,14,0,1,2,3,2,1,0,0
hedo		dw 56,58,58,61,58,58,56,56,-2,-1,0,3,0,-1,-2,-2
taleo		dw -3,-10,-15,-19,-16,-9,-5,-9,-16,-19,-15,-10,-3,-3
		dw 20,20,20,20,9,4,4,4,9,20,20,20,20,20		
		dw 0,1,2,3,4,5,6,5,4,3,2,1,0,0



camscol		dw 0f00h,0f01h,0f02h,0f03h,0f04h,0f05h,0f06h,0f07h
		dw 0f08h,0f09h,0f0ah,0f0bh,0f0ch,0f0dh,0f0eh,0f0fh
		dw 0f0fh,0e1fh,0d2fh,0c3fh,0b4fh,0a5fh,096fh,087fh
		dw 079dh,06abh,05b9h,04c7h,03d5h,02e3h,01f1h,00f0h
shsho		db 0
bstr		dw 1024
cama 		dw 0
xfin		dw 0
plane2		db 0,0,1,0,4,0,0,0,5,0,0,4,0,0,6,2
		db 0,0,1,0,4,0,0,0,5,0,0,4,0,0,6,2
		db 0,0,15,5,5,5,0,0,14,15,0,5,0,0,8,16
		db 0,0,15,5,5,5,0,0,14,15,0,5,0,0,8,16

plane3		db 0,1,2,0,1,0,0,0,1,0,1,1,0,2,1,0
		db 1,1,0,3,0,2,2,0,1,0,3,3,3,3,0,2
		db 0,1,1,1,0,2,2,0,1,1,1,0,1,2,3,2

		db 1,0,0,1,0,2,0,3,0,2,0,1,0,3,0,0
p3xt		db 0,28,29,27

bsize		db 0,0,18,5,18,5,5,5,81,1,7,4,18,5,6,40

bvos
;		dw 0,8,-8,16,-16
		dw 0,3,-3,6,-6
baos		dw 6,0,5,2,5,-2
bulls		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0

shxes		db 96 dup (?)
shxfree		db 16
shfra		db 160 dup (?)
frap		db 0
fraa		db 0
frad		dw 0


bulrun		dw nexb,stdbul,explo,spread,balls,LAZE,stdbul
		dw wibul,stdbul,synrun,zzapr
buldraw		dw prose,sbdraw,exdraw,sprdraw,baldraw,LAZDRAW,robdraw
		dw widraw,budraw,syndrw,zzapd
bullau		dw norml,sprlau,balau,lalau,roblau,falau,wilau,bulla
		dw synl,zzapl
bdamt		dw 0,3,0,8,8,6,12,6,10,6,12
lwxt		db 0,3,5,6,2,1,7,4,9
lwf		db 1
lwp		db 7
btype		db 0
lwep		db 0
pdrain		db 127
pdraint		db 127,30,40,96,10,64,50,25,30,5
raint		db 127,30,40,96,10,64,50,25,30,5
gorb 		db 0
afree 		db 3
pfree		db 4
camdat		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
camfr		db 8
camlau		dw 512
camres		dw 1024
bcount		db 0
bcow		dw 0

score		db 0,0,0,0,0,0,0,0
lives		dw 10
bmv		dw 5

testadd		dw offset sprite

pulist		db 104
		dw pinpuls
		db 56
		dw blup1
		db 57
		dw blup2
		db 59
		dw br
		db 60
		dw ry
		db 61
		dw yb
		db 62
		dw bulp
		db -1

bulp		dw 0f00h,0ff0h,-1,bulp

;bulp		dw 0000h,0ff0h,0100h,0ee0h,0200h,0dd0h,0300h,0cc0h
		dw 0400h,0bb0h,0500h,0aa0h,0600h,0990h,0700h,0880h
		dw 0800h,0770h,0900h,0660h,0a00h,0550h,0b00h,0440h
		dw 0c00h,0330h,0d00h,0220h,0e00h,0110h,0f00h,-1,bulp

hv		dw -32,0,32,-10,-20,-10

br		dw 0fh,10eh,20dh,30ch,40bh,50ah,609h,708h,807h
		dw 906h,0a05h,0b04h,0c03h,0d02h,0e01h
ry		dw 0f00h,0f10h,0f20h,0f30h,0f40h,0f50h,0f60h,0f70h
		dw 0f80h,0f90h,0fa0h,0fb0h,0fc0h,0fd0h,0fe0h
yb		dw 0ff0h,0ee1h,0dd2h,0cc3h,0bb4h,0aa5h,996h,887h
		dw 778h,669h,55ah,44bh,33ch,22dh,11eh,-1
		dw br

pinpuls		dw 0f0fh,0f1eh,0f2dh,0f3ch,0f4bh,0f5ah,0f69h,0f78h
		dw 0f87h,0f96h,0fa5h,0fb4h,0fc3h,0fd2h,0fe1h,0ff0h
		dw 0ef1h,0df2h,0cf3h,0bf4h,0af5h,09f6h,08f7h,07f8h
		dw 06f9h,05fah,04fbh,03fch,02fdh,01feh,00ffh,01efh
		dw 02dfh,03cfh,04bfh,05afh,069fh,078fh,087fh,096fh
		dw 0a5fh,0b4fh,0c3fh,0d2fh,0e1fh,-1
		dw pinpuls

brass
		db 64,64,64,65,64,65,64,65,65,65,66,65,66,65,66,66
		db 67,66,67,66,67,67,67,67,68,67,68,68,68,69,68,69
		db 69,70,69,70,70,71,70,71,71
		db 79,79,78,79,78,78,78,78,78,77,78,78,77,78,77,77
		db 78,77,77,77,77,76,77,77,76,77,76,77,76,76,76,77
		db 76,76,76,76,76,75,76,76,75,76,76,75,76,75,75,75
		db 75,75,75,76,75,75,75,74,75,74,74,73,74,73,73,72
		db 73,72,72


;		db 64,64,65,65,66,66,67,67,68,68,69,69,70,70
;		db 71,71,79,79,78,78,77,77,76,76,75,75,74,74,73,73,73,72
;		db 96,96,97,97,98,98,99,99,100,100,101,101
;		db 102,102,103,103,60,60,103,103,102,102,101,101,100,100
;		db 99,99,98,98,97,97,96,96,72,72,73,73,74,74,75,75
;		db 76,76,77,77,78,78,79,79,71,71,70,70,69,69,68,68,67,67
;		db 66,66,65,65,64,64,64,65,66,67,68,69,70

blup1		dw 0ffh,0efh,0dfh,0cfh,0bfh,0afh,09fh,08fh,08fh,08fh
		dw 08fh,08fh,08fh,08fh,0ff0h,-1,blup1
blup2		dw 0cch,0bch,0ach,09ch,08ch,07ch,06ch,05ch,05ch,05ch
		dw 05ch,05ch,05ch,05ch,0ec0h,-1,blup2

titxt		db 'ATTACK OF THE MUTANT CAMELS: KONIX VERSION 0.4',0

didat		db 192 dup (?)
icopy		dw 0,10,20,30,0,10,20,30,0,10,20,30,0,10,20,30
		dw 0,0,0,0,40,40,40,40,80,80,80,80,120,120,120,120
		dw -5,-4,4,5,-4,-3,3,4,-3,-2,2,3,-2,-1,1,2
		dw -5,-5,-5,-5,-6,-6,-6,-6,-7,-7,-7,-7,-8,-8,-8,-8
		dw 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
		dw 440,440,440,440,440,440,440,440,440,440,440,440
		dw 440,440,440,440

wep1		db 'CANNON SELECTED',0
wep2		db 'V-BEAM SELECTED',0
wep3		db '3-WAY SHOT SELECTED',0
wep4		db 'BEAM LAZER SELECTED',0
wep5		db 'HUGE BULLETS SELECTED',0
wep6		db 'REAR CANNON SELECTED',0
wep7		db 'WIDEBEAM ASSKICKERS SELECTED',0
wep8		db 'BURST BEAM SELECTED',0
wep9		db 'SINUS SELECTED',0
wep10		db 'SMART LAZERS SELECTED',0
pwrup		db '!!POWER-UP!!',0
tyou		db 'NEUTRONIUM PELLET RECEIVED - THANK YOU',0
twhat		db 'GO PUT THAT SOMEWHERE USEFUL!',0
theeya		db 'YOU GOT THE BOMB! GO KICK SOME ASS!',0
tgotem		db '!! GOT THE SCUMMERS !!',0
gotem		db 0
syna		db 0
eqdur		db 0

weptxtab	dw wep1,wep2,wep3,wep4,wep5,wep6,wep7,wep8,wep9,wep10
pshipx		dw 0
pshipy		dw 0
neuc		dw 0
nunum		dw 5
the_business	dw 0
hasl_pc		dw lstring
h_sp		dw h_stac
h_stac		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,0,0
h_start		dw 0
wtime		dw 0
wnum		db 0

 



tlaus
		db 0,0,0,0,0,0,20,0,-10,-1,0,0,0,0,1,0
		db 7,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,95,0,0,0,95
		db 0,196,5,0,2,5,1,0,0,0,0,0,3,3,3,2
		db 0,0,2,0,0,0,0,0,0,0,0,12,0,0,0,4
		db 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,6,2
		dw tlautab
		
rlaus		db 0,0,0,0,0,0,0,0,0,0,0,1,4,0,1,0
		db 4,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0
		db 0,0,0,228,0,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,10,0,0,0,0,0,0,-32,0,0,0,0,0,0
		db 0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,5,5
		dw rotab



tlautab		dw gopu,goxp,0,hseek,0,0,golf,gort,0,reffl,reffl,0,0,0
		dw 0,fyah

rotab		dw goxp,goxp,0,0,0,0,0,0,0,kilit,0,0,0,0,0,0

boncon		dw 0,pup,0,0,0
		dw 0,0,0,0,0,bowns,kilit,0,0,0,0

waval		dw tlaus,rlaus

lstring		db '[w',30,'f',1,'l',2,0,'(',6,'w',15,'f',1,'l',6,1
		db ')]'

znul		db '.'
pup		db 'U'
kilit		db 'K'
bowns		db 'b',8,'S',-127,-1,'.'
reffl		db 'b',8,'F.'
golf		db 'b',36,'S',3,0,'Zb',72,'s',-30,'.'
		db 'b',6,'S',-30,-1,'.'
gort		db 'b',36,'S',3,0,'Zb',72,'s',30,'.'
		db 'b',6,'S',30,0,'.'
gopu		db 'xU.'
goxp		db 'x.'
fyah		db 'Q',22,'Q',34,'.'
hseek		db 'R',90,'b',36,'S',3,0,'.'




eboff		db 0
calend		dw 0
h_on		db 50
h_d		db 5
h_di		db 1

xts		db 0
dxps		db 32 dup (?)
xtd		db 6
xtm 		db 0
xtx		dw 0

bfree		db 12
ffreq		db 10
bmode		db 0
wdb		db 0
xct		db 0
yct		db 0
hmp		db 0
ass		db 1
can		db 1

bullen 		dw 0
scro		dw 0

drawvex		dw dshot,dex,drass,drcan,adraw,smdr,drezin
movevex		dw n_al,mshot,mex,mshot,acont,smmo,mrezin

shipbuf		db 64 dup (?)
shbpt		dw 0
adat		db 2048 dup (?)
alend		dw 0

zap_dat		dw -1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 52 dup (?)
		dw -1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 52 dup (?)
		dw -1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 52 dup (?)
		dw -1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db 52 dup (?)

_zap		dw 0,0,_zapp,6,-1
_zapp		db 'a,0004(a^p,0400(p]*p[$0000.)p-0040=0100)a-0001=0000:'
_pow		dw 1,0,_powp,7,-1
_powp		db 'a,0005x,0080(a^[$p,xc,0008'
		db '(p*0000.)p-0014c-0001=0000)x-0002a-0001=FFFF:'
_shot		dw 2,0,_shotp,8,-1
_shotp		db 'a,0004x,0180(a^$p,xc,0004'
		db '(p*$0000.)p+0080c-0001=0000)x-0050a-0001=0003:'
		

_hit		dw 3,0,_hitp,9,-1
_hus2		db '0000*000C.'
_hitp		db 'a,0006x,0080(a^[[[[$p,xc,000C'
		db '(p*0000.)p-0010c-0001=0000)x-0002a-0001=FFFF:'
		
_hus		dw 1,1,_husp,7,-1
_husp		db 'a,0006x,0080(a^p,xc,0008'
		db '(p*$0000.)p-0014c-0001=0000)x+0002a-0001=FFFF:'
_stp		dw 1,0,_stpp,7,-1
_stpp		db 'a,0004$x,0080(a^p,xc,0008'
		db '(p*0000.)p-000ac-0001=0000)x-0002a-0001=0005:'

_DIVE		dw 1,1,_divep,7,3,1,_dp2,9,-1
_divep		db 'a,0004^t,0000p,0200(p*t$0000.)t+0008p+0003>0600:'
_dp2		db 'a,0004^t,0000p,0100(p*t$0000.)t+0004p+0002>0600:'


_kpow		dw 1,1,_husp,7,3,1,_hus2,9,-1


_klek		dw 1,0,_klekp,7,-1
_klekp		db 'a,0004t,0000(x,0200a^t$c,0004(x*0001.x[*0001.)'
		db 'x+0011c-0001=0000)t+0008a-0001=FFFF:'


_ptting		dw 3,0,_pttinp,9,-1
_pttinp		db '0200*0004^0000$0003.0400*v,0006(v^a,0000'
		db '(a$0000.)a+0160>0800)v-0001=FFFF:'

_camkil		dw 0,1,_ckilp,6,2,1,_ckil2,8,-1
_ckilp		db '0000$v,0004^p,0200a,FFD3(p*[[0001.)p-a'
		db 'a+0002>0018v,0006(v^a,0000p,04A0(p*[[$0001.)'
		db 'p-aa+0003>0046)v-0002<0000:'
_ckil2		db '0000$v,0004^p,0205a,FFD3(p*0001.)p-a'
		db 'a+0002>0018v,0006(v^a,0000p,04A0(p*0001.)'
		db 'p-aa+0003>0046)v-0002<0000:'
_laza		dw 0,0,_zap1,6,-1
_zap1		db 'a,0004(a^p,0400(p]*p[[[$0000.)p-0020=0100)a-0001=0000:'
_tway		dw 0,0,_zap2,6,-1
_zap2		db '0000$a,0004(a^p,0800(p]*0000.)p-0080<0080)a[[$'
		DB 'a-0001=0000:'
_veeb		dw 0,0,_zap3,6,-1
_zap3		db '0000$a,0004(a^p,0080(p]*p[[[[$0000.)p+0080>0880)a[[$'
		DB 'a-0001=0000:'
_wyd		dw 0,0,_zap4,6,-1
_zap4		db 'a,0004x,0300(a^p,x'
		db '(p*$0000.)p-0280<F000)x+0100a-0001=FFFF:'

_brst		dw 0,0,_zap5,6,-1
_zap5		db 'a,0004t,0000(x,0200a^t[[[$c,0004(x*0001.x[*0001.)'
		db 'x+0041c-0001=0000)t+0008a-0001=FFFF:'		
_fhb		dw 0,0,_zap6,6,-1
_zap6		db 'a,0005x,0080(a^p,xc,0008'
		db '(p*[[[[$0001.)p-0014c-0001=0000)x+0002a-0001=FFFF:'
_sml		dw 0,0,_zap7,6,-1
_zap7		db 'v,0004(t,0800v^0120*(t[[$0000.)t-0080<0000)v-0001<0000:'

_laun		dw 0,1,_laun1,6,1,1,_laun2,7,2,1,_laun3,8,-1
_laun3		db '0001.'
_laun2		db '0001.'
_laun1		db 'a,0004^p,00C0t,0000(p*t$0001.)t+0008p-0002'
		db '<0040c,0006(t,0000(t$0000.)t+0010>0180)c-0001=0000:'


nvoxx		dw 4
PITCH		DW 0
twists		dw 4,4,4*8,8,2*8,16,8,2*8,25*8,25*8,512*8,2*4
		dw 4,4,4*8,8,2*8,16,8,2*8,25*8,25*8,512*8,2*4
;		dw 0,0,22,4,34,8,46,16,68,32,4,64
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw ttun,ttuna,ttun,ttuna,ttun,ttuna,ttun,ttuna
		dw ttun,ttuna,ttun,ttun
		dw env1,env1,env1,env1,env1,env1,env1,env1
		dw env1,env1,env1,env1
		dw 6,2,6,2,6,2,2,2,2,2,2,2
		dw 6,4,6,4,6,4,2,2,2,2,2,2
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,512,512,0,512,0,0,0,0,0,0

c_blok		dw twists
cc_blok		dw twists
a_blok		dw 0
camon		dw 2,4,8,16,4,8,8,2*8,25*8,25*8,512*8,2*4
		dw 2,4,8,16,4,8,16,25*8,25*8,512*8,2*4,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw ttt,tt1,ttt,tt1,ttt,tt1,ttun,ttuna
		dw ttun,ttuna,ttun,ttun
		dw env2,env2,env2,env2,env2,env2,env1,env1
		dw env1,env1,env1,env1
		dw 6,2,6,2,6,2,2,2,2,2,2,2
		dw 6,4,6,4,6,4,2,2,2,2,2,2
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,512,512,0,512,0,0,0,0,0,0

gotu		dw 2,4,6,8,10,12,8,2*8,25*8,25*8,512*8,2*4
		dw 2,4,6,8,10,12,8,2*8,25*8,25*8,512*8,2*4
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw dtt,dtt,dtt,dtt,dtt,dtt,ttun,ttuna
		dw ttun,ttuna,ttun,ttun
		dw env1,env3,env2,env1,env3,env2,env1,env1
		dw env1,env1,env1,env1
		dw 6,2,6,2,6,2,2,2,2,2,2,2
		dw 6,4,6,4,6,4,2,2,2,2,2,2
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,512,512,0,512,0,0,0,0,0,0

ttt		dw 10,0102h,10,0207h,2,010ah,2,0102h,7,0207h,7,-2
tt1		dw 010ah,2,7,10,0102h,2,7,10,0107h,2,7,10,-1

strans		dw 24,12,24,12,0,12,0,12,12,0,12,12,0,0,1,0,0

boni		dw 4,4,4*8,8,2*8,16,8,2*8,25*8,25*8,512*8,2*4
		dw 4,4,4*8,8,2*8,16,8,2*8,25*8,25*8,512*8,2*4
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw btt,btt1,btt,btt1,btt,btt1,ttun,ttuna
		dw ttun,ttuna,ttun,ttun
		dw env1,env1,env1,env1,env1,env1,env1,env1
		dw env1,env1,env1,env1
		dw 6,2,6,2,6,2,2,2,2,2,2,2
		dw 6,4,6,4,6,4,2,2,2,2,2,2
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,512,512,0,512,0,0,0,0,0,0

suboni		dw 2,4,6,8,10,12,8,2*8,25*8,25*8,512*8,2*4
		dw 2,4,6,8,10,12,8,2*8,25*8,25*8,512*8,2*4
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw ctt,ctt,ctt,ctt,ctt,ctt,ttun,ttuna
		dw ttun,ttuna,ttun,ttun
		dw env1,env3,env2,env1,env3,env2,env1,env1
		dw env1,env1,env1,env1
		dw 6,2,6,2,6,2,2,2,2,2,2,2
		dw 6,4,6,4,6,4,2,2,2,2,2,2
		dw 0,0,0,0,0,0,0,0,0,0,0,0
		dw 0,0,512,512,0,512,0,0,0,0,0,0

ctt		dw 0,4,7,0100h,0104h,0107h,0200h,0204h,0207h,-1		
dtt		dw 0207h,0203h,0200h,0107h,0103h,0100h,7,3,0,-1

env3		dw 1,0100h,1,0c0h,1,080h,1,040h,1,020h,1,0,0

env1
		dw 0e00h,1h
		dw 1000h,0140h,0f00h,0010h,0e00h,2,0d00h,4
		dw 0c00h,8,0b00h,16,0a00h,10h,0900h,20h,0800h,30h
		dw 0700h,40h,0600h,080h,500h,060h,0700h,060h
		dw 0900h,40h,0700h,30h,0500h,010h,0300h,01h
		dw 0500h,08h,0700h,10h,0900h,1800h,0c00h,1000h,0


env2		dw 0400h,60h,0600h,50h,0800h,40h,0c00h,30h,1000h,20h
		dw 1,0,1,0,1,0,1,0,1,100h,-1
twist		dw 8000h
a_blot		dw 0
xtrans		dw 0
btt		dw 0,0100h,0,0107h,0100h,0200h,0100h,0104h
		dw 0107h,0200h,0100h,0104h,0107h,0,4,7
btt1		dw 0200h,0204h,0207h,0200h,0204h,0207h,0100h,-1

ttun		dw 0,0,0,0100h,0100h,0100h,0,0,0100h
		dw 100h,200h,200h,100h,100h
ttuna		dw 0,3,7,0103h,0107h,0200h,0200h,0108h,0107h
		dw 0103h,-1
tedge		dw 0

		dw 0,0100h,-2,-2,0200h,0300h
		dw 0,4,-2,0,7,0,0100h,0104h,0100h,0107h,0100h
		dw 0007h,0300h,0204h,0404h,0104h,-2,-2,0,-2,0100h
ttun1
		dw 0,4,-2,0,7,0,0100h,0104h,0100h,0107h,0100h
		dw 0007h,0300h,0204h,0404h,0104h,-2,-2,0,-2,0100h
ttun2
		dw 0207h,0207h,0200h,-2,0100h,0104h,0100h,-2,0000
ttun3		dw 7,-2,7,4,7,-2,7,0,7,-2,7,4,7,-2,7,0
		dw -2,-2,0,4,7,0,4,7,12,7,12,7,12,24,0,24,12
		dw 0,4,7,0100h,0104h,0107h,0200h,0204h,0207h
		dw 0,4,7,0100h,0104h,0107h,0200h,0204h,0207h
		dw 0,4,7,0100h,0104h,0107h,0200h,0204h,0207h
		dw 4,7,4,7,4,7,4,7,-1

note_tab
		dw 268,284,301,318,337,358,379,401,425,451
		dw 477,506

llyst		dw inbas,atship,nship,atshx,atshy,rahnd,shxbot
lc_vex		dw lc_a,lc_b,nul,lc_d,nul,lc_f,nul,nul,lc_i,nul
		dw nul,lc_l,lc_m,lc_n,nul,lc_p,nul,lc_r,lc_s
		dw nul,nul,nul,nul,lc_x,lc_y,lc_z
uc_vex		dw uc_a,nul,nul,uc_d,nul,uc_f,nul,nul,uc_i,nul
		dw uc_k,nul,uc_m,uc_n,nul,uc_p,uc_q,uc_r,uc_s
		dw nul,uc_u,nul,nul,nul,nul,uc_z

tran_tab	dw 0,12,0,5,17,5
		dw 7,0,24,0,12,0,12
		dw 7,19,0,24,7,19
		dw 15,3,15,15,12,0,24,36,6,14,12,0,24,0
		dw 12,0,12,0,2,14,16,4,6,18,6,18,7,6,7,2,7,0,-1
tran_trig	dw 128
tran_spd	dw 128
tran_ptr	dw 0
xpose		dw 0

oct		dw 0

lx1		dw 0
ly1		dw 0
lx2		dw 0
ly2		dw 0
ix1		dw 0
iy1		dw 0
ix2		dw 0
iy2		dw 0
out1		dw 0
out2		dw 0
icode1		dw 0
icode2		dw 0
midx		dw 0
midy		dw 0
lc		dw 0
altc		db 4
xorf		db 0
running_time	dw 0

sine_prog	include dspsine.asm

sine		incbin sine.img

game_pal	incbin palette.bin

sprites		incbin sprites.bin
spage2		
pbase equ 166


data 	ends

data2	segment at 0a000h

sprites2	incbin blok2.bin

data2	ends


;----------------------------------------------------------------
;MACRO for running a blitter pogram. AX is offset of program from
;9000h

bum_run		MACRO command
;		out BLPROG0,al
;		mov al,ah
;		out BLPROG1,al
;		xchg al,ah
		out BLPROG0,ax
;		mov al,09h			;segment / 1000h
;		out BLPROG2,al
;		mov al,command
;		out BLCMD,al
		mov al,09h
		mov ah,command
		out BLPROG2,ax
		ENDM







;------------------------------------------------------------------
;The guts of this demo. Set up the palette with some wierdy colours
;and then draw some lines and move the ball.


code_seg	segment	at 8000h

		assume cs:code_seg
		assume ds:data


do_demo		mov sp,0
		mov ax,9000h
		mov ds,ax
		mov ax,0000h
		mov ss,ax			;set up stack and data ptr


		mov si,offset sine_prog	; load and run DSP program
		call load_dsp
		call init_dsp

;		mov si,12
;		mov ax,0000h
;		call write_dsp
;		inc si
;		mov ax,1
;		call write_dsp
;		mov ax,1000h
;		mov si,15
;		call write_dsp
;		inc si
;		mov ax,1000h
;		call write_dsp
;useful		jmp useful	


;-------------------------------------------
;Initialise routine. Highly inefficient code

		mov ax,0fffh
		out BORDL,ax			;BLACK border
		mov ax,60
		out STARTL,ax			;screen start, central
		mov ax,259			;200 active lines ?
		out ENDL,ax

		mov al,01h
		out MEM,al			;DRAM at 80000h
		mov al,01h
		out MODE,al			;MEDIUM screen resolution
		mov al,0
		out PMASK,al
		out INDEX,al			;clear palette index

		mov ax,100h			;screen start, above int
		out SCROLL1,ax			;pointers
		out SCROLL3,al
		mov ax,offset bulls
		add ax,28*12
		mov bullen,ax
		mov alend,offset alend
		mov ax,offset adat
		add ax,128*8
		mov calend,ax

;-------------------

		push ds
		mov cx,64			;do the first 64 interrupts
		mov bx,0			;only 20h,21h,22h and 23h
		mov ds,bx			;need be intitialised but
		mov ax,offset cs:int_s0		;what the hell
set_i:		mov word ptr ds:[bx],ax
		add bx,2
		mov word ptr ds:[bx],cs
		add bx,2
		loop set_i
		mov bx,21h*4			;video IRQ
		mov ax,offset cs:frast		;rasta list icode
		mov word ptr ds:[bx],ax
		add bx,2
		mov word ptr ds:[bx],cs		;vector for rasta
		pop ds
		mov bx,4000h
		mov es,bx
		pushf
		pop ax
		and ax,0bffh
		push ax
		popf				;set flag string-dir
		mov si,clist
		xor di,di

;-------------------

		mov ax,255
		out INTL,ax			;interrupt at line 255
		mov al,0Fh			;disable all INTS
		out ACK,al
		mov al,0Eh
		out DIS,al			;enable the video interrupt
		sti

		mov al,0h			;do NOT mask blitter interrupts
		out BLCON,al

		mov al,1			;for random number generator
		out DIAG,al			;electron beam pos in LIGHTPEN regs



; test block command

		call set_pal		;initialise game's palette
		call dcls
;		mov bx,offset tmsg
;		call print		;try character print
;		mov lx1,50
;		mov ly1,50
;		mov lx2,-500
;		mov ly2,80
;		mov lc,104
;gov		push lx1
;		push ly1
;		push lx2
;		push ly2
;		call ccline
;		pop ly2
;		pop lx2
;		pop ly1
;		pop lx1
;		add lx2,50
;		add lx2,20
;		cmp lx2,500
;		jle gov
;shigg		jmp shigg
;		mov fto,15
;		mov ffrom,0
;		mov fdel,5001h
;		mov fstart,1
;		mov fend,255
;		mov fcur,1
;		mov fstep,1
;		mov fon,1		;test fadein

;		mov t_rgen,offset rasbld
;		mov rsteps,16
;		mov rshfts,4
;		mov rcmd,2		;build and fade to list


		mov irqmode,2		;null raster
		mov ppos,0d700h		;start PPOS
		mov shipy,160
		mov w_mode,1		;turn on raster window
		mov w_hite,2		;mere sliver
		mov ax,offset rasbl2
		mov t_rgen,ax
		mov rcmd,1
wrg		test rcmd,-1
		jne wrg
		mov thron,1
		mov pspd,0
		mov irqmode,1
		mov ax,offset cs:main_loop
		mov the_business,ax


camels		call dbuff
		mov ax,running_time
		cmp ax,JOY_TIMEOUT
		jae no_inc
		inc ax
		mov running_time,ax
		jmp camels
no_inc		xor ax,ax
		out BORDL,ax
		jmp camels		;run main game loop forever


_paws		call wcon
		jmp iend


main_loop

;
; main doublebufferstuff loop
;
		mov bptr,0		;set buffer ptr to zero
;
; (code to draw on ascreen)
;

		mov ax,orbit
		mov bl,ah
		xor bh,bh
		add bx,offset sine
		mov al,[bx]		;sine
		cbw	
		add ax,50
		mov dx,ax		;X component
		sub bx,offset sine
		add bl,40h
		add bx,offset sine
		mov al,[bx]		;cosine
		cbw
		add ax,pbase
		mov cx,ax
		mov bx,dx
;		mov bx,128
;		mov cx,80
		mov ax,ngraf
		call _sprite

		test lboltd,-1
		je nzappa
		mov ly1,0
		mov bx,offset lbolt
		mov cx,4
		mov lc,104
dblt		mov ax,[bx]
		mov lx1,ax
		mov ax,ly1
		add ax,35
		mov ly2,ax
		mov ax,2[bx]
		mov lx2,ax
		push bx
		push cx
		call ccline
		add ly1,35
		pop cx
		pop bx
		inc bx
		inc bx
		loop dblt
		sub ly1,35
		mov ax,2[bx]
		mov lx2,ax
		call ccline
		mov rasxp,offset rhit1
;		jmp nocloud

nzappa		mov cx,40
		mov ax,ppos
		shl ax,1
		shl ax,1
		mov al,ah
		and ax,0ffh
		neg ax
		mov bx,ax
		sub ax,256
		mov ax,122
		push bx
		call xsprite
		pop bx
		mov cx,50
		add bx,128
		mov ax,123
		push bx
		call xsprite
		pop bx
		add bx,128
		mov cx,40
		mov ax,122
		push bx
		call xsprite
		pop bx
		mov cx,50
		add bx,128
		mov ax,123
		call xsprite

		mov cx,20
		mov ax,ppos
		shl ax,1
		shl ax,1
		shl ax,1
		mov al,ah
		and ax,0ffh
		neg ax
		mov bx,ax
		sub ax,256
		mov ax,120
		push bx
		call xsprite
		pop bx
		mov cx,30
		add bx,128
		mov ax,121
		push bx
		call xsprite
		pop bx
		add bx,128
		mov cx,20
		mov ax,120
		push bx
		call xsprite
		pop bx
		mov cx,30
		add bx,128
		mov ax,121
		call xsprite

nocloud		mov cx,pbase-39
		mov al,byte ptr ppos+1
		xor ah,ah
		xor al,255
		mov bx,ax
		sub bx,256
		mov ax,107
		push bx
		push cx
		call xsprite
		pop cx
		pop bx
		add bx,256
		mov ax,107
		push bx
		call xsprite
		pop bx
		sub bx,201
		mov cx,pbase-7
		push bx
		push cx
		mov ax,108
		call xsprite
		pop cx
		pop bx
		add bx,256
		mov ax,108
		call xsprite		;back plane of scroll
		mov cx,pbase+3
		mov ax,ppos
		rol ax,1
		
		rol ax,1

		mov al,ah
		xor al,255
		xor ah,ah
		mov dx,ax
		neg dl
		mov bx,dx
		and bx,0f0h
		sub dx,bx		;dx has offset
		neg dx
		shr bx,1
		shr bx,1
		shr bx,1
		shr bx,1		;div bx by 16 - offset inti data
		add bx,offset plane2	;get spridef data
drp2		mov al,[bx]		;get sprite no.
		cmp al,0
		je ndrp
		xor ah,ah
		add ax,110
		add bx,32
		mov cl,[bx]		;v.offset
		sub bx,32
		xor ch,ch
		neg cx
		add cx,pbase+6		;right Y start
		xchg bx,dx
		push bx
		push cx
		push dx
		call xsprite
		pop dx
		pop cx
		pop bx
		xchg dx,bx
ndrp		inc bx
		add dx,16
		cmp dx,256
		jl drp2

		mov dx,ppos
		and dx,0fff0h
		ror dx,1
		ror dx,1		;dh=offset
		ror dx,1
		mov bl,dh
		xor bh,bh
		ror dx,1
		ror dx,1
		and dx,3fh
;		xor dx,3fh		;offset in ax
		neg dx
;
;		mov dx,0
drp3		add bx,offset plane3	;plane3 info..
		mov al,[bx]		;get sprite no.
		cmp al,0
		je ndp3
		xor ah,ah
		push bx
		mov bx,ax
		add ax,116
		add bx,offset p3xt
		mov cl,[bx]
		pop bx
		xor ch,ch
		neg cx
		add cx,pbase+9
		xchg dx,bx
		push bx
		push cx
		push dx
		call xsprite
		pop dx
		pop cx
		pop bx
		xchg bx,dx
ndp3		sub bx,offset plane3
		inc bx
		and bx,31
		add dx,64
		cmp dx,256
		jl drp3
		
xscize	
		call draw_als
		mov camy,-1
		mov cx,0
		mov bx,offset camdat
draca		mov ax,[bx]
		cmp ax,0
		je necca
		push bx
		push cx
		mov bx,ax
		mov cx,50+66
		mov dx,56
		call scan
		sub bx,ppos
		shr bx,1
		shr bx,1
		shr bx,1
		shr bx,1
		test bx,0e00h
		jne nokam
		sub bx,80
		cmp bx,256
		jge nokam 
		pop dx
		push dx
		mov cama,dx
		mov camy,cx
		mov camx,bx
		call draw_camel
nokam		pop cx
		pop bx
necca		inc bx
		inc bx
		add cx,2
		cmp cx,16
		jne draca		;scan and draw all possible beasts

		cmp kcpos,0		;kamel being killed?
		je nock
		mov bx,kcpos
		mov cx,50+66
		sub bx,ppos
		sar bx,1
		sar bx,1
		sar bx,1
		sar bx,1
		cmp xtm,2
		je always
		test bx,0e00h
		jne nock
always		sub bx,80
		mov xtx,bx
		call draw_kcam


nock		call draw_bulls

		cmp neuc,0		;Neutronium carried?
		je gimmy
		mov bx,shbpt
		mov cx,0
nockl		push cx
		dec bx
		dec bx
		and bx,30
		push bx
		add bx,offset shipbuf
		cmp cx,40
		jl arested
		mov ax,neuc
		jmp katad
arested		mov ax,140
katad		add cx,32[bx]
		mov bx,[bx]
		sub bx,4
		call csprite
		pop bx
		pop cx
		add cx,5
		cmp cx,45
		jne nockl
gimmy		mov bx,shipx
		sal bx,1
		sal bx,1
		sal bx,1
		sal bx,1
		add bx,320
		add bx,ppos
		mov cx,shipy
		mov dx,104
		call scan
		mov al,shipp		;small rocket
		xor ah,ah
		mov bx,offset shxt
		add bx,ax
		mov al,[bx]
		xor ah,ah		;get def from xtable
		mov cx,shipy
		mov bx,shipx
		call crsprite		;on current screen

		cmp thron,0		;do flame if thrusting
		je noth
		mov dx,shipx
		mov cx,shipy
		cmp shipp,0
		jne rthr
		mov bl,fpha
		and bl,3
		xor bh,bh
		add bx,offset lfo
zaxon		mov al,[bx]
		cbw
		add dx,ax
		add bx,4
		mov al,[bx]
		cbw
		add cx,ax
		add bx,4
		mov al,[bx]
		xor ah,ah
		jmp pth
rthr		cmp shipp,4
		jne noth
		mov bl,fpha
		and bl,3
		xor bh,bh
		add bx,offset rfo
		jmp zaxon
pth		mov bx,dx
		call rsprite
noth	
		cmp lwep,4
		jne noorb
		mov cx,4
		mov bl,gorb
		xor bh,bh
		add bx,offset sine
drorb		push cx
		mov dx,shipx
		mov cx,shipy
		mov al,[bx]
		cbw
		sar ax,1
		sar ax,1
		add dx,ax
		sub bx,offset sine
		add bx,40h
		and bx,0ffh
		add bx,offset sine
		mov al,[bx]
		cbw
		sar ax,1
		sar ax,1
		add cx,ax
		push bx
		mov bx,dx
		mov ax,141
		call csprite
		pop bx
		pop cx
		loop drorb
noorb	
		mov bx,0a70h
		sub bx,ppos
		shr bx,1
		shr bx,1
		shr bx,1
		shr bx,1
		test bx,0f00h
		je bas1
wesgerm		jmp nobas1
bas1
		sub bx,50h
		mov tedge,bx
		mov pitch,bx
		mov dh,37+66
		add dh,eboff
		mov cl,gorb
		cmp gotem,0
		je cycc
		call random
		mov cl,al
cycc		xor ch,ch
		mov pitch,offset brass
bBas		push cx
		push bx
		mov bx,pitch
		mov cl,[bx]
		add cl,128
		mov lcolr,cl
		inc bx
		mov pitch,bx
		pop bx
		pop cx
		push cx
		push bx
		add cx,offset sine
		xchg cx,bx
		mov al,[bx]
		xchg cx,bx
		cbw
		add ax,128
		sar ax,1
		sar ax,1
		sar ax,1
		sub bx,ax
		cmp bx,0
		jg boomz
		pop bx
		jmp ititl
boomz		mov llen,bl
		xor dl,dl
		push dx
		add dx,ascreen
		mov word ptr lix,dx
		mov al,ascb
		mov lseg,al
		mov ax,offset hline
		bum_run 11h
		pop dx
		pop bx
ititl		pop cx
		add cx,13
		and cx,255
;		inc dh
		inc bx
		inc dh
		cmp dh,120+66
		jne bBas
		
nobas1		mov bx,0ec00h
		sub bx,ppos
		shr bx,1
		shr bx,1
		shr bx,1
		shr bx,1
		test bx,0f00h
		je bas2
		jmp abase
bas2
		add bx,50h
		mov dh,37+66
		mov cl,gorb
		xor ch,ch
		mov pitch,offset brass
bBas1		push cx
		push bx
		mov bx,pitch
		mov cl,[bx]
		mov lcolr,cl
		inc bx
		mov pitch,bx
		pop bx
		pop cx
		push cx
		push bx
		add cx,offset sine
		xchg cx,bx
		mov al,[bx]
		xchg cx,bx
		cbw
		add ax,128
		sar ax,1
		sar ax,1
		sar ax,1
		sub bx,ax
		cmp bx,255
		jl boomz1
		pop bx
		jmp ittl
boomz1		mov dl,255
		sub dl,bl
		mov llen,dl
		MOV dl,Bl
		push dx
		add dx,ascreen
		mov word ptr lix,dx
		mov al,ascb
		mov lseg,al
		mov ax,offset hline
		bum_run 11h
		pop dx
		pop bx
ittl		pop cx
		add cx,7
		and cx,255
;		inc dh
		dec bx
		inc dh
		cmp dh,120+66
		jne bBas1
		jmp nobas2





		sub bx,ppos
		shr bx,1
		shr bx,1
		shr bx,1
		shr bx,1
		test bx,0f00h
		jne nobas2
		push bx
		mov ah,bl
		mov al,100
		mov bh,255
		sub bh,bl
		mov bl,20
		mov cx,64
		call hcblok
		pop bx
		push bx
		mov cx,101
		inc bx
		mov ax,3
		call xsprite
		pop bx
dlt		mov ax,155
		mov cx,82
		push bx
		call xsprite
		pop bx
		add bx,17
		cmp bx,255
		jl dlt

abase		cmp gotem,0
		jne dothis
		jmp nobas2
dothis		mov ax,16
		mov bx,offset shfra
drfxx		cmp word ptr [bx],0
		je yaghi
		mov dx,[bx]
		mov cx,2[bx]
		push ax
		push bx
		mov ax,4[bx]
		cmp ax,3
		jge rao
		add ax,137
		mov bx,dx
		push cx
		push dx
		call csprite
		pop dx
		pop cx
rao		pop bx
		mov ax,2
		call gexp
		pop ax
yaghi		add bx,10
		dec ax		
		jne drfxx
nobas2 
		mov cx,0
		mov bx,0
		mov ax,157
		call rsprite
		mov cx,0
		mov bx,253
		mov ax,158
		call rsprite


		cmp txtdur,0
		je notext
		mov bx,shbpt
		add bx,offset shipbuf
		mov cx,32[bx]
		sub cx,20
		mov ax,[bx]
		mov bx,txtadr
		mov xf,0
		call tsprite


notext		call draw_shx
		cmp frad,0
		je impaled
		call draw_frap
impaled
;
;Draw score
;
		mov ax,219
		mov bx,1
		mov cx,172
		call xsprite	;'Score' plaque
		mov ax,bmv
		add ax,20
		mov bx,31
		mov cx,172+16
		call xsprite
		mov ax,218
		mov bx,136
		mov cx,172
		call xsprite	;Weapons bar
		mov ax,223
		mov bx,136
		mov cx,172+13
		call xsprite	;Weapons scale
		mov ax,lives
		cmp ax,0
		je no_lyves
		cmp ax,10
		jle youij
		mov ax,10
youij		mov pitch,ax
		mov ax,220
		test thron,-1
		je noui
		mov bl,fpha
		and bx,1
		add ax,bx
		inc ax
noui		cmp shipp,4
		je nouil
		cmp shipp,0
		jne setmid
		add ax,4
		jmp nouil
setmid		mov ax,227
nouil	
		mov bx,offset shoffs
		mov dx,ax
		sub dx,220
		add bx,dx
		mov bl,[bx]
		xor bh,bh
		add bx,44 
		mov cx,172+18
xshipl		push ax
		push bx
		push cx
		call xsprite
		pop cx
		pop bx
		add bx,21
		pop ax
		dec pitch
		jne xshipl	;draw lives left		


no_lyves	mov bx,offset score
		mov pitch,8	;allow 8 digite
		mov dx,43	;initial X pos
dr_sc		mov al,[bx]	;check leading 0's
		cmp al,0
		jne dr_sc1
		inc bx
		dec pitch
		jne dr_sc
		jmp ze_sc
dr_sc1		xor ah,ah
		add ax,208	;get right sprite no.
		push bx
		push dx
		mov bx,dx	;get Xpos
		mov cx,173
		call xsprite	;draw digit
		pop dx
		add dx,12	;offset next digit
		pop bx
		inc bx
		mov al,[bx]
		dec pitch
		jne dr_sc1	;draw whole score 
		jmp ze_sc2

ze_sc		mov bx,dx
		mov ax,208
		mov cx,173
		call xsprite	;single zero
		
ze_sc2		ret

dbuff		mov ax,the_business
		call ax
		mov ax,bscreen
		mov bx,ascreen
		mov bscreen,bx
		mov ascreen,ax		;swop virtual screens
		mov al,bscb
		mov bl,ascb
		mov ascb,al
		mov bscb,bl
		mov ax,00h
;		out BORDL,ax
		mov sync,1
wsy		cmp sync,0
		jne wsy			;wait for sync
		jmp cls




draw_frap	mov cx,16
		mov bx,offset shfra
drawf		push cx
		mov dx,[bx]
		sub dx,ppos
		sar dx,1
		sar dx,1
		sar dx,1
		sar dx,1
		sub dx,80
		mov cx,32[bx]
		sar cx,1
		sar cx,1
		sar cx,1
		sar cx,1
		mov al,frap
		xor ah,ah
		push bx
		mov bx,dx
		call csprite
		pop bx
		pop cx
		inc bx
		inc bx
		loop drawf
		ret

draw_shx	cmp shxfree,16
		jne drash
		ret
drash		mov bx,offset shxes
		mov ax,16
telev		push ax
		cmp word ptr [bx],0
		jne prch
_prch		jmp next_prch
prch		mov dx,[bx]
		sub dx,ppos
		sar dx,1
		sar dx,1
		sar dx,1
		sar dx,1
		test dx,0e00h
		jne _prch
		mov cx,32[bx]
		sar cx,1
		sar cx,1
		sar cx,1
		sar cx,1
		sub dx,80
		push bx
		mov ax,64[bx]
		mov bx,dx
		mov t_y,cx
		mov t_x,bx
		mov t_a,ax		
		add cx,ax
		add bx,ax
		mov ax,170
		call csprite
		mov bx,t_x
		mov cx,t_y
		mov ax,t_a
		add cx,ax
		sal ax,1
		add bx,ax
		mov ax,171
		call csprite
		mov bx,t_x
		mov cx,t_y
		mov ax,t_a
		sub cx,ax
		add bx,ax
		mov ax,172
		call csprite
		mov bx,t_x
		mov cx,t_y
		mov ax,t_a
		sub cx,ax
		sal ax,1
		add bx,ax
		mov ax,173
		call csprite
		pop bx
		mov dx,t_x
		mov cx,t_y
		mov ax,t_a
		cmp ax,0
		jg bogie
		neg ax
bogie		sar ax,1
		sar ax,1
		cmp ax,3
		jge next_prch
		add ax,137
		push bx
		mov bx,dx
		call csprite
		pop bx
next_prch	pop ax
		inc bx
		inc bx
		dec al
		jne ttelev
		ret
ttelev		jmp telev

draw_als
		mov bx,offset adat
drall		cmp byte ptr [bx],0
		jne laba
		jmp next_al
laba		cmp bx,calend
		jge no_skan
		cmp byte ptr [bx],2
		je no_skan
		mov dx,2[bx]
		push bx
		mov cx,4[bx]
		mov bx,dx
		sar cx,1
		sar cx,1
		sar cx,1
		sar cx,1
		mov dx,62
		call scan
		pop bx
no_skan		mov dx,2[bx]
		sub dx,ppos
		sar dx,1
		sar dx,1
		sar dx,1
		sar dx,1
		mov cx,4[bx]
		sar cx,1
		sar cx,1
		sar cx,1
		sar cx,1
		cmp byte ptr 62[bx],0	;incorporate X sine?
		je noxsine		;no
		push cx
		mov cl,60[bx]		;get divisor
		mov ax,56[bx]		;get sine ptr
		and ax,0ffh
		push bx
		mov bx,ax
		add bx,offset sine	;index into sine table
		mov al,[bx]		;get value
		cbw			;sine extend
		sar ax,cl		;divide by specified value
		add dx,ax		;offset true X
		pop bx
		pop cx			;get back used stuff
noxsine		cmp byte ptr 63[bx],0	;now do same fur y
		je noysine
		push cx
		mov cl,61[bx]
		mov ax,58[bx]
		and ax,0ffh
		push bx
		mov bx,ax
		add bx,offset sine
		mov al,[bx]
		cbw
		sar ax,cl
		pop bx
		pop cx
		add cx,ax		;offset Y
noysine		test dx,0e00h
		jne onexal
		sub dx,80
		cmp dx,255
		jg onexal
		mov 32[bx],dx
		push bx
		mov 34[bx],cx
		mov ax,bx
		mov bx,12[bx]
		sal bx,1
		add bx,offset drawvex
		mov bx,[bx]
		xchg dx,bx
		call dx
		pop bx
		mov byte ptr 1[bx],1
		jmp next_al
onexal		mov byte ptr 1[bx],0
next_al		add bx,128
		cmp bx,alend
		jne idrall
		ret
idrall		jmp drall
dshot
;		mov ax,119
		mov ax,165
		jmp csprite
drass		mov ax,191
		jmp csprite
drcan		mov ax,192
		jmp csprite
smdr		mov ax,200
		jmp csprite


adraw		xchg ax,bx
		mov dl,49[bx]
		xor dh,dh
		add dl,51[bx]
		xchg ax,bx
		mov ax,dx
		call csprite
		ret


drezin		push ax
		mov ax,205		;rezup centre block
		push bx
		push cx			;save co-ords
		call csprite
		pop cx
		pop ax
		pop bx			;axxess def blok
		mov dl,24[bx]		;get rez-distance
		xor dh,dh
		mov bx,ax		;retrieve X
		mov ax,dx
		and ax,1
		add ax,206		;gen rezframe grafic
		mov pitch,3		;no. of rez-images
xx_l		push dx
		push cx
		push bx
		push ax			;save all info
		sub bx,dx		;left-offset
		call csprite
		pop ax
		pop bx
		pop cx
		pop dx			;getallback
		push dx
		push cx
		push bx
		push ax	
		add bx,dx		;right offset
		call csprite
		pop ax
		pop bx
		pop cx
		pop dx
		push dx
		push cx
		push bx
		push ax	
		add cx,dx		;bottom offset
		call csprite
		pop ax
		pop bx
		pop cx
		pop dx
		push dx
		push cx
		push bx
		push ax	
		sub cx,dx		;top offset
		call csprite
		pop ax
		pop bx
		pop cx
		pop dx
		sal dx,1
		dec pitch
		je rffin
		jmp xx_l
rffin		ret

dex
		xchg ax,bx
		mov dx,20[bx]
		cmp dx,140
		je nms
		xchg ax,bx
		push bx
		push cx
		push ax
		mov ax,dx
		call csprite
		pop ax
		pop cx
		pop bx
		xchg ax,bx
nms		mov dx,24[bx]
		mov bx,26[bx]
		xchg bx,ax
		add cx,ax
		add bx,dx
		mov yct,3
		mov xcol,167
xxll		mov xct,3
		push bx
xxll1		mov pitch,ax
		push ax
		push bx
		push cx
		push dx
		mov ax,xcol
		call csprite
		pop dx
		pop cx
		pop bx
		pop ax
		inc xcol
		add bx,dx
		dec xct
		jne xxll1
		pop bx
		add cx,ax
		dec yct
		jne xxll
		ret


scan
;
;scan at (bx,cx); uses ax, colour in dx, bx is planet position
;

		mov ax,cx
		sAr ax,1
		sAr ax,1
		sAr ax,1
;		sAr ax,1
		inc al
		mov ah,bh
		xchg ah,al
		add ax,ascreen
		mov word ptr pixx,ax
		mov al,ascb
		mov pixp,al
		mov pixc,dl
		mov ax,offset pixel
		bum_run 11h
		ret

draw_bulls
;
;Draw any active-bullets
;
		mov bx,offset bulls

pros
		push bx
		mov dl,byte ptr [bx]
       		xor dh,dh
		xchg dx,bx
		shl bx,1
		add bx,offset buldraw
		mov ax,[bx]
		xchg dx,bx
		jmp ax			;call relevant DRAW routine
sbdraw	
		mov dx,1[bx]
		mov cx,3[bx]
		mov ax,135
yakka		cmp word ptr 7[bx],0
		jg gokk
		inc ax
gokk		mov bx,dx
		call csprite
prose		pop bx
		add bx,28
		cmp bx,bullen
		jne pros
		ret
budraw		mov ax,201
ru		mov dx,1[bx]
		mov cx,3[bx]
		jmp gokk
syndrw		mov ax,202
		jmp ru


sprdraw		mov dx,1[bx]
		mov cx,3[bx]
		mov ax,149
okah		cmp word ptr 7[bx],0
		jl gokk
		inc ax
		jmp gokk
widraw		mov dx,1[bx]
		mov cx,3[bx]
		mov ax,151
		jmp okah

exdraw				;draw an explosion
		mov dx,1[bx]
		mov cx,3[bx]
		mov ax,5[bx]
		cmp ax,3
		je agi
		add ax,137
		push dx
		push cx
		push bx
		mov bx,dx
		call csprite
		pop bx
		pop cx
		pop dx
		cmp word ptr 8[bx],0
		jge agi
soviets		jmp prose		

agi		mov ax,3
		call gexp
		jmp prose
gexp		push 8[bx]
agr0		push ax
agr		push dx
		push cx
		mov ax,8[bx]
		push ax
		sub cx,ax
		sub dx,ax
		push bx
		mov bx,dx
		mov ax,167
		call csprite
		pop bx
		pop ax
		pop cx
		pop dx
		push dx
		push cx
		push ax
		sub cx,ax
		add dx,ax
		push bx
		mov ax,171
		mov bx,dx
		call csprite
		pop bx
		pop ax
		pop cx
		pop dx
		push dx
		push cx
		push ax
		add cx,ax
		add dx,ax
		push bx
		mov ax,177
		mov bx,dx
		call csprite
		pop bx
		pop ax
		pop cx
		pop dx
		push dx
		push cx
		push ax
		add cx,ax
		sub dx,ax
		push bx
		mov ax,181
		mov bx,dx
		call csprite
		pop bx
		pop ax
		pop cx
		pop dx
		pop ax
		sal word ptr 8[bx],1
		dec ax
		jne agr00
		pop 8[bx]
		ret
agr00		jmp agr0


robdraw		mov dx,1[bx]
		mov cx,3[bx]
		mov ax,193
		jmp okah

zzapd		test byte ptr 8[bx],-1
		je zzax
		mov ax,1[bx]
		mov cx,3[bx]
		jmp zzax1
zzax		mov ax,1[bx]
		sub ax,ppos
		sar ax,1
		sar ax,1
		sar ax,1
		sar ax,1
		test ax,0e00h
		je pro_ceed
		JMP PROSE
pro_ceed	sub ax,80
		mov cx,3[bx]
		sar cx,1
		sar cx,1
		sar cx,1
		sar cx,1
zzax1		mov lx1,ax
		mov ly1,cx
		push bx
		push ax
		push cx
		mov ax,shipx
		mov lx2,ax
		push ax
		mov ax,shipy
		push ax
		sub ax,6
		mov ly2,ax
		mov lc,104
		call ccline		
		pop ax
		add ax,6
		mov ly2,ax
		pop lx2
		pop ly1
		pop lx1
		call ccline
		pop bx
		jmp prose
lazdraw
		mov dx,1[bx]
		mov cx,3[bx]
		mov ax,5[bx]
		add ax,142
		cmp word ptr 7[bx],0
		jg lazd1
		add ax,3
lazd1		mov bx,dx
		call sprite
		jmp prose

baldraw	
;		mov ax,5[bx]	;TB pointer
;		add ax,6
;		and ax,7	;get pos-2
;		add ax,12
;		push bx
;		add bx,ax
;		mov ax,[bx]	;get tb X
;		mov cx,8[bx]	;get tb y
;		mov bx,ax
;		mov ax,141
;		call csprite
;		pop bx
		mov ax,1[bx]
		mov cx,3[bx]
		mov bx,ax
		mov ax,195
		call csprite
		jmp prose

;Now get the balls background into the background buffer and plot the ball
;
;					;29h=	RUN (execute this blitter program)
;		mov ax,offset do_plot	;	SRCUP (source -ball's background is a rectangle)
;		blit_run 29h		;	SRCEN (read the source -COPY)


;		mov ax,offset restore
;		bum_run 31h		;31h=	RUN (execute the blitter)
					;	DSTUP (destination is rectangle)
					;	SRCEN (read source)





; Routine DBLOCK. Draws a block on the current screen
; Set up BLOCK parameters BLOX/BLOY/BHIG/BWID/BCOL then call DBLOCK.

dblock		mov al,bwid
		xor al,255
		inc al
		jmp gret
		mov ah,60h
		jne notmax
		mov ah,22h
notmax		mov bset,20h
		mov bstep,al		;place in blitter prog
		mov ax,offset block	;point to blitterprog
		bum_run 11h		;only dest. used
gret		ret		

; Routine CLS. Use DBLOCK to clear screen to colour zero.
; Clears current (ASCREEN)

cls
		mov ax,ascreen
		mov word ptr blox,ax
		mov al,ascb
		mov sseg,al
		mov bhig,200
 		mov bwid,128		
		mov bcol,0
		mov bset,60h
		mov bstep,0
		mov ax,offset block
		bum_run 11h
		ret

; Horizontally clipped block routine. Draws a block from (ah,al) to
; offset (bh,bl), clipping as appropriate. (colour CL)
hcblok
;		ret
		and ah,0feh
		mov bcol,cl
		mov bloy,al
		mov bhig,bl
		mov al,ah
		xor ah,ah
		mov bl,bh
		xor bh,bh
		cmp ax,xlo
		jge hco1
		sub ax,xlo
		add bx,ax
		jle hfale
		mov ax,xlo
hco1		mov cx,ax
		cmp ax,xhi
		jg hfale
		add ax,bx
		cmp ax,xhi
		jle hok
		sub ax,xhi
		sub bx,ax
		jle hfale
hok		mov blox,cl
;		sar bl,1
		mov bwid,bl		
		mov ax,ascreen
		add word ptr blox,ax
		jmp dblock
hfale		ret


dcls
;
;Clears BOTH screens
;
		mov ax,ascreen
		push ax
		mov ax,bscreen
		mov ascreen,ax
		call cls
		pop ax
		mov ascreen,ax
		jmp cls
		


;set up game-palette
;assumes es --> 40000, ds--> data

set_pal		mov cx,256
		mov bx,offset game_pal+1
		xor dx,dx
pxf		mov ax,[bx]
		push bx		
		mov bx,dx
		mov word ptr es:[bx],ax
		pop bx
		inc bx
		inc bx
		inc dx
		inc dx
		loop pxf
		ret



ccline
;
;CCLINE clips a line to screen boundaries. Set LX1,LX2,LY1,LY2,LC before
;entry. Routine clips then passes clipped stuff to linedraw
;Uses Cohen-Sutherland integer clipping
;
		mov ax,lx1
		mov bx,ly1
		call gen_out	;generate Outcode
		mov out1,dx	;store outcode for point 1
		mov ax,lx2
		mov bx,ly2
		call gen_out	;get Outcode 2
		mov out2,dx	;store point 2 outcode
		test dx,0fh	;test outcode 2
		jne testw1
		test out1,0fh
		jne testw1
jdl		jmp do_line	;both zero, trivial accept

testw1
		and dx,out1	;AND both out-codes
		je nontriv
triv		ret		;trivial reject
nontriv		test out2,0fh	;Point 2 viz?
		je testw3	;Yes, skip RH clipping
		mov dx,out1
		mov icode1,dx
		mov dx,out2
		mov icode2,dx	;Set up for intersect find
		mov dx,lx1
		mov ix1,dx
		mov dx,ly1
		mov iy1,dx
		mov dx,lx2
		mov ix2,dx
		mov dx,ly2
		mov iy2,dx
		call _intersect	;Find intersect of line
		test icode1,0fh
		jne triv	;Reject if off-screen
		mov lx2,ax
		mov ly2,bx	;Right-hand Intersect
		jmp do_line


testw3		mov dx,out2
		mov icode1,dx
		mov dx,out1
		mov icode2,dx	;Set up for intersect find
		mov dx,lx2	;With reversed co-ordinates
		mov ix1,dx
		mov dx,ly2
		mov iy1,dx
		mov dx,lx1
		mov ix2,dx
		mov dx,ly1
		mov iy2,dx		
		test icode2,0fh
		jne testw4
		jmp do_line	;If LH point is viz, skip ifind

testw4		call _intersect
		mov lx1,ax
		mov ly1,bx

do_line		mov bl,byte ptr lx1
		mov bh,byte ptr ly1
		mov al,byte ptr lx2
		mov ah,byte ptr ly2
		mov cl,byte ptr lc
		jmp line

_intersect
;
;Find intersection of (IX1,IY1)-(IX2,IY2) and clip windoe
;Returns ICODE1 nonzero (fail) or point in (AX,BX)
;
		mov ax,ix1
		add ax,ix2
		sar ax,1
		mov bx,iy1
		add bx,iy2
		sar bx,1	;gen midpoint on (ax,bx)
		mov midx,ax
		mov midy,bx	;store mid-point
		call gen_out	;generate Out-Code
		mov cx,icode2
		and cx,dx
		jne fother
		mov cx,midx
		cmp cx,ix1
		jne findw1
		mov cx,midy
		cmp cx,iy1
		jne findw1
		jmp fendit

findw1
		mov cx,midx
		cmp cx,ix2
		jne findw2
		mov cx,midy
		cmp cx,iy2
		jne findw2
		jmp fendit

findw2
		mov cx,midx
		mov ix1,cx
		mov cx,midy
		mov iy1,cx
		mov icode1,dx
		jmp _intersect	;iterate

fother	
		mov cx,midx
		cmp cx,ix2
		jne fother1
		mov cx,midy
		cmp cx,iy2
		je fendit
fother1		mov cx,midx
		cmp cx,ix1
		jne fother2
		mov cx,midy
		cmp cx,iy1
		je fendit
fother2
		test icode1,0fh
		je fother3
		mov cx,dx
		and cx,icode1
		jne fexit
fother3		mov cx,midx
		mov ix2,cx
		mov cx,midy
		mov iy2,cx
		mov icode2,dx
		jmp _intersect

fexit		mov icode1,1
fendit		mov ax,ix1
		mov bx,iy1
		ret

gen_out
;
;Generate Cohen-Sutherland outcode of (ax,bx)
;
		mov dx,0
		cmp bx,200
		jl gout1
		or dx,1
gout1		sal dx,1
		cmp bx,0
		jge gout2
		or dx,1
gout2		sal dx,1
		cmp ax,255
		jle gout3
		or dx,1
gout3		sal dx,1
		cmp ax,0
		jge gout4
		or dx,1
gout4		ret  		

;===================================================================
;LINE plots a line in medium res - from Xstart, Ystart to Xend, Yend
;where
;		AH=Yend, AL=Xend, BH=Ystart, BL=Xstart, CL=colour
;
;ASSUMES DS points to data segment



line
		mov line_col,cl			;set the colour
;		inc bh
;		inc ah				;compensate for address of screen
		add ax,ascreen
		add bx,ascreen
		mov word ptr start_x,bx

		xor cl,cl			;direction flag for X
		sub al,bl			;get Xdir and magnitude ?
		jae lp1
		neg al				;take the modulus
		mov cl,64			;inform of -ve direction
lp1		mov x_sign,cl

		xor cl,cl			;again, this time for Y
		sub ah,bh
		jae lp2
		neg ah
		mov cl,64
lp2		or cl,ascb
		mov y_sign,cl

		mov cl,8+32+128			;LINE draw and MED res screen
		cmp al,ah
		jb lp3
		mov cl,8+32+16+128		;YFRAC set 'cos X bigger than Y
		xchg al,ah			;swap DELTA1 and DELTA2
lp3		mov l_mode,cl

		mov delta_1a,ah			;AL=delta2, AH=delta1
		mov delta_1b,ah
		mov delta_2,al
		shr ah,1			;delta1/2
		mov delta_12,ah

		mov ax,offset line_blit		;execute the blitter program
		bum_run 01h
	ret



;===================================================================
;RANDOM returns a 16 bit random number in AX, no other registers are
;affected
;
;ASSUMES: HLPL and VLPL return pos of the electron beam,
;	  which implies that bit 0 of DIAG is set. Also
;	  assumes DS points to the data segment
;	  (for speed purposes only)

random		in ax,HLPL			;get horizontal position
       		add ax,seed			;add to current random number
		mov seed,ax
		in al,VLPL			;get vertical
		xchg ah,al
		xor al,al
		add ax,seed
		mov seed,ax			;add to top byte of seed word
		ret


;routine SPRITE: Pre-processor for DRAW_SPRITE. Enter with:
;sprite no. (ax), xpos (bx), ypos (cx) to draw sprite on current screen

csprite		mov dx,bx
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		push bx
		mov ax,[bx]
		mov bx,dx
		mov dx,ax
		xor ah,ah
		sar ax,1
		sub bx,ax
		mov al,dh
		sar ax,1
		sub cx,ax
		jmp xyin



cxsprite
		mov dx,bx
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		push bx
		mov ax,[bx]
		mov bx,dx
		mov dx,ax
		xor ah,ah
		sar ax,1
		sub bx,ax
		mov al,dh
		sar ax,1
		sub cx,ax
		jmp xin


sprite	
;
;Draw sprite with all clipping on (0,0)-(255,120) screen
;
		mov dx,bx
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		push bx
		mov ax,[bx]		;XY size info
		mov bx,dx
		mov dx,ax		;in DX
;
;Xclip to within (0-255) and set blitter registers
;
xyin		mov al,dl
		xor ah,ah
		add ax,bx
		cmp bx,0
		jge ixon
		cmp ax,0
		jg ixlegl
ifale		pop bx
		ret		 
ixlegl
		add dl,bl
		mov al,bl
		mov bx,0
		jmp isetx
ixon
 		cmp bx,254
		jge ifale
		cmp ax,254
		jl ipsetx
		sub dl,al
ipsetx		xor al,al
isetx		mov dstx,bl
		mov swid,dl
		xor dl,0ffh
		inc dl
		mov sstp,dl

;
;Yclip to within (0-120) and set blitter registers
;
		mov bl,dh	;B reg is free of X data now
		xor bh,bh
		add bx,cx
		cmp cx,0
		jge yon
		cmp bx,0
		jg ylegl
yfale		pop bx
		ret		 
ylegl
		add dh,cl
		mov ah,cl
		mov cx,0
		jmp sety
yon		mov ah,0
 		cmp cx,200
		jge yfale
		cmp bx,200
		jl psety
		sub bl,200
		sub dh,bl
psety		xor bl,bl
sety		mov dsty,cl
		mov shig,dh
		jmp go_blit


_sprite
;
;Draw sprite with all clipping on (0,0)-(255,100) screen (horizon clip)
;		
		
sp_usu		mov dx,bx
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		push bx
		mov ax,[bx]		;XY size info
		mov bx,dx
		mov dx,ax		;in DX
;
;Xclip to within (0-255) and set blitter registers
;
		mov al,dl
		xor ah,ah
		add ax,bx
		cmp bx,0
		jge _ixon
		cmp ax,0
		jg _ixlegl
_ifale		pop bx
		ret		 
_ixlegl
		add dl,bl
		mov al,bl
		mov bx,0
		jmp _isetx
_ixon
 		cmp bx,255
		jge _ifale
		cmp ax,255
		jl _ipsetx
		sub dl,al
_ipsetx		xor al,al
_isetx		mov dstx,bl
		mov swid,dl
		xor dl,0ffh
		inc dl
		mov sstp,dl

;
;Yclip to within (0-200) and set blitter registers
;
		mov bl,dh	;B reg is free of X data now
		xor bh,bh
		add bx,cx
		cmp cx,0
		jge _yon
		cmp bx,0
		jg _ylegl
_yfale		pop bx
		ret		 
_ylegl
		add dh,cl
		mov ah,cl
		mov cx,0
		jmp _sety
_yon
 		cmp cx,160
		jge _yfale
		cmp bx,160
		jl _psety
		sub bl,160
		sub dh,bl
_psety		xor bl,bl
_sety		mov dsty,cl
		mov shig,dh
		jmp go_blit



xsprite
;
;as SPRITE but only x-clip performed
;
		mov dx,bx
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		push bx
		mov ax,[bx]		;XY size info
		mov bx,dx
		mov dx,ax		;in DX
;
;Xclip to within (0-255) and set blitter registers
;
xin		mov al,dl
		xor ah,ah
		add ax,bx
		cmp bx,0
		jge xon
		cmp ax,0
		jg xlegl
fale		pop bx
		ret		 
xlegl
		add dl,bl
		mov al,bl
		mov bx,0
		jmp setx
xon
 		cmp bx,255
		jge fale
		cmp ax,255
		jl psetx
		sub dl,al
psetx		xor al,al
setx		mov dstx,bl
		mov swid,dl
		xor dl,0ffh
		inc dl
		mov sstp,dl

		mov ah,0	;raw unclipped Y stuff here
		mov dsty,cl
		mov shig,dh

go_blit		pop bx

yokko		mov cx,2[bx]
		sub cl,al
		sub ch,ah
		cmp byte ptr 4[bx],0
		je spage1
		mov srcep,1ah
		add cx,4
		jmp spage22
spage1		mov srcep,19h
		add cx,offset sprites+4
spage22		mov word ptr srcex,cx
		mov byte ptr dstp,0
		mov ax,ascreen
		add word ptr dstx,ax
		mov ax,offset dsprite
		mov bl,ascb
		mov dstp,bl
		bum_run 39h
		ret

gbolt
;
;Generate a Lightning Bolt for background
;
		mov bx,offset lbolt
		call random
		and ax,03fh		;gen bolt start pos
		add ax,07fh
		mov cx,ax
		mov [bx],ax		;start point
		inc bx
		inc bx
		call random
		and ax,1fh
		sub ax,0fh
		add cx,ax		;point B
		mov [bx],cx
		inc bx
		inc bx
		call random
		and ax,1fh
		sub ax,0fh
		add cx,ax
		mov [bx],cx		;point C
		inc bx
		inc bx
		call random
		and ax,1fh
		sub ax,0fh
		add cx,ax		;point D
		mov [bx],cx
		inc bx
		inc bx
		push cx
		call random
		and ax,1fh
		sub ax,0fh
		add cx,ax		;point E
		mov [bx],cx
		inc bx
		inc bx
		pop cx
		call random
		and ax,1fh
		sub ax,0fh
		add cx,ax
		add cx,30
		mov word ptr [bx],cx
		mov lboltd,20		;duration
		ret
				
rsprite
;
;Raw Sprite draw- no clipping, be careful!
;

		mov dstx,bl
		mov dsty,cl
		rol ax,1
		rol ax,1
		rol ax,1	;point to 8-byte segs of data
		mov bx,offset sinfo
		add bx,ax	;point to sprite-bites
		xor ah,ah
		mov al,[bx]	;get x size
		mov swid,al
		mov cl,1[bx]	;y size
		mov shig,cl	
;		jmp yokko
		mov cl,2[bx]
		mov srcex,cl
		mov cx,3[bx]
		mov srcey,cl	;parameters set up
		mov cl,255
		sub cl,al
		inc cl
		mov sstp,cl
;		mov bx,abuff
;		add bx,bptr		;point to current data list
;		mov ax,word ptr dstx	;collext XY start
;		mov [bx],ax		;save XY start
;		mov ax,word ptr shig	;collect dimensions
;		mov 2[bx],ax		;place in buffer
;		add bptr,4		;up-date bptr
ghoat		mov ax,offset sprites+4
		add word ptr srcex,ax
		mov ax,ascreen		;get crnt. screen
		add word ptr dstx,ax	;draw upon it
		mov ax,offset dsprite
		bum_run 39h			;doIt
		ret

crsprite	mov dl,bl
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		mov al,[bx]
		mov swid,al
		shr al,1
		sub dl,al
		mov dstx,dl
		mov al,1[bx]
		mov shig,al
		shr al,1
		sub cl,al
		mov dsty,cl
		mov cl,255
		sub cl,[bx]
		inc cl
		mov sstp,cl
		mov al,2[bx]
		mov srcex,al
		mov ax,3[bx]
		mov srcey,al
		mov srcep,19h
		jmp ghoat 

;==================================================
;Interrupt service routine. This one does nothing !

int_s0	
		out ACK,al			;acknowledge and return
		iret


frast						;fast Rastah man	
		cli
;		movsw				;(at least as fast
		push ax
		lodsw
		xor ax,rasand
		stosw
;		mov di,ax
		mov ax,cline			;the interrupt handling
		add ax,4			;speed of that 8088)
		cmp ax,300		
		jge frast_1
;		jmp frast_1
		mov cline,ax
		out INTL,ax
;		mov ax,di
		pop ax
		xor di,di	
		sti
		OUT ACK,al
		iret
frast_1	
;
;set next rasirq at line-40
;
;		push di
		mov ax,26+78+25+20
		out INTL,ax
		mov si,clist
		add si,6
		mov cline,26+78+25+20
		test w_mode,-1
		je norm_mode
		push bx
		push cx
		mov bl,w_hite
		xor bh,bh
		sar bx,1
		mov ax,shipy
		add ax,60
		sub ax,bx
		mov cx,60
		cmp ax,cx
		jge wtopok
		mov ax,60
wtopok		out STARTL,ax
		sub ax,60
		mov ah,al
		xor al,al
		mov di,ax
		mov ax,shipy			;variable window stuff
		add ax,60
		add ax,bx
		cmp ax,259
		jle wbotok
		mov ax,259
wbotok		out ENDL,ax
		pop cx
		pop bx
		jmp eewok
norm_mode	mov ax,60
		add ax,scro
		out STARTL,ax			;screen start, central
		mov ax,259			;200 active lines ?
;		mov ax,180
		add ax,scro
		out ENDL,ax
		mov ax,0
		mov di,0
;
;VBL-type code
;
eewok
		mov ax,000h
;		out BORDL,ax
		mov ax,bscreen			;bscreen is non-active
		add ax,di
		out SCROLL1,ax			;install
		mov al,bscb
		out SCROLL3,al
		cmp sync,0
		je syok
		sub sync,1			;tell foreg OK		
syok		mov ax,scrl
		dec ax
		dec ax
		and ax,511
		mov scrl,ax
		push bx
		push cx
		push dx
		push si
		push bp
		cmp rasxp,0
		je rabies
		mov bx,rasxp
		mov ax,[bx]
		cmp ax,-1
		jne rabb
		mov rasxp,0
		jmp rabies
rabb		mov rasand,ax
		inc bx
		inc bx
		mov rasxp,bx
rabies


		cmp fon,0		;Palette fade controller code
		je ffade		;no fade current
		mov ax,fdel
		cmp al,0
		je okfade
		dec al
		cmp al,0
		je okfade
		mov fdel,ax
		jmp ffade
okfade	
		mov fdel,ax
		mov ax,fcur		;get current colour
		mov bx,ax
		mov cx,16		;16 colours per fade
		add bx,cx		;ccol+4
		cmp bx,fend		;last colour?
		jg tfade		;yes, do term stuff
		mov bx,offset game_pal+1
		mov dx,ffrom		;get fade level
		add fcur,cx
		call xfur		;transfer with fade
		jmp ffade		;OK fade
tfade
		sub bx,fend		;find out overshoot
		xor bl,15
		mov cl,bl
		inc cx			;generate right no.
		mov bx,offset game_pal+1
		mov dx,ffrom
		call xfur
		mov ax,fto
		cmp ax,ffrom
		jne tfa1
		mov fon,0
		jmp ffade
tfa1		mov ax,fstep
		add ffrom,ax
		mov ax,fdel
		mov al,ah
		mov fdel,ax
		mov ax,fstart
		mov fcur,ax		;reset for next go
ffade
;
;Now do Transit Calc pending
;

		cmp t_mode,0		;transit process on?
		jne woy
		jmp no_trans
woy		cmp t_mode,-1		;start up RDL?
		jne n_rdl
		mov t_mode,1
		jmp init_rdl
n_rdl		mov ax,t_src
		mov dx,t_dstc
		mov ch,t_cstp
		mov cl,t_shft
		call tween		;calc transit step
		mov bx,t_addr
		mov [bx],dx
		inc bx
		inc bx
		mov t_addr,bx		;place transit value
		add t_cstp,1		;step up
		mov al,t_cstp
		cmp al,t_tstp		;total steps done?
		jne no_ra1		;no
init_rdl	cmp t_mode,1		;what going on after this pass
		jne no_ra1		;not a rasta build list
		mov bx,t_rgen
		mov ax,[bx]
		cmp ax,-1
		je tterm
		mov t_src,ax
		inc bx
		inc bx
		mov ax,[bx]
		mov t_dstc,ax
		inc bx
		inc bx
		mov al,[bx]
		mov t_tstp,al
		inc bx
		mov al,[bx]
		mov t_shft,al
		inc bx
		mov t_rgen,bx		;read gen params; update ptr
		mov t_cstp,1		;set current step=0	
		jmp no_ra1		;allow to carry on running
tterm		mov t_mode,0		;shutdown transit calc
		jmp no_trans
no_ra1		jmp no_ra

no_trans	cmp rcmd,0		;Rasta GEN/DISP command?
		je no_ra1
		cmp rcmd,1
		jne rast2		;not gen/disp
		cmp rip,0
		jne rast1		;just finished GAD
		mov ax,dlist
		mov t_addr,ax		;say where to gen list
		mov rip,1
		mov t_mode,-1		;start genlist func
		jmp no_ra
rast1		mov rip,0		;not in progress
		mov rcmd,0		;GAD done
		mov ax,clist
		mov bx,dlist
		mov clist,bx
		mov dlist,ax		;install new list
		jmp no_ra
rast2		cmp rcmd,2
		jne no_ra1		;not gen&fadein
		cmp rip,0		;finished?
		jne rast22		;not started
		mov ax,offset rl4	;rl4 used only for dest list
		mov t_addr,ax
		mov rip,1
		mov t_mode,-1		;generate new list in dlist
		jmp no_ra		;wait until generated
rast22		cmp rip,1		;dest list safely generated?
		jne rast23		;yes, must ne doing transit
		mov rip,2		;set first-pass condition
		mov rnum,0		;start line 0
		mov rcstep,1		;current step val=1
		jmp no_ra
rast23		cmp rip,2
		jne rast24		;rip=3 when first pass done
		mov cx,3
rll		mov bx,clist
		mov dx,rnum
		add bx,dx
		mov ax,[bx]		;get from val
		mov bx,offset rl4
		add bx,dx
		mov dx,[bx]		;get dest colour
		push cx
		mov cl,rshfts
		mov ch,rcstep
		call tween		;gen intermediate colour
		pop cx
		mov bx,glist
		mov ax,rnum
		add bx,ax
		mov [bx],dx		;make new list val
		inc ax
		inc ax
		mov rnum,ax
		cmp ax,256
		je kjk		;continue until list done
		loop rll
		jmp no_ra
kjk		mov ax,clist
		mov bx,glist
		mov cx,dlist		;dlist unused at the mo
		mov glist,cx		;glist free
		mov clist,bx		;old glist displayed
		mov dlist,ax		;source list now at dlist
		mov rnum,0		;reset
		inc rcstep		;next step
		mov rip,3		;tell OK to proceed
		jmp no_ra
rast24		mov cx,3
rll2		mov bx,dlist
		mov dx,rnum
		add bx,dx
		mov ax,[bx]		;get from val
		mov bx,offset rl4
		add bx,dx
		mov dx,[bx]		;get dest colour
		push cx
		mov cl,rshfts
		mov ch,rcstep
		call tween		;gen intermediate colour
		pop cx
		mov bx,glist
		mov ax,rnum
		add bx,ax
		mov [bx],dx		;make new list val
		inc ax
		inc ax
		mov rnum,ax
		cmp ax,256
		je rll3		;continue until list done		 		
		loop rll2
		jmp no_ra
rll3		mov ax,glist
		mov bx,clist
		mov glist,bx
		mov clist,ax		;display faded list
		mov rnum,0
		mov al,rcstep
		cmp al,rsteps		;full fade yet?
		je rast25		;yeah: shut down raster op
		inc rcstep		;do next rasta step
		jmp no_ra
rast25		mov rip,0
		mov rcmd,0		;shutdown, all OK

no_ra
		mov si,clist
		add si,8
		mov di,0
		lodsw
		xor ax,rasand
		stosw
		dec si
		dec si
		mov bx,offset irqvex
		mov ax,irqmode
		sal ax,1
		add bx,ax
		mov ax,[bx]
		jmp ax

_null		jmp iend		;null raster vector		

_launch		
		cmp w_hite,2
		jne noila
		mov si,offset _laun
		mov dx,shipx
		call inison
noila		mov ax,pspd
		add ppos,ax
		dec shipx
		xor xorf,1
		dec pspd
		add w_hite,2
		cmp w_hite,240
		jne anima
		mov w_mode,0
		mov irqmode,0		;startup game
		mov thron,0
		jmp no_raf
anima
		test xorf,-1
		je airb
		dec shipy
airb		jmp no_raf


_game
		cmp shlev,0
		jle nora
		jmp shalive
nora		cmp blowing,0
		jne sblo
		mov dx,shipx
		mov a_blok,offset gotu
		mov a_blot,2
		mov si,offset _dive
		mov altc,4
		call inison
sblo		mov blowing,1
		mov ax,190
		cmp shipy,ax
		jl frez
		call setfrap
		mov eqdur,30
		mov si,offset _kpow
		mov rasxp,offset gshit
		mov dx,shipx
		call inison
frez		inc shipy
		dec altc
		jne begon
		mov altc,4
		call dec_pwr
begon		test shipy,1
		je goathead
		call minizap
goathead	mov ax,pspd
		cmp ax,0
		jl dnegg
		jg dposs
		cmp shipp,0
		jne dnegg
dposs		cmp ax,180
		jge wazzo
		add pspd,2
		jmp wazzo
dnegg		cmp ax,-180
		jle wazzo
		sub pspd,2
wazzo		jmp theads
shalive		cmp frad,0
		je hanged
		call runfrap
hanged		cmp eqdur,0
		je equi
		call random
		and ax,3
		sub ax,2
		mov scro,ax
		dec eqdur
		jne equi
		mov scro,0
equi
;
;Read joystick; update ship position; accelerate.
;
		cmp running_time,JOY_TIMEOUT
		jae joy1_
		call wcon
		jmp no_joy

joy1_		in al,40h		;get joy byte
		xor al,0ffh		;test for weapon switch
		test al,08h		;fire button B
		je no_wep
		cmp wdb,0		;de-bounce
		jne dun_wep
		mov wdb,1
		add btype,1
		mov bl,lwp		;max available log-weap
		inc bl
		cmp btype,bl
		jl sho_wep
		mov btype,0
sho_wep		mov bl,btype
		xor bh,bh
		add bx,offset lwxt
		mov bl,[bx]
		xor bh,bh
		sal bx,1
		add bx,offset weptxtab
		mov cx,[bx]
		mov txtadr,cx
		mov txtdur,80
		jmp dun_wep
no_wep		mov wdb,0

dun_wep		push ax
		test al,4		;FIRE button?
		jne bastd
		jmp no_fire
bastd		sub ffreq,1
		jle bastd2
		jmp done_f
bastd2		mov ffreq,5		;intra-bullet delay
		mov dl,shipp
		cmp dl,0
		je fib
		cmp dl,4
		jne no_fire
fib
		mov bl,btype
		xor bh,bh
		add bx,offset lwxt		;logical weapon XT
		mov bl,[bx]
		mov lwep,bl		;set true weapon no.
		dec pdrain
		jg nodoww
		call dec_pwr		;do power-drain
		push bx
		xor bh,bh
		add bx,offset pdraint
		mov bl,[bx]
		mov pdrain,bl		;reset power drain count
		pop bx
nodoww		xor bh,bh
		shl bx,1
		add bx,offset bullau
		mov cx,[bx]
		jmp cx
;
;bullet type 1 specific launch code
;
norml		cmp bfree,0
		jle no_fire		;no bullets free
		call bseek		;get BX pointing to bullet
		mov cx,shipx
		mov byte ptr [bx],1
		mov 1[bx],cx
		mov cx,shipy
		add cx,3
		mov 3[bx],cx
		mov word ptr 7[bx],8		;X vel
		cmp dl,0
		je ffi
		neg word ptr 7[bx]
ffi		mov word ptr 9[bx],0		;Y vel
		mov word ptr 12[bx],17
		mov word ptr 14[bx],5
		mov si,offset _zap
		mov dx,shipx
		call inison
		jmp done_f		;fired bullet type 1

no_fire		mov ffreq,1
done_f		pop ax
		test al,0c0h		;up or down?
		je noud
		test al,080h
		je joyup
		add shipy,3
		mov bx,190
		cmp shipy,bx
		jl noud
		sub shipy,3

joyup		sub shipy,3
		cmp shipy,6
		jg noud
		add shipy,3
noud	
vvo		test al,30h
		jne mlon
		jmp noud0
mlon		test al,20h
		mov cx,180
		je joyleft
joy_rite	mov thron,1
		mov ax,100
		cmp shipx,ax
		je acc4
		jl acc3
		call dfall
		jmp acc4
acc3		inc shipx
		sub ppos,16
acc4		cmp pspd,cx
		jg zok2
		add pspd,4
		cmp shipp,0
		je zokos
		mov tdir,-1
zok2		jmp no_joy
zokos		jmp no_trn
joyleft		mov thron,1
		mov ax,140
		cmp shipx,ax
		je acc2
		jg acc1
		call dfall
		jmp acc2
acc1		add ppos,16
		dec shipx
acc2		neg cx
		cmp pspd,cx
		jl no_joy
		sub pspd,4
		cmp shipp,4
		je zokos
		mov tdir,1		
		jmp no_joy
noud0		call dfall	
		mov thron,0
		cmp pspd,0
		jl sincc		
		sub pspd,1
		jg no_joy
		mov pspd,0
		jmp no_joy
sincc		add pspd,1
		jl no_joy
		mov pspd,0

no_joy		cmp tdir,0
		je no_trn
		sub tdell,1
		jg no_trn
		mov al,shipp
		add al,tdir
		mov tdell,4
		mov shipp,al
		cmp al,0
		je kturn
		cmp al,4
		jne no_trn
kturn 		mov tdir,0
no_trn		sub fde,1
		jg theads
		add fpha,1
		mov fde,3
theads		mov bx,ppos
		cmp bh,0h
		jne vvf0
		mov ax,204
		cmp neuc,ax
		je got_neuc
		jmp vvf
got_neuc	mov txtadr,offset tgotem
		mov txtdur,200
		inc gotem
		mov bx,offset shfra
		mov cx,16
tcll		mov word ptr [bx],0
		add bx,8
		loop tcll		;clear explosion-area
		jmp vvf1
vvf0		cmp bh,0e8h
		jne vvf1
		cmp neuc,0
		je vvf
		mov ax,203
		cmp neuc,ax
		jne gobom
		mov neuc,0
		dec nunum
		jg usunu
		mov neuc,204
		mov txtadr,offset theeya
		mov txtdur,100
		call inc_pwr
		call inc_pwr
		call inc_pwr
		jmp vvf
usunu		mov txtadr,offset tyou
		mov txtdur,100
		jmp vvf
gobom		mov txtadr,offset twhat
		mov txtdur,100		

;		cmp pspd,0
;		jle joy_left
;		neg pspd
;		jmp joy_left
vvf
;		cmp pspd,0
;		jge joy_rite
		neg pspd
		MOV AX,PSPD
		ADD PPOS,AX
;		jmp joy_rite
vvf1


;
;evaluate PSHIPX/PSHIPY
;
		mov ax,shipy
		shl ax,1
		shl ax,1
		shl ax,1
		shl ax,1
		mov pshipy,ax
		mov ax,shipx
		add ax,80
    		shl ax,1
		shl ax,1
		shl ax,1
		shl ax,1
		add ax,ppos
		mov pshipx,ax	;PSHIPX and PSHIPY have planet coords of
				;my ship

		add gorb,3
		mov bx,offset pulist
puloop		mov al,[bx]
		cmp al,-1
		je puend
		xor ah,ah
		shl ax,1
		mov di,ax
		push bx
		mov bx,1[bx]
		mov ax,[bx]
		cmp ax,-1
		jne puloo
		mov bx,2[bx]
		mov ax,[bx]
puloo		stosw
		inc bx
		inc bx
		mov cx,bx
		pop bx
		mov 1[bx],cx
		inc bx
		inc bx
		inc bx
		jmp puloop
puend

		test lboltd,-1
		je no_blt
		dec lboltd
no_blt

		cmp gotem,0
		je sokkin
		call do_txp
		jmp vvf1
sokkin		call hasl
		mov cx,8
		mov bx,offset camdat
		mov ax,camspd
moca		cmp word ptr [bx],0
		je iinh
		add [bx],ax
iinh		inc bx
		inc bx
		loop moca
		dec camlau
		jg nolau
		mov ax,camres
		mov camlau,ax
		cmp camfr,0
		je nolau
		dec camfr
		mov bx,offset camdat
lfca		cmp word ptr [bx],0
		je gfca
		inc bx
		inc bx
		jmp lfca
gfca		mov word ptr [bx],0103h
		mov word ptr 16[bx],8192
		mov txtadr,offset tclau
		mov txtdur,100
nolau		cmp shsho,0
		je nevva
		dec shsho
nevva


;
;maintain camel-animation stuff
;

		cmp camy,0
		jl no_lau
		dec cff
		jg no_lau
		call random
		and ax,3fh
		add ax,cfba
		mov cff,ax
		call spit
		call hump
		call fire_arse
		call fire_frnt
no_lau		dec wdel
		jne no_a1
		mov ax,fleg
		and ax,15
		cmp ax,2
		jne ballgame
		cmp camy,0
		jle ballgame
		mov si,offset _stp
		mov dx,camx
		call inison
ballgame	mov ax,wspd
		mov wdel,ax
		mov ax,rleg
		mov bx,fleg
		add ax,2
		and ax,31
		mov rleg,ax
		add bx,2
		and bx,31
		mov fleg,ax
		cmp tflik,0
		je nntf
		add taph,2
		cmp taph,28
		jne no_a2
		mov taph,0
		sub tflik,1
		jne no_a2
		call random
		and al,3fh
		add al,20
		mov tdel,al
		jmp nntf 
no_a1		cmp tflik,0	;tail-flix in progress?
		jne no_a2
nntf		sub tdel,1	;inter-flick delay
		jne no_a2
		call random
		and al,3
		add al,1
		mov tflik,al		
no_a2
		mov ax,pspd
		add ppos,ax
		sub orbit,50
		mov al,byte ptr orbit+1
		cmp al,100
		jne no_raf1
		cmp rcmd,0
		jne no_raf
		mov ax,nfade
		mov t_rgen,ax
		mov rsteps,16
		mov rshfts,4
		mov rcmd,2
		mov gfade,1
		jmp no_raf

no_raf1		cmp gfade,0
		je no_raf
		cmp rcmd,0
		jne no_raf
		mov gfade,0
		mov ax,nfade
		xchg ofade,ax
		mov nfade,ax
		mov ax,ngraf
		xchg ograf,ax
		mov ngraf,ax
		


no_raf
		call run_bulls
		mov di,0
		cmp xtm,0
		jne nuxt
		jmp noxt
nuxt		cmp xts,0
		je xtrun
		dec xtd
		jg xtrun
		mov xtd,1
		call random
		and ax,3f1fh
		mov bx,offset dxps
		mov cx,8
xseek		cmp byte ptr [bx],0
		je xgot
		inc bx
		loop xseek
		jmp xtrun
xgot		inc ah
		mov [bx],ah
		inc al
		mov 8[bx],al
		mov byte ptr 16[bx],0
		mov byte ptr 24[bx],3
		dec xts
		jne xtrun
		inc xtm
		push es
		mov ax,ds
		mov es,ax
		mov si,offset icopy
		mov di,offset didat
		mov cx,16*6
xgg		movsw
		loop xgg
		pop es
		mov di,0
xtrun		mov bx,offset dxps
		mov xfin,0
		mov cx,8
xrun		cmp byte ptr [bx],0
		je xnex
		inc xfin
		dec byte ptr 24[bx]
		jne xnex
		mov byte ptr 24[bx],3
		inc byte ptr 16[bx]
		cmp byte ptr 16[bx],3
		jne xnex
		mov byte ptr [bx],0
xnex		inc bx
		loop xrun
		cmp xtm,2
		je nnix
		jmp noxt
nnix		mov cx,16
		mov xtm,0
		mov bx,offset didat
anders		cmp word ptr 160[bx],0
		jne bald
		jmp hair
bald		mov xtm,2
		mov ax,64[bx]
		add [bx],ax		;update X
		mov ax,96[bx]
		add 32[bx],ax		;update Y
		cmp word ptr 32[bx],300		;bounce level
		jl nobo
		mov ax,word ptr 96[bx]
		sar ax,1
		mov dx,ax
		sar dx,1
		add ax,dx
		neg ax
		mov word ptr 96[bx],ax
		mov word ptr 32[bx],299
nobo		cmp word ptr 128[bx],0
		jne npp
		jmp xha
npp		mov ax,[bx]
		sar ax,1
		add ax,xtx
		sub ax,shipx
		jg noh1
		neg ax
noh1		cmp ax,30
		jg aah
		mov ax,32[bx]
		sar ax,1
		sar ax,1
		add ax,40+66
		sub ax,shipy
		jg noh2
		neg ax
noh2		cmp ax,10
		jle ooh
aah		jmp nokol
ooh		mov si,offset _klek
		push bx
		mov dx,shipx
		call inison
		call inc_pwr
		pop bx
		mov word ptr 128[bx],0
		dec bcount
		jne arrest
		mov bcow,2
		mov a_blok,offset suboni
		mov a_blot,2
		mov txtadr,offset nfh
		mov txtdur,100
		cmp neuc,0
		jne arrest
		mov neuc,203
arrest		mov AX,pspd
		sar ax,1
		sar ax,1
		sar ax,1
		mov 64[bx],ax
		mov word ptr 96[bx],-2
		mov word ptr 160[bx],80
xha		jmp noacc		
nokol		dec word ptr 128[bx]
		jg noacc
		mov word ptr 128[bx],4
		cmp word ptr 96[bx],20
		je noacc
		inc word ptr 96[bx]
noacc		dec word ptr 160[bx]
hair		inc bx
		inc bx
		loop inders
		jmp noxt
inders		jmp anders
noxt		cmp xtm,0
		jne noxt1
		mov xtm,0
noxt1		call move_als
		cmp can,1
		jle nocud
		dec can
nocud		cmp h_on,0		;hump event?
		jl nohmp
		je movh
		dec h_on
		jmp nohmp
movh		dec h_d
		jg nohmp
		mov h_d,5
		cmp h_di,0
		jl hclose
		inc hmp
		cmp hmp,6
		jne nohmp
resat		call random
		and ax,3fh
		add ax,40h
		mov h_on,al
		neg h_di
		jmp nohmp
hclose		dec hmp
		je resat
nohmp		mov bx,shbpt			;do ship trail bac
		add bx,offset shipbuf
		mov ax,shipx
		mov [bx],ax
		mov ax,shipy
		mov 32[bx],ax
		sub bx,offset shipbuf
		inc bx
		inc bx
		and bx,31
		mov shbpt,bx		
		cmp txtdur,0
		je notxt1
		dec txtdur
notxt1		call rash
		call run_am
;
;terminate IRQ and go home
;


iend		xor di,di
		pop bp
		pop si
		pop dx
		pop cx
		pop bx
		xor ax,ax
;		out BORDL,ax
		pop ax
		out ACK,al
		sti
		iret

setfrap		mov cx,16
		mov bx,offset shfra
sefra		mov ax,pshipx
		mov [bx],ax
		mov ax,pshipy
		mov 32[bx],ax
		call random
		and ax,07fh
		sub ax,3fh
		add ax,pspd
		mov 64[bx],ax
		call random
		and ax,07fh
		neg ax
		mov 96[bx],ax
		inc bx
		inc bx
		loop sefra
		mov frap,160
		mov frad,200
		mov fraa,3
		mov shipx,128
		mov shipy,50
		mov shlev,32
		ret

runfrap		mov cx,16
		mov bx,offset shfra
runf		mov ax,64[bx]
		add [bx],ax
		mov ax,32[bx]
		add word ptr 96[bx],4
		mov dx,96[bx]
		add ax,dx
		cmp ax,200*16
		jl runf1
		neg word ptr 96[bx]
		sar word ptr 96[bx],1
		mov word ptr 32[bx],199*16
runf1		mov 32[bx],ax
		inc bx
		inc bx
		loop runf
		dec frad
		je fradend
		dec fraa
		je lead
eve		ret
lead		mov fraa,3
 		inc frap
		cmp frap,164
		jne eve
		mov frap,160
		ret
fradend		mov blowing,0
		ret


rash	
		cmp shxfree,16
		jne rash1
		ret
rash1		mov cx,16
		mov bx,offset shxes
rash2		cmp word ptr [bx],0
		je rash21
rash3		cmp word ptr 64[bx],0
		jg goodterm
		dec word ptr 64[bx]
		cmp word ptr 64[bx],-31
		je akill
		jmp rash21
goodterm	inc word ptr 64[bx]
gter		cmp word ptr 64[bx],31
		jne rash21
akill		mov word ptr [bx],0
		inc shxfree		
rash21		inc bx
		inc bx
		loop rash2
		ret


minizap		cmp shxfree,0
		jg bred
		ret
bred		dec shxfree
		mov bx,offset shxes
beefe		cmp word ptr [bx],0
		je thatt
		inc bx
		inc bx
		jmp beefe
thatt		mov ax,pshipx
		mov [bx],ax
		mov ax,pshipy
		mov 32[bx],ax
		mov word ptr 64[bx],1
		cmp shipp,0
		je thatt2
		ret
thatt2		mov word ptr 64[bx],-1
		ret
idoc1		jmp doc1
move_als
		test a_disabl,-1
		je do_ma
		ret
do_ma		mov bx,offset adat
m_als		cmp byte ptr [bx],0
		jne docol
		jmp n_al
noocoo		jmp nodet
docol		cmp blowing,0
		jne idoc1	
		cmp byte ptr 1[bx],0		;Viz
		je noocoo			;Nope
		cmp byte ptr 11[bx],0		;Col woth ship?
		je idoc1
		mov byte ptr 20[bx],0		;default zero
		mov ax,32[bx]
;		sub ax,ppos
;		sar ax,1
;		sar ax,1
;		sar ax,1
;		sar ax,1			;Xpos in screen ordinates
		test ax,0f00h
		je doc2
		mov byte ptr 15[bx],0
		jmp nodet
doc2
;		sub ax,80
		mov dx,34[bx]
;		sar dx,1
;		sar dx,1
;		sar dx,1
;		sar dx,1
		mov si,16[bx]			;get X size
		add si,21			;add ship/2
		sub ax,shipx			;diff tween bullet and ship
		jge polar
		neg ax
polar		cmp ax,si			;in X rect?
		jl hitx1
scof		jmp doc1
hitx1   	mov si,18[bx]			;get Y size
		add si,7			;plus shipy/2
		sub dx,shipy
		jge polar1
		neg dx
polar1		cmp dx,si
		jg scof
hytx1
;		will be call to init_shipzap
		cmp word ptr 66[bx],0			;any Shield Damage?
		je no_shd
		mov ax,word ptr 66[bx]
		sub shlev,ax			;damage shield
		push bx
		call gbolt
		call dec_pwr
		pop bx
		mov txtadr,offset twspr
		mov txtdur,50

		cmp blowing,0
		jne iblo
		mov si,offset _hus
		mov dx,shipx
		call inison
;		neg pspd			;(bounce ship?)
iblo		push bx
		call minizap
		pop bx
no_shd		mov byte ptr 20[bx],1		;flag - hit ship				




doc1		cmp byte ptr 14[bx],0
		jne doc3
		jmp nodet
doc3		cmp bx,calend
		jge russh
		mov byte ptr 15[bx],0		;result, default zero
		mov ax,32[bx]			;get X pos
		test ax,0f00h			;onscreen?
		je docol1			;yes
russh		jmp nodet			;no, go past dcol
docol1
		mov dx,34[bx]			;bullet Y pos
		mov bp,16[bx]			;get X size

   		mov di,18[bx]			;get Y size
		mov si,offset bulls		;point to bullet DS
		push bx
zingo		mov bl,byte ptr [si]
		cmp bl,0		;active bullet?
		je zingun			;no, sod off!
		cmp bl,2
		je zingun
;		mov bx,1[si]
		cmp bl,10			;Special - laser
		jne zorbo
		pop bx
		push bx
		cmp bx,6[si]
		jne zingun
		mov bl,[si]
		dec bfree
		jmp vanis		
zorbo		mov bl,1[si]
		xor bh,bh
		sub bx,ax			;get X difference
		jg jaygee
		neg bx
jaygee
;		mov cx,12[si]
		mov cl,12[si]
		xor ch,ch
		add cx,bp			;X col overlap value
		cmp bx,cx
		jl yupx
zing
zingun		add si,28
		cmp si,bullen
		jne zingo
		pop bx
		jmp nodet
yupx
;		mov bx,3[si]			;Y bullet
		mov bl,3[si]
		xor bh,bh
		sub bx,dx
		jg jaygee1
		neg bx
jaygee1
;		mov cx,14[si]
		mov cl,14[si]
		xor ch,ch
		add cx,di
		cmp bx,cx
		jge zing			;Fail
hytx		mov bl,[si]
		mov byte ptr [si],0
vanis		xor bh,bh
		sal bx,1
		add bx,offset bdamt
		mov di,[bx]			;Get bullet type damage
;		inc bfree
		pop bx
		sub 82[bx],di			;Damage that alien
		jl usux
		cmp byte ptr [si],10
		je usux
		mov byte ptr [si],2
		mov word ptr 5[si],0
		mov byte ptr 7[si],4		;init bullet xplode
		mov word ptr 8[si],0		;bullet fragment offset
		jmp nosix
usux		inc bfree
nosix		mov byte ptr 15[bx],1		;flag - hit bullet				

nodet		mov al,byte ptr [bx]
		xor ah,ah
		sal ax,1
		push bx
		mov bx,offset movevex
		add bx,ax
		mov ax,[bx]
		pop bx
		jmp ax
n_al		add bx,128
		cmp bx,alend
		jne m_il
		ret
m_il		jmp m_als

acont
		mov si,126[bx]		;get Ctrl Blok address
		mov ax,2[bx]
		add ax,6[bx]
		mov 2[bx],ax
		mov ax,4[bx]
		add ax,8[bx]
		mov 4[bx],ax		;Move alien's position
		mov cx,18[bx]		;get Y halfsize
		sal cx,1
		cmp ax,cx
		jge ntopp
		cmp word ptr 18[si],0
		je toc_h
		push si
		mov si,18[si]
		call xcmd		;execute Hit Top code
		pop si
		jmp toc_h
ntopp		neg cx
		add cx,200*16
		cmp ax,cx
		jl toc_h
		cmp word ptr 20[si],0
		je toc_h
		push si
		mov si,20[si]
		call xcmd
		pop si
toc_h
		cmp word ptr 36[bx],0		;Horiz accel set?
		je nhac
		mov dx,36[bx]
		mov al,72[bx]		;get X max speed
		cbw			;sign-extend
		cmp ax,6[bx]		;check against current X vel
		je nhac			;already at veloc	
		jg do_innc		;less than, increment
		sub 6[bx],dx
		jmp nhac		;done horiz. axxeleration
do_innc		add 6[bx],dx
nhac 
		cmp word ptr 38[bx],0		;Vert accel set?
		je nvac
		mov dx,38[bx]
		mov al,73[bx]		;get y max speed
		cbw			;sign-extend
		cmp ax,8[bx]		;check against current y vel
		je nvac			;already at veloc	
		jg do_inn		;less than, increment
		sub 8[bx],dx
		jmp nvac
do_inn		add 8[bx],dx
nvac		cmp byte ptr 64[bx],0	;Animated, this?
		je no_ani
		dec byte ptr 50[bx]	;do IFD
		jne no_ani
		mov al,53[bx]
		mov 50[bx],al		;re-set IFD
		mov al,64[bx]		;get add value
		add 51[bx],al		;update frame
		je ant			;zero, turning point
		mov al,52[bx]
		cmp 51[bx],al		;check upper bound
		jne no_ani		;not yet reached
ant		cmp byte ptr 54[bx],1	;what type?
		jne notosc
		neg byte ptr 64[bx]	;cyclic; negate step value
		jmp no_ani
notosc		jl ramp
		mov byte ptr 64[bx],0	;one-shot; stop cycle
		cmp word ptr 16[si],0
		je no_ani
		push si
		mov si,16[si]
		call xcmd
		pop si			;execute 1SHOTFIN
		jmp no_ani
ramp		mov byte ptr 51[bx],0
no_ani		cmp word ptr 22[si],0	;Timer 1 run?
		je notim1
		dec byte ptr 40[bx]	;dec Timer 1
		jne notim1
		mov al,44[bx]
		mov 40[bx],al		;reset Timer 1
		push si
		mov si,22[si]
		call xcmd
		pop si			;execute Timer 1 code
notim1		cmp word ptr 24[si],0	;Timer 2 run?
		je notim2
		dec byte ptr 41[bx]	;dec Timer 2
		jne notim2
		mov al,45[bx]
		mov 41[bx],al		;reset Timer 2
		push si
		mov si,24[si]
		call xcmd
		pop si
notim2		cmp word ptr 26[si],0
		je notim3
		dec byte ptr 42[bx]
		jne notim3
		mov al,46[bx]
		mov 42[bx],al
		push si
		mov si,26[si]
		call xcmd
		pop si
notim3		cmp word ptr 2[si],0	;what if it hit us...
		je nohy
		cmp byte ptr 20[bx],1	;did it then?
		jne nohy
		push si
		mov si,2[si]
		call xcmd
		pop si			;yeah, doit toit
nohy		cmp word ptr 4[si],0	;special Viz stuff?
		je no_vizz		;nope
		cmp byte ptr 1[bx],0	;viz?
		je no_vizz		;nope
		push si
		mov si,4[si]
		call xcmd
		pop si
		jmp izviz		;no point in next checc
no_vizz		cmp word ptr 6[si],0	;special if NOT Viz?
		je no_v2
		cmp byte ptr 1[bx],0
		jne no_v2
		push si
		mov si,6[si]
		call xcmd
		pop si
		jmp vizok
no_v2		cmp byte ptr 1[bx],0	;turn senses only if viz..
		jne izviz
		jmp vizok
izviz		mov dx,74[bx]		;X Turn Detect Sense
		cmp dx,0		;valid?
		je no_xtrn		;No
		mov ax,pshipx		;get ship X ppos
		sub ax,2[bx]		;get alien offset from ship
		jl l_ship
		cmp ax,dx
		jg no_xtrn		;within sense range?
		cmp ax,78[bx]		;low range
		jl no_xtrn
		push si
		mov si,14[si]			
		call xcmd
		pop si
		jmp no_xtrn
l_ship		neg ax
		cmp ax,dx
		jg no_xtrn
		cmp ax,78[bx]
		jl no_xtrn
		push si
		mov si,12[si]
		call xcmd
		pop si
no_xtrn		mov dx,76[bx]		;Y Turn Detect Sense
		cmp dx,0		;etc...
		je no_ytrn
		mov ax,pshipy
		sub ax,4[bx]
		jl u_ship
		cmp ax,dx
		jg no_ytrn
		cmp ax,80[bx]
		jl no_ytrn
		push si
		mov si,8[si]
		call xcmd
		pop si
		jmp no_ytrn
u_ship		neg ax
		cmp ax,dx
		jg no_ytrn
		cmp ax,80[bx]
		jl no_ytrn
		push si
		mov si,10[si]
		call xcmd
		pop si
no_ytrn		cmp byte ptr 15[bx],0	;Damaged this go?
		je vizok		;No
		cmp word ptr 82[bx],0	;Killed?
		jle i_kill		;Yes
		cmp word ptr 28[si],0	;Action if winged?
		je vizok		;No
		push si
		mov si,28[si]
		call xcmd
		pop si			;Execute winged stuff
		jmp vizok
i_kill
		push si			;Must be action if killed!
		mov ax,124[bx]		;get possible score
		call skorit
		mov dx,32[bx]
		mov si,offset _hit
		call inison
		mov rasxp,offset eshit
		pop si
		push si
		mov si,[si]
		call xcmd
		pop si
		jmp n_al		;If killed, no more stuff
vizok		cmp byte ptr 62[bx],0	;running sine?
		je noxxsi
		mov al,62[bx]
		cbw
		add 56[bx],ax
noxxsi		cmp byte ptr 63[bx],0
		je noyysi
		mov al,63[bx]
		cbw
		add 58[bx],ax
noyysi		cmp byte ptr 47[bx],0
		jl noshotz
		dec byte ptr 46[bx]
		jg noshotz
		mov al,47[bx]
		mov 46[bx],al
		push si
		mov si,30[si]
		call xcmd
		pop si
noshotz		jmp n_al 

mshot		cmp byte ptr 20[bx],0		;been hit?
		jne kilal
		mov ax,2[bx]
		add ax,6[bx]
		mov 2[bx],ax
		mov ax,4[bx]
		add ax,8[bx]
		mov 4[bx],ax
		cmp ax,-64
		jl tall
		cmp ax,200*16
		jg tall
		cmp byte ptr 1[bx],0
		je tall
		jmp n_al
tall		jmp term_al
kilal		jmp kill_al

smmo		
		mov ax,6[bx]
		add 2[bx],ax
		sub word ptr 4[bx],16
		cmp word ptr 4[bx],-160
		jl tall
		jmp n_al

kal		mov byte ptr [bx],2		;Set up
		mov byte ptr 12[bx],1
		mov byte ptr 11[bx],0
		mov byte ptr 14[bx],0		;an EXPLOSION!
		mov word ptr 20[bx],137
		mov byte ptr 22[bx],3
		mov byte ptr 23[bx],100
		mov word ptr 24[bx],0
		mov word ptr 26[bx],0		;offsets for explode frags!
		call random
		and ax,0303h
		mov dl,ah
		xor ah,ah
		xor dh,dh
		sub ax,1
		jne ikal
		dec ax
ikal		cmp dx,0
		jne ikal1
		inc dx
ikal1		cmp word ptr 4[bx],1024
		jl jugg
		neg dx
jugg		mov 28[bx],ax
		mov 30[bx],dx
		ret


kill_al		call kal
fex		jmp n_al

mrezin		dec byte ptr 24[bx]
		jne fex
		mov al,25[bx]
		mov 14[bx],al		;set VUL
		mov al,26[bx]
		mov 11[bx],al		;set SHIPCOL
		mov al,27[bx]
		mov [bx],al		;and Alien Type
		mov byte ptr 12[bx],4
		ret

mex		dec byte ptr 22[bx]
		jg mex1
		mov byte ptr 22[bx],3
		cmp byte ptr 20[bx],140
zuluz		je mex1
		inc word ptr 20[bx]
mex1		mov ax,28[bx]
		add 24[bx],ax
		mov ax,30[bx]
		add 26[bx],ax
		dec byte ptr 23[bx]
		jg fex
term_al		mov byte ptr [bx],0
		cmp bx,calend
		jge term_en
		inc afree
		jmp n_al
term_en		inc pfree
		jmp n_al

wilau		cmp bfree,0
		jg willi
		jmp no_fire
willi		call bseek

		mov byte ptr [bx],7
		mov word ptr 7[bx],6
		mov cx,shipx
		add cx,20
		cmp dl,0
		je willi1
		sub cx,40
		neg word ptr 7[bx]
willi1		mov 1[bx],cx
		mov cx,shipy
		add cx,3
		mov 3[bx],cx
		mov word ptr 12[bx],3
		mov word ptr 14[bx],20
		mov si,offset _wyd
		mov dx,shipx
		call inison
		jmp done_f 

zzapl		mov cx,4
		cmp bfree,0
		jg zzak1
zzak0		jmp done_f
zzak1		mov si,offset adat
zzak2		test byte ptr 1[si],-1
		jne zap_one
fokl
		add si,128
		cmp si,calend
		jl zzak2
		cmp camy,0
		jl zjh
yess		call bseek
		mov byte ptr [bx],10
		mov dx,camx
		add dx,30
		mov 1[bx],dx
		mov dx,camy
		add dx,20
		mov 3[bx],dx
		mov byte ptr 5[bx],6
		mov word ptr 6[bx],-1
		mov byte ptr 8[bx],1
		mov si,offset _sml
		mov dx,shipx
		call inison
		cmp afree,0
iz1		je zzak0
		loop yess
zjh		jmp done_f

zap_one
		test byte ptr 14[si],-1
		je fokl
		call bseek		
		mov dx,2[si]
		mov 1[bx],dx		;X aim point
		mov dx,4[si]
		mov 3[bx],dx
		mov byte ptr [bx],10	;Type: scan laser
		mov byte ptr 5[bx],6	;Duration: 6
		mov 6[bx],si		;Address of alien we zapping
		mov byte ptr 8[bx],0	;Type abs co-ordinates

		cmp bfree,0
		je iz1
atermm		loop zzaak
		jmp done_f 				
		
zzaak		jmp fokl
sprlau
		cmp bfree,5
		jge gslok		;no bullets free
		jmp no_fire
gslok		mov cx,5
		mov bx,offset bvos
slok		push cx
		push bx
		call bseek		;get BX pointing to bullet
		mov cx,shipx
		mov byte ptr [bx],3
		mov 1[bx],cx
		mov cx,shipy
		add cx,3
		mov 3[bx],cx
		mov word ptr 7[bx],7		;X vel
		cmp dl,0
		je ffi2
		neg word ptr 7[bx]
ffi2		mov word ptr 9[bx],0		;Y vel
		mov word ptr 12[bx],6
		mov word ptr 14[bx],8
		mov cx,bx
		pop bx
		mov si,[bx]
		inc bx
		inc bx
		push bx
		mov bx,cx
		mov cx,si
		mov 11[bx],cl
		pop bx
		pop cx
		loop slok
		mov si,offset _veeb
		mov dx,shipx
		call inison
		jmp done_f

lalau		cmp bfree,0
		jg dlala
		jmp no_fire
dlala
		call bseek		;get BX pointing to bullet
		mov cx,shipx
		mov byte ptr [bx],5
		cmp dl,0
		je ffik
		sub cx,71
ffik		mov 1[bx],cx
		mov cx,shipy
		add cx,2
		add cx,lazo
		xor lazo,2
		mov 3[bx],cx
		mov word ptr 7[bx],6		;X vel
gdirc		cmp dl,0
		je ffi3
		neg word ptr 7[bx]
ffi3		mov word ptr 5[bx],0	; lazer phase
		mov word ptr 12[bx],41
		mov word ptr 14[bx],1
		mov si,offset _laza
		mov dx,shipx
		call inison
		jmp done_f

synl		cmp bfree,1
		jge sinl1
		jmp no_fire
sinl1		call bseek
		mov cx,shipx
		mov 1[bx],cx
		mov byte ptr [bx],9
		mov cx,shipy
		add cx,3
		mov 3[bx],cx
		mov word ptr 7[bx],4
		mov al,syna
		mov byte ptr 11[bx],al
		xor syna,128
		mov word ptr 12[bx],6
		mov word ptr 14[bx],5
		cmp dl,0
		je nii
		neg word ptr 7[bx]
nii		mov si,offset _tway
		mov dx,shipx
		call inison
		jmp done_f


bulla		cmp bfree,4
		jge fala
		jmp no_fire
fala		mov ax,4
fala1		call bseek
		mov cx,shipx
		mov 1[bx],cx
		mov byte ptr [bx],8
		mov cx,shipy
		add cx,3
		mov 3[bx],cx
		mov word ptr 7[bx],ax
		mov word ptr 12[bx],12
		mov word ptr 14[bx],5
		cmp dl,0
		je nofff
		neg word ptr 7[bx]
nofff		add ax,2
		cmp ax,12
		jne fala1
		mov si,offset _brst
		mov dx,shipx
		call inison
		jmp done_f

falau		cmp bfree,2
		jge bala
		jmp no_fire
bala
		call bseek
		mov cx,shipx
		mov 1[bx],cx
		mov byte ptr [bx],1
		mov dx,shipy
		add dx,3
		mov 3[bx],dx
		mov word ptr 7[bx],6
		mov word ptr 12[bx],17
		mov word ptr 14[bx],5
		call bseek
		mov 1[bx],cx
		mov 3[bx],dx
		mov word ptr 7[bx],-6
		mov byte ptr [bx],1
		mov word ptr 12[bx],9
		mov word ptr 14[bx],3
		mov si,offset _zap
		mov dx,shipx
		call inison
		jmp done_f


roblau		cmp bfree,4
		jge robgau
		jmp no_fire
robgau		mov cx,4
		mov bl,gorb
		xor bh,bh
		add bx,offset sine
		push ax
robi		push cx
		mov al,[bx]
		cbw
		sar ax,1
		sar ax,1
		add ax,shipx
		mov cx,ax
		sub bx,offset sine
		add bx,40h
		and bx,0ffh
		add bx,offset sine
		mov al,[bx]
		cbw
		sar ax,1
		sar ax,1
		add ax,shipy
		push bx
		call bseek
		mov 1[bx],cx
		mov 3[bx],ax
		mov byte ptr [bx],6
		mov word ptr 7[bx],5
		cmp dl,0
		je ffi5
		neg word ptr 7[bx]
ffi5		mov word ptr 12[bx],13
		mov word ptr 14[bx],10
		pop bx
		pop cx
		loop robi
		pop ax
		mov si,offset _fhb
		mov dx,shipx
		call inison
		jmp done_f
		

balau		cmp bfree,3
		jge balok
		jmp no_fire
balok		mov cx,3
		mov bp,offset baos
sloth		push cx
		push dx
		call bseek
		mov cx,shipx
		mov byte ptr [bx],4
		mov 1[bx],cx
		mov dx,shipy
		add dx,3
		mov 3[bx],dx
		mov word ptr 12[bx],6
		mov word ptr 14[bx],10
		mov si,bx
		mov bx,bp
		mov cx,[bx]
		mov dx,2[bx]
		add bx,4
		mov bp,bx
		mov bx,si
		mov 9[bx],dx
		mov 7[bx],cx
		pop dx
		cmp dl,0
		je dontneg
		neg word ptr 7[bx]
dontneg	
		pop cx
		loop sloth
		mov si,offset _tway
		mov dx,shipx
		call inison
		jmp done_f

wcon
;
;Do selective enable of stuff off joy 2
;
		in al,50h	;get Joy2 status
		xor al,-1
		test al,4	;test Button 1
		je no_b1
		mov irqmode,4	;pause
		call idsp
noata		ret
no_b1		test al,8	;but 2
		je no_b2
		mov irqmode,0	;unpause
		ret
no_b2		test al,64
		je no_b3
		mov s_disabl,1	;disable sonix
		call idsp
		ret
no_b3		test al,128
		je no_b4
		mov s_disabl,0	;enable	sonix 
		ret
no_b4		test al,32
		je no_b5
		mov a_disabl,1	;disable ACONT
		ret
no_b5		test al,16
		je noata
		mov a_disabl,0	;enable ACONT

skip_joy2:	ret


skorit
;
;Add score in ax to our score
;Trashes SI
;
		cmp ax,0
		jne do_score
		ret
do_score
		mov si,offset score
		mov dl,al
		xor dh,dh
		add si,dx		;Point to digit
_score		push si
		mov cx,bmv
_sk		add [si],cl
		cmp byte ptr [si],10	;rollover?
		jl _scor1
		sub byte ptr [si],10
		mov cl,1
		dec si
		jge _sk
_scor1		pop si
		dec ah
		jge _score
		ret
ret
		
		
		 
run_bulls
;
;Run all active bullets to termination
;
		mov bx,offset bulls

runb
		mov dl,[bx]
		xor dh,dh
		xchg dx,bx
		shl bx,1
		add bx,offset bulrun
		mov ax,[bx]
		xchg bx,dx
		jmp ax
;
;Run bullet type 1
;


zeek		jmp nexb
beek		jmp bkill
stdbul	
		mov dx,1[bx]
		add dx,7[bx]		
		cmp dx,-20
		jle beek
		cmp dx,256
		jg beek
		mov 1[bx],dx
camdet		mov ax,camy
		cmp ax,0
		jl zeek			;do detecol on any displayed camel
		mov ax,3[bx]		;get bullet 'y'
		mov cx,14[bx]		;bullet's halfsize Y
		add cx,25		;half camel height
		sub ax,75+66		;camel centered origin
		jg camd1
		neg ax
camd1		cmp ax,cx		;within limit?
		jg zeek			;no

;		cmp ax,50
;		jl zeek
;		cmp ax,90
;		jg zeek
;		mov ax,camx
;		cmp ax,dx
;		jg zeek
;		add ax,64
;		cmp ax,dx
;		jl zeek

		mov ax,1[bx]		;bullet X position
		mov cx,12[bx]		;X halfsize bullet
		add cx,25		;X halfsize camel
		sub ax,camx		;Uncentred camel origin
		sub ax,25
		jg camd2
		neg ax
camd2		cmp ax,cx
		jg zeek			;Leave if out of range
hcam		mov shsho,20
		push bx
		mov si,offset _pow
		call inison
		mov cl,[bx]
		xor ch,ch
		mov bx,cama
		add bx,offset camdat
		mov si,offset bdamt
		sal cx,1
		add si,cx		;Get bullet strength
		mov cx,[si]
		mov ch,cl
		xor cl,cl
		sar cx,1		;x64
		sar cx,1
		sub 16[bx],cx
		jg lokk
		mov a_blok,offset boni
		mov a_blot,2
		mov si,offset _camkil
		mov dx,camx
		call inison
;		call inc_pwr
;		call inc_pwr
;		call inc_pwr
		mov cx,[bx]
		mov word ptr [bx],0
		mov kcpos,cx
		mov cx,rleg
		mov kfr,cx
		mov cx,fleg
		mov kff,cx
		mov cx,taph
		mov ktp,cx		;kill camel?
		inc camfr
		mov camy,-1
		mov eqdur,30
		mov xts,20
		mov xtm,1
		mov bcow,0
		mov bcount,16
		jmp oga
lokk		mov bx,16[bx]
		mov bl,bh
		xor bh,bh
		shr bx,1
		and bx,03eh
		add bx,offset camscol
		mov cx,[bx]
		mov bx,116
		mov word ptr es:[bx],cx
oga		pop bx
		jmp b_xp
nexb
		add bx,28
		cmp bx,bullen
		jne zigi
		ret
zigi		jmp runb

bkill	
		mov byte ptr [bx],0
		inc bfree
rivva		jmp nexb

zzapr	
		dec byte ptr 5[bx]
		jne aaz
		jmp bkill		
aaz		cmp word ptr 6[bx],0
		jge rivva
		cmp camy,0
		jle rivva
		jmp hcam
explo	
		cmp word ptr 8[bx],0
		jge perfo
		dec byte ptr 7[bx]
		jg jinc
		mov byte ptr 7[bx],4
		inc word ptr 5[bx]
		cmp word ptr 5[bx],3
		je jink
		jmp nexb
perfo		dec byte ptr 7[bx]
		jg justinc
		mov byte ptr 7[bx],4
		cmp word ptr 5[bx],3
		je justinc
		inc word ptr 5[bx]
justinc		inc word ptr 8[bx]
		cmp word ptr 8[bx],60
jinc		jne nexb
jink		jmp bkill

b_xp	
		cmp byte ptr [bx],10
		je ordr		
		mov byte ptr [bx],2
		mov word ptr 5[bx],0
		mov byte ptr 7[bx],4
		mov word ptr 8[bx],-1
ordr		jmp nexb

wibul	 	mov dx,1[bx]
		add dx,7[bx]		
		cmp dx,-20
		jle wino
		cmp dx,256
		jg wino
		mov 1[bx],dx
		mov ax,camy
		cmp ax,0
		jl wiok			;do detecol on any displayed camel
		mov ax,3[bx]
		cmp ax,30+66
		jl wiok
		cmp ax,110+66
		jg wiok
		mov ax,camx
		cmp ax,dx
		jg wiok
		add ax,64
		cmp ax,dx
		jge wiblo
wiok		jmp nexb
wino		jmp bkill
wiblo		jmp hcam
synrun		mov cx,bx
		add byte ptr 11[bx],16
		mov al,11[bx]
		xor ah,ah
		mov bx,offset sine
		add bx,ax
		mov al,[bx]
		cbw
		sar ax,1
		sar ax,1
		sar ax,1
		sar ax,1
		sar ax,1
		mov bx,cx
		add 3[bx],ax
		jmp stdbul	
spread
		mov al,11[bx]
		cmp al,0
		jg godow
		jl gowup
		jmp stdbul
godow		sub byte ptr 11[bx],1
		add word ptr 3[bx],3
		jmp camdet
gowup		add byte ptr 11[bx],1
		sub word ptr 3[bx],3
		jmp camdet		

balls		
		mov ax,7[bx]		;get X vel
		mov cx,9[bx]		;get Y vel
		add 3[bx],cx		;update y
		add 1[bx],ax		;update x
		mov dx,1[bx]
		cmp dx,-20
		jl ovaa
		cmp dx,256
		jg ovaa
		jmp camdet
ovaa		jmp bkill

laze		
		mov ax,5[bx]
		cmp ax,1
		je usu_laze
		add word ptr 5[bx],1
		cmp word ptr 7[bx],0
		jg noah
		sub word ptr 1[bx],10		;only left facing laser does this
noah		jmp lazen
usu_laze	mov ax,7[bx]
		add 1[bx],ax
		mov ax,1[bx]
		cmp ax,-120
		jl laki
		cmp ax,255
		jl lazen
laki		jmp bkill
lazen		mov ax,camy
		cmp ax,0
		jl lazn			;do detecol on any displayed camel
		mov ax,3[bx]
		cmp ax,50+66
		jl lazn
		cmp ax,90+66
		jg lazn
		mov ax,camx
		mov dx,1[bx]
		cmp ax,dx
		jl lazn
		add ax,64
		add dx,81
		cmp ax,dx
		jg lazn
		cmp word ptr 7[bx],0
		jl noaah
		sub ax,64
noaah		mov 1[bx],ax
		jmp hcam

lazn		jmp nexb
		
dfall		mov al,shipp		;decelerate - no thrust
		cmp al,0		;get ship orient
		jne fall_rite		;not left
		mov ax,60
		cmp shipx,ax
		jle fall_done
		sub shipx,1
		add ppos,16
		jmp fall_done
fall_rite	cmp al,4
		jne fall_done
		mov ax,200
		cmp shipx,ax
		jge fall_done
		add shipx,1
		sub ppos,16
fall_done	ret

bseek		mov bx,offset bulls
gagg		cmp byte ptr [bx],0
		je bgot
		add bx,28
		jmp gagg
bgot		sub bfree,1		;get and de-allocate free bull.
		ret


do_txp
;
;do terminal-explosions on enemy base
;

		call random
		and ax,3
		sub ax,2
		mov scro,ax
		dec xd
		jne yes1
		mov xd,3
		inc eboff
		cmp eboff,88
yes		je yes
yes1		mov cx,16
		mov si,offset shfra
lookfor		cmp word ptr [si],0
		je gotfor
		add si,10
		loop lookfor
		jmp doxx
gotfor		call random
		and ax,7fffh		;ah will be y-position
		mov dl,ah
		xor dh,dh
		add dx,30
		mov bl,eboff
		xor bh,bh
		add dx,bx
		mov 2[si],dx
		xor ah,ah
gfl		cmp ax,tedge
		jl gfl1
		sar ax,1
		jmp gfl
gfl1		inc ax
		mov [si],ax
		mov word ptr 4[si],0
		mov word ptr 6[si],4
		mov word ptr 8[si],0
doxx		mov cx,16
		mov si,offset shfra
doxxy		cmp word ptr [si],0
		je notu1
		inc word ptr 8[si]
		cmp word ptr 8[si],10
		jge dikk
		dec word ptr 6[si]
		jne notu1
		mov word ptr 6[si],4
		inc word ptr 4[si]
		jmp notu1
dikk		mov word ptr [si],0
notu1		add si,10
		loop doxxy
		cmp rasxp,0
		je setyt
		ret
setyt		mov rasxp,offset termf
		ret
		

print
;
;This routine should be passed the address of a string in [bx].
;The string will be scanned and printed according to the PCHAR
;routine.
;
;Scan codes implemented are \r,\g,\e
;
		push bx		;save, checking word length
		mov cx,txtx	;word length counter
wscan		xor ah,ah
		mov al,[bx]	;get character
		cmp al,'\'	;cmd?
		je enppo	;yes, end pre-proc OK
		cmp al,' '
		je enppo	;space,hooray!
		push bx
		sub al,32
		add al,cfb	;sprite number
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		mov al,[bx]	;sprite width
		xor ah,ah
		add cx,ax
		pop bx
		inc bx		;next character
		cmp cx,txmax	;greater than xmax?
		jle wscan	;loop length of word
nlin		mov cx,retst	;get return column
		mov txtx,cx	;reset text
		mov cx,txty	;current line
		add cx,cfv	;add current height this font
		mov txty,cx
		cmp cx,tymax	;bottom-of-page?
		jle enppo	;OK
		pop bx		;get back nonzero BX
		ret
enppo		pop bx		;clear to go
wloop		mov al,[bx]	;re-get character
		cmp al,'\'
		je dcmd		;go do command if told to
		call pchar	;print the char in al
		cmp al,' '	;'space'?
		jne nchar
		inc bx
		jmp print
nchar		inc bx
		jmp wloop
dcmd		inc bx
		mov al,[bx]	;get cmd letter
		cmp al,'e'	;END?
		jne n_end
		mov bx,0	;flag for successful print finish
		ret
n_end		cmp al,'r'	;CR?
		jne n_cr
		inc bx
		push bx
		jmp nlin	;use word wrap CR code		
n_cr		cmp al,'g'	;GoTo?
		jne n_go
		inc bx
		mov al,[bx]
		xor ah,ah
		mov txtx,ax
		mov retst,ax
		inc bx
		mov al,[bx]
		mov txty,ax
		jmp nchar
n_go		ret

pchar
;
;print the character in AL. preserves ax,bx
;
		push ax
		push bx
		sub al,32
		add al,cfb	;sprite number
		mov dl,al	;save it
		xor ah,ah
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		mov al,[bx]	;sprite width
		xor ah,ah
		mov cx,txtx
		add txtx,ax	;add width o'letter
		mov al,dl	;retrieve sprite no.
		mov bx,cx
		mov cx,txty
		push ax		;save sprite no.
		push bx		;and xpos
		call usprite	;print on ascreen
		pop bx
		pop ax
		mov cx,ascreen
		push cx
		mov cx,bscreen
		mov ascreen,cx
		mov cx,txty
		call usprite	;print on other screen
		pop bx
		mov ascreen,bx	;restore proper Ascreen
		pop bx
		pop ax
		ret 		


usprite
;
;Same as SPRITE but doesn't use the buffer
;
		call sprite
		ret

tsprite
;
;Make a Textsprite, centered around (ax,cx). Pass addr. of text
;in bx, null-terminated. Set CFB (font base) and XF (expansion factor)
;
		xor dx,dx	;Sprite Length counter
		push ax
		push cx		;Save these, for later
		push bx		;save string-start
tsp		mov al,[bx]	;get that char
		cmp al,0	;term.		
		je drts
		push bx
		sub al,32
		add al,cfb
		xor ah,ah
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		mov al,[bx]
		xor ah,ah
		add dx,ax	;add to Total Length
		add dx,xf	;and that Expansion Factor
		pop bx
		inc bx
		jmp tsp		;loop until end of string
drts		pop bx
		pop cx
		pop ax		;get Xpos
		sar dx,1	;halve xsize
		sub ax,dx	;gen true X start
		mov dx,ax	;put Xpos in dx
drt_l		mov al,[bx]
		cmp al,0
		je Coke_can
		push bx
		sub al,32
		add al,cfb	;sprite number
		xor ah,ah
		push ax
		push cx
		push dx
		mov bx,dx	;set up for a SPRITE op
		call sprite
		pop dx
		pop cx
		pop ax		;restore goodies
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		mov al,[bx]	;sprite width
		xor ah,ah
		add dx,ax	;update it
		add dx,xf
		pop bx
		inc bx
		jmp drt_l
Coke_can	ret		

qtsprite
;
;Uncentred Text-sprite for speed
;

		mov dx,ax	;put Xpos in dx
drt_l3		mov al,[bx]
		cmp al,0
		je Coke_can
		push bx
		sub al,32
		add al,cfb	;sprite number
		xor ah,ah
		push ax
		push cx
		push dx
		mov bx,dx	;set up for a SPRITE op
		call rsprite
		pop dx
		pop cx
		pop ax		;restore goodies
		rol ax,1
		rol ax,1
		rol ax,1
		mov bx,offset sinfo
		add bx,ax
		mov al,[bx]	;sprite width
		xor ah,ah
		add dx,ax	;update it
		add dx,xf
		pop bx
		inc bx
		jmp drt_l3
		ret

set_fade
;
;enter with colour in ax,level in dx
;returns colour in ax; uses dx
;
		cmp dx,15	;trap obvious cases
		je Coke_can	;unaltered if maximum
		cmp dx,0
		jne do_fade
		xor ax,ax	;return zero if colour level 0
		ret
do_fade		mov cx,ax	;working copy of colour
		and cx,0fh	;get blue component
		cmp cx,dx	;check against desired level
		jle fad_1	;leave if less or equal
		mov cx,dx	;chop to level if greater
fad_1		rol dx,1
		rol dx,1
		rol dx,1
		rol dx,1	;align comparator
		mov ch,ah	;save top nybble
		and ax,0f0h
		cmp ax,dx	;do compare
		jle fad_2
		or cx,dx	;or in green cmpnt
		jmp fad_21
fad_2		or cx,ax	;put in true green
fad_21		mov ah,ch	;re-get top nybble
		xor ch,ch	;clear where it was
		and ax,0f00h
		rol dx,1
		rol dx,1
		rol dx,1
		rol dx,1	;align comparator to red
		cmp ax,dx
		jle fad_3
		or cx,dx
fadfin		mov ax,cx	;return colour
		ret
fad_3		or cx,ax
		jmp fadfin	;done fade

xfur
;
;Transfer cx colours from [bx], fade level dx, start colour ax
;
		rol ax,1		;make colour num into word index
		mov di,ax	;index into h/w palette
		add bx,ax	;point to initial colour
xfur_l		mov ax,[bx]	;get colour
		push bx
		push cx
		push dx		;preserve count etc
		call set_fade
		stosw		;put into palette
		pop dx
		pop cx
		pop bx
		inc bx
		inc bx
		loop xfur_l	;xfer all coliurs
		xor di,di
		ret
		
tween
;
;routine used by colour-transition code. enter with cl=shift count
;ch=current transition point,ax=colour <from>,dx=colour<to>
;returns dx=transient colour
;
		cmp ch,0	;check for trivial cases
		jne tw_1	;origin colour kept
		mov dx,ax	;return col start
		ret
tw_1		xor di,di	;use di to hold result
		xchg dx,di	;preserve dx in di
		mov dx,di
		push ax		;save original values
		and al,0fh
		and dl,0fh	;get blue cmpnt.
		sub dl,al	;generate delta
		mov al,dl	;get delta in right place
		imul ch		;multiply by current transit point
		sar ax,cl	;divide by power-of-2
		pop dx
		push dx
		and dx,0fh	;original colour
		add dx,ax	;add in transition value
		xchg dx,di	;done blue component, store & get DX
		pop ax		;got DX and AX back ready for green

		push dx
		push ax		;save originals again
		and ax,0f0h
		and dx,0f0h	;get green component
		shr ax,1
		shr ax,1
		shr ax,1
		shr ax,1
		shr dx,1
		shr dx,1
		shr dx,1
		shr dx,1	;make nybble low
		sub dl,al	;just as before...
		mov al,dl
		imul ch
		sar ax,cl
		pop dx
		push dx
		and dx,0f0h	;standby to cop green comp.
		sal ax,1
		sal ax,1
		sal ax,1
		sal ax,1	;shift t'high nybble
		add dx,ax	;add to original level
		or di,dx	;OK

		pop ax
		pop dx		;get back originals
		push ax
		xchg ah,al
		xchg dh,dl	;get high nybbles of each (red)
		sub dl,al	;same ol' code
		mov al,dl
		imul ch
		sar ax,cl
		pop dx
		xchg dh,dl
		xor dh,dh
		add dx,ax
		and dx,0fh
		xchg dh,dl	;place hi nybble
		or dx,di	;place whole colour
		xor di,di	;clear di-no flicker
		ret		;OK		

tt		mov dx,di
		xor di,di
		ret

draw_camel
;
;Draw a camel at (bx,cx) according to the various animation
;parameters (preset)
;
		push bx
		add bx,8
		mov cx,85+66
		mov dx,bx
		mov bx,offset lego_r
		add bx,rleg
		add dx,[bx]
		add cx,32[bx]		
		mov bx,dx
		mov ax,rleg
		shr ax,1
		add ax,63
		cmp ax,78
		jne rca
		dec ax
rca		call xsprite	;draw rear leg (backg)
		pop bx
		push bx
		add bx,43
		mov cx,85+66
		mov dx,bx
		mov bx,offset lego
		add bx,fleg
		add dx,[bx]
		add cx,32[bx]
		mov bx,dx
		mov ax,fleg
		shr ax,1
		add ax,78
		call xsprite	;draw front leg (backg)
		pop bx



		push bx
		mov cx,50+66
		add bx,48
		mov dx,bx
		mov bx,offset neko
		mov ax,fleg
		and ax,15
		add bx,ax
		add cx,[bx]
		mov ax,16[bx]
		mov bx,dx
		add ax,95
		call xsprite	;draw neck
		pop bx

		push bx
		mov cx,50+66
		mov dx,bx
		mov bx,offset hedo
		mov ax,fleg
		and ax,15
		add bx,ax
		add dx,[bx]
		add cx,16[bx]
		mov bx,dx
		mov ax,99	;hed1
		push bx
		push cx
		call xsprite	;draw head
		pop cx
		pop bx		;get back head pos
		cmp shsho,0
		je noshi
		sub cx,20
		add bx,5
		mov ax,159	;camel's shield indicator
		call xsprite
noshi	
		pop bx

		push bx
		mov cx,50+66
		mov dx,bx
		mov bx,offset taleo
		add bx,taph
		add dx,[bx]
		add cx,28[bx]
		mov ax,56[bx]
		mov bx,dx
		add ax,100
		call xsprite	;draw tail
		pop bx
		push bx
		add bx,43
		mov cx,85+66
		mov dx,bx
		mov bx,offset lego
		mov ax,fleg
		add ax,16
		and ax,31
		add bx,ax
		add dx,[bx]
		add cx,32[bx]
		mov bx,dx
		shr ax,1
		add ax,78
		call xsprite	;draw front fore 
		pop bx

		push bx
		add bx,8
		mov cx,85+66
		mov dx,bx
		mov bx,offset lego_r
		mov ax,rleg
		add ax,16
		and ax,31
		add bx,ax
		add dx,[bx]
		add cx,32[bx]
		mov bx,dx
		shr ax,1
		add ax,63
		call xsprite	;draw rear fore 
		pop bx

		mov ax,94	;camel's body
		mov cx,50+66
		inc bx
		push bx
		call xsprite
		pop bx
do_weapons	cmp hmp,0
		je no_hump
		mov al,hmp
		xor ah,ah
		add ax,182
		push bx
		add bx,18
		mov cx,50+66
		call xsprite
		pop bx
no_hump		cmp ass,0
		je no_ass
		mov ax,189
		push bx
		sub bx,3
		mov cx,70+66
		call xsprite
		pop bx
no_ass		cmp can,0
		je no_can
		mov al,can
		xor ah,ah
		add bx,37
		sub bx,ax
		mov ax,190
		mov cx,80+66
		call xsprite
no_can		ret		

draw_kcam
		cmp xtm,1
		je docc
		jmp xddx
docc		push bx
		push cx
		add bx,8
		add cx,35
		mov dx,bx
		mov bx,offset lego_r
		add bx,kfr
		add dx,[bx]
		add cx,32[bx]		
		mov bx,dx
		mov ax,kfr
		shr ax,1
		add ax,63
		cmp ax,78
		jne rca1
		dec ax
rca1		call xsprite	;draw rear leg (backg)
		pop cx
		pop bx


		push bx
		push cx
		add bx,43
		add cx,35
		mov dx,bx
		mov bx,offset lego
		add bx,kff
		add dx,[bx]
		add cx,32[bx]
		mov bx,dx
		mov ax,kff
		shr ax,1
		add ax,78
		call xsprite	;draw front leg (backg)
		pop cx
		pop bx


		push bx
		push cx
		add bx,48
		mov dx,bx
		mov bx,offset neko
		mov ax,kff
		and ax,15
		add bx,ax
		add cx,[bx]
		mov ax,16[bx]
		mov bx,dx
		add ax,95
		call xsprite	;draw neck
		pop cx
		pop bx



		push bx
		push cx
		mov dx,bx
		mov bx,offset hedo
		mov ax,kff
		and ax,15
		add bx,ax
		add dx,[bx]
		add cx,16[bx]
		mov bx,dx
		mov ax,99	;hed1
		call xsprite	;draw head
		pop cx
		pop bx		;get back head pos



		push bx
		push cx
		mov dx,bx
		mov bx,offset taleo
		add bx,ktp
		add dx,[bx]
		add cx,28[bx]
		mov ax,56[bx]
		mov bx,dx
		add ax,100
		call xsprite	;draw tail
		pop cx
		pop bx

		push bx
		push cx
		add bx,43
		add cx,35
		mov dx,bx
		mov bx,offset lego
		mov ax,kff
		add ax,16
		and ax,31
		add bx,ax
		add dx,[bx]
		add cx,32[bx]
		mov bx,dx
		shr ax,1
		add ax,78
		call xsprite	;draw front fore 
		pop cx
		pop bx

		push bx
		push cx
		add bx,8
		add cx,35
		mov dx,bx
		mov bx,offset lego_r
		mov ax,kfr
		add ax,16
		and ax,31
		add bx,ax
		add dx,[bx]
		add cx,32[bx]
		mov bx,dx
		shr ax,1
		add ax,63
		call xsprite	;draw rear fore 
		pop cx
		pop bx
		mov ax,94	;camel's body
		inc bx
		call xsprite
		call do_weapons
xddx		mov bx,offset dxps
		mov cx,8
xddxl		cmp byte ptr [bx],0
		je nogga
		push cx
		push bx
		mov al,16[bx]
		xor ah,ah
		add ax,137
		mov cl,8[bx]
		xor ch,ch
		add cx,40+66
		mov dl,[bx]
		xor dh,dh
		add dx,xtx
		mov bx,dx
		call xsprite
		pop bx
		pop cx
nogga		inc bx
 		loop xddxl
		cmp xtm,2
		je draxx
		ret
draxx		mov cx,16
		mov bx,offset didat
dxxx		cmp word ptr 160[bx],0
		je okill
		push cx
		push bx
		mov dx,[bx]
		sar dx,1
		add dx,xtx
		add dx,15
		mov cx,32[bx]
		sar cx,1
		sar cx,1
		add cx,40+66
		cmp word ptr 128[bx],0
		jne xfarg
		mov ax,164
		add ax,bcow
		jmp ofarg
xfarg		mov ax,dx
		and ax,7
		sar al,1
		add ax,160
ofarg		mov bx,dx
		
		call csprite
		pop bx
		pop cx
okill 		inc bx
		inc bx
		loop dxxx		
		ret

hump
;
;Fire three projectiles from camel's hump
;
		cmp camy,0
		jg hfi
nfi		ret
hfi		cmp pfree,3
		jl nfi
		cmp hmp,6
		jne nfi
		mov bx,cama
		add bx,offset camdat
		mov ax,[bx]
		add ax,30*16
		mov dx,116*16
		mov si,offset hv
		mov cx,3
gfi		dec pfree
		mov bx,calend
adatl1		cmp byte ptr [bx],0
		je adgot1
		add bx,128
		jmp adatl1
adgot1		mov 2[bx],ax
		mov 4[bx],dx
		push ax
		mov ax,[si]		
		mov word ptr 6[bx],ax
		mov ax,6[si]
		mov word ptr 8[bx],ax
		mov word ptr [bx],0101h
		mov word ptr 12[bx],0
		mov word ptr 14[bx],1
		mov byte ptr 11[bx],1
		mov word ptr 16[bx],11
		mov word ptr 18[bx],11				
		inc si
		inc si
		pop ax
		loop gfi
		ret

fire_arse
;
;fire a shot outta the camel's bum
;
		cmp taph,3
		jge bumfir
		ret
bumfir 		cmp pfree,0
		je nfi
		dec pfree
		mov bx,cama
		add bx,offset camdat
		mov ax,[bx]
;		add ax,10*16
		mov dx,136*16
		mov bx,calend
adazz		cmp byte ptr [bx],0
		je gotty
		add bx,128
		jmp adazz
gotty		mov 2[bx],ax
		mov 4[bx],dx
		mov word ptr [bx],0103h
		mov word ptr 6[bx],-2*16
		call random
		and ax,0fh
		cmp shipy,60
		jg dontt
		neg ax
dontt		mov word ptr 8[bx],ax
		mov word ptr 11[bx],1
		mov word ptr 12[bx],2
		mov word ptr 14[bx],0
		mov word ptr 16[bx],18
		mov word ptr 18[bx],3
		mov word ptr 66[bx],3
mi6		ret 	
fire_frnt
;
;fire a shot from front cannon
;
 		cmp pfree,0
		je mi6
		dec pfree
		mov bx,cama
		add bx,offset camdat
		mov ax,[bx]
		add ax,60*16
		mov dx,146*16
		mov bx,calend
aazz		cmp byte ptr [bx],0
		je gtty
		add bx,128
		jmp aazz
gtty		mov 2[bx],ax
		mov 4[bx],dx
		mov word ptr [bx],0103h
		mov word ptr 6[bx],3*16
		call random
		and ax,7h
		mov can,12
		cmp shipy,60
		jg dott
		neg ax
dott		mov word ptr 8[bx],ax
		mov word ptr 12[bx],3
		mov byte ptr 11[bx],1
		mov word ptr 14[bx],0
		mov word ptr 16[bx],18
		mov word ptr 18[bx],3
		mov word ptr 66[bx],4
		ret 	
	
gfire		cmp byte ptr 1[bx],0
		jne izzuz
		ret		;only if viz
izzuz		push si
		mov ax,32[bx]
		mov dx,34[bx]	;get co-ords
		cmp dx,0
		je nyd
		add ax,80	;adjust to ppos ordinates	
		sal ax,1
		sal ax,1
		sal ax,1
		sal ax,1
		sal dx,1
		sal dx,1
		sal dx,1
		sal dx,1
		add ax,ppos	;got ppos including sine
		call fffire
nyd		pop si
		ret 

spit
;
;Fire aimed shot at player from <ax>,<dx> (ppos ordinates)
;
		cmp camy,0
		jg con
		ret
con		mov bx,cama
		mov di,32
		add bx,offset camdat
		mov ax,[bx]
		add ax,65*16
		mov dx,116*16

fffire		cmp pfree,0
		jg ok_fire
		ret
ok_fire		dec pfree
		mov si,offset _shot
		push dx
		push ax
		sub ax,80
		sar ax,1
		sar ax,1
		sar ax,1
		sar ax,1
		mov dx,ax
		call inison
		pop ax
		pop dx
		mov bx,calend
adatl		cmp byte ptr [bx],0
		je adgot
		add bx,128
		jmp adatl
adgot		mov 2[bx],ax
		mov 4[bx],dx
		call aim
		mov word ptr 6[bx],cx
		mov word ptr 8[bx],si
		mov word ptr [bx],0101h
		mov byte ptr 11[bx],1
		mov word ptr 12[bx],0
		mov word ptr 14[bx],0
		mov word ptr 16[bx],11
		mov word ptr 18[bx],11
		mov word ptr 32[bx],0
		mov word ptr 34[bx],0 
		mov word ptr 66[bx],1
		ret


aim
;		mov cx,shipx
;		add cx,80
;		sal cx,1
;		sal cx,1
;		sal cx,1
;		sal cx,1		;get ship X in ppos form
;		mov si,shipy
;		sal si,1
;		sal si,1
;		sal si,1
;		sal si,1
;		add cx,ppos

		mov cx,pshipx
		mov si,pshipy
		sub cx,ax		;cx has delta-X
		jge yop
		neg cx
		call yop
		neg cx
okeh		ret		
yop				;get in ppos form
		sub si,dx		;si has delta-y
		jge raim
		neg si
		call raim
		neg si
		jmp okeh
raim		cmp si,cx
		jg sig
shloo		cmp cx,di
		jl nsh
		shr cx,1
		shr si,1
		jmp shloo
sig		xchg cx,si
sigl		cmp cx,di
		jl sige
		shr cx,1
		shr si,1
		jmp sigl
sige		mov cx,di
		xchg cx,si		
		ret
nsh		mov cx,di
		ret


mpu
;
;turn shot enemy into a power-up token
;


		mov ax,pspd
		sar ax,1
		mov word ptr 6[bx],ax
		mov word ptr 8[bx],0
		mov word ptr 14[bx],0
		mov word ptr 16[bx],9
		mov word ptr 18[bx],9
		mov word ptr 36[bx],0
		mov word ptr 38[bx],6
		mov word ptr 44[bx],1
		mov word ptr 46[bx],0
		mov byte ptr 49[bx],197
		mov word ptr 50[bx],3
		mov word ptr 52[bx],303h
		mov byte ptr 54[bx],0
		mov word ptr 62[bx],0
		mov byte ptr 64[bx],1
		mov word ptr 66[bx],0
		mov byte ptr 71[bx],0
		mov byte ptr 73[bx],64
		mov word ptr 126[bx],offset boncon
		ret 

pkal		mov word ptr 88[bx],137	;set up
		mov byte ptr 90[bx],3	;a partial
		mov word ptr 84[bx],1	;explosion
		mov word ptr 86[bx],0	;yeah
		ret



inbas		mov word ptr 2[bx],0
		mov word ptr 4[bx],2680
		jmp glaunch

atship		mov ax,pshipx
		mov 2[bx],ax
		mov ax,pshipy
		mov 4[bx],ax
urez		call glaunch
		jmp make_rez

nship		call random
		and ax,0ff0h
		sub ax,07f0h
		add ax,pshipx
		mov 2[bx],ax
randy		call random
		and ax,2047
		add ax,512
		mov 4[bx],ax
		jmp urez
atshx		mov ax,pshipx
		mov 2[bx],ax
		jmp randy
atshy		mov ax,pshipy
		mov 4[bx],ax
		call baboon
		jmp urez
baboon		call random
		and ax,16383
		sub ax,8192
		add ax,pshipx
		mov 2[bx],ax
		ret
rahnd		call baboon
		jmp randy

shxbot		mov ax,pshipx
		mov 2[bx],ax
		mov word ptr 4[bx],220*16
		jmp glaunch

x_fur		push es
		mov cx,ds
		mov es,cx
		mov di,bx
		mov cx,64
		rep movsw
		pop es
		ret

lxcmd
;
;as XCMD but specific to launcher; AL=launch code
;
		push bx
		xor ah,ah
		mov bx,offset llyst
		sal ax,1
		add bx,ax
		mov ax,[bx]
		pop bx
		call x_fur
		jmp ax

xcmd
;
;Process a Launch/Change command string
;BX=>alien block; SI=>start of command string; DI=offset from BX
;
		cmp si,0
		jne xcm
		ret
xcm	
		lodsb		;get command byte
		cmp al,'.'
		jne nononsh		;return if done
		jmp nsh
nononsh		cmp al,'a'
		jge dlowa
		push bx
		mov bx,offset uc_vex
		sub al,'A'
		xor ah,ah
		sal ax,1
		add bx,ax
		mov ax,[bx]
		pop bx
		jmp ax		;jump to vectop

dlowa		push bx
		mov bx,offset lc_vex
		sub al,'a'
		xor ah,ah
		sal ax,1
		add bx,ax
		mov ax,[bx]
		pop bx
		jmp ax		

lc_b
;				set pointer
		lodsb
		xor ah,ah
		mov di,ax
		jmp xcm		;pointer set, loop back
lc_x
		lodsb
		cmp al,'U'
		je mpu2
mpu1		jmp kal		;Blow th' sucker up!!
mpu2		call random
		and al,0fh
		cmp al,0ah
		jle mpu1
		jmp mpu

lc_y		jmp pkal

lc_r		call random
		mov cx,ax
		jmp xcm

lc_l		add cx,ppos
		jmp xcm

lc_f		neg byte ptr [bx+di]
		jmp xcm

lc_p		lodsb		;add next byte in CL
		add cl,al
		jmp xcm

lc_n		lodsb		;move next byte to CL
		mov cl,al
		jmp xcm

lc_i		inc BYTE PTR [bx+di]	
		jmp xcm

lc_d		dec byte ptr [bx+di]
		jmp xcm

lc_m		mov [bx+di],cl
		inc di		;move CL to current and inc
		jmp xcm
lc_z		mov byte ptr [bx+di],0
		inc di
		jmp xcm

lc_a		lodsb
		and cl,al
		jmp xcm

lc_s		lodsb
		mov [bx+di],al
		inc di
		jmp xcm
no8s		ret

uc_f		neg word ptr [bx+di]
		jmp xcm

uc_p		lodsw		;add next byte in CL
		add cx,ax
		jmp xcm
uc_n		lodsw		;move next byte to CL
		mov cx,ax
		jmp xcm
uc_i		inc word PTR [bx+di]	
		jmp xcm
uc_d		dec word ptr [bx+di]
		jmp xcm
uc_m		mov [bx+di],cx
		inc di		;move CL to current and inc
		inc di
		jmp xcm
uc_z		mov word ptr [bx+di],0
		inc di
		inc di
		jmp xcm
uc_a		lodsw
		and cx,ax
		jmp xcm
uc_s		lodsw
		mov [bx+di],ax
		inc di
		inc di
		jmp xcm
uc_q		lodsb
		xor ah,ah
		mov di,ax
		call gfire	;Fire a shot
		jmp xcm
uc_r		mov ax,2[bx]	;get alien X
		shr ax,1	;make positive only
		mov cx,pshipx	;get our ship x
		shr cx,1
		cmp ax,cx	;test direction
		jl setpp
		lodsb
		neg al
		mov 72[bx],al 	
		jmp xcm
setpp		lodsb
		mov 72[bx],al
		jmp xcm
uc_k		inc afree
		mov byte ptr [bx],0
		ret
uc_u		mov si,offset _ptting
		mov dx,shipx
		call inison
		call inc_pwr
		mov byte ptr [bx],5
		mov ax,pspd
		mov 6[bx],ax
		mov txtadr,offset pwrup
		mov txtdur,50
		mov byte ptr 49[bx],200
		mov word ptr 12[bx],5 
nul		ret
no16u		ret

inc_pwr
		ret
		cmp lwp,8		;max LW?
		jne oktinc
		cmp lwf,12		;max FWF?
		je noh232
oktinc		inc wbv
		inc lwf
		cmp lwf,13
		jne noh232
		inc lwp			;allow next weapon
		mov lwf,0
noh232		ret

dec_pwr
		ret
		cmp lwp,0		;Decrement ship power level
		jne oktoke
		cmp lwf,1
		je noh232
oktoke		dec wbv
		dec lwf
		jge ddode
		mov lwf,12
		dec lwp
ddode		mov al,lwp
		cmp btype,al
		jle noh232
		mov btype,al
		ret

lautst
;
;test command string imterpreter by using it to launch type-1 static shots
;
		cmp afree,0
		jg dlaut
		ret
dlaut		dec afree
		mov bx,offset adat
gebbul		cmp byte ptr [bx],0
		je gobbul
		add bx,128
		jmp gebbul
gobbul		mov si,offset tlaus
		call lxcmd		;execute command launch $
glaunch	
;
;General launch common-ground stuff for alien/shot --> BX
;
		mov byte ptr [bx],4
		mov byte ptr 12[bx],4
		mov byte ptr 11[bx],1
		mov byte ptr 14[bx],1
		mov byte ptr 15[bx],0	;zero detcol stuff
		mov byte ptr 1[bx],1	;assume visible until disproven
		mov byte ptr 20[bx],0	;hit ship flag
		mov word ptr 32[bx],0
		mov word ptr 34[bx],0	;zero 'logical detecol' position
		mov ax,word ptr 38[bx]
		mov word ptr 36[bx],ax	;reset acc delays to defaults
		mov ax,word ptr 44[bx]
		mov word ptr 40[bx],ax
		mov ax,word ptr 46[bx]
		mov word ptr 42[bx],ax	;sundry timers set
		mov al,53[bx]
		mov 50[bx],al		;set IFD
		mov byte ptr 55[bx],0		;ATARG flag
		ret
make_rez
;
;Make any GLAUNCHed alien into rez-up form
;
		mov al,[bx]
		mov 27[bx],al
		mov byte ptr [bx],6	;alien type=Rezup
		mov al,11[bx]
		mov 26[bx],al
		mov byte ptr 11[bx],0	;store and null ship col
		mov al,14[bx]
		mov 25[bx],al
		mov byte ptr 14[bx],0	;null VUL
		mov byte ptr 24[bx],40	;rez-duration
		mov byte ptr 12[bx],6	;rez-draw
		ret
 
hasl
;
;Air-support launcher
;
		test wtime,-1		;timer set?
		je has_1
		dec wtime
		ret
has_1		mov al,wnum
		cmp al,afree		;required aliens free?
		jle has_2
		ret			;wait until free
has_2
		mov wnum,0
		mov bx,hasl_pc
has_loop	mov al,[bx]		;get cmd
		inc bx
		cmp al,'w'		;WAIT?
		jne hloo1
		mov al,[bx]
		xor ah,ah
		mov wtime,ax
		inc bx
		mov hasl_pc,bx
		ret
hloo1		cmp al,'s'
		jne hloo2
		mov al,[bx]
		inc bx
		xor ah,ah
		sal ax,1		;x64 for 'seconds'
		sal ax,1
		sal ax,1
		sal ax,1
		sal ax,1
		sal ax,1
		mov wtime,ax
		mov hasl_pc,bx
		ret
hloo2		cmp al,'f'
		jne hloo3
		mov al,[bx]
		inc bx
		mov hasl_pc,bx
		mov wnum,al
		ret
hloo3		cmp al,'p'
		jne hloo4
		cmp camx,0
		jg hccn
		dec bx
		mov hasl_pc,bx
		ret
hccn		jmp has_loop
hloo4		cmp al,'l'
		jne hloo5
		mov al,[bx]	;get Launch Code
		inc bx
		mov cl,[bx]
		inc bx		;and alien type no.
		mov hasl_pc,bx	;save PC
		mov bx,offset adat
lfaan		cmp byte ptr [bx],0
		je gfaan
		add bx,128
		jmp lfaan	;find free alien
gfaan		dec afree
		xor ch,ch
		sal cx,1
		mov si,offset waval
		add si,cx	;get..
		mov si,[si]	;address of alien string
		call lxcmd	;do launch
		mov bx,hasl_pc	;restore pc
		jmp has_loop	;go proc sum more
hloo5		cmp al,'('
		jne hloo6
		mov si,h_sp	;get stac ptr
;		inc bx
		mov al,[bx]	;get count
		inc bx
		mov [si],bx	;place loop-addr
		inc si
		inc si
		xor ah,ah
		mov [si],ax	;place loop-count
		inc si
		inc si
		mov h_sp,si	;replace SP
		jmp has_loop	;continue
hloo6		cmp al,')'
		jne hloo7
		mov si,h_sp
		dec si
		dec si
		dec word ptr [si]
		je hloo61
		dec si
		dec si
		mov bx,[si]	;loop
		jmp has_loop
hloo61		dec si
		dec si
		mov h_sp,si	;restore SP
		jmp has_loop	;OK
hloo7		cmp al,'['
		jne hloo8
		mov h_start,bx
		jmp has_loop
hloo8		cmp al,']'
		jne hloo9
		mov bx,h_start
		jmp has_loop
hloo9		jmp has_loop


		


init_dsp	
		call clr_chip
idsp		mov ppitch,000h
		mov twist,00h
		mov si,11
savvy		push si
		call get_vox
		mov cx,0
		mov dx,1000
		call set_vol
		mov bx,0
		mov cx,ppitch
		call set_pitch
		mov dx,twist
		call set_twist
		add ppitch,0
		add twist,80h
		pop si
		dec si
		jge savvy

		mov ax,nvoxx
		mov si,96
		call write_dsp


		mov ppitch,0
		ret

whit1		mov bx,01000h
		mov cx,1
whit		dec bx
		jne whit
		mov bx,01000h
		dec cx
		jne whit

run_am
		test s_disabl,-1
		je do_son
		ret
do_son          call run_sonix
;		ret
		dec tran_trig
		jne www
		mov bx,tran_ptr
		inc bx
		inc bx
		mov tran_ptr,bx
		add bx,offset tran_tab
		mov ax,[bx]
		cmp ax,0
		jge usu_trat
		mov tran_ptr,0
		mov bx,offset tran_tab
		mov ax,[bx]
usu_trat	mov xpose,ax
		cmp a_blot,0
		je cusik
		dec a_blot
		mov ax,a_blok
		mov cc_blok,ax
		mov xtrans,0
		jmp www
cusik		cmp camy,0
		jl cusu
		mov cc_blok,offset camon
		jmp ww0
cusu		mov cc_blok,offset twists
ww0
		mov bx,shipy
		sar bx,1
		sar bx,1

		and bx,30
		add bx,offset strans
		mov bx,[bx]
		mov xtrans,bx
www		mov bx,cc_blok
		mov si,0
whit2		cmp tran_trig,0
		je cake
		dec word ptr [bx]
		je whit22
		jmp whit3
whit22		mov ax,24[bx]
		mov [bx],ax
		add word ptr 192[bx],0110h
		and word ptr 192[bx],1fffh	;stereo sweep

cake		inc word ptr 48[bx]		
		mov dx,48[bx]
 		push si
IGGI		push bx
		mov bx,72[bx]	;ptr to tune row
		sal dx,1
		add bx,dx
		mov dx,[bx]	;get note
		cmp dx,0
		jge onote
		cmp dx,-2
		jne iggi1
		call get_vox
;		mov bx,0
;		mov cx,0
;		call set_pitch
		jmp yiggle		

iggi1		pop bx
		mov dx,0
		mov word ptr 48[bx],0
		JMP IGGI
onote		call get_vox
		mov cl,dh
		xor dh,dh
		xor ch,ch
		add dx,xpose

		add dx,xtrans
cchk		cmp dx,12
		jl yippie
		sub dx,12
		inc cx
		jmp cchk		
yippie		
		call play_note
		pop bx
		mov word ptr 120[bx],1
		mov word ptr 168[bx],0		;re-set enveLopE
		jmp yeggle
yiggle		pop bx
yeggle		pop si
whit3
		push si
		dec word ptr 120[bx]
		jne erot
		mov ax,144[bx]
		mov 120[bx],ax
		push bx
		mov dx,192[bx]		;get Stereo Pointer
		test dx,1000h		;test bit 11
		je in_ranj
		sub dx,1000h		;reduce to 0-511
		xor dx,0fffh		;invert
in_ranj		mov ax,168[bx]
		mov bx,96[bx]
		add bx,ax
		mov cx,[bx]
		cmp cx,0
		jne nerot
		pop bx
		jmp erot
nerot		push bx
		mov bx,cx
		call get_vox
		call set_dvol
		pop bx
		mov dx,2[bx]		;get Twist Envelope
		dec dx
		call set_twist
		pop bx
		add word ptr 168[bx],4
erot		pop si
		inc bx
		inc bx
		inc si
		cmp si,6
		jne whit5
		cmp tran_trig,0
		jne tranz
		mov ax,tran_spd
		mov tran_trig,ax
tranz		ret
whit5		jmp whit2


;---------------------------------------------------------------------
;			    UTILITY SUBROUTINES
;---------------------------------------------------------------------


;---------------------------------------------------------------------
;Load dsp - load a DASM dsp file into DSP program and data ram.
;
;
; Input: 
;
;	ds:si - pointer to program data block.
;
; Output:
;
;	Crashes with scrolling border if DSP program fails to load.


load_dsp	push es

		mov ax,DSP_SEG			; DSP's base address
		mov es,ax

	 	mov al,DSP_STOP		; stop the dsp 
		mov byte ptr es:[DSP_STATUS],al

		mov bx,si			; bx is info table
		add si,10			; si is first word

		cld 

	  	mov di,word ptr [bx]		
		add di,di			; Is this required ?
		add di,DSP_PRAM 
		mov cx,word ptr [bx+2]		; length of program
		call dsp_ld

		mov di,word ptr [bx+4]
		add di,di			; double because we're using
		mov cx,word ptr [bx+6]		; words.
		call dsp_ld


		mov al,byte ptr es:[DSP_PRAM]  ; start it executing
	 	mov al,DSP_RUN
		mov byte ptr es:[DSP_STATUS],al

		pop es
		ret


;---------------------------------------------------------------------


dsp_ld		lodsw
		mov byte ptr es:[di],al	; need to write the same
		inc di
		mov byte ptr es:[di],ah	; word twice
		dec di
		mov dl,byte ptr es:[di]	; and read three times
		mov dl,byte ptr es:[di]
		inc di
		mov dh,byte ptr es:[di]
		inc di

		cmp ax,dx
		je  verify_ok

failed_verify	inc ax				; crash with very wierd
 		out BORDL,al			; border.
		jmp failed_verify

verify_ok	loop dsp_ld
		ret



;---------------------------------------------------------------------
; write_dsp - used to write a word to the DSP, while it is running
;
; 	si = offset into DSP data memory to write to
; 	ax = value to write


write_dsp:	push ds
		mov dx,ax

		mov ax,DSP_SEG
		mov ds,ax

		and si,255			; DSP ram is 128 words...
		add si,si

;wr1:		mov al,byte ptr [DSP_STATUS]	; wait for last dsp write data to be written
;  		cmp al,10h			; look at status ...
;		jne wr1

		mov DSP_DRAM[si],dx		; write the data
		shr si,1			; return si to original value

		pop ds
		ret

		

;-----------------------------------------------------------------------
;
; *     *  *****  *    *
;  *   *  *     * *   *
;   * *   *     * *  *
;    *    ******* ***
;    *    *     * *  *
;    *    *     * *   *
;    *    *     * *    *
;
; SOUNDCHIP MAINTENENCE ROUTINES FOR 2-12 VOICE SFX GENERATOR
;
; These routines use SI, so must be used from IRQ only if current
; raster stuff is used


clr_vox
;
; Initialise a zero voice on channel <SI>; set L and R volumes to 0
; SI is set to following voice

		mov ax,si
		sal si,1
		sal si,1
		sal si,1	;chan*8
		sub si,ax	;chan*7
		add si,3	;base offset from base of DSP data RAM
		mov ax,0
		call write_dsp
		inc si
		mov ax,0
		call write_dsp	;zero wave's pointer
		mov ax,8000h
 		inc si
		call write_dsp
		inc si
		mov ax,0
		call write_dsp	;some boring pitch
		inc si
		mov ax,0
		call write_dsp	;no twist
		inc si
		mov ax,0
		call write_dsp	;left vol. off
		inc si
		mov ax,0
		call write_dsp
		inc si
		ret		;done, voice active but silent

clr_chip
;
;Initialise the sound chip to default: 10 voices, all zero volume
;
		mov si,11	;clear all 12 voice channels
cvox		push si
		call clr_vox	;use Clr_Vox to zap a channel
		pop si
		dec si
		jge cvox	;do 12 voices
		mov si,96	;word 96 is no. vox pairs
		mov ax,4	;5 vox pairs; 10 voices
		call write_dsp	;tell DSP about it
		ret		;done
get_vox
;
;Get SI setting for voice <SI>
;
		mov ax,si
		sal si,1
		sal si,1
		sal si,1
		sub si,ax
		add si,3	;vox base offset
		ret

set_pitch
;
;Set Voice <SI> to pitch <BX:CX>. SI, BX, CX undisturbed
;
		push dx
		inc si
		inc si
		mov ax,cx
		call write_dsp
		mov ax,bx
		inc si
		call write_dsp
		sub si,3
		pop dx
		ret

set_twist
;
;Set Twist of voice <SI> to <DX>. These regs. preserved
;
		add si,4
		mov ax,dx
		push dx
		call write_dsp
		pop dx
		sub si,4
		ret

set_vol
;
;Set Voice SI to volume <CX>, stereo position <DX>. <DX> is, like,
;a screen co-ordinate; a 128-value would give equal volume on both
;stereo channels. CX is a shift-count.
;
		add si,5	;point to L volume
		sub dx,64
		sal dx,1
		sal dx,1
		mov ax,dx
		cmp ax,0
		jge izpozz
		neg ax		;get abs distance from L stereo source
izpozz		cmp ax,1023	;allow +/- 512
		jg ile		;out of 'hearing'
;		sal ax,1	;range 0-1024 (may be altered if desired)
		xor ax,1023	;invert so 0=max
		sal ax,cl	;mult to true 'volume'
;		sal ax,1
		push dx
		call write_dsp
		pop dx		;done L channel
ile		mov ax,512	;position of R stereo point
		inc si
		sub ax,dx
		jge izpos1
		neg ax
izpos1		cmp ax,1023	;same as before, all this				 
		jg ile2
;		sal ax,1
		xor ax,1023
		sal ax,cl
		push dx
		call write_dsp
		pop dx
ile2		sub si,6
		ret

set_dvol
;
;Set direct volume <BX>=vol, stereo position in DX
;
		add si,5
;		mov ax,dx
		mov cx,dx
;		xor cx,511
;		sar cx,1
;		sar cx,1
; ;		sar cx,1
;		sar cx,1
;		sar cx,1
;		sar cx,1
;		sar cx,1
;		sar ax,cl
		mov ax,cx
		call write_dsp
		inc si
		mov ax,0fffh
		sub ax,cx
;		mov ax,bx
		sal ax,1
		call write_dsp
		sub si,6
		ret

play_note
;
;Play musical note: <SI> set, dx=note, cx=octave
;
		mov bx,offset note_tab
		mov ax,dx
		sal ax,1	;ax=word ptr to note
		add bx,ax
		mov ax,[bx]	;get note tuning value
;		sar ax,1
		sal ax,cl	;get octave
		sar ax,1
		push ax
		mov ah,al
		xor al,al
		add si,2
		call write_dsp	;fractional part
		pop ax
		mov al,ah
		xor ah,ah
		inc si
		call write_dsp	;integer part
		sub si,3
		ret		;OK

run_sonix
;
;Interpret up to 4 SFX channels using the Yakly sound language
;extended from the ST version to cover more channels, stereo and
;Twisted waveforms.
;
;This is the first Sound routine I have ever written which has to be
;scrolled by the Screen code. Stereo FX have to track the action!
;
		mov si,offset zap_dat
		mov cx,4		;6 possible channels
sfxl		cmp word ptr [si],0
		jl sfxe			;-ve means channel off
		cmp word ptr 16[si],0		;chan. delay set?
		je skwal
		dec word ptr 16[si]
		jmp sfxe
skwal		push cx			;trashin' these..
		mov bx,2[si]		;get prog PC..
		lea dx,34[si]		;point to alfa 'a'
		mov cx,0		;clear 'acc'
		call run_sprog		;run program
		pop cx
sfxe		add si,86
		loop sfxl		;do 6 possible groovy chanels
		ret			;.. and piss off

run_sprog
;
;The nitty gritty. Run the SFXL code --> BX
;

		mov al,[bx]		;get Cmd byte
		cmp al,'a'		;wha' is it?
		jl not_alfa
		sub al,97		;damn fool programmer wants an alfa
		xor ah,ah
		sal ax,1		;word ptr
		lea dx,34[si]		;base alfa
		add dx,ax		;got alfa base
		xchg bx,dx
		mov cx,[bx]		;fetch value, preserve BX
		xchg bx,dx		;OK
n_cmd		inc bx	
		jmp run_sprog		;go do some more
not_alfa	cmp al,'0'		;check for 4-digit numerik
		jl no_numeric
		cmp al,'9'
		jle is_numeric		;0-9,definite range
		cmp al,'A'
		jl no_numeric		;less than A, no go
		cmp al,'F'
		jg no_numeric		;greater than F, tough shite
is_numeric	call get_numeric	;fetch 4 byte value into DI
		mov cx,di		;place in Acc
		jmp run_sprog		;get next cmd
no_numeric	cmp al,'*'		;Set Pitch?
		jne nopitch
		push bx
		push cx
		push si
		push dx
		mov si,[si]		;get Log. Chan
		mov bl,ch		;get top word Pitch
		xor bh,bh
		mov ch,cl
		xor cl,cl		;bottom word of Pitch
		call get_vox		;get Voice
		call set_pitch		;set th' pitch
		pop dx
		pop si
		pop cx
		pop bx
		jmp n_cmd		;Pitch is set
nopitch		cmp al,'.'		;WAIT wanted?
		jne nowait
		mov 16[si],cx		;place Acc as WAIT value
		inc bx			;skip '.'
		mov 2[si],bx		;save PC
		ret			;leave the code
nowait		cmp al,'^'		;set Volume?
		jne novol
		push si
		push bx
		push dx
		mov dx,12[si]		;get stereo-position
		mov si,[si]
		call get_vox
		call set_vol		;set the volume
		pop dx
		pop bx
		pop si
		jmp n_cmd
novol		cmp al,'$'		;Twist?
		jne notwst
		push si
		push dx
		mov dx,cx
		mov si,[si]
		call get_vox
		call set_twist		;set that Twist
		pop dx
		pop si
		jmp n_cmd
notwst		cmp al,':'		;Term?
		jne noturm
		mov word ptr 10[si],0	;clear Inhibit
		push si
		mov si,[si]
		mov bx,0
		mov cx,0
		call get_vox
		call set_pitch		;shutdown finished vox
		pop si
		mov word ptr [si],-1	;shut down channel
		ret			;and go		 
noturm		cmp al,','		;Load Alfa?
		jne nlal
		inc bx			;skip th' comma
		call get_numeric
		mov cx,di
		xchg bx,dx
		mov [bx],di		;set numerik value
		xchg dx,bx
		jmp run_sprog		;done
nlal		cmp al,'('		;Loop Start set?
		jne nols
		mov ax,bx
		mov bx,8[si]		;get stac ptr
		mov [bx],ax		;save PC value
		inc bx
		inc bx			;update SP
		mov 8[si],bx		;save SP
		mov bx,ax		;restore PC
		jmp n_cmd		;loop point done
nols		cmp al,'['
		jne norol
		sal cx,1
		jmp n_cmd
norol		cmp al,']'
		jne noror
		sar cx,1
		jmp n_cmd
noror 		cmp al,'='		;Compare-loopend?
		jne neq_loop
		inc bx
		call get_numeric
		cmp cx,di
		je loop_end
loop_bak	mov bx,8[si]		;get SP
		dec bx
		dec bx			;point at prev loopbak
		mov bx,[bx]		;get new PC value
		jmp n_cmd
loop_end	sub word ptr 8[si],2		;adjust SP
		jmp run_sprog		;continue
neq_loop	cmp al,'<'
		jne nle_loop
		inc bx
		call get_numeric
		cmp cx,di
		jl loop_end
		jmp loop_bak
nle_loop	cmp al,'>'
		jne ngr_loop
		inc bx
		call get_numeric
		cmp cx,di
		jg loop_end
		jmp loop_bak
ngr_loop	cmp al,'-'		;subtrac
		jne no_subt
		inc bx
		call get_numeric
		sub cx,di
setvv		xchg bx,dx
		mov [bx],cx
		xchg bx,dx
		jmp run_sprog
no_subt		cmp al,'+'
		jne no_adds
		inc bx
		call get_numeric
		add cx,di
		jmp setvv		 
no_adds		jmp n_cmd		;Skip null chars				
				

get_numeric
;
;Build word in DI corresponding to 4-digit hexstring starting at [BX]
;Increment BX accordingly. Gets alfas if asked to.
;
		mov al,[bx]
		cmp al,'a'
		jl get4byte
		sub al,97		;damn fool programmer wants an alfa
		xor ah,ah
		sal ax,1		;word ptr
		push dx
		lea dx,34[si]		;base alfa
		add dx,ax		;got alfa base
		xchg bx,dx
		mov di,[bx]		;fetch value, preserve BX
		xchg bx,dx		;OK
		pop dx
		inc bx
		ret

get4byte
		push cx
		mov cx,4
		mov di,0
getig		mov al,[bx]
		xor ah,ah
		inc bx
		cmp al,'A'
		jl no_adj
		sub al,7		;correct for Hex digits
no_adj		sub al,48
		shl di,1
		shl di,1
		shl di,1
		shl di,1
		or di,ax		;build number by Nybbles
		loop getig
		pop cx
		ret


inison
;
;Start up one or more SFXL progs. Enter with <si>=start of SFX def bloc
;and <dx>=stereo position

		push bx
		push ax
isprg		mov bx,[si]
		mov ax,bx
		sal bx,1
		sal bx,1
		sal bx,1
		sal bx,1
		sal bx,1
		sal bx,1		;bx*64
		sal ax,1
		add bx,ax		;bx*66
		sal ax,1
		add bx,ax		;*70
		sal ax,1
		sal ax,1
		add bx,ax		;*86
		add bx,offset zap_dat
		cmp word ptr 10[bx],0		;inhibit?
		je no_inh		
		cmp word ptr 2[si],0		;Power to override?
		je nxt_1
no_inh		mov ax,4[si]
		mov 2[bx],ax		;place PC
		lea ax,18[bx]
		mov 8[bx],ax		;set SP
		mov ax,6[si]
		mov [bx],ax		;set chan. no.
		mov ax,2[si]
		mov 10[bx],ax		;set pri-mode
		mov ax,dx
		mov word ptr 12[bx],ax		;stereo position
nxt_1		add si,8
		cmp word ptr [si],0
		jg isprg
		pop ax
		pop bx
		ret
		
				
						

code_seg	ends
	

		end ;do_demo

		
