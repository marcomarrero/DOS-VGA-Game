;-------------------------
; TIMER TICK for GAME.PAS
;-------------------------
;-------------------------------------------
; timer_tick(freq) | Change system timer
;-------------------------------------------}
IDEAL
P286N
MODEL SMALL, PASCAL
LOCALS
JUMPS
SMART

DATASEG
extrn timerl:DWORD
ENDS

;컴컴컴 EXTERNAL VARIABLES 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CODESEG
assume	cs:@code, ds:nothing; es:nothing; ss:nothing
P386N

PUBLIC  TIMER_INT
PROC    TIMER_INT       FAR
	push	ax
	push	ds

	mov	ax,seg timerl
	mov	ds,ax
        inc     [timerl]

	mov	al,20h	;-- send end-of-interrupt...
	out	20h,al	;-- to the interrupt controller

	pop	ds
	pop	ax
	iret

ENDP	timer_int
ENDS
END

