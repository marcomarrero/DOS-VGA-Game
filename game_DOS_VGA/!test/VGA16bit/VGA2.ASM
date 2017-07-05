;======================================================================
;	Stupid 386 VGA routines -  Programmed by Marco A. Marrero
;======================================================================

.286
jumps
locals

extrn screen : word
extrn color  : byte
extrn key    : byte

extrn mx     : word
extrn my     : word
extrn mk     : word
extrn mouse  : word
extrn moved  : byte
extrn clicked : byte

public mode,palette,vsynch,vwait,readmode,writemode,get10,put10,put10add
public get6,put6,pset,cls,memcpy_vga,read_pcx,point,clear10,processor
public keyvec,analog,mouse_on,mousek,mouse_show,mouse_hide,mouse_area
public mouse_wait,mouse_set

ARG1 = [bp+6]
ARG2 = [bp+8]
ARG3 = [bp+10]
ARG4 = [bp+12]
ARG5 = [bp+14]
ARG6 = [bp+16]

;---- parameter handling ----

begin	macro
	push	bp
	mov	bp,sp
	endm


bye	macro	%1
	pop	bp
	ret	%1
	endm

cseg segment 'CODE'
align  word
assume cs:cseg; ds:nothing; es:nothing
.386

align 4
;-----------------------------------
; mode(num) | Select graphics mode
;-----------------------------------
mode		proc	far
		begin

		mov	ax,ARG1
		int	10h

		bye    2
mode		endp

align 4
;------------------------------------------------
; palette(color,r,g,b) | Change the color palette
;-------------------------------------------------
palette 	proc	far
		begin

		mov	dx,03C8h
		mov	ax,ARG4
		out	dx,al
		inc	dx
		mov	ax,ARG3
		out	dx,al
		mov	ax,ARG2
		out	dx,al
		mov	ax,ARG1
		out	dx,al

		bye    8
palette 	endp


align 16
;----------------------------------------------
; vsynch | Synchronize to the Vertical retrace
;----------------------------------------------
vsynch		proc	far

		mov	dx,03DAh		;-- Status register
		mov	ah,8

@@v_still:	in	al,dx
		test	al,ah
		jnz	@@v_still

@@v_wait:	in	al,dx
		test	al,ah
		jz	@@v_wait

		ret
vsynch		endp


align 16
;----------------------------------------
; vwait | Wait for the vertical retrace
;----------------------------------------
vwait		proc	far
		mov	dx,03DAh		; status register
		mov	ah,8

@@w_wait:	in	al,dx
		test	al,ah
		jz	@@w_wait
		ret
vwait		endp


align 16
;------------------------------------------
; readmode(num) | Sets the VGA read mode
;------------------------------------------
readmode	proc	far
		begin

		mov	ax,ARG1
		mov	ah,al
		mov	dx,3ceh 	; Graph index
		mov	al,5
		out	dx,al
		inc	dx
		in	al,dx
		and	al,11111100b	; clear out write mode bits
		and	ah,00000011b
		or	al,ah
		out	dx,al

		bye	2
readmode	endp


align 16
;-------------------------------------
; writemode | Sets the VGA write mode
;-------------------------------------
writemode	proc	far
		begin

		mov	ax,ARG1
		mov	ah,al

		mov	dx,3c3h 	; Graph index
		mov	al,5
		out	dx,al
		inc	dx
		in	al,dx
		and	al,11110111b	; Clear out write mode bits
		shl	ah,3		; Move bit to correct position
		and	ah,00001000b
		or	al,ah
		out	dx,al

		bye    2
writemode	endp


