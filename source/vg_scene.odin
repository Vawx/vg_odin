package vg

import "core:math"
import gl "vendor:OpenGL"

view_context :: struct {
    location: v3,
    front: v3,
    up: v3,
    right: v3,
    yaw: f64,
    pitch: f64,
    fov: f32,
    view: m4,
    projection: m4,
};

scene_light :: struct {
    pos: v3,
    col: v3,
}

vg_scene_context :: struct {
    view: view_context,
    render_objects: [dynamic]gl_render_object,
    lights: [dynamic]scene_light,
}

scene_context: vg_scene_context;

vg_scene_context_init :: proc() {
    scene_context.view.location = V3(0, 0, 25);
    scene_context.view.yaw = -90;
    scene_context.view.pitch = 0;
    scene_context.view.fov = 40;
    scene_context.view.up = V3(0, 1, 0);
    scene_context.view.front = V3(0, 0, -1);
    
    l: scene_light;
    l.pos = V3(-10, 10, 10);
    l.col = V3(300, 300, 300);
    append(&scene_context.lights, l);
    l.pos = V3(10, 10, 10);
    append(&scene_context.lights, l);
    l.pos = V3(-10, -10, 10);
    append(&scene_context.lights, l);
    l.pos = V3(10, -10, 10);
    append(&scene_context.lights, l);
}

view_context_push_to :: proc(shader: ^gl_program) {
    gl.UseProgram(shader.id);
    gl_set_m4(shader, "u_projection", scene_context.view.projection);
    gl_set_m4(shader, "u_view", scene_context.view.view);
}

view_context_transform :: proc() {
    scene_context.view.front = V3d(0);
    scene_context.view.front.x = cast(f32)math.cos(math.to_radians(scene_context.view.yaw)) * cast(f32)math.cos(math.to_radians(scene_context.view.pitch));
    scene_context.view.front.y = cast(f32)math.sin(math.to_radians(scene_context.view.pitch));
    scene_context.view.front.z = cast(f32) math.sin(math.to_radians(scene_context.view.yaw)) * cast(f32)math.cos(math.to_radians(scene_context.view.pitch));
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
    
    // render
    for i := 0; i < len(scene_context.render_objects); i += 1 {
        obj: gl_render_object = scene_context.render_objects[i];
        
        view_context_push_to(&obj.program);
        gl_set_real(&obj.program, "metallic", 0.5);
        gl_set_real(&obj.program, "roughness", 0.5);
        gl_set_v3(&obj.program, "camPos", scene_context.view.location);
        
        gl.ActiveTexture(gl.TEXTURE0);
        gl.BindTexture(gl.TEXTURE_CUBE_MAP, hdr_context.irradiance_map.id);
        gl.ActiveTexture(gl.TEXTURE1);
        gl.BindTexture(gl.TEXTURE_CUBE_MAP, hdr_context.prefilter_map.id);
        gl.ActiveTexture(gl.TEXTURE2);
        gl.BindTexture(gl.TEXTURE_2D, hdr_context.brdf_map.id);
        
        for j := 0; j < len(obj.transforms); j += 1 {
            model: m4 = M4d(1);
            model = m4_mult(model, translate(obj.transforms[j].location));
            model = m4_mult(model, rotate(obj.transforms[j].rotation.x, V3(1.0, 0.0, 0.0)));
            model = m4_mult(model, rotate(obj.transforms[j].rotation.y, V3(0.0, 1.0, 0.0)));
            model = m4_mult(model, rotate(obj.transforms[j].rotation.z, V3(0.0, 0.0, 1.0)));
            model = m4_mult(model, scale(obj.transforms[j].scale));
            gl_set_m4(&obj.program, "u_model", model);
            gl_set_real(&obj.program, "roughness", obj.render_attrib[j].roughness);
            gl_set_real(&obj.program, "metallic", obj.render_attrib[j].metallic);
            
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
    
    gl.BindVertexArray(0);
    
    pos_str: [4]cstring = {
        "lightPositions[0]", 
        "lightPositions[1]", 
        "lightPositions[2]", 
        "lightPositions[3]", 
    };
    
    col_str: [4]cstring = {
        "lightColors[0]", 
        "lightColors[1]", 
        "lightColors[2]", 
        "lightColors[3]", 
    };
    
    for i:= 0; i < len(scene_context.lights); i += 1 {
        gl_set_v3(&hdr_context.pbr, pos_str[i], scene_context.lights[i].pos);
        gl_set_v3(&hdr_context.pbr, col_str[i], scene_context.lights[i].col);
    }
    
    gl.UseProgram(hdr_context.background.program.id);
    view_context_push_to(&hdr_context.background.program);
    gl.ActiveTexture(gl.TEXTURE0);
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, hdr_context.cubemap.id);
    
    // render background
    gl.BindVertexArray(hdr_context.background.obj.data.vao);
    mode: u32 = gl_get_render_mode(hdr_context.background.obj.mode);
    gl.DrawArrays(mode, 0, hdr_context.background.obj.data.indice_count);
    gl.BindVertexArray(0);
    
}
