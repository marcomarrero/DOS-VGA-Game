{-----------------------------
      MegaCRT v2.10 ·eta
 =============================
    Version 1 : 06/18/1992
    Version 2 : 01/15/1994
    Revision  : 05/06/1995
 -=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 (c) 1992,95 Marco A. Marrero
------------------------------}
{A+,X+,F+,R-,B-,T-,V-,G+,Y-,E-,I-,N-,O-,P-,Q-,S-}
{$D-,L-}

unit megacrt;

interface

type
 page = array[0..8191] of byte;               	{-- 8K supports up to 80x50 }

 str80  = string[80];                           {-- common string types }
 str12  = string[12];
 str128 = string[128];

const
 black  = 0;    dkgray  = 8;    {-- color constants }
 blue   = 1;    ltblue  = 9;
 green  = 2;    ltgreen = 10;
 cyan   = 3;    ltcyan  = 11;
 red    = 4;    ltred   = 12;
 pink   = 5;    ltpink  = 13;
 brown  = 6;    yellow  = 14;
 ltgray = 7;    white   = 15;
 hilite = 128;

 co40 = 1;  co80 = 3;           {-- screen mode constants }
 bw80 = 7;

 sysshadow : byte = $08;        {-- shadow constants }

 mk_left  = 1;
 mk_right = 2;
 mk_both  = 3;
 null     = 0;

{----- Keyboard flags --}
 RShift=  1;  LShift=   2; Ctrl    =  4;  Alt    =   8;
 Scroll= 16;  NumLock= 32; CapsLock= 64;  Insert = 128;

{----- Key values }
 Space=  #32;  Enter= #13;  Esc= #27;  Tab= #9;  Backspace= #8;

{---- Ekey values }
 Ins=#82;  Del=#83;   Home=#71;  Ed=#79;     PgUp=#73;
 Up =#72;  Down=#80;  Left=#75;  Right=#77;  PgDn=#81;

{---- Box drawing variables }
  thinbox  : str12 = '⁄ƒø¿ƒŸ≥≥≥≥≥≥';
  thickbox : str12 = '…Õª»Õº∫∫∫∫∫∫';
  flatbox  : str12 = '’Õ∏‘Õæ≥≥≥≥≥≥';
  fillbox  : str12 = '‹‹‹ﬂﬂﬂ›››ﬁﬁﬁ';

{----- Screens ------------}

var                                {---------- 80x25 ------------ }
 whole_screen    : word;           {-- Screen size  = 80x25 = 2000   }
 down_lin        : word;           {-- Bytes x line = 80x2  = 160    }
 screen_addr     : word;           {-- Screen seg   = $b800 if color }
 cols,rows       : word;           {-- Columns      = 80 - 1 = 79    }
 maxcols,maxrows : word;           {-- Rows         = 25 - 1 = 24    }

 xadd         : word;              {-- Window x upper area }
 yadd         : word;              {-- Window y upper area }

 display      : byte;              {-- Current display mode in use }
 display_page : byte;              {-- Current display page }
 screen_mode  : byte;              {-- Current video mode }
 crtc         : word;              {-- CRTC address register / $3d4 color }

 syscolor       : byte;            {-- Current Color }
 output         : word;

 screen1,screen2,screen3,screen4: pointer;	{-- screens }

 key,ekey               : char;    {-- Key code / extended key code }
 alternate,control      : char;    {-- Alt/Ctrl+letter combination }
 fkey,afkey,cfkey,sfkey : byte;    {-- Alt/Crtl/Shift/None + Function key }

 mx,my,mk,mouse : integer;         {-- Mouse variables }
 moved,clicked  : byte;

procedure vsynch;
procedure delay(time:word);
procedure color(atxt,abkg : byte);
procedure tcolor(atxt : byte);
procedure bcolor(abkg : byte);
procedure cls(chr:char);
procedure out_char(x,y:integer ; cha:char);
procedure mouse_on;
procedure mouse_show;
procedure mouse_hide;
procedure mousek;
procedure mouse_set(x,y:integer);
procedure mouse_wait;
function mouse_area(button,x,y,x1,y1:integer) : integer;
procedure readkey;
procedure clear_buffer;
procedure gotoxy(col,row:integer);
function keyboard_flags : word;
procedure Wait_Event;
procedure init_video;
procedure mode(mode:word);
procedure cursor_off;
procedure cursor_small;
procedure cursor_big;
procedure cursor_half;
procedure clear_line;
procedure hline(x,y,x1:integer ; first,mid,last:char);
procedure vline(x,y,y1:integer ; first,mid,last:char);
procedure print(x,y:integer; var txt:string);
procedure Fill(x,y,x1,y1:integer ; paint:char);
procedure get_screen(page:pointer);
procedure put_screen(page:pointer);
procedure scroll_l(x,y,x1,y1:integer);
procedure scroll_u(x,y,x1,y1:integer);
procedure scroll_r(x,y,x1,y1:integer);
procedure scroll_d(x,y,x1,y1:integer);
procedure tbox(x,y,x1,y1:integer ; var bar:str12);
procedure tboxfill(x,y,x1,y1:integer ; var bar:str12);
procedure reset_window;
procedure window(x,y,x1,y1:integer);
procedure shadowbox(x,y,x1,y1:integer);
procedure shadow_x(x,y,x1 : integer);
procedure shadow_y(x,y,y1 : integer);
procedure help(bs:string);
procedure nosound;
procedure sound(Hz:word);
procedure lowcase(var bs:string);
procedure upcase(var bs:string);
procedure vgapalette(color,red,green,blue:integer);
procedure reset_screen;

implementation
{************************************** PROCEDURES ********************* }

const
{---- Alt keyboard layout }
  Keylayout : string[36] = 'QWERTYUIOP****ASDFGHJKL*****ZXCVBNM';

{$L crtlogo1.obj}
{$L crtlogo2.obj}
{$L crtlogo3.obj}
{$L crtlogo4.obj}
procedure crtlogo1; external;
procedure crtlogo2; external;
procedure crtlogo3; external;
procedure crtlogo4; external;

