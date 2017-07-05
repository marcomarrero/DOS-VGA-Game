{---------------------------------
  PCX 320x200x256.
  Programado por Marco A. Marrero
----------------------------------}

program pcx;
const
 screen : word = $a000;


var
 fil : file of byte;
 buf : array[1..64000] of char;
 m,r,g,b : byte;
 x,i	 : word;

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
procedure palette(color,red,green,blue:byte); assembler;
asm
		mov	dx,03C8h
		mov	al,color
		out	dx,al
		inc	dx
		mov	al,red
		out	dx,al
		mov	al,green
		out	dx,al
		mov	al,blue
		out	dx,al
end;



{------------------------
 Pokes a byte to screen
-------------------------}
procedure pokeb(where:word; c:byte); assembler;
asm
		mov	es,screen

		mov	bx,where
		mov	al,c
		mov	es:[bx],al
end;



{********************************* MAIN ***********************************}
begin

 mode($13);

 assign(fil,'c:\mmedia\graph\marco2.pcx');
 reset(fil);
 seek(fil,128);

 x:=0;
 repeat
  read(fil,m);

  if (m and $C0)=$C0 then

  begin
   i:=(m and $3F);
   read(fil,m);
   repeat
    pokeb(x,m);
    inc(x);
    dec(i);
   until i=0;
  end

  else

  begin
   pokeb(x,m);
   inc(x);
  end;

 until x>=64000;

 read(fil,m);
 for m:=0 to 255 do
 begin
  read(fil,r);
  read(fil,g);
  read(fil,b);
  r:=r shr 2;		{-- r:=r div 4 }
  g:=g shr 2;
  b:=b shr 2;
  palette(m,r,g,b);
 end;

 readln;
 close(fil);
 mode(3);
end.