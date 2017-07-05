{A+,X-,F+,B-,T-,V-,E-,I-,N-,O-,P-,G+}
{$R-,Q-,S-}
{$D-,L-,Y-}

unit maze;
interface
uses graphic;

type
 mazetype = array[0..639] of byte;
 buffer = array[0..64000] of byte;
 page = ^buffer;
 str60 = string[59];

 playerinfo = record
  who	: byte;		{-- player #		}
  what	: byte;		{-- 0=monster, 1=player }
  key	: byte;		{-- valid key		}
  frame	: byte;		{-- animation		}
  image	: byte;   	{-- image to plot	}
  map	: integer;   	{-- current map pos.    }
  omap	: integer;   	{-- old map position	}
  x,y	: integer;	{-- position		}
  ox,oy : integer;	{-- old x,y		}
  xd,yd	: integer;	{-- direction		}
  gx,gy : integer;	{-- real coordinates    }
  gox,goy : integer;	{-- old coordinates     }
  control : byte;	{-- control type }
  add	  : byte;	{-- color adder  }
 end;

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
{-- controller types }
 keyboard1	= 0;
 keyboard2	= 1;
 joystick1	= 2;
 joystick2	= 3;
 modem		= 4;
 ipx		= 5;

{----- play settings constants --- }
 jump= 2;	{-- pixels per move }
 oops= 3;	{-- collision/cornering }

 maxcpu : integer = 10;

{----- Key values }
 Space= 57;  Enter= 28;  Esc= 1;

 screen : word = $a000;
 color	: byte = 0;

{---- Ekey values }
 Ins=82;  Del=83; Home=71;  Ed=79; PgUp=73; ctrl_q=16; f10=68;
 Up =72;  Down=80; Left=75;  Right=77;  PgDn=81;


 maze1 : mazetype =
 ( 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
   1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,0,1,
   1,0,1,1,1,1,1,0,1,0,1,1,1,1,1,0,1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1,
   1,0,1,0,0,0,1,0,1,0,1,1,1,1,1,0,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0,1,
   1,0,1,0,1,0,1,0,1,0,0,0,0,0,1,0,1,0,1,1,0,1,0,1,1,1,0,1,0,1,0,1,
   1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1,
   1,0,0,0,1,0,0,0,0,0,1,0,1,0,1,0,1,0,1,1,1,1,0,1,0,1,1,1,0,1,0,1,
   1,1,1,1,1,0,1,1,0,1,1,0,1,0,1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,1,
   1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,1,1,1,1,0,1,1,1,1,1,0,1,0,1,
   1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,1,
   1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,0,1,1,1,0,1,0,1,
   1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
   1,0,1,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,0,0,1,
   1,0,1,0,1,0,1,0,1,0,0,1,0,1,0,0,1,0,1,1,0,0,0,1,1,0,1,1,0,0,0,1,
   1,0,1,0,1,0,1,0,1,1,1,1,0,1,1,1,1,0,1,0,0,0,0,1,0,0,0,1,0,0,0,1,
   1,0,1,0,1,0,1,0,1,0,0,1,0,1,0,1,0,0,1,0,0,0,0,1,0,0,0,1,0,0,0,1,
   1,0,1,0,0,0,1,0,1,0,0,1,0,1,0,1,0,0,1,1,0,0,0,1,1,0,1,1,0,0,0,1,
   1,0,1,0,0,0,1,0,1,0,0,1,0,1,0,1,1,0,0,1,1,1,0,0,1,1,1,0,0,0,0,1,
   1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);

var
 page_maze	: page;
 page_buf	: page;
 vgascreen	: pointer;
 key		: byte;
 ns		: string[8];
 xbs		: str60;

 {-- mouse stuff --}
 mx,my,mk,mouse : word;
 moved,clicked	: byte;

 {--- Sprites }
 pak  : array[0..3]  of sprite;
 bad  : array[0..3]  of sprite;
 wall : array[0..20] of sprite;
 font : array[0..65] of alpha;

 i	: integer;

 {--- Players }
 player   : playerinfo;
 player2  : playerinfo;

 computer : array[0..500] of playerinfo;

procedure quit;
function analog(b:byte) : word;
function control(var who:playerinfo) : byte;
procedure get_sprites;
procedure print(x,y:integer; bs:str60);
procedure printnum(x,y,n:integer);
procedure maze_conv(var maze:mazetype);
procedure maze_draw(var maze:mazetype);
procedure mode(num:integer);
procedure palette(color,red,green,blue:integer);
procedure vsynch;
procedure vwait;
procedure readmode(num:integer);
procedure writemode(num:integer);
procedure get10(x,y:word;image:pointer);
procedure put10(x,y:word; image:pointer);
procedure clear10(x,y:word);
procedure put10add(x,y:word; image:pointer; num:byte);
procedure get6(x,y:word;image:pointer);
procedure put6(x,y:word; image:pointer);
procedure pset(x,y,color:word);
procedure cls(color:integer);
procedure read_pcx(where:pointer);
procedure memcpy_vga(from,upto:pointer);
function point(x,y:word) : word;
procedure set_start_offset(x:word);
procedure pixel_pan(x:byte);
procedure pixel_pan_compatible;
procedure mouse_on;
procedure mousek;
procedure mouse_hide;
procedure mouse_show;
procedure mouse_wait;
procedure mouse_area(button,x,y,x1,y1:word);

implementation
var
 int9seg,int9ofs : word;

const
{-- joystick calibration --}
 jc1 : array[1..4] of word = (300,600,320,450);
 jc2 : array[1..4] of word = (300,600,320,450);

{-- keyboard handling }
 keys1 : array[1..4] of byte = (72,80,75,77);	{-- keyboard keys }
 keys2 : array[1..4] of byte = (17,45,30,32);

{-- vga adapter cards --}
 none=0; mda=1; cga=2; egamono=3; egacolor=4; vgamono=5; vgacolor=6;
 mcgamono=7; mcgacolor=8;
 PS2_CARDS : array[1..13] of byte = (0,1,2,2,4,3,2,5,6,2,8,7,8);


{---------------------------------
      Detect graphics card
----------------------------------}
function which_video : word; assembler;
asm
	mov  ax,1A00h	{ Try calling VGA Identity Adapter function }
	int  10h
	cmp  al,1Ah	{ Do we have PS/2 video bios ? }
	jne  @not_PS2	{ No! }

	cmp  bl,0Ch	{ bl > 0Ch => CGA hardware }
	jg   @is_CGA	{ Jump if we have CGA }
	xor  bh,bh
	add  bx,offset PS2_CARDS
	xor  ah,ah
	mov  al,[bx]	{ Load ax from PS/2 hardware table }
	jmp  @done	{ return ax }
@is_CGA:
	mov  ax,CGA	{ Have detected CGA, return id }
	jmp  @done
@not_PS2:		{ OK We don't have PS/2 Video bios }
	mov  ah,12h	{ Set alternate function service }
	mov  bx,10h	{ Set to return EGA information }
	int  10h	{ call video service }
	cmp  bx,10h	{ Is EGA there ? }
	je   @simple_adapter	{ Nope! }
	mov  ah,12h		{ Since we have EGA bios, get details }
	mov  bl,10h
	int  10h
	or   bh,bh		{ Do we have colour EGA ? }
	jz   @ega_color		{ Yes }
	mov  ax,EGAMono		{ Otherwise we have Mono EGA }
	jmp  @done
@ega_color:
	mov  ax,EGAColor	{ Have detected EGA Color, return id }
	jmp  @done
@simple_adapter:
	int  11h	{ Let's try equipment determination service }
	and  al,30h
	shr  al,4
	xor  ah,ah
	or   al,al	{ Do we have any graphics card at all ? }
	jz   @done	{ No?? This is a stupid machine! }
	cmp  al,3	{ Do We have a Mono adapter }
	jne  @is_CGA	{ No }
	mov  ax,MDA	{ Have detected MDA, return id }
@done:
end;

{-----------------------------------
  Sets the VGA start display offset
------------------------------------}
procedure set_start_offset(x:word); assembler;
asm
	mov	bx,x
	mov     dx,3d4h		{  CRTC_Index	}
	mov     al,0ch
	mov     ah,bh		{ write the HIGH byte }
	out     dx,ax
	inc     al
	mov     ah,bl		{ write the LOW byte  }
	out     dx,ax
end;

{--------------------------------------
      Sets the pixel pan value
--------------------------------------}
procedure pixel_pan(x:byte); assembler;
asm
	mov	ah,x
	mov     dx,3dah			{ InputStatus1 }
	in      al,dx			{ dummy input  }
	mov     dx,3c0h			{ Attr_Index }
	mov     al,33h
	out     dx,al
	mov     al,ah
	out     dx,al
end;

{--------------------------------------
    Sets pixel pan compatibility
--------------------------------------}
procedure pixel_pan_compatible; assembler;
asm
	mov     dx,3dah			{ InputStatus1 }
	in      al,dx           	{ dummy input  }
	mov     dx,3c0h			{ Attr_Index   }
	mov     al,30h
	out     dx,al
	inc     dx
	in      al,dx
	dec     dx
	or      al,00100000b
	out     dx,al
end;


{$L C:\DATA\PAS\VGA\VGA2.OBJ}
function analog(b:byte) : word; external;
procedure mode(num:integer); external;
procedure palette(color,red,green,blue:integer); external;
procedure vsynch; external;
procedure vwait; external;
procedure readmode(num:integer); external;
procedure writemode(num:integer); external;
procedure get10(x,y:word;image:pointer); external;
procedure put10(x,y:word; image:pointer); external;
procedure clear10(x,y:word); external;
procedure put10add(x,y:word; image:pointer; num:byte); external;
procedure get6(x,y:word;image:pointer); external;
procedure put6(x,y:word; image:pointer); external;
procedure pset(x,y,color:word); external;
procedure cls(color:integer); external;
procedure read_pcx(where:pointer); external;
procedure memcpy_vga(from,upto:pointer); external;
function point(x,y:word) : word; external;
procedure mouse_on; external;
procedure mousek; external;
procedure mouse_hide; external;
procedure mouse_show; external;
procedure mouse_wait; external;
procedure mouse_area(button,x,y,x1,y1:word); external;
procedure keyvec; external;

{---------------------------------
  Get the sprites from the PCX
  file and store them into arrays.
----------------------------------}
procedure get_sprites;
var i,m : integer;
begin
 for i:=0 to 255 do
 begin
  palette(i,0,0,0);
 end;
 get10(0,0,@wall[0]);
 get6(0,0,@font[0]);
 read_pcx(pic);
 for i:=1 to 19 do
   get10(i*11+1,1,@wall[i]);
 for i:=1 to 4 do
   get10(i*11+1,12,@pak[i-1]);
 for i:=1 to 4 do
   get10(i*11+1,23,@bad[i-1]);
 for i:=0 to 44 do		{ Font }
   get6(i*7+1,67,@font[i+1]);
 for i:=0 to 18 do
   get6(i*7+1,73,@font[46+i]);
end;


{--------------------------
	Print String
---------------------------}
procedure print(x,y:integer; bs:str60);
var n : integer;
    c : byte;
begin
 if length(bs)>0 then
 begin
  for n:=1 to length(bs) do
  begin
   c:=ord(bs[n]);
   put6(x,y,@font[ord(bs[n])-32]);
   inc(x,6);
  end;
 end;
end;

{---------------------------
	Print decimal
-----------------------------}
procedure printnum(x,y,n:integer);
begin
asm
	mov	 bx,offset ns
	mov byte ptr ds:[bx],5

	inc	bx
	mov	ax,2020h
	mov	ds:[bx],ax
	mov	ds:[bx+2],ax
	add	bx,4

	mov	ax,n
	mov	cx,10

@many:  xor	dx,dx
	div	cx
	add	dl,48
	mov	ds:[bx],dl
	dec	bx
	or	ax,ax
	jnz	@many
end;
 print(x,y,ns);
end;


{-----------------------------------
  converts ugly maze to pretty maze
------------------------------------}
procedure maze_conv(var maze:mazetype);
var x,y,z	: integer;
    u,d,l,r	: byte;
begin

 for y:=0 to 19 do
 begin
  for x:=0 to 31 do
  begin
   l:=0; r:=0; u:=0; d:=0;
   z:=x+(y shl 5);

   if maze[z]<>0 then
   begin
    if x>0  then l:=maze[z-1];
    if x<31 then r:=maze[z+1];
    if y>0  then u:=maze[z-32];
    if y<19 then d:=maze[z+32];

    if (u+d+l+r=0) then maze[z]:=16
    else if (u+d=0) and (l<>0) and (r<>0) then maze[z]:=1
    else if (u<>0) and (d<>0) and (l+r=0)  then maze[z]:=2

    else if (u<>0) and (r<>0) and (l+d=0)  then maze[z]:=3
    else if (l<>0) and (u<>0) and (r+d=0)  then maze[z]:=4
    else if (l<>0) and (d<>0) and (u+r=0)  then maze[z]:=5
    else if (d<>0) and (r<>0) and (l+u=0)  then maze[z]:=6

    else if (r+l+u=0) and (d<>0) then maze[z]:=7
    else if (r+l+d=0) and (u<>0) then maze[z]:=8
    else if (u+d+r=0) and (l<>0) then maze[z]:=9
    else if (u+d+l=0) and (r<>0) then maze[z]:=10

    else if (d=0) then maze[z]:=12
    else if (u=0) then maze[z]:=13
    else if (l=0) then maze[z]:=14
    else if (r=0) then maze[z]:=15
    else maze[z]:=11;

   end; {if}
  end; {x}
 end; {y}
end;


{-------------------------------
	 Draws the maze
-------------------------------}
procedure maze_draw(var maze:mazetype);
var x,y,m : word;
begin
 x:=0;
 y:=0;
 for m:=0 to 639 do
 begin
  put10(x,y,@wall[maze[m]]);
  inc(x,10);
  if x>319 then
  begin
   x:=0;
   inc(y,10);
  end;
 end;
end;


{---------------------------
	Disable interrputs
---------------------------}
procedure keyboard_int_setup; assembler;
asm
	cli
	push	ds

	mov	al,9		{-- key keyboard int vector }
	mov	ah,35h
	int	21h
	mov	int9ofs,bx	{-- old vectors.. }
	mov	int9seg,es

	mov	dx,offset keyvec	{-- ds:dx = new int }
	mov	ax,seg keyvec
	mov	ds,ax
	mov	ah,25h
	mov	al,9
	int	21h

	pop	ds
	sti
end;

{-----------------------------
  Date of pak-tag release
-----------------------------}
procedure release_date;
begin
 writeln('³ÝÛ²±° Pak-Tag v0.4 * àlpha pre-relase * Programmed by Marco A. Marrero');
 writeln('³ÝÛ²±°'#9'Morse #49, Box 453,  Arroyo, PR 00714 -- Phone: (809) 839-8198');
 writeln('³ÝÛ²±°'#9'Created at 10/28/1994.'#9'Alpha testing release 11/20/1994');
 writeln('³ÝÛ²±° *** NOT FINISHED!! ***');
 writeln;
end;


{---------------------
	Quit..
--------------------}
procedure quit;
begin
 if page_buf<>nil then dispose(page_buf);
asm

	xor	ax,ax
	mov	es,ax
	mov	es:[$471],ah

	cli
	push	ds

	mov	ax,int9seg
	mov	dx,int9ofs
	mov	ds,ax

	mov	ah,25h
	mov	al,9
	int	21h

	pop	ds
	sti

	mov	ax,3h
	int	10h
end;
	release_date;
	writeln;
	halt;
end;


{-------------------------- CONTROL ----------------------------------}
function control(var who:playerinfo) : byte;
var return	: byte;
    x		: word;
begin
 return:=0;

 if who.control=keyboard1 then
 begin
  if key=keys1[1] then return:=up
  else if key=keys1[2] then return:=down
  else if key=keys1[3] then return:=left
  else if key=keys1[4] then return:=right;
 end
 else if who.control=keyboard2 then
 begin
  if key=keys2[1] then return:=up
  else if key=keys2[2] then return:=down
  else if key=keys2[3] then return:=left
  else if key=keys2[4] then return:=right;
 end
 else if who.control=joystick1 then
 begin
  x:=analog(1);
  if x<jc1[1] then return:=left
  else if x>jc1[2] then return:=right;
  x:=analog(2);
  if x<jc1[3] then return:=up
  else if x>jc1[4] then return:=down;
 end
 else if who.control=joystick2 then
 begin
  x:=analog(3);
  if x<jc2[1] then return:=left
  else if x>jc2[2] then return:=right;
  x:=analog(4);
  if x<jc2[3] then return:=up
  else if x>jc2[4] then return:=down;
 end;

 control:=return;
end;



{****************** MAIN *******************}
begin
 page_buf:=nil;
 keyboard_int_setup;

 i:=which_video;
 if (i<5) then
 begin
  writeln('³ÝÛ²±° >>> Fatal Error: VGA/MCGA not detected.');
  writeln('³ÝÛ²±°'#9#9'You need a VGA/MCGA or compatible graphics adapter.');
  writeln;
  quit;
 end;

 vgascreen:=ptr($a000,0);
 new(page_buf);
 if (page_buf=nil) then
 begin
  writeln('³ÝÛ²±° >>> Fatal Error: No enough conventional memory!');
  writeln('³ÝÛ²±°'#9#9'Pak-tag requires 512K free.');
  writeln;
  quit;
 end;

 mode($13);
 get_sprites;
end.