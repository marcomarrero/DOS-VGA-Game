{$A-,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$D+,L+,Y+}
{==============================================
  ModeX development set. (c) 1995 Marco Marrero
===============================================}
program x_develop;
uses game,vga_hard,modex,palette;
var x,y,x1,y1,i,j,k : integer;

{--------------------------------------------------------------------------}



{============================ MAIN =======================================}
begin
 modex_set(M320x200,360,480);
 xcls(1);

 for x:=0 to 359 do
 begin
  xpset(x,0,15);
  xpset(x,479,15);
  xpset(x,239,15);
 end;

 for y:=0 to 479 do
 begin
  xpset(0,y,15);
  xpset(359,y,15);
  xpset(179,y,15);
 end;

 i:=0;
 y:=0;
 repeat
  if (readkey=_left) then
  begin
   inc(i);
   if i>10 then i:=10;
   vsynch(0);
   vga_pos(i+y*90);
  end;

  if (readkey=_right) then
  begin
   dec(i);
   if i<0 then i:=0;
   vsynch(0);
   vga_pos(i+y*90);
 end;

  if (readkey=_up) then
  begin
   dec(y);
   if y<0 then y:=0;
   vsynch(0);
   vga_pos(i+y*90);
 end;

  if (readkey=_down) then
  begin
   inc(y);
   if y>40 then y:=40;
   vsynch(0);
   vga_pos(i+y*90);
 end;


 until (readkey=_space) or (readkey=_enter) or (readkey=_esc);

 modex_to_bios(3);
end.

