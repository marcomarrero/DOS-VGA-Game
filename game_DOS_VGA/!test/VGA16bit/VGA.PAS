{======================================================================
	Stupid 286 VGA routines -  Programmed by Marco A. Marrero
 ======================================================================
	Freeware!! --  Version 2.00 -- For Turbo Pascal 7.0
 ----------------------------------------------------------------------
  These are low-performance, awfully stupid 286 VGA routines. It
  does not use the features of the VGA card and will please all
  286 and 386sx fans, especially those PC's usually found at college...

  The only way possible to do things fast, it's by doing 16 bits at a
  time instead of 8 bit, and avoiding jumps. Thanks for IBM for making
  the PC  with such a stupid hardware (naaah, they just got all PC parts
  from an electronic shop). It's a waste of time doing games for PC,
  so I hope this is the last thing I'll ever do in assembler.

  The code is optimized for 8088/80286 and 80386SX. If you want 486
  code, just do all 32 bits at a time and avoid "CISC" commands
  such as MOVS, LOOP, etc.
 ======================================================================}

{A+,X-,F+,B-,T-,V-,G+,E-,I-,N-,O-,P-}
{$R-,Q-,S-}
{$D-,L-,Y-}

unit vga;
interface

type
 sprite = record
  x    : word;
  y    : word;
  info : array[0..255] of byte;
 end;

 alpha = record
  x	: word;
  y	: word;
  info	: array [0..29] of byte;
 end;

const
{----- Key values }
 Space= 32;  Enter= 13;  Esc= 27; Tab= 9; Backspace= 8;

{---- Ekey values }
 Ins=82;  Del=83; Home=71;  Ed=79; PgUp=73;
 Up =72;  Down=80; Left=75;  Right=77;  PgDn=81;

{---- Special }
 screen : word = $a000;
 color	: byte = 0;

procedure mode(num:integer);
function readkey : word;
procedure palette(color,red,green,blue:integer);
procedure vsynch;
procedure vwait;
procedure readmode(num:integer);
procedure writemode(num:integer);
procedure get16(x,y:word; image:pointer);
procedure put16(x,y:word; image:pointer);
procedure get10(x,y:word; image:pointer);
procedure put10(x,y:word; image:pointer);
procedure put10add(x,y:word; image:pointer; num:byte);
procedure get6(x,y:word; image:pointer);
procedure put6(x,y:word; image:pointer);
procedure put6or(x,y:word; image:pointer);
procedure pokeb(segi,ofi:word ; c:byte);
procedure pokew(segi,ofi:word ; c:word);
procedure pset(x,y,color:word);
function point(x,y:word) : word;
procedure read_pcx(where:pointer);
procedure cls(color:integer);


implementation
{----------------------------- Procedures --------------------------------}

{------------------------
  Select graphics mode
-------------------------}
procedure mode(num:integer); assembler;
asm
		mov 	ax,num
		int 	10h
end;

{--------------------------
	 Read keyboard
---------------------------}
function readkey : word;
begin
asm
		mov	dl,0ffh		{-- Read keyboard }
		mov	ah,06		{-- using func 06 Int 21 }
		int	21h
		xor	ah,ah
		mov	@result,ax
end;
end;

{--------------------------
  Change the color palette
---------------------------}
procedure palette(color,red,green,blue:integer); assembler;
asm
		mov	dx,03C8h
		mov	ax,color
		out	dx,al
		inc	dx
		mov	ax,red
		out	dx,al
		mov	ax,green
		out	dx,al
		mov	ax,blue
		out	dx,al
end;


{-------------------------------------
  Synchronize to the Vertical retrace
--------------------------------------}
procedure vsynch; assembler;
asm
		mov	dx,03DAh		{-- Status register }
		mov	ah,8

@v_still:	in	al,dx
		test	al,ah
		jnz	@v_still

@v_wait:	in	al,dx
		test	al,ah
		jz	@v_wait
end;


{-------------------------------
  Wait for the vertical retrace
--------------------------------}
procedure vwait; assembler;
asm
		mov	dx,03DAh		{ status register }
		mov	ah,8

@w_wait:	in	al,dx
		test	al,ah
		jz	@w_wait
end;

{----------------------------
   Sets the VGA read mode
-----------------------------}
procedure readmode(num:integer); assembler;
asm
		mov	ax,num
		mov	ah,al
		mov	dx,3ceh 	{ Graph index }
		mov	al,5
		out	dx,al
		inc	dx
		in	al,dx
		and	al,11111100b	{ clear out write mode bits }
		and	ah,00000011b
		or	al,ah
		out	dx,al
end;


{--------------------------
  Sets the VGA write mode
----------------------------}
procedure writemode(num:integer); assembler;
asm
		mov	ax,num
		mov	ah,al

		mov	dx,3c3h		{ Graph index }
		mov	al,5
		out	dx,al
		inc	dx
		in	al,dx
		and	al,11110111b	{ Clear out write mode bits }
		shl	ah,3		{ Move bit to correct position }
		and	ah,00001000b
		or	al,ah
		out	dx,al
end;


