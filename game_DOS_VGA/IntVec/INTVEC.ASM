; 浜様様様様様様様様様様様様様様様�
; � Interrupt vector module v1.01 �
; 把陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
; �  (c) 1995 Marco A. Marrero    �
; 藩様様様様様様様様様様様様様様様�
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
;浜様様様様様様様様様曜様様様様様様様様様様様様様様様様様様様様様融
;� ptr=GETVEC(intnum) � Get interrupt vector (address of routine) �
;藩様様様様様様様様様擁様様様様様様様様様様様様様様様様様様様様様夕
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
;浜様様様様様様様様様様様様僕様様様様様様様様様様様�
;� SETVEC(intnum,*routine) � Set interrupt vector  �
;藩様様様様様様様様様様様様瞥様様様様様様様様様様様�
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


;様様様様様様様様様様様様様様様 END 様様様様様様様様様様様様様様様様様様�
ENDS
END
