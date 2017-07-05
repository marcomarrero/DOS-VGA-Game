//-----------------------------------------------------------
 // VGA Hardware Library - Model Large - (c) 1995 M. Marrero
//-----------------------------------------------------------
#ifndef VGA_HARD
 #define VGA_HARD

  #define INPUT_STATUS1 0x3da
  #define MISC_OUTPUT	0x3c2
  #define SC_INDEX	0x3c4
  #define CRTC_INDEX	0x3d4
  #define GRAPH_INDEX	0x3ce
  #define ATTR_INDEX	0x3c0
  #define PEL_WRITE	0x3c8
  #define PEL_READ	0x3c7
  #define PEL_DATE	0x3c9

  #define MASK_PLANE1	0x0102	//-- Map Register + Plane 1
  #define MASK_PLANE2	0x1102	//-- Map Register + Plane 1
  #define ALL_PLANES	0x0F02	//-- Map Register + All Bit Planes
  #define CHAIN4_OFF	0x0604	//-- Chain 4 mode Off
  #define ASYNC_RESET	0x0100	//-- (A)synchronous Reset
  #define SEQU_RESTART	0x0300	//-- Sequencer Restart

  #define LATCHES_ON	0x0008	//-- Bit Mask + Data from Latches
  #define LATCHES_OFF	0xFF08	//-- Bit Mask + Data from CPU }

  extern far pascal void VGA_POS(unsigned x);
  extern far pascal void VGA_PAN(char pan);
  extern far pascal void VGA_PAN_C();
  extern far pascal void VGA_WPLANE(char plane);	//-- 4 bits
  extern far pascal void VGA_RPLANE(char plane);	//-- 4 bits
  extern far pascal void VGA_WMODE(char mode);
  extern far pascal void VGA_RMODE(char mode);
  extern far pascal void VGA_SPLIT(unsigned scanline);
  extern far pascal void VGA_VBLANK(unsigned start,unsigned ending);
  extern far pascal void HSYNCH();
  extern far pascal void VWAIT();
  extern far pascal void VSYNCH(unsigned delay);
  extern far pascal void VSKIP();

  extern far pascal void screen_off();		//-- DON'T USE, because
  extern far pascal void screen_on();		//-- THIS DOES NOT WORK!!

  extern far pascal void video_hirez;		//-- Makes VGA slower
  extern far pascal void video_lorez;		//-- Makes VGA faster

  extern far pascal void scan_height(char value);	//-- 1..199
 }
#endif
