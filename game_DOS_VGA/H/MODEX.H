//-------------------------------------------------------
// ModeX library - (Uncomplete!!) (c) 1995 Marco Marrero
//-------------------------------------------------------
#ifndef MODEX
 #define MODEX

 #define M320x200 0
 #define M320x240 1
 #define M360x200 2
 #define M360x240 3
 #define M376x282 4
 #define M320x400 5
 #define M320x480 6
 #define M360x400 7
 #define M360x480 8
 #define M360x360 9
 #define M376x308 10
 #define M376x564 11
 #define M256x240 12
 #define M256x200 13
 #define M256x154 15;
 #define M256x282 16
 #define M256x70  17;

 extern "C" {
        extern far pascal void modex_set(int mode,int width,int height);
        extern far pascal void mode13_to_x();
        extern far pascal void modex_to_13();
        extern far pascal void modex_to_16();
        extern far pascal void mode16_to_x();
        extern far pascal void xclear(char color);
        extern far pascal void xcls(char color);
        extern far pascal void xpset(int x,int y,char color);
        extern far pascal void xpset4(int x,int y,char color);
        extern far pascal void xcopy(unsigned page1,unsigned page2);
        extern far pascal void xset_page(unsigned page);
        extern far pascal void x_getinfo(void far * what);
        extern far pascal void modex_to_bios(unsigned mode);
 }
#endif
