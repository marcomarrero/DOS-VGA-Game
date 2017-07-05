;ษอออออออออออออออออออออออออออออออออออออออป
;บ    VGA Hardware Library - v1.01	 บ
;บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
;บ   Programmed by Marco A. Marrero	 บ
;บ Morse #49, Box 453 - Arroyo, PR 00714 บ
;บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
;บ Thanx to M. Abrash, Draeden of VLA,	 บ
;บ Iguana, Themie Gouthas,Matt Pritchard บ
 ศอออออออออออออออออออออออออออออออออออออออผ

;ฺยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;รด This thing is mainly a compilation of several sources. It is *not*	  ณ
;รด guaranteed to work on weird VGA cards and cheap VGA monitors.	  ณ
;รด									  ณ
;รด Requires a 286, but can be easily changed to 808x code. However,	  ณ
;รด I cannot imagine someone with such thing with a VGA card! Ugh!	  ณ
;ภมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

IDEAL
MODEL SMALL,PASCAL
JUMPS
P286

INPUT_STATUS1	= 03dah
MISC_OUTPUT	= 03c2h
SC_INDEX	= 03c4h
CRTC_INDEX	= 03d4h
GRAPH_INDEX	= 03ceh
ATTR_INDEX	= 03c0h  ;-- Don't forget clear flipflop & set bit 5 on index
PEL_WRITE	= 03c8h
PEL_READ	= 03c7h
PEL_DATE	= 03c9h

MASK_PLANE1 = 00102h	;-- Map Register + Plane 1
MASK_PLANE2 = 01102h	;-- Map Register + Plane 1
ALL_PLANES  = 00F02h	;-- Map Register + All Bit Planes
CHAIN4_OFF  = 00604h	;-- Chain 4 mode Off
ASYNC_RESET = 00100h	;-- (A)synchronous Reset
SEQU_RESTART= 00300h	;-- Sequencer Restart

LATCHES_ON =00008h	;-- Bit Mask + Data from Latches
LATCHES_OFF=0FF08h	;-- Bit Mask + Data from CPU



CODESEG
ASSUME  cs:@code
P386


;ALIGN 4
;ษออออออออออออออออหออออออออออออออออออออออออออออออออออออป
;บ VGA_POS(int x) บ Sets the VGA start display offset  บ
;ศออออออออออออออออสออออออออออออออออออออออออออออออออออออผ
PUBLIC	VGA_POS
PROC	VGA_POS		FAR
ARG	xpos:WORD

	mov	bx,[xpos]
	mov	dx,CRTC_INDEX	;-- CRTC_INDEX register port
	mov	al,0ch		;-- Register 0ch, "CRTC Start Address High"
	mov	ah,bh		;-- HIGH byte value in here
	out	dx,ax		;-- Write both register and value

	inc	al		;-- Register 0dh, "CRTC Start Address Low"
	mov	ah,bl		;-- LOW byte in here
	out	dx,ax		;-- CRTC 0dh register = value in ah
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออหออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ VGA_PAN(char pan) บ Sets the pixel pan value. **MUST BE EVEN NUMBER*** บ
;ศอออออออออออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออผ
PUBLIC	VGA_PAN
PROC	VGA_PAN		FAR
ARG	pan:BYTE

	mov	dx,INPUT_STATUS1	;-- Input Status 1
	in	al,dx			;-- dummy input, clear flipflop

;--- When we read from INPUT_STATUS1, we clear flipflop that toggles if
;--- ATTR_INDEX port is acting as an address selector or write port, thus
;--- setting ATTR_INDEX as an address register.

	mov	ah,[pan]		;-- Get value to write
	mov	dx,ATTR_INDEX		;-- Attr_Index = port 3c0h
	mov	al,33h			;-- Index 33h
	out	dx,al			;-- Set 33h

	mov	al,ah			;-- Get value
	out	dx,al			;-- Write value

;-- Unlike CRTC, ATTR_INDEX is an address AND write port at the same time.

	ret
