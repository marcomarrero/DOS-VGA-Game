{$A+,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$D+,L+,Y+}
program mouse_sample;
uses mouse,crt;


begin
 textcolor(lightgray);
 textbackground(black);

 textmode(C80);		{-- pone modo texto a la ca¤ona }
 directvideo:=true;
 checksnow:=false;

 mouse_on;		{-- esta vivo! (si lo instalaste) }

 repeat
  mousek;		{-- leo coordenadas }

  if (moved>0) or (clicked>0) then	{-- te moviste o cambiaste?? }
  begin
   mouse_hide;		{-- voy a ensuciar la pantalla. Mouse, desaparece. }
   mx:=mx shr 3;
   my:=my shr 2;

   gotoxy(1,1);
   write('x=',mx,'  ');
   gotoxy(1,2);
   write('y=',my,'  ');
   gotoxy(1,3);
   write('k=',mk,'  ');
   mouse_show;		{-- recuerda siempre ponerlo visible }
  end;

 until (mk=3) or (keypressed);

{-- Deberias siempre hacer que el programa siempre salga por el teclado o
--- por el mouse porque uno unca sabe cuando vas a ver computadoras
--- definitivamente prehist¢ricas sin mouse. (Ejemplo: Olivetti en la Inter).
-----------------------------------------------------------------------------}
 clrscr;
 textmode(lastmode);
end.