align 4
;--------------------------------------
; get10(x,y,image) | Get a 10x10 block
;--------------------------------------
get10		proc	far
		begin
		push	si
		push	di
		push	ds

		mov	si,ARG3
		shl	si,6
		lea	si,[esi+esi*4]	; si*320
		add	si,ARG4

		les	di,ARG1 	;-- ES:DI = sprite (dest.)

		mov	ax,10
		stosw			;-- store image width/height
		stosw

		mov	ds,screen	;-- DS:SI = screen (source)
		mov	ax,310		;-- vertical adder

		movsd	; 1
		movsd
		movsw
		add	si,ax

		movsd	; 2
		movsd
		movsw
		add	si,ax

		movsd	; 3
		movsd
		movsw
		add	si,ax

		movsd	; 4
		movsd
		movsw
		add	si,ax

		movsd	; 5
		movsd
		movsw
		add	si,ax

		movsd	; 6
		movsd
		movsw
		add	si,ax

		movsd	; 7
		movsd
		movsw
		add	si,ax

		movsd	; 8
		movsd
		movsw
		add	si,ax

		movsd	; 9
		movsd
		movsw
		add	si,ax

		movsd	; 10
		movsd
		movsw

		pop	ds
		pop	di
		pop	si
		bye	8
get10		endp


align 16
;---------------------------------------
; put10(x,y,image) | Puts a 10x10 block
;---------------------------------------
put10		proc	far
		begin
		push	si
		push	di
		push	ds

		mov	es,screen	; ES:DI = screen

		mov	di,ARG3
		shl	di,6
		lea	di,[edi+edi*4]
		add	di,ARG4

		lds	si,ARG1
		add	si,4		; Ignore height and width
		mov	ax,310		; vertical adder

		movsd	; 1
		movsd
		movsw
		add	di,ax

		movsd	; 2
		movsd
		movsw
		add	di,ax

		movsd	; 3
		movsd
		movsw
		add	di,ax

		movsd	; 4
		movsd
		movsw
		add	di,ax

		movsd	; 5
		movsd
		movsw
		add	di,ax

		movsd	; 6
		movsd
		movsw
		add	di,ax

		movsd	; 7
		movsd
		movsw
		add	di,ax


		movsd	; 8
		movsd
		movsw
		add	di,ax


		movsd	; 9
		movsd
		movsw
		add	di,ax

		movsd	; 10
		movsd
		movsw

		pop	ds
		pop	di
		pop	si
		bye	8
put10		endp


align 16
;---------------------------------------
; clear10(x,y) | Clears a 10x10 block
;---------------------------------------
clear10 	proc	far
		begin
		push	di

		mov	es,screen	; ES:DI = screen

		mov	di,ARG1
		shl	di,6
		lea	di,[edi+edi*4]
		add	di,ARG2

		xor	eax,eax
		mov	cx,310

		stosd		; 1
		stosd
		stosw
		add	di,cx

		stosd		; 2
		stosd
		stosw
		add	di,cx

		stosd		; 3
		stosd
		stosw
		add	di,cx

		stosd		; 4
		stosd
		stosw
		add	di,cx

		stosd		; 5
		stosd
		stosw
		add	di,cx

		stosd		; 6
		stosd
		stosw
		add	di,cx

		stosd		; 7
		stosd
		stosw
		add	di,cx

		stosd		; 8
		stosd
		stosw
		add	di,cx

		stosd		; 9
		stosd
		stosw
		add	di,cx

		stosd		; 10
		stosd
		stosw
		add	di,cx


		pop	di
		bye	4
clear10 	endp


align 16
;---------------------------------------------------------------
; put10add(x,y,image,num) | Puts a 10x10 block with color adder
;---------------------------------------------------------------
put10add	proc	far
		begin
		push	si
		push	di
		push	ds

		mov	es,screen	; ES:DI = screen

		mov	di,ARG4
		shl	di,6
		lea	di,[edi+edi*4]
		add	di,ARG5

		mov	dx,ARG1 	; dx=adder
		mov	dh,dl
		mov	ax,dx
		shl	edx,16
		mov	dx,ax

		lds	si,ARG2
		add	si,4		; ignore height and width

		mov	bx,310		; vertical adder

		lodsd		; 1
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw
		add	di,bx

		lodsd		; 2
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw
		add	di,bx

		lodsd		; 3
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw
		add	di,bx

		lodsd		; 4
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw
		add	di,bx

		lodsd		; 5
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw
		add	di,bx

		lodsd		; 6
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw
		add	di,bx

		lodsd		; 7
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw
		add	di,bx

		lodsd		; 8
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw
		add	di,bx

		lodsd		; 9
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw
		add	di,bx

		lodsd		; 10
		add	eax,edx
		stosd
		lodsd
		add	eax,edx
		stosd
		lodsw
		add	ax,dx
		stosw

		pop	ds
		pop	di
		pop	si
		bye	10
