;зддддддддддддддддддддддддддддддд©
;Ё    DigiPlay - Speaker fun     Ё
;Ё   Version 1.00 - 00/20/1995	 Ё
;цддддддддддддддддддддддддддддддд╢
;Ё  (c) 1995 Marco A. Marrero	 Ё
;юддддддддддддддддддддддддддддддды

IDEAL
MODEL SMALL,PASCAL
P286
JUMPS


;ммммммммм PUBLIC DATA мммммммммммммммммммммммммммммммммм
DATASEG
 EXTRN	spk_flag	: WORD		;-- 1=playing, 0=stop
 EXTRN	spk_pos		: WORD		;-- sample offset
 EXTRN	spk_wav		: DWORD		;-- sample address
 EXTRN	spk_len		: WORD		;-- sample length in bytes
 EXTRN	spk_loop	: WORD		;-- 1=loop, 0=no loop
ENDS


;ммммммммм FUNCTIONS мммммммммммммммммммммммммммммммммммм

CODESEG
ASSUME  cs:@code, ds:@data
P386


;ALIGN 4
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
; SPK_WAVE(void far *addr, unsigned size) || Set digital waveform
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PUBLIC	SPK_WAVE
PROC	SPK_WAVE	FAR
ARG	addr:DWORD, len:WORD
USES	ds

	cli

	mov	ax,SEG spk_wav
	mov	ds,ax

	mov	eax,[addr]
	mov	[spk_wav],eax

	mov	ax,[len]
	mov	[spk_len],ax

	xor	ax,ax
	mov	[spk_pos],ax
	mov	[spk_flag],ax

	sti
	ret
ENDP


;ALIGN 4
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
; SPK_START() || Starts playing!
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PUBLIC	SPK_START
PROC	SPK_START	FAR
USES	ds

	cli
	mov	ax,SEG spk_pos
	mov	ds,ax

	xor	ax,ax
	mov	[spk_pos],ax
	inc	ax
	mov	[spk_flag],ax

	sti
	ret
ENDP



;ALIGN 4
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
; SPK_STOP() || Stops playback
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PUBLIC	SPK_STOP
PROC	SPK_STOP	FAR
USES	ds

	cli
	mov	ax,SEG spk_pos
	mov	ds,ax

	mov	[spk_flag],0

	sti
	ret

ENDP

;ALIGN 4
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
; SPK_DOLOOP() || Sets playback to loop
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PUBLIC	SPK_DOLOOP
PROC	SPK_DOLOOP	FAR
USES	ds

	cli
	mov	ax,SEG spk_pos
	mov	ds,ax

	mov	[spk_loop],1
	sti
	ret
ENDP


;ALIGN 4
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
; SPK_NOLOOP() || Sets playback to not loop
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PUBLIC	SPK_NOLOOP
PROC	SPK_NOLOOP	FAR
USES	ds

	cli
	mov	ax,SEG spk_pos
	mov	ds,ax

	mov	[spk_loop],0
	sti
	ret
ENDP




;ALIGN 4
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
; SPK_CONTINUE(int pos) || Continues play from offset, unless 0=resume
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PUBLIC	SPK_CONTINUE
PROC	SPK_CONTINUE	FAR
ARG	pos:WORD
USES	ds

	cli
	mov	ax,SEG spk_pos
	mov	ds,ax

	mov	ax,[pos]
	or	ax,ax
	jz	@@skip

	mov	[spk_pos],ax

@@skip:
	mov	[spk_flag],1

	sti
	ret
ENDP



;ALIGN 4
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
; SPK_PLAY_ISR() || Interrupt routine
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PUBLIC	SPK_PLAY_ISR
PROC	SPK_PLAY_ISR	FAR
USES	si,di,es,bx,cx,dx

	xor	si,si		;-- fast zero constant --
	mov	di,1		;-- fast 1 constant --

	mov	ax,SEG spk_wav	;-- get current data segment --
	mov	ds,ax

	cmp	[spk_flag],di	;-- if flag=1, play wave... --
	jne	@@bye

	les	bx,[spk_wav]	;-- get waveform address --
	mov	cx,[spk_pos]	;-- get position of sound --
	cmp	cx,[spk_len]	;-- past end?? --
	jne	@@play		;-- if not, keep playing --

@@fix:
	cmp	[spk_loop],di	;-- if looping, don't stop sound --
	je	@@fix2
	mov	[spk_flag],si	;-- stop! --
	mov	[spk_pos],si
	jmp	@@bye

@@fix2:
	mov	[spk_pos],si	;-- only clear starting point --
	xor	cx,cx

@@play:
	add	bx,cx		;-- get sample offset --
	mov	al,[es:bx]	;-- get waveform value --
	inc	[spk_pos]	;-- increment position --

	out	61h,al		;-- send output to speaker --
@@bye:
	ret
ENDP



;ALIGN 4
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
; SPK_CONVERT(void far *what,unsigned size) || 8 bit to 1 bit... Yuck
;ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PUBLIC	SPK_CONVERT
PROC	SPK_CONVERT	FAR
ARG	what:DWORD, len:WORD
USES	ds,si,di

	lds	si,[what]
	les	di,[what]

	mov	cx,[len]

@@doit:
	lodsb
	cmp	al,128
	ja	@@one
	xor	al,al
	stosb
	loop	@@doit
	jmp	@@bye

@@one:
	mov	al,2
	stosb

@@count:
	loop	@@doit

@@bye:
	ret
ENDP

ENDS
END