package vg_fbx

when ODIN_OS == .Windows {
    foreign import vg_fbx "build/vg_fbx_import.lib";
    
    vg_buffer :: struct {
        ptr: rawptr,
        s_ptr: rawptr,
        type_size: u16,
        size: u32,
    };
    
    vg_allocator :: struct {
        ptr: rawptr,
        s_ptr: rawptr,
        size: u32,
    };
    
    vg_fbx_import_scene :: struct {
        nodes: vg_buffer, // ufbx_import_node
        meshes: vg_buffer, // ufbx_import_mesh
        file_path: cstring,
        allocator: vg_allocator,
    };
    
    foreign vg_fbx {
        ufbx_import_load_fbx_scene::proc(filename: cstring) -> vg_fbx_import_scene ---
    }
}