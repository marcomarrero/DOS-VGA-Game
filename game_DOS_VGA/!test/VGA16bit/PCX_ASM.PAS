{$A-,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$D-,L-,Y-}

const
 screen : word = $a000;

var
 what : pointer;
 x,y,i : integer;
 j,k	: integer;


{----------------------------- Procedures --------------------------------}

{--------------------------
      Wait for a key
------------------------}
procedure wait_key; assembler;
asm
	@wai:	mov	dl,0ffh		{-- Read keyboard }
		mov	ah,06		{-- using func 06 Int 21 }
		int	21h
		or	al,al
		jz	@wai
end;

{--------------------------
      read for a key
------------------------}
function read_key : byte; assembler;
asm
		mov	dl,0ffh		{-- Read keyboard }
		mov	ah,06		{-- using func 06 Int 21 }
		int	21h
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


{------------------------
  Select graphics mode
-------------------------}
procedure mode(num:integer); assembler;
asm
		mov 	ax,num
		int 	10h
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

		push	ds
		mov	ds,screen	{-- DS:SI = screen (source) }

		mov	ax,314		{-- vertical adder }

{6}		movsw; movsw; movsw; add si,ax
{7}		movsw; movsw; movsw; add si,ax
{8}		movsw; movsw; movsw; add si,ax
{9}		movsw; movsw; movsw; add si,ax
{10}		movsw; movsw; movsw

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

		mov	ax,314		{-- vertical adder }

{1}		movsw; movsw; movsw; add di,ax
{2}		movsw; movsw; movsw; add di,ax
{3}		movsw; movsw; movsw; add di,ax
{4}		movsw; movsw; movsw; add di,ax
{5}		movsw; movsw; movsw

		pop 	ds
end;


{-------------------------------------------------------------------------
  read_pcx(where:pointer; palette:word) || Reads a PCX graphic
 -------------------------------------------------------------------------
  where : Address of buffer where the PCX file is located. In C++ it would
	  be "char far *where". There is a Pascal command to read buffers
	  BlockRead. Or, you can use BINOBJ.EXE to convert a .PCX file to
	  a .OBJ file. The file MUST be 320x200 and it must not exceed 64K.
	  (If it is >64K you are an idiot because the screen uses 60K...)

  palette: If it is zero, the palette won't be displayed.
--------------------------------------------------------------------------}

procedure read_pcx(where:pointer; palette:word); assembler;
asm
		push	ds

		mov	es,screen	{-- es:di = screen }
		xor	di,di

		lds	si,where	{-- ds:si = graph  }

		mov	bx,64000	{ constants }
		mov	dl,0c0h
		mov	dh,03fh

		add	si,128		{ skip header }

@pcx:		lodsb			{ get color or run-length }

		mov	ah,al
		and 	ah,dl
		cmp	ah,dl		{ $C0 }
		jne	@norle

		and	al,dh		{ $3f }
		xor	ch,ch
		mov	cl,al		{ CL=run length }

		lodsb			{ Get color }
		mov	ah,al

		shr	cx,1		{ cx/2, we'll draw in words }

		rep	stosw		{ -- store all words }
		adc	cx,cx		{ -- Add carry (1 if cx was odd) }
		rep	stosb		{ -- store a byte IF present }

		cmp	di,bx		{ Got past end?? }
		jb	@pcx
		jmp	@bye

@norle:		stosb			{ Store one pixel }
		cmp	di,bx
		jbe	@pcx

@bye:           mov	bx,ds
		pop	ds

		mov	ax,palette
		or	ax,ax
		jz	@byebye

		push	ds
		mov	ds,bx


		xor	cl,cl
		mov	dx,03C8h

@coloriz:	mov	al,cl
		out	dx,al
		inc	dx

		lodsb
		shr	al,2
		out	dx,al

		lodsb
		shr	al,2
		out	dx,al

		lodsb
		shr	al,2
		out	dx,al

		dec	dx
		inc	cl
		jnz	@coloriz

		pop	ds
@byebye:
end;



procedure shak2; external; {$L c:\mmedia\graph\shak2.obj}


begin
 getmem(what,16384);
 mode($13);

 for x:=0 to 255 do
   palette(x,0,0,0);

 read_pcx(@shak2,0);

 for y:=0 to 63 do
 begin
  vwait;
  for x:=0 to 255 do
   if (y shl 2)<x then palette(x,y,y,y);
 end;

 wait_key;

{ repeat
  x:=random(309);
  y:=random(189);
  get10(x,y,what);
  put10(x,y+1,what);

  x:=random(309);
  y:=random(189);
  get10(x,y,what);
  put10(x+1,y,what);

  x:=random(309)+2;
  y:=random(189)+2;
  get10(x,y,what);
  put10(x,y-1,what);

  x:=random(309)+2;
  y:=random(189)+2;
  get10(x,y,what);
  put10(x-1,y,what);
 until (read_key<>0); }

 for y:=63 downto 0 do
 begin
  vwait;
  for x:=0 to 255 do
   if (y shl 2)<x then palette(x,y,y,y);
 end;

 mode($3);
 freemem(what,16384);
end.