{--------------------------------
     wait vertical synch
--------------------------------}
procedure vwait; assembler;
asm
	mov     dx,crtc         {-- get crt register }
	add     dl,6
	mov     ah,8

@wait:  in      al,dx           {-- wait vertical retrace }
	test    al,ah
	jz      @wait
end;

{-------------------------------------
  Synchronize to the Vertical retrace
--------------------------------------}
procedure vsynch; assembler;
asm
		mov	dx,crtc 		{-- Status register }
		add	dl,6
		mov	ah,8

@v_still:	in	al,dx
		test	al,ah
		jnz	@v_still

@v_wait:	in	al,dx
		test	al,ah
		jz	@v_wait
end;

{-----------------------------
       Waits some time
-----------------------------}
procedure delay(time:word); assembler;
asm
	mov	ah,2ch		{-- get time }
	int	21h
	mov	di,time
	or	di,di
	je	@bye


@sleep:	mov	al,dl		{-- 1/100ths }
@delay:	int	21h
	cmp	al,dl
	je	@delay
	dec	di
	jnz	@sleep
@bye:
end;


{-----------------------
  Select color to use
-----------------------}
procedure color(atxt,abkg : byte); assembler;
asm
	mov     ah,abkg         {-- Last 4 bits indicate background }
	mov	cl,4
	shl	ah,cl

	or	ah,atxt         {-- Fist 4 bits indicate text color }
	mov     syscolor,ah
end;


{------------------------
  Just change text color
-------------------------}
procedure tcolor(atxt : byte); assembler;
asm
	mov     ah,syscolor
	and     ah,11110000b    {-- clear color }
	or      ah,atxt         {-- Set new color }
	mov     syscolor,ah
end;


{-------------------------------
  Just change background color
--------------------------------}
procedure bcolor(abkg : byte); assembler;
asm
	mov     ah,syscolor
	and     ah,00001111b    {-- Mask color }

	mov     al,abkg         {-- get bakground color value... }
	mov     cl,4            {-- ...and shift bits into position }
	shl     al,cl

	or      ah,al           {-- Set bits   }
	mov     syscolor,ah
end;



{---------------------------
   Clears the whole screen.
-----------------------------}
PROCEDURE cls(chr:char); assembler;
asm
	mov	es,screen_addr  {-- Get screen segment }

	mov	al,chr          {-- Get color & attribute }
	mov	ah,syscolor

	mov	cx,whole_screen {-- Screen size }

	xor     di,di

	cli
	rep     stosw
	sti
end;


{-------------------------
  Prints a character
-------------------------- }
procedure out_char(x,y:integer ; cha:char) ; assembler;
asm
	mov  es,screen_addr

	mov  ax,xadd            {-- ax = xadd }

	mov  bx,x               {-- bx = x + xadd}
	add  bx,ax
	cmp  bx,cols
	jg   @bye               {-- x must be inside screen }

	cmp  bx,ax
	jl   @bye

	shl  bx,1               {-- convert x to screen coords }

	mov  ax,y
	add  ax,yadd            {-- ax = y }
	cmp  ax,rows
	jg   @bye
	cmp  ax,yadd
	jl   @bye

	mul  down_lin
	add  bx,ax

	mov  ah,syscolor
	mov  al,cha
	mov  es:[bx],ax
@bye:
end;

{--------------------------
   Enable Mouse Driver
---------------------------}
procedure mouse_on; assembler;
asm
	xor     bx,bx
	mov     es,bx
	add     bx,0cch
	mov     ax,es:[bx]      {-- Get mouse interrupt vector }
	add     ax,es:[bx+2]
	or      ax,ax
	jz      @bye

	mov     ax,21h
	int     33h             {-- Software reset        }
	cmp     ax,-1           {-- If -1 mouse installed }
	je      @cont

	xor     ax,ax
	jz      @bye            {-- Jmp... }

@cont:  mov     ax,1
	int     33h             {-- Unhide mouse }

@bye:   mov     mouse,ax        {-- Will be zero if no mouse }
	xor     ax,ax
	mov     mk,ax
	mov     mx,ax
	mov     my,ax
end;


{-------------------------------
  Confines mouse in a window
-------------------------------}
procedure mouse_window(x,y,x1,y1:word); assembler;
asm
	test    mouse,1
	jz      @bye

	mov     ax,7
	mov     cx,x
	mov     dx,x1
	int     33h

	inc     ax
	mov     cx,y
	mov     dx,y1
	int     33h
@bye:
end;

{---------------------------------
  Shows a previously hidden mouse
----------------------------------}
procedure mouse_show; assembler;
asm
	test    mouse,1         {-- Mouse is working? }
	jz      @bye

	xor     ax,ax
	inc     ax
	int     33h
@bye:
end;

{------------------------------------------------
  Hides mouse. To see it again you must
  Unhide it. IF YOU HIDE IT TWICE YOU MUST
  UNHIDE IT TWICE, OR NO MOUSE WILL BE SHOWN!
------------------------------------------------}
procedure mouse_hide; assembler;
asm
	test    mouse,1         {-- Mouse is working? }
	jz      @bye

	mov     ax,2
	int     33h
@bye:
end;

{---------------------------------------
  Get mouse values inside a window
 ----------------------------------
   Mx = x coordinate (window)
   My = y coordinate (window)
   Mk = Button (1=L,2=R or 3=LR)
   Moved   = zero if no movement
   Clicked = zero if changes
----------------------------------------}
procedure mousek; assembler;
asm
	test    mouse,1         {-- Mouse is working? }
	jz      @bye

	xor     ax,ax           {-- Clear flags }
	mov     moved,al
	mov     clicked,ah

	mov     al,3
	int     33h
	mov     ax,cx
	mov     ch,3

	mov     cl,ch           {-- Convert x coordinate to text }
	shr     ax,cl
	sub     ax,xadd
	cmp     ax,mx           {-- moved the mouse? }
	je      @still

	inc     moved
	mov     mx,ax

@still: mov     cl,ch           {-- Convert y coordinate to text }
	shr     dx,cl
	sub     dx,yadd
	cmp     dx,my           {-- moved the mouse? }
	je      @stil2

	inc     moved
	mov     my,dx

