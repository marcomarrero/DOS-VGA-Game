{$A+,B-,E+,F-,G+,I-,N+,O-,P-,Q-,R-,S-,T-,V-,X-}
{$D+,L+,Y+}

{---------------------------------------------------------------------
  The fantastic screen demo!
  Things so lame you know that the PC can do but nobody cares about!

  Starring:	Marco!
  Comment:	The "sine wave" demo is way cool!!
---------------------------------------------------------------------}
program screen_demo;
uses vga,palette,vga_hard,game,picture;

{--- picture.tpu ---------------------------------------------------------
   Because this graphic is *huge*, must use a unit. Units use a different
  code segment, and must use far calls. If you compile VGA/GAME into an
  unit, DON'T make them public because they are near and will crash!

   That means, if an unit uses VGA/GAME is for it own use. Each unit must
  have its own VGA/GAME.
-------------------------------------------------------------------------}


{--- game.tpu -----------------------------------
  Please read the info included in KEY.PAS
-----------------------------------------------}

type
 pal = record
  r,g,b:byte;
 end;

const
 vgascreen : pointer = ptr($a000,0);
var
 x,y,x1,y1,i,c	: integer;
 ledi,ledi2,wai	: integer;

 rx,ry,rsx,rsy	: real;
 comput		: array[0..199] of integer;

 pal1		: array[0..255] of pal;
 r,g,b		: integer;

 screen,putbuf	: pointer;
 list		: array[0..199] of pointer;

 sliip		: word;

label
 testing;