{---------------------
  Get a 16x16 block
---------------------}
procedure get16(x,y:word;image:pointer); assembler;
asm
		mov	bx,320

		mov	ax,y		{-- calculate SI screen position }
		mul	bx		{-- DS:SI = scren source }
		mov	si,ax
		add	si,x

		les	di,image	{-- ES:DI = sprite (dest.) }

		mov	ax,16
		stosw			{-- store image width/height }
		stosw

		push	ds
		mov	ds,screen	{-- DS:SI = screen (source) }
		mov	ax,304		{-- vertical adder }

{1}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add 	si,ax
{2}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{3}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add 	si,ax
{4}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{5}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{6}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{7}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{8}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{9}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{10}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{11}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{12}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{13}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{14}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{15}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	si,ax
{16}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw

		pop 	ds
end;

{---------------------
  Puts a 16x16 block
---------------------}
procedure put16(x,y:word; image:pointer); assembler;
asm
		mov	es,screen	{-- ES:DI = screen }

		mov	bx,320
		mov	ax,y		{-- calculate DI screen position }
		mul	bx
		mov	di,ax
		add	di,x

		push	ds

		lds	si,image
		add	si,4		{-- Ignore height and width }

		mov	ax,304		{-- vertical adder }

{1}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{2}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{3}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{4}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{5}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{6}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{7}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{8}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{9}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{10}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{11}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{12}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{13}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{14}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{15}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw
		add	di,ax
{16}		movsw; movsw; movsw; movsw; movsw; movsw; movsw; movsw

		pop 	ds
end;

{---------------------
  Get a 10x10 block
---------------------}
procedure get10(x,y:word;image:pointer); assembler;
asm
		mov	bx,320

		mov	ax,y		{-- calculate SI screen position }
		mul	bx		{-- DS:SI = scren source }
		mov	si,ax
		add	si,x

		les	di,image	{-- ES:DI = sprite (dest.) }

		mov	ax,10
		stosw			{-- store image width/height }
		stosw

		push	ds
		mov	ds,screen	{-- DS:SI = screen (source) }

		mov	ax,310		{-- vertical adder }

{1}		movsw; movsw; movsw; movsw; movsw; add si,ax
{2}		movsw; movsw; movsw; movsw; movsw; add si,ax
{3}		movsw; movsw; movsw; movsw; movsw; add si,ax
{4}		movsw; movsw; movsw; movsw; movsw; add si,ax
{5}		movsw; movsw; movsw; movsw; movsw; add si,ax
{6}		movsw; movsw; movsw; movsw; movsw; add si,ax
{7}		movsw; movsw; movsw; movsw; movsw; add si,ax
{8}		movsw; movsw; movsw; movsw; movsw; add si,ax
{9}		movsw; movsw; movsw; movsw; movsw; add si,ax
{10}		movsw; movsw; movsw; movsw; movsw

		pop 	ds
end;


{---------------------
  Puts a 10x10 block
---------------------}
procedure put10(x,y:word; image:pointer); assembler;
asm
		mov	es,screen	{-- ES:DI = screen }

		mov	bx,320
		mov	ax,y		{-- calculate DI screen position }
		mul	bx
		mov	di,ax
		add	di,x

		push	ds

		lds	si,image
		add	si,4		{-- Ignore height and width }

		mov	ax,310		{-- vertical adder }

{1}		movsw; movsw; movsw; movsw; movsw; add di,ax
{2}		movsw; movsw; movsw; movsw; movsw; add di,ax
{3}		movsw; movsw; movsw; movsw; movsw; add di,ax
{4}		movsw; movsw; movsw; movsw; movsw; add di,ax
{5}		movsw; movsw; movsw; movsw; movsw; add di,ax
{6}		movsw; movsw; movsw; movsw; movsw; add di,ax
{7}		movsw; movsw; movsw; movsw; movsw; add di,ax
{8}		movsw; movsw; movsw; movsw; movsw; add di,ax
{9}		movsw; movsw; movsw; movsw; movsw; add di,ax
{10}		movsw; movsw; movsw; movsw; movsw


		pop 	ds
end;

{--------------------------------------
  Puts a 10x10 block with color adder
---------------------------------------}
procedure put10add(x,y:word; image:pointer; num:byte); assembler;
asm
		mov	es,screen	{-- ES:DI = screen }

		mov	bx,320
		mov	ax,y		{-- calculate DI screen position }
		mul	bx
		mov	di,ax
		add	di,x

		mov	dl,num		{-- dx=adder }
		mov	dh,dl

		push	ds

		lds	si,image
		add	si,4		{-- Ignore height and width }

		mov	bx,310		{-- vertical adder }

{1}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw; add di,bx

{2}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw; add di,bx

{3}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw; add di,bx

{4}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw; add di,bx

{5}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw; add di,bx

{6}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw; add di,bx

{7}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw; add di,bx

{8}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw; add di,bx

{9}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw; add di,bx

{10}		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;
		lodsw; add ax,dx; stosw;

		pop 	ds
