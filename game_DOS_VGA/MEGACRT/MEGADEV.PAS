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
writeln('  ��      ��                                 ������   �������  �������� ');
writeln('  ���     ��                                ��    ��  ��    ��    ��    ');
textcolor(cyan);
writeln('  ����  ����   ������    �����    �����     ��        ��    ��    ��    ');
writeln('  ����  ����  ��    ��  ��   ��  ��   ��    ��        ������      ��    ');
textcolor(lightblue);
writeln('  �� ���� ��  �������   ��   ��  ��   ��    ��        ��   ��     ��    ');
writeln('  ��  ��  ��  ��         ������  ��   ��    ��    ��  ��    ��    ��    ');
textcolor(blue);
writeln('  ��      ��   ������        ��   ����� ��   ������   ��    ��    ��    ');
writeln('                         �����                                          ');
writeln;
textcolor(white);
writeln('  ����   � ��� ��� ��   �   �  �  ��   �  �     �   �  �  ��  ��  �� ��   � ');
textcolor(yellow);
writeln(' � �� �  � � � � � �    �� �� � � � � �  � �    �� �� � � � � � � �  � � � �');
textcolor(lightred);
writeln(' � �  �  � ��� ��� ��   � � � ��� ��  �  � �    � � � ��� ��  ��  �� ��  � �');
textcolor(brown);
writeln(' � �� �  �   �   �  �   � � � � � � � �  � �    � � � � � � � � � �  � � � �');
textcolor(red);
writeln('  ����   �   �   � ��   �   � � � � �  �  �     �   � � � � � � � �� � �  � ');
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