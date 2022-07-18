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
    view.front = V3d(0);
    view.front.x = math.cos(math.to_radians(view.yaw)) * math.cos(math.to_radians(view.pitch));
    view.front.y = math.sin(math.to_radians(view.pitch));
    view.front.z = math.sin(math.to_radians(view.yaw)) * math.cos(math.to_radians(view.pitch));
    view.front = v3_norm(view.front);
    view.right = v3_norm(v3_cross(view.front, view.up));
    view.up = v3_norm(v3_cross(view.right, view.front));
    
    view.view = M4d(1);
    view.projection = M4d(1);
    view.projection = m4_mult(view.projection, perspective(math.to_radians(view.fov), cast(f32)win.size[0] / cast(f32)win.size[1], 1, 3000));
    view.view = lookat(view.location, v3_add(view.location, view.front), view.up);
}

view_context_push_to :: proc(shader: ^gl_program) {
    gl.UseProgram(shader.id);
    gl_set_m4(shader, "u_projection", view.projection);
    gl_set_m4(shader, "u_view", view.view);
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
    
    view.location = V3(0, 0, 3);
    view.yaw = -90;
    view.pitch = 0;
    view.fov = 70;
    view.up = V3(0, 1, 0);
    view.front = V3(0, 0, -1);
    
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
    fbx_obj: ^vg_fbx.mesh_object = vg_fbx.ufbx_get_mesh_data("C:\\Users\\kyle\\Desktop\\New folder\\cube.fbx");
    if(!bind_render_data(&obj, auto_cast fbx_obj.vertices, fbx_obj.vertices_size, auto_cast fbx_obj.indices, fbx_obj.indices_size)) {
        fmt.println("failed to bind render data");
    }
    
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
        
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, obj.data.ebo);
        for i := 0; i < len(positions); i += 1 {
            angle += 0.10;
            
            model: m4 = M4d(1);
            model = m4_mult(model, translate(positions[i]));
            model = m4_mult(model, rotate(angle, V3(1.0, 0.3, 0.5)));
            model = m4_mult(model, scale(V3d(1.0)));
            gl_set_m4(&obj.program, "u_model", model);
            
            gl.DrawElements(gl.TRIANGLES, obj.data.indice_count, gl.UNSIGNED_INT, nil);
        }
        
        glfw.SwapBuffers(win.win);
        glfw.PollEvents();
    }
    
    glfw.Terminate();
}