;-------------------------------------------
; MODEX Library v1.10
; Copyright (c) 1995 Marco A. Marrero
;--------------------------------------------
; Contributors:
; --------------
; Draeden, Themie Gouthas, Michael Abrash
; and Matt Pritchard.
;--------------------------------------------

IDEAL
MODEL SMALL,PASCAL
P286
LOCALS

CODESEG
ASSUME  cs:@code
P386

LABEL X320Y200 word
    db	    00	    ; 0e3h    ; dot clock
    db	    02	    ; Number of CRTC Registers to update
    dw	    00014h  ; turn off dword mode
    dw	    0e317h  ; turn on byte mode
    dw	    320     ; width
    dw	    200     ; height

LABEL X320Y200s word
    db	    0e3h    ; dot clock
    db	    02	    ; Number of CRTC Registers to update
    dw	    00014h  ; turn off dword mode
    dw	    0e317h  ; turn on byte mode
    dw	    320     ; width
    dw	    200     ; height

LABEL X320Y240 word
    db	    0e3h    ; dot clock
    db	    10	    ; Number of CRTC Registers to update
    dw	    00d06h  ; vertical total
    dw	    03e07h  ; overflow (bit 8 of vertical counts)
    dw	    04109h  ; cell height (2 to double-scan)
    dw	    0ea10h  ; v sync start
    dw	    0ac11h  ; v sync end and protect cr0-cr7
    dw	    0df12h  ; vertical displayed
    dw	    00014h  ; turn off dword mode
    dw	    0e715h  ; v blank start
    dw	    00616h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    320     ; width
    dw	    240     ; height

LABEL X360Y200 word
    db	    0e7h    ; dot clock
    db	    08	    ; Number of CRTC Registers to update
    dw	    06b00h  ; horz total
    dw	    05901h  ; horz displayed
    dw	    05a02h  ; start horz blanking
    dw	    08e03h  ; end horz blanking
    dw	    05e04h  ; start h sync
    dw	    08a05h  ; end h sync
    dw	    00014h  ; turn off dword mode
    dw	    0e317h  ; turn on byte mode
    dw	    360     ; width
    dw	    200     ; height

LABEL X360Y240 word
    db	    0e7h    ; dot clock
    db	    16	    ; Number of CRTC Registers to update
    dw	    06b00h  ; horz total
    dw	    05901h  ; horz displayed
    dw	    05a02h  ; start horz blanking
    dw	    08e03h  ; end horz blanking
    dw	    05e04h  ; start h sync
    dw	    08a05h  ; end h sync
    dw	    00d06h  ; vertical total
    dw	    03e07h  ; overflow (bit 8 of vertical counts)
    dw	    04109h  ; cell height (2 to double-scan)
    dw	    0ea10h  ; v sync start
    dw	    0ac11h  ; v sync end and protect cr0-cr7
    dw	    0df12h  ; vertical displayed
    dw	    00014h  ; turn off dword mode
    dw	    0e715h  ; v blank start
    dw	    00616h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    360
    dw	    240

LABEL X376Y282 word
    db	    0e7h
    db	    18
    dw	    06e00h  ; horz total
    dw	    05d01h  ; horz displayed
    dw	    05e02h  ; start horz blanking
    dw	    09103h  ; end horz blanking
    dw	    06204h  ; start h sync
    dw	    08f05h  ; end h sync
    dw	    06206h  ; vertical total
    dw	    0f007h  ; overflow
    dw	    06109h  ; cell height
    dw	    0310fh  ;
    dw	    03710h  ; v sync start
    dw	    08911h  ; v sync end and protect cr0-cr7
    dw	    03312h  ; vertical displayed
    dw	    02f13h  ; offset
    dw	    00014h  ; turn off dword mode
    dw	    03c15h  ; v blank start
    dw	    05c16h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    376
    dw	    282

LABEL X320Y400 word
    db	    00	    ; 0e3h    ; dot clock
    db	    03	    ; Number of CRTC Registers to update
    dw	    04009h  ; cell height
    dw	    00014h  ; turn off dword mode
    dw	    0e317h  ; turn on byte mode
    dw	    320     ; width
    dw	    400     ; height

