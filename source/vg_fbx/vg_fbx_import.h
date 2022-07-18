/* vg_fbx_import.h : date = July 16th 2022 5:50 am */

#if !defined(VG_FBX_IMPORT_H)

#define DLL_EXPORT extern __declspec(dllexport)
#define INLINE static inline

#include "vg_fbx_base_types.h"

#include "ufbx/ufbx.c"
#include "ufbx/examples/viewer/external/umath.h"

#define vg_max(a, b) (a > b ? a : b)
#define vg_min(a, b) (a < b ? a : b)
#define vg_abs(a) (a >= 0 ? a : a * -1)
#define vg_nearly_eq(a, b, n) ((vg_abs(a - b)) <= n ? vg_true : vg_false)
#define vg_nearly_zero(a) (vg_abs(a) <= THOUSANDTH ? vg_true : vg_false)
#define vg_within(v, min, max) ((v >= min) && (v < max)) ? vg_true : vg_false)
#define vg_clamp(v, min, max) (v < min ? min : v < max ? v : max)
#define vg_power_of_two(v) ((((s32)v & ((s32)v - 1)) == 0) ? vg_true : vg_false

// basic math types
typedef union v2 {
	struct {
		r32 x, y;
	};
	r32 elements[2];
} v2;

#define V2_IDENT {0.f, 0.f}

INLINE v2 V2(r32 x, r32 y) {
	v2 r = {x, y};
	return r;
}

INLINE v2 V2d(r32 v) {
	v2 r = {v, v};
	return r;
}

typedef union v3 {
	struct {
		r32 x, y, z;
	};
	r32 elements[3];
} v3;

#define V3_IDENT {0.f, 0.f, 0.f}

INLINE v3 V3(r32 x, r32 y, r32 z) {
	v3 r = {x, y, z};
	return r;
}

INLINE v3 V3d(r32 v) {
	v3 r = {v, v, v};
	return r;
}

INLINE v3 v3_add(v3 a, v3 b) {
	v3 r = {a.x + b.x, a.y + b.y, a.z + b.z};
	return r;
}

INLINE v3 v3_sub(v3 a, v3 b) {
	v3 r = {a.x - b.x, a.y - b.y, a.z - b.z};
	return r;
}

INLINE v3 v3_mult(v3 a, v3 b) {
	v3 r = {a.x * b.x, a.y * b.y, a.z * b.z};
	return r;
}

INLINE v3 v3_multf(v3 a, r32 b) {
	v3 r = {a.x * b, a.y * b, a.z * b};
	return r;
}

INLINE r32 v3_dot(v3 a, v3 b) {
	return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
}

INLINE r32 v3_len_sq(v3 a) {
	return v3_dot(a, a);
}

INLINE r64 v3_len(v3 a) {
	return sqrt(v3_len_sq(a));
}

INLINE v3 v3_norm(v3 a) {
	v3 r = V3d(0.f);
	r64 len = v3_len(a);
	if(!vg_nearly_zero(len)) {
		r.x = a.x * (1.f / (r32)len);
		r.y = a.y * (1.f / (r32)len);
		r.z = a.z * (1.f / (r32)len);
	}
	return r;
}

INLINE v3 v3_min(v3 a, v3 b) { return V3(vg_min(a.x, b.x), vg_min(a.y, b.y), vg_min(a.z, b.z)); }
INLINE v3 v3_max(v3 a, v3 b) { return V3(vg_max(a.x, b.x), vg_max(a.y, b.y), vg_max(a.z, b.z)); }

typedef union m4 {
	r32 elements[4][4];
} m4;

INLINE m4 M4() {
	m4 r = {0};
	return r;
}

INLINE m4 M4d(r32 v) {
	m4 r = {0};
	r.elements[0][0] = v;
	r.elements[1][1] = v;
	r.elements[2][2] = v;
	r.elements[3][3] = v;
	return r;
}

INLINE m4 mult_m4_eqf(m4* a, r32 b){
	m4 r = {0};
	s32 columns;
    for(columns = 0; columns < 4; ++columns) {
        s32 rows;
        for(rows = 0; rows < 4; ++rows) {
            r.elements[columns][rows] = a->elements[columns][rows] * b;
        }
    }
}


