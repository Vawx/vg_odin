package vg

import "core:math"
import gl "vendor:OpenGL"

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

vg_scene_context :: struct {
    view: view_context,
    render_objects: [dynamic]gl_render_object,
}

scene_context: vg_scene_context;

vg_scene_context_init :: proc() {
    scene_context.view.location = V3(0, 0, 30);
    scene_context.view.yaw = -90;
    scene_context.view.pitch = 0;
    scene_context.view.fov = 70;
    scene_context.view.up = V3(0, 1, 0);
    scene_context.view.front = V3(0, 0, -1);
}

view_context_push_to :: proc(shader: ^gl_program) {
    gl.UseProgram(shader.id);
    gl_set_m4(shader, "u_projection", scene_context.view.projection);
    gl_set_m4(shader, "u_view", scene_context.view.view);
}

view_context_transform :: proc() {
    scene_context.view.front = V3d(0);
    scene_context.view.front.x = math.cos(math.to_radians(scene_context.view.yaw)) * math.cos(math.to_radians(scene_context.view.pitch));
    scene_context.view.front.y = math.sin(math.to_radians(scene_context.view.pitch));
    scene_context.view.front.z = math.sin(math.to_radians(scene_context.view.yaw)) * math.cos(math.to_radians(scene_context.view.pitch));
    scene_context.view.front = v3_norm(scene_context.view.front);
    scene_context.view.right = v3_norm(v3_cross(scene_context.view.front, scene_context.view.up));
    scene_context.view.up = v3_norm(v3_cross(scene_context.view.right, scene_context.view.front));
    
    scene_context.view.view = M4d(1);
    scene_context.view.projection = M4d(1);
    scene_context.view.projection = m4_mult(scene_context.view.projection, perspective(math.to_radians(scene_context.view.fov), cast(f32)win.size[0] / cast(f32)win.size[1], 1, 3000));
    scene_context.view.view = lookat(scene_context.view.location, v3_add(scene_context.view.location, scene_context.view.front), scene_context.view.up);
}

scene_context_render :: proc() {
    gl.ClearColor(win.col.x, win.col.y, win.col.z, win.col.w);
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    
    view_context_transform();
    
    for i := 0; i < len(scene_context.render_objects); i += 1 {
        obj: gl_render_object = scene_context.render_objects[i];
        view_context_push_to(&obj.program);
        
        for j := 0; j < len(obj.transforms); j += 1 {
            model: m4 = M4d(1);
            model = m4_mult(model, translate(obj.transforms[j].location));
            model = m4_mult(model, rotate(obj.transforms[j].rotation.x, V3(1.0, 0.0, 0.0)));
            model = m4_mult(model, rotate(obj.transforms[j].rotation.y, V3(0.0, 1.0, 0.0)));
            model = m4_mult(model, rotate(obj.transforms[j].rotation.z, V3(0.0, 0.0, 1.0)));
            model = m4_mult(model, scale(obj.transforms[j].scale));
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
    }
}