LABEL X320Y480 word
    db	    0e3h    ; dot clock
    db	    10	    ; Number of CRTC Registers to update
    dw	    00d06h  ; vertical total
    dw	    03e07h  ; overflow (bit 8 of vertical counts)
    dw	    04009h  ; cell height (2 to double-scan)
    dw	    0ea10h  ; v sync start
    dw	    0ac11h  ; v sync end and protect cr0-cr7
    dw	    0df12h  ; vertical displayed
    dw	    00014h  ; turn off dword mode
    dw	    0e715h  ; v blank start
    dw	    00616h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    320     ; width
    dw	    480     ; height

LABEL X360Y400 word
    db	    0e7h    ; dot clock
    db	    09	    ; Number of CRTC Registers to update
    dw	    06b00h  ; horz total
    dw	    05901h  ; horz displayed
    dw	    05a02h  ; start horz blanking
    dw	    08e03h  ; end horz blanking
    dw	    05e04h  ; start h sync
    dw	    08a05h  ; end h sync
    dw	    04009h  ; cell height
    dw	    00014h  ; turn off dword mode
    dw	    0e317h  ; turn on byte mode
    dw	    360     ; width
    dw	    400     ; height


LABEL X360Y480 word
    db	    0e7h
    db	    17
    dw	    06b00h  ; horz total
    dw	    05901h  ; horz displayed
    dw	    05a02h  ; start horz blanking
    dw	    08e03h  ; end horz blanking
    dw	    05e04h  ; start h sync
    dw	    08a05h  ; end h sync
    dw	    00d06h  ; vertical total
    dw	    03e07h  ; overflow
    dw	    04009h  ; cell height
    dw	    0ea10h  ; v sync start
    dw	    0ac11h  ; v sync end and protect cr0-cr7
    dw	    0df12h  ; vertical displayed
    dw	    02d13h  ; offset
    dw	    00014h  ; turn off dword mode
    dw	    0e715h  ; v blank start
    dw	    00616h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    360
    dw	    480

LABEL X360Y360 word
    db	    0e7h
    db	    15
    dw	    06b00h  ; horz total
    dw	    05901h  ; horz displayed
    dw	    05a02h  ; start horz blanking
    dw	    08e03h  ; end horz blanking
    dw	    05e04h  ; start h sync
    dw	    08a05h  ; end h sync
    dw	    04009h  ; cell height
    dw	    08810h  ; v sync start
    dw	    08511h  ; v sync end and protect cr0-cr7
    dw	    06712h  ; vertical displayed
    dw	    02d13h  ; offset
    dw	    00014h  ; turn off dword mode
    dw	    06d15h  ; v blank start
    dw	    0ba16h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    360
    dw	    360

LABEL X376Y308 word
    db	    0e7h
    db	    18
    dw	    06e00h  ; horz total
    dw	    05d01h  ; horz displayed
    dw	    05e02h  ; start horz blanking
    dw	    09103h  ; end horz blanking
    dw	    06204h  ; start h sync
    dw	    08f05h  ; end h sync
    dw	    06206h  ; vertical total
    dw	    00f07h  ; overflow
    dw	    04009h  ;
    dw	    0310fh  ;
    dw	    03710h  ; v sync start
    dw	    08911h  ; v sync end and protect cr0-cr7
    dw	    03312h  ; vertical displayed
    dw	    02f13h  ; offset
    dw	    00014h  ; turn off dword mode
    dw	    03c15h  ; v blank start
    dw	    05c16h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    376
    dw	    308



LABEL X376Y564 word
    db	    0e7h
    db	    18
    dw	    06e00h  ; horz total
    dw	    05d01h  ; horz displayed
    dw	    05e02h  ; start horz blanking
    dw	    09103h  ; end horz blanking
    dw	    06204h  ; start h sync
    dw	    08f05h  ; end h sync
    dw	    06206h  ; vertical total
    dw	    0f007h  ; overflow
    dw	    06009h  ;
    dw	    0310fh  ;
    dw	    03710h  ; v sync start
    dw	    08911h  ; v sync end and protect cr0-cr7
    dw	    03312h  ; vertical displayed
    dw	    02f13h  ; offset
    dw	    00014h  ; turn off dword mode
    dw	    03c15h  ; v blank start
    dw	    05c16h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    376
    dw	    564

