;------------------------------;
;      MegaCRT v3.0            ;
;==============================;
;   Version 1 : 06/18/1992     ;
;   Version 2 : 01/15/1994     ;
;   Version 3 : 08/11/1995     ;
;   Revision  : 08/11/1995     ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
; (c) 1992,95 Marco A. Marrero ;
;------------------------------;

IDEAL
MODEL SMALL, PASCAL
LOCALS
P286



DATASEG
;ÄÄÄÄÄÄÄÄ Variables ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

 EXTERN sysshadow       : WORD          ;--- Shadow constant
 EXTERN whole_screen    : WORD          ;-- Screen size  = 80x25 = 2000
 EXTERN down_lin        : WORD          ;-- Bytes x line = 80x2  = 160
 EXTERN screen_addr     : WORD          ;-- Screen seg   = $b800 if color
 EXTERN cols            : WORD          ;-- Columns      = 80 - 1 = 79
 EXTERN rows            : WORD          ;-- Rows         = 25 - 1 = 24
 EXTERN maxcols         : WORD          ;-- Maximum rows & cols
 EXTERN maxrows         : WORD          ;--

 EXTERN xadd            : WORD          ;-- Window x upper area
 EXTERN yadd            : WORD          ;-- Window y upper area

 EXTERN display         : BYTE          ;-- Current display mode in use
 EXTERN display_page    : BYTE          ;-- Current display page
 EXTERN screen_mode     : BYTE          ;-- Current video mode
 EXTERN crtc            : WORD          ;-- CRTC address register / $3d4 color

 EXTERN syscolor        : BYTE          ;-- Current Color
 EXTERN output          : WORD

 EXTERN screen1         : DWORD         ;-- Screens
 EXTERN screen2         : DWORD
 EXTERN screen3         : DWORD
 EXTERN screen4         : DWORD

 EXTERN key             : BYTE          ;-- Key code / extended key code
 EXTERN ekey            : BYTE

 EXTERN alternate       : BYTE          ;-- Alt/Ctrl+letter combination
 EXTERN control         : BYTE

 EXTERN fkey            : BYTE          ;-- Alt/Crtl/Shift/None + Function key
 EXTERN afkey           : BYTE
 EXTERN cfkey           : BYTE
 EXTERN sfkey           : BYTE    

 EXTERN mx              : WORD          ;-- Mouse variables
 EXTERN my              : WORD
 EXTERN mk              : WORD
 EXTERN mouse           : WORD
 EXTERN moved           : WORD
 EXTERN clicked         : WORD

CODESEG
ASSUME  cs:@@code
P386

mypal           DB      768 dup(?)      ;-- Working palette
keylayout       DB      'QWERTYUIOP****ASDFGHJKL*****ZXCVBNM'

EXTERN          crtlogo : FAR

;ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ VWAIT() ³ Wait vertical synch
;ÃÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ The vertical synch (or vertical retrace) is the time when the electron
;³ beam of the monitor turns off at the bottom right of the screen and goes
;³ up to the top right. It is a *short* period of time in which you may
;³ do fast screen updates to minimize flicker. This one just waits until or
;³ the beam is at the vertical synch.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  vwait
PROC    vwait   FAR
USES    ds

        mov     ax,@data        ;-- set up data segment
        mov     ds,ax

        mov     dx,CRTC         ;-- get crt register
	add     dl,6
	mov     ah,8

@@wait:
        in      al,dx           ;-- wait vertical retrace
	test    al,ah
        jz      @@wait
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ VSYNCH() ³ Syncrhonize to vertical synch
;ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ The vertical synch (or vertical retrace) is the time when the electron
;³ beam of the monitor turns off at the bottom right of the screen and goes
;³ up to the top right. It is a *short* period of time in which you may
;³ do fast screen updates to minimize flicker. This one waits until the beam
;³ BEGINS the vertical retrace.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  vsynch
PROC    vsynch  FAR
USES    ds

        mov     ax,@data                ;-- Set up data segment
        mov     ds,ax

        mov     dx,CRTC                 ;-- Status register
        add     dl,6
        mov     ah,8

@@v_still:
        in      al,dx
        test    al,ah
        jnz     @@v_still

@@v_wait:
        in      al,dx
        test    al,ah
        jz      @@v_wait

        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ DELAY(int hundreths) ³ Delay (wait) in increments of 1/100th of a second
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ This delays the computer for a while using a DOS call to retrieve time.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  delay
PROC    delay   FAR
USES    ds,di
ARG     time : WORD

        mov     ah,2ch          ;-- get time
	int	21h
        mov     di,[time]
	or	di,di
        je      @@bye

@@sleep:
        mov     al,dl           ;-- 1/100ths

@@delay:
        int     21h
	cmp	al,dl
        je      @@delay
	dec	di
        jnz     @@sleep
@@bye:
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ COLOR(char textcolor,backgroundcolor)  ³ Changes the current color
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ This commands changes the internal variable "syscolor" with the
;³ corresponding color and background color.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  color
PROC    color   FAR
ARG     atxt:BYTE, abkg:BYTE
USES    ds

        mov     ax,@data
        mov     ds,ax

        mov     ah,[abkg]       ;-- Last 4 bits indicate background
	mov	cl,4
	shl	ah,cl

        or      ah,[atxt]       ;-- Fist 4 bits indicate text color
	mov     syscolor,ah
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ TCOLOR(char textcolor) ³ Changes text color
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Changes the current text color only (updates "syscolor" variable).
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  tcolor
PROC    tcolor  FAR
USES    ds
ARG     atxt:BYTE

        mov     ax,@data
        mov     ds,ax

        mov     ah,syscolor
        and     ah,11110000b            ;-- clear color
        or      ah,[atxt]               ;-- Set new color
	mov     syscolor,ah
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ BCOLOR(char backgroundcolor) ³ Changes the background color only
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Changes the background current color. Updates the "syscolor" variable.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  bcolor
PROC    bcolor  FAR
USES    ds
ARG     abkg:BYTE

        mov     ax,@data
        mov     ds,ax

        mov     ah,syscolor
        and     ah,00001111b    ;-- Mask color

        mov     al,[abkg]       ;-- get bakground color value...
        mov     cl,4            ;-- ...and shift bits into position
	shl     al,cl

        or      ah,al           ;-- Set bits
        mov     syscolor,ah
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ CLS(char fillchar)  ³ Clears the whole screen
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Clears the screen using the current color and a fill character. Ignores
;³ the current window settings!
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  cls
PROC    cls     FAR
USES    ds,di
ARG     chr:BYTE

        mov     ax,@data
        mov     ds,ax

        mov     es,screen_addr          ;-- Get screen segment

        mov     al,[chr]                ;-- Get color & attribute
	mov	ah,syscolor

        mov     cx,whole_screen         ;-- Screen size

	xor     di,di

	rep     stosw
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ OUT_CHAR(int x,y; char character) ³ Outputs a character on the screen
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Writes a character using the x,y coordinates and with the current color.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  out_char
PROC    out_char        FAR
USES    ds
ARG     x:WORD,y:WORD,cha:BYTE

        mov     ax,@data
        mov     ds,ax

        mov     es,screen_addr

        mov     ax,xadd                 ;-- ax = xadd

        mov     bx,[x]                  ;-- bx = x + xadd
        add     bx,ax
        cmp     bx,cols
        jg      @@bye                   ;-- x must be inside screen

        cmp     bx,ax
        jl      @@bye

        shl     bx,1                    ;-- convert x to screen coords

        mov     ax,[y]
        add     ax,yadd                 ;-- ax = y
        cmp     ax,rows
        jg      @@bye
        cmp     ax,yadd
        jl      @@bye

        mul     down_lin
        add     bx,ax

        mov     ah,syscolor
        mov     al,[cha]
        mov     es:[bx],ax
@@bye:
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ result=MOUSE_ON() ³ Enables mouse driver
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ It first checks if the mouse vector is valid and then proceeds to do
;³ a software reset on the mouse.
;³ Returns: 0 = No mouse present.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  mouse_on
PROC    mouse_on        FAR
USES    ds

        mov     ax,@data
        mov     ds,ax

	xor     bx,bx
	mov     es,bx
	add     bx,0cch
        mov     ax,es:[bx]              ;-- Get mouse interrupt vector
	add     ax,es:[bx+2]
	or      ax,ax
        jz      @@bye

	mov     ax,21h
        int     33h                     ;-- Software reset
        cmp     ax,-1                   ;-- If -1 mouse installed
        je      @@cont

	xor     ax,ax
        jz      @@bye                   ;-- Jmp...

@@cont:
        mov     ax,1
        int     33h                     ;-- Unhide mouse

@@bye:
        mov     mouse,ax                ;-- Will be zero if no mouse
	xor     ax,ax
	mov     mk,ax
	mov     mx,ax
	mov     my,ax
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ MOUSE_WINDOW(int x,y,x1,y1) ³ Restricts the mouse to a window
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Haven't used it. No comment.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  mouse_window
PROC    mouse_window    FAR
USES    ds
ARG     x:WORD,y:WORD,x1:WORD,y1:WORD

        mov     ax,@data
        mov     ds,ax

        test    mouse,1                 ;--- Mouse present?
        jz      @@bye

	mov     ax,7
        mov     cx,[x]
        mov     dx,[x1]
	int     33h

	inc     ax
        mov     cx,[y]
        mov     dx,[y1]
	int     33h
@@bye:
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ MOUSE_SHOW() ³ Shows a hidden mouse
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ It unhides a mouse.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  mouse_show
PROC    mouse_show      FAR
USES    ds

        mov     ax,@data
        mov     ds,ax

        test    mouse,1                 ;-- Mouse is working?
        jz      @@bye

	xor     ax,ax
	inc     ax
	int     33h
