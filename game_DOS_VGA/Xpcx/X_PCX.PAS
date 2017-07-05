{-----------------------------------------------------------------
  This is an experimental xPCX module reader. It may not work
  and erase all your hard disk, so be careful...
-----------------------------------------------------------------}
{$A+,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}

program x_pcx;
uses game,vga,vga_hard,modex,palette;

const
 pic1 : array[0..10] of char = 'eco360.pcx'#0;

var
 x,y,x1,y1	: integer;
 pal		: pal_type;
 buff		: array[0..49154] of byte;

{$L xpcx.obj}
{$F-}
procedure xpcx(filename:pchar; buffer:pointer; bsize:WORD; pal:pointer); external;


begin
 if paramcount>0 then
 begin
  writeln('³ÝÛ²±° Programado por Marco A. Marrero');
  writeln('³ÝÛ²±° Gr fica por Oscar Rodriguez, Mario Mart¡nez');
  writeln('³ÝÛ²±° Copyright (c) 1995 Trilogy Software.');
  halt(0);
 end;

 modex_set(M360x480,360,480);
 pal_all(63,63,63);
 xpcx(@pic1,@buff,49152,@pal);
 pal_unlight(@pal,1);
 wait_key;
 pal_fade(@pal,1);
 mode(_lastmode);
end.
