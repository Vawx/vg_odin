package vg

import strings "core:strings";
import maps "core:slice"
import vg_fetch "vg_fetch"

asset_import_type :: enum {
    ImportNone,
    ImportShader,
    ImportMesh,
    ImportTexture,
};

asset_type :: enum {
    None,
    Shader,
    Mesh,
    Texture,
    Material,
    Skybox
}

asset_header :: struct {
    str: cstring,
    len: u32,
};

asset_buffer :: struct {
    ptr: ^u8,
    size: u32,
};

asset :: struct {
    type: asset_type,
    header: asset_header,
    path: string,
    buffers: [dynamic]asset_buffer,
};

asset_manager :: struct {
    assets: ^asset, 
}

data_type_from_path :: proc(path: string) -> asset_import_type {
    if(strings.has_suffix(path, ".shader")) {
        return .ImportShader;
    }
    if(strings.has_suffix(path, ".fbx")) {
        return .ImportMesh;
    }
    if(strings.has_suffix(path, ".tga") || strings.has_suffix(path, ".png")) {
        return .ImportTexture;
    }
    return .ImportNone;
}
raw_loaded_callback_existing::proc(response: ^vg_fetch.sfetch_response_t) {
    if(response.finished == true && response.error_code == vg_fetch.sfetch_error_t.SFETCH_ERROR_NO_ERROR) {
        
    }
}

raw_loaded_callback_new::proc(response: ^vg_fetch.sfetch_response_t) {
    if(response.finished == true && response.error_code == vg_fetch.sfetch_error_t.SFETCH_ERROR_NO_ERROR) {
        
    }
}

load_raw_data :: proc(path: string, buffer: ^asset_buffer) {
    
};