@@bye:
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ MOUSE_HIDE() ³ It hides the mouse
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ If you hide the mouse twice, you MUST unhide it twice!!
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  mouse_hide
PROC    mouse_hide      FAR
USES    ds

        mov     ax,@data
        mov     ds,ax

        test    mouse,1         ;-- Mouse is working?
        jz      @@bye

	mov     ax,2
	int     33h
@@bye:
        ret
ENDP

;ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ MOUSEK() ³ Get mouse values (inside window)
;ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Returns:
;³         Mx = x coordinate (window)
;³         My = y coordinate (window)
;³         Mk = Button (1=L,2=R or 3=LR)
;³         Moved   = zero if no movement
;³         Clicked = zero if changes
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  mousek
PROC    mousek          FAR
USES    ds

        mov     ax,@data
        mov     ds,ax

        test    mouse,1                 ;-- Mouse is working?
        jz      @@bye

        xor     ax,ax                   ;-- Clear flags
	mov     moved,al
	mov     clicked,ah

	mov     al,3
	int     33h
	mov     ax,cx
	mov     ch,3

        mov     cl,ch                   ;-- Convert x coordinate to text
	shr     ax,cl
	sub     ax,xadd
        cmp     ax,mx                   ;-- moved the mouse?
        je      @@still

	inc     moved
	mov     mx,ax

@@still:
        mov     cl,ch                   ;-- Convert y coordinate to text
	shr     dx,cl
	sub     dx,yadd
        cmp     dx,my                   ;-- moved the mouse?
        je      @@stil2

	inc     moved
	mov     my,dx

@@stil2:
        cmp    bx,mk
        je     @@bye

        mov    mk,bx                    ;-- Button: 1=left,2=right,3=both
        inc    clicked                  ;-- button was pressed or depressed
@@bye:
        ret
ENDP




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ MOUSE_SET(int x,y) ³ Sets the mouse in coordinates. Window relative
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  mouse_set
PROC    mouse_set       FAR
USES    ds
ARG     x:WORD, y:WORD

        mov     ax,@data
        mov     ds,ax

        test    mouse,1         ;-- Mouse is working?
        jz      @@bye

        mov     cx,[x]
	add     cx,xadd

        mov     dx,[y]
	add     dx,yadd

	mov     ax,4
	int     33h
@@bye:
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ MOUSE_WAIT() ³ Waits user to depress mouse button
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  mouse_wait
PROC    mouse_wait      FAR
USES    ds

        mov     ax,@data
        mov     ds,ax

        test    mouse,1         ;-- Mouse is working?
        jz      @@bye

@@wait:
        mov     ax,3
	int     33h
	or      bx,bx
        jnz     @@wait
@@bye:
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ button=MOUSE_AREA(int button,x,y,x1,y1) ³ Returns if mouse button pressed
;ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Will return a value if the mouse button "button" is pressed at the
;³ x,y,x1,y1 coordinates. It is Window dependent
;ÃÄ Parameters: ÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÂÄ Returns: ÄÄÄÄÄÄÄÄÄÄÄ
;³  0 = Failure            ³ 2 = Right mouse button  ³³ Mouse button + 1
;³  1 = Left mouse button  ³ 3 = Both mouse buttons  ³³ (Ex. 2 = Left button)
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  mouse_area
PROC    mouse_area      FAR
USES    ds,si,di
ARG     button:WORD, x:WORD, y:WORD, x1:WORD, y1:WORD

        call    mousek

        mov     ax,@data
        mov     ds,ax

        test    mouse,1         ;-- Mouse is working?
        jz      @@bye

        mov     output,0        ;-- Preliminary is zero --

        mov     ax,[button]
        cmp     ax,mk           ;-- It is correct button? --
        jne     @@bye

	mov     si,xadd
	mov     di,yadd

@@check:
        mov     ax,mx           ;-- Check x pos. --
        mov     bx,[x]
	add     bx,si
	cmp     ax,bx
        jl      @@bye

        mov     bx,[x1]
	add     bx,si
        cmp     ax,bx           ;-- Check x1 pos. --
        jg      @@bye

        mov     ax,my           ;-- Check y pos. --
        mov     bx,[y]
	add     bx,di
	cmp     ax,bx
        jl      @@bye

        mov     bx,[y1]
	add     bx,di
	cmp     ax,bx
        jg      @@bye

	inc     dx
        mov     ax,dx           ;-- Survived! return button value +1
        jmp     @@bye2
@@bye:
        xor     ax,ax
@@bye2:
        ret
ENDP




;ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ READKEY() ³ Read Scan & Keycode stored on Key/Ekey
;ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Will check several alt/shift combinations:
;³         Control   = 'A'-'Z' = (Ctrl+A,Ctrl+B...)
;³         Alternate = 'A'-'Z' = (Alt +A,Alt+B...)
;³         Fkey      = 0..12   = (F1,F2,F3...)
;³         Sfkey     = 0..12   = (Shift+F1...)
;³         Cfkey     = 0..12   = (Ctrl+F1...)
;³         Afkey     = 0..12   = (Alt+F1...)
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  readkey
PROC    readkey         FAR
USES    ds,si,di

        mov     ax,@data
        mov     ds,ax

        xor     ax,ax
        mov     fkey,al         ;-- Clear some values
	mov     sfkey,ah
	mov     afkey,al
	mov     cfkey,ah
	mov     control,al
	mov     alternate,ah

	mov     dl,0ffh
	mov     ah,06
	int     21h
        jnz     @@ok             ;-- key was pressed

	xor     bx,bx
        jmp     @@bye            ;-- no key...

@@ok:
        or      al,al           ;-- special key?
        jz      @@again
	xor     ah,ah
        jmp     @@got

@@again:
        mov     dl,0ffh         ;-- re-read keyboard
	mov     ah,06
	int     21h
	mov     ah,al
        xor     al,al           ;-- al=key / ah=ekey

@@got:
        mov     bx,ax           ;-- bx will store values

        or      al,al           ;------- Test Crtl values
        jz      @@t2             ;-- If not Ctrl skip...

	cmp     al,26
        ja      @@t2             ;-- Above Ctrl+Z?

        add     al,64           ;-- Ctrl+A=1 // 1+64=65="A"
	mov     control,al
        jmp     @@bye

@@t2:
        cmp     ah,16           ;------- Test Alt values
        jb      @@t3            ;-- Below Alt+A?
        cmp     ah,50           ;-- Above Alt+M?
        ja      @@t3

        mov     cx,bx           ;-- cx = old bx value

        sub     ah,15           ;-- Must do a table search!
	xor     bx,bx
        mov     bl,ah           ;-- need value in bx
        mov     si,bx           ;-- ...to store it on si

        mov     dx,seg KeyLayout
        mov     es,dx
        mov     bx,offset Keylayout

        mov     al,es:[bx+si]
        mov     bx,cx

        cmp     al,'*'
        je      @@bye
        mov     alternate,al
        jmp     @@bye

@@t3:
        cmp     ah,59           ;------- Test F1/F10 keys
        jb      @@t4
        cmp     ah,68
        ja      @@t3_1

        sub     ah,58           ;-- Adjust to 1-10
	mov     fkey,ah
        jmp     @@bye

@@t3_1:
        cmp     ah,133          ;--- Test F11/F12
        jb      @@t4
        cmp     ah,134
        ja      @@t4

        sub     ah,122          ;-- Adjust to 11-12
        mov     fkey,ah
        jmp     @@bye

@@t4:
        cmp     ah,84           ;------- Test Shift+F1/F10
        jb      @@t5
        cmp     ah,93
        ja      @@t4_1

        sub     ah,83
        mov     sfkey,ah
        jmp     @@bye

@@t4_1:
        cmp     ah,135          ;-- Shift+F11/F12?
        jb      @@t5
        cmp     ah,136
        ja      @@t5

        sub     ah,124
        mov     sfkey,ah
        jmp     @@bye

@@t5:
        cmp     ah,94           ;------- Test Control+F1/F10
        jb      @@t6
        cmp     ah,103
        ja      @@t5_1

        sub     ah,93
        mov     cfkey,ah
        jmp     @@bye

@@t5_1:
        cmp     ah,137
        jb      @@t6
        cmp     ah,138
        ja      @@t6

        sub     ah,126
        mov     cfkey,ah
        jmp     @@bye

@@t6:
        cmp     ah,104          ;------- Test Alt+F1/F10
        jb      @@t7
        cmp     ah,113
        ja      @@t6_1

        sub     ah,103
        mov     afkey,ah
        jmp     @@bye

@@t6_1:
        cmp     ah,139
        jb      @@t7
        cmp     ah,140
        ja      @@t7

        sub     ah,128
        mov     afkey,ah
        jmp     @@bye

@@t7:
        cmp     ah,129
        jne     @@t8

        mov     ah,'0'
        mov     alternate,ah
        jmp     @@bye

@@t8:
        cmp     ah,120
        jb      @@bye
        cmp     ah,128
        ja      @@bye

	sub     ah,71
	mov     alternate,ah

@@bye:
        mov     key,bl
	mov     ekey,bh
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ CLEAR_BUFFER ³ Clears the entire keyboard buffer
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  clear_buffer
PROC    clear_buffer    FAR

        mov     ah,0ch
	xor     al,al
	int     21h
        ret
