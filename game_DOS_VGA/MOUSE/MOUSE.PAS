{  ษออออออออออออออออออออออออออออออออออออออออป
;  บ		 Mouse Library		    บ
;  บ       Version 3.00 - 03/20/1995        บ
;  วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
;  บ     Programmed by Marco A. Marrero     บ
;  บ Morse #49, Box 453 - Arroyo, PR 00714  บ
;  ศออออออออออออออออออออออออออออออออออออออออผ
;
; This library does NOT fix mouse coordinates, so in an 80x25 text screen
; you'll get 640x200 pixels, and in 320x200 you'll get 640x400.
;
; The "mouse_shape()" routines have not been included here because I
; don't have those listings right now at hand (sorry). Next version
; will do, with a stupid mouse drawing program.
;
; If you see incompatibilities, crashes and weird mouse handling it is
; probably due to a faulty mouse driver. IBM and Microsoft mouse
; drivers are the most compatible I've seen. Logitech would be fine too.
;
; If you have never used a mouse in your software, just remember to hide
; it before drawing text/graphics. Unlike the Amiga, the PC mouse is NOT
; a hardware one. And if it is, it's not standard - especially in DOS.
;
; Enjoy!
}
{$A-,B-,E-,F+,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$D-,L-,Y-}

unit mouse;
interface

var
 mx,my,mk	: word;
 ismouse	: word;
 moved		: word;
 clicked	: word;

 m_marco	: pointer;
 m_arrow	: pointer;
 m_cross	: pointer;
 m_help		: pointer;
 m_ibeam	: pointer;
 m_hour		: pointer;
 m_disk		: pointer;
 m_uarrow	: pointer;
 m_darrow	: pointer;
 m_larrow	: pointer;
 m_rarrow	: pointer;
 m_lrarrow	: pointer;
 m_udarrow      : pointer;

procedure mouse_on;
procedure mouse_show;
procedure mouse_hide;
procedure mousek;
procedure mouse_set(x,y:word);
procedure mouse_wait;
procedure mouse_area(button,x,y,x1,y1:integer);
function mouse_press(button:word) : word;
function mouse_release(button:word) : word;
procedure mouse_window(x,y,x1,y1:word);
procedure mouse_shape(image:pointer);


implementation
var
 sh_o,sh_s : word;
 ox,oy,ok  : word;



{ษออออออออออหอออออออออออออออออออออป
 บ MOUSE_ON บ Enable Mouse Driver บ
 ศออออออออออสอออออออออออออออออออออผ}
procedure mouse_on; assembler;
asm
	xor	bx,bx
	mov	es,bx
	add	bx,0cch
	mov	ax,es:[bx]	{-- Get mouse interrupt vector }
	add	ax,es:[bx+2]
	or	ax,ax
	jz 	@@bye

	mov	ax,21h
	int	33h		{-- Software reset }
	cmp	ax,-1		{-- If -1 mouse installed }
	je 	@@cont

	xor	ax,ax
	jmp 	@@bye

@@cont: mov	ax,1
	int	33h		{-- Unhide mouse }

@@bye:	mov	ismouse,ax	{-- Will be zero if no mouse }
	xor	ax,ax
	mov	mk,ax
	mov	mx,ax
	mov	my,ax
	mov	sh_s,ax
	mov	sh_o,ax
	mov	ox,ax
	mov	oy,ax
	mov	ok,ax
end;


{ษอออออออออออออหอออออออออออออออออออออป
 บ MOUSE_RESET บ Mouse hardware resetบ
 ศอออออออออออออสอออออออออออออออออออออผ}
procedure mouse_reset; assembler;
asm
	xor	bx,bx
	mov	es,bx
	add	bx,0cch
	mov	ax,es:[bx]	{-- Get mouse interrupt vector }
	add	ax,es:[bx+2]
	or	ax,ax
	jz 	@@bye

@@cont: mov	ax,0
	int	33h
	mov	ismouse,ax

	mov	ax,1
	int	33h		{-- Unhide mouse }

