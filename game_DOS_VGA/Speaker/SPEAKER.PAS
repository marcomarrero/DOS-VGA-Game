{$A-,B-,E-,F+,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
unit speaker;
interface
uses game;

var
 spk_flag	: WORD;		{-- 1=playing, 0=stop }
 spk_pos	: WORD;		{-- sample offset     }
 spk_wav	: POINTER;	{-- sample address     }
 spk_len	: WORD;		{-- sample length in bytes }
 spk_loop	: WORD;		{-- 1=loop, 0=no loop }


{$F+}
procedure spk_wave(addr:pointer; size:word);
procedure spk_start;
procedure spk_stop;
procedure spk_doloop;
procedure spk_noloop;
procedure spk_continue(where:word);
procedure spk_convert(what:pointer; size:word);

implementation


{$F+}
{$L speaker.obj}
procedure spk_wave(addr:pointer; size:word); external;
procedure spk_start; external;
procedure spk_stop; external;
procedure spk_doloop; external;
procedure spk_noloop; external;
procedure spk_continue(where:word); external;
procedure spk_convert(what:pointer; size:word); external;
procedure spk_play_isr; far; external;

begin
 asm cli; end;
 spk_flag:=0;
 spk_pos:=0;
 spk_loop:=0;
 _speaker:=@spk_play_isr;
 asm sti; end;
end.