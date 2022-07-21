package vg

import "core:math"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"


hdr_frame_capture :: struct {
    fbo: u32,
    rbo: u32,
    size: v2
}


hdr_gl_env_tex :: struct {
    w, h, n: i32,
    id: u32,
}

hdr_gl_env_cubemap :: struct {
    id: u32,
    fov: f32,
    size: v2,
    projection: m4,
    views: [dynamic]m4,
}

hdr_gl_map_data :: struct {
    id: u32,
    size: v2
} 

hdr_gl_render_data :: struct {
    program: gl_program,
    obj: gl_render_object,
}

hdr_gl_context :: struct {
    frame: hdr_frame_capture,
    hdr: hdr_gl_env_tex,
    cubemap: hdr_gl_env_cubemap,
    irradiance_map: hdr_gl_map_data,
    prefilter_map: hdr_gl_map_data,
    brdf_map: hdr_gl_map_data,
    pbr: gl_program,
    equi: hdr_gl_render_data,
    irradiance: hdr_gl_render_data,
    prefilter: hdr_gl_render_data,
    brdf:  hdr_gl_render_data,
    background: hdr_gl_render_data,
}

hdr_context: hdr_gl_context;

hdr_context_init :: proc() {
    
    // create and init shaders
    hdr_context.pbr = load_shader_from_ptr(pbr_vertex(), pbr_fragment());
    hdr_context.equi.program = load_shader_from_ptr(cubemap_vertex(), equirectangular_to_cubemap());
    hdr_context.irradiance.program = load_shader_from_ptr(cubemap_vertex(), irradiance_convolution());
    hdr_context.prefilter.program = load_shader_from_ptr(cubemap_vertex(), prefilter());
    hdr_context.brdf.program = load_shader_from_ptr(brdf_vertex(), brdf_fragment());
    hdr_context.background.program = load_shader_from_ptr(background_vertex(), background_fragment());
    
    vg_shape_cube(&hdr_context.equi.obj);
    vg_shape_cube(&hdr_context.irradiance.obj);
    vg_shape_cube(&hdr_context.prefilter.obj);
    vg_shape_cube(&hdr_context.background.obj);
    vg_shape_quad(&hdr_context.brdf.obj);
    
    gl.UseProgram(hdr_context.pbr.id);
    gl_set_int(&hdr_context.pbr, "irradianceMap", 0);
    gl_set_int(&hdr_context.pbr, "prefilterMap", 1);
    gl_set_int(&hdr_context.pbr, "brdfLUT", 2);
    gl_set_v3(&hdr_context.pbr, "albedo", V3(1.0, 0, 0.0));
    gl_set_real(&hdr_context.pbr, "ao", 1.0);
    
    gl.UseProgram(hdr_context.background.program.id);
    gl_set_int(&hdr_context.background.program, "environmentMap", 0);
    
    // init frame capture
    gl.GenFramebuffers(1, &hdr_context.frame.fbo);
    gl.GenRenderbuffers(1, &hdr_context.frame.rbo);
    
    gl.BindFramebuffer(gl.FRAMEBUFFER, hdr_context.frame.fbo);
    gl.BindRenderbuffer(gl.RENDERBUFFER, hdr_context.frame.rbo);
    hdr_context.frame.size = V2(2048, 2048);
    gl.RenderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT24, auto_cast hdr_context.frame.size.x, auto_cast hdr_context.frame.size.y);
    gl.FramebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, hdr_context.frame.rbo);
    
    // load HDR texture and bind
    stbi.set_flip_vertically_on_load(1);
    data: ^f32 = stbi.loadf("D:/vgo/content/hdr/HDR_029_Sky_Cloudy_Ref.hdr", &hdr_context.hdr.w, &hdr_context.hdr.h, &hdr_context.hdr.n, 0);
    if(data != nil) {
        gl.GenTextures(1, &hdr_context.hdr.id);
        gl.BindTexture(gl.TEXTURE_2D, hdr_context.hdr.id);
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB16F, hdr_context.hdr.w, hdr_context.hdr.h, 0, gl.RGB, gl.FLOAT, data);
        
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        
        stbi.image_free(data);
    }
    // cubemap
    hdr_context.cubemap.size = V2(2048, 2048);
    
    gl.GenTextures(1, &hdr_context.cubemap.id);
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, hdr_context.cubemap.id);
    for i := 0; i < 6; i += 1 {
        gl.TexImage2D(cast(u32)(gl.TEXTURE_CUBE_MAP_POSITIVE_X + i), 0, gl.RGB16F, auto_cast hdr_context.cubemap.size.x, auto_cast hdr_context.cubemap.size.y, 0, gl.RGB, gl.FLOAT, nil);
    }
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_R, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR); 
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    
    // projection and view matrices
    hdr_context.cubemap.fov = 90.0;
    hdr_context.cubemap.projection = M4d(1.0);
    hdr_context.cubemap.projection = m4_mult(hdr_context.cubemap.projection, perspective(math.to_radians(hdr_context.cubemap.fov), 1.0, 0.1, 10.0));
    
    append(&hdr_context.cubemap.views, lookat(V3(0.0, 0.0, 0.0), V3(1.0,  0.0,  0.0), V3(0.0, -1.0,  0.0)));
    append(&hdr_context.cubemap.views, lookat(V3(0.0, 0.0, 0.0), V3(-1.0,  0.0,  0.0), V3(0.0, -1.0,  0.0)));
    append(&hdr_context.cubemap.views, lookat(V3(0.0, 0.0, 0.0), V3(0.0,  1.0,  0.0), V3(0.0,  0.0,  1.0)));
    append(&hdr_context.cubemap.views, lookat(V3(0.0, 0.0, 0.0), V3(0.0, -1.0,  0.0), V3(0.0,  0.0, -1.0)));
    append(&hdr_context.cubemap.views, lookat(V3(0.0, 0.0, 0.0), V3(0.0,  0.0,  1.0), V3(0.0, -1.0,  0.0)));
    append(&hdr_context.cubemap.views, lookat(V3(0.0, 0.0, 0.0), V3(0.0,  0.0, -1.0), V3(0.0, -1.0,  0.0)));
    
    // convert hdr equir to cubemap
    gl.UseProgram(hdr_context.equi.program.id);
    gl_set_int(&hdr_context.equi.program, "equirectangularMap", 0);
    gl_set_m4(&hdr_context.equi.program, "projection", hdr_context.cubemap.projection);
    gl.ActiveTexture(gl.TEXTURE0);
    gl.BindTexture(gl.TEXTURE_2D, hdr_context.hdr.id);
    
    gl.Viewport(0, 0, auto_cast hdr_context.cubemap.size.x, auto_cast hdr_context.cubemap.size.y);
    gl.BindFramebuffer(gl.FRAMEBUFFER, hdr_context.frame.fbo);
    for i := 0; i < 6; i += 1 {
        gl_set_m4(&hdr_context.equi.program, "view", hdr_context.cubemap.views[i]);
        gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, cast(u32)(gl.TEXTURE_CUBE_MAP_POSITIVE_X + i), hdr_context.cubemap.id, 0);
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        
        // draw HDR equirectangular environment map to cubemap equivalent
        gl.BindVertexArray(hdr_context.equi.obj.data.vao);
        rm: u32 = gl_get_render_mode(hdr_context.equi.obj.mode);
        gl.DrawArrays(rm, 0, hdr_context.equi.obj.data.indice_count);
        gl.BindVertexArray(0);
    }
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0);
    
    // then let OpenGL generate mipmaps from first mip face (combatting visible dots artifact)
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, hdr_context.cubemap.id);
    gl.GenerateMipmap(gl.TEXTURE_CUBE_MAP);
    
    // irradeiance cubemap
    hdr_context.irradiance_map.size = V2(128, 128);
    
    gl.GenTextures(1, &hdr_context.irradiance_map.id);
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, hdr_context.irradiance_map.id);
    for i := 0; i < 6; i += 1 {
        gl.TexImage2D(cast(u32)(gl.TEXTURE_CUBE_MAP_POSITIVE_X + i), 0, gl.RGB16F, auto_cast hdr_context.irradiance_map.size.x, auto_cast hdr_context.irradiance_map.size.y, 0, gl.RGB, gl.FLOAT, nil);
    }
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_R, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    
    gl.BindFramebuffer(gl.FRAMEBUFFER, hdr_context.frame.fbo);
    gl.BindRenderbuffer(gl.RENDERBUFFER, hdr_context.frame.rbo);
    gl.RenderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT24, auto_cast hdr_context.irradiance_map.size.x, auto_cast hdr_context.irradiance_map.size.y);
    
    // diffuse integral irradiance
    gl.UseProgram(hdr_context.irradiance.program.id);
    gl_set_int(&hdr_context.irradiance.program, "environmentMap", 0);
    gl_set_m4(&hdr_context.irradiance.program, "projection", hdr_context.cubemap.projection);
    gl.ActiveTexture(gl.TEXTURE0);
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, hdr_context.cubemap.id);
    
    gl.Viewport(0, 0, auto_cast hdr_context.irradiance_map.size.x, auto_cast hdr_context.irradiance_map.size.y); 
    gl.BindFramebuffer(gl.FRAMEBUFFER, hdr_context.frame.fbo);
    for i := 0; i < 6; i += 1 {
        gl_set_m4(&hdr_context.irradiance.program, "view", hdr_context.cubemap.views[i]);
        gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, cast(u32)(gl.TEXTURE_CUBE_MAP_POSITIVE_X + i), hdr_context.irradiance_map.id, 0);
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        
        // draw irradaiance
        gl.BindVertexArray(hdr_context.irradiance.obj.data.vao);
        rm: u32 = gl_get_render_mode(hdr_context.irradiance.obj.mode);
        gl.DrawArrays(rm, 0, hdr_context.irradiance.obj.data.indice_count);
        gl.BindVertexArray(0);
    }
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0);
    
    // prefilter cubemap
    hdr_context.prefilter_map.size = V2(128, 128);
    gl.GenTextures(1, &hdr_context.prefilter_map.id);
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, hdr_context.prefilter_map.id);
    for i := 0; i < 6; i += 1 {
        gl.TexImage2D(cast(u32)(gl.TEXTURE_CUBE_MAP_POSITIVE_X + i), 0, gl.RGB16F, auto_cast hdr_context.prefilter_map.size.x, auto_cast hdr_context.prefilter_map.size.y, 0, gl.RGB, gl.FLOAT, nil);
    }
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_R, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR); 
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.GenerateMipmap(gl.TEXTURE_CUBE_MAP);
    
    // run a quasi monte-carlo simulation on the environment 
    gl.UseProgram(hdr_context.prefilter.program.id);
    gl_set_int(&hdr_context.prefilter.program, "environmentMap", 0);
    gl_set_m4(&hdr_context.prefilter.program, "projection", hdr_context.cubemap.projection);
    gl.ActiveTexture(gl.TEXTURE0);
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, hdr_context.cubemap.id);
    
    gl.BindFramebuffer(gl.FRAMEBUFFER, hdr_context.frame.fbo);
    maxMipLevels: int = 5;
    for mip := 0; mip < maxMipLevels; mip += 1 {
        // reisze framebuffer according to mip-level size.
        mipWidth: i32 = cast(i32)(128.0 * math.pow(0.5, cast(f32)mip));
        mipHeight: i32 = mipWidth;
        
        gl.BindRenderbuffer(gl.RENDERBUFFER, hdr_context.frame.rbo);
        gl.RenderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT24, mipWidth, mipHeight);
        gl.Viewport(0, 0, mipWidth, mipHeight);
        
        roughness: f32 = cast(f32)mip / cast(f32)(maxMipLevels - 1);
        gl_set_real(&hdr_context.prefilter.program, "roughness", roughness);
        for i := 0; i < 6; i += 1 {
            gl_set_m4(&hdr_context.prefilter.program,"view", hdr_context.cubemap.views[i]);
            gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, cast(u32)(gl.TEXTURE_CUBE_MAP_POSITIVE_X + i), hdr_context.prefilter_map.id, cast(i32)mip);
            
            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
            
            // draw prefilter
            gl.BindVertexArray(hdr_context.prefilter.obj.data.vao);
            rm: u32 = gl_get_render_mode(hdr_context.prefilter.obj.mode);
            gl.DrawArrays(rm, 0, hdr_context.prefilter.obj.data.indice_count);
            gl.BindVertexArray(0);
        }
    }
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0);
    
    // generate a 2D LUT from the BRDF equations used.
    hdr_context.brdf_map.size = V2(512, 512);
    gl.GenTextures(1, &hdr_context.brdf_map.id);
    
    // pre-allocate enough memory for the LUT texture.
    gl.BindTexture(gl.TEXTURE_2D, hdr_context.brdf_map.id);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RG16F, auto_cast hdr_context.brdf_map.size.x, auto_cast hdr_context.brdf_map.size.y, 0, gl.RG, gl.FLOAT, nil);
    // be sure to set wrapping mode to gl.CLAMP_TO_EDGE
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    
    // then re-configure capture framebuffer object and render screen-space quad with BRDF shader.
    gl.BindFramebuffer(gl.FRAMEBUFFER, hdr_context.frame.fbo);
    gl.BindRenderbuffer(gl.RENDERBUFFER, hdr_context.frame.rbo);
    gl.RenderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT24, auto_cast hdr_context.brdf_map.size.x, auto_cast hdr_context.brdf_map.size.y);
    gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, hdr_context.brdf_map.id, 0);
    
    gl.Viewport(0, 0, auto_cast hdr_context.brdf_map.size.x, auto_cast hdr_context.brdf_map.size.y);
    gl.UseProgram(hdr_context.brdf.program.id);
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    // draw
    gl.BindVertexArray(hdr_context.brdf.obj.data.vao);
    rm: u32 = gl_get_render_mode(hdr_context.brdf.obj.mode);
    gl.DrawArrays(rm, 0, 4);
    gl.BindVertexArray(0);
    
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0);
    
    // init static shader uniforms
    gl.UseProgram(hdr_context.background.program.id);
    gl_set_m4(&hdr_context.background.program, "projection", scene_context.view.projection);
    
    
}