{-----------------------
  VGA Hardware Library
------------------------}
{$A+,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}

unit vga_hard;
interface

const
INPUT_STATUS1	= $3da;
MISC_OUTPUT	= $3c2;
SC_INDEX	= $3c4;
CRTC_INDEX	= $3d4;
GRAPH_INDEX	= $3ce;
ATTR_INDEX	= $3c0;	{-- Don't forget clear flipflop & set bit 5 on index }
PEL_WRITE	= $3c8;
PEL_READ	= $3c7;
PEL_DATE	= $3c9;

MASK_PLANE1 = $00102;	{-- Map Register + Plane 1 }
MASK_PLANE2 = $01102;	{-- Map Register + Plane 1 }
ALL_PLANES  = $00F02;	{-- Map Register + All Bit Planes }
CHAIN4_OFF  = $00604;	{-- Chain 4 mode Off }
ASYNC_RESET = $00100;	{-- (A)synchronous Reset }
SEQU_RESTART= $00300;	{-- Sequencer Restart }

LATCHES_ON =$00008;	{-- Bit Mask + Data from Latches }
LATCHES_OFF=$0FF08;	{-- Bit Mask + Data from CPU }

procedure VGA_POS(x:word);
procedure VGA_PAN(pan:byte);
procedure VGA_PAN_C;
procedure VGA_WPLANE(plane:byte);
procedure VGA_RPLANE(plane:byte);
procedure VGA_WMODE(mode:byte);
procedure VGA_RMODE(mode:byte);
procedure VGA_SPLIT(scanline:word);
procedure VGA_VBLANK(start,ending:word);
procedure HSYNCH;
procedure VWAIT;
procedure VSYNCH(n:word);
procedure VSKIP;

procedure screen_off;
procedure screen_on;
procedure video_hirez;
procedure video_lorez;

procedure scan_height(value:byte);


{---------------------------------------------------------}
implementation

{$L vga_hard.obj}
procedure VGA_POS(x:word); external;
procedure VGA_PAN(pan:byte); external;
procedure VGA_PAN_C; external;
procedure VGA_WPLANE(plane:byte); external;
procedure VGA_RPLANE(plane:byte); external;
procedure VGA_WMODE(mode:byte); external;
procedure VGA_RMODE(mode:byte); external;
procedure VGA_SPLIT(scanline:word); external;
procedure VGA_VBLANK(start,ending:word); external;
procedure HSYNCH; external;
procedure VWAIT; external;
procedure VSYNCH(n:word); external;
procedure VSKIP; external;


procedure screen_off; external;
procedure screen_on; external;
procedure video_hirez; external;
procedure video_lorez; external;

procedure scan_height(value:byte); external;
begin
end.