ENDP

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ GOTOXY(int col,row) ³ Puts cursor in these position (y,x)
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  gotoxy
PROC    gotoxy          FAR
USES    ds
ARG     col:WORD, row:WORD

        mov     ax,@data
        mov     ds,ax

        mov     ah,2
        mov     bh,display_page         ;-- Display Page

	mov     cx,row
	mov     dx,col
	mov     dh,cl
	int     10h
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ result=KEYBOARD_FLAGS() ³ Read special key status
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÃÄÄ RETURNS ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ ÚÄÄÄÄÄ Held: ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ ³     1=RightShift ³ 2=LeftShift  ³ 4=Ctrl 8=Alt ³
;³ ³     4096=Scroll  ³ 8192=NumLock ³ 16384=Caps   ³
;³ ³     32768=Insert ³ 256=Ctrl     ³ 512=Alt      ³
;³ ÃÄÄÄÄÄ Toggle: ÄÄÄÂÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÂÄÄ´
;³ ³     16  =Scroll ³ 32=Num          64=Caps   ³  ³
;³ ³     1024=SysReq ³ 2048=Pause(!)  128=Insert ³  ³
;ÀÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  keyboard_flags
PROC    keyboard_flags  FAR

        xor     ax,ax
	mov     es,ax
	mov     ax,es:[0417h]
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ WAIT_EVENT() ³ Waits response from mouse or keyboard
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Wait for mouse or Keyboard after clearing keys. It waits the
;³ release of pressed mouse button before waiting response.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  wait_event
PROC    wait_event      FAR
USES    ds

	call    clear_buffer

        mov     ax,@data
        mov     ds,ax

        xor     bx,bx
	mov     mk,bx
	mov     key,bl
        test    mouse,1         ;-- Is Mouse active?
        jz      @@check         ;-- If active wait user to depress

@@press:
        call    mousek
	test    Mk,0ffffh
        jnz     @@press

@@check:
        call    mousek          ; Wait key or mouse button
	call    readkey
	test    mk,255
        jnz     @@bye
	test    key,255
        jnz     @@bye
	test    fkey,255
        jz      @@check
@@bye:
        ret
ENDP




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ INIT_VIDEO() ³ Initializes MegaCRT
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Gets the screen information, checks if it is in graphics mode and
;³ if its will return to text mode.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  init_video
PROC    init_video      FAR
USES    ds,di,si

        mov     ax,@data
        mov     ds,ax

        cld                     ;-- clear direction flag

        mov     ax,40h          ;-- BIOS data area
	mov     es,ax

        mov     dx,es:[63h]     ;-- get crt address
	mov     crtc,dx

        mov     ax,es:[4ch]     ;-- Lenght of screen
        cmp     ax,13312        ;-- Check if graphics mode
        jb      @@okay

	cmp     dx,3d4h
        je      @@color

@@mono:
        xor     ah,ah           ;-- Force mono display
	mov     al,7
	int     10h
	mov     al,1

@@color:
        xor     ah,ah           ;-- Force color display
	mov     al,3
	int     10h
	xor     al,al

@@okay:
        cmp     dx,3d4h         ;-- Get screen address
        je      @@col2

@@mon2:
        mov     screen_addr,0b000h
        jmp     @@next

@@col2:
        mov     screen_addr,0b800h

;-------- CHANGES!! ------------
@@next:
        mov     dx,crtc         ; $3d4 color
	add     dl,4

	mov     al,es:[65h]
	and     al,11011111b
	out     dx,al
	mov     es:[65h],al

	mov     bl,0
	mov     ax,1003h
	int     10h

        mov     al,es:[49h]     ;-- Get current video mode
	mov     screen_mode,al

        mov     ax,es:[4ah]     ;-- Get # of columns
	dec     ax
	mov     cols,ax
	mov     maxcols,ax

	inc     ax
        shl     ax,1            ;-- Get bytes per column
	mov     down_lin,ax

        mov     al,es:[62h]     ;-- Get video page
	mov     display_page,al


        mov     al,es:[84h]     ;-- Get # of rows
	xor     ah,ah
	mov     rows,ax
	mov     maxrows,ax

        mov     bx,cols         ;-- calculate screen size
	inc     bx
	inc     al
	mul     bx
	mov     whole_screen,ax

        xor     ax,ax           ;-- clear xadd/yadd
	mov     xadd,ax
	mov     yadd,ax

        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ MODE(int biosmode) ³ Changes video mode
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ Changes video mode. It *must* be text or MegaCRT will change you back
;³ to mode(3).
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  mode
PROC    mode    FAR
ARG     which:WORD

        mov     ax,which
	int     10h
        call    init_video
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ CURSOR_OFF() ³ Turns off the cursor
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  cursor_off
PROC    cursor_off      FAR

        mov     ah,1
	mov     cx,2000h
	int     10h
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ CURSOR_SMALL() ³ Changes the cursor size to small.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  cursor_small
PROC    cursor_small    FAR

	mov     ah,1
        mov     cx,0607h        ;-- cl=06  //  ch=07
	int     10h
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ CURSOR_BIG()   ³ Changes the cursor size to big.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  cursor_big
PROC    cursor_big      FAR

        mov     ah,1
        mov     cx,0007h        ;-- cl=00 // ch=07
	int     10h
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ CURSOR_HALF()  ³ Changes the cursor size to big.
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  cursor_half
PROC    cursor_half     FAR

        mov     ah,1
        mov     cx,0407h        ;-- cl=04 // ch=07
	int     10h
        ret
ENDP


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ CLEAR_LINE() ³ Clears the bottom of the display
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  clear_line
PROC    clear_line      FAR
USES    ds,si,di

        call    mouse_hide

        mov     ax,@data
        mov     ds,ax

        mov     ax,screen_addr          ;-- es:bx will have screen address
        mov     es,ax

        mov     ax,whole_screen
        shl     ax,1
        sub     ax,down_lin
        mov     di,ax

        mov     ax,7020h                ;-- Gray+Black + blank space

        mov     cx,cols
        inc     cx

        rep     stosw

        call    mouse_show
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ HLINE(int x,y,x1; char first,mid,last) ³ Draws an horizontal line
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  hline
PROC    hline   FAR
USES    ds,si,di
ARG     x:WORD, y:WORD, x1:WORD, first:BYTE, mid:BYTE, last:BYTE

        mov     ax,@data
        mov     ds,ax

        mov     es,screen_addr

        mov     ax,xadd         ;-- AX = Xadd = Left side

        mov     bx,[x]          ;-- BX = X position
        mov     cx,[x1]         ;-- CX = X1 position
	add     bx,ax
	add     cx,ax

        cmp     bx,cx           ;-- X1 cannot be lower than X
        jle     @@ok0
	xchg    bx,cx

@@ok0:
        cmp     bx,ax           ;-- X is less than Xadd?
        jge     @@ok1

        mov     dl,[mid]        ;-- Adjust beggining of line
	mov     bx,ax
	mov     first,dl

@@ok1:
        cmp     cx,cols         ;-- X1 is out of screen?
        jle     @@ok2
	mov     al,mid
        mov     cx,cols         ;-- Adjust end of line
	mov     last,al

@@ok2:
        sub     cx,bx          ;-- Distance
        js      @@bye           ;-- Exit if no distance (negative)
        jnz     @@ok3           ;-- Check if only one character

        cmp     bx,xadd         ;-- One character at left need fix
        jne     @@ok3
        mov     al,[last]
        mov     [first],al

@@ok3:
        mov     ax,[y]          ;-- Prepare Y position
	add     ax,yadd
        cmp     ax,yadd         ;-- Out of screen?
        jl      @@bye
	cmp     ax,rows
        ja      @@bye

        mul     down_lin        ;-- Adjust Y to screen offset
        shl     bx,1            ;-- Each character = 2 bytes!!
	mov     di,bx
        add     di,ax           ;-- DI has screen offset = X+Y

        mov     ah,syscolor     ;-- Get color

        mov     al,[first]      ;-- Get fist character
	mov     es:[di],ax
	add     di,2

	dec     cx
        js      @@bye           ;-- If only one, that's it
        jz      @@skip          ;-- If only two, print last one

        mov     al,[mid]        ;-- Print middle characters
        rep     stosw

@@skip:
        mov     al,last         ;-- Print last character
	mov     es:[di],ax

@@bye:
        ret
ENDP




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ VLINE(int x,y,x1; char first,mid,last)  ³ Draws a vertical line
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  vline
PROC    vline   FAR
USES    ds,si,di
ARG     x:WORD, y:WORD, y1:WORD, first:BYTE, mid:BYTE, last:BYTE

        mov     ax,@data
        mov     ds,ax

        mov     es,screen_addr

        mov     bx,[x]          ;-- BX = x position
	add     bx,xadd
        cmp     bx,cols         ;-- Check if it's out of bounds
        ja      @@bye2

	cmp     bx,xadd
        jl      @@bye2
        shl     bx,1            ;-- Screen characters are WORDS

        mov     dx,yadd         ;-- DX = yadd

        mov     ax,[y]          ;-- AX = y position
	add     ax,dx

        mov     cx,[y1]         ;-- CX = y1 position
	add     cx,dx

	cmp     ax,cx
        jle     @@ok0           ;-- Jump if y <= y1
	xchg    cx,ax

@@ok0:
        cmp     ax,dx           ;-- Check top character position
        jge     @@ok1

        mov     ax,dx           ;-- Fix first position and character
        mov     dl,[mid]
	mov     first,dl

@@ok1:
        mov     si,ax           ;-- SI has y position
	mul     down_lin
        add     bx,ax           ;-- BX = Xaddress + Yaddress

        cmp     cx,yadd         ;-- Check y1 coordinate if onscreen
        jl      @@bye2
	cmp     cx,rows
        jbe     @@ok2

        mov     cx,rows         ;-- Adjust y1 position
        mov     al,[mid]
        mov     [last],al       ;-- Adjust last character

@@ok2:
        sub     cx,si           ;-- CX = y1 - y = distance
        js      @@bye2          ;-- No distance = nothin
        jnz     @@cont          ;-- Check if only one char

        mov     dl,[last]
	mov     first,dl

@@cont:
        mov     dx,down_lin

        mov     ah,syscolor     ;-- Get color and character
	mov     al,first

        mov     es:[bx],ax      ;-- Plot first character
	dec     cx
        js      @@bye           ;-- Counter is negative if is one
        jz      @@skip          ;-- Counter is zero if are two chars

	mov     al,mid
@@store:
        add     bx,dx           ;-- Go down
        mov     es:[bx],ax      ;-- Store middle characters
	dec     cx
        jnz     @@store

