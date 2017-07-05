{------------------------------------------------------------------------
  kid v1.00.03
  (c) 1995 Marco A. Marrero
----------------------------}
program kid_1;
uses game,vga,palette;

{,sonic;}

const
 FALL=1; JUMP=2; DUCK=3; DEAD=4; TURN=5;	{-- What you're doing? }
 WALK=6;
 LEFT=13; RIGHT=0; 				{-- Where is he facing }
 FRAMEWAIT = 8;			{-- Frames to skip before moving }

type

{--------------------------------------------------------------------------
  kidsType : This data record has all the information of the "kids" or
	    player. Currently it is for a 1-player game but with few
	    changes it could be used to become a multiplayer game.
	    So, please, use data structures...

 To avoid centering and all that mess, I've enclosed the images in
 predefined block sizes. This is ceirtanly a terrible waste of memory
 and loss of efficiency but it's not my fault that the 1979 Atari 400
 had sprites and the 1983 PC has nothing like that.

 x,y   : Screen coordinates, upper left corner.
 frame : Image frame or pose. What kind of image to use at the moment.
 fcount: Frame counter. Number of "steps" to skip. If we move things
	 60 times per second, we WON'T animate the guy 60 times too.
	 You can change the FRAMEWAIT constant to see the effect
 facing: I wanna know if kids is facing either left or right
 what  : If he is jumping, falling or standing or whatever.

-------------------------------------------------------------------------}

 kidstype = record
  x,y	: integer;		{-- His coordinates }
  frame : word;		{-- Animation frame }
  fcount: integer;	{-- Frame counter (time to remain in pose) }
  facing: word;		{-- Facing LEFT or RIGHT?? }
  what  : word;		{-- What is he doing? (FALL/JUMP) }
  lives : word;		{-- Lives }
  image : array[0..32] of pointer;
			{-- Sprites (PC don't have... Symbolic of C-64...}
 end;


var
 x,y,i	: integer;	{-- Dummy globals }
 lp,up	: integer;
 skip	: integer;

 pix1,pix2 : word;

 bad	: pointer;	{-- Bad guy }
 fire1	: pointer;	{-- Fireball }
 fire2	: pointer;
 pal	: pal_type;	{-- palette table }

 kids   : kidstype;

 screen : pointer;	{-- Working screen }
 backg	: pointer;	{-- Still background }


 brick,redbrick,bluebrick : pointer;
 cross,floor		  : pointer;

 whoa	: integer;

{--------------------
   kids graphics
---------------------}
{$L kid.obj}
procedure kid; external;



{---------------------------------------
  Outta memory
---------------------------------------}
procedure no_ram;
begin
 mode($3);
 writeln('³İÛ²±° ==== Error when initializing KID ===');
 writeln('³İÛ²±° Problem   : Out of conventional memory!!');
 writeln('³İÛ²±° Why????   : This program requires 512K of base RAM to run.');
 writeln('³İÛ²±° What to do: You have too many things using conventional RAM.');
 writeln('³İÛ²±°             Try checking your CONFIG.SYS and/or AUTOEXEC.BAT.');
 writeln;
 halt(255);
end;


{--------------------------------------
   Read graphic and get all images
--------------------------------------}
procedure kids_init;
begin
 mode($13);
 {pal_all(0,0,0);}
 i:=read_pcx(@kid,@pal);
 pal_set(@pal);

{ for y:=0 to 199 do
  for x:=0 to 319 do
   if point(x,y)=1 then pset(x,y,0); }

 i:=0;
 x:=2;
 repeat
  getmem(kids.image[i],800);
  if (kids.image[i]=nil) then no_ram;
  get(x,2,x+25,30,kids.image[i]);
  inc(x,29);
  inc(i);
 until x>318;

 x:=2;
 repeat
  if (x<50) then
  begin
   getmem(kids.image[i],800);
  if (kids.image[i]=nil) then no_ram;
   get(x,66,x+25,94,kids.image[i]);
   inc(i);
  end;
  inc(x,29);
 until x>318;

 x:=321-29;
 repeat
  getmem(kids.image[i],800);
  if (kids.image[i]=nil) then no_ram;
  get(x,34,x+25,62,kids.image[i]);
  inc(i);
  dec(x,29);
 until x<1;

 x:=321-29;
 repeat
  if (x>50) and (x<100) then
  begin
   getmem(kids.image[i],800);
   if (kids.image[i]=nil) then no_ram;
   get(x,66,x+25,94,kids.image[i]);
   inc(i);
  end;
  dec(x,29);
 until x<1;

 getmem(kids.image[27],800);
 if (kids.image[27]=nil) then no_ram;
 get(147,66,172,94,kids.image[27]);

 getmem(kids.image[28],800);
 if (kids.image[28]=nil) then no_ram;
 get(176,66,201,94,kids.image[28]);

 getmem(brick,70);
 if (brick=nil) then no_ram;
 get(123,134,133,139,brick);

 getmem(redbrick,104);
 if (redbrick=nil) then no_ram;
 get(222,164,231,173,redbrick);


 getmem(bluebrick,136);
 if (bluebrick=nil) then no_ram;
 get(229,140,239,151,bluebrick);


 getmem(cross,260);
 if (cross=nil) then no_ram;
 get(269,143,284,158,cross);

 getmem(floor,68);
 if (floor=nil) then no_ram;
 get(247,147,254,154,floor);

 cls(0);
 getmem(screen,65400);
 if (screen=nil) then no_ram;
 pal_set(@pal);

 pal_entry(0,0,0,0);		{-- Back }
 pal_entry(2,0,0,63);		{-- Shoes }
 pal_entry(6,45,0,0);		{-- Hair }
 pal_entry(15,60,45,35);	{-- Skin }

 pal_entry(4,0,0,32);		{-- blue border --}

 pal_entry(5,32,0,32);		{-- dark pink (shirt) ---}
 pal_entry(7,25,25,25);		{-- dark gray --}
 pal_entry(8,50,50,50);		{-- light gray ---}
 pal_entry(12,0,0,40);		{-- Blue eyes ---}
 pal_entry(13,63,0,63);		{-- Shirt --}
 pal_entry(1,25,0,0);


 vga_addr(screen);
 cls(0);

 getmem(backg,65400);
 if (backg=nil) then no_ram;
end;




{--------------------------------------------------------------------------
  x,y	: integer;	-- His coordinates
  frame : word;		-- Animation frame
  fcount: word;		-- Frame counter (time to remain in pose)
  facing: word;		-- Facing LEFT or RIGHT??
  what  : word;		-- What is he doing? (FALL/JUMP)
  lives : word;		-- Lives
  image : 0..32
 FALL=1; JUMP=2; DUCK=3; DEAD=4; TURN=5;	-- What you're doing?
 LEFT=95; RIGHT=96; MIDDLE=97;			-- Where is he facing
 x+14,x+11,y+28

 Kid falls in two step increments (if we fall 1 by 1, he seems to float)
 so be sure to use odd kids.y coordinates.
-------------------------------------------------------------------------}

begin
 kids_init;

 kids.x:=0;
 kids.y:=9;
 kids.frame:=0;
 kids.fcount:=0;
 kids.facing:=RIGHT;
 kids.what:=WALK;


 {--- Let's draw the background ---}
 vga_addr(backg);
 cls(0);
 for x:=0 to 32 do
 begin
  for y:=0 to 30 do
  begin
   cput(x*10,y*10,redbrick);
  end;
 end;

 for i:=0 to 5 do
 begin
  put(i shl 4,60,cross);
 end;

 for i:=6 to 9 do
 begin
  put(i shl 4,90,cross);
 end;


 for i:=8 to 11 do
 begin
  put(i shl 4,120,cross);
 end;


 for i:=2 to 7 do
 begin
  put(i shl 4,160,cross);
 end;


 for i:=14 to 19 do
 begin
  put(i shl 4,60,cross);
 end;


 for i:=9 to 14 do
 begin
  put(i shl 4,180,cross);
 end;

 vga_addr(screen);

 whoa:=0;
{========================= MAIN LOOP ==============================}

 skip:=0;

 repeat
  putscreen(backg);

  {-- moving floors --}
  inc(skip);
  cput(skip,60,cross);
  cput(320-skip,60,cross);
  cput(320-skip,120,cross);
  cput(skip,120,cross);

  cput(skip shl 1,180,cross);
  cput(320-(skip shl 1),180,cross);

  cput(skip shr 1+100,90,cross);
  cput(skip shr 1+116,90,cross);

  if (skip>330) then skip:=-20;


  {--- Fell at bottom?? ----}
  if (kids.y>198) then
  begin
   kids.y:=-1;
  end;


  {--- Check boundaries ----}
  if (kids.x<-8) then
  begin
   kids.x:=304;
   if (kids.what=WALK) then
   begin
    kids.frame:=0;
    kids.fcount:=0;
   end;
  end;

  if (kids.x>304) then kids.x:=-8;


  {--- Let's control frames if he's walking ---}
  if (kids.what=WALK) and ((readkey=_left) or (readkey=_right)) then
  begin
   inc(kids.fcount);
   if (kids.fcount>5) then		{--- Wait 5 frames of each pose }
   begin
    kids.fcount:=0;

    if (kids.frame=12) then		{--- If he is down, get up ---}
    begin
     kids.frame:=9;
     kids.fcount:=-6;
    end
    else
    begin
     inc(kids.frame);
     if (kids.frame>6) then
     begin
      kids.frame:=0;
     end;
    end;

   end;
  end

  else if (kids.what=WALK) then		{--- He is quiet ---}
  begin
   if (kids.frame<>0) then
   begin
    inc(kids.fcount);
    if (kids.fcount>10) then		{--- Let's wait him to rest ---}
    begin

     if (kids.frame=12) then		{--- He is in floor, stand up! ---}
     begin
      kids.frame:=9;
      kids.fcount:=0;
     end
     else
     begin
      kids.frame:=0;			{--- Stand still ---}
     end;

    end;
   end;
  end;


  {--- Let's know what's on his feet ---}
  pix1:=point(kids.x+14,kids.y+29);
  pix2:=point(kids.x+11,kids.y+29);


  {--- Is he beginning to fall like an idiot? ---}
  if (kids.what<>JUMP) and (kids.what<>FALL) and (pix1<>8) and (pix2<>8) then
  begin
   kids.what:=FALL;
   kids.frame:=8;
   kids.fcount:=0;
  end;


  {--- If he is falling, he fell onto the floor? ---}
  if (kids.what=FALL) and (pix1=8) and (pix2=8) then
  begin
   if (kids.fcount>40) then		{--- ouch!, he hit the foor hard!! }
   begin
    kids.what:=DUCK;
    kids.frame:=12;
    kids.fcount:=3;
   end

   else if (kids.fcount>20) then	{--- Minor injury... Hurts somewhat }
   begin
    kids.what:=DUCK;
    kids.frame:=9;
    kids.fcount:=0;
   end

   else					{--- okay... No broken bones }

   begin
    kids.what:=DUCK;
    kids.frame:=0;
    kids.fcount:=0;
   end;
  end;



  {--- If he falls, we update his coordinates and determine great fall ---}
  if (kids.what=FALL) then
  begin
   inc(kids.y,2);
   if (kids.y and 2)=2 then
   begin
    if (kids.facing=RIGHT) then inc(kids.x) else dec(kids.x);
   end;

   inc(kids.fcount);
   if (kids.fcount>40) then	{--- Falling from quite high! ---}
   begin
    kids.frame:=11;
   end
   else if (kids.fcount>20) then	{--- High fall, not so much ---}
   begin
    kids.frame:=10;
   end;

  end;



  {--- if you want to control him, he *must* be walking ---}
  if (kids.what<>FALL) and (kids.what<>JUMP) then
  begin
   if (readkey=_left) then
   begin
    kids.what:=WALK;
    dec(kids.x);
    if (kids.facing<>LEFT) then
    begin
     kids.facing:=LEFT;

     if (kids.frame=12) then		{--- If on floor, get up }
     begin
      kids.frame:=9;
      kids.fcount:=-6;
     end
     else
     begin
      kids.frame:=27-13;
      kids.fcount:=-4;
     end;

    end;
   end;

   if (readkey=_right) then
   begin
    kids.what:=WALK;
    inc(kids.x);
    if (kids.facing<>RIGHT) then
    begin
     kids.facing:=RIGHT;

     if (kids.frame=12) then		{--- If on floor, get up }
     begin
      kids.frame:=9;
      kids.fcount:=-6;
     end
     else
     begin
      kids.frame:=28;
      kids.fcount:=-4;
     end;


    end;
   end;
  end;

  cpaste(kids.x,kids.y,kids.image[kids.frame+kids.facing]);

  vga_synch(0);
  vgaputscreen(screen);
 until (readkey=_esc) or (readkey=_enter);


 mode($3);
 writeln('³İÛ²±° Kid áeta v1.00.05');
 writeln('³İÛ²±° Copyright (c) 1995 Marco A. Marrero');
 writeln('³İÛ²±°ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
 writeln('³İÛ²±°  What this does?');
 writeln('³İÛ²±°ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
 writeln('³İÛ²±° ş 32 Bit 100% assembler VGA routines, using standard Mode 13h');
 writeln('³İÛ²±° ş Custom timer and keyboard control in assembler too');
 writeln('³İÛ²±°');
 writeln('³İÛ²±° Preliminary results:');
 writeln('³İÛ²±°ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
 writeln('³İÛ²±° ş Mode13 is Slooooow! ModeX should help it a lot!');
 writeln('³İÛ²±° ş Keyboard feels very sluggish when turning! Why???????');
 writeln('³İÛ²±° ş Why I should enhance it? It will require a 486DX2/66!!!');
 writeln('³İÛ²±°');
 writeln('³İÛ²±° Missing things:');
 writeln('³İÛ²±°ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
 writeln('³İÛ²±° ş Better graphics, sound and joystick support');
 writeln('³İÛ²±° ş Jumping and ducking will be included in next beta');
 writeln('³İÛ²±° ş Maybe I should have nice scrolling, I must do a map editor');
 writeln('³İÛ²±° ş Framerate control synchronized with the PC timer');
 writeln;
 writeln;
end.

