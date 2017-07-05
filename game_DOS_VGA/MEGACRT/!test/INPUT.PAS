program input;

uses megacrt;

var
 output2 : integer;
 insert  : boolean;
 bs	 : string;


{-------------------------------------
  BLANK() | Pads a string with spaces
--------------------------------------}
procedure blank(var bs:string; num:integer); assembler;
asm
	les	di,bs
	mov	ax,2020h

	mov	cx,num
	shl	cx,1
	rep	stosw
	adc	cx,cx
	rep	stosb
end;


{-----------------------------------------------
  remove_trailing(var bs:string)
------------------------------------------------}
PROCEDURE Remove_Spaces(VAR Bs:STRING);
VAR x:INTEGER;
BEGIN
 IF Bs<>'' THEN
 BEGIN
  x:=LENGTH(Bs)+1;
  REPEAT
   x:=x-1;
  UNTIL (Bs[x]<>' ') OR (x=0);
  IF x>=1 THEN
  BEGIN
   Bs[0]:=CHR(x);
  END
  ELSE
  BEGIN
   Bs:='Nil';
  END;
 END;
END;



{------------------------------------------
  CLIP_PRINT() | don't use it, please.
-------------------------------------------}
PROCEDURE clip_print(Atxt,Abkg,finish: WORD; VAR Bs:STRING ; Offs,x,y,x1:BYTE);
VAR i,f	: WORD;
    More: BOOLEAN;
BEGIN
 i:=x+1;
 IF offs>1 THEN
 begin
  tcolor(atxt+128);
  out_char(x,y,CHR(17));
  tcolor(atxt);
 end
 else
  Out_Char(x,y,' ');
 for i:=x+1 TO x1 DO
 begin
  IF Offs>Finish THEN
   Out_Char(i,y,' ')
  ELSE
   Out_Char(i,y,Bs[Offs]);
  Offs:=Offs+1;
 END;
 More:=FALSE;
 f:=Offs-1;
 WHILE f<=Finish DO
 BEGIN
  IF Bs[f]<>' ' THEN
  BEGIN
   More:=TRUE;
   f:=Finish;
  END;
  f:=f+1;
 END;
 IF (Offs-2<Finish) AND (More=TRUE) THEN
 begin
  tcolor(atxt+128);
  Out_Char(i,y,CHR(16));
  tcolor(atxt);
 end
 ELSE
   Out_Char(i,y,' ');
 IF (Offs-2=Finish) THEN
   Output2:=255;
END;



{-------------------------------------------------------------------------
  INPUT.PAS - Explicacion:
 -------------------------

  En el parametro Comm estos son los BITS.

  1    = Salir con flecha Arriba/Abajo (resultado en variable "Output")
  2    = Espacios permitidos (32)
  4    = Solo Mayusculas
  8    = Solo Minuculas
  16   = Numeros (0-9)
  32   = Numeros y punto decimal
  64   = Path characters ( $ * \ .   Bits 4,16 DEBEN ESTAR SELECCIONADOS!)
  128  = Extended characters ( > 127)
  256  = Low ASCII ( < 32 )
  512  = Math ( + - * / = )
  1024 = Punctuation (33-47 and 58-64 and 91-96 and 123-126 )
  2048 = Esc permite salir
  4096 = PgUp/PgDn Permite salir
  8192 = Tab permite salir

  Ejemplos:
  Path=84 / Normkey=1054 / Anykey=1438

 Comm      : Caracteres permitidos
 Offs      : En que lugar del String el cursor va a aparecer
 Len       : Tama¤o del STRING
 x,y,x1    : Tama¤o de la caja donde va el texto
 Atxt,Abkg : Colores
---------------------------------------------------------------------------}

PROCEDURE ReadLn(Comm,Offs : WORD ; VAR Bs:STRING ; Len,x,y,x1,Atxt,Abkg:WORD);
VAR Exit,UpDown,Tab,Upperc,
    Lowerc,Num,Floa,
    Path,Extend,Low,
    Math,Punct,Esc,
    Pgmov,Spac		: BOOLEAN;
    x2,Where,i,f,
    Pressed		: WORD;
