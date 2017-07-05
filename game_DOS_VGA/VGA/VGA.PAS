{$A+,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{-------------------------------
  VGA unit - Turbo Pascal 7.0
-------------------------------}
unit vga;


interface
const
 vgascreen : pointer = ptr($a000,0000);


procedure vga_pal(color,r,g,b:byte);
procedure mode(which:word);
procedure vga_synch(num:word);

procedure vga_addr(where:pointer);
procedure getscreen(where:pointer);
procedure putscreen(where:pointer);
procedure vgaputscreen(where:pointer);

function read_pcx(image:pointer; pal:pointer) : byte;

procedure put(x,y:integer; what:pointer);
procedure get(x,y,x1,y1:integer; what:pointer);
procedure cput(x,y:integer; what:pointer);
procedure cpaste(x,y:integer; what:pointer);
procedure cpasteadd(x,y:integer; what:pointer);

procedure cls(color:byte);
procedure pset(x,y:integer; color:byte);
function  point(x,y:integer) : byte;
procedure boxfill(x,y,x1,y1:integer; color:byte);
procedure boxfilladd(x,y,x1,y1:integer; adder:byte);
procedure line(x,y,x1,y1:integer; color:word);
procedure drawto(x,y,x1,y1:integer; color:word);
procedure hline(x,y,x1:integer; color:byte);
procedure vline(x,y,y1:integer; color:byte);
procedure box(x,y,x1,y1:integer; color:word);



{--------------------------------------------------------------------}
implementation

{$L VGA.OBJ}
procedure vga_pal(color,r,g,b:byte); external;
procedure mode(which:word); external;
procedure vga_synch(num:word); external;

procedure vga_addr(where:pointer); external;
procedure getscreen(where:pointer); external;
procedure putscreen(where:pointer); external;
procedure vgaputscreen(where:pointer); external;

function read_pcx(image:pointer; pal:pointer) : byte; external;

procedure put(x,y:integer; what:pointer); external;
procedure get(x,y,x1,y1:integer; what:pointer); external;
procedure cput(x,y:integer; what:pointer); external;
procedure cpaste(x,y:integer; what:pointer); external;
procedure cpasteadd(x,y:integer; what:pointer); external;

procedure cls(color:byte); external;
procedure pset(x,y:integer; color:byte); external;
function  point(x,y:integer) : byte; external;
procedure boxfill(x,y,x1,y1:integer; color:byte); external;
procedure boxfilladd(x,y,x1,y1:integer; adder:byte); external;
procedure line(x,y,x1,y1:integer; color:word);  external;
procedure drawto(x,y,x1,y1:integer; color:word);  external;
procedure hline(x,y,x1:integer; color:byte);  external;
procedure vline(x,y,y1:integer; color:byte);  external;
procedure box(x,y,x1,y1:integer; color:word);  external;


begin
end.
