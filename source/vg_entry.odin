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
    
    obj: gl_render_object = load_shader_from_disk("D:\\vgo\\content\\shaders\\test.vertex", "D:\\vgo\\content\\shaders\\test.frag");
    vg_shape_cube(&obj);
    for i := 0; i < len(positions); i += 1 {
        append(&obj.transforms, gl_transform_from_v3(positions[i]));
    }
    append(&scene_context.render_objects, obj);
    
    for {
        if(glfw.WindowShouldClose(win.win)) {
            break;
        }
        
        glfw_input(win.win);
        
        scene_context_render();
        
        glfw.SwapBuffers(win.win);
        glfw.PollEvents();
    }
    
    glfw.Terminate();
}