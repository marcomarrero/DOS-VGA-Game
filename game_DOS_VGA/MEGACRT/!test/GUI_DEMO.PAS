{---------------------------------
        msgbox demo
------------------------------}
uses megacrt,gui;

{----------------------------------------------------------------
  GUI.TPU ---
  msgbox(color_titulo,'titulo', color_texto,color_bordes,color_fondo,
         string_especial,botones_a_escojer).

  String especial:
  xs:='Hola | uno dos |!| Esto es para|^decir que| |';
      |  nueva     ! linea         ^ centra-    linea
         linea       con raya        lizado     blanco

  Los botones_a_escojer se el numero que devuelve la funcion en
  la variable de string_especial depende de los divisores.
  Devuelven los valores:
            '  Ok   | Cancel  | Retry ' ....
   Esc='0'    '1'      '2'       '3'    ....

  Cuando veas un numero menor de 16 dentro de un texto a imprimir,
  'Hola '#14'mundo' esto cambia el color al que pongas. Asi,
  pone 'Hola ' del color antes escojido y continua de color 14
  (amarillo).
-----------------------------------------------------------------}
var
 bs,cs : string;

begin
 color(red,green);
 cls('±');

 mouse_on;
 cursor_off;

 help('Dale a [Enter]/Usa el mouse. [Ctrl]+[flechas] o mouse mueve caja. ');
 bs:='^Matrimonio Femenino v1.00|!|^(c) 1995 DivorceSoft, Inc';
 msgbox(ltcyan,' About ',yellow,white,blue,bs,'   Ok   ');

 color(red,blue);
 mouse_hide;
 cls('±');
 mouse_show;

 repeat
  help('Escoje opci¢n del menu, y busca un juez. Est  en orden alfab‚tico.');
  bs:='^¨Con cual de los siguientes soletos te quieres casar ahora mismo?|!|^Escoje uno de los candidatos para la boda';
  msgbox(ltcyan,' Victima ',ltred,white,dkgray,bs,'  Angel  |  Juan  |  Marco  |  Mario  ');

  if bs='0' then
  begin
   help('Ser monja no est  permitido...');
   bs:=' | |        ¨¨¨¨Nadie?????        | | ';
   msgbox(ltred,' Jamona ',ltcyan,white,red,bs,' ¨Qu‚? ');
   bs:='0';
  end;
 until (bs<>'0');

 if bs='1' then cs:='Angel';
 if bs='2' then cs:='Juan';
 if bs='3' then cs:='Marco';
 if bs='4' then cs:='Mario';

 color(cyan,blue);
 mouse_hide;
 cls('±');
 mouse_show;

 help('Est s frita. Van a averiguar a quien escojiste.');
 bs:='^Estoy almacenando la informaci¢n escondida en tu hard disk|';
 bs:=bs+'para luego averiguar quien fu‚ el primero que decidiste.| |!| |';
 bs:=bs+'No intentes borrar el hard disk. No va a funcionar.|';
 bs:=bs+'Correrlo de nuevo no va a cambiar la informaci¢n.';
 msgbox(ltcyan,' Aviso ',white,yellow,blue,bs,' Jajajajaja ');

 color(green,blue);
 cls('±');

 help('¨Creiste eso? Lo PUDE haber hecho pero no soy tan malo.');
 bs:='| | |                         ­Broma!                         | | | |';
 msgbox(ltcyan,' Aviso ',white,yellow,black,bs,' Ok ');

 color(ltred,white);
 mouse_hide;
 cls(#3);
 mouse_show;

 help('Opini¢n...');
 bs:=' |!|Pero pens ndolo bien... ¨Con '#12+cs+#15'?|!| ';
 msgbox(ltcyan,' ­No lo puedo creer! ',white,yellow,red,bs,' Ok ');

 reset_screen;
end.