LABEL X256Y240 word
    db	    0e3h    ; dot clock
    db	    16	    ; Number of CRTC Registers to update

    dw	    05f00h  ; horz total
    dw	    03f01h  ; horz displayed
    dw	    04002h  ;04202h  ; start horz blanking
    dw	    0a003h  ;09f03h  ; end horz blanking
    dw	    04f04h  ; start h sync
    dw	    00405h  ; end h sync

    dw	    00d06h  ; vertical total
    dw	    03e07h  ; overflow (bit 8 of vertical counts)
    dw	    04109h  ; cell height (2 to double-scan)
    dw	    0ea10h  ; v sync start
    dw	    0ac11h  ; v sync end and protect cr0-cr7
    dw	    0df12h  ; vertical displayed
    dw	    0e715h  ; v blank start
    dw	    00616h  ; v blank end

    dw	    00014h  ; turn off dword mode
    dw	    0e317h  ; turn on byte mode
    dw	    256
    dw	    240

LABEL X256Y70 word
    db	    0e3h    ; dot clock
    db	    16	    ; Number of CRTC Registers to update

    dw	    05f00h  ; horz total
    dw	    03f01h  ; horz displayed
    dw	    04002h  ;04202h  ; start horz blanking
    dw	    0a003h  ;09f03h  ; end horz blanking
    dw	    04f04h  ; start h sync
    dw	    00405h  ; end h sync

    dw	    00d06h  ; vertical total
    dw	    03e07h  ; overflow (bit 8 of vertical counts)
    dw	    04709h  ; cell height (8 to get blocky)
    dw	    0ea10h  ; v sync start
    dw	    0ac11h  ; v sync end and protect cr0-cr7
    dw	    0df12h  ; vertical displayed
    dw	    0e715h  ; v blank start
    dw	    00616h  ; v blank end

    dw	    00014h  ; turn off dword mode
    dw	    0e317h  ; turn on byte mode
    dw	    256
    dw	    240

LABEL X256Y154 word
    db	    0e3h    ; dot clock
    db	    18	    ; Number of CRTC Registers to update

    dw	    05f00h  ; horz total
    dw	    03f01h  ; horz displayed
    dw	    04002h  ;04202h  ; start horz blanking
    dw	    0a003h  ;09f03h  ; end horz blanking
    dw	    04f04h  ; start h sync
    dw	    00405h  ; end h sync

    dw	    06206h  ; vertical total
    dw	    00f07h  ; overflow
    dw	    04109h  ; CELL HEIGHT
    dw	    0310fh  ;
    dw	    03710h  ; v sync start
    dw	    08911h  ; v sync end and protect cr0-cr7
    dw	    03312h  ; vertical displayed
    dw	    02f13h  ; offset
    dw	    00014h  ; turn off dword mode
    dw	    03c15h  ; v blank start
    dw	    05c16h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    256
    dw	    308

LABEL X256Y282 word
    db	    0e3h    ; dot clock
    db	    18	    ; Number of CRTC Registers to update

    dw	    05f00h  ; horz total
    dw	    03f01h  ; horz displayed
    dw	    04002h  ;04202h  ; start horz blanking
    dw	    0a003h  ;09f03h  ; end horz blanking
    dw	    04f04h  ; start h sync
    dw	    00405h  ; end h sync

    dw	    06206h  ; vertical total
    dw	    0f007h  ; overflow
    dw	    06109h  ; cell height
    dw	    0310fh  ;
    dw	    03710h  ; v sync start
    dw	    08911h  ; v sync end and protect cr0-cr7
    dw	    03312h  ; vertical displayed
    dw	    02f13h  ; offset
    dw	    00014h  ; turn off dword mode
    dw	    03c15h  ; v blank start
    dw	    05c16h  ; v blank end
    dw	    0e317h  ; turn on byte mode
    dw	    256
    dw	    564


LABEL X256Y200 word
    db	    0e3h    ; dot clock
    db	    8	    ; Number of CRTC Registers to update
    dw	    05f00h  ; horz total
    dw	    03f01h  ; horz displayed
    dw	    04002h  ; start horz blanking
    dw	    0a003h  ; end horz blanking
    dw	    04f04h  ; start h sync
    dw	    00405h  ; end h sync
    dw	    00014h  ; turn off dword mode
    dw	    0e317h  ; turn on byte mode
    dw	    256
    dw	    200

LABEL ModeTable word		;-- Mode X tweak table
    dw	    offset X320Y200
    dw	    offset X320Y240
    dw	    offset X360Y200
    dw	    offset X360Y240
    dw	    offset X376Y282
    dw	    offset X320Y400
    dw	    offset X320Y480
    dw	    offset X360Y400
    dw	    offset X360Y480
    dw	    offset X360Y360
    dw	    offset X376Y308
    dw	    offset X376Y564
    dw	    offset X256Y240
    dw	    offset x256y200
    dw	    offset X320Y200s
    dw	    offset x256y154
    dw	    offset x256y282
    dw	    offset x256y70

