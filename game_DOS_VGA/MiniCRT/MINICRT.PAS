{-------------------------
     MiniCRT Unit
-------------------------}
{$A-,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}

unit minicrt;
interface
procedure MINICRT_INIT;
procedure CRT_CHAR(x,y:integer; cha:char; color:byte);
procedure CRT_LINEX(x,y,x1:integer; cha:char; color:byte);
procedure CRT_LINEY(x,y,y1:integer; cha:char; color:byte);
procedure CRT_SHADEX(x,y,x1:integer);
procedure CRT_SHADEY(x,y,y1:integer);
procedure CRT_PRINT(x,y:integer; txt:pointer; color:byte);
procedure CRT_PCOPY(upto,from:word);
function  CRT_READKEY : integer;
procedure CRT_ECHO(txt:pointer);
procedure CRT_BOXFILL(x,y,x1,y1,color:integer);

implementation
{$L minicrt.obj}
{$F+}
procedure MINICRT_INIT; external;
procedure CRT_CHAR(x,y:integer; cha:char; color:byte); external;
procedure CRT_LINEX(x,y,x1:integer; cha:char; color:byte); external;
procedure CRT_LINEY(x,y,y1:integer; cha:char; color:byte); external;
procedure CRT_SHADEX(x,y,x1:integer); external;
procedure CRT_SHADEY(x,y,y1:integer); external;
procedure CRT_PRINT(x,y:integer; txt:pointer; color:byte); external;
procedure CRT_PCOPY(upto,from:word); external;
function  CRT_READKEY : integer; external;
procedure CRT_ECHO(txt:pointer); external;
procedure CRT_BOXFILL(x,y,x1,y1,color:integer); external;

begin
 minicrt_init;
end.
