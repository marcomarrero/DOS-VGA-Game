;-----------------------------------------------
; ModeX PCX Reader - v1.00 áeta
; Copyright (c) 1995 Marco A. Marrero
;-----------------------------------------------

IDEAL
MODEL SMALL,PASCAL
JUMPS
SMART
LOCALS


CODESEG
ASSUME cs:@code
P386


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

bufaddr DD ?	;-- Buffer address for quick buffered transfers
bufhand DW ?	;-- Buffer handle!

bufpos	DW ?	;-- Buffer current position
buflim	DW ?	;-- Buffer limit, maximum bytes plus offset
bufsiz	DW ?	;-- Buffer total size (original size)



;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; byte=BUF_READ() | Read data from buffer
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PROC	BUF_READ	NEAR

	push	ds si di cx bx dx

	lds	di,[bufaddr]	;-- Get buffer address (ds:di=original)
	mov	si,[bufpos]	;-- Get buffer position
	cmp	si,[buflim]	;-- Reached the end limit??
	jb	@@okay		;--- nope...

@@fail:
	mov     si,di           ;-- If yes, restore position (si=start offset)

	push	ds
	mov	bx,[bufhand]	;-- Handle of file
	mov	cx,[bufsiz]	;-- Bytes to read
	lds	dx,[bufaddr]	;-- Buffer to store data
	mov	ah,03fh 	;-- DOS call...
	int	21h
	pop	ds
	jc	@@error
	mov	ax,cx		;-- Return bytes read

	or	ax,ax		;-- There was someting?
	jz	@@error 	;--- no! there was nothing there!

	cmp	ax,[bufsiz]	;-- Filled up the buffer??
	je      @@okay          ;-- Not yet... All is ok.

@@nofill:
	mov	[bufsiz],ax	;-- Buffer is quite smaller!
	add     ax,di           ;-- size+offset of buffer
	mov	[buflim],ax	;-- Buffer limit is smaller too.

@@okay:
	lodsb			;-- ds:si has buffer position...
	mov	[bufpos],si	;-- Update...

@@error:
	pop	dx bx cx di si ds
	ret
ENDP