M320x200x256 =0			;-- Constants for easy calling
M320x240x256 =1			;-- 60Hz refresh rate instead of 70Hz
M360x200x256 =2
M360x240x256 =3
M376x282x256 =4
M320x400x256 =5
M320x480x256 =6
M360x400x256 =7
M360x480x256 =8
M360x360x256 =9
M376x308x256 =10
M376x564x256 =11		;-- Highest resolution available here
M256x240x256 =12		;-- Can be addressed with 8 bit registers
M256x200x256 =13
M256x154x256 =15
M256x282x256 =16
M256x70x256 =17

InputStatus1=	3dah
MISC_OUTPUT =	3c2h
SC_Index    =	3c4h
CRTC_Index  =	3d4h
Graph_Index =	3ceh
Attr_Index  =	3c0h	;-- Don't forget clear flipflop & set bit 5 on index
PEL_Write   =	3c8h
PEL_Read    =	3c7h
PEL_Data    =	3c9h

MASK_PLANE1	EQU 00102h	;-- Map Register + Plane 1
MASK_PLANE2	EQU 01102h	;-- Map Register + Plane 1
ALL_PLANES	EQU 00F02h	;-- Map Register + All Bit Planes
CHAIN4_OFF	EQU 00604h	;-- Chain 4 mode Off
ASYNC_RESET	EQU 00100h	;-- (A)synchronous Reset
SEQU_RESTART	EQU 00300h	;-- Sequencer Restart

LATCHES_ON	EQU 00008h	;-- Bit Mask + Data from Latches
LATCHES_OFF	EQU 0FF08h	;-- Bit Mask + Data from CPU



;----- Variables ------------------------------------------------------------

xseg		EQU	0a000h	;-- VGA ModeX segment

xP_WIDTH	DW	320	;-- Physical width	(view)
xP_HEIGHT	DW	200	;-- Physical height
xP_WIDTH4	DW	80	;-- Physical width in dwords

xL_WIDTH	DW	320	;-- Logical width	(whole page)
xL_HEIGHT	DW	200	;-- Logical height
xL_WIDTH4	DW	80	;-- Logical width in dwords
xL_SIZE4	DW	16000	;-- Logical size/4 (modex can update 4 pix)
xL_SIZE16	DW	4000	;-- Logical size in pages

xPAGE		DW	0	;-- Page offset
xOFFSET		DW	0	;-- Scrap page to use with GET/PUT

;----- Functions ------------------------------------------------------------


;ALIGN 4
;---------------------------------------------------------------------
; x_getinfo(void far *x_struct) | Gets structure information
;---------------------------------------------------------------------
PUBLIC  x_getinfo
PROC	x_getinfo	FAR
ARG	what:DWORD
USES	ds,di,si

	push	cs		;-- ds:si = local variables
	pop	ds
	mov	si,OFFSET xP_WIDTH

	les	di,[what]	;-- es:di = pointer to structure
        mov     cx,10           ;-- 10 words

	rep	movsw

	ret
ENDP




;ALIGN 4
;----------------------------------------------------------------
; x_getpagesize() | Get page size.
;----------------------------------------------------------------
PUBLIC	x_getpagesize
PROC	x_getpagesize	FAR

	mov	ax,[xL_SIZE4]
	ret
ENDP



;ALIGN 4
;----------------------------------------------------------------
; x_set_page(offset) | Set page offset (offset of screen)
;-----------------------------------------------------------------
PUBLIC	x_set_page
PROC	x_set_page	FAR
ARG	ofs:WORD

;	mov	ax,ofs
;	mov	[xL_PAGE],ax
	ret
ENDP




