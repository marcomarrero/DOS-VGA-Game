{ .--------------------------------------.
  | 	   -=- P A K   T A G  -=-	 |
  |--------------------------------------|
  | 	 Version 0.40	-- 10/28/1994 	 |
  |                        11/06/1994    |
  |--------------------------------------|
  | Copyright (c) 1994 Marco A. Marrero  |
  `--------------------------------------- }

{$M 4096,262144,524288}
{A+,X-,F-,B-,T-,V-,G+,E-,I-,N-,O-,P-}
{$R-,Q-,S-}
{$D-,L-,Y-}

program pak_tag;
uses maze;
const
 _pak = 1;
 _bad = 0;

var
 camera : word;

{$L c:\game\obj\modex.obj}
function modex_set(mode,width:word): word; near; external;
procedure modex_to_13; near; external;

{$L c:\game\obj\vga_hard.obj}
procedure vga_split(scanlin:word); near; external;


{--------------------------- PROCS -----------------------------------------}

{------------------------------
	Communication error
-------------------------------}
procedure comm_error;
begin
end;

{------------------------------
	Communication quit
-------------------------------}
procedure comm_quit;
begin
end;


{------------------------------
	Fatal error handler
-------------------------------}
procedure fatal_error(err:string);
begin
 mode(3);
 writeln('³ÝÛ²±° >>> Fatal Error: ',err);
 writeln;
 comm_error;
 quit;
end;


{---------------------------- BADS ---------------------------------}

{---------------------------
 Init Computer Bads
----------------------------}
procedure cpu_init(var cpu:playerinfo; var maze:mazetype);
var i,z : integer;
begin
 cpu.key:=0;					{-- no key pressed }
 cpu.yd:=0; 					{-- player is still }
 cpu.xd:=0;

 z:=0;
 for i:=638 downto 32 do		{-- search for hole in maze }
 begin
  if (maze[i]=0) then
  begin
   z:=i;
   i:=32;
  end;
 end;

 if (z=0) then fatal_error('Monster can''t find empty spot in maze');

 cpu.x:=0;
 cpu.y:=0;
 maze[z]:=253;		{baddie}
 cpu.map:=z;
 cpu.gx:=(cpu.map and 31)*10;
 cpu.gy:=(cpu.map shr 5)*10;
end;

{-----------------------
	 Move baddies
------------------------}
procedure cpu_move(var cpu:playerinfo; var map:mazetype);
var
 u,d,l,r : byte;
begin

 {-- random movement --}
 if (random(20)=10) then
 begin
  u:=random(4);
  if (u=0) and (cpu.xd=0) then cpu.key:=left;
  if (u=1) and (cpu.xd=0) then cpu.key:=right;
  if (u=2) and (cpu.yd=0) then cpu.key:=up;
  if (u=3) and (cpu.yd=0) then cpu.key:=down;
 end;

 {-- bump values }
 l:=map[cpu.map-1];  r:=map[cpu.map+1];
 u:=map[cpu.map-32]; d:=map[cpu.map+32];

 cpu.ox:=cpu.x;			{-- old position }
 cpu.oy:=cpu.y;
 cpu.omap:=cpu.map;

 cpu.x:=cpu.x+cpu.xd;		{-- new position }
 cpu.y:=cpu.y+cpu.yd;

 {-- Bumped into a wall? }
 if (cpu.xd=jump) and ((r>0) and (r<>254)) then
 begin
  cpu.xd:=0; cpu.x:=0;
  if (u=0) then cpu.key:=up
    else if (d=0) then cpu.key:=down;
 end
 else if (cpu.xd=-jump) and ((l>0) and (l<>254)) then
 begin
  cpu.xd:=0; cpu.x:=0;
  if (d=0) then cpu.key:=down
   else if (u=0) then cpu.key:=up;
 end
 else if (cpu.yd=jump)  and ((d>0) and (d<>254)) then
 begin
  cpu.yd:=0; cpu.y:=0;
  if (r=0) then cpu.key:=right
  else if (l=0) then cpu.key:=left;
 end
 else if (cpu.yd=-jump) and ((u<>0) and (u<>254)) then
 begin
  cpu.yd:=0; cpu.y:=0;
  if (l=0) then cpu.key:=left
   else if (r=0) then cpu.key:=right;
 end;


 if (cpu.xd+cpu.yd=0) then
 begin
  if (cpu.key=left) then cpu.frame:=1
  else if (cpu.key=right) then cpu.frame:=0
  else if (cpu.key=up) then cpu.frame:=2
  else cpu.frame:=3;
 end;
 {-- cpu changed direction }
 if (cpu.key=up) and (u=0) and (cpu.x<=oops) and (cpu.x>=-oops) then
 begin
  cpu.yd:=-jump;
  cpu.frame:=2;
  cpu.x:=0;
  cpu.xd:=0;
 end
 else if (cpu.key=down) and (d=0) and (cpu.x<=oops) and (cpu.x>=-oops) then
 begin
  cpu.xd:=0;
  cpu.x:=0;
  cpu.yd:=jump;
  cpu.frame:=3;
 end
 else if (cpu.key=right) and (r=0) and (cpu.y<=oops) and (cpu.y>=-oops) then
 begin
  cpu.xd:=jump;
  cpu.yd:=0;
  cpu.y:=0;
  cpu.frame:=0;
 end
 else if (cpu.key=left) and (l=0) and (cpu.y<=oops) and (cpu.y>=-oops) then
 begin
  cpu.xd:=-jump;
  cpu.yd:=0;
  cpu.y:=0;
  cpu.frame:=1;
 end;

 if (cpu.x>=10) then		{-- cpu changed map position... }
 begin
  map[cpu.map]:=0; inc(cpu.map,1); map[cpu.map]:=253; cpu.x:=0;
 end
 else if (cpu.x<=-10) then
 begin
  map[cpu.map]:=0; dec(cpu.map,1); map[cpu.map]:=253; cpu.x:=0;
 end
 else if (cpu.y>=10) then
 begin
  map[cpu.map]:=0; inc(cpu.map,32); map[cpu.map]:=253; cpu.y:=0;
 end
 else if (cpu.y<=-10) then
 begin
  map[cpu.map]:=0; dec(cpu.map,32); map[cpu.map]:=253; cpu.y:=0;
 end;

 cpu.gox:=cpu.gx;
 cpu.goy:=cpu.gy;
 cpu.gx:=(cpu.map and 31)*10+cpu.x;
 cpu.gy:=(cpu.map shr 5)*10+cpu.y;
end;

{------------------------------ PAKS ------------------------------------}

{---------------------------
	 Initializes pak
---------------------------}
procedure pak_init(var pak:playerinfo; var maze:mazetype);
var i,z : integer;
begin
 pak.key:=0;					{-- no key pressed }
 pak.yd:=0; 					{-- player is still }
 pak.xd:=jump;


 z:=0;
 for i:=32 to 600 do			{-- search for hole in maze }
 begin
  if (maze[i]=0) then
  begin
   z:=i;
   i:=600;
  end;
 end;

 if (z=0) then fatal_error('Player can''t find empty spot in maze');

 pak.x:=0;
 pak.y:=0;
 pak.map:=z;
 maze[z]:=254; {pak}
 pak.gx:=(pak.map and 31)*10;
 pak.gy:=(pak.map shr 5)*10;
end;


{----------------------------------
	Move the happy paks around
-----------------------------------}
procedure pak_move(var pak:playerinfo; var map:mazetype);
var
 u,d,l,r : byte;
 dir  	 : byte;
begin
 dir:=control(pak);
 if (dir<>0) then pak.key:=dir;

 l:=map[pak.map-1];  r:=map[pak.map+1];
 u:=map[pak.map-32]; d:=map[pak.map+32];

 pak.ox:=pak.x;			{-- old position }
 pak.oy:=pak.y;
 pak.omap:=pak.map;

 pak.x:=pak.x+pak.xd;		{-- new position }
 pak.y:=pak.y+pak.yd;

 {-- Bumped into a wall? }
 if (pak.xd=jump) and (r<>0) then
 begin
  pak.xd:=0; pak.x:=0;
  if pak.key=right then pak.key:=0;
 end
 else if (pak.xd=-jump) and (l<>0) then
 begin
  pak.xd:=0; pak.x:=0;
  if pak.key=left then pak.key:=0;
 end
 else if (pak.yd=jump)  and (d<>0) then
 begin
  pak.yd:=0; pak.y:=0;
  if pak.key=down then pak.key:=0;
 end
 else if (pak.yd=-jump) and (u<>0) then
 begin
  pak.yd:=0; pak.y:=0;
  if pak.key=up then pak.key:=0;
 end;

 {-- pak changed direction }
 if (pak.key=up) and (u=0) and (pak.x<=oops) and (pak.x>=-oops) then
 begin
  pak.xd:=0; pak.yd:=-jump; pak.x:=0; pak.frame:=2;
 end
 else if (pak.key=down) and (d=0) and (pak.x<=oops) and (pak.x>=-oops) then
 begin
  pak.xd:=0; pak.yd:=jump; pak.frame:=3; pak.x:=0; pak.frame:=3;
 end
 else if (pak.key=right) and (r=0) and (pak.y<=oops) and (pak.y>=-oops) then
 begin
  pak.xd:=jump; pak.yd:=0; pak.frame:=0; pak.y:=0; pak.frame:=0;
 end
 else if (pak.key=left) and (l=0) and (pak.y<=oops) and (pak.y>=-oops) then
 begin
  pak.xd:=-jump; pak.yd:=0; pak.frame:=1; pak.y:=0; pak.frame:=1;
 end;

 if (pak.x>=10) then		{-- Pak changed map position... }
 begin
  map[pak.map]:=0; inc(pak.map,1); map[pak.map]:=254; pak.x:=0;
 end
 else if (pak.x<=-10) then
 begin
  map[pak.map]:=0; dec(pak.map,1); map[pak.map]:=254; pak.x:=0;
 end
 else if (pak.y>=10) then
 begin
  map[pak.map]:=0; inc(pak.map,32); map[pak.map]:=254; pak.y:=0;
 end
 else if (pak.y<=-10) then
 begin
  map[pak.map]:=0; dec(pak.map,32); map[pak.map]:=254; pak.y:=0;
 end;

 pak.gox:=pak.gx;
 pak.goy:=pak.gy;
 pak.gx:=(pak.map and 31)*10+pak.x;
 pak.gy:=(pak.map shr 5)*10+pak.y;
end;


{---------------------------
	Display the pak
----------------------------}
procedure display(var it:playerinfo; var map:mazetype);
begin
 clear10(it.gox,it.goy);
 if it.who=_bad then
   put10add(it.gx,it.gy,@bad[it.frame],it.add)
 else
   put10add(it.gx,it.gy,@pak[it.frame],it.add);
end;


{--------------------------- MAIN ----------------------------------------}
begin
 i:=modex_set(5,320);
 vga_split(200);
 modex_to_13;
 pixel_pan_compatible;

 if paramcount>0 then
  val(paramstr(1),maxcpu,i);

 if (maxcpu>334) then maxcpu:=334;
 if (maxcpu<1) then maxcpu:=1;

 cls(0);
 mouse_on;
 mouse_hide;

 palette(12,23,23,23);
 palette(13,33,33,33);
 palette(14,43,43,43);
 palette(15,53,53,53);
 palette(16,63,63,63);

 player.control	:=keyboard1;
 player.add	:=22;
 player.who	:=_bad;

 player2.control:=keyboard2;
 player2.add	:=16;
 player2.who	:=_bad;

 palette(0,0,0,0);

 palette(1,40,0,0);  {-- pak/monst }
 palette(5,53,0,0);
 palette(2,63,0,0);

 palette(3,63,63,63);
 palette(4,40,40,40);
 palette(6,0,0,0);

 palette(7,0,20,15); {-- maze }
 palette(8,0,30,25);
 palette(9,0,40,35);
 palette(10,0,53,45);
 palette(11,63,63,63);

 palette(12,60,50,40);
 palette(13,55,45,35);
 palette(14,52,42,32);
 palette(15,45,35,25);
 palette(16,40,30,20);


 palette(17,30,30,0);  {-- pak/monst }
 palette(21,44,44,0);
 palette(18,55,55,0);
 palette(19,63,63,63);
 palette(20,40,40,40);
 palette(22,0,0,0);

 palette(23,40,0,40);  {-- pak/monst }
 palette(24,63,00,63);
 palette(25,63,63,63);
 palette(26,40,40,40);
 palette(27,50,0,50);
 palette(28,0,0,0);

 maze_conv(maze1);
 maze_draw(maze1);

 print(4,2,' PAK-TAG V0.5(386) - PROGRAMMED BY MARCO A. MARRERO ');

 pak_init(player,maze1);
 pak_init(player2,maze1);

 camera:=0;

 for i:=0 to maxcpu do
 begin
  computer[i].add:=0;
  computer[i].who:=_pak;
  cpu_init(computer[i],maze1);
 end;

 key:=5;
 repeat
  pak_move(player,maze1);
  pak_move(player2,maze1);

  for i:=0 to maxcpu do
    cpu_move(computer[i],maze1);

  if key=59 then camera:=0;
  if key=60 then camera:=1;

  case camera of
   0: begin
      set_start_offset((computer[1].gx div 8)+(computer[1].gy*(320 div 8)));
      pixel_pan(computer[1].gx mod 8);
     end;
   1: begin
       set_start_offset((player.gx div 8)+(player.gy*(320 div 8)));
       pixel_pan(player.gx mod 8);
      end;
  end;

  vsynch;

  display(player,maze1);
  display(player2,maze1);
  for i:=0 to maxcpu do
   display(computer[i],maze1);

 until (key=esc) or (key=enter);

 quit;
end.