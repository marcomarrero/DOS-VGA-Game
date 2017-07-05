
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
