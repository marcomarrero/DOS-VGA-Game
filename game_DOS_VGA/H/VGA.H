//---------------------------------------------
// VGA unit - Model Large - (c) 1995 M.Marrero
//---------------------------------------------

#ifndef VGA
 #define VGA
 extern "C" {
  extern far pascal void vga_pal(char color,char r,char g,char b);
  extern far pascal void mode(unsigned which);
  extern far pascal void vga_synch(unsigned num);

  extern far pascal void vga_addr(void far *where);
  extern far pascal void getscreen(void far *where);
  extern far pascal void putscreen(void far *where);
  extern far pascal void vgaputscreen(void far *where);

  extern far pascal char read_pcx(void far *image, void far *pal);

  extern far pascal void put(int x,int y,void far *what);
  extern far pascal void get(int x,int y,int x1,int y1,void far *what);
  extern far pascal void cput(int x,int y,void far *what);
  extern far pascal void cpaste(int x,int y,void far *what);
  extern far pascal void cpasteadd(int x,int y,void far *what);

  extern far pascal void cls(char color);
  extern far pascal void pset(int x,int y,char color);
  extern far pascal char point(int x,int y);
  extern far pascal void boxfill(int x,int y,int x1,int y1,char color);
  extern far pascal void boxfilladd(int x,int y,int x1,int y1,char adder);
  extern far pascal void line(int x,int y,int x1,int y1,int color);
  extern far pascal void drawto(int x,int y,int x1,int y1,int color);
  extern far pascal void hline(int x,int y,int x1,char color);
  extern far pascal void vline(int x,int y,int y1,char color);
  extern far pascal void box(int x,int y,int x1,int y1,int color);
 }
#endif
