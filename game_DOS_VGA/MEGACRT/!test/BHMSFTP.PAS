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

{============================================================}
procedure AskClient;
begin
  Mouse_Hide;
  Color(white,Blue);
  TBoxFill(5,5,15,9,thickbox);
  ShadowBox(5,5,15,9);
  TColor(ltcyan);
  bs:='Client#';
  Print(7,5,bs);

  Color(yellow,black);
  Hline(7,7,12,' ',' ',' ');


  GotoXY(8,7);
  cursor_half;
  Help('Escribe el n£mero de cliente y oprime '#1'[Enter]'#0'.');
  Readln(client);
  Mouse_Show;
end;


{============================================================}
function IntToStr(i:integer) : string;
var c:string;
begin
  Str(i,c);
  IntToStr:=c;
end;


{============================================================}
procedure CheckError;
var ms:string;
    n:integer;
begin
 n:=IORESULT;
 if n<>0 then
 begin
   ms:=	'^**Bad News**|Un error de programaci¢n ha ocurrido|!|'+
	'I/O error #'+IntToStr(n);
   msgbox(white,' ERROR ',yellow,ltred,red,ms,'  Terminar  ');

   mouse_hide;
   put_screen(screen1);

   Halt(1);
 end;
end;


{==========================================================}
procedure Openfile;
begin
  mouse_hide;
  reset_screen;

  assign(txt,'..\data\auto.dat'); checkerror;
  rewrite(txt);	checkerror;
  writeln(txt,'telep'); checkerror;
  writeln(txt,'t3l3ph4r');
  writeln(txt,'bin');
  writeln(txt,'hash');
  writeln(txt,'lcd ..\data');
end;

{============================================================}
procedure CloseFile;
begin
  writeln(txt,'quit');
  Close(txt); checkerror;
end;

{============================================================}
procedure Catalogo;
begin
  OpenFile;
  writeln(txt,'cd /dsk/ob/telepharma');
  writeln(txt,'dir tp_catalog.txt');
  writeln(txt,'get tp_catalog.txt receive.dat');
  CloseFile;
end;

{============================================================}
procedure Prtback;
begin
  AskClient;
  OpenFile;
  writeln(txt,'cd /user/dsk1/echo');
  writeln(txt,'get ',client,'.prt');
  CloseFile;
end;

{============================================================}
procedure Acumulado;
begin
  AskClient;
  OpenFile;
  writeln(txt,'cd /user/dsk1_bmw/echo/echo'+client);
  writeln(txt,'get prtback.dat_acc ptrback.acc');
  CloseFile;
end;

{============================================================}
procedure TermLog;
begin
  AskClient;
  OpenFile;
  writeln(txt,'cd /user/usr7/echo'+client);
  writeln(txt,'get term.log');
  CloseFile;
end;

{*****************************************************************************}
begin
 color(blue,black);
 cls('±');

 get_screen(screen1);

 mouse_on;
 cursor_off;


 help('Dale a '#1'[Enter]'#0'/Usa el mouse. '#1'[Ctrl]+[flechas]'#0' o mouse mueve caja. ');
 bs:='Este programa obtiene data del sistema Unix atraves de FTP.       |'+
     '­Es recomendado que tengas much espacio de disco libre!|!|'+
     'Selecciona una de los siguientes:';
 msgbox(ltgreen,' Borschow FTP Utility ',yellow,white,blue,bs,'Catalogo|Prtback|Acumulado|TermLog|Cancel');

 if (bs='0') or (bs='5') then
 begin
  mouse_hide;
  put_screen(screen1);
  halt(1);
 end;


 if bs='1' then Catalogo
 else if bs='2' then PrtBack
 else if bs='3' then Acumulado
 else TermLog;

  mouse_hide;
  put_screen(screen1);
end.



