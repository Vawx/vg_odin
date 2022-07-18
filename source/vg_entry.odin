package vg

import "core:fmt"
import "core:math"
import vg_fbx "vg_fbx"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

window :: struct {
    win: glfw.WindowHandle,
    monitor_handle: glfw.MonitorHandle,
    size:[2] i32,
    pos:[2] i32,
    col: v4,
    mouse:[2] i32,
};

win: window;

glfw_input :: proc(win: glfw.WindowHandle) {
    
}

glfw_window_size :: proc(win: glfw.WindowHandle, x, y: i32) {
    gl.Viewport(0, 0, x, y);
}

glfw_mouse :: proc(glfw_win: glfw.WindowHandle, xpos, ypos: f64)  {
    win.mouse[0] = cast(i32)xpos;
    win.mouse[1] = cast(i32)ypos;
}

glfw_error :: proc(err: i32, info: cstring) {
    fmt.printf("error: %d, info: %s\n", err, info);
}

main :: proc() {
    win.monitor_handle = glfw.GetPrimaryMonitor();
    win.size[0] = 1920;
    win.size[1] = 1080;
    win.col = V4(1.0, 0.25, 0.25, 1.0);
    
    vg_scene_context_init();
    
    glfw.Init();
    win.win = glfw.CreateWindow(win.size[0], win.size[1], "odin vg", win.monitor_handle, nil);
    glfw.MakeContextCurrent(win.win);
    
    gl.load_up_to(3, 3, glfw.gl_set_proc_address);                                                                                           
    
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3);
    glfw.WindowHint(glfw.SAMPLES, 4);
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
    
	glfw.SetCursorPosCallback(win.win, cast(glfw.CursorPosProc)glfw_mouse);
    glfw.SetFramebufferSizeCallback(win.win, cast(glfw.FramebufferSizeProc)glfw_window_size);
	glfw.SetErrorCallback(cast(glfw.ErrorProc)glfw_error);
    
    glfw.RestoreWindow(win.win);
    gl.Enable(gl.DEPTH_TEST);
    
    obj: gl_render_object = load_shader_from_disk("D:\\vgo\\content\\shaders\\test.vertex", "D:\\vgo\\content\\shaders\\test.frag");
    //vg_shape_cube(&obj);
    vg_shape_sphere(&obj);
    
    positions: [dynamic]v3;
    append(&positions, V3( 0.0,  0.0,  0.0));
    append(&positions, V3( 2.0,  5.0, -15.0));
    append(&positions, V3(-1.5, -2.2, -2.5));
    append(&positions, V3(-3.8, -2.0, -12.3));
    append(&positions, V3( 2.4, -0.4, -3.5));
    append(&positions, V3(-1.7,  3.0, -7.5));
    append(&positions, V3( 1.3, -2.0, -2.5));
    append(&positions, V3( 1.5,  2.0, -2.5));
    append(&positions, V3( 1.5,  0.2, -1.5));
    append(&positions, V3(-1.3,  1.0, -1.5));
    
    angle: f32 = 20.0;
    
    for {
        if(glfw.WindowShouldClose(win.win)) {
            break;
        }
        
        glfw_input(win.win);
        
        gl.ClearColor(win.col.x, win.col.y, win.col.z, win.col.w);
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        
        view_context_transform();
        view_context_push_to(&obj.program);
        
        for i := 0; i < len(positions); i += 1 {
            angle += 0.10;
            
            model: m4 = M4d(1);
            model = m4_mult(model, translate(positions[i]));
            model = m4_mult(model, rotate(angle, V3(1.0, 0.3, 0.5)));
            model = m4_mult(model, scale(V3d(1.0)));
            gl_set_m4(&obj.program, "u_model", model);
            
            mode: u32 = gl_get_render_mode(obj.mode);
            if(mode == gl.TRIANGLES) {
                if(obj.data.ebo > 0) {
                    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, obj.data.ebo);
                    gl.DrawElements(mode, obj.data.indice_count, gl.UNSIGNED_INT, nil);
                } else {
                    gl.BindVertexArray(obj.data.vao);
                    gl.DrawArrays(mode, 0, obj.data.indice_count);
                }
            }
            if(mode == gl.TRIANGLE_STRIP) {
                if(obj.data.ebo > 0) {
                    gl.BindVertexArray(obj.data.vao);
                    gl.DrawElements(mode, obj.data.indice_count, gl.UNSIGNED_INT, nil);
                }
            }
        }
        
        glfw.SwapBuffers(win.win);
        glfw.PollEvents();
    }
    
    glfw.Terminate();
}