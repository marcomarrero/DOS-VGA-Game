# DOS-VGA-Game
VGA/hardware library, Assembly (TASM Ideal mode) 386 real-mode, and Turbo/Borland Pascal 6.
The ASM code in each folder must be assembled in TASM, then each .pas should be converted to a library/.tpu.

There is a VGA graphics library with some primitives, blitting, and hardware. 
There are some interesing PC hardware routines, and the blit routine is optimized and supports clipping (but not blitting over itself).

The main routine saves the stack, sets up its own keyboard interrupt handler, and handles few BIOS keys to respond QEMM errors.
There is a hotkey that recovers the stack and exits gracefully.

32-bit code in Real Mode is fully functional in any 32-bit CPU on DOS without a DOS extender. I never tried 32-bit protected mode because I was using Turbo Pascal for testing.

I also included a DOS text library called "MegaCRT" that also included a high-level MessageBox
