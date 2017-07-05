{$A+,B-,E-,F+,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{-------------------------------------
  INTVEC  - Interrupt Vector Manager
-------------------------------------}
unit intvec;

interface
function getvec(intnum:byte) : pointer;
procedure setvec(intnum:byte; routine:pointer);

implementation

{ ���������������������������������������������ͻ
  � ptr=GETVEC(intnum) � Get interrupt vector	 �
  ���������������������������������������������ͼ }
function getvec(intnum:byte) : pointer; assembler;
asm
	mov	al,intnum
	mov	ah,35h
	int	21h
	mov	ax,bx
	mov	dx,es
end;




{ ����������������������������������������������ͻ
  � SETVEC(int,*routine) � Set interrupt vector  �
  ����������������������������������������������ͼ }
procedure setvec(intnum:byte; routine:pointer); assembler;
asm
	push	ds

	mov	al,intnum
	mov	ah,25h
	lds	dx,routine
	int	21h

	pop	ds
end;



begin
end.