; The IO space
; ------------

; Video controller locations

INTL		=	00h
INTH		=	01h
STARTL		=	02h
STARTH		=	03h
HCNTL		=	04h
HCNTH		=	05h
VCNTL		=	06h
VCNTH		=	07h
SCROLL1		=	08h
SCROLL2		=	09h
SCROLL3		=	0Ah
ACK		=	0Bh
MODE		=	0Ch
BORDL		=	0Dh
BORDH		=	0Eh
PMASK		=	0Fh
INDEX		=	10h
ENDL		=	11h
ENDH		=	12h
MEM		=	13h
GPR		=	14h
DIAG		=	15h
DIS		=	16h
HLPL		=	00h
HLPH		=	01h
VLPL		=	02h
VLPH		=	03h
STATUS		=	04h

; Blitter locations

BLPROG0		=	30h
BLPROG1		=	31h
BLPROG2		=	32h
BLCMD		=	33h
BLCON		=	34h
BLDEST0		=	20h
BLDEST1		=	21h
BLDEST2		=	22h
BLSRC0		=	23h
BLSRC1		=	24h
BLSRC2		=	25h
BLSTAT		=	26h
BLINNER		=	27h
BLOUTER		=	28h

; External IO

PORT1		=	40h
PORT2		=	50h
PORT3		=	40h

; Expansion IO base locations

GPIO0		=	60h
GPIO1		=	70h


; Blitter Command Definition

BL_SRC0		=	0
BL_SRC1		=	1
BL_SRC2		=	2
BL_DST0		=	3
BL_DST1		=	4
BL_DST2		=	5
BL_MODE		=	6
BL_CMPL		=	7
BL_OUT		=	8
BL_IN		=	9
BL_STEP		=	10
BL_PAT		=	11
BL_CMD		=	12


; DSP memory mapped registers:

DSP_SEG		= 4100h

DSP_SINE	= 0						; start of sine table
DSP_CONST	= 200h					; start of constants area
DSP_REGS	= 280h					; start of internal registers area.
DSP_PC		= 294h					; The DSP program counter.

DSP_DRAM	= 300h
DSP_PRAM	= 400h

DSP_STATUS	= 600h					; offset to run/status register from above
DSP_STOP	= 0						; segment. STOP and RUN are the values to
DSP_RUN		= 10h					; write to DSP_STATUS