@@skip:
        add     bx,dx
	mov     al,last
        mov     es:[bx],ax      ;-- Store last character
@@bye:
        sti
@@bye2:
        ret
ENDP



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³ PRINT(int x,y; char far pastring) ³ Prints a message on the screen
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC  print
PROC    print   FAR
USES    ds,si,di
ARG     x:WORD, y:WORD, txt:DWORD

        mov     ax,@data
        mov     ds,ax

        mov     es,screen_addr  ;-- es:di has screen address

        mov     ax,[y]
	add     ax,yadd
        cmp     ax,rows         ;-- y must be on-screen
        jg      @@bye
	cmp     ax,yadd
        jl      @@bye

        mul     down_lin        ;-- get y screen position

        mov     cx,xadd         ;-- cx = xadd = window left side

        mov     bx,[x]
	add     bx,cx
        cmp     bx,cols         ;-- check if it will display
        jg      @@bye

        xor     dx,dx           ;-- dx has # of unseen chars
        cmp     bx,cx           ;-- all characters are on screen?
        jnl     @@ok

        mov     dx,cx           ;-- count unseen characters
	sub     dx,bx
	add     bx,dx

@@ok:
        shl     bx,1            ;-- get x screen address
	add     ax,bx
        mov     di,ax           ;-- so es:di has screen position

        mov     cx,cols         ;-- store columns temporary
        mov     ch,syscolor     ;-- store syscolor

        lds     si,[txt]        ;-- ds:si = string address

        mov     al,ds:[si]      ;-- get string length
	inc     si

        add     si,dx           ;-- add unseen chars to string ptr
	xor     ah,ah
        sub     ax,dx           ;-- substract to length of string
        jle     @@bye

        mov     ah,ch           ;-- ah has syscolor
        xor     dx,dx           ;-- dx has cols
	mov     dl,cl

        xor     cx,cx           ;-- cx has count of characters
	mov     cl,al

        shr     bx,1            ;-- check string & right border
	add     bx,cx
	cmp     bx,dx
        jng     @@ok2

        sub     bx,dx           ;-- adjust # of chars to display
	dec     bx
	sub     cx,bx

@@ok2:
        mov     dl,255          ;-- dl has escape sequence
        mov     dh,11110000b    ;-- Mask color
        mov     bl,15           ;-- Color select


@@plot:
        mov     al,ds:[si]      ;-- Get char...
	inc     si

	cmp     al,bl
        ja      @@cont

        and     ah,dh           ;-- Change text color
	or      ah,al
	dec     cx
        jnz     @@plot
        jmp     @@bye

@@cont:
        cmp     al,dl           ;-- Escape sequence (255)?
        jne     @@noes

        mov     al,ds:[si]      ;-- Get new character
	inc     si

@@noes:
        mov     es:[di],ax
	add     di,2
	dec     cx
        jnz     @@plot

@@bye:
        ret
ENDP




;--------------------------
  Filled text box
--------------------------
procedure Fill(x,y,x1,y1:integer ; paint:char); assembler;
asm
	mov     es,screen_addr

        mov     ax,xadd         ;-- ax = xadd = Left side
        mov     dx,cols         ;-- dx = cols

        mov     bx,x            ;-- bx = x
	add     bx,ax

        mov     cx,x1           ;-- cx = x1
	add     cx,ax

        cmp     bx,cx           ;-- x1 < x ?
        jle     @@ok0
	xchg    bx,cx

@@ok0:   cmp     bx,dx           ;-- x cannot be out of bounds
        jg      @@bye

        cmp     bx,ax           ;-- x is less than xadd?
        jge     @@ok1
        mov     bx,ax           ;-- adjust x

@@ok1:   cmp     cx,dx           ;-- x1 is out of screen?
        jle     @@ok2
        mov     cx,dx           ;-- Adjust x1

@@ok2:   sub     cx,bx           ;-- Distance
	inc     cx
        jle     @@bye            ;-- must be 1 or greater

        mov     ax,y            ;-- Prepare y position
	mov     dx,y1

;--
        mov     di,yadd         ;-- di = yadd for a while
        mov     si,rows         ;-- si = rows for a while

        mov     ax,y            ;-- ax = y position
	add     ax,di

        mov     dx,y1           ;-- dx = y1 position
	add     dx,di

	cmp     ax,dx
        jle     @@ok3            ;-- Jump if y <= y1
	xchg    dx,ax

@@ok3:   cmp     ax,si           ;-- check y with bottom line
        jg      @@bye
        cmp     ax,di           ;-- Check y with top line
        jge     @@ok4

        mov     ax,di           ;-- Fix top line

@@ok4:   cmp     dx,di           ;-- check y1 with top border
        jl      @@bye
        cmp     dx,si           ;-- check y1 with bottom
        jle     @@ok5

	mov     dx,si

@@ok5:   sub     dx,ax           ;-- si = distance
	inc     dx
        jle     @@bye            ;-- must be > 0
	mov     si,dx

        mul     down_lin        ;-- Adjust y to screen offset
        shl     bx,1            ;-- Each character = 2 bytes!!
	mov     di,bx
        add     di,ax           ;-- DI has screen offset = X+Y

        mov     bx,di           ;-- BX has a copy of screen offset
        mov     dx,cx           ;-- DX has a copy of # of chars

        mov     ah,syscolor     ;-- Get color
        mov     al,paint        ;-- Get character

	cli
@@Doit:  rep     stosw
	add     bx,down_lin
	mov     di,bx
	mov     cx,dx
	dec     si
        jnz     @@Doit
	sti
@@bye:
end;

;-------------------------------
   Stores the screen in Page
--------------------------------
procedure get_screen(page:pointer); assembler;
asm
	push	ds
        les     di,page                 ;-- es:di = buffer dest.

	mov     cx,whole_screen

        mov     ds,screen_addr          ;-- ds:si = screen source
	xor     si,si

	rep     movsw
	pop	ds
end;

;---------------------------------
   Put the Page in the screen
----------------------------------
procedure put_screen(page:pointer); assembler;
asm
	push	ds
	mov     cx,whole_screen

        mov     es,screen_addr          ;-- es:di = screen dest
	xor	di,di

        lds     si,page                 ;-- ds:si = buffer source

	rep     movsw
	pop	ds
end;


;--------------------------------
     Scroll window left
---------------------------------
procedure scroll_l(x,y,x1,y1:integer); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd

        mov     bx,x            ;-- Get x and x1 position
	add     bx,ax

	mov     dx,x1
	add     dx,ax
        sub     dx,bx           ;-- Get x distance
        jle     @@bye            ;-- distance must be > 0

	mov     ax,yadd
        mov     cx,y1           ;-- cx = y1
	add     cx,ax
        add     ax,y            ;-- ax = y + yadd
        sub     cx,ax           ;-- cl = y distance
        jle     @@bye            ;-- Must be more than one

        mov     ch,dl           ;-- ch = x distance
	inc     cl

        mov     si,down_lin     ;-- si = y increment

        shl     bx,1            ;-- calculate screen y position
	mul     si
	add     bx,ax

        mov     di,bx           ;-- di = copy of position

	cli

@@doit:  mov     dl,ch

@@hstep: mov     ax,es:[bx+2]
	mov     es:[bx],ax
	add     bx,2
	dec     dl
        jnz     @@hstep

	mov     al,32
	mov     es:[bx],ax

	add     di,si
	mov     bx,di
	dec     cl
        jnz     @@doit
	sti
@@bye:
end;

;--------------------------------
       Scroll window up
---------------------------------
procedure scroll_u(x,y,x1,y1:integer); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd

        mov     bx,x            ;-- Get x and x1 position
	add     bx,ax

	mov     dx,x1
        add     dx,ax
        sub     dx,bx           ;-- Get x distance
        jle     @@bye

        mov     ax,yadd
        mov     cx,y1           ;-- cx = y1
        add     cx,ax
        add     ax,y            ;-- ax = yadd + y
        sub     cx,ax           ;-- cl = y distance
        jle     @@bye            ;-- Must be more than one

        mov     ch,dl           ;-- ch = x distance
        inc     ch

        mov     si,down_lin     ;-- si = y increment

        shl     bx,1            ;-- calculate screen y position
        mul     si
        add     bx,ax

        mov     di,bx           ;-- di = copy of position
        cli

@@doit:  mov     dl,ch

@@hstep: mov     ax,es:[bx+si]
        mov     es:[bx],ax
        add     bx,2
        dec     dl
        jnz     @@hstep

        add     di,si
        mov     bx,di
	dec     cl
        jnz     @@doit

        mov     cl,ch
        xor     ch,ch
        mov     al,32
@@clir:  rep     stosw
        sti
@@bye:
end;

;--------------------------------
     Scroll window right
---------------------------------
procedure scroll_r(x,y,x1,y1:integer); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd

        mov     bx,x1           ;-- bx and dx = x1
        add     bx,ax
        mov     dx,bx

        add     ax,x
        sub     dx,ax           ;-- dx = x1-x = distance
        jle     @@bye

        mov     ax,yadd         ;-- Get y and y1 position

        mov     di,y            ;-- di = y
        add     di,ax

        mov     cx,y1           ;-- cx = y1 + ax
        add     cx,ax
        sub     cx,di           ;-- cl = y1-y = distance
        jle     @@bye            ;-- Must be more than one

        add     ax,di           ;-- ax = addx + y

        mov     ch,dl           ;-- ch = x distance
        inc     cl

        mov     si,down_lin     ;-- si = y increment

        shl     bx,1
        mul     si              ;-- calculate screen y position
        add     bx,ax

        mov     di,bx           ;-- di = copy of position
        cli

@@doit:  mov     dl,ch

@@hstep: mov     ax,es:[bx-2]
        mov     es:[bx],ax
        sub     bx,2
	dec     dl
        jnz     @@hstep

        mov     al,32
        mov     es:[bx],ax

        add     di,si
        mov     bx,di
        dec     cl
        jnz     @@doit
        sti
