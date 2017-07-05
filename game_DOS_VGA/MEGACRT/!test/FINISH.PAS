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
 bs,cs  : string;
 txt    : text;
 client : string;


{*****************************************************************************}
begin
 get_screen(screen1);

 {color(red,blue);
  cls('±');}

 mouse_on;
 cursor_off;

 help('Dale a '#1'[Enter]'#0'/Usa el mouse. '#1'[Ctrl]+[flechas]'#0' o mouse mueve caja. ');
 bs:='  Fin  ';
 msgbox(ltgreen,' Batch ',yellow,white,blue,bs,' Ok ');

 mouse_hide;
 put_screen(screen1);
end.



