; ЪДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДї
; і   MiniCRT - Fast Text Routines   і
; і  Version 1.10 - Rev. 03/08/1995  і
; ГДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДґ
; і Copyright (c) 1995 Marco Marrero і
; і Licensed to SotfComm Dev. Group  і
; АДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДЩ

IDEAL
MODEL SMALL,PASCAL
JUMPS
LOCALS
P286N

;ДДДД ROUTINES ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД


CODESEG
ASSUME  cs:@code


screen_addr	DW ?	;-- $b800 if color, $b000 if mono
crtc		DW ?	;-- CRTC register addr, $3d4 color
down_lin	DW ?	;-- Characters in an horizontal line


ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; MINICRT_INIT() | Initializes variables - MUST BE CALLED OR PC WILL CRASH!!
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	MINICRT_INIT
PROC	MINICRT_INIT	FAR

	mov	[screen_addr],0b800h	;-- Set initially for color screen

	mov	ax,040h 		;-- BIOS data area, want to know CRT
	mov	es,ax

	mov	dx,[es:63h]		;-- Get CRT address
	mov	[crtc],dx		;-- And store...
	cmp	dx,03d4h		;-- It is color??
	je	@@bye			;-- Yeah... Done..

	mov	[screen_addr],0b000h	;-- Darn. It's a mono monitor.
@@bye:
	ret
ENDP




ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; CRT_CHAR(int x,y; byte char,color) | Outputs a single character
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_CHAR
PROC	CRT_CHAR        FAR
ARG	x:WORD, y:WORD, char:BYTE, color:BYTE
USES	ds

	mov	ds,[screen_addr]
	mov	ax,[y]			; y coordinate

	mul	[down_lin]		; y*bytes_per_row

	mov	bx,[x]			; x coordinate
	shl	bx,1			; x*2 (two bytes per char)
	add	bx,ax			; x + y = address

	mov	al,[char]		; character
	mov	ah,[color]		; color
	mov	[bx],ax 		; store
	ret
ENDP





ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; CRT_LINEX(int x,y,x1; byte char,color) | Horizontal text line
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_LINEX
PROC	CRT_LINEX       FAR
ARG	x:WORD, y:WORD, x1:WORD, char:BYTE, color:BYTE
USES	di

	mov	es,[screen_addr]

	mov	cx,[x1] 	; x1 coordinate
	mov	di,[x]		; x coordinate
	cmp	cx,di		; if (x1<x) then swap
	jae	@@ok
	xchg	cx,di
@@ok:
	sub	cx,di		; x1-x = distance
	shl	di,1		; x*2 (two bytes per char)

	mov	ax,[y]		; y coordinate
	or	ax,ax		; Stupid clipping if it's negative
	js	@@bye

	mul	[down_lin]	; y * bytes_per_row
	add	di,ax		; x + y = address

	mov	al,[char]	; character
	mov	ah,[color]	; color

	rep	stosw
@@bye:	ret
ENDP





ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; CRT_LINEY(int x,y,y1; byte char,color) | Draw vertical line
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_LINEY
PROC	CRT_LINEY       FAR
ARG	x:WORD, y:WORD, y1:WORD, char:BYTE, color:BYTE
USES	ds

	mov	ds,[screen_addr]

	mov	cx,[y1] 	; y1 coordinate
	mov	ax,[y]		; y coordinate
	sub	cx,ax		; y1-y = distance

	mov	bx,[x]		; x coordinate
	shl	bx,1		; x*2 (two bytes per char)

	mul	[down_lin]	; y*bytes_per_row
	add	bx,ax		; x + y = address

	mov	al,[char]	; character
	mov	ah,[color]	; color

	mov	dx,[down_lin]	; dx = y increment

@@plot:
	mov	[bx],ax
	add	bx,dx
	loop	@@plot
	ret
ENDP






ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; CRT_SHADEX(int x,y,x1) | Shades an horizontal line of the screen
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_SHADEX
PROC	CRT_SHADEX      FAR
ARG	x:WORD, y:WORD, x1:WORD
USES	ds

	mov	ds,[screen_addr]

	mov	cx,[x1] 	; x1 coordinate
	mov	bx,[x]		; x coordinate
	sub	cx,bx		; x1-x = distance

	shl	bx,1		; x*2 (two bytes per char)

	mov	ax,[y]		; y coordinate
	mul	[down_lin]	; y * bytes_per_row
	add	bx,ax		; x + y = address

	mov	al,008h 	; dark color
	inc	bx		; align bx to color
	mov	dx,2		; bx increment

@@plot:
	mov	[bx],al
	add	bx,dx
	loop	@@plot

	ret
ENDP





ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; CRT_SHADEY(int x,y,y1) | Shades a vertical line of the screen
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_SHADEY
PROC	CRT_SHADEY      FAR
ARG	x:WORD, y:WORD, y1:WORD
USES	ds

	mov	ds,[screen_addr]

	mov	cx,[y1] 	; y1 coordinate
	mov	ax,[y]		; y coordinate
	sub	cx,ax		; y1-y = distance

	mov	bx,[x]		; x coordinate
	shl	bx,1		; x*2 (two bytes per char)

	mul	[down_lin]	; y * bytes_per_row
	add	bx,ax		; x + y = address

	mov	al,008h 	; color

	mov	dx,[down_lin]	; dx = y increment
	inc	bx		; align bx to color