ENDP




;ALIGN 4
;ษอออออออออออออหออออออออออออออออออออออออออออออป
;บ VGA_PAN_C() บ Set pixel pan compatibility  บ
;ศอออออออออออออสออออออออออออออออออออออออออออออผ
PUBLIC	VGA_PAN_C
PROC	VGA_PAN_C	FAR

	mov	dx,INPUT_STATUS1	;-- Input Status 1
	in	al,dx			;-- dummy input

	mov	dx,ATTR_INDEX		;-- Attr_Index	= Port 3c0h
	mov	al,30h
	out	dx,al
	inc	dx
	in	al,dx
	dec	dx
	or	al,00100000b
	out	dx,al

	ret
ENDP






;ALIGN 4
;ษออออออออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออป
;บ VGA_WPLANE(char plane) บ Plane to write (4 bitplanes, 00001111)  บ
;ศออออออออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผ
; plane: 0000b : bit 0= plane 0, bit 1=plane 1, etc..
;
PUBLIC	VGA_WPLANE
PROC	VGA_WPLANE	FAR
ARG	plane:BYTE

	mov	ah,[plane]	;-- get plane
	mov	dx,SC_INDEX
	mov	al,2		;-- Register #2
	and	ah,1111b	;-- Mask, it only wants 4 bits!
	out	dx,ax
	ret
ENDP







;ALIGN 4
;ษออออออออออออออออออออออออหอออออออออออออออออออออออออออออป
;บ VGA_RPLANE(char plane) บ Latch plane (0-3) to read	บ
;ศออออออออออออออออออออออออสอออออออออออออออออออออออออออออผ
PUBLIC	VGA_RPLANE
PROC	VGA_RPLANE	FAR
ARG	plane:BYTE

	mov	ah,[plane]

	mov	dx,GRAPH_INDEX
	mov	al,4
	out	dx,ax
	ret
ENDP






;ALIGN 4
;ษออออออออออออออออออออออหอออออออออออออออออออป
;บ VGA_WMODE(char mode) บ Write mode (0-3)  บ
;ศออออออออออออออออออออออสอออออออออออออออออออผ
PUBLIC	VGA_WMODE
PROC	VGA_WMODE	FAR
ARG	mode:BYTE

	mov	ah,[mode]
	mov	dx,GRAPH_INDEX
	mov	al,5
	out	dx,al
	inc	dx
	in	al,dx
	and	al,11111100b	;-- Clear out write mode bits
	and	ah,00000011b
	or	al,ah
	out	dx,al
	ret
ENDP




;ALIGN 4
;ษออออออออออออออออออออออหออออออออออออออออออออออออออป
;บ VGA_RMODE(char mode) บ Sets vga read mode (0,1) บ
;ศออออออออออออออออออออออสออออออออออออออออออออออออออผ
PUBLIC	VGA_RMODE
PROC	VGA_RMODE	FAR
ARG	mode:BYTE

	mov	ah,[mode]
	mov	dx,GRAPH_INDEX
	mov	al,5
	out	dx,al
	inc	dx
	in	al,dx
	and	al,11110111b	;-- Clear out write mode bits
	shl	ah,3		;-- Move bit to correct position
	and	ah,00001000b
	or	al,ah
	out	dx,al
	ret
ENDP






;ALIGN 4
;ษออออออออออออออออออออออออหออออออออออออออออออออออออออออป
;บ VGA_SPLIT(int scanlin) บ Splits screen at scanline  บ
;ศออออออออออออออออออออออออสออออออออออออออออออออออออออออผ
PUBLIC	VGA_SPLIT
PROC	VGA_SPLIT	FAR
ARG	scanlin:WORD

	mov	bx,[scanlin]

	mov	al,18h
	mov	ah,bl
	mov	dx,CRTC_Index
	out	dx,ax		;-- Set bits 0-7

	mov	al,09h
	out	dx,al
	inc	dx
	in	al,dx
	mov	ah,bh
	and	ah,00000010b
	shl	ah,5
	and	al,10111111b
	or	al,ah
	out	dx,al		;-- Set bit 9

	dec	dx
	mov	al,07h
	out	dx,al
	inc	dx
	in	al,dx
	and	al,11101111b
	mov	ah,bh
	and	ah,00000001b
	shl	ah,4
	or	al,ah
	out	dx,al		;-- Set bit 8

	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออออออออออหอออออออออออออออออออออออออป
