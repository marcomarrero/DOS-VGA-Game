//----------------------------------------------------
// MiniCRT - (c) 1995 Marco A. Marrero
//----------------------------------------------------
#ifndef MINICRT
 #define MINICRT
 extern "C" {
        extern far pascal void minicrt_init();
        extern far pascal void crt_char(int x,int y,char what,char color);
        extern far pascal void crt_linex(int x,int y,int x1,char whar,char color);
        extern far pascal void crt_liney(int x,int y,int y1,char what,char color);
        extern far pascal void crt_shadex(int x,int y,int x1);
        extern far pascal void crt_shadey(int x,int y,int y1);
        extern far pascal void crt_print(int x,int y:,char far *txt,char color);
        extern far pascal void crt_pcopy(unsigned upto,unsigned from);
        extern far pascal int  crt_readkey();
        extern far pascal void crt_echo(char far *txt);
        extern far pascal void crt_boxfill(int x,int y,int x1,int y1,int color);
 }
#endif

