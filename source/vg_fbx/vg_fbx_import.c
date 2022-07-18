#include "vg_fbx_import.h"

ufbx_import_scene ufbx_import_load_fbx_scene(const char* filename) {
	printf("import load fbx scene %s\n", filename);
    ufbx_import_scene import_scene = {0};
	import_scene.allocator = make_allocator(mega(128));
	
	ufbx_load_opts opts = {0};
	opts.load_external_files = true;
	opts.allow_null_material = true;
	opts.target_axes.right = UFBX_COORDINATE_AXIS_POSITIVE_X;
	opts.target_axes.up = UFBX_COORDINATE_AXIS_POSITIVE_Y;
	opts.target_axes.front = UFBX_COORDINATE_AXIS_POSITIVE_Z;
	opts.target_unit_meters = 1.f;
	
	ufbx_error error;
	ufbx_scene *scene = ufbx_load_file(filename, &opts, &error);
	if (!scene) {
		printf("Failed to load scene: [%s]", filename);
        __debugbreak();
	}
	
	ufbx_import_read_scene(&import_scene, scene);
	
	um_vec3 p = um_dup3(+INFINITY);
	um_vec3 m = um_dup3(-INFINITY);
	//import_scene.aabb_min = V3(p.x, p.y, p.z);
	//import_scene.aabb_max = V3(m.x, m.y, m.z);
	
	for(s32 i = 0; i < buffer_used(&import_scene.meshes); i+= import_scene.meshes.type_size) {
		ufbx_import_mesh* mesh = (ufbx_import_mesh*)import_scene.meshes.s_ptr[i];
		v3 origin = v3_multf(v3_add(mesh->aabb_max, mesh->aabb_min), 0.5f);
		v3 extent = v3_multf(v3_sub(mesh->aabb_max, mesh->aabb_min), 0.5f);
		if(mesh->aabb_is_local) {
			for(s32 j = 0; j < buffer_used(&import_scene.nodes); j += import_scene.nodes.type_size) {
				ufbx_import_node* node = (ufbx_import_node*)&import_scene.nodes.s_ptr[i];
				//v3 world_origin = m4_transform_point(&node->geometry_to_world, origin);
				//v3 world_extent = m4_transform_extent(&node->geometry_to_world, extent);
				
				//import_scene.aabb_min = v3_min(import_scene.aabb_min, v3_add(origin, extent));
				//import_scene.aabb_max = v3_max(import_scene.aabb_max, v3_add(origin, extent));
			}
		} else {
			//import_scene.aabb_min = v3_min(import_scene.aabb_min, mesh->aabb_min);
			//import_scene.aabb_max = v3_max(import_scene.aabb_max, mesh->aabb_max);
		}
	}
	
	vg_buffer f_path = request_buffer(&import_scene.allocator, (s32)strlen(filename), sizeof(u8));
	import_scene.file_path = (char*)f_path.s_ptr;
	memcpy(import_scene.file_path, filename, strlen(filename));
	
	ufbx_free_scene(scene);
	return import_scene;
}

mesh_object* ufbx_get_mesh_data(ufbx_import_scene* scene) {
    if(scene && scene->meshes.size) {
        printf("fbx scene is valid has [%d] meshes\n", scene->meshes.size / (s32)sizeof(ufbx_import_mesh));
        
        const s32 mesh_count = scene->meshes.size / sizeof(ufbx_import_mesh);
        mesh_object* r = (mesh_object*)allocate(sizeof(mesh_object) * mesh_count);
        mesh_object* r_ptr = r;
        
        for(s32 i = 0; i < mesh_count; ++i) {
            ufbx_import_mesh_part* part = (ufbx_import_mesh_part*)((ufbx_import_mesh*)scene->meshes.s_ptr)->parts.s_ptr;
            
            r_ptr->vertices = (u8*)part->vertex_buffer.s_ptr;
            r_ptr->indices = (u8*)part->index_buffer.s_ptr;
            r_ptr->vertices_size = buffer_used(&part->vertex_buffer);
            r_ptr->indices_size = buffer_used(&part->index_buffer);
            
            printf("getting mesh data vertices[%d], indices[%d]\n", r_ptr->vertices_size, r_ptr->indices_size);
            r_ptr++;
        }
        return r;
    } 
    if(scene) {
        printf("fbx scene is valid but has [%d] meshes and has a type size of [%d]\n", scene->meshes.size, scene->meshes.type_size);
    } else {
        printf("trying to load fbx scene but scene is invalid.\n");
    }
    return NULL;
}

