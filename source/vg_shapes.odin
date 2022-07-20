package vg
import gl "vendor:OpenGL"
import math "core:math"

vg_shape_cube :: proc(r: ^gl_render_object) {
    if(r.data.vao == 0) {
        vertices: []f32 = {
            // back face
            -1.0, -1.0, -1.0, -1.0, 0.0, 0.0, 0.0,  0.0,  // bottom-left
            1.0,  1.0, -1.0, -1.0, 1.0, 1.0, 0.0,  0.0,  // top-right
            1.0, -1.0, -1.0, -1.0, 1.0, 0.0, 0.0,  0.0, // bottom-right         
            1.0,  1.0, -1.0, -1.0, 1.0, 1.0, 0.0,  0.0,  // top-right
            -1.0, -1.0, -1.0, -1.0, 0.0, 0.0, 0.0,  0.0, // bottom-left
            -1.0,  1.0, -1.0, -1.0, 0.0, 1.0, 0.0,  0.0,  // top-left
            // front face
            -1.0, -1.0,  1.0,  1.0, 0.0, 0.0,  0.0,  0.0, // bottom-left
            1.0, -1.0,  1.0,  1.0, 1.0, 0.0, 0.0,  0.0,  // bottom-right
            1.0,  1.0,  1.0,   1.0, 1.0, 1.0, 0.0,  0.0,  // top-right
            1.0,  1.0,  1.0,   1.0, 1.0, 1.0, 0.0,  0.0,  // top-right
            -1.0,  1.0,  1.0,  1.0, 0.0, 1.0, 0.0,  0.0,   // top-left
            -1.0, -1.0,  1.0,  1.0, 0.0, 0.0, 0.0,  0.0,   // bottom-left
            // left face
            -1.0,  1.0,  1.0, 0.0, 1.0, 0.0, -1.0,  0.0,   // top-right
            -1.0,  1.0, -1.0, 0.0, 1.0, 1.0, -1.0,  0.0,   // top-left
            -1.0, -1.0, -1.0, 0.0, 0.0, 1.0, -1.0,  0.0,   // bottom-left
            -1.0, -1.0, -1.0, 0.0, 0.0, 1.0, -1.0,  0.0,   // bottom-left
            -1.0, -1.0,  1.0, 0.0, 0.0, 0.0, -1.0,  0.0,   // bottom-right
            -1.0,  1.0,  1.0, 0.0, 1.0, 0.0, -1.0,  0.0,   // top-right
            // right face
            1.0,  1.0,  1.0,  0.0, 1.0, 0.0, 1.0,  0.0,   // top-left
            1.0, -1.0, -1.0,  0.0, 0.0, 1.0, 1.0,  0.0,   // bottom-right
            1.0,  1.0, -1.0,  0.0, 1.0, 1.0, 1.0,  0.0,   // top-right         
            1.0, -1.0, -1.0,  0.0, 0.0, 1.0, 1.0,  0.0,   // bottom-right
            1.0,  1.0,  1.0,   0.0, 1.0, 0.0, 1.0,  0.0,  // top-left
            1.0, -1.0,  1.0,  0.0, 0.0, 0.0, 1.0,  0.0,   // bottom-left     
            // bottom face
            -1.0, -1.0, -1.0,   0.0, 0.0, 1.0, 0.0, -1.0,  // top-right
            1.0, -1.0, -1.0,  0.0, 1.0, 1.0, 0.0, -1.0,   // top-left
            1.0, -1.0,  1.0,  0.0, 1.0, 0.0, 0.0, -1.0,   // bottom-left
            1.0, -1.0,  1.0,  0.0, 1.0, 0.0, 0.0, -1.0,   // bottom-left
            -1.0, -1.0,  1.0,  0.0, 0.0, 0.0, 0.0, -1.0,   // bottom-right
            -1.0, -1.0, -1.0,  0.0, 0.0, 1.0, 0.0, -1.0,   // top-right
            // top face
            -1.0,  1.0, -1.0,  0.0, 0.0, 1.0, 0.0,  1.0,   // top-left
            1.0,  1.0 , 1.0,  0.0, 1.0, 0.0, 0.0,  1.0,   // bottom-right
            1.0,  1.0, -1.0,   0.0, 1.0, 1.0, 0.0,  1.0,  // top-right     
            1.0,  1.0,  1.0,  0.0, 1.0, 0.0, 0.0,  1.0,   // bottom-right
            -1.0,  1.0, -1.0,  0.0, 0.0, 1.0, 0.0,  1.0,   // top-left
            -1.0,  1.0,  1.0,  0.0, 0.0, 0.0, 0.0,  1.0,    // bottom-left        
        };
        
        gl.GenVertexArrays(1, &r.data.vao);
        gl.GenBuffers(1, &r.data.vbo);
        
        gl.BindBuffer(gl.ARRAY_BUFFER, r.data.vao);
        gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(f32), &vertices[0], gl.STATIC_DRAW);
        gl.BindVertexArray(r.data.vao);
        
        gl.EnableVertexAttribArray(0);
        gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(mesh_vertex), 0);
        gl.EnableVertexAttribArray(1);
        gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(mesh_vertex), size_of(v3));
        gl.EnableVertexAttribArray(2);
        gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, size_of(mesh_vertex), size_of(v3) + size_of(v3));
        
        gl.BindBuffer(gl.ARRAY_BUFFER, 0);
        gl.BindVertexArray(0);
        
        r.data.indice_count = 36;
        r.mode = .triangles;
        gl.BindVertexArray(r.data.vao);
    }
}