end;
{---------------------
  Get a 6x5 block
---------------------}
procedure get6(x,y:word;image:pointer); assembler;
asm
		mov	bx,320

		mov	ax,y		{-- calculate SI screen position }
		mul	bx		{-- DS:SI = scren source }
		mov	si,ax
		add	si,x

		les	di,image	{-- ES:DI = sprite (dest.) }

		mov	ax,6
		stosw			{-- store image width/height }
		mov	ax,5
		stosw

		push	ds
		mov	ds,screen	{-- DS:SI = screen (source) }

		mov	ax,314		{-- vertical adder }

{1}		movsw; movsw; movsw; add si,ax
{2}		movsw; movsw; movsw; add si,ax
{3}		movsw; movsw; movsw; add si,ax
{4}		movsw; movsw; movsw; add si,ax
{5}		movsw; movsw; movsw

		pop 	ds
end;


{---------------------
  Puts a 6x5 block
---------------------}
procedure put6(x,y:word; image:pointer); assembler;
asm
		mov	es,screen	{-- ES:DI = screen }

		mov	bx,320
		mov	ax,y		{-- calculate DI screen position }
		mul	bx
		mov	di,ax
		add	di,x

		push	ds

		lds	si,image
		add	si,4		{-- Ignore height and width }

		mov	ax,314		{-- vertical adder }

{1}		movsw; movsw; movsw; add di,ax
{2}		movsw; movsw; movsw; add di,ax
{3}		movsw; movsw; movsw; add di,ax
{4}		movsw; movsw; movsw; add di,ax
{5}		movsw; movsw; movsw; add di,ax

		pop 	ds
end;

{---------------------------------------
  Puts a 6x5 block with color and OR
---------------------------------------}
procedure put6or(x,y:word; image:pointer); assembler;
asm
		mov	es,screen	{-- ES:DI = screen }

		mov	bx,320
		mov	ax,y		{-- calculate DI screen position }
		mul	bx
		mov	di,ax
		add	di,x

		push	ds

		lds	si,image
		add	si,4		{-- Ignore height and width }

		mov	bx,316		{-- vertical adder   }
		mov	dx,2		{-- horizontal adder }

{1}		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,bx

{2}		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,bx

{3}		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,bx

{4}		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,bx

{5}		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,dx
		lodsw; or es:[di],ax; add di,bx

		pop 	ds
end;

{----------------------
	Pokes a byte
-----------------------}
procedure pokeb(segi,ofi:word ; c:byte); assembler;
asm
		mov	ax,segi
		mov	es,ax
		mov	bx,ofi
		mov	al,c
		mov	es:[bx],al
end;


{----------------------
	Pokes a word
-----------------------}
procedure pokew(segi,ofi:word ; c:word); assembler;
asm
		mov	ax,segi
		mov	es,ax
		mov	bx,ofi
		mov	ax,c
		mov	es:[bx],ax
end;


{-----------------------
	 Plots a pixel
------------------------}
procedure pset(x,y,color:word); assembler;
asm
		mov	bx,320

		mov	ax,y
		mul	bx
		add	ax,x

		mov	di,ax
		mov	ax,color
		mov	es,screen

		stosb
end;


{--------------------------
	   Gets a pixel
--------------------------}
function point(x,y:word) : word;
begin
asm
		mov	bx,320

		mov	ax,y
		mul	bx
		mov	bx,ax
		add	bx,x

		mov	es,screen

		xor	ax,ax
		mov	al,es:[bx]
		mov	@result,ax
end;
end;


{--------------------------
	Clear screen
---------------------------}
procedure cls(color:integer); assembler;
asm
	mov	es,screen
	mov	ax,color
	mov	al,ah
	xor	di,di
	mov	cx,64000/256

@clir:	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	stosw; stosw; stosw; stosw; stosw; stosw; stosw; stosw
	dec cx
	jnz @clir
end;

{--------------------------
  Reads a PCX graphic
--------------------------}
procedure read_pcx(where:pointer); assembler;
asm
		mov	es,screen

		push	ds
		lds	si,where

		xor	di,di

		add	si,128		{ skip header }

		mov	bx,64000	{ constants }
		mov	dl,$c0
		mov	dh,$3f

@pcx:		mov	al,ds:[si]	{ get color or run-length }
		inc	si

		test	al,dl		{ $c0 }
		jz	@norle

		and	al,dh		{ $3f }
		mov	cl,al		{ CL=run length }

		mov	al,ds:[si]
		inc	si
		mov	ah,al

		shr	cl,1		{-- Run Length/2 }
		jc	@rle_b

@rle_w:		mov	es:[di],ax
		inc	di
		inc	di
		dec	cl
		jnz	@rle_w

		cmp	di,bx
		jb	@pcx
		jmp	@bye

@rle_b:		jz	@rle1b
@rleb:		mov	es:[di],ax
		inc	di
		inc	di
		dec	cl
		jnz	@rleb

@rle1b:		mov	es:[di],al
		inc	di
		cmp	di,bx
		jb	@pcx
		jmp	@bye

@norle:		mov	es:[di],al
		inc	di
		cmp	di,bx
		jbe	@pcx

@bye:		pop	ds
end;

begin
end.