put10add	endp


align 4
;------------------------------------
; get6(x,y,image) | Get a 6x5 block
;------------------------------------
get6		proc	far
		begin
		push	si
		push	di
		push	ds

		mov	si,ARG3
		shl	si,6
		lea	si,[esi+esi*4]
		add	si,ARG4

		les	di,ARG1 	; ES:DI = sprite (dest.)

		mov	ax,6
		stosw			; store image width/height
		mov	ax,5
		stosw

		mov	ds,screen	; DS:SI = screen (source)
		mov	ax,314		; vertical adder

		movsd	; 1
		movsw
		add	si,ax

		movsd	; 2
		movsw
		add	si,ax

		movsd	; 3
		movsw
		add	si,ax

		movsd	; 4
		movsw
		add	si,ax

		movsd	; 5
		movsw

		pop	ds
		pop	di
		pop	si
		bye	8
get6		endp


align 16
;------------------------------------
; put6(x,y,image) | Puts a 6x5 block
;------------------------------------
put6		proc	far
		begin
		push	si
		push	di
		push	ds

		mov	es,screen	; ES:DI = screen

		mov	di,ARG3
		shl	di,6
		lea	di,[edi+edi*4]
		add	di,ARG4

		lds	si,ARG1
		add	si,4		; Ignore height and width

		mov	ax,314		; vertical adder

		movsd	;1
		movsw
		add	di,ax

		movsd	;2
		movsw
		add	di,ax

		movsd	;3
		movsw
		add	di,ax

		movsd	;4
		movsw
		add	di,ax

		movsd	;5
		movsw

		pop	ds
		pop	di
		pop	si
		bye	8
put6		endp


align 16
;------------------------
; pset(x,y,color) | Pixel
;-------------------------
pset		proc	far
		begin
		push	di

		mov	di,ARG2
		shl	di,6
		lea	di,[edi+edi*4]
		add	di,ARG3

		mov	ax,ARG1
		mov	es,screen
		stosb

		pop	di
		bye	6
pset		endp


align 4
;--------------------------
; cls(n) |   Clear screen
;---------------------------
cls		proc	far
		begin
		push	di

		mov	es,screen
		mov	ax,ARG1
		mov	al,ah
		xor	di,di
		mov	cx,64000/64

@@clir: 	stosd	; 4
		stosd	; 8
		stosd	; 12
		stosd	; 16
		stosd	; 20
		stosd	; 24
		stosd	; 28
		stosd	; 32
		stosd	; 36
		stosd	; 40
		stosd	; 44
		stosd	; 48
		stosd	; 52
		stosd	; 56
		stosd	; 60
		stosd	; 64
		stosd	; 68
		stosd	; 72
		stosd	; 76
		stosd	; 80
		stosd	; 84
		stosd	; 88
		stosd	; 92
		stosd	; 96
		stosd	; 100
		stosd	; 104
		stosd	; 108
		stosd	; 112
		stosd	; 116
		stosd	; 120
		stosd	; 124
		stosd	; 128
		loop	@@clir

		pop	di
		bye	2
cls		endp


align 16
;------------------------------------------------------------
; Memcpy_vga(^from,^to) || Copies a vga screen
;------------------------------------------------------------
memcpy_vga	proc	far
		begin
		push	si
		push	di
		push	ds

		lds	si,ARG3
		les	di,ARG1

		mov	cx,200

@@cpy:		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd ; 64
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd ; 128
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd ; 196
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd ; 256
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd
		movsd ; 320

		dec	cx
		jnz	@@cpy

		pop	ds
		pop	di
		pop	si
		bye	8
memcpy_vga	endp


