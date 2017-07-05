;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³     FileIO - Disk routines	 ³
;³   Version 2.00 - 04/25/1995	 ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³  (c) 1995 Marco A. Marrero	 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IDEAL
MODEL SMALL,PASCAL
P286
JUMPS


;ÍÍÍÍÍÍÍÍÍ PUBLIC DATA ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
DATASEG
EXTRN	doserror : WORD 	;ÄÄ DOS error flag
ENDS


;ÍÍÍÍÍÍÍÍÍ FUNCTIONS ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

CODESEG
ASSUME  cs:@code, ds:@data


;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; OPEN_READ(char far *filename) | Open file with handle to read/write
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	OPEN_READ
PROC	OPEN_READ	FAR
ARG	filename:DWORD
USES	ds

	xor	cx,cx		;-- We store handle in cx after DOS call

	lds	dx,[filename]	;-- ds:dx has ASCIIZ filename
	mov	ax,03d02h	;-- ah=3dh, al=02 (read/write)
	int	21h
	jc	@@error 	;-- If cannot open, it's dead!
	mov	cx,ax		;-- We could open it! cx has handle
	xor	ax,ax		;-- No error...

@@error:
	mov	bx,@data	;-- Set up data segment
	mov	ds,bx		;---- to be sure!
	mov	[doserror],ax	;-- Indicate error, if any

	mov	ax,cx		;-- return handle to user
	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; OPEN_FILE(char far *filename) | Open file with handle to read/write
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	OPEN_FILE
PROC	OPEN_FILE       FAR
ARG	filename:DWORD
USES	ds

	lds	dx,[filename]	;-- ds:dx has ASCIIZ filename
	mov	ax,03d02h	;-- ah=3dh, al=02 (read/write)
	int	21h
	jc	@@create	;-- If cannot open, let's try creating it
	mov	cx,ax		;-- We could open it! cx has handle
	xor	ax,ax		;-- No error...
	jmp	@@done

@@create:
	lds	dx,[filename]	;-- ds:dx has filename. Just to be sure...
	mov	cx,020h 	;-- File marked for archive (to be polite)
	mov	ah,03ch 	;-- Create new file
	int	21h
	jc	@@done		;-- If carry set, it's sure it can't be done!
	mov	cx,ax		;-- Ok.. Success. cx has handle
	xor	ax,ax		;-- And no error!

@@done:
	mov	bx,@data	;-- Set up data segment
	mov	ds,bx		;---- to be sure!
	mov	[doserror],ax	;-- Indicate error, if any

	mov	ax,cx		;-- return handle to user (if error, garbage)
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; CLOSE_FILE(word handle) | Close file with handle
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	CLOSE_FILE
PROC	CLOSE_FILE      FAR
ARG	handle:WORD
USES	ds

	mov	bx,[handle]	;-- Handle of file to close
	mov	ah,03eh 	;-- DOS function
	int	21h
	jc	@@error 	;-- If carry, something went kaboom
	xor	ax,ax		;-- Clear error...

@@error:
	mov	bx,@data	;-- Setup data segment
	mov	ds,bx
	mov	[doserror],ax	;-- Write error value. 0 if no error.
	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; wread=READ_FILE(word handle, void far *buffer, word bytes) | Read File
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	READ_FILE
PROC	READ_FILE       FAR
ARG	handle:WORD, buffer:DWORD, bytes:WORD
USES	ds

	mov	bx,[handle]	;-- Handle of file
	mov	cx,[bytes]	;-- Bytes to read
	lds	dx,[buffer]	;-- Buffer to store data
	mov	ah,03fh 	;-- DOS call...
	int	21h
	jc	@@error
	mov	cx,ax		;-- cx has bytes read
	xor	ax,ax		;-- signal no error

@@error:
	mov	bx,@data	;-- set up data segment
	mov	ds,bx

	mov	[doserror],ax	;-- Signal error
	mov	ax,cx		;-- Return bytes read
	ret
ENDP




