
{$A+,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$D+,L+,Y+}
{-------------------------------------------
  If you pass any parameter, VGA synch will
  not be in effect
--------------------------------------------}

program put_demo;
uses game,vga,vga_hard,palette;


type
 pal = record
  r,g,b:byte;
 end;

var
 x,y,x1,y1,i,c:integer;
 pal1 : array[0..255] of pal;		{-- Palette }
 data : array[0..62000] of byte;	{-- Buffer to store graphic }
 screen, buffer:pointer;
 vsyn : word;



{$L \tp7\data\pics\ryo.obj}
procedure ryo; external;

{----------------------------------------------------------------------
  In Turbo Pascal @var is the same as &var in C, the address operator.

 Unlike C, you CANNOT use an array name as a pointer. For example in C
    char dat[200];	/*-- Array of 200 characters --*/
    char *what;		/*-- Pointer variable of type char --*/

    yxt=&dat[1];	/*-- These two do the same thing --*/
    txt=dat;

 In Pascal this IS illegal, "dat" does not exist as a pointer, dat
 is still a procedure. @dat is the dat address... Weird...
----------------------------------------------------------------------}

begin
 if (paramcount<>0) then vsyn:=0 else vsyn:=1;

 mode($13);
 pal_all(63,63,63);		{-- Don't want to see the graphic loading.}
 c:=read_pcx(@ryo,@pal1);	{-- Display graphic, store palette in @pal }
 vsynch(0);			{-- This vsynch will prevent flicker }

 get(83,20,234,170,@data);	{-- Get graphic (and black borders) }



 cls(0);
 writeln('Put Demo - Linear mode (mode 13)');
 writeln('--------------------------------');
 writeln('If you supply a parameter, screen');
 writeln('will not syncronize.');
 writeln;
 writeln('Press any key...');

 pal_set(@pal1);
 repeat
 until (readkey=_esc) or (readkey=_enter) or (readkey=_space);


 vsynch(0);
 mode($13);		{-- This will reset the cursor position }


 pal_set(@pal1);	{-- Restore palette, mode() changes it! }
 x:=random(200)+50;	{-- Let's bounce graphic }
 y:=random(100)+50;
 x1:=2;
 y1:=2;
 write('Clipping PUT'#13);
 repeat
  x:=x+x1;
  y:=y+y1;

  if (x>300) or (x<-130) then
  begin
   x1:=-x1;
   x:=x+x1;
  end;

  if (y>180) or (y<-130) then
  begin
   y1:=-y1;
   y:=y+y1;
  end;

  if (vsyn<>0) then vsynch(0);
  cput(x,y,@data);	{-- CPUT() is "ClippingPut" }
  cput(200-x,y,@data);
  cput(x,100-y,@data);
  cput(200-x,100-y,@data);
 until (readkey=_esc) or (readkey=_enter) or (readkey=_space);
 pal_light(@pal1,0);

 {-----------------------------}
 cls(0);
 write('NON Clipping put');
 pal_unlight(@pal1,1);
 x:=4;
 y:=4;
 repeat
  x:=x+x1;
  y:=y+y1;

  if (x>163) or (x<0) then
  begin
   x1:=-x1;
   x:=x+x1;
  end;

  if (y>50) or (y<0) then
  begin
   y1:=-y1;
   y:=y+y1;
  end;

  if (vsyn<>0) then vsynch(0);
  put(x,y,@data);
  put(163-x,y,@data);
  put(x,50-y,@data);
  put(163-x,50-y,@data);

 until (readkey=_esc) or (readkey=_enter) or (readkey=_space);
 pal_light(@pal1,0);

 {-----------------------------}
 cls(0);
 writeln;
 writeln('--- Non Modex -- -- Slow VGA --');
 writeln;
 writeln('RAM background image updating!');
 writeln('and using Clipping Put + Vsynch!');
 writeln;
 writeln('#1) Draw all in computer''s RAM');
 writeln('#2) Copy RAM to VGA RAM');
 writeln;
 writeln('Sloooow!!');


 {--------- Cool stuff ---------------}
 pal_unlight(@pal1,1);
 repeat
 until (readkey=_esc) or (readkey=_enter) or (readkey=_space);
 vsynch(1);			{-- delay for a while... }

 repeat
 until (readkey>=128);

 GETMEM(buffer,64000);		{-- Get 64K of ram }
 vga_addr(buffer);		{-- Set video address to buffer RAM }
 cls(0);			{-- Clear any garbage }
 x:=2;
 y:=2;
 x1:=4;
 y1:=4;

 repeat
  x:=x+x1;
  y:=y+y1;

  if (x>300) or (x<-130) then
  begin
   x1:=-x1;
   x:=x+x1;
  end;

  if (y>130) or (y<-130) then
  begin
   y1:=-y1;
   y:=y+y1;
  end;

  cput(x,y,@data);		{-- We're drawing in RAM, not VGA }
  cput(200-x,y,@data);
  cput(x,100-y,@data);
  cput(200-x,100-y,@data);
  if (vsyn<>0) then vsynch(0);
  vgaputscreen(buffer);		{-- copy buffer to VGA $a000:0000 }
 until (readkey=_esc) or (readkey=_enter) or (readkey=_space);

 {--- getscreen() and putscreen() use the vga_addr() value --- }
 {--- vgaputscreen() uses always the $a000:0000 address!   --- }

 mode(3);
 FREEMEM(buffer,64000);
end.