align 16
;----------------------------------------
; var=point(x,y) | Reads a pixel color
;----------------------------------------
point		proc	far
		begin

		mov	bx,ARG1
		lea	bx,[ebx+ebx*4]
		shl	bx,6
		add	bx,ARG2

		mov	es,screen

		xor	ax,ax
		mov	al,es:[bx]
		bye	4
point		endp


align 4
;-----------------------------------------
; read_pcx(where) | Reads a PCX graphic
;-----------------------------------------
read_pcx	proc	far
		begin
		push	si
		push	di
		push	ds

		mov	es,screen
		xor	di,di
		lds	si,ARG1

		add	si,128		; skip header

		mov	bx,64000	; constants
		mov	dl,0c0h
		mov	dh,03fh

@@pcx:		mov	al,ds:[si]	; get color or run-length
		inc	si

		test	al,dl		; $c0
		jz	@@norle

		and	al,dh		; $3f
		mov	cl,al		; CL=run length

		mov	al,ds:[si]
		inc	si
		mov	ah,al

		shr	cl,1		;-- Run Length/2
		jc	@@rle_b

@@rle_w:	mov	es:[di],ax
		inc	di
		inc	di
		dec	cl
		jnz	@@rle_w

		cmp	di,bx
		jb	@@pcx
		jmp	@@pcxend

@@rle_b:	jz	@@rle1b
@@rleb: 	mov	es:[di],ax
		inc	di
		inc	di
		dec	cl
		jnz	@@rleb

@@rle1b:	mov	es:[di],al
		inc	di
		cmp	di,bx
		jb	@@pcx
		jmp	@@pcxend

@@norle:	mov	es:[di],al
		inc	di
		cmp	di,bx
		jbe	@@pcx

@@pcxend:	pop	ds
		pop	di
		pop	si
		bye	2
read_pcx	endp



align 4
;----------------------------------------
; Processor detection routine (buggy)
;----------------------------------------
processor	proc	far

		mov	al,1
		mov	cl,32
		shl	al,cl
		jnz	@i186

		mov	color,0
		ret

@i186:		push	sp
		pop	ax
		cmp	ax,sp
		je	@i286

		mov	color,1
		ret

@i286:		pushf

		pushf
		pop	ax
		xor	ax,03000h
		push	ax
		popf
		pushf
		pop	bx
		popf
		cmp	ax,bx
		jne	@i386

		mov	color,2
		ret

@i386:		mov	color,3
		ret
processor	endp



align 16
;-----------------------------------
;      Keyboard vector routine
;-----------------------------------
keyvec		proc	far
		push	ds
		push	ax

		mov	ax,seg key
		mov	ds,ax

		in	al,60h			;-- get key
		mov	ds:[offset key],al	;-- store it

		in	al,61h			;-- read 8255 port pb
		or	al,80h			;-- Keyboard acknowledge
		out	61h,al
		and	al,7fh			;-- reset key acknowledge...
		out	61h,al			;-- restore original 8255

		mov	al,20h		;-- send end-of-interrupt...
		out	20h,al		;-- to the interrupt controller

		pop	ax
		pop	ds
		iret
keyvec		endp


align 16
;------------------------
;     read joystick
; b= 1 = stick 1 x
; b= 2 = stick 1 y
; b= 4 = stick 2...
;-------------------------
analog		proc	far
		begin

		mov	bx,ARG1
		mov	dx,201h
		cli
		xor	cx,cx
@@an1:		in	al,dx
		test	al,bl
		jz	@@an2
		loop	@@an1
		xor	ax,ax
		jmp	@@bye

@@an2:		out	dx,al
		xor	cx,cx

@@an3:		in	al,dx
		test	al,bl
		jz	@@an4
		loop	@@an3
		xor	ax,ax
		jmp	@@bye

@@an4:		neg	cx
		mov	ax,cx

@@bye:		sti
		bye	2
analog		endp



align 2
;--------------------------
;   Enable Mouse Driver
;---------------------------
mouse_on	proc	far
		xor	bx,bx
		mov	es,bx
		add	bx,0cch
		mov	ax,es:[bx]	;-- Get mouse interrupt vector
		add	ax,es:[bx+2]
		or	ax,ax
		jz	@@bye

                mov     ax,21h
		int	33h		;-- Software reset
		cmp	ax,-1		;-- If -1 mouse installed
		je	@@cont

		xor	ax,ax
		jz	@@bye		;-- Jmp...

