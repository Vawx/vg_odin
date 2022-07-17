package vg

import "core:fmt"
import "core:os"
import "core:strings";
import gl "vendor:OpenGL"

gl_program :: struct {
    id: u32,
}

gl_render_data :: struct {
    vbo: u32,
    vao: u32,
    ebo: u32,
}

gl_render_object :: struct {
    data: gl_render_data,
    program: gl_program
} 

load_shader_from_disk :: proc(vert_path: string, frag_path: string) -> gl_render_object {
    result: gl_render_object;
    
    vert_f, vert_err := os.open(vert_path);
    if(vert_err != os.ERROR_NONE) {
        fmt.println("failed to open vert file: ", vert_path);
        return result;
    }
    vert_size, vert_err_size := os.file_size(vert_f);
    vert_read := [2048]byte{};
    vert_read_size, vert_read_err := os.read(vert_f, vert_read[:]);
    if(vert_read_size == 0) {
        fmt.println("failed to read frag file:", vert_path);
        return result;
    }
    
    vert: u32 = gl.CreateShader(gl.VERTEX_SHADER);
    vert_cstr := cstring(&vert_read[0]);
    gl.ShaderSource(vert, 1, &vert_cstr, auto_cast &vert_size);
    gl.CompileShader(vert);
    
    // frag
    frag_f, frag_err := os.open(frag_path);
    if(frag_err != os.ERROR_NONE) {
        fmt.println("failed to open frag file: ", frag_path);
        return result;
    }
    frag_read := [2048]byte{};
    frag_size, frag_err_size := os.file_size(frag_f);
    frag_read_size, frag_read_err := os.read(frag_f, frag_read[:]);
    if(frag_read_size == 0) {
        fmt.println("failed to read frag file:", frag_path);
        return result;
    }
    
    frag: u32 = gl.CreateShader(gl.FRAGMENT_SHADER);
    frag_cstr := cstring(&frag_read[0]);
    gl.ShaderSource(frag, 1, &frag_cstr, auto_cast &frag_size);
    gl.CompileShader(frag);
    
    result.program.id = gl.CreateProgram();
    gl.AttachShader(result.program.id, vert);
    gl.AttachShader(result.program.id, frag);
    gl.LinkProgram(result.program.id);
    
    gl.DeleteShader(vert);
    gl.DeleteShader(frag);
    
    os.close(vert_f);
    os.close(frag_f);
    
    return result;
}

bind_render_data :: proc(render_obj: ^gl_render_object, vertices: []f32, indices: []i32) -> bool {
    gl.GenVertexArrays(1, &render_obj.data.vao);
    gl.GenBuffers(1, &render_obj.data.vbo);
    gl.BindVertexArray(render_obj.data.vao);
    
    gl.BindBuffer(gl.ARRAY_BUFFER, render_obj.data.vbo);
    len: i32 = auto_cast len(vertices);
    size: i32 = auto_cast len * size_of(f32);
    gl.BufferData(gl.ARRAY_BUFFER, auto_cast size, &vertices[0], gl.STATIC_DRAW);
    
    //TODO file data with indices
    
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), auto_cast 0);
    gl.EnableVertexAttribArray(0);
    
    return render_obj.data.vao > 0 && render_obj.data.vbo > 0 && render_obj.program.id > 0;
}