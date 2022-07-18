package vg

import "core:fmt"
import "core:os"
import "core:strings";
import gl "vendor:OpenGL"

mesh_vertex :: struct {
    position: v3,
    normal: v3,
    uv: v2,
};

gl_program :: struct {
    id: u32,
}

gl_render_data :: struct {
    vbo: u32,
    vao: u32,
    ebo: u32,
    indice_count: i32,
}

gl_render_object_mode :: enum {
    points,
    line_strip,
    line_loop,
    lines,
    line_strip_adjacency,
    line_adjacency,
    triangle_strip,
    triangle_fan,
    triangles,
    triangle_strip_adjacency,
    triangles_adjacency,
    patches
};

gl_get_render_mode :: proc(mode: gl_render_object_mode) -> u32 {
    switch mode {
        case .points: {return gl.POINTS;}
        case .line_strip: {return gl.LINE_STRIP;}
        case .line_loop: {return gl.LINE_LOOP;}
        case .lines: {return gl.LINES;}
        case .line_strip_adjacency: {return gl.LINE_STRIP_ADJACENCY;}
        case .line_adjacency: {return gl.LINES_ADJACENCY;}
        case .triangle_strip: {return gl.TRIANGLE_STRIP;}
        case .triangle_fan: {return gl.TRIANGLE_FAN;}
        case .triangles: {return gl.TRIANGLES;}
        case .triangle_strip_adjacency: {return gl.TRIANGLE_STRIP_ADJACENCY;}
        case .triangles_adjacency: {return gl.TRIANGLES_ADJACENCY;}
        case .patches: {return gl.PATCHES;}
    }
    return 0;
}

gl_transform :: struct {
    location: v3,
    rotation: v3,
    scale: v3,
};

gl_transform_ident :: proc() -> gl_transform {
    r: gl_transform;
    r.location = V3d(0.0);
    r.rotation = V3d(0.0);
    r.scale = V3d(1.0);
    return r;
}

gl_transform_from_v3 :: proc(v: v3) -> gl_transform {
    r: gl_transform;
    r.location = v;
    r.rotation = V3d(0.0);
    r.scale = V3d(1.0);
    return r;
}

gl_render_object :: struct {
    data: gl_render_data,
    program: gl_program,
    mode: gl_render_object_mode,
    transforms: [dynamic]gl_transform,
} 

gl_check_compile_errors :: proc(id: u32,  is_shader: u8) {
	success: i32 = 0;
	info: [1024]u8;
	if (is_shader == 1) {
		gl.GetShaderiv(id, gl.COMPILE_STATUS, &success);
		if (success == 0) {
			gl.GetShaderInfoLog(id, 1024, nil, &info[0]);
			fmt.println("open gl shader error: ", info);
		}
	} else {
		gl.GetProgramiv(id, gl.LINK_STATUS, &success);
		if (success == 0) {
			gl.GetProgramInfoLog(id, 1024, nil, &info[0]);
			fmt.println("open gl program error: ", info);
		}
	}
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
    
    result.mode = .triangles;
    return result;
}

bind_render_data :: proc(render_obj: ^gl_render_object, vertices: ^f32, vertice_size: i32, indices: ^i32, indices_size: i32) -> bool {
    gl.GenVertexArrays(1, &render_obj.data.vao);
    gl.GenBuffers(1, &render_obj.data.vbo);
    gl.GenBuffers(1, &render_obj.data.ebo);
    gl.BindVertexArray(render_obj.data.vao);
    
    gl.BindBuffer(gl.ARRAY_BUFFER, render_obj.data.vbo);
    gl.BufferData(gl.ARRAY_BUFFER, auto_cast vertice_size, vertices, gl.STATIC_DRAW);
    
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, render_obj.data.ebo);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, auto_cast indices_size, indices, gl.STATIC_DRAW);
    
    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(mesh_vertex), 0);
    gl.EnableVertexAttribArray(1);
    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(mesh_vertex), size_of(v3));
    gl.EnableVertexAttribArray(2);
    gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, size_of(mesh_vertex), size_of(v3) + size_of(v3));
    
    render_obj.data.indice_count = indices_size / size_of(i32);
    return render_obj.data.vao > 0 && render_obj.data.vbo > 0 && render_obj.program.id > 0;
}

gl_set_bool :: proc(shader: ^gl_program, name: cstring,  value: u8) {         
	gl.Uniform1i(gl.GetUniformLocation(shader.id, name), auto_cast value); 
}

gl_set_int :: proc(shader: ^gl_program, name: cstring,  value: i32) { 
	gl.Uniform1i(gl.GetUniformLocation(shader.id, name), value); 
}

gl_set_real :: proc(shader: ^gl_program, name: cstring, value: f32) { 
	gl.Uniform1f(gl.GetUniformLocation(shader.id, name), value); 
}

gl_set_v2 :: proc(shader: ^gl_program, name: cstring, value: v2) { 
    arr: [dynamic]f32;
    append(&arr, value.x);
    append(&arr, value.y);
	gl.Uniform2fv(gl.GetUniformLocation(shader.id, name), 1, &arr[0]); 
}

gl_set_v2f :: proc(shader: ^gl_program, name: cstring, x, y: f32) { 
	gl.Uniform2f(gl.GetUniformLocation(shader.id, name), x, y); 
}

gl_set_v3 :: proc(shader: ^gl_program, name: cstring,  value: v3) { 
    arr: [dynamic]f32;
    append(&arr, value.x);
    append(&arr, value.y);
    append(&arr, value.z);
	gl.Uniform3fv(gl.GetUniformLocation(shader.id, name), 1, &arr[0]); 
}

gl_set_v3f :: proc(shader: ^gl_program, name: cstring, x, y, z: f32){ 
	gl.Uniform3f(gl.GetUniformLocation(shader.id, name), x, y, z); 
}

gl_set_v4 :: proc(shader: ^gl_program, name: cstring,  value: v4) { 
    arr: [dynamic]f32;
    append(&arr, value.x);
    append(&arr, value.y);
    append(&arr, value.z);
    append(&arr, value.w);
	gl.Uniform4fv(gl.GetUniformLocation(shader.id, name), 1, &arr[0]); 
}

gl_set_v4f :: proc(shader: ^gl_program, name: cstring,  x, y, z, w: f32) { 
	gl.Uniform4f(gl.GetUniformLocation(shader.id, name), x, y, z, w); 
}

gl_set_m4 :: proc(shader: ^gl_program, name: cstring, mat: m4) {
    arr: [dynamic]f32;
    for i := 0; i < 4; i += 1 {
        for j := 0; j < 4; j += 1 {
            append(&arr, mat.elements[i][j]);
        }
    }
	gl.UniformMatrix4fv(gl.GetUniformLocation(shader.id, name), 1, gl.FALSE, &arr[0]);
}