@@cont: 	mov	ax,1
		int	33h		;-- Unhide mouse

@@bye:		mov	mouse,ax	;-- Will be zero if no mouse
		xor	ax,ax
		mov	mk,ax
		mov	mx,ax
		mov	my,ax

		ret
mouse_on	endp



align 16
;---------------------------------
; Shows a previously hidden mouse
;---------------------------------
mouse_show	proc	far

		test	mouse,1 	;-- Mouse is working?
		jz	@@bye

		xor	ax,ax
		inc	ax
		int	33h
@@bye:		ret
mouse_show	endp



align 16
;------------------------------------------------
; Hides mouse. To see it again you must
; Unhide it. IF YOU HIDE IT TWICE YOU MUST
; UNHIDE IT TWICE, OR NO MOUSE WILL BE SHOWN!
;-----------------------------------------------
mouse_hide	proc	far
		test	mouse,1 	;-- Mouse is working?
		jz	@@bye

		mov	ax,2
		int	33h
@@bye:		ret
mouse_hide	endp



align 16
;---------------------------------------
; Get mouse values inside a window
;----------------------------------
;  Mx = x coordinate (window)
;  My = y coordinate (window)
;  Mk = Button (1=L,2=R or 3=LR)
;  Moved   = zero if no movement
;  Clicked = zero if changes
;----------------------------------------
mousek		proc	far
		test	mouse,1 	;-- Mouse is working?
		jz	@@bye

		xor	ax,ax		;-- Clear flags
		mov	moved,al
		mov	clicked,ah

		mov	al,3
		int	33h

		shr	cx,1
		cmp	cx,mx		;-- moved the mouse?
		je	@@still

		inc	moved
		mov	mx,cx

@@still:	cmp	dx,my		;-- moved the mouse?
		je	@@still2

		inc	moved
		mov	my,dx

@@still2:	cmp    bx,mk
		je     @@bye

		mov    mk,bx		;-- Button: 1=left,2=right,3=both
		inc    clicked		;-- button was pressed or depressed

@@bye:		ret
mousek		endp


align 16
;---------------------------------
; Puts mouse in this coordinate
;----------------------------------
mouse_set	proc	far
		begin

		test	mouse,1 	;-- Mouse is working?
		jz	@@bye

		mov	cx,ARG2
		mov	dx,ARG1

		mov	ax,4
		int	33h
@@bye:		bye	4
mouse_set	endp



;--------------------------------
;  Waits user to depress button
;---------------------------------
mouse_wait	proc	far
		test	mouse,1 	;-- Mouse is working?
		jz	@@bye

@@wait: 	mov	ax,3
		int	33h
		or	bx,bx
                jnz     @@wait
@@bye:		ret
mouse_wait	endp


;---------------------------------------------
; Tells user if pressed/not pressed mouse
; button at specified coordinates.
;    Button: 0=None,1=L,2=R,3=LR
; mouse_area(button,x,y,x1,y1)
;---------------------------------------------
mouse_area	proc	far
		begin

		call	mousek
		test	mouse,1 	;-- Mouse is working?
		jz	@@bye		;-- no.

		mov	ax,ARG5
		cmp	ax,mk		;-- It is correct button?
		jne	@@bye

@@check:	mov	ax,mx		;-- Check x position
		mov	bx,ARG4 	;-- x
		cmp	ax,bx
		jl	@@bye

		mov	bx,ARG2 	;-- x1
		cmp	ax,bx		;-- Check
		jg	@@bye

		mov	ax,my		;-- Check y pos.
		mov	bx,ARG3 	;-- y
		cmp	ax,bx
		jl	@@bye

		mov	bx,ARG1
		cmp	ax,bx
		jg	@@bye

		mov	ax,1		;-- Survived! return 1
		jmp	@@bye2

@@bye:		xor	ax,ax
@@bye2: 	bye	10
mouse_area	endp


cseg		ends
		end
