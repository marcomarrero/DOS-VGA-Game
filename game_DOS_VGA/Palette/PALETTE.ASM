;  ษออออออออออออออออออออออออออออออออออออออออป
;  บ		 PALETTE Library	    บ
;  บ	   Version 1.10 - May/01/1995	    บ
;  บ----------------------------------------บ
;  บ Copyright (c) 1993,95 Marco A. Marrero บ
;  ศออออออออออออออออออออออออออออออออออออออออผ

IDEAL
MODEL SMALL, PASCAL
LOCALS
P286


CODESEG
ASSUME  cs:@code
P386

mypal	db	768 dup(?)	;-- Working palette


;ฤฤฤฤฤฤฤฤ Functions ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ


;ALIGN 4
;ษออออออออออออออออออออออออออออออหอออออออออออออออออป
;บ PAL_ENTRY(char color,r,g,b)	บ Change palette  บ
;ศออออออออออออออออออออออออออออออสอออออออออออออออออผ
PUBLIC	PAL_ENTRY
PROC	PAL_ENTRY	FAR
ARG	color:BYTE, red:BYTE, green:BYTE, blue:BYTE

	mov	dx,03C8h
	mov	al,[color]
	out	dx,al
	inc	dx

	mov	al,[red]
	out	dx,al
	mov	al,[green]
	out	dx,al
	mov	al,[blue]
	out	dx,al

	ret
ENDP




;ALIGN 4
;ษออออออออออออออออออออออออออหอออออออออออออออออป
;บ PAL_SET(void far table)  บ Set all palette บ
;ศออออออออออออออออออออออออออสอออออออออออออออออผ
PUBLIC	PAL_SET
PROC	PAL_SET         FAR
ARG	ptable:DWORD
USES	ds,si

	lds	si,[ptable]	;-- ds:si points to color table
	mov	dx,03C8h	;-- Palette adress
	xor	ax,ax		;-- Update from color 0
	out	dx,al
	inc	dx
	mov	cx,768		;-- 768 values

	rep	outsb		;-- Update 768 palette entries

	ret
ENDP



;ALIGN 4
;ษอออออออออออออออออออออหอออออออออออออออออป
;บ PAL_ALL(r,g,b:byte) บ Set all palette บ
;ศอออออออออออออออออออออสอออออออออออออออออผ
PUBLIC	PAL_ALL
PROC	PAL_ALL         FAR
ARG	r:BYTE, g:BYTE, b:BYTE

	mov	ah,[r]		;-- ah = RED
	mov	bh,[g]		;-- bh = GREEN
	mov	bl,[b]		;-- bl = BLUE

	mov	dx,03C8h	;-- Palette adress/Index
	xor	al,al		;-- Update from color 0
	out	dx,al
	inc	dx		;-- Palette write address

	mov	cx,256		;-- 256 colors to update

@@doit:
	mov	al,ah		;-- red
	out	dx,al

	mov	al,bh		;-- green
	out	dx,al

	mov	al,bl		;-- blue
	out	dx,al
	loop	@@doit

	ret
ENDP




;ALIGN 4
;ษอออออออออออออออออออออออออออออออออออออออหอออออออออออออออออป
;บ PAL_FADE(void far palette, int delay) บ Fades palette   บ
;ศอออออออออออออออออออออออออออออออออออออออสอออออออออออออออออผ
PUBLIC	PAL_FADE
PROC	PAL_FADE        FAR
ARG	pal:DWORD, delay:WORD
USES	ds,si,di

	lds	si,[pal]	;-- ds:si = palette to fade

	mov	ax,cs		;-- es:di = working palette
	mov	es,ax
	mov	di,offset mypal

	mov	cx,768/4	;-- Copy palette to working
	rep	movsd

	mov	di,offset mypal ;-- di = working palette offset
	mov	ds,ax		;-- ds:si = working palette

	mov	bl,63		;-- bl = 63 palette changes...

@@prepare:
	mov	cx,768		;-- Let's modify palette now
	mov	si,di		;-- si = working palette

@@work:
	mov	al,[ds:si]	;-- Get entry color
	dec	al		;-- Decrement
	cmp	al,255
	jne	@@ok		;-- If >0 then it's ok
	xor	al,al

@@ok:	mov	[ds:si],al	;-- Update...
	inc	si

	loop	@@work		;-- 768 times!

