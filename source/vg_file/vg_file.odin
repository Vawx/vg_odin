package vg_file

when ODIN_OS == .Windows {
    foreign import vg_file "build/vg_file.lib";
    
    handle :: struct {
        ptr: rawptr,
        len: i32,
    };
    
    foreign vg_file {
        load_file_from_disk::proc(path: cstring) -> handle ---;
        free_file::proc(file: handle) ---;
    }
}