vg_shape_sphere :: proc(r: ^gl_render_object) {
    
    sphereVAO: u32 = 0;
    indexCount: u32 = 0;
    
    if (r.data.vao == 0) {
        gl.GenVertexArrays(1, &r.data.vao);
        gl.GenBuffers(1, &r.data.vbo);
        gl.GenBuffers(1, &r.data.ebo);
        
        positions: [dynamic]v3;
        uv: [dynamic]v2;
        normals: [dynamic]v3;
        indices: [dynamic]i32;
        
        X_SEGMENTS: int = 64;
        Y_SEGMENTS: int = 64;
        PI: f32 = 3.14159265359;
        for x := 0; x <= X_SEGMENTS; x += 1 {
            for y := 0; y <= Y_SEGMENTS; y += 1 {
                xSegment: f32 = cast(f32)x / cast(f32)X_SEGMENTS;
                ySegment: f32 = cast(f32)y / cast(f32)Y_SEGMENTS;
                xPos: f32 = math.cos(xSegment * 2.0 * PI) * math.sin(ySegment * PI);
                yPos: f32 = math.cos(ySegment * PI);
                zPos: f32 = math.sin(xSegment * 2.0 * PI) * math.sin(ySegment * PI);
                
                append(&positions, V3(xPos, yPos, zPos));
                append(&uv, V2(xSegment, ySegment));
                append(&normals, V3(xPos, yPos, zPos));
            }
        }
        
        oddRow: bool = false;
        for y := 0; y < Y_SEGMENTS; y += 1 {
            if oddRow == false {
                for x := 0; x <= X_SEGMENTS; x += 1 {
                    append(&indices, cast(i32)(y * (X_SEGMENTS + 1) + x));
                    append(&indices, cast(i32)((y + 1) * (X_SEGMENTS + 1) + x));
                }
            } else {
                for x := X_SEGMENTS; x >= 0; x -= 1 {
                    append(&indices, cast(i32)((y + 1) * (X_SEGMENTS + 1) + x));
                    append(&indices, cast(i32)(y * (X_SEGMENTS + 1) + x));
                }
            }
            oddRow = !oddRow;
        }
        r.data.indice_count = auto_cast len(indices);
        
        data: [dynamic]f32;
        for i := 0; i < len(positions); i += 1 {
            append(&data, positions[i].x);
            append(&data, positions[i].y);
            append(&data, positions[i].z);
            
            if len(normals) > 0  {
                append(&data, normals[i].x);
                append(&data, normals[i].y);
                append(&data, normals[i].z);
            }
            if len(uv)  > 0 {
                append(&data, uv[i].x);
                append(&data, uv[i].y);
            }
        }
        
        gl.GenVertexArrays(1, &r.data.vao);
        gl.GenBuffers(1, &r.data.vbo);
        gl.GenBuffers(1, &r.data.ebo);
        gl.BindVertexArray(r.data.vao);
        
        gl.BindBuffer(gl.ARRAY_BUFFER, r.data.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, len(data) * size_of(f32), &data[0], gl.STATIC_DRAW);
        
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, r.data.ebo);
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices) * size_of(i32), &indices[0], gl.STATIC_DRAW);
        
        gl.EnableVertexAttribArray(0);
        gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(mesh_vertex), 0);
        gl.EnableVertexAttribArray(1);
        gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(mesh_vertex), size_of(v3));
        gl.EnableVertexAttribArray(2);
        gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, size_of(mesh_vertex), size_of(v3) + size_of(v3));
        
        r.mode = .triangle_strip;
    }
}

vg_shape_quad :: proc(r: ^gl_render_object) {
    if (r.data.vao == 0) {
        quad_vertices: [20]f32 = {
            -1.0,  1.0, 0.0, 0.0, 1.0,
            -1.0, -1.0, 0.0, 0.0, 0.0,
            1.0,  1.0, 0.0, 1.0, 1.0,
            1.0, -1.0, 0.0, 1.0, 0.0,
        };
        
        gl.GenVertexArrays(1, &r.data.vao);
        gl.GenBuffers(1, &r.data.vbo);
        gl.BindVertexArray(r.data.vao);
        gl.BindBuffer(gl.ARRAY_BUFFER, r.data.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, 20 * size_of(f32), &quad_vertices[0], gl.STATIC_DRAW);
        gl.EnableVertexAttribArray(0);
        gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 0);
        gl.EnableVertexAttribArray(1);
        gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 3 * size_of(f32));
        
        r.mode = .triangle_strip;
        r.data.indice_count = 4;
    }
}