;ALIGN 4
;ษอออออออออออออออออออออออออออออหอออออออออออออออออออออป
;บ modex_set(word mode,swidth) บ Calls ModeX Screen  บ
;ศอออออออออออออออออออออออออออออสอออออออออออออออออออออผ
PUBLIC	modex_set
PROC	modex_set	FAR
ARG	mode:WORD, swidth:WORD, sheight:WORD
USES	ds,si,di

	mov	bx,cs
	mov	ds,bx
	mov	es,bx


	mov	ax,[mode]
	cmp	ax,17			;-- If mode invalid, won't fry VGA!
	ja	@@bye

	mov	cx,[swidth]
	mov	[ds:xL_WIDTH],cx	;-- Store logical width

	mov	ax,13h			;-- Let BIOS set standard 256-color
	int	10h			;-- mode 13 (320x200 linear)

	mov	dx,SC_INDEX
	mov	ax,0604h
	out	dx,ax			;-- disable chain4 mode
	mov	ax,0100h
	out	dx,ax		;-- synchronous reset while setting Misc
				;-- Output for safety, even though clock
				;-- unchanged

	mov	bx,[mode]	;-- Get information from table
	add	bx,bx
	mov	si,[ds:bx+ModeTable]
	lodsb

	or	al,al
	jz	@@DontSetDot
	mov	dx,MISC_OUTPUT
	out	dx,al			;-- select the dot clock and Horiz
					;--  scanning rate
@@DontSetDot:
	mov	dx,SC_INDEX
	mov	ax,0300h
	out	dx,ax			;-- Undo reset (restart sequencer)

	mov	dx,CRTC_INDEX		;-- Reprogram the CRT Controller
	mov	al,11h			;-- VSync End reg contains register
	out	dx,al			;---- write protect bit
	inc	dx			;-- CRT Controller Data register
	in	al,dx			;-- Get current VSync End reg set
	and	al,07fh 		;-- Remove write protect on various
	out	dx,al			;---- CRTC registers
	dec	dx			;-- CRT Controller Index
	cld
	xor	cx,cx
	lodsb
	mov	cl,al

@@SetCRTParmsLoop:
	lodsw			;-- get the next CRT Index/Data pair
	out	dx,ax		;-- set the next CRT Index/Data pair
	dec	cx
	jne 	@@SetCRTParmsLoop

	lodsw				;-- Physical width and height
	mov     [ds:xP_WIDTH],ax	;-- (The screen you are seeing)
	lodsw
	mov     [ds:xP_HEIGHT],ax


	mov	dx,SC_INDEX
	mov	ax,0f02h
	out	dx,ax			;-- enable writes to all 4 planes
					;-- now clear all display memory
	mov	ax,0a000h
	mov     es,ax			;-- 16 pixels at a time
	xor	di,di			;-- point ES:DI to display memory
	xor	ax,ax			;-- clear to zero-value pixels
	xor	cx,cx			;-- # of dwords in all display mem
	rep	stosd			;-- clear all of display memory

;------ ModeX is set, now set the required logical page width. ---------

	mov	cx,[ds:xL_WIDTH]	;-- Logical width (real)
	shr	cx,2			;-- in Dwords
	mov     [ds:xL_WIDTH4],cx	;-- Logical width (dwords)

	shr	cx,1			;-- Divide by 8 to set logical width
	mov	dx,CRTC_INDEX		;---- to the VGA hardware
	mov	al,13h
	mov	ah,cl
	out	dx,ax


;------ Now let's calculate screen size --------------------------------

	mov	ax,[ds:xL_WIDTH]	;-- xL_WIDTH  = Logical width
	shr	ax,2			;-- In DWORDs, of course.
	mov	[ds:xL_WIDTH4],ax	;-- xL_WIDTH4 = Logical width dword

	mov	bx,[sheight]		;-- Get logical height
	mov	[ds:xL_HEIGHT],bx	;-- store

	mul	bx			;-- xL_WIDTH * xL_HEIGHT = xL_SIZE
	mov	[ds:xL_SIZE4],ax	;-- Size of screen in dwords

	mov	ax,[ds:xP_WIDTH]	;-- xP_WIDTH  = Physical width
	shr	ax,2
	mov	[ds:xP_WIDTH4],ax	;-- xP_WIDTH4 = P.width in dwords

	mul	[ds:xP_HEIGHT]		;-- width*height = size
;	mov	[ds:xP_SIZE4],ax	;-- Screen size in dwords (modex)

	mov	bx,ax			;-- Save ax.
	shr	bx,2			;-- Screen size in pages, if we
;	mov	[ds:xP_SIZE16],bx	;--- have to store stuff in dwords

@@bye:
	ret
ENDP


;------ Video Buffer Routines ----------------------------------------------