;--------------------------------------------------------------------------
; This thingy will read .PCX graphics in any rez as long as you are in the
; correct logical screen width (it is possible to view 320x200 and read
; 640x480. Don't forget that this reads 256 color!! 16 colors won't work!
;--------------------------------------------------------------------------

;ALIGN 4
;--------------------------------------------------------------------------
; xpcx(char far *filename, void far *buffer, unsigned size, void far *pal)
;-------------------------------------------------------------------------
PUBLIC	xpcx
PROC	xpcx	NEAR
ARG	filename:DWORD, buffer:DWORD, bsize:WORD, pal:DWORD
USES	si,di,ds


;--- Let's open the file. If there's an error, just quit ---

	lds	dx,[filename]	;-- ds:dx has ASCIIZ filename
	mov	ax,03d02h	;-- ah=3dh, al=02 (read/write)
	int	21h
	jc	@@bye	 	;-- If cannot open, it's dead!
	mov	[bufhand],ax	;-- Store handle

;--- Buffer management ----

	mov     ebx,[buffer]	;-- Get buffer address
	mov	[bufaddr],ebx	;-- done..

	mov	ax,[bsize]	;-- Get size of buffer
	mov	[bufsiz],ax	;-- Store original size
	add     ax,bx           ;-- Add offset to size
	mov	[buflim],ax	;-- Limit buffer address (offset+size)
	mov     [bufpos],ax     ;-- Pos=End... (force read disk later)


;-- Read header info ---

	call    BUF_READ
	cmp	al,0ah		;-- PCX header is 0ah
	jne	@@bye2		;-- exit (and close) if wrong!


;-- Let's play dirty. We have direct access to the buffer, don't we?
;-- Besides, the buffer is now full of data!

	lds	si,[bufaddr]	;-- Presto!

	xor	edx,edx		;-- 32 bit stuff...
	mov	dx,[ds:si+8]	;-- Xmax
	sub	dx,[ds:si+4]	;-- Xmin
	inc	dx

	xor	eax,eax		;-- Because we're going for a 32 bit mul!
	mov	ax,[ds:si+10]	;-- Ymax
	add	ax,[ds:si+6]	;-- Ymin
	inc	ax

	mul	edx		;-- eax*edx = ysize*xsize = Num Pixels
	mov	ecx,eax		;-- Bytes in screen. 32 bit number!!
	inc	ecx


;-- We must skip 128 bytes to get rid of the stupid header. Because
;-- we're going to cheat, we'll update the position. So, the buffer
;-- MUST be greater than 129. Anyway you are an idiot if you use such
;-- niniature buffers.

	add	[bufpos],127


;-- Now, we are going to set two *very* important registers. --

	mov	ax,0a000h	;-- es:di = VGA screen (a0000:0000)
	mov	es,ax
	xor	di,di

	mov	bx,0102h	;-- bh=01=Bitplane/ bl=02=vga hardware comm.
	mov	dx,3c4h		;-- dx=SC_INDEX (to select bitplanes)


;---------------------------------------------------------------------------
;-- Let's make a summary of registers now.
;-- es:di=screen, bx=bitplane+vga hardware, cx=size, dx=SC_INDEX, ax=?, si=?
;----------------------------------------------------------------------------

@@pcx:	call    BUF_READ	;-- Get color or run-length

	mov	ah,al		;-- Copy in ah, we'll mess ah.
	and	ah,0C0h 	;-- Determine run length
	cmp	ah,0C0h 	;---- Bits set??
	jne	@@norle 	;----- Nope. Plot one pixel. No RL

;-- Run length detected ---

	and	al,03Fh 	;-- Determine run value
	xor	ah,ah
	mov	si,ax		;-- si = run of bytes.

	call	BUF_READ	;-- Read color

@@rle:
	xchg	ax,bx		;-- ax=hardware/pixel info, bx=pixel
	out	dx,ax		;-- Set bitplane
	xchg	ax,bx

	mov	[es:di],al	;-- store (cannot increment di yet)

	shl	bh,1		;-- set new bitplane
	cmp	bh,16		;-- past 4 pixels?
	jne	@@1_nox

	mov	bh,1		;-- Yep. Past 4. Bitplane = 1
	inc	di		;-- di has new position

@@1_nox:
	dec	ecx		;-- Decrement screen size
	jz	@@finish	;-- If no more, finish!

	dec	si		;-- Decrement run-length
	jnz	@@rle		;-- If haven't ended, continue.
	jmp	@@pcx		;-- Do it again...


@@norle:
	xchg	ax,bx		;-- ax=hardware/pixel info, bx=pixel
	out	dx,ax		;-- Set bitplane
	xchg	ax,bx

	mov	[es:di],al	;-- store (cannot increment di yet)

	shl	bh,1		;-- set new bitplane
	cmp	bh,16		;-- past 4 pixels?
	jne	@@2_nox

	mov	bh,1		;-- Yep. Past 4. Bitplane = 1
	inc	di		;-- di has new position

@@2_nox:
	dec	ecx		;-- Decrement screen size
	jnz	@@pcx		;-- keep working....

;-- Finished drawing image. Let's get palette in table ----
@@finish:

	les	di,[pal]	;-- es:di = Palette table address
	mov	cx,256		;-- 256 colors to copy
@@colr:
	mov	bl,3		;-- 3 entries, Red/Green/Blue
@@movp:
	CALL	BUF_READ	;-- Get palette entry in al
	shr	al,2		;-- PCX stores 256 entries, VGA use only 64
	stosb			;-- Store...

	dec	bl		;-- Stored three?
	jnz	@@movp		;-- Nope.. Keep on.
	loop	@@colr		;-- Done 256?

@@bye2:
	mov	bx,[bufhand]	;-- Handle of file to close
	mov	ah,03eh 	;-- DOS function
	int	21h		;-- File closed!
@@bye:
	ret
ENDP
END