@@bye:
end;

;--------------------------------
     Scroll window down
---------------------------------
procedure scroll_d(x,y,x1,y1:integer); assembler;
asm
	mov     es,screen_addr

        mov     ax,xadd

        mov     bx,x            ;-- Get x and x1 position
        add     bx,ax

        mov     dx,x1
        add     dx,ax
        sub     dx,bx           ;-- Get x distance
        jle     @@bye

        mov     di,yadd
        mov     cx,y1           ;-- cx = y1
        add     cx,di
        mov     ax,cx           ;-- ax = y1 + yadd
        add     di,y            ;-- di = yadd + y
        sub     cx,di           ;-- cl = y distance
        jle     @@bye            ;-- Must be more than one

        mov     ch,dl           ;-- ch = x distance
	inc     ch

        shl     bx,1            ;-- calculate screen y position
        mul     down_lin
        add     bx,ax

        mov     di,bx           ;-- di = copy of position
        mov     si,bx
        sub     si,down_lin
        cli

@@doit:  mov     dl,ch

@@hstep: mov     ax,es:[si]
        mov     es:[bx],ax
        add     bx,2
        add     si,2
        dec     dl
        jnz     @@hstep

	sub     di,down_lin
        mov     bx,di
        mov     si,bx
        sub     si,down_lin

        dec     cl
        jnz     @@doit

        mov     cl,ch
        xor     ch,ch
        mov     al,32
@@clir:  rep     stosw
        sti
@@bye:
end;


;-------------------------
	  Text Box
-------------------------
procedure tbox(x,y,x1,y1:integer ; var bar:str12);
begin
asm
        mov     ax,x            ;-- Check coordinates
	cmp     x1,ax
        jle     @@ok
	xchg    ax,x1

@@ok:    mov     x,ax

	mov     ax,y
	cmp     ax,y1
        jle     @@ok2
	xchg    ax,y1

@@ok2:   mov     y,ax
end;
 hline(x,y,x1,bar[1],bar[2],bar[3]);
 hline(x,y1,x1,bar[4],bar[5],bar[6]);
 dec(y1,1);
 inc(y,1);
 vline(x,y,y1,bar[7],bar[8],bar[9]);
 vline(x1,y,y1,bar[10],bar[11],bar[12]);
end;



procedure tboxfill(x,y,x1,y1:integer ; var bar:str12);
begin
asm
	mov     ax,x
	cmp     ax,x1
        jle     @@ok
	xchg    ax,x1
@@ok:    mov     x,ax

	mov     ax,y
	cmp     ax,y1
        jle     @@ok2
	xchg    ax,y1

@@ok2:   mov     y,ax
end;
 hline(x,y,x1,bar[1],bar[2],bar[3]);
 hline(x,y1,x1,bar[4],bar[5],bar[6]);
 dec(y1,1);
 inc(y,1);
 vline(x,y,y1,bar[7],bar[8],bar[9]);
 vline(x1,y,y1,bar[10],bar[11],bar[12]);
 inc(x,1);
 dec(x1,1);
 fill(x,y,x1,y1,' ');
end;


;---------------------------
  Resets window to default
  coordinates.
----------------------------
procedure reset_window; assembler;
asm
	xor     ax,ax
	mov     xadd,ax
	mov     yadd,ax

	mov     ax,maxcols
	mov     bx,maxrows
	mov     cols,ax
	mov     rows,bx
end;

;--------------------------------
  Defines the window coordinate.
  Default: 0,0,maxcols,maxrows
   - Does not check values -
--------------------------------
procedure window(x,y,x1,y1:integer); assembler;
asm
	mov     ax,x
	mov     bx,x1
	cmp     ax,bx
        jl      @@ok
        jz      @@bye
	xchg    ax,bx

@@ok:    mov     xadd,ax
	mov     cols,bx

	mov     ax,y
	mov     bx,y1
	cmp     ax,bx
        jl      @@ok2
        jz      @@bye
	xchg    ax,bx

@@ok2:   mov     yadd,ax
	mov     rows,bx

@@bye:
end;

;----------------------------
  Darken a horizontal line
-----------------------------
procedure shadow_x(x,y,x1 : integer); assembler;
asm
	mov     es,screen_addr

        mov     ax,y            ;-- ax = y coordinate
	add     ax,yadd
        cmp     ax,yadd         ;-- y is out of bounds?
        jl      @@bye
	cmp     ax,rows
        jg      @@bye
	mul     down_lin

        mov     si,xadd         ;-- commonly used...
	mov     di,cols

        mov     bx,x            ;-- bx = x
        add     bx,si

        mov     cx,x1           ;-- cx = x1
        add     cx,si

        cmp     bx,cx
        jle     @@ok
	xchg    bx,cx

@@ok:    cmp     bx,di           ;-- x > cols?
        jg      @@bye

        cmp     bx,si           ;-- x < left?
        jge     @@ok2
	mov     bx,si

@@ok2:   cmp     cx,si           ;-- x1 < left?
        jb      @@bye

        cmp     cx,di           ;-- x1 > cols?
        jle     @@ok3
	mov     cx,di

@@ok3:   cmp     bx,cx           ;-- x1 less than x
        jg      @@bye

        sub     cx,bx           ;-- cx = distance
	inc     cx

	shl     bx,1
	add     bx,ax
	inc     bx

	mov     al,sysshadow
	mov     dx,2

@@doit:  mov     es:[bx],al
	add     bx,dx
        loop    @@doit
@@bye:
end;

;----------------------------
  Darken a vertical line
-----------------------------
procedure shadow_y(x,y,y1 : integer); assembler;
asm
	mov     es,screen_addr

	mov     ax,xadd
        mov     bx,x            ;-- bx = x
	add     bx,ax
	cmp     bx,ax
        jl      @@bye
	cmp     bx,cols
        jg      @@bye
	shl     bx,1

        mov     dx,yadd

        mov     ax,y            ;-- ax = y position
        add     ax,dx

        mov     cx,y1           ;-- cx = y1 position
        add     cx,dx

        cmp     ax,cx           ;-- swap y,y1 if necessary
        jle     @@ok
	xchg    cx,ax

@@ok:    mov     si,rows         ;-- si=rows //  dx=yadd

        cmp     ax,si           ;-- y > bottom?
        jg      @@bye

        cmp     cx,dx           ;-- y1 < top?
        jl      @@bye

        cmp     ax,dx           ;-- y needs top chop?
        jge     @@ok1
	mov     ax,dx

@@ok1:   cmp     cx,si           ;-- y1 needs bottom chop?
        jle     @@ok2
	mov     cx,si

@@ok2:   cmp     ax,cx
        jg      @@bye

        sub     cx,ax           ;-- get distance
	inc     cx

        mul     down_lin        ;-- get y position
        add     bx,ax           ;-- bx = x + y

	mov     al,sysshadow
	mov     dx,down_lin
	inc     bx

@@doit:  mov     es:[bx],al
	add     bx,dx
        loop    @@doit
@@bye:
end;


;-------------------------
  Creates the box shadow
--------------------------
procedure shadowbox(x,y,x1,y1:integer);
begin
asm
	mov     ax,x
	mov     bx,x1
	cmp     ax,bx
        jle     @@ok
	xchg    ax,bx

@@ok:    add     al,2
	add     bl,2
	mov     x,ax
	mov     x1,bx

	mov     ax,y
	mov     bx,y1
	cmp     ax,bx
        jle     @@ok2
	xchg    ax,bx

@@ok2:   inc     ax
	inc     bx
	mov     y,ax
	mov     y1,bx
end;
 shadow_x(x,y1,x1);
 shadow_y(x1,y,y1);
 shadow_y(x1-1,y,y1);
end;

procedure autoexec; assembler;
asm
	xor     ax,ax
	xor     bx,bx

	mov     mouse,ax
	mov     mk,bx
	mov     mx,ax
	mov     my,bx

end;


procedure help(bs:string);
var i : byte;
begin
 i:=syscolor;
 syscolor:=$70;
 clear_line;
 bs:='³İÛ²±° '+bs;
 mouse_hide;
 print(1,rows,bs);
 mouse_show;
 syscolor:=i;
end;


;------------------------
     Fast uppercase
-------------------------
procedure upcase(var bs:string); assembler;
asm
	mov     ax,[bp+8]
	mov     es,ax
	mov     bx,[bp+6]
	xor     cx,cx
	mov     cl,es:[bx]

	mov     ah,'a'
	mov     dl,'z'
	mov     dh,223

        jcxz    @@bye

@@doit:  inc     bx
	mov     al,es:[bx]
        cmp     al,ah           ;-- al < 'a'?
        jb      @@skip
        cmp     al,dl           ;-- al > 'z'?
        ja      @@skip
        and     al,dh           ;-- clear bit
	mov     es:[bx],al
@@skip:  loop    @@doit
@@bye:
end;


;-----------------------------
  convert string to lowercase
------------------------------
procedure lowcase(var bs:string); assembler;
asm
	mov     ax,[bp+8]
	mov     es,ax
	mov     bx,[bp+6]
	xor     cx,cx
	mov     cl,es:[bx]

	mov     ah,'A'
	mov     dl,'Z'
	mov     dh,32

        jcxz    @@bye

@@doit:  inc     bx
	mov     al,es:[bx]
        cmp     al,ah           ;-- al < 'A'?
        jb      @@skip
        cmp     al,dl           ;-- al > 'Z'?
        ja      @@skip
        or      al,dh           ;-- set bit
	mov     es:[bx],al
@@skip:  loop    @@doit
@@bye:
end;


;------------------
  Generate sound
------------------
procedure sound(Hz:WORD); assembler;
asm
	mov	bx,Hz
	cmp     bx,12h
        jna     @@bye

	mov	dx,43h

	mov     ax,34DDh
	div     bx
	mov     bx,ax

	in      al,61h
	test    al,3
        jne     @@nope
	or      al,3
	out     61h,al
	mov     al,0B6h
	out     dx,al

