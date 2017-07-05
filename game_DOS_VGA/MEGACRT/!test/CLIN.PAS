{----------------------------
       Disk Clin v1.1
 ----------------------------
 Programmed by Marco Marrero
-----------------------------}
{A+,X+,F-,R-,B-,T-,V-,G-,Y-,E-,I-,N-,O-,P-,Q-,S-}
{$D-,L-}

program clin;

uses megacrt,gui;

var
 xs : string;
 x,y,byebye  : integer;
 mydrive : byte;
 what    : byte;

{*******************************************************************}


procedure verify_sector(drive,track:byte); assembler;
asm
        mov     ah,4            {-- function 4 }
        mov     al,1            {-- # of sectors  }
        mov     dh,0            {-- head 0 }
        mov     dl,drive

        mov     ch,track        {-- track # }
        xor     cl,cl           {-- sector  }
        int     $13
        mov     what,ah
end;

begin
 cursor_off;
 syscolor:=$14;
 fill(0,0,cols,rows,'±');

 syscolor:=$03;
 tboxfill(6,1,74,5,thickbox);
 shadowbox(6,1,74,5);
 syscolor:=$0B;
 xs:='Disk Clin';
 print(35,2,xs);
 syscolor:=$0E;
 xs:='Programmed by Marco A. Marrero';
 print(25,3,xs);
 syscolor:=$0B;
 xs:='Morse #49, BOX 453, Arroyo, PR 00714';
 print(21,4,xs);
 mouse_on;

 help('Select Ok to continue,  Help! for a help screen...');
 xs:='^Disk Clin v1.01|!|^'#13'  The cleaning disk companion|!|^'#11'Revision 8/25/94';
 msgbox(ltcyan,' About ',yellow,white,blue,xs,'   Ok   | Help! ');

 if xs='2' then
 begin
  xs:='When you use a head cleaning diskette, DOS just goes to|';
  xs:=xs+'the boot sector to identify it. However, it isn''t very|';
  xs:=xs+'efficient to read just one track.|  |';
  xs:=xs+'Disk Clin will "read" all tracks from the disk. So it|';
  xs:=xs+'makes easier to clean a drive.';
  help('Click on Continue or press [Enter] for next help screen...');
  msgbox(ltcyan,' Help! ',black,cyan,ltblue,xs,'   Continue   ');

  xs:='The user interface is designed for mouse use. However|';
  xs:=xs+'you can use the following keys:|!|';
  xs:=xs+'To choose button: [Arrow keys]|';
  xs:=xs+'To activate     : [Enter]|';
  xs:=xs+'Cancel          : [Esc]|';
  xs:=xs+'Move window     : [Crtl]+[Arrow keys]';

  help('Select Ok to continue with Disk Clin or exit to DOS...');
  msgbox(ltcyan,' Help! ',black,cyan,ltblue,xs,'     Ok     |Exit to DOS');
 end;

 if (xs<>'1') then
 begin
  reset_screen;
  halt(1);
 end;

 xs:='This program simply moves the disk drive head from track 0 to|';
 xs:=xs+'track 79 to enhance the cleaning diskette effectivity.|!|';
 xs:=xs+#11'Please select the disk drive to clean...';
 help('Select drive to clean. Drive A: or Drive B:. Select Cancel to quit.');
 msgbox(ltcyan,' Disk Clin ',yellow,white,blue,xs,'Drive A:|Drive B:|Cancel');

 if (xs='3') or (xs='0') then
 begin
  reset_screen;
  halt(1);
 end;

 mouse_hide;
 mydrive:=ord(xs[1])-48;
 byebye:=0;

 repeat
  syscolor:=$0B;
  tboxfill(-1,10,80,15,thinbox);

  xs:=' Diskette Status ';
  print(2,10,xs);

  help('Select Start to begin cleaning, Quit to exit to DOS');
  xs:='^Insert the cleaning diskette|^In drive ';
  xs:=xs+chr(mydrive+64)+':|!|'#15'Then press '#11'[Enter]'#15' or click on the|'#15'Start button to begin...';
  mouse_show;
  msgbox(ltcyan,' Disk Clin request ',yellow,white,pink,xs,'Start Cleaning!|Quit');

  if (xs='2') or (xs='0') then
  begin
   reset_screen;
   halt(1);
  end;

  syscolor:=$0f;
  xs:=' Drive '+chr(mydrive+64)+': ';
  print(19,10,xs);

  syscolor:=$19;
  x:=0;
  help('Cleaning in progress... This will take about 40 seconds. [Esc] to abort.');
  repeat
   verify_sector(mydrive-1,x);

   if (what=128) then
   begin
    help('There''s no cleaning diskette in drive!');
    xs:='Please insert cleaning diskette|^in drive '+chr(mydrive+64);
    xs:=xs+'|!|And press [Enter] to continue...';
    msgbox(yellow,' Disk Clin Error ',yellow,ltred,red,xs,' Ooops | Quit ');
    help('Cleaning back to progress... Press [Esc] to abort.');

    if (xs='2') or (xs='0') then
    begin
     reset_screen;
     halt(1);
    end;

    syscolor:=$19;
   end;

   readkey;
   if key=esc then x:=79;
   mouse_hide;
   fill(x-8,11,x,14,'±');
   mouse_show;
   x:=x+4;
  until x>79;

  mouse_hide;
  fill(0,11,79,14,'±');
  gotoxy(1,1);
  writeln(#7);
  mouse_show;

  if byebye=0 then
  begin
   if mydrive=1 then mydrive:=2 else mydrive:=1;
   xs:='^Finished|!|Do you want to clean drive '+chr(mydrive+64)+': ?';
   help('Select "Yes" to clean drive '+chr(mydrive+64)+':');
   msgbox(ltcyan,' Disk Clin ',yellow,white,blue,xs,' Yes  |  No  ');
   if (xs='2') or (xs='0') then byebye:=1;
  end;
  byebye:=byebye+1;
 until byebye=2;

 xs:='^Finished!|!|Don''t forget to clean your drives every 40 hours!|';
 help('Press [Enter] to return to DOS.');
 msgbox(ltcyan,' Disk Clin ',yellow,white,pink,xs,'   Exit to DOS   ');

 reset_screen;
 halt(0);
end.
