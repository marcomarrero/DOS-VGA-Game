{ .----------------------------.
  |      Alert Unit v1.0á      |
  |----------------------------|
  |      Revision 6/24/94      |
  |============================|
  | (c) 1994 Marco A. Marrero  |
  `----------------------------'  }

{A+,X+,F+,R-,B-,T-,V-,G+,Y-,E-,I-,N-,O-,P-,Q-,S-}
{$D-,L-}
unit GUI;
interface
uses megacrt;
procedure MsgBox(colm:byte; mess:string; text,bord,back:byte ; var bs:string; cs:string);


implementation
var
 x,y,x1,y1,x2,y2   : integer;
 but_n,but_l,but_x : integer;
 i,f               : integer;
 button            : array[1..16] of byte;
 ms                : string;                    {-- temp. }
 selected,redraw   : integer;                   {-- button & dialog  }
 grab,lx,ly        : integer;

procedure MsgBox(colm:byte; mess:string; text,bord,back:byte ; var bs:string; cs:string);
begin
 bs:='|'+bs+'||';
 cs:=cs+'|';

 mouse_hide;
 get_screen(screen4);
 mouse_show;

 {--- first I will scan the string to determine maximum size }
 {--- x=counter, x1=longest, y1=# of lines }
 x1:=0; y1:=0; x:=0; y:=0;

 for i:=2 to ord(bs[0]) do
 begin
  if bs[i]<>'|' then
   x:=x+1
  else
  begin
   if bs[i-1]<>'|' then y1:=y1+1;
   if x1<x then x1:=x-1;
   x:=0;
  end;
 end;


  {---- Now, calculate the center of the screen }

  x:=(cols shr 1)-(x1 shr 1);
  y:=(rows shr 1)-(y1 shr 1);


  {---- Calculate button information }
  if cs='' then
  begin
   but_n:=0
  end
  else
  begin
   but_x:=0;
   y1:=y1+2;
   but_n:=0;
   but_l:=6;

   for i:=1 to ord(cs[0]) do
   begin
    if cs[i]='|' then
    begin
     but_n:=but_n+1;
     button[but_n]:=but_x;
     but_x:=but_x+but_l;
     but_l:=6;
    end
    else
    begin
     but_l:=but_l+1;
    end;
   end;

  end;
  button[but_n+1]:=but_x;
  but_x:=but_x-but_l+3;

 {--------- Main redraw ---- }

 grab:=0;
 repeat

  mouse_hide;

  if grab=1 then
  begin
   vsynch;
   put_screen(screen4);
   lx:=mx;
   ly:=my;
  end;

  {--- Draw header line }
  color(bord,back);
  tboxfill(x-3,y-2,x1+x+3,y1+y+1,thickbox);
  shadowbox(x-3,y-2,x1+x+3,y1+y+1);

  {--- Draw title bar }
  tcolor(colm);
  i:=(x1 shr 1)-(ord(mess[0]) shr 1);
  print(x+i,y-2,mess);

  {--- Draw information }
  tcolor(text);
  x2:=2;
  y2:=y;
  for i:=2 to ord(bs[0]) do
  begin
   if bs[i]='|' then
   begin
    ms:=copy(bs,x2,i-x2);

    if ms[1]='^' then             {-- Center }
    begin
     ms[1]:=' ';
     print(x+(x1 shr 1)-(ord(ms[0]) shr 1),y2,ms);
    end
    else if ms[1]='!' then        {-- divider }
    begin
     tcolor(bord);
     hline(x-3,y2,x+x1+3,'Ç','Ä','¶');
     tcolor(text);
    end
    else
     print(x,y2,ms);

    y2:=y2+1;
    x2:=i+1;
   end;
  end;
  selected:=1;

  {----- Will use the mouse / keyboard to change info. }
  mouse_show;
  redraw:=1;

  {------------- Main loop --------------- }
  repeat
   readkey;
   mousek;

   {---- Check keyboard commands ---- }
    if (ekey=right) or (key=tab) then
    begin
     selected:=selected+1;
     if selected > but_n then selected:=1;
     if but_n>1 then redraw:=1;
    end

    else if (ekey=left) then
    begin
     selected:=selected-1;
     if selected < 1 then selected:=but_n;
     if but_n>1 then redraw:=1;
    end;

   {---- Mouse operations }
   if mk=0 then grab:=0
   else if (mk=1) and (lx<>mx) or (ly<>my) then
   begin
    if (mx<x-3) or (mx>x1+x+3) or (my<y) or (my>y1+y+1) then
     begin
      grab:=1;           {-- You clicked outside of the window! }
      key:=#254;
     end;
   end;

   if (ekey=#141) or (ekey=#116) or (ekey=#115) or (ekey=#145) then
   begin
    grab:=1;
    key:=#254;
    output:=4000;
   end;

   f:=(x+x1)-but_x;                                     {-- Check buttn }
   for i:=1 to but_n do
   begin

    if (my=y+y1-1) then
    if (mx>=f+button[i]) and (mx<f+button[i+1]-2) then
    begin
     grab:=0;
     if mk=1 then key:=Enter;
     if selected<>i then
     begin
      selected:=i;
      redraw:=1;
     end;
    end;
   end;


   {------ Redraw buttons ---- }
   if (redraw=1) or (key=Enter) or (key=#255) then
   begin
    redraw:=0;
    f:=(x+x1)-but_x;
    x2:=1;
    y2:=1;
    mouse_hide;
    for i:=1 to ord(cs[0]) do
    begin
     if cs[i]='|' then
     begin

      ms:='  '+copy(cs,x2,i-x2)+'  ';
      x2:=i+1;

      if ((key=enter) or (key=#255)) and (selected=y2) then
      begin
       syscolor:=$0B;
       print(f+button[y2]+1,y+y1-1,ms);
       color(back,back);
       hline(f+button[y2]+1,y+y1,f+button[y2+1]-2,'ß','ß','ß');
       out_char(f+button[y2],y+y1-1,'Ü');
      end
      else
      begin
       if selected=y2 then syscolor:=$3f else syscolor:=$30;
       print(f+button[y2],y+y1-1,ms);
       color(black,back);
       hline(f+button[y2]+1,y+y1,f+button[y2+1]-2,'ß','ß','ß');
       out_char(f+button[y2+1]-2,y+y1-1,'Ü');
      end;

      y2:=y2+1;
     end;
    end; {f}
    mouse_show;
   end;

  until (key=enter) or (key=esc) or (key=#254);

 if output=4000 then
 begin
  if ekey=#141 then y:=y-1;
  if ekey=#145 then y:=y+1;
  if ekey=#115 then x:=x-1;
  if ekey=#116 then x:=x+1;
  output:=0;
 end
 else
 begin
  x:=mx-2;
  y:=my+2;
 end;

 until (key=enter) or (key=esc);
 if key=enter then bs:=chr(selected+48) else bs:='0';
 mouse_wait;
 mouse_hide;
 put_screen(screen4);
 mouse_show;
end;

begin
end.