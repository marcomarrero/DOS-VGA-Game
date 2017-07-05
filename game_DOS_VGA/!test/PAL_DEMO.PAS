{$A+,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$D+,L+,Y+}

{--------------------------------------------------------------------------
 | Trilogy palette demo - Version 3 |
 ------------------------------------
 Because VGA has only 256 miserable colors, we must deal with a rather
 limited palette. VGA has 262,144 colors, really 64 shades of red,green,blue
 (0..63). So, 64*64*64 = 262,144. So, each color can be anything.

 If VGA could handle 24 bit color (16 million colors) we wouldn't need a
 palette because we can display all of them on-screen. This would slow
 miserably pallette effects, but we could make nice effects. As you
 might know, the Super Nintendo can handle 320x200x256 with 262,144 colors
 and costs much less than a Super VGA card.

 Quickbasic handles the palette in an formidably-hateful stupid way,
 and it's abysmally slow -- so forget about it.

 VGA.TPU manages palette just like VGA hardware, in (red,green,blue).
 It can manage a palette list, to make easy fades...

 *NEW*

 Flicker was eliminated due to a *stupid* mistake updating a hardware
 value that automatically updates itself. Gee, I tried that but didn't
 work before and now it works?!? Programming... Sigh...

 Pal Modify did not work on previous releases because of a bug handling
 bytes. Now it works correctly and the last one doesn't get all white.
--------------------------------------------------------------------------}
program paldemo;
uses game,vga,palette;

var
 x,y,x1,y1,i,c:word;
 pal1 : pal_type;		{--- pal1[0].r, pal1[0].g, pal1[0].b }


{$L c:\game\graph\sufre.obj}	{-- Graphic }
procedure sufre; far; external;

{--- All palette commands must use the (red,green,blue) format, 0 to 63 ---}

begin
 mode($13);

 pal_all(0,0,0);		{-- Set all palette to 0,0,0 }
 x:=read_pcx(@sufre,@pal1);	{-- Read graphic, put palette in pal1 }
 if x<>0 then halt(10);

 pal_unfade(@pal1,1);	{-- from black to palette, delay 2 }
 pal_light(@pal1,0);	{-- from palette to white }
 pal_unlight(@pal1,0);	{-- from white to palette }
 pal_fade(@pal1,0);	{-- from palette to black }

 pal_modify(0,@pal1,0,0,10); 		{-- blue + 10 }
 vga_synch(100);


 pal_modify(0,@pal1,0,-20,0);		{-- green-20 }
 vga_synch(100);

 for x:=1 to 63 do
 begin
  pal_modify(0,@pal1,x,0,0);		{-- increment red }
 end;
 vga_synch(100);


 for x:=1 to 50 do
 begin
  pal_modify(0,@pal1,x,-x div 2,-x div 2); {-- add red, decement blue,gren }
 end;
 vga_synch(100);

 for x:=1 to 50 do
 begin
  pal_modify(1,@pal1,-x,-x,0);
 end;
 vga_synch(100);

 pal_fade(@pal1,3);		{-- Nice, unstoppable effect }

 mode(_lastmode);
end.
