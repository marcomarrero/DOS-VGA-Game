{$g+,a-}
program display_marco;
uses vga;

procedure picture; external; {$L c:\mmedia\graph\picture.obj}


begin
 mode($13);
 read_pcx(@picture);
 readln;
 mode($3);
end.