; I think this piece of junk won't work.
;ALIGN 4
;ษอออออออออออออออหออออออออออออออออออออออออออออออออออออป
;บ mode13_to_x() บ Get back to ModeX after vga_linear บ
;ศอออออออออออออออสออออออออออออออออออออออออออออออออออออผ
PUBLIC	mode13_to_x
PROC	mode13_to_x	FAR

	mov	dx,SC_INDEX
	mov	ax,0604h
	out	dx,ax		    ; disable chain4 mode

	mov	dx,CRTC_INDEX
	mov	ax,00014h	    ; turn off dword mode
	out	dx,ax
	mov	ax,0e317h	    ; turn on byte mode
	out	dx,ax
	ret
ENDP


; Maybe won't work.
;ALIGN 4
;ษอออออออออออออออหออออออออออออออออออออออออออออออออออออออออออออออป
;บ modex_to_13() บ Converts from ModeX to Linear (only 320x200) บ
;ศอออออออออออออออสออออออออออออออออออออออออออออออออออออออออออออออผ
PUBLIC	modex_to_13
PROC	modex_to_13	FAR

	mov	dx,SC_INDEX
	mov	ax,0E04h
	out	dx,ax		; enable chain4 mode

	mov	dx,CRTC_INDEX	; reprogram the CRT Controller
	mov	ax,04014h	; turn on dword mode
	out	dx,ax
	mov	ax,0a317h	; turn off byte mode
	out	dx,ax
	ret
ENDP


;ALIGN 4
;--------------------------------------------------------------------
; modex_to_16() | Changes FROM 256 color planar TO 16 color planar
;--------------------------------------------------------------------
PUBLIC	modex_to_16
PROC	modex_to_16	FAR

	mov     dx,Graph_Index
	mov     ax,00005h		;-- Set Shift reg to 0
	out     dx,ax

	mov     dx,InputStatus1
	in      al,dx			;-- Dummy input
	mov     dx,Attr_Index
	mov     al,30h
	out     dx,al
	mov     al,21h			;-- Turn off PCS, and turns on PCC
	out     dx,al
	mov     ah,0
	mov     dx,InputStatus1
	in      al,dx			;-- Dummy input
	mov     dx,Attr_Index
	mov     al,33h
	out     dx,al
	mov     al,ah
	out     dx,al

	ret
ENDP



;ALIGN 4
;-----------------------------------------------------------------------
; mode16_to_x() | Changes FROM 16 color planar TO 256 color planar
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ---
PUBLIC	mode16_to_x
PROC	mode16_to_x	FAR

	mov     dx,Graph_Index
	mov     ax,04005h		;-- Set Shift reg to 1
	out     dx,ax

	mov     dx,InputStatus1
	in      al,dx			;-- Dummy input
	mov     dx,Attr_Index
	mov     al,30h
	out     dx,al
	mov     al,61h			;-- Turns on PCS & PCC
	out     dx,al

	mov     ah,0
	mov     dx,InputStatus1
	in      al,dx			;-- Dummy input
	mov     dx,Attr_Index
	mov     al,33h
	out     dx,al
	mov     al,ah
	out     dx,al

	ret
ENDP




;ALIGN 4
;--------------------------------------------
; clearx(byte color) | Clear all VGA memory
;--------------------------------------------
PUBLIC	xclear
PROC	xclear		FAR
ARG	color:BYTE
USES	di

	mov	dx,SC_INDEX	;-- enable writes to all four planes
	mov	ax,0f02h
	out	dx,ax


	mov	ax,xSEG		;-- es:di = screen address
	mov     es,ax
	xor	di,di


	mov	al,[color]	;-- Get value, and convert it to 32 bits
	mov	ah,al
	mov	bx,ax
	shl	eax,16
	mov	ax,bx

	mov	cx,16000	;-- # of dwords in whole display memory
	rep	stosd		;-- clear all of display memory

	ret
ENDP





;ALIGN 4
;----------------------------------------
; xcls(byte color) | Clear ModeX screen
;----------------------------------------
PUBLIC	xcls
PROC	xcls		FAR
ARG	color:BYTE
USES	di

	mov	dx,SC_INDEX	;-- Enable all bitplanes
	mov	ax,ALL_PLANES
	out	dx,ax

	mov     di,[xPAGE]	;-- es:di = Screen
	mov	ax,xSEG
	mov     es,ax

	mov	al,[color]	;-- Get color, and set it up to 32 bit.
	mov	ah,al
	mov	dx,ax
	shl	eax,16
	mov	ax,dx

	mov	cx,[xL_SIZE16]	;-- Modex screen pixels in dwords