;บ VGA_VBLANK(int start,end) บ Set VGA blanking limits บ
;ศอออออออออออออออออออออออออออสอออออออออออออออออออออออออผ
PUBLIC	VGA_VBLANK
PROC	VGA_VBLANK	FAR
ARG	start:WORD, ending:BYTE

	mov	dx,CRTC_INDEX	;-- Reprogram the CRT Controller
	mov	al,11h		;-- VSync End reg contains register write
	out	dx,al		;---- protect bit. Let's unprotect!
	inc	dx		;-- CRT Controller Data register
	in	al,dx		;-- Get current VSync End reg setting
	and	al,07fh 	;-- Remove write protect on various
	out	dx,al		;---- CRTC registers
	dec	dx		;-- CRTC Controller Index

	mov	bx,[start]	;-- We have 9-bit value
	mov	dx,CRTC_INDEX	;-- Actually 3d4h, if you forgot
	mov	al,15h		;-- CRTC Start vertical blank register
	mov	ah,bl		;-- low byte
	out	dx,ax

	mov	al,07h		;-- CRTC overflow register
	out	dx,al		;-- Set..

	inc	dx		;-- CRTC data
	in	al,dx		;-- Get value of register

	shl	bh,2		;-- Move bit 0 to 2
	and	bh,00000100b	;-- Clear all except bit 2
	and	al,11011011b	;-- make hole for bit
	or	al,bh		;-- set bit, if present
	out	dx,al

	dec	dx		;-- CRTC Index
	mov	ah,[ending]	;-- We have 7-bit value
	and	ah,01111111b	;-- (now it's really 7 bit!)
	mov	al,16h		;-- "CRTC End vertical blank" register
	out	dx,ax		;-- Done!

	ret
ENDP




;ALIGN 4
;ษออออออออออหอออออออออออออออออออออออออออออป
;บ HSYNCH() บ Synch to the horizontal int บ
;ศออออออออออสอออออออออออออออออออออออออออออผ
PUBLIC	HSYNCH
PROC	HSYNCH	FAR

	mov	dx,03dah

@@lab1:
	in	al,dx
	jmp	@@dum1
@@dum1:
	test	al,01
	jnz	@@lab1

@@lab2: in	al,dx
	jmp	@@dum2
@@dum2:
	test	al,01
	jz	@@lab2

	ret
ENDP


;ALIGN 4
;ษอออออออออหออออออออออออออออออออออออออออออออป
;บ VWAIT() บ Wait for the vertical retrace  บ
;ศอออออออออสออออออออออออออออออออออออออออออออผ
PUBLIC	VWAIT
PROC	VWAIT	FAR

	mov	dx,03DAh		; status register
	mov	bl,8

@@w_wait:
	in	al,dx
	test	al,bl
	jz	@@w_wait

	ret
ENDP



;ALIGN 4
;ษออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ VSYNCH(n:word) บ Wait for the vertical retrace, if is there wait next  บ
;ศออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
PUBLIC	VSYNCH
PROC	VSYNCH	FAR
ARG	delay:WORD

	mov	dx,03DAh	;-- status register
	mov	bl,8

	mov	cx,[delay]
	jcxz	@@last		;-- If cx=0, we just wait one.

@@skip_vr:			;-- Wait several
	in	al,dx
	test	al,bl
	jnz	@@skip_vr

@@wait_vr:
	in	al,dx
	test	al,bl
	jz	@@wait_vr
	loop	@@skip_vr

@@last:
	in	al,dx		;-- This is the one...
	test	al,bl
	jnz	@@last

@@last2:
	in	al,dx
	test	al,bl
	jz	@@last2
	ret
ENDP



;ALIGN 4
;ษอออออออออหอออออออออออออออออออออออออออออออออออออป
;บ VSKIP() บ Wait until not in vertical retrace. บ
;ศอออออออออสอออออออออออออออออออออออออออออออออออออผ
PUBLIC	VSKIP
PROC	VSKIP	FAR

	mov	dx,03DAh		; status register
	mov	bl,8

@@wait_vr:
	in	al,dx
	test	al,bl
	jz	@@wait_vr

@@skip_vr:
	in	al,dx
	test	al,bl
	jnz	@@skip_vr

	ret
ENDP


;ALIGN 4
;=============================================================
; screen_off | Turns video off for quicker update
;=============================================================
PUBLIC	screen_off
PROC	screen_off	FAR

	mov	dx,SC_INDEX	;-- 3c4h = SC_INDEX (function)
	mov	al,1		;-- function 1
	out	dx,al		;-- carry out

	inc	dx		;-- SC_INDEX+1 (data)
	in	al,dx		;-- Get value
	and	al,11011111b	;-- Screen off bit #5
	out	dx,al		;-- Who turned off the lights???
	ret
ENDP



;ALIGN 4
;=============================================================
; screen_on | Turns video off for seeing someting
;=============================================================
PUBLIC	screen_on
PROC	screen_on	FAR

	mov	dx,SC_INDEX	;-- 3c4h = SC_INDEX (function)
	mov	al,1		;-- function 1
	out	dx,al		;-- carry out

	inc	dx		;-- SC_INDEX+1 (data)
	in	al,dx		;-- Get value
	or	al,00100000b	;-- Screen off bit #5
	out	dx,al		;-- the shining...

	dec	dx		;-- SC_INDEX (function)
	mov	ax,ASYNC_RESET	;-- Function 0 (al), value 1 (ah)
	out	dx,ax

	ret
ENDP



;ALIGN 4
;=======================================================================
; video_lores | Gives priority to CPU to access video memory
;=======================================================================
PUBLIC	video_lorez
PROC	video_lorez	FAR

	mov	dx,SC_INDEX	;-- 3c4h = SC_INDEX (function)
	mov	al,1		;-- function 1
	out	dx,al		;-- carry out

	inc	dx		;-- SC_INDEX+1 (data)
	in	al,dx		;-- Get value
	or	al,00000010b	;-- Bit 1 means 3 access of 5.
	out	dx,al		;-- Okay
	ret
ENDP


;ALIGN 4
;=========================================================================
; video_hirez | Gives priority for the graphics chip to access video RAM
;=========================================================================
PUBLIC	video_hirez
PROC	video_hirez	FAR

	mov	dx,SC_INDEX	;-- 3c4h = SC_INDEX (function)
	mov	al,1		;-- function 1
	out	dx,al		;-- carry out

	inc	dx		;-- SC_INDEX+1 (data)
	in	al,dx		;-- Get value
	and	al,11111101b	;-- Mask bit
	out	dx,al		;-- Any improvement?
	ret
ENDP

;ALIGN 4
;=======================================================================
; scan_height | Programs the number of vertical scans for each pixel
;=======================================================================
PUBLIC	scan_height
PROC	scan_height	FAR
ARG	height:BYTE

	mov	ah,[height]	;-- Get number of scan lines
	dec	ah		;-- Cell height - 1

	mov	dx,CRTC_Index	;-- 3d4h = Crtc
	mov	al,9		;-- index 9, scan lines in char row (5 bit)
	out	dx,al		;-- Set register to read/write

	inc	dl		;-- CRTC write register
	in	al,dx		;-- Get current register status
	and	al,11100000b	;-- Mask bits (don't want to mess others)
	or	al,ah		;-- Stamp
	out	dx,al		;-- Data sent
	ret
ENDP


;ออออออออออออออออออออ END ออออออออออออออออออออออออออออออออออออออออออออออออออออ

ENDS
END