@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay + 1
	inc	cx

@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
	jnz	@@v_still

@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
	jz	@@v_wait

	loop	@@v_still

@@setit:
	mov	dx,03c8h	;-- Palette address
	mov	cx,768		;-- 768 palette entries
	xor	ax,ax		;-- Color index

	out	dx,al		;-- Start from color 0
	inc	dx		;-- Palette data port

	mov	si,di		;-- Restore palette table
	rep	outsb

	dec	bl
	jnz	@@prepare

	ret
ENDP




;ALIGN 4
;ษออออออออออออออออออออออออออออออออออออหออออออออออออออออออป
;บ PAL_LIGHT(void far pal, int delay) บ Lightens palette บ
;ศออออออออออออออออออออออออออออออออออออสออออออออออออออออออผ
PUBLIC	PAL_LIGHT
PROC	PAL_LIGHT       FAR
ARG	pal:DWORD, delay:WORD
USES	ds,si,di

	lds	si,[pal]	;-- ds:si = palette to fade

	mov	ax,cs		;-- es:di = working palette
	mov	es,ax
	mov	di,offset mypal

	mov	cx,768/4	;-- Copy palette to working
	rep	movsd

	mov	di,offset mypal ;-- di = working palette offset
	mov	ds,ax		;-- ds:si = working palette

	mov	bl,63		;-- bl = 63 palette changes...

@@prepare:
	mov	cx,768		;-- Let's modify palette now
	mov	si,di		;-- si = working palette

@@work:
	mov	al,[ds:si]	;-- Get entry color
	inc	al		;-- Decrement
	cmp	al,63
	jbe	@@ok		;-- If <63 then it's ok
	mov	al,63

@@ok:	mov	[ds:si],al	;-- Update...
	inc	si

	loop	@@work		;-- 768 times!

@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay + 1
	inc	cx

@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
	jnz	@@v_still

@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
	jz	@@v_wait

	loop	@@v_still

@@setit:
	mov	dx,03c8h	;-- Palette address
	xor	ax,ax		;-- Start from color 0
	out	dx,al
	inc	dx		;-- Palette data port

	mov	si,di		;-- Restore palette table

	mov	cx,768		;-- 768 palette entries
	rep	outsb		;-- Send palette...

	dec	bl
	jnz	@@prepare

	ret
ENDP






;ALIGN 4
;ษอออออออออออออออออออออออออออออออออออออหอออออออออออออออออป
;บ PAL_UNFADE(void far pal, int delay) บ Unfades palette บ
;ศอออออออออออออออออออออออออออออออออออออสอออออออออออออออออผ
PUBLIC	PAL_UNFADE
PROC	PAL_UNFADE      FAR
ARG	pal:DWORD, delay:WORD
USES	ds,si,di

	mov	ax,cs		;-- ds:si = Working palette
	mov	ds,ax
	mov	si,offset mypal

	mov	cx,768/4	;-- Copy palette to working
	mov	dx,4
	xor	eax,eax

@@palblank:
	mov	[ds:si],eax
	add	si,dx
	loop	@@palblank

	mov	bl,63		;-- bl = 63 palette changes...

@@prepare:

	mov	cx,768		;-- Let's modify palette now
	mov	si,offset mypal ;-- ds:si = working palette
	les	di,[pal]	;-- es:di = original palette

@@work:
	mov	al,[ds:si]	;-- Get entry color
	inc	al		;-- Increment
	cmp	al,[es:di]
	jbe	@@ok		;-- If color <= original then it's ok
	dec	al

@@ok:
	mov	[ds:si],al	;-- Update...
	inc	si
	inc	di

	loop	@@work		;-- 768 times!

@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay + 1
	inc	cx

@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
	jnz	@@v_still

@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
	jz	@@v_wait

	loop	@@v_still

@@setit:
	mov	dx,03c8h	;-- Palette address (index)
	xor	ax,ax		;-- Update from color 0
	out	dx,al		;-- Set.
	inc	dx		;-- Palette data

	mov	si,offset mypal ;-- Restore palette table
	mov	cx,768		;-- 768 color palette entries
	rep	outsb		;-- Set palette

	dec	bl
	jnz	@@prepare

	ret
ENDP




