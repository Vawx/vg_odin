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

view_context :: struct {
    location: v3,
    front: v3,
    up: v3,
    right: v3,
    yaw: f32,
    pitch: f32,
    fov: f32,
    view: m4,
    projection: m4,
};

view: view_context;

view_context_transform :: proc() {
    front: v3 = V3d(0);
    front.x = math.cos(math.to_radians(view.yaw)) * math.cos(math.to_radians(view.pitch));
    front.y = math.sin(math.to_radians(view.pitch));
    front.z = math.sin(math.to_radians(view.yaw)) * math.cos(math.to_radians(view.pitch));
    front = v3_norm(front);
    view.right = v3_norm(v3_cross(view.front, view.up));
    
    view.view = M4d(1);
    view.projection = M4d(1);
    view.projection = m4_mult(view.projection, perspective(math.to_radians(view.fov), cast(f32)win.size[0] / cast(f32)win.size[1], 1, 3000));
    view.view = lookat(view.location, v3_add(view.location, view.front), view.up);
}

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
    
    fbx_data: vg_fbx.vg_fbx_import_scene = vg_fbx.ufbx_import_load_fbx_scene("C:\\Users\\kyle\\Desktop\\New folder\\cube.fbx");
    
    view.location = V3d(0);
    view.yaw = -90;
    view.pitch = 0;
    view.fov = 70;
    view.up = V3(0, 1, 0);
    
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
    
    vertices: []f32 = {
        0.5, -0.5, 0.0, 
        -0.5, -0.5, 0.0,
        0.0,  0.5, 0.0  
    };
    
    if(!bind_render_data(&obj, vertices)) {
        fmt.println("failed to generate render object");
        return;
    }
    
    for {
        if(glfw.WindowShouldClose(win.win)) {
            break;
        }
        
        glfw_input(win.win);
        
        gl.ClearColor(win.col.x, win.col.y, win.col.z, win.col.w);
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        
        //view_context_transform();
        
        gl.UseProgram(obj.program.id);
        gl.BindVertexArray(obj.data.vao);
        gl.DrawArrays(gl.TRIANGLES, 0, 3);
        
        glfw.SwapBuffers(win.win);
        glfw.PollEvents();
    }
    
    glfw.Terminate();
}