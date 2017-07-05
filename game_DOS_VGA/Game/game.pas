{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
	 GAME MANAGER v1.0 - Copyright (c) 1995 Marco A. Marrero
อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}
unit game;
interface
uses intvec;

const

{-- Key scan codes ---}
 _space=57;  _enter=28; _esc= 1; _tab=15; _crtl=29; _rshift=54;
 _lshift=42; _alt=56; _caps=58; _up = 72; _down=80; _left=75;
 _right=77; _num5=76; _pgup=73; _pgdn=81; _home=71; _end=79;
 _ins=82; _del=83; _back=14;

 _f1=59; _f2=60;  _f3=61;  _f4=62;  _f5=63; _f6=64; _f7=65; _f8=66;
 _f9=67; _f10=68; _f11=87; _f12=88;

 _a=30; _b=48; _c=46; _d=32; _e=18; _f=33; _g=34; _h=35; _i=23; _j=36;
 _k=37; _l=38; _m=50; _n=49; _o=24; _p=25; _q=16; _r=19; _s=31; _t=20;
 _u=22; _v=47; _w=17; _x=45; _y=21; _z=44;

 _1=2; _2=3; _3=4; _4=5; _5=6; _6=7; _7=8; _8=9; _9=10; _0=11;

 NONE = 0;	MDA = 1;	CGA =2;		EGAMONO =3;
 EGACOLOR =4;	VGAMONO = 5;	VGACOLOR = 6;	MCGAMONO = 7;
 MCGACOLOR = 8;

var
 _lastmode	: word;
 _base		: word;
 _errormsg	: string;

 readkey	: byte;
 keyboard	: array[0..127] of byte;

 timerw		: word;
 framew		: word;

 _proc1,_proc2,_proc3,_proc4,_speaker : pointer; {-- timer routines!! --}

 procedure int_mask_register(which:byte);
 procedure key_leds(which:byte);
 procedure timer_tick(freq:word);
 procedure sound(hz:word);
 procedure nosound;

 procedure biosgotoxy(x,y:byte);
 function  bioswherex : byte;
 function  bioswherey : byte;
 procedure bioscls(color:byte);
 procedure echo(txt:string; color:byte);
 procedure numx(val:string; value:word);
 procedure numhex(val:string; value:word);
 procedure echonum(num:word; color:byte);

 function which_video : byte;
 function joystick(what:byte) : word;
 function button : byte;
{function peekb(addr:pointer; adder:word) : byte;
 function peekw(addr:pointer; adder:word) : word; }

 function ptrseg(buf:pointer):word;
 function ptrofs(buf:pointer):word;

 procedure wait_key;

 procedure game_off;
 procedure game_on;



implementation

var
 _oldkey   : pointer;
 _oldint16h: pointer;
 _oldtimer : pointer;
 _oldtick  : word;

 _bp,_sp,_ss,_ds,_es	 : word;
 _flag			 : word;
 _ax,_bx,_cx,_dx,_si,_di : word;

 bs : string[80];


{----------------------- ROUTINES -----------------------------------}


{--------------------------------
  Detect if a 386 CPU is in
---------------------------------}
function cpu_check : word; assembler;
asm
	mov		ax,7000h
	push	ax
	popf
	pushf
	pop		ax
	and		ax,07000h
	jz		@@noway		{-- ax = 0 ... check failed }
	xor		ax,ax
	inc		ax				{-- ax <> 0 ... check ok ! }
@@noway:
	sti							{-- bug... This miserable disable ints! }
end;



{--------------------------------------
	BIOSGOTOXY(x,y) | Moves cursor pos
--------------------------------------}
procedure biosgotoxy(x,y:byte); assembler;
asm
	mov	dl,y
	mov	dh,x
	mov	ah,2
	xor	bh,bh
	int	10h
end;


{-------------------------------------
	BIOSWHEREX() | Returns x position
--------------------------------------}
function bioswherex : byte; assembler;
asm
	mov	ah,3
	mov	bh,0
	int	10h
	mov	al,dh
end;