;ALIGN 4
;ษออออออออออออออออออออออออออออออออออออออหอออออออออออออออออออป
;บ PAL_UNLIGHT(void far pal, int delay) บ Unlights palette  บ
;ศออออออออออออออออออออออออออออออออออออออสอออออออออออออออออออผ
PUBLIC	PAL_UNLIGHT
PROC	PAL_UNLIGHT     FAR
ARG	pal:DWORD, delay:WORD
USES	ds,si,di

	mov	ax,cs		;-- ds:si = Working palette
	mov	ds,ax
	mov	si,offset mypal

	mov	cx,768/4	;-- Copy palette to working
	mov	dx,4

	mov	al,63
	mov	ah,al
	mov	bx,ax
	shl	eax,16
	mov	ax,bx

@@palblank:
	mov	[ds:si],eax
	add	si,dx
	loop	@@palblank

	mov	bl,63		;-- bl = 63 palette changes...

@@prepare:
	mov	cx,768		;-- Let's modify palette now
	mov	si,offset mypal ;-- ds:si = working palette
	les	di,[pal]	;-- es:di = original palette

@@work:
	mov	al,[ds:si]	;-- Get entry color
	dec	al		;-- Decrement
	cmp	al,[es:di]
	jae	@@ok		;-- If color >= original then it's ok
	inc	al

@@ok:	mov	[ds:si],al	;-- Update...
	inc	si
	inc	di

	loop	@@work		;-- 768 times!

@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay + 1
	inc	cx

@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
	jnz	@@v_still

@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
	jz	@@v_wait

	loop	@@v_still

@@setit:
	mov	dx,03c8h	;-- Palette address index (color)
	xor	ax,ax		;-- Start from 0
	out	dx,al
	inc	dx		;-- Palette data


	mov	cx,768		;-- 768 palette entries
	mov	si,offset mypal ;-- Get palette offset
	rep	outsb		;-- Quick! hurry up!

	dec	bl
	jnz	@@prepare

	ret
ENDP




;ALIGN 4
;ษอออออออออออออออออออออออออออออออออออออออออออออออออหอออออออออออออออออออป
;บ PAL_MODIFY(int delay, void far pal, char r,g,b) บ Modifies palette  บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออสอออออออออออออออออออผ
PUBLIC	PAL_MODIFY
PROC	PAL_MODIFY      FAR
ARG	delay:WORD, pal:DWORD, r:WORD, g:WORD, b:WORD
USES	ds,di,si

	mov	ax,cs		;-- es:di = Working palette
	mov	es,ax
	mov	di,offset mypal

	mov	dx,63		;-- To speed up things...
	lds	si,[pal]	;-- ds:si = Original palette
	mov	cx,256		;-- 256 colors

@@modi: xor	ax,ax		;-- Clear color
	lodsb			;-- mov al,ds:[si] = Red
	add	ax,[r]		;-- add red modifier

	jns	@@r1
	xor	ax,ax

@@r1:	cmp	ax,dx		;-- Is greater than 63?
	jle	@@r2
	mov	ax,dx

@@r2:	stosb			;-- mov es:[di],al
	xor	ax,ax		;-- Clear color
	lodsb			;-- mov al,ds:[si] = Green
	add	ax,[g]		;-- add green modifier

	jns	@@g1		;-- If negative, color must be zeroed
	xor	ax,ax

@@g1:	cmp	ax,dx		;-- If greater than 63, color = 63
	jle	@@g2
	mov	ax,dx

@@g2:	stosb			;-- mov es:[di],al
	xor	ax,ax		;-- Clear color
	lodsb			;-- mov al,ds:[si] = Blue
	add	ax,[b]		;-- add blue modifier

	jns	@@b1		;-- Is negative?
	xor	ax,ax

@@b1:	cmp	ax,dx		;-- Is greater than 63?
	jle	@@b2
	mov	ax,dx

@@b2:	stosb			;-- mov es:[di],al
	loop	@@modi


;--- Let's prepare some data before synching ---
	mov	ax,cs		;-- Get palette segment
	mov	ds,ax		;-- into DS

@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay

	or	cx,cx		;-- if cx is negative, do not synch.
	js	@@prepare
	inc	cx

@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
	jnz	@@v_still

@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
	jz	@@v_wait
	loop	@@v_still

