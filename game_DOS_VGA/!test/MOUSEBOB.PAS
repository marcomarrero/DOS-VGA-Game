{----------------------------
  MOUSEBOB II (Mario Killer)
-----------------------------}
{$A-,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$D+,L+,Y+}

program mouse_bob;
uses game,vga,mouse,palette,vga_hard,sonic;

const
 SIZE	= 20;

 ADD	: integer = 1;


var
 pal  : pal_type;		{-- pal[0].r, pal[0].g,... }

 x,y,x1,y1 : integer;
 g,b	   : word;



{----------------------------  Main problemo ---------------------------}
begin
 mode($13);		{-- VGA screen... }


{----------------------------------------------------------------------
 I'm going to do this with the palette:  (all are incremented by 32 )
   0..31	: blue going up
   32..63 	: blue going down
   64..95	: red going up
   95..127	: red going down
   128..159	: green going up
   160..191	: green going down
   192..223	: pink going up
   224..255	: ping going down
--------------------------------------------------------------------}

{-----------.------------------------------.-----}
{-----------|rgb  |*pal|  rgbadd | from..to|-----}

 pal_spread(0,0,0,  @pal, 0,0,2,  000,031);	{-- blue }
 pal_spread(0,0,63, @pal, 0,0,-2, 032,063);

 pal_spread(0,0,0,  @pal, 2,0,0,  064,095);	{-- red }
 pal_spread(63,0,0, @pal, -2,0,0, 096,127);

 pal_spread(0,0,0,  @pal, 0,2,0,  128,159);	{-- green }
 pal_spread(0,63,0, @pal, 0,-2,0, 160,191);

 pal_spread(0,0,0,  @pal, 2,0,2,  192,223);	{-- pinky }
 pal_spread(63,0,63,@pal, -2,0,-2,224,255);



 pal_set(@pal);		{-- done!...}



{---------------------------------
	  Bob demo in here
----------------------------------}

 mouse_on;		{-- init mouse hardware & show it }
 if (ismouse=0) then
 begin
  _errormsg:='Mouse/Driver not detected...';
  halt(1);
 end;

 repeat
  mousek;		{-- read mouse }

  if (mk=1) then	{-- if left button held do this }
  begin
   mouse_hide;

   repeat
    mousek;

    if readkey = _x then
    begin
      sonic2;
    end;

    mx:=mx SHR 1;

    if (moved>0) then
    begin
     boxfilladd(mx-SIZE,my-SIZE,mx+SIZE,my+SIZE,ADD);
     boxfilladd(320-mx-SIZE,my-SIZE,320-mx+SIZE,my+SIZE,ADD);
     boxfilladd(mx-SIZE,200-my-SIZE,mx+SIZE,200-my+SIZE,ADD);
     boxfilladd(320-mx-SIZE,200-my-SIZE,320-mx+SIZE,200-my+SIZE,ADD);
    end;


   until (mk=0);

   mouse_show;
  end;


 until (mk=2) or (readkey<128);

 mode(3);
end.
