{$A-,B-,E-,F-,G+,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}

unit fileio;
interface

var
 doserror:word;

function  open_file(where:pchar) : word;
function  open_read(where:pchar) : word;
procedure close_file(handle:word);
function  read_file(handle:word; buffer:pointer; howmany:word) : word;

procedure buf_set(bufaddr:pointer; size:word; filename:pointer);
function  buf_read : byte;
procedure buf_close;

procedure write_file(handle:word; buffer:pointer; howmany:word);
function  move_pointer(handle:word; where:longint) : longint;
procedure seek_top(handle:word);
procedure seek_end(handle:word);
procedure flush_data;
function  set_default_drive(drive:char) : byte;
function  get_default_drive : char;
procedure set_dta_address(where:pointer);
function  get_dta_address : pointer;
procedure make_dir(name:pchar);
procedure remove_dir(name:pchar);
procedure change_dir(name:pchar);
procedure delete_file(name:pchar);
function  get_file_attrib(name:pchar) : word;
procedure set_file_attrib(name:pchar; attrib:word);
function  device_removable(drive:char) : word;
procedure get_current_dir(result:pchar; drive:byte);
procedure rename_file(oldname,newname:pchar);


implementation

{$L fileio.obj}
function  open_file(where:pchar) : word; external;
function  open_read(where:pchar) : word; external;
procedure close_file(handle:word); external;
function  read_file(handle:word; buffer:pointer; howmany:word) : word; external;

procedure buf_set(bufaddr:pointer; size:word; filename:pointer); external;
function  buf_read : byte; external;
procedure buf_close; external;

procedure write_file(handle:word; buffer:pointer; howmany:word); external;
function  move_pointer(handle:word; where:longint) : longint; external;
procedure seek_top(handle:word); external;
procedure seek_end(handle:word); external;
procedure flush_data; external;
function  set_default_drive(drive:char) : byte; external;
function  get_default_drive : char; external;
procedure set_dta_address(where:pointer); external;
function  get_dta_address : pointer; external;
procedure make_dir(name:pchar); external;
procedure remove_dir(name:pchar); external;
procedure change_dir(name:pchar); external;
procedure delete_file(name:pchar); external;
function  get_file_attrib(name:pchar) : word; external;
procedure set_file_attrib(name:pchar; attrib:word); external;
function  device_removable(drive:char) : word; external;
procedure get_current_dir(result:pchar; drive:byte); external;
procedure rename_file(oldname,newname:pchar); external;


begin
end.