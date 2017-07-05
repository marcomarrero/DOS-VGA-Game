;  ษออออออออออออออออออออออออออออออออออออออออป
;  บ	      VGA Graphics Library	    บ
;  บ	   Version 3.10 - 00/00/1995	    บ
;  บ----------------------------------------บ
;  บ Copyright (c) 1993,95 Marco A. Marrero บ
;  ศออออออออออออออออออออออออออออออออออออออออผ
;
; This thing uses the pascal calling convention, and all are FAR!!
; When I say "void far", it means a far pointer. All *must* be far.
; These are intended to be used in C++/C/Pascal modules. If you want
; a 100% assembler version, you should change the uses to several push
; or maybe pusha.

IDEAL			;-- Ideal mode, TASM specific
MODEL SMALL, PASCAL	;-- Small model, Pascal parameter stuff
LOCALS			;-- Local labels @@name (Automatic in Ideal)
P286                    ;-- 286 code, real mode.

CODESEG
ASSUME  cs:@code
P386

VGASEG	dw	0a000h		;-- VGA address
VGAOFS	dw	0


vgasize 	EQU	64000	;-- VGA 13h constants
vga4size	EQU	16000
vgawidth	EQU	320
vgalogwidth	EQU	320
vgaheight	EQU	200

mypal	db	768 dup(?)	;-- Working palette


;ฤฤฤฤฤฤฤฤ Functions ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

;ALIGN 4
;ษออออออออออออออออออออออออออออหอออออออออออออออออป
;บ VGA_PAL(color,r,g,b:byte)  บ Change palette	บ
;ศออออออออออออออออออออออออออออสอออออออออออออออออผ
PUBLIC	VGA_PAL
PROC	VGA_PAL		FAR
ARG	color:BYTE, red:BYTE, green:BYTE, blue:BYTE

	mov	dx,03C8h	;-- Palette address
	mov	al,[color]	;-- Color to modify
	out	dx,al		;-- Set.
	inc	dx

	mov	al,[red]	;-- Change colors...
	out	dx,al
	mov	al,[green]
	out	dx,al
	mov	al,[blue]
	out	dx,al

	ret
ENDP



;ALIGN 4
;ษออออออออออออออออหอออออออออออออออออออออออป
;บ MODE(num:word) บ Select graphics mode  บ
;ศออออออออออออออออสอออออออออออออออออออออออผ
PUBLIC	MODE
PROC	MODE		FAR
ARG	modenum:WORD

	mov	ax,[modenum]	;-- If you pass something > 255, won't work!
	int	10h		;-- Bacause ah must be 0.
	ret
ENDP




;ALIGN 4
;ษอออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ VGA_SYNCH(n:word) บ Wait for the vertical retrace, if is there wait nextบ
;ศอออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออผ
PUBLIC	VGA_SYNCH
PROC	VGA_SYNCH       FAR
ARG	delay:WORD

	mov	dx,03DAh	  ;-- status register
	mov	bl,8		    ;-- Bit to check...

	mov	cx,[delay]
	jcxz	@@last		;-- If cx=0, we just wait one.


ALIGN 4
@@skip_vr:			  ;-- Wait several
	in	al,dx
	test	al,bl
	jnz	@@skip_vr

ALIGN 4
@@wait_vr:
	in	al,dx
	test	al,bl
	jz	@@wait_vr
	loop	@@skip_vr

ALIGN 4
@@last:
	in	al,dx		;-- This is the one...
	test	al,bl
	jnz	@@last

ALIGN 4
@@last2:
	in	al,dx
	test	al,bl
	jz	@@last2
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออหออออออออออออออป
;บ CLS(color:byte) บ Clear screen บ
;ศอออออออออออออออออสออออออออออออออผ
PUBLIC	CLS
PROC	CLS             FAR
ARG	color:BYTE
USES	di

	mov	al,[color]	;-- Get color and shift it into 32 bit
	mov	ah,al
	mov	bx,ax
	shl	eax,16
	mov	ax,bx

	mov	cx,vga4size	;-- VGA size / 4

	mov	es,[vgaseg]	;-- Get screen address and offset
	mov	di,[vgaofs]

	rep	stosd		;-- Doublewords...
	ret
ENDP



