{$A+,B-,E-,F+,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{-------------------------------------
  INTVEC  - Interrupt Vector Manager
-------------------------------------}
unit intvec;

interface
function getvec(intnum:byte) : pointer;
procedure setvec(intnum:byte; routine:pointer);

implementation

{ ษออออออออออออออออออออหออออออออออออออออออออออออป
  บ ptr=GETVEC(intnum) บ Get interrupt vector	 บ
  ศออออออออออออออออออออสออออออออออออออออออออออออผ }
function getvec(intnum:byte) : pointer; assembler;
asm
	mov	al,intnum
	mov	ah,35h
	int	21h
	mov	ax,bx
	mov	dx,es
end;




{ ษออออออออออออออออออออออหอออออออออออออออออออออออป
  บ SETVEC(int,*routine) บ Set interrupt vector  บ
  ศออออออออออออออออออออออสอออออออออออออออออออออออผ }
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