{---------------------------------------
    Programmer/Demo information
----------------------------------------}
procedure marcoinfo;
begin
 mode(_lastmode);
 echo('³ÝÛ²±° In your Face v1.00'#13#10,15);
 echo('³ÝÛ²±° ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'#13#10,15);
 echo('³ÝÛ²±° Programado por Marco A. Marrero'#13#10,15);
 echo('³ÝÛ²±° Morse #49, Box 453 Arroyo, PR 00714'#13#10,15);
 echo('³ÝÛ²±° ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'#13#10,15);
 echo('³ÝÛ²±°'#13#10,15);
 echo(#13#10,15);
 halt;
end;



{---------------
  kit
---------------}
procedure kit;
begin
 inc(wai);
 if (wai>8) then
 begin
  wai:=0;
  ledi:=ledi+ledi2;
  if (ledi=1) or (ledi=3) then ledi2:=-ledi2;

  if ledi=1 then key_leds(2)
  else if ledi=2 then key_leds(4)
  else key_leds(1);
 end;
end;



{---------------------------
   Quit....
---------------------------}
procedure bye_bye;
begin
 biosgotoxy(13,10); echo('ÛßßßßßßßßßßßßßßßÛ',250);
 biosgotoxy(13,11); echo('Û'#0#249' ¨No te gust¢? '#0#250'Û',250);
 biosgotoxy(13,12); echo('ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ',250);
 pal_fade(@pal1,1);
 marcoinfo;
end;



{---------------------------------------
  Wait for a key, if [esc] exit.
----------------------------------------}
procedure mwait;
begin
 asm sti; end;
 sliip:=0;
 repeat
  vsynch(0);
  kit;
  inc(sliip);
 until (readkey=_esc) or (readkey=_enter) or (readkey=_space) or (timerw>10000);

 {-- exit? --}
 if (readkey=_esc) then bye_bye;


 pal_fade(@pal1,0);
 cls(0);
 pal_set(@pal1);
end;


{---------------------- MAIN ---------------------}

begin
 ledi:=1;ledi2:=1; wai:=0;

 mode($13);
 vga_vblank(396,2);
 video_lorez;

 pal_all(0,0,0);
 getmem(screen,64004);		{-- Allocate just 128K }
 getmem(putbuf,64004);		{-- screen and get/put buffer }

 if (screen=nil) or (putbuf=nil) then
 begin
  _errormsg:='Insufficient memory!';
  halt(8);
 end;


{-------------------------------------------------
   We're going to draw in the background screen
   a picture and then draw it to the visible one.

   This is the "hidden screen" demo. The rest do
   a different thing.
--------------------------------------------------}

 vga_addr(screen);		{-- Set RAM buffer, so PCX will be in RAM }

 if (read_pcx(@vax_320,@pal1)<>0) then	{-- Read me in the RAM buffer }
   halt(1);


 pal_set(@pal1);

 x:=0;
 while (x<12) do
 begin
  y:=x;
  vsynch(5);
  while (y<320) do
  begin
   vga_addr(screen);		{-- Set RAM buffer }
   get(y,0,y,199,putbuf);	{-- Get line from RAM buffer }
   vga_addr(vgascreen);		{-- Set VGA buffer }
   put(y,0,putbuf);		{-- Put line in VGA screen }
   inc(y,12);
  end;
  inc(x);
 end;


 freemem(putbuf,64004);
 freemem(screen,64004);		{-- De-Allocate 128K }



{-----------------------------------------------------------------
  We're going to get *each* horizontal line into a memory area.
  Instead of using a mother of arrays, we dynamically allocate
  memory. Remember, we only got 640K unless we buy Borland Pascal
  which can use 286 protected mode.

  Turbo Pascal returns a run-time error when there is no memory
  available. It could be that you really ran out of RAM or that
  it's absolutely badly fragmented. (This RAM is the "heap",
  the memory free of 640K)
------------------------------------------------------------------}

 box(0,0,319,199,0);		{-- Black border }


 for y:=0 to 199 do
 begin
  getmem(list[y],324);		{-- Allocate memory for each horiz. line }
  get(0,y,319,y,list[y]);       {-- Get it }
 end;


{**************************** GOTO in here! *******************************}
 goto testing;
 testing:
{---- END OF DANGEROUS GOTO ---}

 cls(0);

{-------------------------------------------------
  Interlace - Two broken screens merging into one
--------------------------------------------------}
 for x:=0 to 320 do
 begin

  vsynch(0);
  for y:=0 to 199 do
  begin
   if (y mod 2)=0 then
     cput(320-x,y,list[y])
   else
    cput(x-320,y,list[y]);
  end;
 end;

 mwait;

{--------------------------------------------------------------
  Paint roll - Looks like a bucket of paint spilled all over.
---------------------------------------------------------------}
 for y:=0 to 199 do
 begin
  vsynch(0);
  for x:=y to 199 do
   cput(0,x,list[y]);

 end;

 mwait;

{-----------------------------------------------------------------
  From right - Slanted image scrolling and stops (broken) on left
------------------------------------------------------------------}
 x:=323;
 while (x>-199) do
 begin
  dec(x,3);
  vsynch(0);
  for y:=0 to 199 do
   if (x+y>=0) then cput(x+y,y,list[y]);
 end;

 mwait;


{--------------------------------------------------------------
  Cinema - Movie camera with *serious* problems with film.
---------------------------------------------------------------}
 for i:=25 downto 1 do
 begin
  x:=0;
  vsynch(6);
  for y:=0 to 199 do
  begin
   cput(0,y,list[x]);
   x:=x+i;
   if x>199 then x:=0;
  end;
 end;

 mwait;


{-----------------------------------------------------------------
  Head to head - A four eyed monster. Stupid effect, weird result.
------------------------------------------------------------------}
 for i:=99 downto 0 do
 begin
  vsynch(0);
  for y:=i to 99 do
  begin
   cput(0,y,list[y-i]);
   cput(0,99+y,list[199-(99+y)]);
  end;
 end;

 mwait;

{-------------------------------------------------------------------
  Sine Wave - Waving image
 -------------------------------------------------------------------------

   I first fill a table with SIN values and the I display it. It prevents
  flicker if we do all computations before displaying the actual image. This
  math is fairly elemental, just keep in mind that computers likes math
  in radians. PI=3.14, 2PI=6.28...

   In Pascal we *must* convert numeric data types. In C the compiler changes
  from floats (real) to integer without need of INT() or TRUNC().

  ry	affects speed of waves
  rx	affects wave frequency	(vertical size, number of cycles)
  i	affects the amplitude	(horizontal)

  Pressing "+" or "-" will modify amplitude.
  Pressing "." or "," will modify speed.
  Pressing "]" or "[" will modify frequency.

  Pressing "r,R,g,G,b,B" will change palette.


  Unfortunately, clearing the display is too slow for these routines to do
  that on a single synch. Sorry for the garbage at left/right...
---------------------------------------------------------------------------}
 rx:=0; ry:=0;
 rsx:=0.03;
 rsy:=0.1;
 i:=25;

 r:=0;
 g:=0;
 b:=0;
 readkey:=128;
 repeat
  {-- manage keyboard -- key.pas has a nice table! -- }

  if readkey=78 then inc(i,5)			{ + }
  else if readkey=13 then inc(i,5)		{ = }
  else if readkey=12 then dec(i,5)		{ - }
  else if readkey=52 then rsy:=rsy+0.03		{ . }
  else if readkey=51 then rsy:=rsy-0.03		{ , }
  else if readkey=26 then rsx:=rsx+0.01		{ [ }
  else if readkey=27 then rsx:=rsx-0.01		{ ] }


  {-- This is tricky, read [Shift] and key --}
  else if (keyboard[_lshift]=0) and (keyboard[_r]<>0) then	{-- small r }
  begin
   inc(r,4);
   pal_modify(0,@pal1,r,g,b);
  end
  else if (keyboard[_lshift]<>0) and (keyboard[_r]<>0) then	{-- big R }
  begin
   dec(r,4);
   pal_modify(0,@pal1,r,g,b);
  end

  else if (keyboard[_lshift]=0) and (keyboard[_g]<>0) then	{-- small g }
  begin
   inc(g,4);
   pal_modify(0,@pal1,r,g,b);
  end
  else if (keyboard[_lshift]<>0) and (keyboard[_g]<>0) then	{-- big G }
  begin
   dec(g,4);
   pal_modify(0,@pal1,r,g,b);
  end

  else if (keyboard[_lshift]=0) and (keyboard[_b]<>0) then	{-- small b }
  begin
   inc(b,4);
   pal_modify(0,@pal1,r,g,b);
  end
  else if (keyboard[_lshift]<>0) and (keyboard[_b]<>0) then	{-- big B }
  begin
   dec(b,4);
   pal_modify(0,@pal1,r,g,b);
  end;


  {-- let's do the math --}
  ry:=ry+rsy;
  if ry>6.28 then ry:=ry-6.28;
  rx:=ry;

  for y:=2 to 197 do
  begin
   rx:=rx+rsx;				{-- go to 0PI to 2PI }
   if rx>6.28 then rx:=rx-6.28;
   comput[y]:=trunc(sin(rx)*i);		{-- fill coordinate table }
  end;


  {-- plot image --}
  vsynch(0);
  for y:=2 to 197 do
   cput(comput[y],y,list[y]);

 until (readkey=_enter) or (readkey=_space) or (readkey=_esc);

{--------- Finis -----------}

 for y:=0 to 199 do
   freemem(list[y],324);		{-- De-allocate memory! }

 pal_fade(@pal1,1);
 marcoinfo;
end.
