package vg

import "core:fmt"
import "core:math"
import vg_fbx "vg_fbx"
import vg_fetch "vg_fetch"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

window :: struct {
    win: glfw.WindowHandle,
    monitor_handle: glfw.MonitorHandle,
    size: [2]i32,
    pos: [2]i32,
    col: v4,
    mouse: [2]f64,
    last_mouse: [2]f64,
    cam: bool,
};

win: window;

glfw_input :: proc(glfw_win: glfw.WindowHandle) {
    velocity: f32  = 4.5 * 0.016;
    if (glfw.GetKey(glfw_win, glfw.KEY_W) == glfw.PRESS) {
        scene_context.view.location = v3_add(scene_context.view.location, v3_multf(scene_context.view.front, velocity));
    }
    if (glfw.GetKey(glfw_win, glfw.KEY_S) == glfw.PRESS) {
        scene_context.view.location = v3_sub(scene_context.view.location, v3_multf(scene_context.view.front, velocity));
    }
    if (glfw.GetKey(glfw_win,  glfw.KEY_D) == glfw.PRESS) {
        scene_context.view.location = v3_add(scene_context.view.location, v3_multf(scene_context.view.right, velocity));
    }
    if (glfw.GetKey(glfw_win, glfw.KEY_A) == glfw.PRESS) {
        scene_context.view.location = v3_sub(scene_context.view.location, v3_multf(scene_context.view.right, velocity));
    }
    
    if (glfw.GetKey(glfw_win, glfw.KEY_LEFT_ALT) == glfw.PRESS) {
        win.cam = true;
    }
    if (glfw.GetKey(glfw_win, glfw.KEY_LEFT_ALT) == glfw.RELEASE) {
        win.cam = false;
    }
}

glfw_window_size :: proc(win: glfw.WindowHandle, x, y: i32) {
    gl.Viewport(0, 0, x, y);
}

glfw_mouse :: proc(glfw_win: glfw.WindowHandle, xpos, ypos: f64)  {
    win.mouse[0] = xpos;
    win.mouse[1] = ypos;
    
    if(win.cam == true) {
        if(win.last_mouse[0] == 0) {
            win.last_mouse[0] = win.mouse[0];
        }
        if(win.last_mouse[1] == 0) {
            win.last_mouse[1] = win.mouse[1];
        }
        
        xoffset: f64 = win.mouse[0] - win.last_mouse[0];
        yoffset: f64 = win.last_mouse[1] - win.mouse[1]; // reversed since y-coordinates go from bottom to top
        
        win.last_mouse[0] = win.mouse[0];
        win.last_mouse[1] = win.mouse[1];
        
        xoffset *= 0.1;
        yoffset *= 0.1;
        
        scene_context.view.yaw += xoffset;
        //scene_context.view.pitch += yoffset;
        
        // make sure that when pitch is out of bounds, screen doesn't get flipped
        if (scene_context.view.pitch > 89.0) {
            scene_context.view.pitch= 89.0;
        }
        if (scene_context.view.pitch < -89.0) {
            scene_context.view.pitch = -89.0;
        }
    }
}

glfw_error :: proc(err: i32, info: cstring) {
    fmt.printf("error: %d, info: %s\n", err, info);
}

test_load :: proc(response: ^vg_fetch.sfetch_response_t) {
    if(response.finished) {
        fmt.println("finished");
    } else {
        fmt.println("not finished");
    }
    
    if(response.fetched) {
        fmt.println("fetched");
    } else {
        fmt.println("not fetched");
    }
}

main :: proc() {
    win.monitor_handle = glfw.GetPrimaryMonitor();
    win.size[0] = 1920;
    win.size[1] = 1080;
    win.col = V4(1.0, 0.25, 0.25, 1.0);
    
    vg_scene_context_init();
    
    glfw.Init();
    
    desc: vg_fetch.sfetch_desc_t;
    vg_fetch.sfetch_setup(&desc);
    
    i: u32 = size_of(vg_fetch.sfetch_response_t);
    j: u32 = size_of(vg_fetch.sfetch_handle_t);
    k: u32 = size_of(vg_fetch.sfetch_request_t);
    l: u32 = size_of(vg_fetch.sfetch_desc_t);
    m: u32 = size_of(b8);
    
    buff: [2048]u8;
    
    request: vg_fetch.sfetch_request_t;
    request.path = "D:/vgo/content/shaders/test.frag";
    request.callback = test_load;
    request.buffer_ptr = &buff[0];
    request.buffer_size = 2048;
    vg_fetch.sfetch_send(&request);
    
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
    gl.Enable(gl.MULTISAMPLE);  
    
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
            r: f32 = clamp(0.05, 1.0, cast(f32)col / 7.0);
            
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
        
        vg_fetch.sfetch_dowork();
        glfw_input(win.win);
        
        scene_context_render();
        
        glfw.SwapBuffers(win.win);
        glfw.PollEvents();
    }
    
    vg_fetch.sfetch_shutdown();
    glfw.Terminate();
}