@@prepare:

	mov	dx,03c8h	;-- Palette index (color)
	xor	ax,ax		;-- Start from color 0
	out	dx,al
	inc	dx		;-- Palette data


	mov	cx,768		;-- 768 palette entries
	mov	si,offset mypal ;-- Palette offset
	rep	outsb

	ret
ENDP




;ALIGN 4
;ษอออออออออออออหอออออออออออออออออออออออออออออออป
;บ VGA_PAL16() บ Sets VGA mode for 16 colors   บ
;ศอออออออออออออสอออออออออออออออออออออออออออออออผ
PUBLIC	VGA_PAL16
PROC	VGA_PAL16       FAR

	mov	dx,3dah 	;-- now use a linear palette, dacs 0-15.
	in	al,dx
	mov	dx,3c0h 	;-- mode control register,
	mov	al,10h
	out	dx,al
	inc	dx
	in	al,dx		;-- read it.
	dec	dx
	mov	ah,al
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,10h
	out	dx,al
	mov	al,ah		;-- force get bits p4&p5 from reg #14.
	or	al,80h
	out	dx,al

	mov	al,14h
	out	dx,al
	xor	al,al
	out	dx,al		;-- force dac index bits p4-p7 == 0.

	mov	cx,16
	xor	al,al
@@pl1:
	out	dx,al		;-- output index.
	out	dx,al		;-- output value. value == index.
	inc	al
	loop	@@pl1

	mov	al,34h		;-- redo it, activating the vga along.
	out	dx,al
	xor	al,al
	out	dx,al		;-- force dac index bits p4-p7 == 0.
	ret
ENDP





;ALIGN 4
;ษออออออออออออออออออออออออออออหออออออออออออออออออออออออออออออออออป
;บ PAL_WORD2PAL(void far pal) บ Copy working palette to palette  บ
;ศออออออออออออออออออออออออออออสออออออออออออออออออออออออออออออออออผ
PUBLIC	PAL_WORK2PAL
PROC	PAL_WORK2PAL    FAR
ARG	pal:DWORD
USES	ds,si,di

	les	di,[pal]	;-- Get destination palette address
	mov	ax,cs		;-- And source too..
	mov	ds,ax
	mov	si,offset mypal

	mov	cx,768/4	;-- Entries...
	rep	movsd		;-- Move them

	ret
ENDP


;ALIGN 4
;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออหอออออออออออป
;บ PAL_SPREAD(int r,g,b; far *pal; int r+,g+,b+; word start,end)บ Create palบ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออสอออออออออออผ
PUBLIC	PAL_SPREAD
PROC	PAL_SPREAD	FAR
ARG	r:WORD,g:WORD,b:WORD,pal:DWORD,radd:WORD,gadd:WORD,badd:WORD,start:WORD,ending:WORD
USES	di

	les	di,[pal]	;-- es:di = starting palette

	mov	bx,[start]	;-- bx = starting color
	cmp	bx,255		;-- way too high or low?
	jg	@@bye		;---- yep.. nothing to do

	mov	cx,[ending]	;-- cx = ending color
	cmp	cx,255		;-- way too high or low?
	jg	@@bye		;--- yep... Retire

	cmp	cx,bx		;-- start>end?
	jae	@@ok		;-- no problemo
	xchg	cx,bx		;-- exchange values

@@ok:
	sub	cx,bx		;-- number of entries + 1
	inc	cx

	mov	ax,3		;-- 3 * start = palette offset
	mul	bx		;-- done..
	add	di,ax		;-- add [di] the result to get address

	mov	ax,[r]		;-- r,g,b initial values
	mov	bx,[g]
	mov	dx,[b]

@@fun:

;--- red ---
	add	ax,[radd]	;-- add red stuff
	jns	@@r_ok1		;-- if (ax<0) then ax=0
	xor	ax,ax
@@r_ok1:
	cmp	ax,63		;-- if (ax>63) then ax=63
	jbe	@@r_ok2
	mov	ax,63

@@r_ok2:
;--- green ---
	add	bx,[gadd]	;-- add green stuff
	jns	@@g_ok1		;-- if (bx<0) then bx=0
	xor	bx,bx
@@g_ok1:
	cmp	bx,63		;-- if (bx>63) then bx=63
	jbe	@@g_ok2
	mov	bx,63

