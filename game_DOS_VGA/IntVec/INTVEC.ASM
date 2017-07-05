; ษอออออออออออออออออออออออออออออออป
; บ Interrupt vector module v1.01 บ
; วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
; บ  (c) 1995 Marco A. Marrero    บ
; ศอออออออออออออออออออออออออออออออผ
;

IDEAL
MODEL SMALL,PASCAL
LOCALS
SMART
P286N


CODESEG
ASSUME  CS:@code, DS:NOTHING, ES:NOTHING, SS:NOTHING
P386N

ALIGN 4
;ษออออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออออป
;บ ptr=GETVEC(intnum) บ Get interrupt vector (address of routine) บ
;ศออออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออออผ
PUBLIC  GETVECT
PROC    GETVECT         FAR
ARG     intnum:BYTE

	mov     al,[intnum]
	mov	ah,35h
	int	21h
	mov	ax,bx
	mov	dx,es
	ret
ENDP



ALIGN 4
;ษอออออออออออออออออออออออออหอออออออออออออออออออออออป
;บ SETVEC(intnum,*routine) บ Set interrupt vector  บ
;ศอออออออออออออออออออออออออสอออออออออออออออออออออออผ
PUBLIC  SETVEC
PROC    SETVEC          FAR
ARG     intnum:BYTE, routine:DWORD
USES    ds

	mov     al,[intnum]
	mov	ah,25h
	lds     dx,[routine]
	int	21h
	ret
ENDP


;ออออออออออออออออออออออออออออออ END อออออออออออออออออออออออออออออออออออออ
ENDS
END
