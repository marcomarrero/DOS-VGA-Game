; �������������������������������ͻ
; � Interrupt vector module v1.01 �
; �������������������������������Ķ
; �  (c) 1995 Marco A. Marrero    �
; �������������������������������ͼ
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
;����������������������������������������������������������������ͻ
;� ptr=GETVEC(intnum) � Get interrupt vector (address of routine) �
;����������������������������������������������������������������ͼ
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
;�������������������������������������������������ͻ
;� SETVEC(intnum,*routine) � Set interrupt vector  �
;�������������������������������������������������ͼ
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


;������������������������������ END �������������������������������������
ENDS
END