;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
bufaddr DD ?	;-- Buffer address for quick buffered transfers
bufhand DW ?	;-- Buffer handle!

bufpos	DW ?	;-- Buffer current position
buflim	DW ?	;-- Buffer limit, maximum bytes plus offset
bufsiz	DW ?	;-- Buffer total size (original size)




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; BUF_SET(void far *bufaddr, word size, void far *file) | Set buffer variables
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	BUF_SET
PROC	BUF_SET         FAR
ARG     addr:DWORD, xsize:WORD, filename:DWORD
USES	ds


;--- Let's open file. If there's an error, doserror is set in OPEN_READ, so
;--- we don't need to check if failed. (the caller must check doserror).
;----------------------------------------------------------------------------

	call OPEN_READ pascal, [filename]
	mov	[bufhand],ax

	lds     bx,[addr]               ;-- Get buffer address
	mov     [WORD HIGH bufaddr],ds  ;-- Store!
	mov     [WORD LOW  bufaddr],bx

	mov	ax,[xsize]	;-- Get size of buffer
	mov	[bufsiz],ax	;-- Store original size
        add     ax,bx           ;-- Add offset to size
	mov	[buflim],ax	;-- Limit buffer address (offset+size)
        mov     [bufpos],ax     ;-- Pos=End... (force read disk later)

        lds     ax,[bufaddr]    ;-- Debugging!!
        mov     dx,ds           ;-- Let's return address in case we did wrong!
        ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; byte=BUF_READ() | Read data from buffer
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	BUF_READ
PROC	BUF_READ	FAR
USES	ds,si,di

	lds	di,[bufaddr]	;-- Get buffer address (ds:di=original)

	mov	si,[bufpos]	;-- Get buffer position
	cmp	si,[buflim]	;-- Reached the end limit??
	jb	@@okay		;--- nope...

@@fail:
        mov     si,di           ;-- If yes, restore position (si=start offset)
        call READ_FILE PASCAL,[bufhand],[bufaddr],[bufsiz]

	or	ax,ax		;-- There was someting?
	jz	@@error 	;--- no! there was nothing there!

	cmp	ax,[bufsiz]	;-- Filled up the buffer??
        je      @@okay          ;-- Not yet... All is ok.

@@nofill:
	mov	[bufsiz],ax	;-- Buffer is quite smaller!
        add     ax,di           ;-- size+offset of buffer
	mov	[buflim],ax	;-- Buffer limit is smaller too.


@@okay:
	lodsb			;-- ds:si has buffer position...
	mov	[bufpos],si
	ret

@@error:
	mov	bx,@data	;-- Restore data segment
	mov	ds,bx

	mov	bx,[doserror]	;-- Let's see if DOS messed it up
	or	bx,bx		;-- If not zero, disk horror.
	jnz	@@bye

	dec	[doserror]	;-- If not him, we mess it up real ugly

@@bye:
	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; BUF_CLOSE() | Closes the buffer's file
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	BUF_CLOSE
PROC	BUF_CLOSE	FAR

	mov	bx,[bufhand]	;-- Handle of file to close
	mov	ah,03eh 	;-- DOS function
	int	21h
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; WRITE_FILE(word handle, void far *buffer, word bytes) | Write File/Device
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	WRITE_FILE
PROC	WRITE_FILE	FAR
ARG	handle:WORD, buffer:DWORD, bytes:WORD
USES	ds


	mov	bx,[handle]	;-- Handle of file
	mov	cx,[bytes]	;-- Bytes to write
	lds	dx,[buffer]	;-- Buffer where data is stored
	mov	ah,040h 	;-- DOS call...
	int	21h
	pop	ds
	jc	@@error
	xor	ax,ax

@@error:
	mov	bx,@data
	mov	ds,bx

	mov	[doserror],ax
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; pos=MOVE_POINTER(word handle, long where) | Move file pointer
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	MOVE_POINTER
PROC	MOVE_POINTER	FAR
ARG	handle:WORD, where:DWORD
USES	ds

	les	dx,[where]	;-- File position (32 bit number)
	mov	cx,es

	mov	bx,[handle]	;-- Handle of file
	mov	ax,04201h	;-- DOS Call...
	int	21h
	jc	@@error
	mov	cx,ax		;-- save ax...
	xor	ax,ax		;-- signal no error