@@g_ok2:
;--- blue ---
	add	dx,[badd]	;-- add blue stuff
	jns	@@b_ok1		;-- if (dx<0) then dx=0
	xor	dx,dx

@@b_ok1:
	cmp	dx,63		;-- if (ax>63) then ax=63
	jbe	@@b_ok2
	mov	dx,63

@@b_ok2:
	stosb			;-- mov ax,[es:di++]
	mov	[es:di],bl	;-- store colors
	inc	di
	mov	[es:di],dl
	inc	di

	loop	@@fun

@@bye:
	ret
ENDP




;ALIGN 4
;ษออออออออออออออออออออออออออออออออออออออออออออออออหอออออออออออป
;บ PAL_CHANGE(far *pal; int r,g,b; word start,end)บ Change palบ
;ศออออออออออออออออออออออออออออออออออออออออออออออออสอออออออออออผ
PUBLIC	PAL_CHANGE
PROC	PAL_CHANGE	FAR
ARG	pal:DWORD,r:WORD,g:WORD,b:WORD,start:WORD,ending:WORD
USES	ds,si,es,di

	les	di,[pal]	;-- es:di = starting palette
	lds	si,[pal]	;-- ds:si = the same stuff too

	mov	bx,[start]	;-- bx = starting color
	cmp	bx,255		;-- way too high or low?
	jg	@@bye		;---- yep.. nothing to do

	mov	cx,[ending]	;-- cx = ending color
	cmp	cx,255		;-- way too high or low?
	jg	@@bye		;--- yep... Retire

	cmp	cx,bx		;-- start>end?
	jae	@@ok		;-- no problemo
	xchg	cx,bx		;-- exchange values

@@ok:
	sub	cx,bx		;-- number of entries + 1
	inc	cx

	mov	ax,3		;-- 3 * start = palette offset
	mul	bx		;-- done..

	add	di,ax		;-- add [di] the result to get address
	add	si,ax		;-- Of both.

	xor	ax,ax		;-- Clear ah.

@@fun:
;--- red ---
	lodsb			;-- Get color
	add	ax,[r]		;-- add red stuff
	jns	@@r_ok1		;-- if (ax<0) then ax=0
	xor	ax,ax
@@r_ok1:
	cmp	ax,63		;-- if (ax>63) then ax=63
	jbe	@@r_ok2
	mov	ax,63

@@r_ok2:
	stosb
;--- green ---
	lodsb
	add	ax,[g]		;-- add green stuff
	jns	@@g_ok1		;-- if (bx<0) then bx=0
	xor	ax,ax
@@g_ok1:
	cmp	ax,63		;-- if (bx>63) then bx=63
	jbe	@@g_ok2
	mov	ax,63

@@g_ok2:
	stosb
;--- blue ---
	lodsb
	add	ax,[b]		;-- add blue stuff
	jns	@@b_ok1		;-- if (dx<0) then dx=0
	xor	ax,ax

@@b_ok1:
	cmp	ax,63		;-- if (ax>63) then ax=63
	jbe	@@b_ok2
	mov	ax,63

@@b_ok2:
	stosb			;-- store
	loop	@@fun

@@bye:
	ret
ENDP




;ALIGN 4
;ษออออออออออออออออออออออออออออออออออออออหออออออออออออออป
;บ PAL_COPY(far *pal;word start,end,to) บ Copy palette บ
;ศออออออออออออออออออออออออออออออออออออออสออออออออออออออผ
PUBLIC	PAL_COPY
PROC	PAL_COPY	FAR
ARG	pal:DWORD,start:WORD,ending:WORD,upto:WORD
USES	ds,si,es,di

	les	di,[pal]	;-- es:di = "to" palette
	lds	si,[pal]	;-- ds:si = "start" palette

	xor	eax,eax
	mov	ax,[start]
	mov	cx,[ending]	;-- cx = number of colors to copy
	sub	cx,ax		;-- Got it.
	lea	cx,[ecx+ecx*2]	;-- Multiply by 3 to know number of bytes

	lea	ax,[eax+eax*2]	;-- Multiply by 3
	add	si,ax		;-- Starting palette position

	mov	ax,[upto]
	lea	ax,[eax+eax*2]	;-- Multiply by 3
	add	di,ax		;-- destination palette position

	rep	movsb		;-- Copy it
@@bye:
	ret
ENDP



;อออออ END! อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
ENDS
END

