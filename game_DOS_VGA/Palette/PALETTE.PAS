{$A+,B-,E-,F+,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{-------------------------------
  Palette unit - Turbo Pascal 7.0
-----------------------------------}
unit palette;


interface

type
 rgbpal = record
  r,g,b : byte;
 end;

 pal_type = array[0..255] of rgbpal;


procedure pal_entry(color,red,green,blue:byte);
procedure pal_set(which:pointer);
procedure pal_all(red,green,blue:byte);
procedure pal_fade(which:pointer; delay:word);
procedure pal_light(which:pointer; delay:word);
procedure pal_unfade(which:pointer; delay:word);
procedure pal_unlight(which:pointer; delay:word);
procedure pal_modify(delay:integer; which:pointer; r,g,b:integer);
procedure pal_work2pal(which:pointer);
procedure vga_pal16;
procedure pal_spread(r,g,b:word; pal:pointer; radd,gadd,badd:integer; start,ending:word);
procedure pal_copy(pal:pointer; starting,ending,upto:integer);
procedure pal_change(pal:pointer; r,g,b:integer; start,ending:integer);

implementation

{$l palette.obj}
procedure pal_entry(color,red,green,blue:byte); external;
procedure pal_set(which:pointer); external;
procedure pal_all(red,green,blue:byte); external;
procedure pal_fade(which:pointer; delay:word); external;
procedure pal_light(which:pointer; delay:word); external;
procedure pal_unfade(which:pointer; delay:word); external;
procedure pal_unlight(which:pointer; delay:word); external;
procedure pal_modify(delay:integer; which:pointer; r,g,b:integer); external;
procedure pal_work2pal(which:pointer); external;
procedure vga_pal16; external;
procedure pal_spread(r,g,b:word; pal:pointer; radd,gadd,badd:integer; start,ending:word); external;
procedure pal_copy(pal:pointer; starting,ending,upto:integer); external;
procedure pal_change(pal:pointer; r,g,b:integer; start,ending:integer); external;

begin
end.