@@nope:  mov     al,bl
	dec	dx

	out     dx,al
	mov     al,bh
	out     dx,al
@@bye:
end;


;------------------------------
      Turn off sound
-------------------------------
procedure nosound; assembler;
asm
	in      al,61H
	and     al, 0fcH
	out     61H, al
end;

;--------------------------
  Change the color palette
---------------------------
procedure vgapalette(color,red,green,blue:integer); assembler;
asm
		mov	dx,03C8h
		mov	bl,63
		mov	ax,color
		out	dx,al
		inc	dx
		mov	ax,red
		and	al,bl
		out	dx,al
		mov	ax,green
		and	al,bl
		out	dx,al
		mov	ax,blue
		and	al,bl
		out	dx,al
end;


;---------------------------
     Set the break flag
----------------------------
procedure break_off; assembler;
asm
	xor	dl,dl
	mov	ax,3301h
	int	21h
end;

procedure break_on; assembler;
asm
	mov	dl,1
	mov	ax,3301h
	int	21h
end;


;------------------------------------------------------------
  Clears screen, original colors, hide mouse and show cursor
---------------------------------------------------------------
procedure reset_screen;
begin
 mouse_hide;
 syscolor:=$07;
 cls(' ');
 gotoxy(0,0);
 cursor_small;
end;


;----------------------------------------------------------
begin
 init_video;
 autoexec;
 screen1:=@@crtlogo1;
 getmem(screen2,8192);
 getmem(screen3,8192);
 getmem(screen4,8192);
end.


;  ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;  º		 PALETTE Library	    º
;  º	   Version 1.10 - May/01/1995	    º
;  º----------------------------------------º
;  º Copyright (c) 1993,95 Marco A. Marrero º
;  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼



;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_ENTRY(char color,r,g,b)	º Change palette  º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_ENTRY
PROC	PAL_ENTRY	FAR
ARG	color:BYTE, red:BYTE, green:BYTE, blue:BYTE

	mov	dx,03C8h
	mov	al,[color]
	out	dx,al
	inc	dx

	mov	al,[red]
	out	dx,al
	mov	al,[green]
	out	dx,al
	mov	al,[blue]
	out	dx,al

	ret
ENDP




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_SET(void far table)  º Set all palette º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_SET
PROC	PAL_SET         FAR
ARG     ptable:DWORD
USES	ds,si

	lds	si,[ptable]	;-- ds:si points to color table
	mov	dx,03C8h	;-- Palette adress
	xor	ax,ax		;-- Update from color 0
	out	dx,al
	inc	dx
	mov	cx,768		;-- 768 values

	rep	outsb		;-- Update 768 palette entries

	ret
ENDP



;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_ALL(r,g,b:byte) º Set all palette º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_ALL
PROC	PAL_ALL         FAR
ARG	r:BYTE, g:BYTE, b:BYTE

	mov	ah,[r]		;-- ah = RED
	mov	bh,[g]		;-- bh = GREEN
	mov	bl,[b]		;-- bl = BLUE

	mov	dx,03C8h	;-- Palette adress/Index
	xor	al,al		;-- Update from color 0
	out	dx,al
	inc	dx		;-- Palette write address

	mov	cx,256		;-- 256 colors to update

@@@@doit:
	mov	al,ah		;-- red
	out	dx,al

	mov	al,bh		;-- green
	out	dx,al

	mov	al,bl		;-- blue
	out	dx,al
        loop    @@@@doit

	ret
ENDP




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_FADE(void far palette, int delay) º Fades palette   º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_FADE
PROC	PAL_FADE        FAR
ARG     pal:DWORD, delay:WORD
USES	ds,si,di

	lds	si,[pal]	;-- ds:si = palette to fade

	mov	ax,cs		;-- es:di = working palette
	mov	es,ax
	mov	di,offset mypal

	mov	cx,768/4	;-- Copy palette to working
	rep	movsd

	mov	di,offset mypal ;-- di = working palette offset
	mov	ds,ax		;-- ds:si = working palette

	mov	bl,63		;-- bl = 63 palette changes...

@@@@prepare:
	mov	cx,768		;-- Let's modify palette now
	mov	si,di		;-- si = working palette

@@@@work:
	mov	al,[ds:si]	;-- Get entry color
	dec	al		;-- Decrement
	cmp	al,255
        jne     @@@@ok            ;-- If >0 then it's ok
	xor	al,al

@@@@ok:   mov     [ds:si],al      ;-- Update...
	inc	si

        loop    @@@@work          ;-- 768 times!

@@@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay + 1
	inc	cx

@@@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
        jnz     @@@@v_still

@@@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
        jz      @@@@v_wait

        loop    @@@@v_still

@@@@setit:
	mov	dx,03c8h	;-- Palette address
	mov	cx,768		;-- 768 palette entries
	xor	ax,ax		;-- Color index

	out	dx,al		;-- Start from color 0
	inc	dx		;-- Palette data port

	mov	si,di		;-- Restore palette table
	rep	outsb

	dec	bl
        jnz     @@@@prepare

	ret
ENDP




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_LIGHT(void far pal, int delay) º Lightens palette º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_LIGHT
PROC	PAL_LIGHT       FAR
ARG     pal:DWORD, delay:WORD
USES	ds,si,di

	lds	si,[pal]	;-- ds:si = palette to fade

	mov	ax,cs		;-- es:di = working palette
	mov	es,ax
	mov	di,offset mypal

	mov	cx,768/4	;-- Copy palette to working
	rep	movsd

	mov	di,offset mypal ;-- di = working palette offset
	mov	ds,ax		;-- ds:si = working palette

	mov	bl,63		;-- bl = 63 palette changes...

@@@@prepare:
	mov	cx,768		;-- Let's modify palette now
	mov	si,di		;-- si = working palette

@@@@work:
	mov	al,[ds:si]	;-- Get entry color
	inc	al		;-- Decrement
	cmp	al,63
        jbe     @@@@ok            ;-- If <63 then it's ok
	mov	al,63

@@@@ok:   mov     [ds:si],al      ;-- Update...
	inc	si

        loop    @@@@work          ;-- 768 times!

@@@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay + 1
	inc	cx

@@@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
        jnz     @@@@v_still

@@@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
        jz      @@@@v_wait

        loop    @@@@v_still

@@@@setit:
	mov	dx,03c8h	;-- Palette address
	xor	ax,ax		;-- Start from color 0
	out	dx,al
	inc	dx		;-- Palette data port

	mov	si,di		;-- Restore palette table

	mov	cx,768		;-- 768 palette entries
	rep	outsb		;-- Send palette...

	dec	bl
        jnz     @@@@prepare

	ret
ENDP






;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_UNFADE(void far pal, int delay) º Unfades palette º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_UNFADE
PROC	PAL_UNFADE      FAR
ARG     pal:DWORD, delay:WORD
USES	ds,si,di

	mov	ax,cs		;-- ds:si = Working palette
	mov	ds,ax
	mov	si,offset mypal

	mov	cx,768/4	;-- Copy palette to working
	mov	dx,4
	xor	eax,eax

@@@@palblank:
	mov	[ds:si],eax
	add	si,dx
        loop    @@@@palblank

	mov	bl,63		;-- bl = 63 palette changes...

@@@@prepare:

	mov	cx,768		;-- Let's modify palette now
	mov	si,offset mypal ;-- ds:si = working palette
	les	di,[pal]	;-- es:di = original palette

@@@@work:
	mov	al,[ds:si]	;-- Get entry color
	inc	al		;-- Increment
	cmp	al,[es:di]
        jbe     @@@@ok            ;-- If color <= original then it's ok
	dec	al

@@@@ok:
	mov	[ds:si],al	;-- Update...
	inc	si
	inc	di

        loop    @@@@work          ;-- 768 times!

@@@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay + 1
	inc	cx

@@@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
        jnz     @@@@v_still

@@@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
        jz      @@@@v_wait

        loop    @@@@v_still

@@@@setit:
	mov	dx,03c8h	;-- Palette address (index)
	xor	ax,ax		;-- Update from color 0
	out	dx,al		;-- Set.
	inc	dx		;-- Palette data

	mov	si,offset mypal ;-- Restore palette table
	mov	cx,768		;-- 768 color palette entries
	rep	outsb		;-- Set palette

	dec	bl
        jnz     @@@@prepare

	ret
ENDP




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_UNLIGHT(void far pal, int delay) º Unlights palette  º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_UNLIGHT
PROC	PAL_UNLIGHT     FAR
ARG     pal:DWORD, delay:WORD
USES	ds,si,di

	mov	ax,cs		;-- ds:si = Working palette
	mov	ds,ax
	mov	si,offset mypal

	mov	cx,768/4	;-- Copy palette to working
	mov	dx,4

	mov	al,63
	mov	ah,al
	mov	bx,ax
	shl	eax,16
	mov	ax,bx

@@@@palblank:
	mov	[ds:si],eax
	add	si,dx
        loop    @@@@palblank

	mov	bl,63		;-- bl = 63 palette changes...

@@@@prepare:
	mov	cx,768		;-- Let's modify palette now
	mov	si,offset mypal ;-- ds:si = working palette
	les	di,[pal]	;-- es:di = original palette

@@@@work:
	mov	al,[ds:si]	;-- Get entry color
	dec	al		;-- Decrement
	cmp	al,[es:di]
        jae     @@@@ok            ;-- If color >= original then it's ok
	inc	al

@@@@ok:   mov     [ds:si],al      ;-- Update...
	inc	si
	inc	di

        loop    @@@@work          ;-- 768 times!

@@@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay + 1
	inc	cx

@@@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
        jnz     @@@@v_still

@@@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
        jz      @@@@v_wait

        loop    @@@@v_still