@@plot:
	mov	[bx],al
	add	bx,dx
	loop	@@plot
	ret
ENDP






ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; CRT_PRINT(int x,y; char far *txt; char color) | Outputs an ASCIIZ string
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_PRINT
PROC	CRT_PRINT       FAR
ARG	x:WORD, y:WORD, txt:DWORD, color:BYTE
USES	ds,si,di

	mov	es,[screen_addr]
	mov	ax,[y]		; y coordinate
	mul	[down_lin]	; y*bytes_per_line

	mov	di,[x]		; x coordinate (es:di points to screen)
	shl	di,1		; x * 2 (bytes_per_character)
	add	di,ax		; x + y = screen address

	lds	si,[txt]	; ds:si = *char
	mov	ah,[color]	; color

@@doit:
	lodsb			; get character (or escape code)
	or	al,al		; it is zero?
	je	@@bye		;--  begone

	cmp	al,17		; it is a color request? <=17
	jb      @@colr          ;--  yeah...

	cmp	al,255		; do you want ASCII code 0..15?
	je      @@ascii         ;-- affirmative...

@@plot:
	stosw			; Store character + color
	jmp     @@doit          ; And keep working

@@colr:
	dec	al		; color must be 0..15
	and	ah,0f0h 	; mask color nibble
	or	ah,al		; stamp new color
	jmp     @@doit          ; change is done!

@@ascii:
	lodsb			; get new character
	or	al,al		; we WON'T print asciiZ (safety)
	jnz     @@plot

@@bye:
	ret
ENDP





ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; CRT_PCOPY(word to,from) | Copies video memory (text)
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_PCOPY
PROC	CRT_PCOPY       FAR
ARG	to:WORD, from:WORD
USES	si,di,ds

	mov	ax,[screen_addr]
	mov	es,ax		; Both segments will point at screen
	mov	ds,ax

	mov	cx,4000 	; 80x25 (words to copy)

	mov	ax,[to] 	; di = destination
	mul	cx		; dest*page size
	mov	di,ax		; done

	mov	ax,[from]	; si = source
	mul	cx		; source*page size
	mov	si,ax		; done.

	shr	cx,1		; page size (word transfer)
	rep	movsw
	ret
ENDP





ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; wkey=CRT_READKEY() | DON'T USE THIS IF YOU HAVE YOUR OWN KEYBORD HANDLER
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_READKEY
PROC	CRT_READKEY     FAR

	mov	dl,0ffh
	mov	ah,6
	int	21h
	jz	@@nochar

	or	al,al		; Extended code?
	jnz	@@nochar

	mov	dl,0ffh 	; Read again...
	mov	ah,6
	int	21h

	xor	ah,ah
	neg	ax
	jmp	@@bye

@@nochar:
	xor	ah,ah

@@bye:
	ret
ENDP






ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; CRT_ECHO(char far *txt) | Echoes text to the screen using DOS (not BIOS)
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_ECHO
PROC	CRT_ECHO        FAR
ARG	txt:DWORD
USES	ds

	lds	dx,[txt]	; ds:dx = string address

	mov	bx,dx		; Let's do STRLEN
	xor	cx,cx

@@check:
	mov	al,[bx] 	; Get character
	or	al,al		; It's zero?
	je	@@found 	; Found end of string.

	inc	cx		; It's a character
	inc	bx		; Fetch next one
	jmp	@@check

@@found:
	or	cx,cx		; If there is nothing, just go away
	jz	@@bye

	mov	bx,1		; File handle (1=stdout)
	mov	ah,040h 	; Write file/device
	int	21h

@@bye:
	ret
ENDP





ALIGN 4
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; CRT_BOXFILL(int x,y,x1,y1; word color) | Draws a filled box in screen
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
PUBLIC	CRT_BOXFILL
PROC	CRT_BOXFILL     FAR
ARG	x:WORD, y:WORD, x1:WORD, y1:WORD, color:WORD
USES	di,si

	mov	di,[color]
	mov	si,[x1]
	dec	si

	call	CRT_LINEX PASCAL, [x],[y],si,'Н',di
	call	CRT_LINEX PASCAL, [x],[y1],si,'Н',di
	call	CRT_LINEY PASCAL, [x],[y],[y1],'є',di
	call	CRT_LINEY PASCAL, si,[y],[y1],'є',di

	call	CRT_CHAR PASCAL, [x],[y],'Й',di
	call	CRT_CHAR PASCAL, si,[y],'»',di
	call	CRT_CHAR PASCAL, [x],[y1],'И',di
	call	CRT_CHAR PASCAL, si,[y1],'ј',di

	mov	ax,[x]		;-- crt_shadex(x+2,y1+1,x1+1)
	add	al,2
	mov	bx,[y1]
	inc	bx
	inc	si
	call	CRT_SHADEX PASCAL, ax,bx,si

	mov	ax,[y]		;--  shade_y(x1+1,y+1,y1+2)
	inc	ax
	mov	bx,[y1]
	add	bl,2
	call	CRT_SHADEY PASCAL, si,ax,bx
	dec	si

	inc	[x]

@@loopi:
	inc	[y]
	mov	bx,[y]
	mov	cx,[y1]

	cmp	cx,bx
	jae	@@bye

	call	CRT_LINEX PASCAL, [x],bx,si,' ',di
	jmp	@@loopi

@@bye:
	ret
ENDP

;ДДДДДДД END!! ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

ENDS
END
