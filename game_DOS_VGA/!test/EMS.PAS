{.-------------------------------------.
 |      EMS memory manager unit        |
 |-------------------------------------|
 | Copyright (c) 1995 Marco A. Marrero |
 `--------------------------------------- }
program ems;
uses intvec;

var
 _emsframe :pointer;
 _ems_error:byte;
 _ems_list : array[0..512] of word;


{---------------------
   Return EMS status
-----------------------}
function ems_get_status : byte; assembler;
asm
	mov	ah,40h
	int	67h
	mov	al,ah
	mov	_ems_error,al
end;



{-------------------------
  Get page frame address
-------------------------}
function ems_get_address : pointer; assembler;
asm
	mov	ah,41h
	int	67h
	mov	_ems_error,ah

	mov	dx,bx	{-- segment }
	xor	ax,ax	{-- offset  }
end;





{-----------------------------
  Get number of used pages
------------------------------}
function ems_used_pages : word; assembler;
asm
	mov	ah,42h
	int	67h

	mov	_ems_error,ah
	sub	dx,bx		{-- total-free }
	mov	ax,dx
end;



{-----------------------------
  Get number of free pages
------------------------------}
function ems_free_pages : word; assembler;
asm
	mov	ah,42h
	int	67h

	mov	_ems_error,ah
	mov	ax,bx
end;



{-----------------------------
  Get number of total pages
------------------------------}
function ems_total_pages : word; assembler;
asm
	mov	ah,42h
	int	67h

	mov	_ems_error,ah
	mov	ax,dx
end;



{------------------------------
      Allocate pages
-------------------------------}
function ems_allocate_page : word; assembler;
asm
	mov	si,offset _ems_list[0]
	mov	ah,43h
	zzzzzzz
end;





{--------------------------------------------
  Get vector to check if something is there!
---------------------------------------------}
function emsgetvec(intnum:byte) : longint; assembler;
asm
	mov	al,intnum
	mov	ah,35h
	int	21h
	mov	ax,bx
	mov	dx,es
end;

{------------------------------------------
 Check is EMS manager is installed. 0=NO
-------------------------------------------}
function ems_installed : byte;
installed:byte;
begin
 if emsgetvect($67)=0 then
   installed:=0;
 else
   installed:=1;

 _emsframe:=ems_get_address;
 if _ems_error<>0 then installed:=0;

 ems_installed:=installed;
end;




{-------------------
  Clear EMS list
--------------------}
procedure ems_clear_list; assembler;
asm
	mov	ax,seg _ems_list[0]
	mov	es,ax
	mov	di,offset _ems_list[0]

	xor	ax,ax
	mov	cx,256
	rep	stosw
end;


{-----------------------
  Unallocate *all* EMS
------------------------}
procedure ems_panic; assembler;
asm
	mov	si,offset _ems_list[0]
	mov	cx,512

@@doit:
	lodsw			{-- get value }
	or	ax,ax		{-- if it's zero, is unallocated }
	jz	@@skip

@@freee:
	mov	dx,ax		{-- dx = page }
	mov	ah,45h		{-- free page }
	int	67h

@@skip:
	loop	@@doit
end;


{============================== MAIN ================================}
begin
 _ems_error:=ems_installed;
end;