@@bye:	mov	ismouse,ax	{-- Will be zero if no mouse }
	xor	ax,ax
	mov	mk,ax
	mov	mx,ax
	mov	my,ax
	mov	sh_s,ax
	mov	sh_o,ax
	mov	ox,ax
	mov	oy,ax
	mov	ok,ax
end;



{ษออออออออออออออหออออออออออออออออออออออออออออออออออป
 บ MOUSE_SHOW() บ Shows a previously hidden mouse  บ
 ศออออออออออออออสออออออออออออออออออออออออออออออออออผ}
procedure mouse_show; assembler;
asm
	test	ismouse,1 	{-- Mouse is working? }
	jz 	@@bye

	mov	ax,1
	int	33h
@@bye:
end;




{ษออออออออออออออหออออออออออออออออออป
 บ MOUSE_HIDE() บ  Hides mouse.    บ
 ศออออออออออออออสออออออออออออออออออผ}
procedure mouse_hide; assembler;
asm
	test	ismouse,1 	{-- Mouse is working? }
	jz 	@@bye

	mov	ax,2
	int	33h
@@bye:
end;




{ษออออออออออหอออออออออออออออออออป
 บ MOUSEK() บ Get mouse values	บ
 ศออออออออออสอออออออออออออออออออผ}
procedure mousek; assembler;
asm
	test	ismouse,1 	{-- Mouse is working? }
	jz 	@@bye

	xor	ax,ax		{-- Clear flags }
	mov	moved,ax
	mov	clicked,ax

	mov	al,3
	int	33h

	mov	mx,cx		{-- update coords, user can change 'em }
	mov	my,dx
	mov	mk,bx		{-- Button: 1=left,2=right,3=both }

	cmp	cx,ox		{-- moved the mouse? }
	je 	@@still

	inc	moved		{-- moved it! }
	mov	ox,cx		{-- "old" value to know if moved again }

@@still:
	cmp	dx,oy		{-- moved the mouse? }
	je 	@@still2

	inc	moved		{-- mouse moved! }
	mov	oy,dx		{-- "old" value update }

@@still2:
	cmp	bx,ok		{-- mouse button changed?? }
	je	@@bye

	mov	ok,bx		{-- Update "old" button value }
	inc	clicked		{-- button was pressed or depressed }

@@bye:
end;




{ษออออออออออออออออหอออออออออออออออออออออออออออออออป
 บ MOUSE_SET(x,y) บ Puts mouse in this coordinate บ
 ศออออออออออออออออสอออออออออออออออออออออออออออออออผ}
procedure mouse_set(x,y:word); assembler;
asm
	test	ismouse,1 	{-- Mouse is working? }
	jz 	@@bye

	mov	cx,x
	mov	dx,y

	mov	ax,4
	int	33h

@@bye:
end;




{ษออออออออออออออหอออออออออออออออออออออออออออออออป
 บ MOUSE_WAIT() บ Waits user to depress button	บ
 ศออออออออออออออสอออออออออออออออออออออออออออออออผ}
procedure mouse_wait; assembler;
asm
	test	ismouse,1	{-- Mouse is working? }
	jz 	@@bye

@@wait: mov	ax,3
	int	33h
	or	bx,bx
	jnz 	@@wait

	mov     mx,cx
	mov	my,dx
	mov	mk,bx

	mov	ox,cx
	mov	oy,dx
	mov	ok,bx

@@bye:
end;




{ษออออออออออออออออออออออออออออออหอออออออออออออออออออออออออออออป
 บ MOUSE_AREA(button,x,y,x1,y1) บ Checks button & coordinates บ
 ศออออออออออออออออออออออออออออออสอออออออออออออออออออออออออออออผ}
procedure mouse_area(button,x,y,x1,y1:integer); assembler;
asm
	test	ismouse,1 	{-- Mouse is working? }
	jz 	@@bye		{-- no. }

	call	mousek

	mov     mx,cx
	mov	my,dx
	mov	mk,bx

	mov	ox,cx
	mov	oy,dx
	mov	ok,bx

	mov	ax,button
	cmp	ax,mk		{-- It is correct button? }
	jne 	@@bye

@@check:
	mov	ax,mx		{-- Check x position }
	mov	bx,x		{-- x }
	cmp	ax,bx
	jl 	@@bye

	mov	bx,x1		{-- x1 }
	cmp	ax,bx		{-- Check }
	jg	@@bye

	mov	ax,my		{-- Check y pos. }
	mov	bx,y		{-- y }
	cmp	ax,bx
	jl 	@@bye

	mov	bx,y1		{-- check y1 }
	cmp	ax,bx
	jg 	@@bye

	mov	ax,1		{-- Survived! Return nonzero }
	jmp 	@@bye2

@@bye:	xor	ax,ax
@@bye2:
end;



{----------------------------------------------------------------------
  times:=MOUSE_PRESS(bt:word) | Get # of presses, update coordinates.
-----------------------------------------------------------------------}
function mouse_press(button:word) : word; assembler;
asm
	mov	ax,5
	int	33h

	mov	bx,ax
	mov	mk,ax
	mov	mx,cx
	mov	my,dx
end;



{-----------------------------------------------------------------------
  times:=MOUSE_RELEASE(bt:word) | Get release pos, update coordinates.
------------------------------------------------------------------------}
function mouse_release(button:word) : word; assembler;
asm
	mov	ax,6
	int	33h

	mov	bx,ax
	mov	mk,ax
	mov	mx,cx
	mov	my,dx
end;



{------------------------------------------------------------
  mouse_window(x,y,x1,y1:word) | Set screen limits for mouse
-------------------------------------------------------------}
procedure mouse_window(x,y,x1,y1:word); assembler;
asm
	mov	cx,x	{-- set min/max horizontal }
	mov	dx,x1
	mov	ax,7h
	int	33h

	mov	cx,y	{-- set min/max vertical }
	mov	dx,y1
	inc	ax
	int	33h
end;



{-----------------------------------------------
  mouse_shape(img:pointer) | Set graphic mouse
-----------------------------------------------}
procedure mouse_shape(image:pointer); assembler;
asm
	les	bx,image	{-- es:bx = image address }
	mov	ax,es

	cmp	bx,sh_o		{-- check if it's a new one }
	je	@@bye
	cmp	ax,sh_s
	je	@@bye

	mov	dx,es:[bx]	{-- get width }
	mov	cx,es:[bx+2]	{-- get height }
	add	bx,4		{-- set to address }
	xchg	bx,dx		{-- swap dx,bx }

	mov	ax,09h  	{-- set graphics cursor block }
	int	33h
@@bye:
end;


{$L ..\mouse\marco.obj}
procedure marco; external;

{$L ..\mouse\arrow.obj}
procedure arrow; external;

{$L ..\mouse\help.obj}
procedure help; external;

{$L ..\mouse\hour.obj}
procedure hour; external;

{$L ..\mouse\cross.obj}
procedure cross; external;

{$L ..\mouse\ibeam.obj}
procedure ibeam; external;

{$L ..\mouse\uarrow.obj}
procedure uarrow; external;

{$L ..\mouse\darrow.obj}
procedure darrow; external;

{$L ..\mouse\larrow.obj}
procedure larrow; external;

{$L ..\mouse\rarrow.obj}
procedure rarrow; external;

{$L ..\mouse\lrarrow.obj}
procedure lrarrow; external;

{$L ..\mouse\udarrow.obj}
procedure udarrow; external;

{$l ..\mouse\disk.obj}
procedure disk; external;


{------------------------------------------------}
begin
 m_marco:=@marco;
 m_disk:=@disk;

 m_arrow:=@arrow;
 m_cross:=@cross;
 m_hour:=@hour;
 m_help:=@help;
 m_ibeam:=@ibeam;

 m_uarrow:=@uarrow;
 m_darrow:=@darrow;
 m_larrow:=@larrow;
 m_rarrow:=@rarrow;
 m_lrarrow:=@lrarrow;
 m_udarrow:=@udarrow;
end.
