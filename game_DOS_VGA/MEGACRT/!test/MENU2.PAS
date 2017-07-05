{A+,X-,F-,B-,T-,V-,G+,E-,I-,N-,O-,P-}
{$R-,Q-,S-}
{$D-,L-,Y-}

uses megacrt,gui;

{A+,X-,F-,B-,T-,V-,G+,E-,I-,N-,O-,P-}
{$R-,Q-,S-}

var
 xs,bs : string;

begin
 cursor_off;            {-- adios cursor }
 mouse_on;              {-- ahora si hay mouse... }

 mouse_hide;            {-- Evitar que Get_screen capture el mouse... }
 get_screen(SCREEN1);
 mouse_show;

 {-- informacion al usuario --}

 help('Men£ Barato v1.21                '#1'Programado por Marco A. Marrero');

 {-- caja con mensaje y botones --}

 bs:=   '^Bienvenido al c‚ntro de c¢mputos|  |';
 bs:=bs+'^¨Qu‚ tipo de cuenta te asignaron en el sistema?';

 msgbox(ltcyan,' Men£ ',white,yellow,dkgray,bs,
               '   Aplicaciones   |     Lenguaje     ');


 {--- msgbox siempre limpia la pantalla... --- }

 if bs='0' then      {-- usuario oprimio [Esc] }
 begin
  mouse_hide;
  put_screen(SCREEN1);
  cursor_small;
  halt(0);
 end;

 {-- caja con mensaje y botones --}

 xs:='Por favor dime donde tu est s ahora mismo|para poder subir los drivers de redes correctos.';


 msgbox(ltcyan,' Men£ ',yellow,white,blue,xs,
        '  Pasillo  |   Sal¢n   |   No s‚   ');

 {-- vamos a poner la pantalla como estaba al principio }

 {-- vamos a regresar el valor del boton como un "error" }

 mouse_hide;
 put_screen(SCREEN1);
 cursor_small;

{---- Devuelvo: ---------------------
No se, 0
Aplicaciones 1=pasillo, 2=salon
Salon 3=pasillo, 4=salon
-----------------------------------}


 if (xs='0') or (xs='3') then halt(0);          {-- [esc] o "No se" }

 if bs='1' then                                 {-- Aplicaciones }
 begin
  if xs='1' then halt(1) else halt(2);
 end
 else
 begin
  if xs='1' then halt(3) else halt(4);
 end;

 {-- para saber que error regresa un programa dentro de turbo,
     busca en el menu  Compile | Information... }

end.