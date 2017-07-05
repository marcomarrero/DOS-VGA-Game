//-------------------------------------------
// FileIO - (c) 1994,1995 Marco A. Marrero
//-------------------------------------------
#ifndef FILEIO
 #define FILEIO
 unsigned doserror;
 extern "C" {
        extern far pascal unsigned open_file(where:pchar);
        extern far pascal unsigned open_read(where:pchar);
        extern far pascal void close_file(unsigned handle);
        extern far pascal unsigned read_file(unsigned handle,void far *buffer,unsigned howmany);

        extern far pascal void buf_set(void far *bufaddr,unsigned size,char far *filename);
        extern far pascal char buf_read();
        extern far pascal void buf_close();

        extern far pascal void write_file(unisgned handle,void far *buffer,unsigned howmany);
        extern far pascal long move_pointer(unsigned handle,long where);
        extern far pascal void seek_top(unsigned handle);
        extern far pascal void seek_end(unsigned handle);
        extern far pascal void flush_data();
        extern far pascal char set_default_drive(char drive);
        extern far pascal char get_default_drive();
        extern far pascal void set_dta_address(void far *where);
        extern far pascal void far *get_dta_address();
        extern far pascal void make_dir(char far *name);
        extern far pascal void remove_dir(char far *name);
        extern far pascal void change_dir(char far *name);
        extern far pascal void delete_file(char far *name);
        extern far pascal unsigned get_file_attrib(char far *name);
        extern far pascal void set_file_attrib(char far *name,unsigned attrib);
        extern far pascal unsigned device_removable(char drive);
        extern far pascal void get_current_dir(char far *result,char drive);
        extern far pascal void rename_file(char far *oldname,char far *newname);
 }
#endif