;ALIGN 4
;ษออออออออออออออออออออออออออหอออออออออออออออออออออป
;บ VGA_ADDR(void far where) บ Set drawing address บ
;ศออออออออออออออออออออออออออสอออออออออออออออออออออผ
PUBLIC	VGA_ADDR
PROC	VGA_ADDR	FAR
ARG	where:DWORD

	les	bx,[where]	;-- Gee... I should put all these
	mov	[vgaofs],bx	;--- variables in the data segment
	mov	[vgaseg],es	;--- instead of making stupid routines!
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออออออออออออออหออออออออออออออออออออป
;บ PSET(x,y:integer color:byte)  บ Puts a nice pixel  บ
;ศอออออออออออออออออออออออออออออออสออออออออออออออออออออผ
PUBLIC	PSET
PROC	PSET            FAR
ARG	x1:WORD, y1:WORD, color:BYTE
USES	ds

	mov	bx,[y1] 	    ;--- y coordinate
	cmp	bx,vgaheight	;--- y clipping
	jge	@@bye

	shl	bx,6		      ;--- y*320
	lea	bx,[ebx+ebx*4]

	mov	ax,[x1] 	    ;--- x coordinate
	cmp	ax,vgawidth   ;--- x clipping
	jge	@@bye

	add	bx,ax		      ;-- x+(y*320) = address

	mov	ds,[vgaseg]	  ;-- VGA segment and offset
	add	bx,[vgaofs]	  ;-- (I can't assume screen start is zero)

	mov	al,[color]	  ;--- Color
	mov	[bx],al 	    ;--- Gee... All this for a single pixel?!?
@@bye:
  ret
ENDP




;ALIGN 4
;ษอออออออออออออออออออหออออออออออออออออออป
;บ n=POINT(int x,y)  บ Get pixel color	บ
;ศอออออออออออออออออออสออออออออออออออออออผ
PUBLIC	POINT
PROC	POINT           FAR
ARG	x1:WORD, y1:WORD
USES	ds

	mov	bx,[y1] 	    ;--- y coordinate
	cmp	bx,vgaheight	;--- clipping
	jge	@@bye

	shl	bx,6		      ;--- y*320
	lea	bx,[ebx+ebx*4]

	mov	dx,[x1] 	    ;--- get x coordinate
	cmp	dx,vgawidth	  ;--- clipping
	jge	@@bye

	add	bx,dx
	mov	ds,[vgaseg]	  ;--- VGA segment & offset
	add	bx,[vgaofs]

	mov	al,[bx] 	    ;--- Get pixel color

@@bye:
	ret
ENDP




;ALIGN 4
;ษออออออออออออออออออออออออออหออออออออออออออออออออออออออออออออออออออออออป
;บ GETSCREEN(void far dest) บ Copy VGA memory to RAM. CANNOT OVERLAP!  บ
;ศออออออออออออออออออออออออออสออออออออออออออออออออออออออออออออออออออออออผ
PUBLIC	GETSCREEN
PROC	GETSCREEN       FAR
ARG	dest:DWORD
USES	ds,si,di

	mov	ds,[vgaseg]	  ;-- VGA address
	mov	si,[vgaofs]
	les	di,[dest]	    ;-- Buffer address

	mov	cx,vga4size	  ;-- Screen size if DWORDS
	rep	movsd		      ;-- Data transfer
	ret
ENDP




;ALIGN 4
;ษออออออออออออออออออออออออหออออออออออออออออออออป
;บ PUTSCREEN(void far to) บ Copy RAM to VGA.   บ
;ศออออออออออออออออออออออออสออออออออออออออออออออผ
PUBLIC	PUTSCREEN
PROC	PUTSCREEN       FAR
ARG	dest:DWORD
uses	di,si,ds

	mov	es,[vgaseg]	  ;-- VGA address, destination
	mov	di,[vgaofs]

	lds	si,[dest]	    ;-- Buffer address, source

	mov	cx,vga4size
	rep	movsd
	ret
ENDP




;ALIGN 4
;ษอออออออออออออออออออออออออออออหออออออออออออออออออออออป
;บ VGAPUTSCREEN(void far dest) บ Copy RAM to REAL VGA.บ
;ศอออออออออออออออออออออออออออออสออออออออออออออออออออออผ
PUBLIC	VGAPUTSCREEN
PROC	VGAPUTSCREEN    FAR
ARG	dest:DWORD
USES	di,si,ds

	mov	ax,0a000h
	mov	es,ax		      ;-- VGA address, destination
	xor	di,di

	lds	si,[dest]	    ;-- Buffer address, source
	mov	cx,vga4size

	rep	movsd
	ret
ENDP





;ALIGN 4
;ษออออออออออออออออออออออออออออออออออออหออออออออออออออออออป
;บ BOXFILL(int x,y,x1,y1; byte color) บ Draw filled box  บ
;ศออออออออออออออออออออออออออออออออออออสออออออออออออออออออผ
PUBLIC	BOXFILL
PROC	BOXFILL         FAR
ARG	x1:WORD, y1:WORD, x2:WORD, y2:WORD, color:BYTE
USES	di,si

;--- y coordinates -----
	mov	di,[y1] 	;-- y1 coordinate
	mov	si,[y2] 	;-- y2 coordinate

	cmp	di,si		;-- if y>y1 then swap(y,y1)
	jle	@@box0
	xchg	di,si

@@box0:
  or	di,di		;-- if y<0 then y=0
	jns	@@box1
	xor	di,di

@@box1:
  mov	dx,vgaheight
	cmp	si,dx		;-- if y1>=MAXY then y1=MAXY-1
	jl	@@box2
	mov	si,dx
	dec	si

@@box2:
  cmp	di,dx		;-- if y>MAXY then exit
	jae	@@bye

	or	si,si		;-- if y2<0 then exit
	js	@@bye

	sub	si,di		;-- si = (y2-y) = Heigth!

;--- x coordinates ---
	mov	ax,[x1] 	;-- x1 coordinate
	mov	cx,[x2] 	;-- x2 coordinate
	mov	dx,vgawidth	;-- Screen logical width

	cmp	ax,cx		;-- if x>x1 then swap(x,y1)
	jle	@@box3
	xchg	ax,cx

@@box3:
  cmp	ax,dx		;-- if x>MAXX then exit
	jge	@@bye

	or	cx,cx		;-- if x1<0 then exit
	js	@@bye

	or	ax,ax		;-- if x<0 then x=0
	jns	@@box4
	xor	ax,ax

@@box4:
  cmp	cx,dx		;-- if x1>=MAXX then x1=MAXX-1
	jl	@@box5
	mov	cx,dx
	dec	cx

@@box5:
  inc	cx
	sub	cx,ax		;-- cx = (x1+1)-x = xwidth
	sub	dx,cx		;-- dx = MAXX-width = wrap

	shl	di,6
	lea	di,[edi+edi*4]
	add	di,ax            ;-- y*320+x = address

;--- dx=wrap, es:di=addr, bh=carry1, bl=carry2, si=height, eax=color ----
;--- bp=dword width --

	mov	al,[color]	;-- Convert color to 32 bit stuff
	mov	ah,al
	mov	bx,ax
	shl	eax,16
	mov	ax,bx

	mov	es,[vgaseg]	;-- es:di = screen address
	add	di,[vgaofs]

	inc	si		  ;-- heigth + 1

	xor	bx,bx		;-- Get carry bits...
	shr	cx,1
	adc	bl,bl		;-- bl = byte
	shr	cx,1
	adc	bh,bh		;-- bh = word

	push	bp		;-- Ideal quirk
	mov	bp,cx		;-- bp has width. (don't use local vars!!)

ALIGN 4
@@doit:
  rep	stosd		;-- store line
	add	cl,bh		;-- with the quadword trick.
	rep	stosw
	add	cl,bl
	rep	stosb

	mov	cx,bp		;-- restore width
	add	di,dx		;-- add wrap (y1++, pos=x1)

	dec	si		  ;-- Decrement height
	jnz	@@doit	;-- If not all, continue.
	pop	bp

@@bye:
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออป
;บ PUT(int x,y; void far buffer) บ Puts an image to screen (no clipping) บ
;ศอออออออออออออออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออผ
PUBLIC	PUT
PROC	PUT             FAR
ARG	x1:WORD, y1:WORD, buffer:DWORD
USES	ds,si,di

	push	bp		    ;-- Ideal mode quirk

	lds	si,[buffer]	;-- ds:si = buffer
	mov	es,[vgaseg]	;-- es:di = screen

	mov	di,[y1] 	  ;-- y coordinate
	shl	di,6		    ;-- y*320
	lea	di,[edi*4+edi]

	add	di,[x1] 	    ;-- di = y*320 + x coordinate

	mov	bp,vgawidth	  ;-- bp = wrap
	mov	cx,[ds:si]	  ;-- cx = width
	mov	ax,[ds:si+2]	;-- ax = heigth
	sub	bp,cx		      ;-- bp = screenwidth-putwidth

	add	si,4

	xor	dx,dx		;-- Convert cx to dword loop
	shr	cx,1		;-- Carry bits: dl=byte, dh=word
	adc	dl,dl
	shr	cx,1
	adc	dh,dh

	mov	bx,cx		;-- bx = width copy
	add	di,[vgaofs]

;--- dl=byte,  dh=word,  cx=work, ax=height, bx=width, es:di=screen ---
;-- ds:si=mem, bp=wrap --

ALIGN 4
@@plot:
  rep	movsd
	mov	cl,dh
	rep	movsw
	mov	cl,dl
	rep	movsb

	mov	cx,bx
	add	di,bp

	dec	ax
	jnz	@@plot

	pop	bp
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออออออออออออออออออออหออออออออออออออออออออออออออออออออออป
;บ GET(int x,y,x1,y1; void far buffer) บ Get image from screen (clipping) บ
;ศอออออออออออออออออออออออออออออออออออออสออออออออออออออออออออออออออออออออออผ
PUBLIC	GET
PROC	GET		FAR
ARG	x:WORD, y:WORD, x1:WORD, y1:WORD, buffer:DWORD
USES	ds,si,di

	push	bp		;-- Gosh... Ideal mode crashes if I use bp

	les	di,[buffer]	;-- es:di = buffer
	mov	ds,[vgaseg]	;-- ds:si = screen

	mov	si,[y]		;-- y coordinate
	mov	dx,[y1] 	;-- y1 coordinate

;--- Clipping ---
	cmp	si,dx
	jle	@@y_ok		;-- if y>y1 then swap(y,y1)
	xchg	si,dx

@@y_ok:
	mov	ax,199
	cmp	si,ax		;-- if y>199 then y=199
	jle	@@y1_ok
  mov	si,ax

@@y1_ok:
	cmp	dx,ax		;-- if y1>199 then y1=199
	jle	@@y2_ok
	mov	dx,ax

@@y2_ok:
	or	dx,dx		;-- if y1<0 then y1=0
	jns	@@y3_ok
	xor	dx,dx

@@y3_ok:
	or	si,si		;-- if y<0 then y=0
	jns	@@y4_ok
	xor	si,si

;--- End clipping ---
@@y4_ok:
	mov	bx,si		;-- bx = y coordinate
	shl	si,6		;-- y*320 = address
	lea	si,[esi*4+esi]

	mov	ax,[x]		;-- ax = x coordinate
	mov	cx,[x1] 	;-- cx = x1 coordinate

;--- Clipping ---
	cmp	ax,cx
	jle	@@x_ok		;-- If x>x1 then swap(x,x1)
	xchg	cx,ax

@@x_ok:

	mov	bp,319
	cmp	ax,bp		;-- if x>319 then x=319
	jle	@@x1_ok
	mov	ax,bp

@@x1_ok:
	or	ax,ax		;-- if x<0 then x=0
	jns	@@x2_ok
	xor	ax,ax

@@x2_ok:
	cmp	cx,bp		;-- if x1>319 then x1=319
	jle	@@x3_ok
	mov	cx,bp

@@x3_ok:
	or	cx,cx		;-- if x1<0 then x1=0
	jns	@@x4_ok
	xor	cx,cx

;--- End Clipping ---
@@x4_ok:
	add	si,ax		;-- es:si = y*320+x = screen addr
	sub	cx,ax		;-- cx = width = x1-x
	inc	cx

	mov	bp,dx		;-- y1 coordinate
	sub	bp,bx		;-- Height = y1-y
	inc	bp

	mov	[es:di],cx	;-- store width
	mov	[es:di+2],bp	;-- store height
	add	di,4

	mov	ax,320		;-- ax = wrap = 320-width
	sub	ax,cx

	mov	dx,0		;-- Convert cx to dword loop
	shr	cx,1		;-- Carry bits: dl=byte, dh=word
	adc	dl,dl
	shr	cx,1
	adc	dh,dh

	mov	bx,cx		;-- bx = width copy
	add	si,[vgaofs]

;--- dl=byte,  dh=word,  cx=work, ax=wrap, bx=width, es:di=screen ---
;-- ds:si=mem, bp=height --

ALIGN 4
@@plot:
  rep	movsd
	mov	cl,dh
	rep	movsw
	mov	cl,dl
	rep	movsb

	mov	cx,bx
	add	si,ax

	dec	bp
	jnz	@@plot

	pop	bp
	ret
ENDP





;ALIGN 4
;ษออออออออออออออออออออออออออออออออออหอออออออออออออออออออออออออออออออป
;บ READ_PCX(void far pcx,palette)   บ Read 320x200x256.PCX graphic  บ
;ศออออออออออออออออออออออออออออออออออสอออออออออออออออออออออออออออออออผ
PUBLIC	READ_PCX
PROC	READ_PCX        FAR
ARG	pcx:DWORD, pal:DWORD
USES	di,si,ds

	mov	di,[vgaofs]
	mov	es,[vgaseg]	;-- es:di = VGA screen

	lds	si,[pcx]	;-- ds:si = buffer in PCX format

	mov	al,1
	mov	ah,[ds:si]
	cmp	ah,0ah		;-- PCX header is 0ah
	jne	@@bye2

;       mov     al,2
;       mov     ah,[ds:si+3]
;       cmp     al,8            ;-- 8 bit image?
;       jne     @@bye2


	mov	bx,[ds:si+8]	;-- Xmax
	sub	bx,[ds:si+4]	;-- Xmin
	inc	bx

	mov	ax,[ds:si+10]	;-- Ymax
	add	ax,[ds:si+6]	;-- Ymin
	inc	ax

	mul	bx		;-- bx = ysize*xsize = Num Pixels
	mov	bx,ax

	add	si,128		;-- skip header

ALIGN 4
@@pcx:
  lodsb			    ;-- Get color or run-length

	mov	ah,al
	and	ah,0C0h 	;-- Determine run length
	cmp	ah,0C0h 	;---- Bits set??
	jne	@@norle 	;----- Nope. Plot one pixel

	and	al,03Fh 	;-- Determine run value
	xor	ch,ch		  ;-- cx = run length
	mov	cl,al

	lodsb			    ;-- Get color

	mov	ah,al		  ;-- And make it a 32 bit value
	mov	dx,ax		  ;--- so we'll plot 4 pixels at a time
	shl	eax,16
	mov	ax,dx

	mov	dx,0		  ;-- dx will have odd (bit 0) value
	shr	cx,1		  ;-- cx/2
	adc	dx,dx		  ;-- dx = 0 + carry (bit 0)
	shr	cx,1		  ;-- cx/2, (now cx=cx/4)

	rep	stosd		  ;-- Doublewords
	adc	cx,cx		  ;-- Add carry, 1 if (cx MOD 4=2)
	rep	stosw		  ;-- store word if present
	mov	cx,dx		  ;-- (dx=1 if was odd)
	rep	stosb		  ;-- store a byte IF present

	cmp	di,bx		  ;-- Got past end of screen??
	jbe	@@pcx		  ;--- Nope. Keep working.
	jmp	@@bye		  ;---- Outta here.

ALIGN 4
@@norle:
	stosb			    ;-- Store one miserable pixel
	cmp	di,bx		  ;-- Got past end of screen??
	jbe	@@pcx		  ;---- Nope. Do it again.

;-- Finished drawing image. Let's get palette in table ----

ALIGN 4
@@bye:
  les	di,[pal]	;-- es:di = Palette table address
	mov	cx,256		;-- 256 colors to copy


ALIGN 4
@@colr:
	mov	bl,3		;-- 3 entries, Red/Green/Blue

ALIGN 4
@@movp:
	lodsb
	shr	al,2
	stosb

	dec	bl
	jnz	@@movp

	loop	@@colr

	xor	ax,ax

@@bye2:
	ret
ENDP





;ALIGN 4
;ษออออออออออออออออออออออออออออออหอออออออออออออป
;บ DRAWTO(int x1,y1,x2,y2,color)บ Draws a lineบ
;ศออออออออออออออออออออออออออออออสอออออออออออออผ
PUBLIC	DRAWTO
PROC	DRAWTO          FAR
ARG	XStart:WORD, YStart:WORD, XEnd:WORD, Yend:WORD, Color:WORD
LOCAL	Adjup:WORD, AdjDown:WORD, WholeStep:WORD, XAdvance:WORD
USES	si,di,ds

	mov	ds,[vgaseg]
	mov	es,[vgaseg]

;-- We'll draw top to bottom, to reduce the number of cases we have to handle.
;-- and to make lines between the same endpoints always draw the same pixels.

	mov	ax,[YStart]
	cmp	ax,[YEnd]
	jle	@@LineIsTopToBottom

	xchg	[YEnd],ax	;-- swap endpoints
	mov	[YStart],ax
	mov	bx,[XStart]
	xchg	[XEnd],bx
	mov	[XStart],bx


@@LineIsTopToBottom:

	mov	dx,VGAWIDTH	; Point DI to the first pixel to draw.
	mul	dx		; YStart * SCREEN_WIDTH
	mov	si,[XStart]
	mov	di,si
	add	di,ax		; DI = YStart * WIDTH + XStart

;-- Figure out how far we're going vertically (guaranteed to be positive).

	mov	cx,[YEnd]
	sub	cx,[YStart]	; CX = YDelta

;-- Figure out whether we're going left or right, and how far we're going --
;-- horizontally. In the process. special-case vertical lines, for speed and --
;-- to avoid nesty boundary conditions and division by 0.

	mov	dx,[XEnd]
	sub	dx,si			        ; XDelta
	jnz	@@NotVerticalLine	; XDelta == 0 means vertical line

;-- Special case for vertical lines ---

	mov	ax,[color]
	add	di,[vgaofs]

ALIGN 4
@@Vloop:
	mov	[di],al
	add	di,VGAWIDTH
	dec	cx
	jns	@@Vloop
	jmp	@@done

;--  Special-case code for horizontal lines ---

ALIGN 4
@@IsHorizontalLine:
	mov	ax,[color]
	mov	ah,al		; Duplicate in high byte for word access
	and	bx,bx		      ; left to right?
	jns	@@DirSet	    ;-- yes
	sub	di,dx		      ; Now right to left, point to left end so we
				            ; can go left to right (avoids unpleasantness
	add	di,[vgaofs]	  ; with right to left REP STOSW)


@@DirSet:
	mov	cx,dx
	inc	cx		  ; # of pixels to draw
	shr	cx,1		; # of words to draw
	rep	stosw		; Do as many words as possible
	adc	cx,cx
	rep	stosb		; Do the odd byte. if there is one
	jmp	@@Done

;-- Special-case code for diagonal lines --

ALIGN 4
@@IsDiagonalline:
	mov	ax,[color]
	add	di,[vgaofs]
	add	bx,[vgawidth]	; Advance distance from one pixel to next

ALIGN 4
@@Dloop:
	mov	[di],al
	add	di,bx
	dec	cx
	jns	@@Dloop
	jmp	@@Done

ALIGN 4
@@NotVerticalLine:
	mov	bx,1		         ; assume left to right, so XAdvance = 1
				               ; ***leaves flags unchanged***
	jns	@@LeftToRight	   ; left to right. all set
	neg	bx		           ; right to left, so XAdvance = -1
	neg	dx		           ; |XDelta|


@@LeftToRight:
;--- Special-case hotizontal lines --
	and	cx,cx		; YDelta == 0?
	jz	@@IsHorizontalLine

;-- Special-case diagonal lines --
	cmp	cx,dx		; YDelta == XDelta?
	jz	@@IsDiagonalLine

;-- Determine whether the line is X or Y major, and handle accordingly ---
	cmp	dx,cx
	jae	@@XMajor
	jmp	@@YMajor

;-- X-major (more horizontal than vertical) line ---

ALIGN 4
@@XMajor:
	and	bx,bx		  ; Left to right?
	jns	@@DFSet 	; yes, CLD is already set
	std			      ; right to left. so draw backwards

ALIGN 4
@@DFSet:
	mov	ax,dx		; XDelta
	sub	dx,dx		; prepare for division
	div	cx		  ; AX=XDelta/YDelta
				      ; (minimum # of pixels in a run in this line)
				      ; DX= XDelta% YDelta
	mov	bx,dx		; error term adjust each time Y steps by 1;
	add	bx,bx		; used to tell when one extra pixel should be
	mov	[AdjUp],bx	; drawn as part of a run, to account for
				          ; fractional steps along the X axis per
				          ; 1-pixel steps along Y

	mov	si,cx		      ; error term adjust when the error term turns
	add	si,si		      ; over. used to factor out the X step made at
	mov	[AdjDown],si	; that time

;---- Initial error term: reflects an initial step of 0.5 along the Y axis ---
	sub	dx,si		      ; (Xdelta% YDelta)- (YDelta* 2)
				            ; DX = initial error term
;-- The initial and last runs are partial. because Y advances only 0.5 for
;-- these runs. rather than 1. Divide one full run, plus the initial pixel.
;-- between the initial and last runs.

	mov	si,cx		; SI=Ydelta
	mov	cx,ax		; whole step (minimum run length)
	shr	cx,1
	inc	cx		  ; initial pixel count = (whole step / 2) +1;
				      ; (may be adjusted later). This is also the
				      ; final run pixel count
	push	cx		; remember final run pixel count for later

;-- If the basic run length is even and there's no fractional advance, we have
;-- one pixel that could go to either the initial or last partial run, which
;-- we'll arbitrarily allocate to the last run.

;--If there is an odd number of pixels per run, we have one pixel that can't
;-- be allocated to either the initial or last partial run, so we'll add 0.5 to
;-- the error term so this pixel will be handled by the normal full-run loop.

	add	dx,si		     ; assume odd length, add YDelta to error term
				           ; (add 0.5 of a pixel to the error term)
	test	al,1		   ; Is run length even?
	jnz	@@XMajorAdjustDone ; no, already did work for odd case, all set
	sub	dx,si		; Length is even, undo odd stuff we just did
	and	bx,bx		; is the adjust up equal to 0?
	jnz	@@XMajorAdjustDone ; No (don't need to check for odd length.
				   ; because of the above test)
	dec	cx		; Both conditions met: make initial run 1
				; shorter


@@XMajorAdjustDone:
	mov	[WholeStep],ax	; whole step (minimum run length)
	mov	ax,[color]	    ; AL=drawingcolor
	add	di,[vgaofs]

;-- Draw the first, partial run of pixels --
       rep	stosb		  ; draw the final run
       add	di,VGAWIDTH	; advance along rhe minor axis (Y)

;-- Draw all full runs --
	cmp	si,1		; Are there more than 2 scans. so there are
				      ; some full runs? (SI = # scans 1)
	jna	@@XMajorDrawLast	; no, no full runs
	dec	dx		                    ; adjust error term by -1 so we can use
				                        ; carry test
	shr	si,1		                  ; convert from scan to scan-pair
	jnc	@@XMajorFullRunsOddEntry	;if there is an odd number
						                    ; do the odd scan now

ALIGN 4
@@XMajorFullRunsLoop:
	mov	cx,[WholeStep]	; run is at least this long
	add	dx,bx		; advance the error term and add an extra
	jnc	@@XMajorNoExtra ; pixel if the error term so indicates
	inc	cx		; one eXtra pixel in run
	sub	dx,[AdjDown]	; reset the error term


@@XMajorNoExtra:
	rep	stosb		; Draw this scan line's run
	add	di,VGAWIDTH	; advance along the minor axis (Y)


@@XMajorFullRunsOddEntry:	; enter loop here if there is an odd number
				; of full runs
	mov	cx,[WholeStep]	; run is at least this long
	add	dx,bx		; advance the error term and add an extra
	jnc	@@XMajorNoExtra2 ; pixel if the error term so indicates
	inc	cx		 ; one extra pixel in run
	sub	dx,[AdjDown]	 ; reset the error term


@@XMajorNoExtra2:
	rep	stosb		      ; draw this scan line's run
	add	di,VGAWIDTH	  ; advance along the minor axis (Y)
	dec	si
	jnz	@@XMajorFullRunsLoop

;--- Draw the final run of pixels ---

@@XMajorDrawLast:
	pop	cx		; get back the final run pixel length
	rep	stosb		; draw the final run

	cld			; restore normal direction flag
	jmp	@@Done

;--- Y-major (more vertical than horizontal) line --
ALIGN 4
@@YMajor:
	mov	[XAdvance],bx	; remember which way X advances
	mov	ax,cx		; YDelta
	mov	cx,dx		; XDelta
	sub	dx,dx		; prepare for divisibn
	div	cx		; AX=YDelta/XDelta
				; (minimum # of pixels in a run in this line)
				; DX= YDelta% XDelta
	mov	bx,dx		; error term adjust each time X steps by 1;
	add	bx,bx		; used to tell when one extra pixel should be
	mov	[AdjUp],bx	; drawn as part of a run, to account for
				; fractional steps along the Y axis per
				; 1-pixel steps along X
	mov	si,cx		; error term adjust when the error term turns
	add	si,si		; over, used to factor out the Y step made at
	mov	[AdjDown],si	; that time

;-- Initial error term: reflects an initial step of 0.5 along the X axis --
	sub	dx,si		; (YDelta 8 XDelta) - (XDelta * 2)
				; DX = initial error term
;-- The initial and last runs are partial, because X advances only 0.5 for --
;-- these runs, rather than 1. Divide one full run, plus the initial pixel.
;-- between the initial and last runs.

	mov	si,cx		; SI=XDelta
	mov	cx,ax		; whole step (minimum run length)
	shr	cx,1
	inc	cx		; initial pixel count = (whole step / 2) +1:
				; (may be adjusted later)
	push	cx		; remember final run pixel count for later

;-- If the basic run lenght is even and there's no fractional advance,
;-- we have one pixel that could go to either the initial or last
;-- partial run, which we'll arbitrarily allocate to the last run
;--If there is an odd number of pixels per run, we have one pixel that can't
;-- be allocated to either the initial or last partial run, so we'll add 0.5 to
;-- the error term so this pixel will be handled by the normal full-run loop.

	add	dx,si		; assume odd length, add XDelta to error term
	test	al,1		; ir run length even?
	jnz	@@YMajorAdjustDone	; no, already did work for odd case.	   dx.si	      :length is even, undo odd stuff we just

	sub	dx,si		; Length is even, undo odd stuff we did
	and	bx,bx		; is the adjust up equal to 0?
	jnz	@@YmajorAdjustDone	; no (don't need to check for odd
					; length because of the above test)
	dec	cx			; both conditions met: make initial run
					; shorter

@@YMajorAdjustDone:
	mov	[WholeStep],ax	; Whole step (minimum run length)
	mov	ax,[color]	; AL = drawing color
	add	di,[vgaofs]
	mov	bx,[XAdvance]	; which way X advances

;--- Draw the first, partial run of pixels ---
@@YmajorFirstloop:
	mov	[di],al 	; draw the pixel
	add	di,VGAWIDTH	; advance along the major axis'(Y)
	dec	cx
	jnz	@@YMajorFirstLoop
	add	di,bx		; advance along the minor axis (X)
;-- Draw all full runs --
	cmp	si,1		; # of full runs. Are there more than 2
				; columns, so there are some full runs?
				; (SI=#columns -1)
	jna	@@YMajorDrawLast	; no, no full runs
	dec	dx		; adjust error term by -1 so we can use
				; carry test
	shr	si,1		; convert from column to column-pair count
	jnc	@@YMajorFullRunsOddEntry	; if there is an odd number of
						; columns, do the odd column

@@YMajorFullRunsLoop:
	mov	cx,[WholeStep]	; run is at least this long
	add	dx,[AdjUp]	; advance the error term and add an extra
	jnc	@@YmajorNoExtra ; pixel if the error term so indicates
	inc	cx		; one extra pixel in run
	sub	dx,[AdjDown]	; reset the error term

@@YmajorNoExtra:
				; draw the run
ALIGN 4
@@YmajorRunloop:
	mov	[di],al 	; draw the pixel
	add	di,VGAWIDTH	; advance along the major axis (Y)
	dec	cx
	jnz	@@YMajorRunLoop
	add	di,bx		; advance along the minor axis (X)

ALIGN 4
@@YMajorFullRunsOddEntry:	; enter loop here if there is an odd number
				; of full runs
	mov	cx,[WholeStep]	; run is at least this long
	add	dx,[AdjUp]	; advance the error term and add an ext
	jnc	@@YMajorNoExtra2	; pixel if the error term so indicates
	inc	cx		; one extra pixel in run
	sub	dx,[AdjDown]	; reset the error term

@@YmajorNoExtra2:
				;draw the run
ALIGN 4
@@YmajorRunloop2:
	mov	[di],al 	; draw the pixel
	add	di,VGAWIDTH	; advance along the_major Rxis (Y)
	loop	@@YmajorRunloop2
	add	di,bx		; advance along the minor axis (X)

	dec	si
	jnz	@@YMajorFullRunsLoop

;-- Draw the final run of pixels.
@@YMajorDrawLast:
	pop	cx		; get back the final run pixel length

ALIGN 4
@@YMajorlastloop:
	mov	[di],al 	; draw the pixel
	add	di,VGAWIDTH	; advance along the major axis (Y)
	loop	@@YmajorLastLoop
@@Done:
	cld
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออออออออออออออหอออออออออออออออออออออออออออออออป
;บ LINE(int x1,y1,x2,y2, color)  บ Draws a line w/ clipping!!	 บ
;ศอออออออออออออออออออออออออออออออสอออออออออออออออออออออออออออออออผ
PUBLIC	LINE
PROC	LINE            FAR
ARG	clip_x1:WORD, clip_y1:WORD, clip_x2:WORD, clip_y2:WORD, color:WORD
USES	ds,si,di
LOCAL	clip_swap:BYTE:2

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
; Sutherland-Cohen clipping algorithm implemented in assembler
; Programmed by Engel Sanchez of Trilogy, damaged by Marco A. Marrero
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

left_code	equ	01h
above_code	equ	02h
right_code	equ	04h
below_code	equ	08h
d		equ	dword ptr

;-- empieza el mambo --
	mov	[clip_swap],0	; marca no ha habido intercambio

;-- bl=codigo de punto 1
;-- bh=codigo de punto 2


@@repeat:
	xor	bx,bx			;cero en bl y bh (futuros codigos)
	mov	ax,[clip_x1]		;ax=x1
	or	ax,ax			;es x1 negativo?
	jns	@@no_left_1		;si no,no marques
	or	bl,left_code		;si lo es. marca punto a la izquierda

@@no_left_1:
	cmp	ax,320			;esta a la derecha?
	jl	@@no_right_1		;no? pues no marques nada
	or	bl,right_code		;si, pues marca punto a la derecha


@@no_right_1:
	mov	ax,[clip_y1]		;ax=y1
	or	ax,ax			;es y1 negativo?
	jns	@@no_above_1		;no lo es, no marques nada
	or	bl,above_code		;si, pues marca punto arriba


@@no_above_1:
	cmp	ax,200			;es y1 muy grande?
	jl	@@no_below_1		;no, pues no marques
	or	bl,below_code		;si, pues marca punto abajo

@@no_below_1:

;-- ahora trabajemos con el segundo punto --

	mov	ax,[clip_x2]		;ax=x2
	or	ax,ax			;es x2 negativo?
	jns	@@no_left_2		;no, pues no marques
	or	bh,left_code		;si. marca punto 2 a la izquierda

@@no_left_2:
	cmp	ax,320			;es x2 muy grande?
	jl	@@no_right_2		;no lo es, no marques
	or	bh,right_code		;si. marca punto 2 a la derecha

@@no_right_2:
	mov	ax,[clip_y2]		;ax=y2
	or	ax,ax			;es y2 negativa?
	jns	@@no_above_2		;no lo es, no marques
	or	bh,above_code		;si.marca punto 2 arriba

@@no_above_2:
	cmp	ax,200			;es y2 muy grande?
	jl	@@no_below_2		;no lo es. no marques
	or	bh,below_code		;si. marca punto 2 abajo

@@no_below_2:

;-- prueba a ver si la linea esta adentro o afuera
;-- si el "or" logico es cero,esta adentro(los dos adentro)
;-- si el 'and' logico es diferente de cero, toda la linea se omite

	mov	ax,bx			;copia de los codigos
	or	al,bh			;al=or logico
	jnz	@@1
	jmp	@@clip_in		;si or logico=0, linea adentro

ALIGN 4
@@1:	and	ah,bl			;ah=and logico
	jz	@@2
	jmp	@@clip_out		;no es cero, toda la linea se omite

;-- intercambia p1 y p2 si p1 esta adentro --

ALIGN 4
@@2:	or	bl,bl			;esta p1 adentro(bl==0?)
	jnz	@@clip_no_swap		;no, continua
	mov	ax,[clip_x1]		;procede al intercambio
	xchg	ax,[clip_x2]		;x1 en x2
	xchg	ax,[clip_x1]		;x2 en x1
	mov	ax,[clip_y1]		;
	xchg	ax,[clip_y2]		;y1 en y2
	xchg	ax,[clip_y1]		;y2 en y1
	xor	[clip_swap],1		;marca swap (flip,1 intercambiados,0 no)
	xchg	bl,bh			;intercambia codigos tambien

ALIGN 4
@@clip_no_swap:
@@clip_left:

	test	bl,left_code		;esta a la izquierda?
	jz	@@clip_above		;no,continua

	mov	ax,[clip_y2]
	sub	ax,[clip_y1]		;ax=y2-y1
	mov	cx,[clip_x1]
	neg	cx			;cx=(xul-x1)
	imul	cx			;dx:ax=(y2-y1)(xul-x1)
	add	cx,[clip_x2]		;cx=(x2-x1)
	idiv	cx			;ax=(y2-y1)(xul-x1)/(x2-x1)
	add	[clip_y1],ax		;y1+=(y2-y1)(xul-x1)/(x2-x1)
	mov	[clip_x1],0		;x1=xul
	jmp	@@repeat		;calcula todo de nuevo

ALIGN 4
@@clip_above:
	test	bl,above_code		;esta arriba?
	jz	@@clip_right		;no,continua

	mov	ax,[clip_x2]
	sub	ax,[clip_x1]		;ax=(x2-x1)
	mov	cx,[clip_y1]
	neg	cx			;cx=(yul-y1)
	imul	cx			;dx:ax=(x2-x1)(yul-y1)
	add	cx,[clip_y2]		;cx=(y2-y1)
	idiv	cx			;ax=(x2-x1)(yul-y1)/(y2-y1)
	add	[clip_x1],ax		;x1+=^^^^^^^^^^^^^^^^^^^^^^
	mov	[clip_y1],0		;y1=yul
	jmp	@@repeat		;otra iteracion

ALIGN 4
@@clip_right:
	test	bl,right_code		;esta a la derecha?
	jz	@@clip_below		;no,continua.

	mov	ax,[clip_y2]
	sub	ax,[clip_y1]		;ax=y2-y1
	mov	di,320
	dec	di			;di=xlr
	mov	cx,di			;cx=xlr
	mov	si,[clip_x1]		;si=x1
	sub	cx,si			;cx=(xlr-x1)
	imul	cx			;dx:ax=(y2-y1)(xlr-x1)
	mov	cx,[clip_x2]
	sub	cx,si			;cx=x2-x1
	idiv	cx			;ax=(y2-y1)(xlr-x1)/(x2-x1)
	add	[clip_y1],ax		;y1+=^^^^^^^^^^^^^^^^^^^^^
	mov	[clip_x1],di		;x1=xlr
	jmp	@@repeat

ALIGN 4
@@clip_below:
	;-- no se necesita prueba --

	mov	ax,[clip_x2]
	sub	ax,[clip_x1]		;ax=x2-x1
	mov	di,200
	dec	di			;di=ylr
	mov	cx,di			;di=ylr
	mov	si,[clip_y1]		;si=y1
	sub	cx,si			;cx=ylr-y1
	imul	cx			;dx:ax=(ylr-y1)(x2-x1)
	mov	cx,[clip_y2]		;cx=y2
	sub	cx,si			;cx=y2-y1
	idiv	cx			;ax=(ylr-y1)(x2-x1)/(y2-y1)
	add	[clip_x1],ax		;x1+=^^^^^^^^^^^^^^^^^^^^^
	mov	[clip_y1],di		;y1=ylr
	jmp	@@repeat

ALIGN 4
@@clip_in:
	xor	ax,ax			;todo bien,devuelve cero
	mov	bl,[clip_swap]
	or	bl,bl			;estan intercambiados?
	jz	@@clip_no_swap_again

;-- swap again ---

	mov	ax,[clip_x1]		;procede al intercambio
	xchg	ax,[clip_x2]		;x1 en x2
	xchg	ax,[clip_x1]		;x2 en x1
	mov	ax,[clip_y1]		;
	xchg	ax,[clip_y2]		;y1 en y2
	xchg	ax,[clip_y1]		;y2 en y1

@@clip_no_swap_again:
@@clip_out:
	call DRAWTO PASCAL, [clip_x1],[clip_y1],[clip_x2],[clip_y2],[color]
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออออออออออออออหออออออออออออออออออออออออออออป
;บ HLINE(int x,y,x1; char color) บ Horizontal line (clipping) บ
;ศอออออออออออออออออออออออออออออออสออออออออออออออออออออออออออออผ
PUBLIC	HLINE
PROC	HLINE           FAR
ARG	x:WORD, y:WORD, x1:WORD, color:BYTE
USES	di

	mov	es,[vgaseg]

	mov	di,[y]		;-- y coordinate
	or	di,di
	js	@@bye		;-- exit if negative
	cmp	di,vgaheight	;-- exit if out of bounds
	jge	@@bye

	shl	di,6		;-- di*320
	lea	di,[edi*4+edi]

	mov	ax,[x]		;-- ax = x coordinate
	mov	cx,[x1] 	;-- cx = x1 coordinate

	cmp	ax,cx		;-- Swap if x>x1
	jle	@@x_ok
	xchg	ax,cx

@@x_ok:
	or	ax,ax		;-- Let's check x coordinate
	jns	@@xl_ok 	;-- If negative, set to zero
	xor	ax,ax

@@xl_ok:
	cmp	ax,vgawidth	;-- If x>320 then is not on screen
	jge	@@bye

	or	cx,cx		;-- Let's check x1
	js	@@bye		;-- If x1 is negative, no line
	cmp	cx,vgawidth
	jl	@@xr_ok 	;-- If x1>319 then x1=319
	mov	cx,vgawidth
	dec	cx

@@xr_ok:
	sub	cx,ax		;-- cx = distance = x1 - x
	inc	cx

	add	di,ax		;-- di = vga screen address

	mov	al,[color]	;-- Let's make color 32 bit value
	mov	ah,al
	mov	bx,ax
	shl	eax,16
	mov	ax,bx

	add	di,[vgaofs]

	xor	dx,dx		;-- Let's prepare doubleword transfer --
	shr	cx,1
	adc	dx,dx		;-- dx = odd result (byte remainder)
	shr	cx,1

	rep	stosd		;-- Doublewords
	adc	cx,cx		;-- Add carry from last "shr" if result/2
	rep	stosw
	mov	cx,dx
	rep	stosb

@@bye:
	ret
ENDP



;ALIGN 4
;ษอออออออออออออออออออออออออออออออหออออออออออออออออป
;บ VLINE(int x,y,y1; char color) บ Vertical line  บ
;ศอออออออออออออออออออออออออออออออสออออออออออออออออผ
PUBLIC	VLINE
PROC	VLINE           FAR
ARG	x:WORD, y:WORD, y1:WORD, color:BYTE
USES	ds

	mov	ds,[vgaseg]

	mov	bx,[y]		;-- bx = y coordinate
	mov	cx,[y1] 	;-- cx = y1 coordinate

	cmp	bx,cx		;-- If y>y1 the swap(y,y1)
	jle	@@y_ok
	xchg	bx,cx

@@y_ok:
	or	bx,bx		;-- If y<0 then y=0
	jns	@@yt_ok
	xor	bx,bx

@@yt_ok:
	cmp	cx,vgaheight	;-- if y1>200 then y1=199
	jl	@@yb_ok
	mov	cx,vgaheight
	dec	cx

@@yb_ok:
	cmp	bx,vgaheight	;-- If y>200 then bye
	jge	@@bye
	or	cx,cx		;-- If y1<0 then bye
	js	@@bye

	sub	cx,bx		;-- distance = (y1 - y) +1
	inc	cx

	shl	bx,6		;-- bx*320
	lea	bx,[ebx*4+ebx]

	mov	ax,[x]		;-- x coordinate
	or	ax,ax
	js	@@bye		;-- If (x<0) or (x>319) then bye
	cmp	ax,vgawidth
	jge	@@bye

	add	bx,ax		;-- bx = (y*320)+x = address

	mov	al,[color]	;-- al = color
	mov	dx,320		;-- vertical adder

	add	bx,[vgaofs]

@@plot:
	mov	[bx],al
	add	bx,dx
	loop	@@plot

@@bye:
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออออออออออออหออออออออออออออออออออออออออออออป
;บ CPUT(int x,y; void far buf) บ Puts an image with clipping! บ
;ศอออออออออออออออออออออออออออออสออออออออออออออออออออออออออออออผ
PUBLIC	CPUT
PROC	CPUT            FAR
ARG	x1:WORD, y1:WORD, buf:DWORD
USES	ds,si,di

	push	bp		;-- Ideal mode quirk

	lds	si,[buf]	;-- ds:si = buffer
	mov	es,[vgaseg]
	mov	di,[vgaofs]	;-- es:di = vga screen

	mov	cx,[ds:si]	;-- cx = width
	inc	si
	inc	si
	lodsw			;-- ax = height

	mov	bx,[y1] 	;-- y1 coordinate
	mov	dx,bx		;-- in dx too...

	or	bx,bx
	jge	@@yt_ok 	;-- if bx<0 then fix(y top)

;;--- Let's fix y coordinate (top) ---

	neg	bx		;-- bx = y = is positive
	sub	ax,bx		;-- Substract excess (bx is negative)
	jbe	@@bye		;-- If <=0 there's no image!

	xchg	bx,ax		;-- ax=bx, bx=ax (ax has excess portion)
	mul	cx		;-- unseen part*width
	add	si,ax		;-- add to buffer to avoid displaying it
	mov	ax,bx		;-- restore height..

	xor	bx,bx		;-- Top starts at coordinate 0
	xor	dx,dx

@@yt_ok:
	add	dx,ax		;-- dx = y1 + height = y2 (bottom)
	sub	dx,VGAHEIGHT	;-- y2=y2-200
	js	@@yb_ok 	;-- if negative, y2<199

;--- Let's fix y1 coordinate (bottom) ---
	sub	ax,dx		;-- Substract value from total heigth
	jbe	@@bye		;-- If negative, no image is seen!

@@yb_ok:
	mov	ah,al		;-- ah = height (must be less than 255)

	shl	bx,6
	lea	bx,[ebx+ebx*4]	;-- Compute y address
	add	di,bx		;---- and add it to vgaofs

	mov	bx,[x1] 	;-- bx = x coordinate/left. Working value
	mov	dx,bx		;-- dx = x coordinate, final result.

	or	bx,bx		;-- if x>=0 then check for right part
	jge	@@xl_ok 	;--- otherwise, let's clip...

;;--- Clip x (left) --	Update xadd (unseen left+right of image) --

	neg	bx		;-- -(-x) = x is positive, and it's xadd
	add	si,bx		;-- Add to image source (unseen left part)
	sub	cx,bx		;-- Substract to width
	jbe	@@bye		;---- if width <=0 there's nothing!

	xor	dx,dx		;-- x coordinate is zero
	jmp	@@x_done	;-- We don't need to check right side

@@xl_ok:
	add	bx,cx		;-- bx= x + width = x1
	sub	bx,VGAWIDTH	;-- bx= x1 - 320 = unseen portion less 1
	js	@@xr_ok

;---- Fix x1 (right) -- bx will be xadd (unseen left+right) ---

	sub	cx,bx		;-- width -= unseen part
	jbe	@@bye		;-- if width <0, there's nothing!
	jmp	@@x_done

@@xr_ok:
	xor	bx,bx

@@x_done:
	add	di,dx		;-- Update x position

	mov	dx,VGAWIDTH	;-- let's calculate wrap (320-width)
	sub	dx,cx		;-- So, we can step down the screen!

	xor	al,al		;-- al will tell if image size is odd
	shr	cx,1		;-- width / 2
	adc	al,al		;-- add carry (remainder bit) to al. 1 or 0

	mov	bp,cx		;-- We need to save original half-width

ALIGN 4
@@rockin:
	shr	cx,1		;-- cx = width / 4
	rep	movsd
	adc	cl,cl
	rep	movsw
	mov	cl,al
	rep	movsb

	add	di,dx		;-- add wrap (320-width = pos(x,y+1) )
	mov	cx,bp		;-- got back original half-width
	add	si,bx		;- added xadd (unseen from left+right)

	dec	ah		  ;-- height
	jnz	@@rockin

@@bye:
	pop	bp
	ret
ENDP




;ALIGN 4
;ษอออออออออออออออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออป
;บ CPASTE(int x,y; void far buf) บ Puts an image with clipping and mask! บ
;ศอออออออออออออออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออผ
PUBLIC	CPASTE
PROC	CPASTE          FAR
ARG	x1:WORD, y1:WORD, buf:DWORD
USES	di,di,ds

	push	bp		;-- Ideal mode quirk

	lds	si,[buf]	;-- ds:si = buffer
	mov	es,[vgaseg]
	mov	di,[vgaofs]	;-- es:di = vga screen

	mov	cx,[ds:si]	;-- cx = width
	inc	si
	inc	si
	lodsw			;-- ax = height

	mov	bx,[y1] 	;-- y1 coordinate
	mov	dx,bx		;-- in dx too...

	or	bx,bx
	jge	@@yt_ok 	;-- if bx<0 then fix(y top)

;;--- Let's fix y coordinate (top) ---

	neg	bx		;-- bx = y = is positive
	sub	ax,bx		;-- Substract excess (bx is negative)
	jbe	@@bye		;-- If <=0 there's no image!

	xchg	bx,ax		;-- ax=bx, bx=ax (ax has excess portion)
	mul	cx		;-- unseen part*width
	add	si,ax		;-- add to buffer to avoid displaying it
	mov	ax,bx		;-- restore height..

	xor	bx,bx		;-- Top starts at coordinate 0
	xor	dx,dx

@@yt_ok:
	add	dx,ax		;-- dx = y1 + height = y2 (bottom)
	sub	dx,VGAHEIGHT	;-- y2=y2-200
	js	@@yb_ok 	;-- if negative, y2<199

;--- Let's fix y1 coordinate (bottom) ---
	sub	ax,dx		;-- Substract value from total heigth
	jbe	@@bye		;-- If negative, no image is seen!

@@yb_ok:
	mov	ah,al		;-- ah = height (must be less than 255)

	shl	bx,6
	lea	bx,[ebx+ebx*4]	;-- Compute y address
	add	di,bx		;---- and add it to vgaofs

	mov	bx,[x1] 	;-- bx = x coordinate/left. Working value
	mov	dx,bx		;-- dx = x coordinate, final result.

	or	bx,bx		;-- if x>=0 then check for right part
	jge	@@xl_ok 	;--- otherwise, let's clip...

;;--- Clip x (left) --	Update xadd (unseen left+right of image) --

	neg	bx		;-- -(-x) = x is positive, and it's xadd
	add	si,bx		;-- Add to image source (unseen left part)
	sub	cx,bx		;-- Substract to width
	jbe	@@bye		;---- if width <=0 there's nothing!

	xor	dx,dx		;-- x coordinate is zero
	jmp	@@x_done	;-- We don't need to check right side

@@xl_ok:
	add	bx,cx		;-- bx= x + width = x1
	sub	bx,VGAWIDTH	;-- bx= x1 - 320 = unseen portion less 1
	js	@@xr_ok

;---- Fix x1 (right) -- bx will be xadd (unseen left+right) ---
	sub	cx,bx		;-- width -= unseen part
	jbe	@@bye		;-- if width <0, there's nothing!
	jmp	@@x_done

@@xr_ok:
	xor	bx,bx

@@x_done:
	add	di,dx		        ;-- Update x position

	mov	dx,VGAWIDTH	    ;-- let's calculate wrap (320-width)
	sub	dx,cx		        ;-- So, we can step down the screen!
	mov	bp,cx	          ;-- We need to save original half-width

ALIGN 4
@@rockin:
	lodsb			          ;-- get pixel value
	cmp	al,0		        ;-- if zero, skip
	jz  @@skip

	mov	 [es:di],al	    ;-- store if nonzero
  inc  di
  loop @@rockin
	add	 di,dx	        ;-- add wrap (320-width = pos(x,y+1) )
	mov	 cx,bp          ;-- got back original half-width
	add	 si,bx          ;- added xadd (unseen from left+right)

	dec	ah		          ;-- height
	jnz	@@rockin
  jmp @@bye


ALIGN 4
@@skip:
	inc	di	      	;-- increment screen position
	loop	@@rockin	;-- loop until all done

	add	di,dx		    ;-- add wrap (320-width = pos(x,y+1) )
	mov	cx,bp		    ;-- got back original half-width
	add	si,bx		    ;- added xadd (unseen from left+right)

	dec	ah		      ;-- height
	jnz	@@rockin

@@bye:
	pop	bp
	ret
ENDP




;ALIGN 4
;ษออออออออออออออออออออออออออหออออออออออออออออออออออออออป
;บ BOX(int x,y,x1,y1,color) บ  Draws a box w/ clipping บ
;ศออออออออออออออออออออออออออสออออออออออออออออออออออออออผ
PUBLIC	BOX
PROC	BOX             FAR
ARG	x:WORD, y:WORD, x1:WORD, y1:WORD, color:WORD
USES	si,di

	mov	si,[y]		;-- si = y coordinate
	mov	di,[y1] 	;-- di = y1 coordinate

	call	HLINE PASCAL,[x],si,[x1],[color]
	call	HLINE PASCAL,[x],di,[x1],[color]
	call	VLINE PASCAL,[x],si,di,[color]
	call	VLINE PASCAL,[x1],si,di,[color]
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออออออออออออออออออออออหออออออออออออออออออป
;บ BOXFILLADD(int x,y,x1,y1; char adder) บ Draw "shadebob"  บ
;ศอออออออออออออออออออออออออออออออออออออออสออออออออออออออออออผ
PUBLIC	BOXFILLADD
PROC	BOXFILLADD      FAR
ARG	x:WORD, y:WORD, x1:WORD, y1:WORD, adder:BYTE
USES	di,si

	push	bp		;-- Ideal mode quirk

;--- y coordinates -----
	mov	di,[y]		;-- y coordinate
	mov	si,[y1] 	;-- y1 coordinate

	cmp	di,si		;-- if y>y1 then swap(y,y1)
	jle	@@box0
	xchg	di,si

@@box0: or	di,di		;-- if y<0 then y=0
	jns	@@box1
	xor	di,di

@@box1: mov	dx,vgaheight

	cmp	si,dx		;-- if y1>=MAXY then y1=MAXY-1
	jl	@@box2
	mov	si,dx
	dec	si

@@box2: cmp	di,dx		;-- if y>MAXY then exit
	jae	@@bye

	or	si,si		;-- if y2<0 then exit
	js	@@bye

	sub	si,di		;-- si = (y2-y) = Heigth!

;--- x coordinates ---
	mov	ax,[x]		;-- x coordinate
	mov	cx,[x1] 	;-- x1 coordinate
	mov	dx,vgawidth	;-- Screen logical width

	cmp	ax,cx		;-- if x>x1 then swap(x,y1)
	jle	@@box3
	xchg	ax,cx

@@box3: cmp	ax,dx		;-- if x>MAXX then exit
	jge	@@bye

	or	cx,cx		;-- if x1<0 then exit
	js	@@bye

	or	ax,ax		;-- if x<0 then x=0
	jns	@@box4
	xor	ax,ax

@@box4: cmp	cx,dx		;-- if x1>=MAXX then x1=MAXX-1
	jl	@@box5
	mov	cx,dx
	dec	cx

@@box5: inc	cx
	sub	cx,ax		;-- cx = (x1+1)-x = xwidth
	sub	dx,cx		;-- dx = MAXX-width = wrap

	shl	di,6
	lea	di,[edi+edi*4]
	add	di,ax		;-- y*320+x = address

;--- dx=wrap, es:di=addr, bh=carry1, bl=carry2, si=height, eax=color ----
;--- bp=dword width --

	mov	al,[adder]	;-- Convert adder to 32 bit stuff
	mov	ah,al
	mov	bx,ax
	shl	eax,16
	mov	ax,bx

	mov	es,[vgaseg]	;-- es:di = screen address
	add	di,[vgaofs]

	inc	si		;-- heigth + 1

	xor	bx,bx		;-- Get carry bits... First clear bx.

	shr	cx,1		;-- width / 2
	adc	bl,bl		;-- bl = byte

	shr	cx,1		;-- width / 2 (now width / 4)
	adc	bh,bh		;-- bh = word

	mov	bp,cx		;-- bp=cx

@@doit0:
	jcxz	@@skip1 	;-- Skip if not in Dwords

@@doit1:
	add	[es:di],eax	;-- Add to color...
	add	di,4		;-- Increment
	loop	@@doit1

@@skip1:
	mov	cl,bh		;-- Number of words
	jcxz	@@skip2 	;-- Skip if not a Word
	add	[es:di],ax
	add	di,2

@@skip2:
	mov	cl,bl		;-- Number of bytes
	jcxz	@@skip3 	;-- If any... You know...
	add	[es:di],al
	inc	di

@@skip3:
	mov	cx,bp		;-- restore width
	add	di,dx		;-- add wrap

	dec	si		;-- Decrement height
	jnz	@@doit0 	;-- Let's work again!

@@bye:
	pop	bp
	ret
ENDP





;ALIGN 4
;ษอออออออออออออออออออออออออออออออออออออออออออหอออออออออออออออออออออออออออออป
;บ CPASTEADD(int x,y; void far buf; int add) บ Put w/ clipping, add, mask! บ
;ศอออออออออออออออออออออออออออออออออออออออออออสอออออออออออออออออออออออออออออผ
PUBLIC	CPASTEADD
PROC	CPASTEADD       FAR
ARG	x1:WORD, y1:WORD, buf:DWORD, adder:WORD
USES	ds,di,si
LOCAL	xbadd:WORD

	push	bp		;-- Ideal mode quirk

	lds	si,[buf]	;-- ds:si = buffer
	mov	es,[vgaseg]
	mov	di,[vgaofs]	;-- es:di = vga screen

	mov	cx,[ds:si]	;-- cx = width
	inc	si
	inc	si
	lodsw			;-- ax = height

	mov	bx,[y1] 	;-- y1 coordinate
	mov	dx,bx		;-- in dx too...

	or	bx,bx
	jge	@@yt_ok 	;-- if bx<0 then fix(y top)

;;--- Let's fix y coordinate (top) ---

	neg	bx		;-- bx = y = is positive
	sub	ax,bx		;-- Substract excess (bx is negative)
	jbe	@@bye		;-- If <=0 there's no image!

	xchg	bx,ax		;-- ax=bx, bx=ax (ax has excess portion)
	mul	cx		;-- unseen part*width
	add	si,ax		;-- add to buffer to avoid displaying it
	mov	ax,bx		;-- restore height..

	xor	bx,bx		;-- Top starts at coordinate 0
	xor	dx,dx

@@yt_ok:
	add	dx,ax		;-- dx = y1 + height = y2 (bottom)
	sub	dx,VGAHEIGHT	;-- y2=y2-200
	js	@@yb_ok 	;-- if negative, y2<199

;--- Let's fix y1 coordinate (bottom) ---
	sub	ax,dx		;-- Substract value from total heigth
	jbe	@@bye		;-- If negative, no image is seen!

@@yb_ok:
	mov	ah,al		;-- ah = height (must be less than 255)

	shl	bx,6
	lea	bx,[ebx+ebx*4]	;-- Compute y address
	add	di,bx		;---- and add it to vgaofs

	mov	bx,[x1] 	;-- bx = x coordinate/left. Working value
	mov	dx,bx		;-- dx = x coordinate, final result.

	or	bx,bx		;-- if x>=0 then check for right part
	jge	@@xl_ok 	;--- otherwise, let's clip...

;;--- Clip x (left) --	Update xadd (unseen left+right of image) --

	neg	bx		;-- -(-x) = x is positive, and it's xadd
	add	si,bx		;-- Add to image source (unseen left part)
	sub	cx,bx		;-- Substract to width
	jbe	@@bye		;---- if width <=0 there's nothing!

	xor	dx,dx		;-- x coordinate is zero
	jmp	@@x_done	;-- We don't need to check right side

@@xl_ok:
	add	bx,cx		;-- bx= x + width = x1
	sub	bx,VGAWIDTH	;-- bx= x1 - 320 = unseen portion less 1
	js	@@xr_ok

;---- Fix x1 (right) -- bx will be xadd (unseen left+right) ---
	sub	cx,bx		;-- width -= unseen part
	jbe	@@bye		;-- if width <0, there's nothing!
	jmp	@@x_done

@@xr_ok:
	xor	bx,bx

@@x_done:
	add	di,dx		;-- Update x position

	mov	dx,VGAWIDTH	;-- let's calculate wrap (320-width)
	sub	dx,cx		;-- So, we can step down the screen!
	mov	[xbadd],bx	;-- Xadd
	mov	bx,[adder]	;-- Color adder
	mov	bp,cx		;-- We need to save original half-width

ALIGN 4
@@rockin:
	lodsb			      ;-- get pixel value
	or	al,al		    ;-- if zero, skip
	jz	@@skip
	add	al,bl		    ;-- adder...
	mov	[es:di],al	;-- store if nonzero
	inc	di		      ;-- increment screen position
	loop	@@rockin	;-- loop until all done

	add	di,dx		    ;-- add wrap (320-width = pos(x,y+1) )
	mov	cx,bp		    ;-- got back original half-width
	add	si,bx		    ;- added xadd (unseen from left+right)

	dec	ah		      ;-- height
	jnz	@@rockin
  jmp @@bye

ALIGN 4
@@skip:
	inc	di		      ;-- increment screen position
	loop	@@rockin	;-- loop until all done

	add	di,dx		    ;-- add wrap (320-width = pos(x,y+1) )
	mov	cx,bp		    ;-- got back original half-width
	add	si,bx		    ;- added xadd (unseen from left+right)

	dec	ah		      ;-- height
	jnz	@@rockin

@@bye:
	pop	bp
	ret
ENDP




;อออออ END! อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
ENDS
END