@stil2: cmp    bx,mk
	je     @bye

	mov    mk,bx            {-- Button: 1=left,2=right,3=both   }
	inc    clicked          {-- button was pressed or depressed }
@bye:
end;


{---------------------------------
  Puts mouse in this coordinate
     It is window relative!
-----------------------------------}
procedure mouse_set(x,y:integer); assembler;
asm
	test    mouse,1         {-- Mouse is working? }
	jz      @bye

	mov     cx,x
	add     cx,xadd

	mov     dx,y
	add     dx,yadd

	mov     ax,4
	int     33h
@bye:
end;


{--------------------------------
   Waits user to depress button
---------------------------------}
PROCEDURE mouse_wait; Assembler;
ASM
	test    mouse,1         {-- Mouse is working? }
	jz      @bye

@wait:  mov     ax,3
	int     33h
	or      bx,bx
	jnz     @wait
@bye:
END;


{---------------------------------------------
 Tells user if pressed/not pressed mouse
 button at specified coordinates.
    Button: 0=None,1=L,2=R,3=LR

 Will return button +1 Window dependent!
---------------------------------------------}
function mouse_area(button,x,y,x1,y1:integer) : integer; assembler;
asm
	call	mousek

	test    mouse,1         {-- Mouse is working? }
	jz      @bye

	mov     output,0        {-- Preliminary is zero -- }

	mov     ax,button
	cmp     ax,mk           {-- It is correct button? --}
	jne     @bye

	mov     si,xadd
	mov     di,yadd

@check: mov     ax,mx           {-- Check x pos. --}
	mov     bx,x
	add     bx,si
	cmp     ax,bx
	jl      @bye

	mov     bx,x1
	add     bx,si
	cmp     ax,bx           {-- Check x1 pos. --}
	jg      @bye

	mov     ax,my           {-- Check y pos. --}
	mov     bx,y
	add     bx,di
	cmp     ax,bx
	jl      @bye

	mov     bx,y1
	add     bx,di
	cmp     ax,bx
	jg      @bye

	inc     dx
	mov     ax,dx       	{-- Survived! return button value +1 }
	jmp	@bye2
@bye:	xor	ax,ax
@bye2:
END;

{------------------------------------------
 Read Scan & Keycode stored on Key/Ekey

 Will check several alt/shift combinations:
  Control   = 'A'-'Z' = (Ctrl+A,Ctrl+B...)
  Alternate = 'A'-'Z' = (Alt +A,Alt+B...)
  Fkey      = 0..12   = (F1,F2,F3...)
  Sfkey     = 0..12   = (Shift+F1...)
  Cfkey     = 0..12   = (Ctrl+F1...)
  Afkey     = 0..12   = (Alt+F1...)
-------------------------------------------}
procedure readkey; assembler;
asm
	xor     ax,ax
	mov     fkey,al         {-- Clear some values }
	mov     sfkey,ah
	mov     afkey,al
	mov     cfkey,ah
	mov     control,al
	mov     alternate,ah

	mov     dl,0ffh
	mov     ah,06
	int     21h
	jnz     @ok             {-- key was pressed }

	xor     bx,bx
	jmp     @bye            {-- no key... }

@ok:    or      al,al           {-- special key? }
	jz      @again
	xor     ah,ah
	jmp     @got

@again: mov     dl,0ffh         {-- re-read keyboard }
	mov     ah,06
	int     21h
	mov     ah,al
	xor     al,al           {-- al=key / ah=ekey }