@@error:
	mov	bx,@data
	mov	ds,bx

	mov	[doserror],ax	;-- signal error
	mov	ax,cx		;-- restore, returns dx:ax
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; SEEK_TOP(word handle) |  Goto top of open file
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	SEEK_TOP
PROC	SEEK_TOP	FAR
ARG	handle:WORD
USES	ds

	mov	ax,@data
	mov	ds,ax

	mov	[doserror],0	;-- Clear error flag

	mov	bx,[handle]	;-- Handle of file
	xor	cx,cx		;-- Clear position... We want top.
	xor	dx,dx

	mov	ax,04200h	;-- DOS call...
	int	21h
	jnc	@@okay

	mov	[doserror],ax
	xor	ax,ax

@@okay:
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; SEEK_END(word handle) | Goto end of file
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	SEEK_END
PROC	SEEK_END	FAR
ARG	handle:WORD

	mov	ax,@data
	mov	ds,ax

	mov	[doserror],0	;-- No error is zero

	mov	bx,[handle]	;-- Handle of file
	xor	cx,cx		;-- Clear values
	xor	dx,dx

	mov	ax,04202h	;-- DOS call...
	int	21h
	jnc	@@okay

	mov	[doserror],ax	;-- Indicate if you messed it up.
	xor	ax,ax

@@okay:
	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; FLUSH_DATA() | Write all data to disk, but user must close files!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	FLUSH_DATA
PROC	FLUSH_DATA	FAR
	mov	ah,0dh
	int	21h
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; bLogicaldrives=SET_DEFAULT_DRIVE(char 'A') | Set default drive
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	SET_DEFAULT_DRIVE
PROC	SET_DEFAULT_DRIVE	FAR
ARG	drive:BYTE

	mov	dl,[drive]	;-- Get parameter
	cmp	dl,27		;-- If you sent a number, you got it!
	jb	@@done

	cmp	dl,65		;-- If invalid value, do nothing
	jb	@@bye

	cmp	dl,90		;-- It if less than uppercase Z?
	ja	@@lower 	;--- No, it is surely lowercase

	sub	dl,'A'          ;-- Convert 'A' to 0, etc... Get the idea?
	jmp	@@done

@@lower:
	sub	dl,'a'          ;-- Convert 'a' to 0, etc... You know...

@@done:
	mov	ah,0eh
	int	21h
@@bye:
	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; bchar=GET_DEFAULT_DRIVE() | Get default drive
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	GET_DEFAULT_DRIVE
PROC	GET_DEFAULT_DRIVE	FAR

	mov	ah,19h
	int	21h
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; SET_DTA_ADDRESS(void far where) | Set DTA address
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	SET_DTA_ADDRESS
PROC	SET_DTA_ADDRESS	FAR
ARG	where:DWORD
USES	ds

	lds	dx,[where]
	mov	ah,01ah
	int	21h
	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; farpointer=GET_DTA_ADDRESS() | Get DTA address
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	GET_DTA_ADDRESS
PROC	GET_DTA_ADDRESS	FAR

	mov	ah,2fh
	int	21h

	mov	ax,bx
	mov	dx,es
	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; MAKE_DIR(char far *name) | Create directory
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	MAKE_DIR
PROC	MAKE_DIR	FAR
ARG	xname:DWORD
USES	ds

	lds	dx,[xname]
	mov	ah,39h
	int	21h
	jc	@@error
	xor	ax,ax

@@error:
	mov	bx,@data
	mov	ds,bx

	mov	[doserror],ax
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; REMOVE_DIR(char far *name) | Remove directory
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	REMOVE_DIR
PROC	REMOVE_DIR	FAR
ARG	mname:DWORD
USES	ds

	lds	dx,[mname]
	mov	ah,3ah
	int	21h
	jc	@@error
	xor	ax,ax