@@clsx:
	rep	stosd		;-- 16 pixels at once! Yikes!
	ret
ENDP





;ALIGN 4
;----------------------------------------------------------------------
; xpset(int x,y; byte color) | Sets a pixel in logical page (clipping)
;----------------------------------------------------------------------
PUBLIC	xpset
PROC	xpset		FAR
ARG	x1:WORD, y1:WORD, color:BYTE
USES	di

	mov	bx,[xPAGE]
	mov	ax,xSEG
	mov	es,ax

	mov     di,[x1]         ;-- x coordinate
	mov     cx,di           ;-- cx has x position too

	cmp     di,[xL_WIDTH]   ;-- it's out of bounds?
	jae     @@bye

	mov     ax,[y1]         ;-- y coordinate
	cmp     ax,[xL_HEIGHT]  ;-- y is out of bounds?
	jae     @@bye

	mul     [xL_WIDTH4]	;-- ax = y address

	shr	di,2		;-- width / 4
	add	di,ax		;-- di = x + y


	and	cl,3		;-- cl = x mod 4 (to set plane select)
	mov	ax,MASK_PLANE1	;-- Get Map Mask register and 1 plane set
	shl	ah,cl		;-- Roll bit to get correct plane.

	mov	dx,SC_INDEX	;-- $3c4
	out	dx,ax

	mov	al,[color]	;-- Get color
	stosb

@@bye:
	ret
ENDP



;ALIGN 4
;--------------------------------------------------------------------------
; xpset4(int x,y; byte color) | Sets a pixel in logical page | NO clipping
;--------------------------------------------------------------------------
PUBLIC	xpset4
PROC	xpset4		FAR
ARG	x1:WORD, y1:WORD, color:BYTE
USES	di

	mov	bx,[xPAGE]
	mov	ax,xSEG
	mov	es,ax

	mov	di,[x1]		;-- x coordinate
	mov	cx,bx		;-- cx has x position too
	mov	ax,[y1]		;-- y coordinate

	mul	[xL_WIDTH4]	;-- ax = y address

	shr	di,2		;-- width / 4
	add	di,ax		;-- di = x + y


	and	cl,3		;-- cl = x mod 4 (to set plane select)
	mov	ax,MASK_PLANE1	;-- Get Map Mask register and 1 plane set
	shl	ah,cl		;-- Roll bit to get correct plane.

	mov	dx,SC_INDEX
	out	dx,ax

	mov	al,[color]	;-- Get color
	stosb

@@bye:  ret
ENDP





;ALIGN 4
;---------------------------------------------------------------
; x_pcopy(word page1,page2) | Copies page1 to page2 (logical size)
;---------------------------------------------------------------
PUBLIC	x_pcopy
PROC	x_pcopy		FAR
ARG	page1:WORD, page2:WORD
USES	ds,si,di

	mov	ax,xSEG		;-- xSEG is a constant, must use register
	mov	ds,ax
	mov	es,ax

	mov	dx,SC_INDEX	;-- enable writes to all four planes
	mov	ax,0f02h	;-- Index 02, 1111
	out	dx,ax

	mov	di,[page1]	;-- page 1
	mov	si,[page2]	;-- page 2

	mov	cx,[xL_SIZE16]	;-- Logical screen size in Dwords
	rep	movsd		;-- Doubleword transfer!!

	ret
ENDP




;ALIGN 4
;=====================================================
; modex_to_bios(int mode) | Leave modex
;=====================================================
PUBLIC	modex_to_bios
PROC	modex_to_bios	FAR
ARG	mode:byte

	xor	ah,ah
	mov	al,[mode]
	int	10h

	ret
ENDP



;ALIGN 4
;====================================================================
; x_boxfill(int x,y,x1,y1; byte color) || No clipping!
;====================================================================
PUBLIC	x_boxfill
PROC	x_boxfill	FAR
ARG     x1:WORD, y1:WORD, x2:WORD, y2:WORD, color:BYTE
USES	di


	mov	di,[xPAGE]	;-- Screen start offset (page number)
	mov	ax,xSEG		;-- VGA segment
	mov	es,ax


;-- Let's get number of vertical lines

	mov	cx,[y2]		;-- y2 MUST be greater than y1!
	sub	cx,[y1]		;-- So we got distance
	inc	cx

;-- Let's get
ENDP


;ฤฤฤฤฤฤฤฤ Finish ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
ENDS
END

