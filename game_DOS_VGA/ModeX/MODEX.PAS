{----------------------------------
  ModeX Libary. (c) 1995 M.Marrero
-----------------------------------}
{$A-,B-,E-,F+,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}

unit modex;
interface

type
 x_struct = RECORD
  xP_WIDTH,xP_HEIGHT,xP_SIZE4,xP_WIDTH4,xL_WIDTH,xL_HEIGHT,xL_SIZE4,
  xL_WIDTH4,xPAGE,xPAGE1,xPAGE2,xPAGE3,xPAGE4:word;
 end;

const
 M320x200=0;  M320x240=1;  M360x200=2;  M360x240=3;  M376x282=4;
 M320x400=5;  M320x480=6;  M360x400=7;  M360x480=8;  M360x360=9;
 M376x308=10; M376x564=11; M256x240=12; M256x200=13; M256x154=15;
 M256x282=16; M256x70x=17;

InputStatus1=	$3da;
MISC_OUTPUT =	$3c2;
SC_Index    =	$3c4;
CRTC_Index  =	$3d4;
Graph_Index =	$3ce;
Attr_Index  =	$3c0; {-- Don't forget clear flipflop & set bit 5 on index}
PEL_Write   =	$3c8;
PEL_Read    =	$3c7;
PEL_Data    =	$3c9;

MASK_PLANE1	= $00102;	{-- Map Register + Plane 1 }
MASK_PLANE2	= $01102;	{-- Map Register + Plane 1 }
ALL_PLANES	= $00F02;	{-- Map Register + All Bit Planes }
CHAIN4_OFF	= $00604;	{-- Chain 4 mode Off }
ASYNC_RESET	= $00100;	{-- (A)synchronous Reset }
SEQU_RESTART	= $00300;	{-- Sequencer Restart }

LATCHES_ON	= $00008;	{-- Bit Mask + Data from Latches }
LATCHES_OFF	= $0FF08;	{-- Bit Mask + Data from CPU     }


procedure modex_set(mode,width,height:word);
procedure mode13_to_x;
procedure modex_to_13;
procedure modex_to_16;
procedure mode16_to_x;
procedure xclear(color:byte);
procedure xcls(color:byte);
procedure xpset(x,y:integer; color:byte);
procedure xpset4(x,y:integer; color:byte);
{ procedure xcopy(page1,page2:word); }
{ procedure xset_page(page:word); }
procedure x_getinfo(what:pointer);
procedure modex_to_bios(mode:word);
{==========================================================================}

implementation

{$L modex.obj}
procedure modex_set(mode,width,height:word); external;
procedure mode13_to_x; external;
procedure modex_to_13; external;
procedure modex_to_16; external;
procedure mode16_to_x; external;
procedure modex_to_bios(mode:word); external;

procedure xclear(color:byte); external;
procedure xcls(color:byte); external;
procedure xpset(x,y:integer; color:byte); external;
{ procedure xcopy(page1,page2:word); external; }

procedure xpset4(x,y:integer; color:byte); external;


{ procedure xset_page(page:word); external; }
procedure x_getinfo(what:pointer); external;



begin
end.