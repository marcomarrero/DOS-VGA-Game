{A-,X-,F-,B-,T-,V-,G+,E-,I-,N-,O-,P-}
{$R-,Q-,S-}
{$D-,L-,Y-}
unit buffer;
interface

var
 buf : ^word;
 pic : ^byte;


 b_width  : word;
 b_heigth : word;

{----------------------------------------------------------------------}

implementation

var
 buf_dat  : array[0..63999] of byte;

procedure picture; external; {$L c:\mmedia\graph\picture.obj}

begin
 buf:=@b_width;
 pic:=@picture;
end.