@@error:
	mov	bx,@data
	mov	ds,bx

	mov	[doserror],ax
	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; CHANGE_DIR(char far *dir) | Change dir (not drive!!)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	CHANGE_DIR
PROC	CHANGE_DIR	FAR
ARG	dir:DWORD
USES	ds

	lds	dx,[dir]
	mov	ah,3bh
	int	21h
	jc	@@error
	xor	ax,ax

@@error:
	mov	bx,@data
	mov	ds,bx
	mov	[doserror],ax
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; DELETE_FILE(char far *which) | Deletes a file (readolny are left alone)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	DELETE_FILE
PROC	DELETE_FILE	FAR
ARG	which:DWORD
USES	ds

	lds	dx,[which]
	mov	ah,41h
	int	21h
	jc	@@error
	xor	ax,ax

@@error:
	mov	bx,@data
	mov	ds,bx
	mov	[doserror],ax
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; wattr=GET_FILE_ATTRIB(char far *file) | Get attrib
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	GET_FILE_ATTRIB
PROC	GET_FILE_ATTRIB	FAR
ARG	file:DWORD
USES	ds

	lds	dx,[which]
	mov	ax,4300h
	int	21h
	jc	@@error
	xor	ax,ax

@@error:
	mov	bx,@data
	mov	ds,bx
	mov	[doserror],ax
	mov	ax,cx
	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; SET_FILE_ATTRIB(char far *file, word attrib) | Set file attributes
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	SET_FILE_ATTRIB
PROC	SET_FILE_ATTRIB	FAR
ARG	file:DWORD, attrib:WORD
USES	ds

	lds	dx,[which]
	mov	cx,[attrib]
	mov	ax,4301h
	int	21h
	jc	@@error
	xor	ax,ax

@@error:
	mov	bx,@data
	mov	ds,bx
	mov	[doserror],ax
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; word=DEVICE_REMOVABLE(char drive) | Determines if device removable (0=Yes)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	DEVICE_REMOVABLE
PROC	DEVICE_REMOVABLE	FAR
ARG	drive:BYTE
USES	ds

	mov	bl,[drive]	;-- Get parameter
	cmp	bl,27		;-- If you sent a number, you got it!
	jb	@@done

	cmp	bl,65		;-- If invalid value, do nothing
	jb	@@bye

	cmp	bl,90		;-- It if less than uppercase Z?
	ja	@@lower 	;--- No, it is surely lowercase

	sub	bl,'A'          ;-- Convert 'A' to 0, etc... Get the idea?
	jmp	@@done

@@lower:
	sub	bl,'a'          ;-- Convert 'a' to 0, etc... You know...

@@done:
	mov	ax,4408h
	int	21h

	mov	bx,@data
	mov	ds,bx
	mov	[doserror],ax
@@bye:	ret
ENDP




;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; GET_CURRENT_DIR(char far *result, byte drivenum) | Gets current directory
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	GET_CURRENT_DIR
PROC	GET_CURRENT_DIR	FAR
ARG	result:DWORD, drivenum:BYTE
USES	ds,si

	lds	si,[result]
	mov	dl,[drivenum]
	mov	ah,47h
	int	21h
	jc	@@error
	xor	ax,ax

@@error:
	mov	bx,@data
	mov	ds,bx
	mov	[doserror],ax
	ret
ENDP





;ALIGN 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; RENAME_FILE(char far *oldname,newname) | Renames (or moves) a file
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBLIC	RENAME_FILE
PROC	RENAME_FILE	FAR
ARG	oldname:DWORD, newname:DWORD
USES	ds,di

	lds	dx,[oldname]
	les	di,[newname]
	mov	ah,56h
	int	21h
	jc	@@error
	xor	ax,ax

@@error:
	mov	bx,@data
	mov	ds,bx
	mov	[doserror],ax
	ret
ENDP


;ÄÄÄÄ END! ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ENDS
END
