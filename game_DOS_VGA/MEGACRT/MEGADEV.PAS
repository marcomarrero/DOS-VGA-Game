uses megacrt,crt;
var
 i,x,y : integer;
 mar : file of byte;
 bb : byte;

procedure clir(what:pointer); assembler;
asm
        les     bx,what
        mov     cx,8192
        xor     ax,ax
@@sto:
        mov     es:[bx],al
        inc     bx
        loop    @@sto
end;


function value(what:pointer; add:integer) : byte; assembler;
asm
        les     bx,what
        add     bx,add
        mov     al,es:[bx]
end;


begin
 color(white,black);
 cls(' ');
textbackground(black);
textcolor(lightcyan);
writeln('  лл      лл                                 лллллл   ллллллл  лллллллл ');
writeln('  ллл     лл                                лл    лл  лл    лл    лл    ');
textcolor(cyan);
writeln('  лллл  лллл   лллллл    ллллл    ллллл     лл        лл    лл    лл    ');
writeln('  лллл  лллл  лл    лл  лл   лл  лл   лл    лл        лллллл      лл    ');
textcolor(lightblue);
writeln('  лл лллл лл  ллллллл   лл   лл  лл   лл    лл        лл   лл     лл    ');
writeln('  лл  лл  лл  лл         лллллл  лл   лл    лл    лл  лл    лл    лл    ');
textcolor(blue);
writeln('  лл      лл   лллллл        лл   ллллл лл   лллллл   лл    лл    лл    ');
writeln('                         ллллл                                          ');
writeln;
textcolor(white);
writeln('  лллл   л ллл ллл лл   л   л  л  лл   л  л     л   л  л  лл  лл  лл лл   л ');
textcolor(yellow);
writeln(' л лл л  л л л л л л    лл лл л л л л л  л л    лл лл л л л л л л л  л л л л');
textcolor(lightred);
writeln(' л л  л  л ллл ллл лл   л л л ллл лл  л  л л    л л л ллл лл  лл  лл лл  л л');
textcolor(brown);
writeln(' л лл л  л   л   л  л   л л л л л л л л  л л    л л л л л л л л л л  л л л л');
textcolor(red);
writeln('  лллл   л   л   л лл   л   л л л л л  л  л     л   л л л л л л л лл л л  л ');
writeln('                                                                            ');
writeln;
writeln;
writeln;


clir(screen1);
get_screen(screen1);
assign(mar,'c:\game\crtlogo.bin');
rewrite(mar);
for i:=0 to 8191 do
begin
 bb:=value(screen1,i);
 write(mar,bb);
end;
close(mar);

end.