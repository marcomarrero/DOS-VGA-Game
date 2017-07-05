program digiplay;
uses game;


var
 spk_flag	: word;
 spk_pos	: word;
 spk_wav	: pointer;
 spk_len	: word;
 spk_loop	: word;

 hz:word;


{-----------------------------------------------------------------------
  spk_wave(addr:pointer,size:word) || Sets digital waveform
-----------------------------------------------------------------------}
procedure spk_wave(addr:pointer; size:word);
begin
asm  cli
end;
 spk_wav:=addr;
 spk_len:=size;
 spk_pos:=0;
 spk_flag:=0;
asm  sti
end;
end;



{------------------------------------------------------------------------
  spk_start() | Starts playing wave
------------------------------------------------------------------------}
procedure spk_start;
begin
asm  cli
end;
 spk_pos:=0;
 spk_flag:=1;
asm  sti
end;
end;



{------------------------------------------------------------------------
  spk_stop() | Stops playing wave
------------------------------------------------------------------------}
procedure spk_stop;
begin
 spk_flag:=0;
end;



{-----------------------------------------------------------------------
  spk_loop() | Sets sound to loop continuously
------------------------------------------------------------------------}
procedure spk_doloop;
begin
 spk_loop:=1;
end;



{-----------------------------------------------------------------------
  spk_noloop() | Sets sound to NOT loop continuously
------------------------------------------------------------------------}
procedure spk_noloop;
begin
 spk_loop:=0;
end;



{------------------------------------------------------------------------
  spk_continue(pos:word) | Continues playing wave at position. 0=resume
-------------------------------------------------------------------------}
procedure spk_continue(pos:word);
begin
asm  cli
end;
 if pos>0 then spk_pos:=pos;
 spk_flag:=1;
asm sti
end;
end;



{-------------------------------------------------------------------------
  interrupt function
--------------------------------------------------------------------------}
procedure spk_play_isr; far; assembler;
asm
	xor	si,si		{-- fast zero constant --}
	mov	di,1		{-- fast 1 constant --}

	mov	ax,seg spk_wav  {-- get current data segment --}
	mov	ds,ax

	cmp	spk_flag,di	{-- if flag=1, play wave... --}
	jne	@@bye


	les	bx,spk_wav	{-- get waveform address --}
	mov	cx,spk_pos	{-- get position of sound --}
	cmp	cx,spk_len	{-- past end?? --}
	jne	@@play		{-- if not, keep playing --}

@@fix:
	cmp	spk_loop,di	{-- if looping, don't stop sound --}
	je	@@fix2
	mov	spk_flag,si	{-- stop! --}
	mov	spk_pos,si
	jmp	@@bye

@@fix2:
	mov	spk_pos,si	{-- only clear starting point --}
	xor	cx,cx



@@play:
	add	bx,cx		{-- get sample offset --}
	mov	al,[es:bx]	{-- get waveform value --}
	inc	spk_pos		{-- increment position --}

	mov	dx,$61		{-- send output to speaker --}
	out	dx,al
@@bye:
end;



{------------------------------------------------------------------------
  Convert 8-bit digital values to 1-bit sound...
-------------------------------------------------------------------------}
procedure spk_convert(what:pointer; len:word); assembler;
asm
	push	ds
	push	si
	push	di

	lds	si,what
	les	di,what

	mov	cx,len

@@doit:
	lodsb
	cmp	al,128
	ja	@@one
	xor	al,al
	stosb
	loop	@@doit
	jmp	@@bye

@@one:
	mov	al,2
	stosb

@@count:
	loop	@@doit

@@bye:
	pop	di
	pop	si
	pop	ds

end;




{-------------------------------------------------------------------------}
{$l c:\data\pas\game\experim\ryu.obj} { 9998 bytes }
procedure ryu; external;




begin
 bioscls($07);
 biosgotoxy(0,0);
 echo('Speaker unit v1.00.00'#13#10,$07);
 echo('DigiPlay (c) 1995 Marco A. Marrero'#13#10#10,$07);
 echo('Press [Enter] to play sound'#13#10,$07);
 echo('Press [Esc] to quit'#13#10,$07);

 val(paramstr(1),hz,spk_pos);
 spk_flag:=0;
 spk_pos:=0;
 spk_loop:=0;

 asm cli; end;
 _proc5:=@spk_play_isr;
 asm sti; end;

 spk_wave(@ryu,9998);
 spk_convert(@ryu,9998);

 echo('Frequency: ',$07);
 echonum(hz,$0e);
 echo(#13#10#10,$07);
 timer_tick(hz);


 repeat
  if (readkey=_enter) and (spk_flag=0) then
  begin
   spk_start;
  end;

  if (spk_pos=1) then
  begin
   echo('.',$9);
  end;

 until (readkey=_esc);
 timer_tick(0);
end.

