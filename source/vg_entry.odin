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
    
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3);
    glfw.WindowHint(glfw.SAMPLES, 4);
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
    
    win.win = glfw.CreateWindow(win.size[0], win.size[1], "odin vg", win.monitor_handle, nil);
    glfw.MakeContextCurrent(win.win);
    
    gl.load_up_to(3, 3, glfw.gl_set_proc_address);                                                                                           
    
	glfw.SetCursorPosCallback(win.win, cast(glfw.CursorPosProc)glfw_mouse);
    glfw.SetFramebufferSizeCallback(win.win, cast(glfw.FramebufferSizeProc)glfw_window_size);
	glfw.SetErrorCallback(cast(glfw.ErrorProc)glfw_error);
    
    glfw.RestoreWindow(win.win);
    gl.Enable(gl.DEPTH_TEST);
    gl.DepthFunc(gl.LEQUAL);
    gl.Enable(gl.TEXTURE_CUBE_MAP_SEAMLESS);
    
    hdr_context_init();
    
    obj: gl_render_object;
    obj.program = hdr_context.pbr;
    vg_shape_sphere(&obj);
    for row := 0; row < 7; row += 1 {
        m: f32 = cast(f32)row / 7.0;
        for col := 0; col < 7; col += 1 {
            pos: v3 = V3(cast(f32)(cast(f32)col - (7.0 / 2.0)) * 2.5,
                         cast(f32)(cast(f32)row - (7.0 / 2.0)) * 2.5,
                         -2.0);
            append(&obj.transforms, gl_transform_from_v3(pos));
            r: f32 = clamp(cast(f32)col / 7.0, 0.05, 1.0);
            
            attrib: gl_render_attrib;
            attrib.metallic = m;
            attrib.roughness = r;
            append(&obj.render_attrib, attrib);
        }
    }
    append(&scene_context.render_objects, obj);
    
    view_context_transform();
    view_context_push_to(&hdr_context.pbr);
    view_context_push_to(&hdr_context.background.program);
    
    gl.Viewport(0, 0, win.size[0], win.size[1]);
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