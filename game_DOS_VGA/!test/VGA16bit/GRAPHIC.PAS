unit graphic;
interface

var
 pic : ^byte;

{----------------------------------------------------------------------}

implementation

procedure picture; external; {$L c:\game\graph\picture.obj}

begin
 pic:=@picture;
end.