{-------------------------------------
	BIOSWHEREY() | Returns x position
--------------------------------------}
function bioswherey : byte; assembler;
asm
	mov	ah,3
	mov	bh,0
	int	10h
	mov	al,dl
end;



{-------------------------------------------------------------------
	bioscls(color:byte) || Clears the text screen with the color...
--------------------------------------------------------------------}
procedure bioscls(color:byte); assembler;
asm
	mov	ax,0600h	{-- ah=06, al=00. al=0=whole screen }
	mov	bh,color	{-- color }
	mov	ch,0			{-- top row }
	mov	cl,0			{-- left }
	mov	dh,24			{-- bottom }
	mov	dl,79			{-- right }
	int	10h
end;



{----------------------------------------------------------------
	echo(*txt,backg,color) | Does not interpret ASCII codes
------------------------------------------------------------------}
procedure echo(txt:string; color:byte); assembler;
asm
	push	ds
	push    si

	lds	si,txt			{-- get string address in ds:si }
	xor	cx,cx

	mov	cl,ds:[si]	{-- get pascal string length }
	inc	si
	or	cx,cx				{-- Empty string?? }
	jz	@bye

	mov	ah,0eh			{-- function.. }
	mov	bh,0				{-- No background}
	mov	bl,color		{-- Color	 }

@doit:
	lodsb					{-- get char, mov al,ds:[si] }
	or	al,al			{-- escape code? }
	jnz	@plot

@color:
	lodsb			{-- get color number }
	mov	bl,al
	dec	cx
	jz	@bye
	loop	@doit
	jmp	@bye

@plot:
	int	10h		{-- BIOS Write character }
	loop	@doit

@bye:
	pop	si
	pop	ds
end;




{--------------------------------------------
	num(string,num) | Convert number to string
---------------------------------------------}
procedure numx(val:string; value:word);assembler;
asm
	mov	cx,_base	{-- Base }
	xor	bx,bx		{-- Counter }
	xor	dx,dx		{-- remainder }

	mov	ax,value	{-- Number value }
	or	ax,ax
	je	@@done

@@wind:
	xor	dx,dx
	div	cx		{-- Divide by base }

