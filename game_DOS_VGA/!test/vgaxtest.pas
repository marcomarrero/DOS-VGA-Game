{$A+,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$D+,L+,Y+}
program vgaxtest;	{-- modex development and testing...}
uses game, modex, vga, mouse, vga_hard;
{ game.inc  }
{ modex.inc }
{ vga.inc   }


var x,y,z: integer;

begin
 modex_set(M360x200,360,200);
 xcls(0);

 mouse_on;
 mouse_hide;

 for x:=0 to 1000 do
  xpset(random(640),random(200),random(16));

 repeat
  mousek;
  if (moved=0) then
  begin
   vsynch(0);
   vga_pos(my*(640 div 4)+(mx div 4));
   if (mx mod 2)=2 then vga_pan(mx mod 4);
  end;
 until (readkey<>0);


 mode(3);
end.