@@@@setit:
	mov	dx,03c8h	;-- Palette address index (color)
	xor	ax,ax		;-- Start from 0
	out	dx,al
	inc	dx		;-- Palette data


	mov	cx,768		;-- 768 palette entries
	mov	si,offset mypal ;-- Get palette offset
	rep	outsb		;-- Quick! hurry up!

	dec	bl
        jnz     @@@@prepare

	ret
ENDP




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_MODIFY(int delay, void far pal, char r,g,b) º Modifies palette  º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_MODIFY
PROC	PAL_MODIFY      FAR
ARG     delay:WORD, pal:DWORD, r:WORD, g:WORD, b:WORD
USES	ds,di,si

	mov	ax,cs		;-- es:di = Working palette
	mov	es,ax
	mov	di,offset mypal

	mov	dx,63		;-- To speed up things...
	lds	si,[pal]	;-- ds:si = Original palette
	mov	cx,256		;-- 256 colors

@@@@modi: xor     ax,ax           ;-- Clear color
	lodsb			;-- mov al,ds:[si] = Red
	add	ax,[r]		;-- add red modifier

        jns     @@@@r1
	xor	ax,ax

@@@@r1:   cmp     ax,dx           ;-- Is greater than 63?
        jle     @@@@r2
	mov	ax,dx

@@@@r2:   stosb                   ;-- mov es:[di],al
	xor	ax,ax		;-- Clear color
	lodsb			;-- mov al,ds:[si] = Green
	add	ax,[g]		;-- add green modifier

        jns     @@@@g1            ;-- If negative, color must be zeroed
	xor	ax,ax

@@@@g1:   cmp     ax,dx           ;-- If greater than 63, color = 63
        jle     @@@@g2
	mov	ax,dx

@@@@g2:   stosb                   ;-- mov es:[di],al
	xor	ax,ax		;-- Clear color
	lodsb			;-- mov al,ds:[si] = Blue
	add	ax,[b]		;-- add blue modifier

        jns     @@@@b1            ;-- Is negative?
	xor	ax,ax

@@@@b1:   cmp     ax,dx           ;-- Is greater than 63?
        jle     @@@@b2
	mov	ax,dx

@@@@b2:   stosb                   ;-- mov es:[di],al
        loop    @@@@modi


;--- Let's prepare some data before synching ---
	mov	ax,cs		;-- Get palette segment
	mov	ds,ax		;-- into DS

@@@@vsynch:
	mov	dx,03dah	;-- Let's synch to the screen
	mov	cx,[delay]	;-- cx = delay

	or	cx,cx		;-- if cx is negative, do not synch.
        js      @@@@prepare
	inc	cx

@@@@v_still:
	in	al,dx		;-- If you're in VSYNCH, get out of it.
	test	al,08h
        jnz     @@@@v_still

@@@@v_wait:
	in	al,dx		;-- Now, wait VSYNCH...
	test	al,08h
        jz      @@@@v_wait
        loop    @@@@v_still

@@@@prepare:

	mov	dx,03c8h	;-- Palette index (color)
	xor	ax,ax		;-- Start from color 0
	out	dx,al
	inc	dx		;-- Palette data


	mov	cx,768		;-- 768 palette entries
	mov	si,offset mypal ;-- Palette offset
	rep	outsb

	ret
ENDP




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º VGA_PAL16() º Sets VGA mode for 16 colors   º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	VGA_PAL16
PROC	VGA_PAL16       FAR

	mov	dx,3dah 	;-- now use a linear palette, dacs 0-15.
	in	al,dx
	mov	dx,3c0h 	;-- mode control register,
	mov	al,10h
	out	dx,al
	inc	dx
	in	al,dx		;-- read it.
	dec	dx
	mov	ah,al
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,10h
	out	dx,al
	mov	al,ah		;-- force get bits p4&p5 from reg #14.
	or	al,80h
	out	dx,al

	mov	al,14h
	out	dx,al
	xor	al,al
	out	dx,al		;-- force dac index bits p4-p7 == 0.

	mov	cx,16
	xor	al,al
@@@@pl1:
	out	dx,al		;-- output index.
	out	dx,al		;-- output value. value == index.
	inc	al
        loop    @@@@pl1

	mov	al,34h		;-- redo it, activating the vga along.
	out	dx,al
	xor	al,al
	out	dx,al		;-- force dac index bits p4-p7 == 0.
	ret
ENDP





;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_WORD2PAL(void far pal) º Copy working palette to palette  º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_WORK2PAL
PROC	PAL_WORK2PAL    FAR
ARG     pal:DWORD
USES	ds,si,di

	les	di,[pal]	;-- Get destination palette address
	mov	ax,cs		;-- And source too..
	mov	ds,ax
	mov	si,offset mypal

	mov	cx,768/4	;-- Entries...
	rep	movsd		;-- Move them

	ret
ENDP


;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_SPREAD(int r,g,b; far *pal; int r+,g+,b+; WORD start,end)º Create palº
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_SPREAD
PROC	PAL_SPREAD	FAR
ARG     r:WORD,g:WORD,b:WORD,pal:DWORD,radd:WORD,gadd:WORD,badd:WORD,start:WORD,ending:WORD
USES	di

	les	di,[pal]	;-- es:di = starting palette

	mov	bx,[start]	;-- bx = starting color
	cmp	bx,255		;-- way too high or low?
        jg      @@@@bye           ;---- yep.. nothing to do

	mov	cx,[ending]	;-- cx = ending color
	cmp	cx,255		;-- way too high or low?
        jg      @@@@bye           ;--- yep... Retire

	cmp	cx,bx		;-- start>end?
        jae     @@@@ok            ;-- no problemo
	xchg	cx,bx		;-- exchange values

@@@@ok:
	sub	cx,bx		;-- number of entries + 1
	inc	cx

	mov	ax,3		;-- 3 * start = palette offset
	mul	bx		;-- done..
	add	di,ax		;-- add [di] the result to get address

	mov	ax,[r]		;-- r,g,b initial values
	mov	bx,[g]
	mov	dx,[b]

@@@@fun:

;--- red ---
	add	ax,[radd]	;-- add red stuff
        jns     @@@@r_ok1         ;-- if (ax<0) then ax=0
	xor	ax,ax
@@@@r_ok1:
	cmp	ax,63		;-- if (ax>63) then ax=63
        jbe     @@@@r_ok2
	mov	ax,63

@@@@r_ok2:
;--- green ---
	add	bx,[gadd]	;-- add green stuff
        jns     @@@@g_ok1         ;-- if (bx<0) then bx=0
	xor	bx,bx
@@@@g_ok1:
	cmp	bx,63		;-- if (bx>63) then bx=63
        jbe     @@@@g_ok2
	mov	bx,63

@@@@g_ok2:
;--- blue ---
	add	dx,[badd]	;-- add blue stuff
        jns     @@@@b_ok1         ;-- if (dx<0) then dx=0
	xor	dx,dx

@@@@b_ok1:
	cmp	dx,63		;-- if (ax>63) then ax=63
        jbe     @@@@b_ok2
	mov	dx,63

@@@@b_ok2:
	stosb			;-- mov ax,[es:di++]
	mov	[es:di],bl	;-- store colors
	inc	di
	mov	[es:di],dl
	inc	di

        loop    @@@@fun

@@@@bye:
	ret
ENDP




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_CHANGE(far *pal; int r,g,b; WORD start,end)º Change palº
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_CHANGE
PROC	PAL_CHANGE	FAR
ARG     pal:DWORD,r:WORD,g:WORD,b:WORD,start:WORD,ending:WORD
USES	ds,si,es,di

	les	di,[pal]	;-- es:di = starting palette
	lds	si,[pal]	;-- ds:si = the same stuff too

	mov	bx,[start]	;-- bx = starting color
	cmp	bx,255		;-- way too high or low?
        jg      @@@@bye           ;---- yep.. nothing to do

	mov	cx,[ending]	;-- cx = ending color
	cmp	cx,255		;-- way too high or low?
        jg      @@@@bye           ;--- yep... Retire

	cmp	cx,bx		;-- start>end?
        jae     @@@@ok            ;-- no problemo
	xchg	cx,bx		;-- exchange values

@@@@ok:
	sub	cx,bx		;-- number of entries + 1
	inc	cx

	mov	ax,3		;-- 3 * start = palette offset
	mul	bx		;-- done..

	add	di,ax		;-- add [di] the result to get address
	add	si,ax		;-- Of both.

	xor	ax,ax		;-- Clear ah.

@@@@fun:
;--- red ---
	lodsb			;-- Get color
	add	ax,[r]		;-- add red stuff
        jns     @@@@r_ok1         ;-- if (ax<0) then ax=0
	xor	ax,ax
@@@@r_ok1:
	cmp	ax,63		;-- if (ax>63) then ax=63
        jbe     @@@@r_ok2
	mov	ax,63

@@@@r_ok2:
	stosb
;--- green ---
	lodsb
	add	ax,[g]		;-- add green stuff
        jns     @@@@g_ok1         ;-- if (bx<0) then bx=0
	xor	ax,ax
@@@@g_ok1:
	cmp	ax,63		;-- if (bx>63) then bx=63
        jbe     @@@@g_ok2
	mov	ax,63

@@@@g_ok2:
	stosb
;--- blue ---
	lodsb
	add	ax,[b]		;-- add blue stuff
        jns     @@@@b_ok1         ;-- if (dx<0) then dx=0
	xor	ax,ax

@@@@b_ok1:
	cmp	ax,63		;-- if (ax>63) then ax=63
        jbe     @@@@b_ok2
	mov	ax,63

@@@@b_ok2:
	stosb			;-- store
        loop    @@@@fun

@@@@bye:
	ret
