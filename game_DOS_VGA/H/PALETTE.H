//-------------------------------------------------
// Palette.H -- Model Large - (c) 1995 M. Marrero
//-------------------------------------------------

#ifndef PALETTE
 #define PALETTE
 extern "C" {
  extern far pascal void pal_entry(char color,char red,char green,char blue);
  extern far pascal void pal_set(void far *which);
  extern far pascal void pal_all(char red,char green,char blue);
  extern far pascal void pal_fade(void far *which,unsigned delay);
  extern far pascal void pal_light(void far *which,unsigned delay);
  extern far pascal void pal_unfade(void far *which,unsigned delay);
  extern far pascal void pal_unlight(void far *which,unsigned delay);
  extern far pascal void pal_modify(int delay,void far *which,int r,int g,int b);
  extern far pascal void pal_work2pal(void far *which);
  extern far pascal void vga_pal16;
  extern far pascal void pal_spread(int r,int g,int b,void far *pal,int radd,int gadd,int badd,int start,int ending);
  extern far pascal void pal_copy(void far *pal,int start,int end,int to);
  extern far pascal void pal_change(void far *pal,int r,int g,int b,int start,int end);
 }
#endif