BEGIN
 UpDown:=FALSE;
 Tab:=FALSE;
 Upperc:=FALSE;
 Lowerc:=FALSE;
 Num:=FALSE;
 Floa:=FALSE;
 Path:=FALSE;
 Extend:=FALSE;
 Low:=FALSE;
 Math:=FALSE;
 Punct:=FALSE;
 Esc:=FALSE;
 PgMov:=FALSE;
 Spac:=FALSE;
 Exit:=FALSE;

 IF Insert=TRUE THEN
   Cursor_Small
 ELSE
   Cursor_Big;
 IF (Comm AND 1)=1 THEN
   UpDown:=TRUE;
 IF (Comm AND 2)=2 THEN
   Spac:=TRUE;
 IF (Comm AND 4)=4 THEN
   Upperc:=TRUE;
 IF (Comm AND 8)=8 THEN
   Lowerc:=TRUE;
 IF (Comm AND 16)=16 THEN
   Num:=TRUE;
 IF (Comm AND 32)=32 THEN
   Floa:=TRUE;
 IF (Comm AND 64)=64 THEN
   Path:=TRUE;
 IF (Comm AND 128)=128 THEN
   Extend:=TRUE;
 IF (Comm AND 256)=256 THEN
   Low:=TRUE;
 IF (Comm AND 512)=512 THEN
   Math:=TRUE;
 IF (Comm AND 1024)=1024 THEN
   Punct:=TRUE;
 IF (Comm AND 2048)=2048 THEN
   Esc:=TRUE;
 IF (Comm AND 4096)=4096 THEN
   Pgmov:=TRUE;
 IF (Comm AND 8192)=8192 THEN
   Spac:=TRUE;
 x2:=x+1;

 REPEAT
  Mouse_hide;
  clip_print(Atxt,Abkg,Len,Bs,Offs,x,y,x1);
  Mouse_show;
  gotoxy(x2,y);
  Where:=(Offs-1)+(x2-x);
  IF Where>Len THEN
  BEGIN
   x2:=x2-1;
   IF (x2<x+1) THEN
   BEGIN
    x2:=x+1;
    Offs:=Offs-1;
    IF Offs<1 THEN
    BEGIN
     Offs:=1;
     x2:=x+1;
    END;
   END;
   gotoxy(x2,y);
   Where:=(Offs-1)+(x2-x);
  END;
  Pressed:=0;
  REPEAT
   Readkey;
   Mousek;
  UNTIL (ord(Key)+ord(ekey)<>0) OR (Mk=1);

  IF (Mouse=65535) AND (Mk=1) AND (My=y) THEN
  BEGIN
   IF (Mx>x) AND (Mx<x1) THEN
   BEGIN
    IF (Offs-1)+(Mx-x)<=Len THEN
    BEGIN
     x2:=Mx;
     Mouse_wait;
    END;
   END
   ELSE IF Mx=x THEN
   BEGIN
    Key:=#0;
    Ekey:=#75;
    Delay(1);
   END
   ELSE IF Mx=x1 THEN
   BEGIN
    Key:=#0;
    Ekey:=#77;
    Delay(1);
   END;
  END;

  IF Key=#0 THEN     { Special keys }
   CASE  Ekey OF
    #77 : BEGIN                 { --> }
	  x2:=x2+1;
	  IF (x2>x1-1) THEN
	  BEGIN
	   x2:=x1-1;
	   Offs:=Offs+1;
	   IF Output2=255 THEN
	   BEGIN
	    Offs:=Offs-1;
	    x2:=x1-1;
	    Output2:=0;
	   END;
	  END;
	 END;

    #75 : BEGIN                 { <-- }
	  x2:=x2-1;
	  IF (x2<x+1) THEN
	  BEGIN
	   x2:=x+1;
	   Offs:=Offs-1;
	   IF Offs<1 THEN
	   BEGIN
	    Offs:=1;
	    x2:=x+1;
	   END;
	  END;
	 END;

    #72 : BEGIN                     { Up Arrow }
	  IF UpDown=FALSE THEN
	  BEGIN
	   i:=Len;
	   WHILE (Bs[i]=' ') AND (i>1) DO
	     i:=i-1;
	   Offs:=i;
	   x2:=x+1;
	  END;
	 END;

    #80 : BEGIN                     { Down Arrow }
	  IF UpDown=FALSE THEN
	  BEGIN
	   Offs:=1;
	   x2:=x+1;
	  END;
	 END;

    #73 : BEGIN                   { PgUp }
	  IF PgMov=FALSE THEN
	  BEGIN
	   i:=Len;
	   WHILE (Bs[i]=' ') AND (i>1) DO
	     i:=i-1;
	   Offs:=i;
	   x2:=x+1;
	  END;
	 END;

    #81 : BEGIN                   { PgDn }
	  IF PgMov=FALSE THEN
	  BEGIN
	   Offs:=1;
	   x2:=x+1;
	  END;
	 END;

    #79 : BEGIN                   { End }
	  i:=Len;
	  WHILE (Bs[i]=' ') AND (i>1) DO
	    i:=i-1;
	  Offs:=i;
	  x2:=x+1;
	 END;

    #71 : BEGIN                  { Home }
	  Offs:=1;
	  x2:=x+1;
	 END;

    #82 : BEGIN                  { Insert }
	  IF Insert=TRUE THEN
	  BEGIN
	   Insert:=FALSE;
	   Cursor_Big;
	  END
	 ELSE
	  BEGIN
	   Insert:=TRUE;
	   Cursor_Small;
	  END;
	 END;

    #83 : BEGIN                 { Del }
	  IF Where=Len THEN
	    Bs[Where]:=' '
	 ELSE
	  BEGIN
	   FOR i:=Where TO Len-1 DO
	    Bs[i]:=Bs[i+1];
	   Bs[Len]:=' ';
	  END;
	 END;

     #6 : BEGIN                 { CRTL+Del }
	  FOR i:=1 TO Len DO
	    Bs[i]:=' ';
	  Offs:=1;
	  x2:=x+1;
	 END;
  END;

  CASE Key OF

    #46     : BEGIN                  { Point }
	      IF Floa THEN
		Pressed:=ord(Key)
	      ELSE IF Path THEN
		Pressed:=ord(Key)
	      ELSE IF Math THEN
		Pressed:=ord(Key)
	      ELSE IF Punct THEN
		Pressed:=ord(Key)
	     END;

   #8      : BEGIN               { backspace }
	      IF (Where>1) THEN
	      BEGIN
	       x2:=x2-1;
	       IF (x2<x+1) THEN
	       BEGIN
		x2:=x+1;
		Offs:=Offs-1;
		IF Offs<1 THEN
		BEGIN
		 Offs:=1;
		 x2:=x+1;
		END;
	       END;
	       Where:=(Offs-1)+(x2-x);
	       IF Where=Len THEN
		 Bs[Where]:=' '
	      ELSE
	       BEGIN
		FOR i:=Where TO Len-1 DO
		 Bs[i]:=Bs[i+1];
		Bs[Len]:=' ';
	       END;
	      END;
	     END;

    #25     :  BEGIN              { CTRL+Y }
	       IF Ekey=#21 THEN
	       BEGIN
		FOR i:=1 TO Len DO
		  Bs[i]:=' ';
		Offs:=1;
		x2:=x+1;
	       END;
	      END;

    #48..#57 : BEGIN              { Numbers 0-9 }
	      IF (Num) OR (Math) THEN
		Pressed:=ord(Key);
	     END;

    #65..#90 : BEGIN              { Uppercase }
	      IF Upperc THEN
		Pressed:=ord(Key)
	      ELSE IF Lowerc THEN
		Pressed:=ord(Key)+32;
	     END;

    #97..#122 : BEGIN             { Lowercase }
	       IF Lowerc THEN
		 Pressed:=ord(Key)
	       ELSE IF Upperc THEN
		 Pressed:=ord(Key)-32;
	     END;

    #128..#255 : IF Extend THEN Pressed:=ord(key);

    #0..#31    : IF Low THEN Pressed:=ord(Key);

 #33..#47,#58..#64,#91..#96,#123..#126 : BEGIN
				  IF Punct THEN
				    Pressed:=ord(Key)
				  ELSE IF (Math) AND (Key IN [#46,#42,#43,#47,#61,#94,#246]) THEN
				    Pressed:=ord(Key)
				  ELSE IF (Path) AND (Key IN [#42,#46,#58,#63,#92]) THEN
				    Pressed:=ord(Key);
				 END;

    #32     : BEGIN
	      IF Spac THEN
		Pressed:=ord(Key);
	     END;

  END;
  IF (Tab) AND (key=#12) THEN
    Exit:=TRUE;
  IF (UpDown) AND (Key=#0) THEN
   IF (Ekey=#72) OR (Ekey=#80) THEN
    Exit:=TRUE;
  IF (Tab) AND (Key=#9) THEN
    Exit:=TRUE;
  IF (Esc) AND (Key=#7) THEN
    Exit:=TRUE;
  IF (PgMov) AND (Ekey=#73) AND (Key=#0) THEN
    Exit:=TRUE;
  IF (PgMov) AND (Key=#0) THEN
   IF (ekey=#73) OR (ekey=#88) OR (ekey=#32) OR (ekey=#18) THEN
    Exit:=TRUE;
  IF (Key=#13) THEN
    Exit:=TRUE;
 IF (Exit=FALSE) AND (Pressed>0) THEN   { Typing section }
  IF Insert THEN
  BEGIN
   IF Where<Len THEN
     FOR i:=len-1 DOWNTO Where DO
       Bs[i+1]:=Bs[i];
   Bs[Where]:=CHR(Pressed);
   x2:=x2+1;
   IF (x2>x1-1) THEN
   BEGIN
    x2:=x1-1;
    Offs:=Offs+1;
    IF Output2=255 THEN
    BEGIN
     Offs:=Offs-1;
     x2:=x1-1;
     Output2:=0;
    END;
   END;
  END
 ELSE
  BEGIN
   Bs[Where]:=CHR(Pressed);
   x2:=x2+1;
   IF (x2>x1-1) THEN
   BEGIN
    x2:=x1-1;
    Offs:=Offs+1;
    IF Output2=255 THEN
    BEGIN
     Offs:=Offs-1;
     x2:=x1-1;
     Output2:=0;
    END;
   END;
  END;
 UNTIL Exit;
 Output:=ord(Key);
END;




begin
 cls(' ');
 mouse_on;
 bs:='Hello world!';
 readln(65535,1,bs,100,1,1,20,yellow,blue);
end.