INLINE m4 m4_mult(m4 left, m4 right) {
    m4 r = {0};
    s32 columns;
    for(columns = 0; columns < 4; ++columns) {
        s32 rows;
        for(rows = 0; rows < 4; ++rows) {
            r32 sum = 0.f;
            s32 current_matrice;
            for(current_matrice = 0; current_matrice < 4; ++current_matrice) {
                sum += left.elements[current_matrice][rows] * right.elements[columns][current_matrice];
            }
            r.elements[columns][rows] = sum;
        }
    }
    return r;
}

// mem
#pragma warning(disable: 4042) //winnls.h "unnamed-parameter has bad storage class"
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#pragma warning(default: 4042)

INLINE u8* allocate(s32 size) {
	u8* ptr = (u8*)VirtualAlloc(NULL, size, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
	return ptr;
}
INLINE void free_allocation(u8* ptr) {
	VirtualFree(ptr, 0, MEM_RELEASE);
}

typedef struct {
	u8* ptr;
	u8* s_ptr;
	u16 type_size;
	u32 size;
} vg_buffer;

typedef struct {
	u8* ptr;
	u8* s_ptr;
	u32 size;
} vg_allocator;

INLINE vg_allocator make_allocator(s32 size) {
	vg_allocator r = {0};
	r.s_ptr = allocate(size);
	r.ptr = r.s_ptr;
	r.size = size;
	return r;
}

#define push_to_allocator(a,t,c) \
(t*)a->ptr; \
a->ptr += (sizeof(t) * c)

#define pop_amount_allocator(a, s) \
a->ptr -= s;

INLINE vg_buffer request_buffer(vg_allocator* allocator, s32 count, s16 type_size) {
	vg_buffer buffer = {0};
	buffer.s_ptr = allocator->ptr;
	buffer.ptr = buffer.s_ptr;
	buffer.size = count * type_size;
	buffer.type_size = type_size;
	
	allocator->ptr += buffer.size;
	return buffer;
}

INLINE s32 buffer_used(vg_buffer* b) {
	if(b->s_ptr == b->ptr) {
		return 0;
	}
	s32 size = (s32)(b->ptr - b->s_ptr);
	return size;
}

INLINE s32 buffer_count(vg_buffer* b) {
	s32 u = buffer_used(b);
	if(u) {
		return u / b->type_size;
	}
	return 0;
}

INLINE u8* buffer_push(vg_buffer* b, u8* ptr) {
	u8* t = b->ptr;
	vg_memcpy(b->ptr, ptr, b->type_size);
	b->ptr += b->type_size;
	return t;
}

INLINE u8* buffer_push_ignore_type(vg_buffer* b, u8* ptr, s32 size) {
	u8* t = b->ptr;
	vg_memcpy(b->ptr, ptr, size);
	b->ptr += b->type_size;
	return t;
}

#define buffer_ptr(b, t, i) (t*)&b->s_ptr[i]
#define buffer_ptr_count(b, t, c) (t*)&b->s_ptr[b->type_size * c]

// ufbx

#define MAX_BONES 64
#define MAX_BLEND_SHAPES 64

INLINE v2 ufbx_vec2_to_v2(ufbx_vec2 v) { return V2(v.x, v.y); }
INLINE v3 ufbx_vec3_to_v3(ufbx_vec3 v) { return V3(v.x, v.y, v.z); }
INLINE um_quat ufbx_to_um_quat(ufbx_quat v) { return um_quat_xyzw((float)v.x, (float)v.y, (float)v.z, (float)v.w); }
INLINE m4 ufbx_mat_to_m4(ufbx_matrix m) {
	m4 r = {(r32)m.m00, (r32)m.m01, (r32)m.m02, (r32)m.m03,
		(r32)m.m10, (r32)m.m11, (r32)m.m12, (r32)m.m13,
		(r32)m.m20, (r32)m.m21, (r32)m.m22, (r32)m.m23,
		0, 0, 0, 1,};
	return r;
}

struct ufbx_fbx_import_data {
	char file_path[255];
	vg_buffer block; // 
	s32 vert_size;
	s32 index_size;
};

typedef struct ufbx_import_mesh_vertex {
	v3 position;
	v3 normal;
	v2 uv;
} ufbx_import_mesh_vertex;

typedef struct ufbx_import_skin_vertex {
	u8 bone_index[4];
	u8 bone_weight[4];
} ufbx_import_skin_vertex;

typedef struct ufbx_import_mesh_part {
	vg_buffer vertex_buffer;
	vg_buffer index_buffer;
	vg_buffer skin_buffer; // Optional
	
	s32 num_indices;
	s32 material_index;
} ufbx_import_mesh_part;

typedef struct ufbx_import_mesh {
	vg_buffer instance_node_indices; // s32
	vg_buffer parts; // ufmeshbx_import_mesh_part
	
	bool aabb_is_local;
	v3 aabb_min;
	v3 aabb_max;
	
	// Skinning (optional)
	bool skinned;
	s32 num_bones;
	s32 bone_indices[MAX_BONES];
	m4 bone_matrices[MAX_BONES];
	
	// Blend shapes (optional)
	s32 num_blend_shapes;
	u32 blend_shape_image;
	s32 blend_channel_indices[MAX_BLEND_SHAPES];
} ufbx_import_mesh;

typedef struct  ufbx_import_node {
	s32 parent_index;
	
	m4 geometry_to_node;
	m4 node_to_parent;
	m4 node_to_world;
	m4 geometry_to_world;
	m4 normal_to_world;
} ufbx_import_node;

typedef struct ufbx_import_blend_channel {
	r32 weight;
} ufbx_import_blend_channel;

typedef struct ufbx_import_node_anim {
	r32 time_begin;
	r32 framerate;
	s32 num_frames;
	um_quat const_rot;
	v3 const_pos;
	v3 const_scale;
	
	v3 *pos;
	v3 *scale;
	um_quat* rot;
} ufbx_import_node_anim;

typedef struct ufbx_import_blend_channel_anim {
	r32 const_weight;
	r32* weight;
} ufbx_import_blend_channel_anim;

typedef struct ufbx_import_anim {
	const char *name;
	r32 time_begin;
	r32 time_end;
	r32 framerate;
	s32 num_frames;
	
	ufbx_import_node_anim* nodes;
	ufbx_import_blend_channel_anim* blend_channels;
} ufbx_import_anim;

typedef struct ufbx_import_scene {
	vg_buffer nodes; // ufbx_import_node
	vg_buffer meshes; // ufbx_import_mesh
	char* file_path;
	
	vg_allocator allocator;
} ufbx_import_scene;

INLINE void ufbx_import_read_node(ufbx_import_node* vnode, ufbx_node* node) {
	vnode->parent_index = node->parent ? node->parent->typed_id : -1;
	vnode->node_to_parent = ufbx_mat_to_m4(node->node_to_parent);
	vnode->node_to_world = ufbx_mat_to_m4(node->node_to_world);
	vnode->geometry_to_node = ufbx_mat_to_m4(node->geometry_to_node);
	vnode->geometry_to_world = ufbx_mat_to_m4(node->geometry_to_world);
	vnode->normal_to_world = ufbx_mat_to_m4(ufbx_matrix_for_normals(&node->geometry_to_world));
}

#include <stdlib.h>

INLINE void* tmp_alloc_imp(size_t type_size, size_t count) {
	void* ptr = calloc(type_size * count, type_size);
	if (!ptr) {
		printf("unable to allocate");
		__debugbreak();
	}
	return ptr;
}

#define alloc(ts, c) (ts*)tmp_alloc_imp(sizeof(ts), c)

INLINE void ufbx_import_read_mesh(ufbx_import_mesh* vmesh, ufbx_mesh* mesh, ufbx_import_scene* scene) {
	// Count the number of needed parts and temporary buffers
	s32 max_parts = 0;
	s32 max_triangles = 0;
	
	// We need to render each material of the mesh in a separate part, so let's
	// count the number of parts and maximum number of triangles needed.
	for (s32 pi = 0; pi < mesh->materials.count; pi++) {
		ufbx_mesh_material *mesh_mat = &mesh->materials.data[pi];
		if (mesh_mat->num_triangles == 0) continue;
		max_parts += 1;
		max_triangles = vg_max((s32)max_triangles, (s32)mesh_mat->num_triangles);
	}
	
	// Temporary buffers
	s32 num_tri_indices = (s32)(mesh->max_face_triangles * 3);
	
	// Result buffers
	
	vg_buffer parts = request_buffer(&scene->allocator, max_parts, sizeof(ufbx_import_mesh_part));
	s32 num_parts = 0;
	
	// In FBX files a single mesh can be instanced by multiple nodes. ufbx handles the connection
	// in two ways: (1) `ufbx_node.mesh/light/camera/etc` contains pointer to the data "attribute"
	// that node uses and (2) each element that can be connected to a node contains a list of
	// `ufbx_node*` instances eg. `ufbx_mesh.instances`.
	vmesh->instance_node_indices = request_buffer(&scene->allocator, (s32)mesh->instances.count, sizeof(s32));
	
	s32 count = 0;
	for(u32 i = 0; i < vmesh->instance_node_indices.size; i += vmesh->instance_node_indices.type_size) {
		s32* indx = (s32*)&vmesh->instance_node_indices.s_ptr[i];
		*indx = (s32)mesh->instances.data[count]->typed_id;
		++count;
	}
	
	// Create the vertex buffers
	s32 num_blend_shapes = 0;
	ufbx_blend_channel *blend_channels[MAX_BLEND_SHAPES];
	s32 num_bones = 0;
	ufbx_skin_deformer *skin = NULL;
	
	u32* tri_indices = alloc(u32, num_tri_indices);
	ufbx_import_mesh_vertex* vertices = alloc(ufbx_import_mesh_vertex, max_triangles * 3);
	ufbx_import_skin_vertex* skin_vertices = alloc(ufbx_import_skin_vertex, max_triangles * 3);
	ufbx_import_skin_vertex* mesh_skin_vertices = alloc(ufbx_import_skin_vertex, mesh->num_vertices);
	u32 *indices = alloc(u32, max_triangles * 3);
	
	if (mesh->skin_deformers.count > 0) {
		vmesh->skinned = true;
		
		// Having multiple skin deformers attached at once is exceedingly rare so we can just
		// pick the first one without having to worry too much about it.
		skin = mesh->skin_deformers.data[0];
		
		// NOTE: A proper implementation would split meshes with too many bones to chunks but
		// for simplicity we're going to just pick the first `MAX_BONES` ones.
		for (s32 ci = 0; ci < skin->clusters.count; ci++) {
			ufbx_skin_cluster *cluster = skin->clusters.data[ci];
			if (num_bones < MAX_BONES) {
				vmesh->bone_indices[num_bones] = (int32_t)cluster->bone_node->typed_id;
				vmesh->bone_matrices[num_bones] = ufbx_mat_to_m4(cluster->geometry_to_bone);
				num_bones++;
			}
		}
		vmesh->num_bones = num_bones;
		
		// Pre-calculate the skinned vertex bones/weights for each vertex as they will probably
		// be shared by multiple indices.
		for (s32 vi = 0; vi < mesh->num_vertices; vi++) {
			s32 num_weights = 0;
			float total_weight = 0.0f;
			float weights[4] = { 0.0f };
			uint8_t clusters[4] = { 0 };
			
			// `ufbx_skin_vertex` contains the offset and number of weights that deform the vertex
			// in a descending weight order so we can pick the first N weights to use and get a
			// reasonable approximation of the skinning.
			ufbx_skin_vertex vertex_weights = skin->vertices.data[vi];
			for (u32 wi = 0; wi < vertex_weights.num_weights; wi++) {
				if (num_weights >= 4) break;
				ufbx_skin_weight weight = skin->weights.data[vertex_weights.weight_begin + wi];
				
				// Since we only support a fixed amount of bones up to `MAX_BONES` and we take the
				// first N ones we need to ignore weights with too high `cluster_index`.
				if (weight.cluster_index < MAX_BONES) {
					total_weight += (float)weight.weight;
					clusters[num_weights] = (uint8_t)weight.cluster_index;
					weights[num_weights] = (float)weight.weight;
					num_weights++;
				}
			}
			
			// Normalize and quantize the weights to 8 bits. We need to be a bit careful to make
			// sure the _quantized_ sum is normalized ie. all 8-bit values sum to 255.
			if (total_weight > 0.0f) {
				ufbx_import_skin_vertex* skin_vert = &mesh_skin_vertices[vi];
				u32 quantized_sum = 0;
				for (s32 i = 0; i < 4; i++) {
					uint8_t quantized_weight = (uint8_t)((float)weights[i] / total_weight * 255.0f);
					quantized_sum += quantized_weight;
					skin_vert->bone_index[i] = clusters[i];
					skin_vert->bone_weight[i] = quantized_weight;
				}
				skin_vert->bone_weight[0] += (u8)(255 - quantized_sum);
			}
		}
	}
	
	// Fetch blend channels from all attached blend deformers.
	for (s32 di = 0; di < mesh->blend_deformers.count; di++) {
		ufbx_blend_deformer *deformer = mesh->blend_deformers.data[di];
		for (s32 ci = 0; ci < deformer->channels.count; ci++) {
			ufbx_blend_channel *chan = deformer->channels.data[ci];
			if (chan->keyframes.count == 0) continue;
			if (num_blend_shapes < MAX_BLEND_SHAPES) {
				blend_channels[num_blend_shapes] = chan;
				vmesh->blend_channel_indices[num_blend_shapes] = (int32_t)chan->typed_id;
				num_blend_shapes++;
			}
		}
	}
	if (num_blend_shapes > 0) {
		//vmesh->blend_shape_image = pack_blend_channels_to_image(mesh, blend_channels, num_blend_shapes);
		//vmesh->num_blend_shapes = num_blend_shapes;
	}
	
	// Our shader supports only a single material per draw call so we need to split the mesh
	// into parts by material. `ufbx_mesh_material` contains a handy compact list of faces
	// that use the material which we use here.
	for (s32 pi = 0; pi < mesh->materials.count; pi++) {
		ufbx_mesh_material *mesh_mat = &mesh->materials.data[pi];
		if (mesh_mat->num_triangles == 0) continue;
		
		ufbx_import_mesh_part* part = (ufbx_import_mesh_part*)&parts.s_ptr[num_parts * sizeof(ufbx_import_mesh_part)];
		parts.ptr += num_parts * sizeof(ufbx_import_mesh_part);
		++num_parts;
		
		s32 num_indices = 0;
		
		// First fetch all vertices into a flat non-indexed buffer, we also need to
		// triangulate the faces
		for (s32 fi = 0; fi < mesh_mat->num_faces; fi++) {
			ufbx_face face = mesh->faces[mesh_mat->face_indices[fi]];
			s32 num_tris = ufbx_triangulate_face(tri_indices, num_tri_indices, mesh, face);
			
			ufbx_vec2 default_uv = { 0 };
			
			// Iterate through every vertex of every triangle in the triangulated result
			for (s32 vi = 0; vi < num_tris * 3; vi++) {
				u32 ix = tri_indices[vi];
				ufbx_import_mesh_vertex* vert = &vertices[num_indices];
				
				ufbx_vec3 pos = ufbx_get_vertex_vec3(&mesh->vertex_position, ix);
				ufbx_vec3 normal = ufbx_get_vertex_vec3(&mesh->vertex_normal, ix);
				ufbx_vec2 uv = mesh->vertex_uv.data ? ufbx_get_vertex_vec2(&mesh->vertex_uv, ix) : default_uv;
				
				vert->position = ufbx_vec3_to_v3(pos);
				vert->normal = v3_norm(ufbx_vec3_to_v3(normal));
				vert->uv = ufbx_vec2_to_v2(uv);
				
				//vert->f_vertex_index = (float)mesh->vertex_indices[ix];
				
				// The skinning vertex stream is pre-calculated above so we just need to
				// copy the right one by the vertex index.
				if (skin) {
					skin_vertices[num_indices] = mesh_skin_vertices[mesh->vertex_indices[ix]];
				}
				++num_indices;
			}
		}
		
		ufbx_vertex_stream streams[2];
		s32 num_streams = 1;
		
		streams[0].data = vertices;
		streams[0].vertex_size = sizeof(ufbx_import_mesh_vertex);
		
		if (skin) {
			streams[1].data = skin_vertices;
			streams[1].vertex_size = sizeof(ufbx_import_skin_vertex);
			num_streams = 2;
		}
		
		// Optimize the flat vertex buffer into an indexed one. `ufbx_generate_indices()`
		// compacts the vertex buffer and returns the number of used vertices.
		ufbx_error error;
		s32 num_vertices = (s32)ufbx_generate_indices(streams, num_streams, indices, num_indices, NULL, &error);
		if (error.type != UFBX_ERROR_NONE) {
			printf("Failed to generate index buffer");
			__debugbreak();
		}
		
		// To unify code we use `ufbx_load_opts.allow_null_material` to make ufbx create a
		// `ufbx_mesh_material` even if there are no materials, so it might be `NULL` here.
		part->num_indices = num_indices;
		if (mesh_mat->material) {
			part->material_index = (int32_t)mesh_mat->material->typed_id;
		} else {
			part->material_index = -1;
		}
		
		part->index_buffer = request_buffer(&scene->allocator, num_indices, sizeof(u32));
		memcpy(part->index_buffer.s_ptr, indices, num_indices * sizeof(u32));
		part->index_buffer.ptr += num_indices * sizeof(u32);
		
		part->vertex_buffer = request_buffer(&scene->allocator, num_vertices, sizeof(ufbx_import_mesh_vertex));
		memcpy(part->vertex_buffer.s_ptr, vertices, num_vertices * sizeof(ufbx_import_mesh_vertex));
		part->vertex_buffer.ptr += num_vertices * sizeof(ufbx_import_mesh_vertex);
		
		if(vmesh->skinned) {
			part->skin_buffer = request_buffer(&scene->allocator, num_vertices, sizeof(ufbx_import_skin_vertex));
			memcpy(part->skin_buffer.s_ptr, skin_vertices, num_vertices * sizeof(ufbx_import_skin_vertex));
		}
	}
	
	// Free the temporary buffers
	free(tri_indices);
	free(vertices);
	free(skin_vertices);
	free(mesh_skin_vertices);
	free(indices);
	
	// Compute bounds from the vertices
	vmesh->aabb_is_local = mesh->skinned_is_local;
	um_vec3 a = um_dup3(+INFINITY);
	vmesh->aabb_min = V3(a.x, a.y, a.z);
	um_vec3 b = um_dup3(-INFINITY);
	vmesh->aabb_max = V3(b.x, b.y, b.z);
	for (s32 i = 0; i < mesh->num_vertices; i++) {
		ufbx_vec3 p = mesh->skinned_position.data[i];
		v3 pos = V3(p.x, p.y, p.z);
		vmesh->aabb_min = v3_min(vmesh->aabb_min, pos);
		vmesh->aabb_max = v3_max(vmesh->aabb_max, pos);
	}
	
	vmesh->parts = parts;
}

INLINE void ufbx_import_read_scene(ufbx_import_scene* import_scene, ufbx_scene* scene) {
	import_scene->nodes = request_buffer(&import_scene->allocator, (s32)scene->nodes.count, sizeof(ufbx_import_node)); 
	
	s32 c = 0;
	for(u32 i = 0; i < import_scene->nodes.size; i += import_scene->nodes.type_size) {
		ufbx_import_node* import_node = (ufbx_import_node*)&import_scene->nodes.s_ptr[i];
		ufbx_node* node = scene->nodes.data[c];
		vg_bool b_valid_mesh = node->mesh != NULL;
		if(b_valid_mesh && node->props.num_props) {
			ufbx_import_read_node(import_node, node);
		}
		++c;
	}
	
	import_scene->meshes = request_buffer(&import_scene->allocator, (s32)scene->meshes.count, sizeof(ufbx_import_mesh)); 
    printf("reading scene. mesh count [%d], mesh type size [%d]\n", (s32)scene->meshes.count, import_scene->meshes.type_size);
	
	c = 0;
	for(u32 i = 0; i < import_scene->meshes.size; i += import_scene->meshes.type_size) {
		ufbx_import_mesh* import_mesh = (ufbx_import_mesh*)&import_scene->meshes.s_ptr[i];
		ufbx_import_read_mesh(import_mesh, scene->meshes.data[c], import_scene);
		++c;
	}
	
	/*
	import_scene->num_blend_channels = scene->blend_channels.count;
	import_scene->blend_channels = alloc(viewer_blend_channel, import_scene->num_blend_channels);
	for (s32 i = 0; i < import_scene->num_blend_channels; ++i) {
		read_blend_channel(&import_scene->blend_channels[i], scene->blend_channels.data[i]);
	}
	
	import_scene->num_animations = scene->anim_stacks.count;
	import_scene->animations = alloc(viewer_anim, import_scene->num_animations);
	for (s32 i = 0; i < import_scene->num_animations; ++i) {
		read_anim_stack(&import_scene->animations[i], scene->anim_stacks.data[i], scene);
	}
*/
}

INLINE u8* ufbx_import_pack_fbx_scene(ufbx_import_scene* scene, s32* out_vert_size, s32* out_index_size, s32* out_size) {
	u8* vertex_buffer = allocate(mega(10));
	u8* v_ptr = vertex_buffer;
	
	u8* index_buffer = allocate(mega(10));
	u8* i_ptr = index_buffer;
	
	for(u32 i = 0; i < scene->meshes.size; i += scene->meshes.type_size) {
		ufbx_import_mesh* import_mesh = (ufbx_import_mesh*)&scene->meshes.s_ptr[i];
		for(u32 j = 0; j < import_mesh->parts.size; j += import_mesh->parts.type_size) {
			ufbx_import_mesh_part* import_mesh_part = (ufbx_import_mesh_part*)&import_mesh->parts.s_ptr[j];
			
			for(u32 v = 0; v < import_mesh_part->vertex_buffer.size; v += import_mesh_part->vertex_buffer.type_size) {
				ufbx_import_mesh_vertex* vert = (ufbx_import_mesh_vertex*)&import_mesh_part->vertex_buffer.s_ptr[v];
				memcpy(v_ptr, vert, import_mesh_part->vertex_buffer.type_size);
				v_ptr += import_mesh_part->vertex_buffer.type_size;
			}
			
			for(u32 idx = 0; idx < import_mesh_part->index_buffer.size; idx += import_mesh_part->index_buffer.type_size) {
				s32* indice = (s32*)&import_mesh_part->index_buffer.s_ptr[idx];
				memcpy(i_ptr, indice, import_mesh_part->index_buffer.type_size);
				i_ptr += import_mesh_part->index_buffer.type_size;
			}
		}
	}
	
	s32 vertex_size = (s32)(v_ptr - vertex_buffer);
	s32 index_size = (s32)(i_ptr - index_buffer);
	
	u8* out_buffer = allocate(vertex_size + index_size);
	u8* o_ptr = out_buffer;
	memcpy(o_ptr, vertex_buffer, vertex_size);
	o_ptr += vertex_size;
	memcpy(o_ptr, index_buffer, index_size);
	o_ptr += index_size;
	
	free_allocation(vertex_buffer);
	free_allocation(index_buffer);
	*out_size = (s32)(o_ptr - out_buffer);
	*out_vert_size = vertex_size;
	*out_index_size = index_size;
	return out_buffer;
}

typedef struct {
	u8* vertices;
	u32 vertices_size;
	u8* indices;
	u32 indices_size;
} mesh_object;

DLL_EXPORT ufbx_import_scene ufbx_import_load_fbx_scene(const char* filename);
DLL_EXPORT mesh_object* ufbx_get_mesh_data(ufbx_import_scene* scene);

#define VG_FBX_IMPORT_H
#endif //VG_FBX_IMPORT_H