ENDP




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º PAL_COPY(far *pal;WORD start,end,to) º Copy palette º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	PAL_COPY
PROC	PAL_COPY	FAR
ARG     pal:DWORD,start:WORD,ending:WORD,upto:WORD
USES	ds,si,es,di

	les	di,[pal]	;-- es:di = "to" palette
	lds	si,[pal]	;-- ds:si = "start" palette

	xor	eax,eax
	mov	ax,[start]
	mov	cx,[ending]	;-- cx = number of colors to copy
	sub	cx,ax		;-- Got it.
	lea	cx,[ecx+ecx*2]	;-- Multiply by 3 to know number of bytes

	lea	ax,[eax+eax*2]	;-- Multiply by 3
	add	si,ax		;-- Starting palette position

	mov	ax,[upto]
	lea	ax,[eax+eax*2]	;-- Multiply by 3
	add	di,ax		;-- destination palette position

	rep	movsb		;-- Copy it
@@@@bye:
	ret
ENDP



;ÍÍÍÍÍ END! ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
ENDS
END


INPUT_STATUS1	= 03dah
MISC_OUTPUT	= 03c2h
SC_INDEX	= 03c4h
CRTC_INDEX	= 03d4h
GRAPH_INDEX	= 03ceh
ATTR_INDEX	= 03c0h  ;-- Don't forget clear flipflop & set bit 5 on index
PEL_WRITE	= 03c8h
PEL_READ	= 03c7h
PEL_DATE	= 03c9h

MASK_PLANE1 = 00102h	;-- Map Register + Plane 1
MASK_PLANE2 = 01102h	;-- Map Register + Plane 1
ALL_PLANES  = 00F02h	;-- Map Register + All Bit Planes
CHAIN4_OFF  = 00604h	;-- Chain 4 mode Off
ASYNC_RESET = 00100h	;-- (A)synchronous Reset
SEQU_RESTART= 00300h	;-- Sequencer Restart

LATCHES_ON =00008h	;-- Bit Mask + Data from Latches
LATCHES_OFF=0FF08h	;-- Bit Mask + Data from CPU




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º VGA_SPLIT(int scanlin) º Splits screen at scanline  º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	VGA_SPLIT
PROC	VGA_SPLIT	FAR
ARG	scanlin:WORD

	mov	bx,[scanlin]

	mov	al,18h
	mov	ah,bl
	mov	dx,CRTC_Index
	out	dx,ax		;-- Set bits 0-7

	mov	al,09h
	out	dx,al
	inc	dx
	in	al,dx
	mov	ah,bh
	and	ah,00000010b
	shl	ah,5
	and	al,10111111b
	or	al,ah
	out	dx,al		;-- Set bit 9

	dec	dx
	mov	al,07h
	out	dx,al
	inc	dx
	in	al,dx
	and	al,11101111b
	mov	ah,bh
	and	ah,00000001b
	shl	ah,4
	or	al,ah
	out	dx,al		;-- Set bit 8

	ret
ENDP



;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º VGA_VBLANK(int start,end) º Set VGA blanking limits º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	VGA_VBLANK
PROC	VGA_VBLANK	FAR
ARG	start:WORD, ending:BYTE

	mov	dx,CRTC_INDEX	;-- Reprogram the CRT Controller
	mov	al,11h		;-- VSync End reg contains register write
	out	dx,al		;---- protect bit. Let's unprotect!
	inc	dx		;-- CRT Controller Data register
	in	al,dx		;-- Get current VSync End reg setting
	and	al,07fh 	;-- Remove write protect on various
	out	dx,al		;---- CRTC registers
	dec	dx		;-- CRTC Controller Index

	mov	bx,[start]	;-- We have 9-bit value
	mov	dx,CRTC_INDEX	;-- Actually 3d4h, if you forgot
	mov	al,15h		;-- CRTC Start vertical blank register
	mov	ah,bl		;-- low byte
	out	dx,ax

	mov	al,07h		;-- CRTC overflow register
	out	dx,al		;-- Set..

	inc	dx		;-- CRTC data
	in	al,dx		;-- Get value of register

	shl	bh,2		;-- Move bit 0 to 2
	and	bh,00000100b	;-- Clear all except bit 2
	and	al,11011011b	;-- make hole for bit
	or	al,bh		;-- set bit, if present
	out	dx,al

	dec	dx		;-- CRTC Index
	mov	ah,[ending]	;-- We have 7-bit value
	and	ah,01111111b	;-- (now it's really 7 bit!)
	mov	al,16h		;-- "CRTC End vertical blank" register
	out	dx,ax		;-- Done!

	ret
ENDP




;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º HSYNCH() º Synch to the horizontal int º
;ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	HSYNCH
PROC	HSYNCH	FAR

	mov	dx,03dah

@@lab1:
	in	al,dx
	jmp	@@dum1
@@dum1:
	test	al,01
	jnz	@@lab1

@@lab2: in	al,dx
	jmp	@@dum2
@@dum2:
	test	al,01
	jz	@@lab2

	ret
ENDP


;ALIGN 4
;ÉÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º VSKIP() º Wait until not in vertical retrace. º
;ÈÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
PUBLIC	VSKIP
PROC	VSKIP	FAR

	mov	dx,03DAh		; status register
	mov	bl,8

@@wait_vr:
	in	al,dx
	test	al,bl
	jz	@@wait_vr

@@skip_vr:
	in	al,dx
	test	al,bl
	jnz	@@skip_vr

	ret
ENDP


;--------------------------------
  Detect if a 386 CPU is in
---------------------------------
function cpu_check : word; assembler;
asm
	mov	ax,7000h
	push	ax
	popf
	pushf
	pop	ax
	and	ax,07000h
        jz      @@noway         ;-- ax = 0 ... check failed
	xor	ax,ax
        inc     ax              ;-- ax <> 0 ... check ok !
@@noway:
        sti                     ;-- bug... This miserable disable ints!
end;




;--------------------------------------
  BIOSGOTOXY(x,y) | Moves cursor pos
--------------------------------------
procedure biosgotoxy(x,y:byte); assembler;
asm
	mov	dl,x
	mov	dh,y
	mov	ah,2
	xor	bh,bh
	int	10h
end;


;-------------------------------------
  BIOSWHEREX() | Returns x position
--------------------------------------
function bioswherex : byte; assembler;
asm
	mov	ah,3
	mov	bh,0
	int	10h
	mov	al,dl
end;



;-------------------------------------
  BIOSWHEREY() | Returns x position
--------------------------------------
function bioswherey : byte; assembler;
asm
	mov	ah,3
	mov	bh,0
	int	10h
	mov	al,dh
end;



;ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
 º sound(hz) º Generate sound  º
 ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
procedure sound(hz:word); assembler;
asm
	mov	bx,hz
	cmp	bx,012h
	jna	@@bye

	mov	dx,043h

	mov	ax,034ddh
	div	bx
	mov	bx,ax

	in	al,061h
	test	al,3
	jne	@@nope
	or	al,3
	out	061h,al
	mov	al,0b6h
	out     dx,al
@@nope:
	mov	al,bl
	dec	dx

	out	dx,al
	mov	al,bh
	out	dx,al
@@bye:
end;




;ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
 º NOSOUND() º Turn off sound º
 ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
procedure nosound; assembler;
asm
	in	al,061h
	and     al,0fch
	out     061h,al
end;



;-------------------------------------------------------
  i=BIOSGETMODE() | Gets the current BIOS graphics mode
--------------------------------------------------------
function biosgetmode : word; assembler;
asm
	mov	ah,0fh
	int	10h
	xor	ah,ah
end;



;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
 º x=which_video() º Detect graphics card º
 ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
function which_video : byte; assembler;
asm
        mov     ax,1A00h        ; Try calling "Read Display Codes"
	int	10h
        cmp     al,1Ah          ; Status ok?
        jne     @@not_PS2       ; No! Video Card is old!

        cmp     bl,0Ch          ; bl > 0Ch => CGA hardware
        jg      @@is_CGA        ; Jump if we have CGA

	xor	bh,bh
	add	bx,offset @@PS2_CARDS
        mov     al,cs:[bx]      ; Load ax from PS/2 hardware table
	jmp	@@bye

@@is_CGA:
        mov     ax,CGA          ; Have detected CGA, return id
	jmp	@@bye

@@not_PS2:                      ; OK We don't have PS/2 Video bios
        mov     ah,12h          ; Set alternate function service
        mov     bx,10h          ; Set to return EGA information
        int     10h             ; call video service
        cmp     bx,10h          ; Is EGA there ?
        je      @@simple_adapter        ; Nope!
        mov     ah,12h                  ; Since we have EGA bios, get info
	mov	bl,10h
	int	10h
        or      bh,bh           ; Do we have color EGA ?
        jz      @@ega_color     ; Yes
        mov     ax,EGAMONO      ; Otherwise we have Mono EGA
	jmp	@@bye

@@ega_color:
        mov     ax,EGACOLOR     ; Have detected EGA Color, return id
	jmp	@@bye

@@simple_adapter:
        int     11h             ; Let's try equipment determination service
	and	al,30h

	mov	cl,4
	shr	al,cl
	xor	ah,ah
        or      al,al           ; Do we have any graphics card at all ?
        jz      @@done          ; No?? This is a stupid machine!

        cmp     al,3            ; Do We have a Mono adapter
        jne     @@is_CGA        ; No
        mov     ax,MDA          ; Have detected MDA, return id
	jmp	@@bye

@@done:
	mov	ax,NONE
	jmp	@@bye

@@PS2_CARDS:	db	0,1,2,2,4,3,2,5,6,2,8,7,8,6,6

@@bye:
end;



 key_leds((mem[0:$417] shr 4) and 7);   ;-- Restore keyboard leds

;-------------------------------------
  leds(000b) | Turn on specific leds
--------------------------------------
procedure key_leds(which:byte); assembler;
asm
	mov	dx,60h
	mov	al,0edh
	out	dx,al

	mov	cx,400
@@loo:  dec	cx
	jnz	@@loo

	mov	al,which
	out	dx,al
end;


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ END ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

ENDS
END