@@done:
	inc	bx		{-- Counter }
	add	dl,'0'		{-- Convert to ascii }
	cmp	dl,'9'		{-- It's greater than 9? }
	jbe	@@nohex		{---- No, it's not hex }
	add	dl,7 		{-- Convert to 'A...'}

@@nohex:
	push	dx		{-- Push in stack }
	or	ax,ax		{-- Number is zero? }
	jnz	@@wind		{--- No, keep working }

@@fin:
	mov	cx,bx		{-- number of digits }
	les	bx,val		{-- get string position }
	mov	[bx],cl		{-- store number }

@@store:
	inc	bx
	pop	ax		{-- Get digit }
	mov	[bx],al		{-- store.. }
	loop	@@store		{-- until all popped up }
end;




{--------------------------------------------
	numhex(string,num) | Convert number to hex
---------------------------------------------}
procedure numhex(val:string; value:word);assembler;
asm
	mov	cx,16		{-- Base }
	xor	bx,bx		{-- Counter }
	xor	dx,dx		{-- remainder }

	mov	ax,value	{-- Number value }
	or	ax,ax
	je	@@done

@@wind:
	xor	dx,dx
	div	cx		{-- Divide by base }

@@done:
	inc	bx		{-- Counter }
	add	dl,'0'		{-- Convert to ascii }
	cmp	dl,'9'		{-- It's greater than 9? }
	jbe	@@nohex		{---- No, it's not hex }
	add	dl,7 		{-- Convert to 'A...'}

@@nohex:
	push	dx		{-- Push in stack }
	or	ax,ax		{-- Number is zero? }
	jnz	@@wind		{--- No, keep working }

@@fin:
	mov	cx,bx		{-- number of digits }
	les	bx,val		{-- get string position }
	mov byte ptr [bx],4	{-- store 4 digits }

	cmp	cl,4		{-- If 4 digits, don't need to pad }
	je	@@store
	mov	ax,cx		{-- Number of digits in ax }
	mov	ah,'0'
@@fill:
	inc	bx		{-- store zeros }
	mov	[bx],ah
	inc	al
	cmp	al,4
	jb	@@fill

@@store:
	inc	bx
	pop	ax		{-- Get digit }
	mov	[bx],al		{-- store.. }
	loop	@@store		{-- until all popped up }
end;




{--------------------------------------------------
  echonum(num) | Echoes a number to the screen
--------------------------------------------------}
procedure echonum(num:word; color:byte);
var last:word;
begin
 last:=_base;
 _base:=10;
 numx(bs,num);
 echo(bs,color);
 _base:=last;
end;



{-------------------------------
	 Convert string to uppercase
-------------------------------}
procedure upcase(var bs:string); assembler;
asm
				les     bx,[bp+4]
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



{----------------------------------------------
	int_mask_register(irq) | Turn on/off irqs!!
----------------------------------------------}
procedure int_mask_register(which:byte); assembler;
asm
	mov	al,which	{-- get which to use }
	out	21h,al		{-- ok.. }
end;





{ษอออออออออออหอออออออออออออออออป
 บ sound(hz) บ Generate sound  บ
 ศอออออออออออสอออออออออออออออออผ}
procedure sound(hz:word); assembler;
asm
	mov	bx,hz
	cmp	bx,012h
	jna	@@bye

	mov	dx,043h

	mov	ax,034ddh
	div	bx
	mov	bx,ax

	in	al,061h
	test	al,3
	jne	@@nope
	or	al,3
	out	061h,al
	mov	al,0b6h
	out     dx,al
@@nope:
	mov	al,bl
	dec	dx

	out	dx,al
	mov	al,bh
	out	dx,al
@@bye:
end;




{ษอออออออออออหออออออออออออออออป
 บ NOSOUND() บ Turn off sound บ
 ศอออออออออออสออออออออออออออออผ}
procedure nosound; assembler;
asm
	in	al,061h
	and     al,0fch
	out     061h,al
end;



{----------------------------------------
			Keyboard scan/ascii tables
----------------------------------------}
procedure scan_shift; assembler;
asm
	 db 000,001,002,003,004,005,006,007,008,009
	 db 010,011,012,013,014,015,016,017,018,019
	 db 020,021,022,023,024,025,026,027,028,000
	 db 030,031,032,033,034,035,036,037,038,039
	 db 040,041,000,043,044,045,046,047,048,049
	 db 050,051,052,053,000,000,000,057,000,084
	 db 085,086,087,088,089,090,091,092,093,000
	 db 000,071,072,073,074,075,000
end;

procedure scan_ctrl; assembler;
asm
	 db 000,000,000,001,000,000,000,007,000,000
	 db 000,000,012,000,014,000,016,017,018,019
	 db 020,021,022,023,024,025,026,027,028,000
	 db 030,031,032,033,034,035,036,037,038,000
	 db 000,000,000,000,044,045,046,047,048,049
	 db 050,000,000,000,000,114,000,057,000,094
	 db 095,096,097,098,099,100,101,102,103,000
	 db 000,119,000,132,000,115,000,116,000,117
	 db 000,118,004,006,114,000,000,000,000,000
end;


procedure scan_alt; assembler;
asm
	 db 000,000,120,121,122,123,124,125,126,127
	 db 128,129,130,131,008,000,016,017,018,019
	 db 020,021,022,023,024,025,000,000,000,000
	 db 030,031,032,033,034,035,036,037,038,000
	 db 000,000,000,000,000,000,000,002,000,104
	 db 105,106,107,108,109,110,111,112,113,000
	 db 000,000,000,000,000,000,000,000,000,000
	 db 000,000,000,000,000,000,000,000,000,000
end;

procedure ascii_ctrl; assembler;
asm
	 db 000,027,000,000,000,000,000,27,000,000
	 db 000,000,031,000,127,000,017,23,005,018
	 db 020,025,021,009,015,016,027,029,010,000
	 db 001,019,004,006,007,008,010,011,012,000
	 db 000,000,000,028,026,024,003,022,002,014
	 db 013,000,000,000,000,000,000,' ',000,000
	 db 000,000,000,000,000,000,000,000,000,000
	 db 000,000,000,000,000,000,000,000,000,000
end;

procedure ascii_shift; assembler;
asm
	 db 000,027,'!','@','#','$','%','^','&','*'
	 db '(',')','_','+',000,000,'Q','W','E','R'
	 db 'T','Y','U','I','O','P','[',']',013,000
	 db 'A','S','D','F','G','H','J','K','L',':'
	 db '"','~',000,'|','Z','X','C','V','B','N'
	 db 'M','<','>','?',000,000,000,000,000,000
	 db 000,000,000,000,000,000,000,000,000,000
	 db 000,000,000,000,'-',000,000,000,'+',000
	 db 000,000,000,000,000,000,000,000,000,000
end;

procedure ascii_normal; assembler;
asm
	db 000,027,'1','2','3','4','5','6','7','8'
	db '9','0','-','=',008,009,'q','w','e','r'
	db 't','y','u','i','o','p','[',']',013,000
	db 'a','s','d','f','g','h','j','k','l',';'
	db 039,'`',000,'\','z','x','c','v','b','n'
	db 'm',',','.','/',000,000,000,' ',000,000
	db 000,000,000,000,000,000,000,000,000,000
	db 000,000,000,000,'-',000,'5',000,'+',000
	db 000,000,000,000,000,000,000,000,000,000
end;



{-------------------------------------------------------
  i=BIOSGETMODE() | Gets the current BIOS graphics mode
--------------------------------------------------------}
function biosgetmode : word; assembler;
asm
	mov	ah,0fh
	int	10h
	xor	ah,ah
end;




{ษอออออออออออออออออหอออออออออออออออออออออออออออออออออออป
 บ RESTORE_CLOCK() บ Restore time from CMOS registers  บ
 ศอออออออออออออออออสอออออออออออออออออออออออออออออออออออผ}
procedure restore_clock; assembler;
asm
	xor	al,al
	out	70h,al
	in	al,71h
	mov	dh,al
	and	dh,15
	mov	cl,4
	shr	al,cl

	mov     dl,10
	mul	dl
	add	dh,al

	mov	al,2
	out	70h,al
	in	al,71h
	mov	cl,al
	and	cl,15

	push	cx
	mov	cl,4
	shr	al,cl
	pop	cx

	mov	dl,10
	mul	dl
	add	cl,al

	mov	al,4
	out	70h,al
	in	al,71h
	mov	ch,al
	and	ch,15

	push	cx
	mov	cl,4
	shr	al,cl
	pop	cx

	mov	dl,10
	mul	dl
	add	ch,al

	xor	dl,dl
	mov	ah,2dh
	int	21h

	mov	al,7
	out	70h,al
	in	al,71h
	mov	dl,al
	and	dl,15

	push	cx
	mov	cl,4
	shr	al,cl
	pop	cx

	mov	ch,10
	mul	ch
	add	dl,al

	mov	al,8
	out	70h,al
	in	al,71h
	mov	dh,al
	and	dh,15

	push	cx
	mov	cl,4
	shr	al,cl
	pop	cx

	mov	ch,10
	mul	ch
	add	dh,al

	mov	al,4
	out	70h,al
	in	al,71h
	mov	cl,al
	and	cl,15

	push	cx
	mov	cl,4
	shr	al,cl
	pop	cx

	mov	ch,10
	mul	ch
	add	cl,al

	xor	ch,ch
	add	cx,1900
	mov	ah,2bh
	int	21h
end;



{---------------------------------
  Clear values | Clear variables
----------------------------------}
procedure clear_values; assembler;
asm
	push	di

	mov	cx,128
	mov	readkey,cl

	mov	ax,seg keyboard[0]
	mov	es,ax
	mov	di,offset keyboard[0]

	xor	ax,ax

@clir:
	shr	cx,1
	rep	stosw
	adc	cx,cx
	rep	stosb

	pop	di
end;




{-------------------------------------
	leds(000b) | Turn on specific leds
--------------------------------------}
procedure key_leds(which:byte); assembler;
asm
	mov	dx,60h
	mov	al,0edh
	out	dx,al

	mov	cx,1400
@@loo:
	dec	cx
	jnz	@@loo

	mov	al,which
	out	dx,al
end;





{-------------------------------------------
	timer_tick(freq) | Change system timer
--------------------------------------------}
procedure timer_tick(freq:word); assembler;
asm
	mov	al,36h			{-- channel 0 controls INT 08h timer }
	out	43h,al

	mov	bx,freq			{-- 1193180/freq=times per second }
	mov	_oldtick,bx

	mov	al,bl
	out	40h,al			{-- Write low byte }
	mov	al,bh
	out	40h,al  		{-- Write high byte }

end;


{=========================== CLEANUP =====================================}

{ษอออออออออออออออออออออออออออออออออออออออออป
 บ key_cleanup() | Clean the mess you did! บ
 ศอออออออออออออออออออออออออออออออออออออออออผ}
procedure key_cleanup; far;
begin
 asm  cld; end;

 int_mask_register(0);								{-- enable all interrupts   }
 timer_tick(0); 											{-- restore timer frequency }
 setvec(9,_oldkey);										{-- return keyboard interrupt }

 setvec(8,_oldtimer);									{-- return timer interrupt }
{ restore_clock;}											{-- read clock from CMOS   }

 setvec($16,_oldint16h);							{-- restore bios keyboard }
 key_leds((mem[seg0040:$017] shr 4) and 7);	{-- Restore keyboard leds }


 {--- Print debug information ---}
 if exitcode<>0 then
 begin
	asm
	mov	ax,_lastmode	{-- restore last mode }
	int	10h
	end;
	_base:=10;
	echo('Abnormal Exit: Error value #',15);
	numx(bs,exitcode);
	echo(bs+' at address ',15);
	numhex(bs,SEG(erroraddr));
	echo(bs+':',15);
	numhex(bs,OFS(erroraddr));
	echo(bs,15);

	if (exitcode=255) then _errormsg:='User break!';
	if (exitcode=216) then _errormsg:='General Protection Error';


	if _errormsg<>'' then
	begin
	 echo(#13#10'   In english: ',15);
	 echo(_errormsg,15);
	end;

	echo(#13#10'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'#13#10,15);
	echo('  GAMEOS v1.21  - Copyright (c) 1995,99 Marco A. Marrero',15);
	echo(#13#10'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'#13#10,15);
	echo(' AX   BX   CX   DX   SI   DI   BP   SP   SS   DS   ES  Flag'#13#10,15);
	numhex(bs,_ax); bs:=bs+' '; echo(bs,15);
	numhex(bs,_bx); bs:=bs+' '; echo(bs,15);
	numhex(bs,_cx); bs:=bs+' '; echo(bs,15);
	numhex(bs,_dx); bs:=bs+' '; echo(bs,15);
	numhex(bs,_si); bs:=bs+' '; echo(bs,15);
	numhex(bs,_di); bs:=bs+' '; echo(bs,15);
	numhex(bs,_bp); bs:=bs+' '; echo(bs,15);
	numhex(bs,_sp); bs:=bs+' '; echo(bs,15);
	numhex(bs,_ss); bs:=bs+' '; echo(bs,15);
	numhex(bs,_ds); bs:=bs+' '; echo(bs,15);
	numhex(bs,_es); bs:=bs+' '; echo(bs,15);
	numhex(bs,_flag);bs:=bs+' '; echo(bs,15);
	echo(#13#10'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'#13#10,15);
 end;

 asm
	mov	ax,4c00h	{-- exit gracefully! }
	int	21h
 end;
end;





{ษออออออออออออออออออออออออออออออออออป
 บ   Keyboard vector routine        บ
 ศออออออออออออออออออออออออออออออออออผ }
procedure key_int; far; assembler;
asm
	push	ds
	push	bx
	push	ax

    mov     bx,seg readkey
    mov     ds,bx
    mov	bx,offset keyboard[0]       { BX has keyboard array address}

	in	al,60h							{-- get key  }
	mov	readkey,al					{-- store key }

	cmp	al,198 							{-- pressed pause/break? }
	je	@@guru							{--- aarrggghh!! Must quit!! }

@@falsealarm:
	mov	ah,al
	and	ah,7fh
	cmp	ah,al 							{-- last bit set? }
	jne	@@clir							{---- if so, key released! }

@@set:
	xor	ah,ah
	add	bx,ax 							{-- bx has table offset }
	mov	byte ptr [bx],1
	jmp	@@okay


@@clir:
	mov	al,ah
	xor	ah,ah
	add	bx,ax 							{-- bx has table offset }
	mov	ds:[bx],ah


@@okay:
	in	al,61h		{-- read 8255 port pb }
	or	al,80h		{-- Keyboard acknowledge }
	out	61h,al
	and	al,7fh		{-- reset key acknowledge... }
	out	61h,al		{-- restore original 8255 }

	mov	al,20h		{-- send end-of-interrupt...	}
	out	20h,al		{-- to the interrupt controller }

	pop	ax
	pop	bx
	pop	ds
	iret
'add your scan code processing code here

@@guru:
{--- Critical halt!! ---}
    mov       al,[bx + _crtl]
    cmp       al,1
    mov       al,198
    jne       @@falsealarm
    cld

	mov	ax,seg _bp
	mov	ds,ax

	xchg	bp,_bp	{-- restore original registers }

	mov	ax,_ss
	mov	_ss,ss
	mov	ss,ax

	mov	ax,_es
	mov	_es,es
	mov	es,ax

	pop	ax
	mov	_ax,ax

	pop	ax
	mov	_bx,ax


	pop	ax
	xchg	ax,_ds
	mov	ds,ax

	pop	ax
	mov	_flag,ax

	add	sp,4
	xchg	sp,_sp

	mov	_si,si
	mov	_di,di
	mov	_cx,cx
	mov	_dx,dx


{-- Signal End of Interrupt --}
	in	al,61h	{-- read 8255 port pb }
	or	al,80h	{-- Keyboard acknowledge }
	out	61h,al
	and	al,7fh	{-- reset key acknowledge... }
	out	61h,al	{-- restore original 8255 }

	mov	al,20h		{-- send end-of-interrupt...	}
	out	20h,al		{-- to the interrupt controller }

	jmp	key_cleanup	{-- clean-up mess! }
end;




{------------------------------------------------------------------
	BIOS16SIM | Emulate BIOS keyboard calls to allow pop-ups to run!
-------------------------------------------------------------------}
procedure bios16sim; far; assembler;
asm
	push	ax
	push	bx
	push	ds

	cmp	ah,0
	jz	@@func0

	cmp	ah,1
	je	@@func0


	cmp	ah,10h
	je	@@func0

	cmp	ah,11h
	je	@@func0

@@bye:
	pop	ds
	pop	bx
	add	sp,2
	iret


@@func0:
	mov	ax,seg readkey
	mov	ds,ax

	xor	ah,ah		{-- clear scan code }
	mov	al,readkey
	cmp	al,128
	jb	@@okay

	xor	ax,ax
	jmp	@@bye

{-- Let's get value from table --}
@@okay:
	mov	bx,offset ascii_normal
	add	bx,ax
	mov	al,cs:[bx]
	jmp	@@bye

end;




{-----------------------------------------
				 timer routine
------------------------------------------
 It manages two timers.
	* timer
	* frame

 You can hook it, and you should take
 care of these two..
------------------------------------------}
procedure timer_int; far; assembler;
asm
	push	ax
	push	ds

	mov	al,20h		{-- send end-of-interrupt...	}
	out	20h,al		{-- to the interrupt controller }

	mov	ax,seg timerw
	mov	ds,ax

	inc	timerw
	inc	framew

	call	_proc1
	call	_proc2
	call	_proc3
	call	_proc4
	call	_speaker


	pop	ds
	pop	ax
	iret
end;




{ษออออออออออออออออออหออออออออออออออออออออออออออออออออออออออออออออออออออออออป
 บ x=JOYSTICK(what) บ Read joystick. (Stick 1:1=x,2=y), (Stick 2: 3=x,4=y) บ
 ศออออออออออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}
function joystick(what:byte) : word; assembler;
asm
	mov	bl,what
	mov	dx,201h
	xor	cx,cx

@@an1:
	in	al,dx
	test	al,bl
	jz 	@@an2

	dec	cx
	jnz 	@@an1

	xor	ax,ax
	jz  	@@bye

@@an2:
	out	dx,al
	xor	cx,cx

@@an3:
	in	al,dx
	test	al,bl
	jz 	@@an4
	dec	cx
	jnz 	@@an3

	xor	ax,ax
	jz 	@@bye

@@an4:	neg	cx
	mov	ax,cx

@@bye:
end;



{ษออออออออออออหอออออออออออออออออออออออป
 บ x=BUTTON() บ Read joysticks button บ
 ศออออออออออออสอออออออออออออออออออออออผ}
function button : byte; assembler;
asm
	mov     dx,0201h
	in      al,dx
	not     al
	xor     ah,ah
end;



{อออออออ ADAPTER CARDS INFORMATION อออออออออออออออออออออออออออออออออออ}


{ษอออออออออออออออออหออออออออออออออออออออออป
 บ x=which_video() บ Detect graphics card บ
 ศอออออออออออออออออสออออออออออออออออออออออผ}
function which_video : byte; assembler;
asm
	mov	ax,1A00h	{ Try calling "Read Display Codes" }
	int	10h
	cmp	al,1Ah		{ Status ok? }
	jne 	@@not_PS2	{ No! Video Card is old! }

	cmp	bl,0Ch		{ bl > 0Ch => CGA hardware }
	jg 	@@is_CGA	{ Jump if we have CGA }

	xor	bh,bh
	add	bx,offset @@PS2_CARDS
	mov	al,cs:[bx]	{ Load ax from PS/2 hardware table }
	jmp	@@bye

@@is_CGA:
	mov	ax,CGA		{ Have detected CGA, return id }
	jmp	@@bye

@@not_PS2:			{ OK We don't have PS/2 Video bios }
	mov	ah,12h		{ Set alternate function service }
	mov	bx,10h		{ Set to return EGA information }
	int	10h		{ call video service }
	cmp	bx,10h		{ Is EGA there ? }
	je 	@@simple_adapter	{ Nope! }
	mov	ah,12h			{ Since we have EGA bios, get info }
	mov	bl,10h
	int	10h
	or	bh,bh		{ Do we have color EGA ? }
	jz 	@@ega_color	{ Yes }
	mov	ax,EGAMONO	{ Otherwise we have Mono EGA }
	jmp	@@bye

@@ega_color:
	mov	ax,EGACOLOR	{ Have detected EGA Color, return id }
	jmp	@@bye

@@simple_adapter:
	int	11h		{ Let's try equipment determination service }
	and	al,30h

	mov	cl,4
	shr	al,cl
	xor	ah,ah
	or	al,al		{ Do we have any graphics card at all ? }
	jz 	@@done		{ No?? This is a stupid machine! }

	cmp	al,3		{ Do We have a Mono adapter }
	jne 	@@is_CGA	{ No }
	mov	ax,MDA		{ Have detected MDA, return id }
	jmp	@@bye

@@done:
	mov	ax,NONE
	jmp	@@bye

@@PS2_CARDS:	db	0,1,2,2,4,3,2,5,6,2,8,7,8,6,6

@@bye:
end;







{-----------------------------------
	Get values from memory pointers
----------------------------------}
{
function peekb(addr:pointer; adder:word) : byte; assembler;
asm
	les	bx,addr
	add	bx,adder
	mov	al,es:[bx]
end;

function peekw(addr:pointer; adder:word) : word; assembler;
asm
	les	bx,addr
	add	bx,adder
	mov	ax,es:[bx]
end;

}




{--------------------------
	Pointer segment/offset
---------------------------}
function ptrseg(buf:pointer):word; assembler;
asm
	les	ax,buf
	mov	ax,es
end;
function ptrofs(buf:pointer):word; assembler;
asm
	les	ax,buf
end;



{--------------------
	Check keyboard
---------------------}
procedure check_keyboard; assembler;
asm
	push	ds
	mov	ax,seg readkey
	mov	ds,ax

	mov	al,5
	mov	readkey,al

	pop	ds
end;



{---------------------
	Wait for keyboard
----------------------}
procedure wait_key; assembler;
asm
	push	ds
	mov	ax,SEG readkey
	mov	ds,ax

@@wait:
	cmp	readkey,128	{-- wait key press }
	jae	@@wait

@@wait2:
	cmp	readkey,128	{-- wait key release }
	jb	@@wait2

	pop	ds
end;



{------------------------------------------------------------------------
	dummyproc() || Dummy function
-------------------------------------------------------------------------}
procedure dummyproc; far; assembler;
asm
	retf
end;




{------------------------------------------------------------------------
	game_off() || Return stupid BIOS/DOS isr's and timer frequency
------------------------------------------------------------------------}
procedure game_off;
begin
 asm cli; end;
 timer_tick(0); 		{-- restore timer frequency }
 setvec(9,_oldkey);		{-- return keyboard interrupt }
 setvec(8,_oldtimer);		{-- return timer interrupt }
 {restore_clock; }			{-- read clock from CMOS   }
 setvec($16,_oldint16h);		{-- restore bios keyboard }
 key_leds((mem[0:$417] shr 4) and 7);	{-- Restore keyboard leds }
 asm sti; end;
end;



{-------------------------------------------------------------------------
	game_on() || Get back to life!!
--------------------------------------------------------------------------}
procedure game_on;
begin
 asm cli; end;
 timer_tick(_oldtick);		{-- Timer tick back to normal --}
 setvec(9,@key_int);		{-- Our keyboard ISR }
 setvec(8,@timer_int);		{-- Our own timer ISR }
 setvec($16,@bios16sim);	{-- Our Bios 16h emulator }
 key_leds(0);			{-- Kill leds again --}
 asm sti; end;
end;




{=========================================================================}

{ษออออออออหออออออออออออออออออออออออออออออออออออป
 บ main() บ Initialize keyboard vector routine บ
 ศออออออออสออออออออออออออออออออออออออออออออออออผ}
begin
 if (cpu_check=0) then
 begin
	 echo(#13#10'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'#13#10,15);
	 echo(#13#10'ณÝÛฒฑฐ Fatal error: 386 CPU or better required!'#13#10,15);
	 echo(#13#10'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'#13#10,15);
	 halt(255);
 end;


 readkey:=which_video;
 if (readkey<>VGACOLOR) and (readkey<>VGAMONO) then
 begin
	echo(#13#10'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'#13#10,15);
	echo(#13#10'ณÝÛฒฑฐ Fatal error: VGA/SVGA graphics adapter not detected!'#13#10,15);
	echo(#13#10'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'#13#10,15);
	halt(255);
 end;

{--- Let's check if we can access variables ok, bug in TP ---}
 check_keyboard;
 if (readkey<>5) then
 begin
	echo(#13#10'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'#13#10,15);
	echo(#13#10'ณÝÛฒฑฐ  Fatal error: Too many variables in Data Segment!'#13#10,15);
	echo(#13#10'ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'#13#10,15);
	halt(255);
 end;

{--- Save stack stuff ---}
 asm
	mov	_bp,bp
	mov	_sp,sp
	mov	_ss,ss
	mov	_ds,ds
	mov	_es,es
 end;


{--- Set timer routines ----}
 _proc1:=@dummyproc;
 _proc2:=@dummyproc;
 _proc3:=@dummyproc;
 _proc4:=@dummyproc;
 _speaker:=@dummyproc;

 _oldtick:=0;


{--- Get interrupt vetctors ---}
 _oldkey:=getvec(9);
 _oldtimer:=getvec(8);
 _oldint16h:=getvec($16);


{--- Initialize interrupts ---}
 clear_values;
 exitproc:=@key_cleanup;
 setvec(9,@key_int);
 setvec(8,@timer_int);
 setvec($16,@bios16sim);

 _lastmode:=biosgetmode;
 exitcode:=255;
 key_leds(0);
 _errormsg:='';
 asm sti; end;
end.