@got:   mov     bx,ax           {-- bx will store values }

	or      al,al           {------- Test Crtl values }
	jz      @t2             {-- If not Ctrl skip... }

	cmp     al,26
	ja      @t2             {-- Above Ctrl+Z?}

	add     al,64           {-- Ctrl+A=1 // 1+64=65="A" }
	mov     control,al
	jmp     @bye

@t2:    cmp     ah,16           {------- Test Alt values }
	jb      @t3             {-- Below Alt+A? }
	cmp     ah,50           {-- Above Alt+M? }
	ja      @t3

	mov     cx,bx           {-- cx = old bx value }

	sub     ah,15           {-- Must do a table search! }
	xor     bx,bx
	mov     bl,ah           {-- need value in bx }
	mov     si,bx           {-- ...to store it on si }

        mov     dx,seg KeyLayout
        mov     es,dx
        mov     bx,offset Keylayout

        mov     al,es:[bx+si]
        mov     bx,cx

        cmp     al,'*'
        je      @bye
        mov     alternate,al
        jmp     @bye

@t3:    cmp     ah,59           {------- Test F1/F10 keys }
        jb      @t4
        cmp     ah,68
        ja      @t3_1

        sub     ah,58           {-- Adjust to 1-10 }
	mov     fkey,ah
        jmp     @bye

@t3_1:  cmp     ah,133          {--- Test F11/F12 }
        jb      @t4
        cmp     ah,134
        ja      @t4

        sub     ah,122          {-- Adjust to 11-12 }
        mov     fkey,ah
        jmp     @bye

@t4:    cmp     ah,84           {------- Test Shift+F1/F10 }
        jb      @t5
        cmp     ah,93
        ja      @t4_1

        sub     ah,83
        mov     sfkey,ah
        jmp     @bye

@t4_1:  cmp     ah,135          {-- Shift+F11/F12? }
        jb      @t5
        cmp     ah,136
        ja      @t5

        sub     ah,124
        mov     sfkey,ah
        jmp     @bye

@t5:    cmp     ah,94           {------- Test Control+F1/F10 }
        jb      @t6
        cmp     ah,103
        ja      @t5_1

        sub     ah,93
        mov     cfkey,ah
        jmp     @bye

@t5_1:  cmp     ah,137
	jb      @t6
        cmp     ah,138
        ja      @t6

        sub     ah,126
        mov     cfkey,ah
        jmp     @bye

@t6:    cmp     ah,104          {------- Test Alt+F1/F10}
        jb      @t7
        cmp     ah,113
        ja      @t6_1

        sub     ah,103
        mov     afkey,ah
        jmp     @bye

@t6_1:  cmp     ah,139
        jb      @t7
        cmp     ah,140
	ja      @t7

        sub     ah,128
        mov     afkey,ah
        jmp     @bye

@t7:    cmp     ah,129
        jne     @t8

        mov     ah,'0'
        mov     alternate,ah
        jmp     @bye

@t8:    cmp     ah,120
        jb      @bye
        cmp     ah,128
        ja      @bye

	sub     ah,71
	mov     alternate,ah

@bye:   mov     key,bl
	mov     ekey,bh
end;


{--------------------------------------
  Clears the entire keyboard buffer
---------------------------------------}
procedure clear_buffer; assembler;
asm
	mov     ah,0ch
	xor     al,al
	int     21h
end;


{---------------------------------------
    Puts cursor in these position (y,x)
------------------------------------------}
procedure gotoxy(col,row:integer); assembler;
asm
	mov     ah,2
	mov     bh,display_page { Display Page }

	mov     cx,row
	mov     dx,col
	mov     dh,cl
	int     10h
end;


{---------------------------------------
   Read key status: Stored in OUTPUT
 ====== Held: =====
 1=RightShift  2=LeftShift  4=Ctrl 8=Alt
 4096=Scroll   8192=NumLock 16384=Caps
 32768=Insert  256=Ctrl     512=Alt
 ====== Toggle: ====
 16  =Scroll  32=Num         64=Caps
 1024=SysReq  2048=Pause(!) 128=Insert
-----------------------------------------}
function keyboard_flags : word; assembler;
asm
	xor     ax,ax
	mov     es,ax
	mov     ax,es:[0417h]
end;


{-----------------------------
  Wait for mouse or Keyboard
  after clearing keys and
  waiting release mouse button
-------------------------------}
procedure wait_event; assembler;
asm
	call    clear_buffer
	xor     bx,bx
	mov     mk,bx
	mov     key,bl
	test    mouse,1         { Is Mouse active? }
	jz      @check          { If active wait user to depress }

@press: call    mousek
	test    Mk,0ffffh
	jnz     @press

@check: call    mousek          { Wait key or mouse button }
	call    readkey
	test    mk,255
	jnz     @bye
	test    key,255
	jnz     @bye
	test    fkey,255
	jz      @check
@bye:
end;

{----------------------------------
  Gets the screen information,
  checks if it is in graphics.
-----------------------------------}
procedure init_video ; assembler;
asm
	cld                     {-- clear direction flag }

	mov     ax,40h          {-- BIOS data area }
	mov     es,ax

	mov     dx,es:[63h]     {-- get crt address }
	mov     crtc,dx

	mov     ax,es:[4ch]     {-- Lenght of screen }
	cmp     ax,13312        {-- Check if graphics mode }
	jb      @okay

	cmp     dx,3d4h
	je      @color

@mono:  xor     ah,ah           {-- Force mono display }
	mov     al,7
	int     10h
	mov     al,1

@color: xor     ah,ah           {-- Force color display }
	mov     al,3
	int     10h
	xor     al,al

@okay:  cmp     dx,3d4h         {-- Get screen address }
	je      @col2

@mon2:  mov     screen_addr,0b000h
	jmp     @next

@col2:  mov     screen_addr,0b800h

{-------- CHANGES!! ------------}
@next:
	mov     dx,crtc		{ $3d4 color}
	add     dl,4

	mov     al,es:[65h]
	and     al,11011111b
	out     dx,al
	mov     es:[65h],al

	mov     bl,0
	mov     ax,1003h
	int     10h

	mov     al,es:[49h]     {-- Get current video mode }
	mov     screen_mode,al

	mov     ax,es:[4ah]     {-- Get # of columns }
	dec     ax
	mov     cols,ax
	mov     maxcols,ax

	inc     ax
	shl     ax,1            {-- Get bytes per column }
	mov     down_lin,ax

	mov     al,es:[62h]     {-- Get video page }
	mov     display_page,al


	mov     al,es:[84h]     {-- Get # of rows }
	xor     ah,ah
	mov     rows,ax
	mov     maxrows,ax

	mov     bx,cols         {-- calculate screen size }
	inc     bx
	inc     al
	mul     bx
	mov     whole_screen,ax

	xor     ax,ax           {-- clear xadd/yadd }
	mov     xadd,ax
	mov     yadd,ax
end;

{-------------------------------
   Sets mode. (must be text!)
--------------------------------}
procedure mode(mode:word); assembler;
asm
	mov     ax,mode
	int     10h

	call    init_video
end;


{--------------------------------
   Turns off the system Cursor
---------------------------------}
procedure cursor_off; assembler;
asm
	mov     ah,1
	mov     cx,2000h
	int     10h
end;


{------------------------
   Small system cursor
-------------------------}
procedure cursor_small; assembler;
asm
	mov     ah,1
	mov     cx,0607h        {-- cl=06  //  ch=07 }
	int     10h
end;


{-----------------------
   Big system cursor
------------------------}
procedure cursor_big; assembler;
asm
	mov     ah,1
	mov     cx,0007h        {-- cl=00 // ch=07 }
	int     10h
end;

{-----------------------
   Half system cursor
------------------------}
procedure cursor_half; assembler;
asm
	mov     ah,1
	mov     cx,0407h        {-- cl=04 // ch=07 }
	int     10h
end;


{------------------------------------
   Clears the bottom of the display.
---------------------------------------}
procedure clear_line; assembler;
asm
        call mouse_hide

	mov  ax,screen_addr     {-- es:bx will have screen address }
	mov  es,ax

	mov  ax,whole_screen
	shl  ax,1
	sub  ax,down_lin
	mov  di,ax

	mov  ax,7020h               {-- Gray+Black + blank space }

	mov  cx,cols
	inc  cx

	rep  stosw

        call mouse_show
end;

{--------------------------
    Horizontal line
--------------------------}
procedure hline(x,y,x1:integer ; first,mid,last:char); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd         {-- AX = Xadd = Left side }

	mov     bx,x            {-- BX = X position }
	mov     cx,x1           {-- CX = X1 position }
	add     bx,ax
	add     cx,ax

	cmp     bx,cx           {-- X1 cannot be lower than X }
	jle     @ok0
	xchg    bx,cx

@ok0:   cmp     bx,ax           {-- X is less than Xadd? }
	jge     @ok1

	mov     dl,mid          {-- Adjust beggining of line }
	mov     bx,ax
	mov     first,dl

@ok1:   cmp     cx,cols         {-- X1 is out of screen? }
	jle     @ok2
	mov     al,mid
	mov     cx,cols         {-- Adjust end of line }
	mov     last,al

@ok2:   sub     cx,bx           {-- Distance }
	js      @bye            {-- Exit if no distance (negative) }
	jnz     @ok3            {-- Check if only one character }

	cmp     bx,xadd         {-- One character at left need fix }
	jne     @ok3
	mov     al,last
	mov     first,al

@ok3:   mov     ax,y            {-- Prepare Y position }
	add     ax,yadd
	cmp     ax,yadd         {-- Out of screen? }
	jl      @bye
	cmp     ax,rows
	ja      @bye

	mul     down_lin        {-- Adjust Y to screen offset }
	shl     bx,1            {-- Each character = 2 bytes!! }
	mov     di,bx
	add     di,ax           {-- DI has screen offset = X+Y }

	mov     ah,syscolor     {-- Get color }

	mov     al,first        {-- Get fist character }
	mov     es:[di],ax
	add     di,2

	dec     cx
	js      @bye            {-- If only one, that's it }
	jz      @skip           {-- If only two, print last one }

	mov     al,mid          {-- Print middle characters }

	rep     stosw

@skip:  mov     al,last         {-- Print last character }
	mov     es:[di],ax

@bye:
end;


{---------------------------
  Draw a vertical line
----------------------------}
procedure vline(x,y,y1:integer ; first,mid,last:char); assembler;
asm
	mov     es,screen_addr

	mov     bx,x            {-- BX = x position }
	add     bx,xadd
	cmp     bx,cols         {-- Check if it's out of bounds }
	ja      @bye2

	cmp     bx,xadd
	jl      @bye2
	shl     bx,1            {-- Screen characters are WORDS }

	mov     dx,yadd         {-- DX = yadd }

	mov     ax,y            {-- AX = y position  }
	add     ax,dx

	mov     cx,y1           {-- CX = y1 position }
	add     cx,dx

	cmp     ax,cx
	jle     @ok0            {-- Jump if y <= y1 }
	xchg    cx,ax

@ok0:   cmp     ax,dx           {-- Check top character position }
	jge     @ok1

	mov     ax,dx           {-- Fix first position and character }
	mov     dl,mid
	mov     first,dl

@ok1:   mov     si,ax           {-- SI has y position }
	mul     down_lin
	add     bx,ax           {-- BX = Xaddress + Yaddress }

	cmp     cx,yadd         {-- Check y1 coordinate if onscreen }
	jl      @bye2
	cmp     cx,rows
	jbe     @ok2

	mov     cx,rows         {-- Adjust y1 position }
	mov     al,mid
	mov     last,al         {-- Adjust last character }

@ok2:   sub     cx,si           {-- CX = y1 - y = distance }
	js      @bye2           {-- No distance = nothin }
	jnz     @cont           {-- Check if only one char }

	mov     dl,last
	mov     first,dl

@cont:  mov     dx,down_lin

	mov     ah,syscolor     {-- Get color and character }
	mov     al,first

	cli
	mov     es:[bx],ax      {-- Plot first character }
	dec     cx
	js      @bye            {-- Counter is negative if is one }
	jz      @skip           {-- Counter is zero if are two chars }


	mov     al,mid
@store: add     bx,dx           {-- Go down }
	mov     es:[bx],ax      {-- Store middle characters }
	dec     cx
	jnz     @store

@skip:  add     bx,dx
	mov     al,last
	mov     es:[bx],ax      {-- Store last character }
@bye:   sti
@bye2:
end;



{----------------------------
  Prints a message on screen
-------------------------------}
procedure print(x,y:integer ; var txt:string); assembler;
asm
	push    ds

	mov     es,screen_addr  {-- es:di has screen address }

	mov     ax,y
	add     ax,yadd
	cmp     ax,rows         {-- y must be on-screen }
	jg      @bye
	cmp     ax,yadd
	jl      @bye

	mul     down_lin        {-- get y screen position }

	mov     cx,xadd         {-- cx = xadd = window left side }

	mov     bx,x
	add     bx,cx
	cmp     bx,cols         {-- check if it will display }
	jg      @bye

	xor     dx,dx           {-- dx has # of unseen chars }
	cmp     bx,cx           {-- all characters are on screen? }
	jnl     @ok

	mov     dx,cx           {-- count unseen characters }
	sub     dx,bx
	add     bx,dx

@ok:    shl     bx,1            {-- get x screen address }
	add     ax,bx
	mov     di,ax           {-- so es:di has screen position }

	mov     cx,cols         {-- store columns temporary }
	mov     ch,syscolor     {-- store syscolor }

	lds	si,txt		{-- ds:si = string address }

	mov     al,ds:[si]      {-- get string length }
	inc     si

	add     si,dx           {-- add unseen chars to string ptr }
	xor     ah,ah
	sub     ax,dx           {-- substract to length of string }
	jle     @bye

	mov     ah,ch           {-- ah has syscolor }
	xor     dx,dx           {-- dx has cols }
	mov     dl,cl

	xor     cx,cx           {-- cx has count of characters }
	mov     cl,al

	shr     bx,1            {-- check string & right border }
	add     bx,cx
	cmp     bx,dx
	jng     @ok2

	sub     bx,dx           {-- adjust # of chars to display }
	dec     bx
	sub     cx,bx

@ok2:   mov     dl,255          {-- dl has escape sequence }
	mov     dh,11110000b    {-- Mask color   }
	mov     bl,15           {-- Color select }


@plot:  mov     al,ds:[si]      {-- Get char... }
	inc     si

	cmp     al,bl
	ja      @cont

	and     ah,dh           {-- Change text color }
	or      ah,al
	dec     cx
	jnz     @plot
	jmp     @bye

@cont:  cmp     al,dl           {-- Escape sequence (255)? }
	jne     @noes

	mov     al,ds:[si]      {-- Get new character }
	inc     si

@noes:  mov     es:[di],ax
	add     di,2
	dec     cx
	jnz     @plot

@bye:   pop	ds
end;


{--------------------------
  Filled text box
--------------------------}
procedure Fill(x,y,x1,y1:integer ; paint:char); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd         {-- ax = xadd = Left side }
	mov     dx,cols         {-- dx = cols }

	mov     bx,x            {-- bx = x }
	add     bx,ax

	mov     cx,x1           {-- cx = x1 }
	add     cx,ax

	cmp     bx,cx           {-- x1 < x ? }
	jle     @ok0
	xchg    bx,cx

@ok0:   cmp     bx,dx           {-- x cannot be out of bounds }
	jg      @bye

	cmp     bx,ax           {-- x is less than xadd? }
	jge     @ok1
	mov     bx,ax           {-- adjust x }

@ok1:   cmp     cx,dx           {-- x1 is out of screen? }
	jle     @ok2
	mov     cx,dx           {-- Adjust x1 }

@ok2:   sub     cx,bx           {-- Distance }
	inc     cx
	jle     @bye            {-- must be 1 or greater }

	mov     ax,y            {-- Prepare y position }
	mov     dx,y1

{--}
	mov     di,yadd         {-- di = yadd for a while }
	mov     si,rows         {-- si = rows for a while }

	mov     ax,y            {-- ax = y position  }
	add     ax,di

	mov     dx,y1           {-- dx = y1 position }
	add     dx,di

	cmp     ax,dx
	jle     @ok3            {-- Jump if y <= y1 }
	xchg    dx,ax

@ok3:   cmp     ax,si           {-- check y with bottom line }
	jg      @bye
	cmp     ax,di           {-- Check y with top line }
	jge     @ok4

	mov     ax,di           {-- Fix top line }

@ok4:   cmp     dx,di           {-- check y1 with top border }
	jl      @bye
	cmp     dx,si           {-- check y1 with bottom }
	jle     @ok5

	mov     dx,si

@ok5:   sub     dx,ax           {-- si = distance }
	inc     dx
	jle     @bye            {-- must be > 0 }
	mov     si,dx

	mul     down_lin        {-- Adjust y to screen offset }
	shl     bx,1            {-- Each character = 2 bytes!! }
	mov     di,bx
	add     di,ax           {-- DI has screen offset = X+Y }

	mov     bx,di           {-- BX has a copy of screen offset}
	mov     dx,cx           {-- DX has a copy of # of chars }

	mov     ah,syscolor     {-- Get color }
	mov     al,paint        {-- Get character }

	cli
@Doit:  rep     stosw
	add     bx,down_lin
	mov     di,bx
	mov     cx,dx
	dec     si
	jnz     @Doit
	sti
@bye:
end;

{-------------------------------
   Stores the screen in Page
--------------------------------}
procedure get_screen(page:pointer); assembler;
asm
	push	ds
	les	di,page			{-- es:di = buffer dest. }

	mov     cx,whole_screen

	mov	ds,screen_addr		{-- ds:si = screen source }
	xor     si,si

	rep     movsw
	pop	ds
end;

{---------------------------------
   Put the Page in the screen
----------------------------------}
procedure put_screen(page:pointer); assembler;
asm
	push	ds
	mov     cx,whole_screen

	mov	es,screen_addr		{-- es:di = screen dest  }
	xor	di,di

	lds	si,page			{-- ds:si = buffer source }

	rep     movsw
	pop	ds
end;


{--------------------------------
     Scroll window left
---------------------------------}
procedure scroll_l(x,y,x1,y1:integer); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd

	mov     bx,x            {-- Get x and x1 position }
	add     bx,ax

	mov     dx,x1
	add     dx,ax
	sub     dx,bx           {-- Get x distance }
	jle     @bye            {-- distance must be > 0 }

	mov     ax,yadd
	mov     cx,y1           {-- cx = y1 }
	add     cx,ax
	add     ax,y            {-- ax = y + yadd }
	sub     cx,ax           {-- cl = y distance }
	jle     @bye            {-- Must be more than one }

	mov     ch,dl           {-- ch = x distance }
	inc     cl

	mov     si,down_lin     {-- si = y increment }

	shl     bx,1            {-- calculate screen y position }
	mul     si
	add     bx,ax

	mov     di,bx           {-- di = copy of position }

	cli

@doit:  mov     dl,ch

@hstep: mov     ax,es:[bx+2]
	mov     es:[bx],ax
	add     bx,2
	dec     dl
	jnz     @hstep

	mov     al,32
	mov     es:[bx],ax

	add     di,si
	mov     bx,di
	dec     cl
	jnz     @doit
	sti
@bye:
end;

{--------------------------------
       Scroll window up
---------------------------------}
procedure scroll_u(x,y,x1,y1:integer); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd

	mov     bx,x            {-- Get x and x1 position }
	add     bx,ax

	mov     dx,x1
        add     dx,ax
        sub     dx,bx           {-- Get x distance }
        jle     @bye

        mov     ax,yadd
        mov     cx,y1           {-- cx = y1 }
        add     cx,ax
        add     ax,y            {-- ax = yadd + y }
        sub     cx,ax           {-- cl = y distance }
        jle     @bye            {-- Must be more than one }

        mov     ch,dl           {-- ch = x distance }
        inc     ch

        mov     si,down_lin     {-- si = y increment }

        shl     bx,1            {-- calculate screen y position }
        mul     si
        add     bx,ax

        mov     di,bx           {-- di = copy of position }
        cli

@doit:  mov     dl,ch

@hstep: mov     ax,es:[bx+si]
        mov     es:[bx],ax
        add     bx,2
        dec     dl
        jnz     @hstep

        add     di,si
        mov     bx,di
	dec     cl
        jnz     @doit

        mov     cl,ch
        xor     ch,ch
        mov     al,32
@clir:  rep     stosw
        sti
@bye:
end;

{--------------------------------
     Scroll window right
---------------------------------}
procedure scroll_r(x,y,x1,y1:integer); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd

        mov     bx,x1           {-- bx and dx = x1 }
        add     bx,ax
        mov     dx,bx

        add     ax,x
        sub     dx,ax           {-- dx = x1-x = distance }
        jle     @bye

        mov     ax,yadd         {-- Get y and y1 position }

        mov     di,y            {-- di = y }
        add     di,ax

        mov     cx,y1           {-- cx = y1 + ax }
        add     cx,ax
        sub     cx,di           {-- cl = y1-y = distance }
        jle     @bye            {-- Must be more than one }

        add     ax,di           {-- ax = addx + y }

        mov     ch,dl           {-- ch = x distance }
        inc     cl

        mov     si,down_lin     {-- si = y increment }

        shl     bx,1
        mul     si              {-- calculate screen y position }
        add     bx,ax

        mov     di,bx           {-- di = copy of position }
        cli

@doit:  mov     dl,ch

@hstep: mov     ax,es:[bx-2]
        mov     es:[bx],ax
        sub     bx,2
	dec     dl
        jnz     @hstep

        mov     al,32
        mov     es:[bx],ax

        add     di,si
        mov     bx,di
        dec     cl
        jnz     @doit
        sti
@bye:
end;

{--------------------------------
     Scroll window down
---------------------------------}
procedure scroll_d(x,y,x1,y1:integer); assembler;
asm
	mov     es,screen_addr

        mov     ax,xadd

        mov     bx,x            {-- Get x and x1 position }
        add     bx,ax

        mov     dx,x1
        add     dx,ax
        sub     dx,bx           {-- Get x distance }
        jle     @bye

        mov     di,yadd
        mov     cx,y1           {-- cx = y1 }
        add     cx,di
        mov     ax,cx           {-- ax = y1 + yadd }
        add     di,y            {-- di = yadd + y }
        sub     cx,di           {-- cl = y distance }
        jle     @bye            {-- Must be more than one }

        mov     ch,dl           {-- ch = x distance }
	inc     ch

        shl     bx,1            {-- calculate screen y position }
        mul     down_lin
        add     bx,ax

        mov     di,bx           {-- di = copy of position }
        mov     si,bx
        sub     si,down_lin
        cli

@doit:  mov     dl,ch

@hstep: mov     ax,es:[si]
        mov     es:[bx],ax
        add     bx,2
        add     si,2
        dec     dl
        jnz     @hstep

	sub     di,down_lin
        mov     bx,di
        mov     si,bx
        sub     si,down_lin

        dec     cl
        jnz     @doit

        mov     cl,ch
        xor     ch,ch
        mov     al,32
@clir:  rep     stosw
        sti
@bye:
end;


{-------------------------
	  Text Box
-------------------------}
procedure tbox(x,y,x1,y1:integer ; var bar:str12);
begin
asm
	mov     ax,x            {-- Check coordinates }
	cmp     x1,ax
	jle     @ok
	xchg    ax,x1

@ok:    mov     x,ax

	mov     ax,y
	cmp     ax,y1
	jle     @ok2
	xchg    ax,y1

@ok2:   mov     y,ax
end;
 hline(x,y,x1,bar[1],bar[2],bar[3]);
 hline(x,y1,x1,bar[4],bar[5],bar[6]);
 dec(y1,1);
 inc(y,1);
 vline(x,y,y1,bar[7],bar[8],bar[9]);
 vline(x1,y,y1,bar[10],bar[11],bar[12]);
end;



procedure tboxfill(x,y,x1,y1:integer ; var bar:str12);
begin
asm
	mov     ax,x
	cmp     ax,x1
	jle     @ok
	xchg    ax,x1
@ok:    mov     x,ax

	mov     ax,y
	cmp     ax,y1
	jle     @ok2
	xchg    ax,y1

@ok2:   mov     y,ax
end;
 hline(x,y,x1,bar[1],bar[2],bar[3]);
 hline(x,y1,x1,bar[4],bar[5],bar[6]);
 dec(y1,1);
 inc(y,1);
 vline(x,y,y1,bar[7],bar[8],bar[9]);
 vline(x1,y,y1,bar[10],bar[11],bar[12]);
 inc(x,1);
 dec(x1,1);
 fill(x,y,x1,y1,' ');
end;


{---------------------------
  Resets window to default
  coordinates.
----------------------------}
procedure reset_window; assembler;
asm
	xor     ax,ax
	mov     xadd,ax
	mov     yadd,ax

	mov     ax,maxcols
	mov     bx,maxrows
	mov     cols,ax
	mov     rows,bx
end;

{--------------------------------
  Defines the window coordinate.
  Default: 0,0,maxcols,maxrows
   - Does not check values -
--------------------------------}
procedure window(x,y,x1,y1:integer); assembler;
asm
	mov     ax,x
	mov     bx,x1
	cmp     ax,bx
	jl      @ok
	jz      @bye
	xchg    ax,bx

@ok:    mov     xadd,ax
	mov     cols,bx

	mov     ax,y
	mov     bx,y1
	cmp     ax,bx
	jl      @ok2
	jz      @bye
	xchg    ax,bx

@ok2:   mov     yadd,ax
	mov     rows,bx

@bye:
end;

{----------------------------
  Darken a horizontal line
-----------------------------}
procedure shadow_x(x,y,x1 : integer); assembler;
asm
	mov     es,screen_addr

	mov     ax,y            {-- ax = y coordinate }
	add     ax,yadd
	cmp     ax,yadd         {-- y is out of bounds? }
	jl      @bye
	cmp     ax,rows
	jg      @bye
	mul     down_lin

	mov     si,xadd         {-- commonly used... }
	mov     di,cols

        mov     bx,x            {-- bx = x }
        add     bx,si

        mov     cx,x1           {-- cx = x1 }
        add     cx,si

        cmp     bx,cx
        jle     @ok
	xchg    bx,cx

@ok:    cmp     bx,di           {-- x > cols? }
	jg      @bye

	cmp     bx,si           {-- x < left? }
	jge     @ok2
	mov     bx,si

@ok2:   cmp     cx,si           {-- x1 < left? }
	jb      @bye

	cmp     cx,di           {-- x1 > cols? }
	jle     @ok3
	mov     cx,di

@ok3:   cmp     bx,cx           {-- x1 less than x }
	jg      @bye

	sub     cx,bx           {-- cx = distance }
	inc     cx

	shl     bx,1
	add     bx,ax
	inc     bx

	mov     al,sysshadow
	mov     dx,2

@doit:  mov     es:[bx],al
	add     bx,dx
	loop    @doit
@bye:
end;

{----------------------------
  Darken a vertical line
-----------------------------}
procedure shadow_y(x,y,y1 : integer); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd
	mov     bx,x            {-- bx = x }
	add     bx,ax
	cmp     bx,ax
	jl      @bye
	cmp     bx,cols
	jg      @bye
	shl     bx,1

        mov     dx,yadd

        mov     ax,y            {-- ax = y position }
        add     ax,dx

        mov     cx,y1           {-- cx = y1 position }
        add     cx,dx

        cmp     ax,cx           {-- swap y,y1 if necessary }
        jle     @ok
	xchg    cx,ax

@ok:    mov     si,rows         {-- si=rows //  dx=yadd }

	cmp     ax,si           {-- y > bottom? }
	jg      @bye

	cmp     cx,dx           {-- y1 < top? }
	jl      @bye

	cmp     ax,dx           {-- y needs top chop? }
	jge     @ok1
	mov     ax,dx

@ok1:   cmp     cx,si           {-- y1 needs bottom chop? }
	jle     @ok2
	mov     cx,si

@ok2:   cmp     ax,cx
	jg      @bye

	sub     cx,ax           {-- get distance }
	inc     cx

	mul     down_lin        {-- get y position }
	add     bx,ax           {-- bx = x + y }

	mov     al,sysshadow
	mov     dx,down_lin
	inc     bx

@doit:  mov     es:[bx],al
	add     bx,dx
	loop    @doit
@bye:
end;


{-------------------------
  Creates the box shadow
--------------------------}
procedure shadowbox(x,y,x1,y1:integer);
begin
asm
	mov     ax,x
	mov     bx,x1
	cmp     ax,bx
	jle     @ok
	xchg    ax,bx

@ok:    add     al,2
	add     bl,2
	mov     x,ax
	mov     x1,bx

	mov     ax,y
	mov     bx,y1
	cmp     ax,bx
	jle     @ok2
	xchg    ax,bx

@ok2:   inc     ax
	inc     bx
	mov     y,ax
	mov     y1,bx
end;
 shadow_x(x,y1,x1);
 shadow_y(x1,y,y1);
 shadow_y(x1-1,y,y1);
end;

procedure autoexec; assembler;
asm
	xor     ax,ax
	xor     bx,bx

	mov     mouse,ax
	mov     mk,bx
	mov     mx,ax
	mov     my,bx

end;


procedure help(bs:string);
var i : byte;
begin
 i:=syscolor;
 syscolor:=$70;
 clear_line;
 bs:='≥›€≤±∞ '+bs;
 mouse_hide;
 print(1,rows,bs);
 mouse_show;
 syscolor:=i;
end;


{------------------------
     Fast uppercase
-------------------------}
procedure upcase(var bs:string); assembler;
asm
	mov     ax,[bp+8]
	mov     es,ax
	mov     bx,[bp+6]
	xor     cx,cx
	mov     cl,es:[bx]

	mov     ah,'a'
	mov     dl,'z'
	mov     dh,223

	jcxz    @bye

@doit:  inc     bx
	mov     al,es:[bx]
	cmp     al,ah           {-- al < 'a'? }
	jb      @skip
	cmp     al,dl           {-- al > 'z'? }
	ja      @skip
	and     al,dh           {-- clear bit }
	mov     es:[bx],al
@skip:  loop    @doit
@bye:
end;


{-----------------------------
  convert string to lowercase
------------------------------}
procedure lowcase(var bs:string); assembler;
asm
	mov     ax,[bp+8]
	mov     es,ax
	mov     bx,[bp+6]
	xor     cx,cx
	mov     cl,es:[bx]

	mov     ah,'A'
	mov     dl,'Z'
	mov     dh,32

	jcxz    @bye

@doit:  inc     bx
	mov     al,es:[bx]
	cmp     al,ah           {-- al < 'A'? }
	jb      @skip
	cmp     al,dl           {-- al > 'Z'? }
	ja      @skip
	or      al,dh           {-- set bit }
	mov     es:[bx],al
@skip:  loop    @doit
@bye:
end;


{------------------
  Generate sound
------------------}
procedure sound(Hz:word); assembler;
asm
	mov	bx,Hz
	cmp     bx,12h
	jna     @bye

	mov	dx,43h

	mov     ax,34DDh
	div     bx
	mov     bx,ax

	in      al,61h
	test    al,3
	jne     @nope
	or      al,3
	out     61h,al
	mov     al,0B6h
	out     dx,al

@nope: 	mov     al,bl
	dec	dx

	out     dx,al
	mov     al,bh
	out     dx,al
@bye:
end;


{------------------------------
      Turn off sound
-------------------------------}
procedure nosound; assembler;
asm
	in      al,61H
	and     al, 0fcH
	out     61H, al
end;

{--------------------------
  Change the color palette
---------------------------}
procedure vgapalette(color,red,green,blue:integer); assembler;
asm
		mov	dx,03C8h
		mov	bl,63
		mov	ax,color
		out	dx,al
		inc	dx
		mov	ax,red
		and	al,bl
		out	dx,al
		mov	ax,green
		and	al,bl
		out	dx,al
		mov	ax,blue
		and	al,bl
		out	dx,al
end;


{---------------------------
     Set the break flag
----------------------------}
procedure break_off; assembler;
asm
	xor	dl,dl
	mov	ax,3301h
	int	21h
end;

procedure break_on; assembler;
asm
	mov	dl,1
	mov	ax,3301h
	int	21h
end;


{------------------------------------------------------------
  Clears screen, original colors, hide mouse and show cursor
---------------------------------------------------------------}
procedure reset_screen;
begin
 mouse_hide;
 syscolor:=$07;
 cls(' ');
 gotoxy(0,0);
 cursor_small;
end;


{----------------------------------------------------------}
begin
 init_video;
 autoexec;
 screen1:=@crtlogo1;
 screen2:=@crtlogo2;
 screen3:=@crtlogo3;
 screen4:=@crtlogo4;
end.