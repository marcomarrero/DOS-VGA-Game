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

 help('Oprima '#1'[Enter]'#2' para continuar...');

 {-- caja con mensaje y botones --}

 bs:=   '­EL SISTEMA HA DETECTADO QUE LA COMPUTADORA FUE APAGADA|';
 bs:=bs+'O REINICIALIZADA MIENTRAS WINDOWS ESTABA CORRIENDO!|!|';
 bs:=bs+'Esto puede causar que la data de disco se corrompa y|';
 bs:=bs+'traiga problemas con TelePharma y/o RxExpress';
 msgbox(ltcyan,' Mensaje - 1/2 ',white,yellow,red,bs,'   Continuar   ');

 bs:=   'Para poder apagar la computadora, primero se debe salir|';
 bs:=bs+'de RxExpress, TelePharma y el Windows Journal.|';
 bs:=bs+'Luego en el Program Manager, en el men£ seleccionar|';
 bs:=bs+'File y Exit Windows.';
 msgbox(ltcyan,' Mensaje - 2/2 ',white,yellow,red,bs,'   Entendido   ');

 mouse_hide;
 put_screen(SCREEN1);
 cursor_small;
 halt(0);
end.