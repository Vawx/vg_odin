#ifndef UFBXT_CHECK_SCENE_H_INCLUDED
#define UFBXT_CHECK_SCENE_H_INCLUDED

#ifndef ufbxt_assert
#include <assert.h>
#define ufbxt_assert(cond) assert(cond)
#endif

#ifndef ufbxt_arraycount
#define ufbxt_arraycount(arr) (sizeof(arr) / sizeof(*(arr)))
#endif

#include <string.h>
#include "../ufbx.h"

static void ufbxt_check_string(ufbx_string str)
{
	// Data may never be NULL, empty strings should have data = ""
	ufbxt_assert(str.data != NULL);
	ufbxt_assert(strlen(str.data) == str.length);
}

static void ufbxt_check_element_ptr(ufbx_scene *scene, void *v_element)
{
	if (!v_element) return;
	ufbx_element *element = (ufbx_element*)v_element;
	ufbxt_assert(scene->elements.data[element->element_id] == element);
	ufbxt_assert(scene->elements_by_type[element->type].data[element->typed_id] == element);
}

static void ufbxt_check_vertex_element(ufbx_scene *scene, ufbx_mesh *mesh, void *void_elem, size_t elem_size)
{
	ufbx_vertex_attrib *elem = (ufbx_vertex_attrib*)void_elem;
	if (elem->data == NULL) {
		ufbxt_assert(elem->indices == NULL);
		ufbxt_assert(elem->num_values == 0);
		return;
	}

	ufbxt_assert(elem->num_values >= 0);
	if (mesh->num_indices > 0) {
		ufbxt_assert(elem->indices != NULL);
	}

	// Check that the indices are in range
	for (size_t i = 0; i < mesh->num_indices; i++) {
		int32_t ix = elem->indices[i];
		ufbxt_assert(ix >= -1 && (size_t)ix < elem->num_values);
	}

	// Check that the data at invalid index is valid and zero
	char zero[32] = { 0 };
	ufbxt_assert(elem_size <= 32);
	ufbxt_assert(!memcmp((char*)elem->data - elem_size, zero, elem_size));
}

static void ufbxt_check_props(ufbx_scene *scene, const ufbx_props *props, bool top)
{
	ufbx_prop *prev = NULL;
	for (size_t i = 0; i < props->num_props; i++) {
		ufbx_prop *prop = &props->props[i];

		ufbxt_assert(prop->type < UFBX_NUM_PROP_TYPES);
		ufbxt_check_string(prop->name);
		ufbxt_check_string(prop->value_str);

		// Properties should be sorted by name
		if (prev) {
			ufbxt_assert(prop->internal_key >= prev->internal_key);
			ufbxt_assert(strcmp(prop->name.data, prev->name.data) >= 0);
		}

		ufbx_prop *ref = ufbx_find_prop(props, prop->name.data);
		if (top) {
			ufbxt_assert(ref == prop);
		} else {
			ufbxt_assert(ref != NULL);
		}

		prev = prop;
	}

	if (props->defaults) {
		ufbxt_check_props(scene, props->defaults, false);
	}
}

static void ufbxt_check_element(ufbx_scene *scene, ufbx_element *element)
{
	ufbxt_check_props(scene, &element->props, true);
	ufbxt_check_string(element->name);
	ufbxt_assert(scene->elements.data[element->element_id] == element);

	ufbxt_assert(scene->elements.data[element->element_id] == element);
	ufbxt_assert(scene->elements_by_type[element->type].data[element->typed_id] == element);

	for (size_t i = 0; i < element->connections_src.count; i++) {
		ufbx_connection *c = &element->connections_src.data[i];
		ufbxt_check_string(c->src_prop);
		ufbxt_check_string(c->dst_prop);
		ufbxt_assert(c->src == element);
		if (i > 0) {
			int cmp = strcmp(c[-1].src_prop.data, c[0].src_prop.data);
			ufbxt_assert(cmp <= 0);
			if (cmp == 0) {
				ufbxt_assert(strcmp(c[-1].dst_prop.data, c[0].dst_prop.data) <= 0);
			}
		}
	}

	for (size_t i = 0; i < element->connections_dst.count; i++) {
		ufbx_connection *c = &element->connections_dst.data[i];
		ufbxt_check_string(c->src_prop);
		ufbxt_check_string(c->dst_prop);
		ufbxt_assert(c->dst == element);
		if (i > 0) {
			int cmp = strcmp(c[-1].dst_prop.data, c[0].dst_prop.data);
			ufbxt_assert(cmp <= 0);
			if (cmp == 0) {
				ufbxt_assert(strcmp(c[-1].src_prop.data, c[0].src_prop.data) <= 0);
			}
		}
	}

	ufbxt_assert(element->type >= 0);
	ufbxt_assert(element->type < UFBX_NUM_ELEMENT_TYPES);
	if (element->type >= UFBX_ELEMENT_TYPE_FIRST_ATTRIB && element->type <= UFBX_ELEMENT_TYPE_LAST_ATTRIB) {
		for (size_t i = 0; i < element->instances.count; i++) {
			ufbx_node *node = element->instances.data[i];
			ufbxt_check_element_ptr(scene, node);
			bool found = false;
			for (size_t j = 0; j < node->all_attribs.count; j++) {
				if (node->all_attribs.data[j] == element) {
					found = true;
					break;
				}
			}
			ufbxt_assert(found);
		}
	} else {
		ufbxt_assert(element->instances.count == 0);
	}
}

static void ufbxt_check_node(ufbx_scene *scene, ufbx_node *node)
{
	ufbxt_check_element_ptr(scene, node->parent);
	if (node->parent) {
		bool found = false;
		for (size_t i = 0; i < node->parent->children.count; i++) {
			if (node->parent->children.data[i] == node) {
				found = true;
				break;
			}
		}
		ufbxt_assert(found);
	}

	for (size_t i = 0; i < node->children.count; i++) {
		ufbxt_assert(node->children.data[i]->parent == node);
	}

	for (size_t i = 0; i < node->all_attribs.count; i++) {
		ufbx_element *attrib = node->all_attribs.data[i];
		ufbxt_check_element_ptr(scene, attrib);
		bool found = false;
		for (size_t j = 0; j < attrib->instances.count; j++) {
			if (attrib->instances.data[j] == node) {
				found = true;
				break;
			}
		}
		ufbxt_assert(found);
	}

	if (node->all_attribs.count > 0) {
		ufbxt_assert(node->attrib == node->all_attribs.data[0]);
		if (node->all_attribs.count == 1) {
			ufbxt_assert(node->attrib_type == node->attrib->type);
		}
	}

	switch (node->attrib_type) {
	case UFBX_ELEMENT_MESH: ufbxt_assert(node->mesh); break;
	case UFBX_ELEMENT_LIGHT: ufbxt_assert(node->light); break;
	case UFBX_ELEMENT_CAMERA: ufbxt_assert(node->camera); break;
	case UFBX_ELEMENT_BONE: ufbxt_assert(node->bone); break;
	default: /* No shorthand */ break;
	}
}

static void ufbxt_check_mesh(ufbx_scene *scene, ufbx_mesh *mesh)
{
	// ufbx_mesh *found = ufbx_find_mesh(scene, mesh->node.name.data);
	// ufbxt_assert(found && !strcmp(found->node.name.data, mesh->node.name.data));

	ufbxt_assert(mesh->vertices == mesh->vertex_position.data);
	ufbxt_assert(mesh->vertex_indices == mesh->vertex_position.indices);

	for (size_t vi = 0; vi < mesh->num_vertices; vi++) {
		int32_t ii = mesh->vertex_first_index[vi];
		if (ii >= 0) {
			ufbxt_assert(mesh->vertex_indices[ii] == vi);
		} else {
			ufbxt_assert(ii == -1);
		}
	}

	ufbxt_check_vertex_element(scene, mesh, &mesh->vertex_position, sizeof(ufbx_vec3));
	ufbxt_check_vertex_element(scene, mesh, &mesh->vertex_normal, sizeof(ufbx_vec3));
	ufbxt_check_vertex_element(scene, mesh, &mesh->vertex_tangent, sizeof(ufbx_vec3));
	ufbxt_check_vertex_element(scene, mesh, &mesh->vertex_bitangent, sizeof(ufbx_vec3));
	ufbxt_check_vertex_element(scene, mesh, &mesh->vertex_uv, sizeof(ufbx_vec2));
	ufbxt_check_vertex_element(scene, mesh, &mesh->vertex_color, sizeof(ufbx_vec4));
	ufbxt_check_vertex_element(scene, mesh, &mesh->skinned_position, sizeof(ufbx_vec3));
	ufbxt_check_vertex_element(scene, mesh, &mesh->skinned_normal, sizeof(ufbx_vec3));

	ufbxt_assert(mesh->num_vertices == mesh->vertex_position.num_values);
	ufbxt_assert(mesh->num_triangles <= mesh->num_indices);

	ufbxt_assert(mesh->vertex_position.value_reals == 3);
	ufbxt_assert(mesh->vertex_normal.value_reals == 3);
	ufbxt_assert(mesh->vertex_tangent.value_reals == 3);
	ufbxt_assert(mesh->vertex_bitangent.value_reals == 3);
	ufbxt_assert(mesh->vertex_uv.value_reals == 2);
	ufbxt_assert(mesh->vertex_color.value_reals == 4);
	ufbxt_assert(mesh->vertex_crease.value_reals == 1);

	uint32_t prev_end = 0;
	for (size_t i = 0; i < mesh->num_faces; i++) {
		ufbx_face face = mesh->faces[i];
		ufbxt_assert(face.index_begin == prev_end);
		prev_end = face.index_begin + face.num_indices;
		ufbxt_assert(prev_end <= mesh->num_indices);

		// TODO: Maybe?
#if 0
		for (size_t j = face.index_begin; j < face.index_begin + face.num_indices; j++) {
			ufbx_face *p_face = ufbx_find_face(mesh, j);
			ufbxt_assert(p_face - mesh->faces == i);
		}
#endif

		// TODO
#if 0
		if (face.num_indices >= 3) {
			size_t num_tris = face.num_indices - 2;
			ufbxt_assert(face.num_indices <= 1024);
			uint32_t tris[1024];
			size_t ix_count[1024];
			memset(tris, 0xff, num_tris * 3 * sizeof(uint32_t));
			memset(ix_count, 0, face.num_indices * sizeof(uint32_t));
			ufbxt_assert(ufbx_triangulate(tris, ufbxt_arraycount(tris), mesh, face));

			for (size_t i = 0; i < num_tris; i++) {
				uint32_t a = tris[i*3 + 0];
				uint32_t b = tris[i*3 + 1];
				uint32_t c = tris[i*3 + 2];
				ufbxt_assert(a != b);
				ufbxt_assert(b != c);
				ufbxt_assert(a >= face.index_begin && a - face.index_begin < face.num_indices);
				ufbxt_assert(b >= face.index_begin && b - face.index_begin < face.num_indices);
				ufbxt_assert(c >= face.index_begin && c - face.index_begin < face.num_indices);
				ix_count[a - face.index_begin]++;
				ix_count[b - face.index_begin]++;
				ix_count[c - face.index_begin]++;
			}

			for (uint32_t i = 0; i < face.num_indices; i++) {
				ufbxt_assert(ix_count[i] >= 0);
			}
		}
#endif
	}

	for (size_t i = 0; i < mesh->num_edges; i++) {
		ufbx_edge edge = mesh->edges[i];
		ufbxt_assert(edge.indices[0] < mesh->num_indices);
		ufbxt_assert(edge.indices[1] < mesh->num_indices);
	}

	for (size_t i = 0; i < mesh->uv_sets.count; i++) {
		ufbx_uv_set *set = &mesh->uv_sets.data[i];
		ufbxt_assert(set->vertex_uv.value_reals == 2);
		ufbxt_assert(set->vertex_tangent.value_reals == 3);
		ufbxt_assert(set->vertex_bitangent.value_reals == 3);

		if (i == 0) {
			ufbxt_assert(mesh->vertex_uv.data == set->vertex_uv.data);
			ufbxt_assert(mesh->vertex_uv.indices == set->vertex_uv.indices);
			ufbxt_assert(mesh->vertex_uv.num_values == set->vertex_uv.num_values);
		}
		ufbxt_check_string(set->name);
		ufbxt_check_vertex_element(scene, mesh, &set->vertex_uv, sizeof(ufbx_vec2));
	}

	for (size_t i = 0; i < mesh->color_sets.count; i++) {
		ufbx_color_set *set = &mesh->color_sets.data[i];
		ufbxt_assert(set->vertex_color.value_reals == 4);

		if (i == 0) {
			ufbxt_assert(mesh->vertex_color.data == set->vertex_color.data);
			ufbxt_assert(mesh->vertex_color.indices == set->vertex_color.indices);
			ufbxt_assert(mesh->vertex_color.num_values == set->vertex_color.num_values);
		}
		ufbxt_check_string(set->name);
		ufbxt_check_vertex_element(scene, mesh, &set->vertex_color, sizeof(ufbx_vec4));
	}

	for (size_t i = 0; i < mesh->num_edges; i++) {
		ufbx_edge edge = mesh->edges[i];
		ufbxt_assert(edge.indices[0] < mesh->num_indices);
		ufbxt_assert(edge.indices[1] < mesh->num_indices);
		// TODO: Do we want find face?
#if 0
		ufbx_face *face = ufbx_find_face(mesh, edge.indices[0]);
		ufbxt_assert(face);
		ufbxt_assert(face == ufbx_find_face(mesh, edge.indices[1]));
#endif
	}

	if (mesh->face_material) {
		for (size_t i = 0; i < mesh->num_faces; i++) {
			int32_t material = mesh->face_material[i];
			ufbxt_assert(material >= 0 && (size_t)material < mesh->materials.count);
		}
	}

	for (size_t i = 0; i < mesh->materials.count; i++) {
		ufbx_mesh_material *mat = &mesh->materials.data[i];
		ufbxt_check_element_ptr(scene, mat->material);

		for (size_t j = 0; j < mat->num_faces; j++) {
			ufbxt_assert(mesh->face_material[mat->face_indices[j]] == (int32_t)i);
		}
	}
	for (size_t i = 0; i < mesh->skin_deformers.count; i++) {
		ufbxt_assert(mesh->skin_deformers.data[i]->vertices.count >= mesh->num_vertices);
		ufbxt_check_element_ptr(scene, mesh->skin_deformers.data[i]);
	}
	for (size_t i = 0; i < mesh->blend_deformers.count; i++) {
		ufbxt_check_element_ptr(scene, mesh->blend_deformers.data[i]);
	}
	for (size_t i = 0; i < mesh->cache_deformers.count; i++) {
		ufbxt_check_element_ptr(scene, mesh->cache_deformers.data[i]);
	}
	for (size_t i = 0; i < mesh->all_deformers.count; i++) {
		ufbxt_check_element_ptr(scene, mesh->all_deformers.data[i]);
	}

	// Real TODO
#if 0
	for (size_t i = 0; i < mesh->skins.count; i++) {
		ufbx_skin *skin = &mesh->skins.data[i];
		ufbxt_assert(skin->bone);
		ufbxt_check_node(scene, skin->bone);

		for (size_t j = 0; j < skin->num_weights; j++) {
			ufbxt_assert(skin->indices[j] >= -1 && skin->indices[j] < mesh->num_vertices);
		}
	}
#endif
}

static void ufbxt_check_skin_deformer(ufbx_scene *scene, ufbx_skin_deformer *deformer)
{
	for (size_t i = 0; i < deformer->clusters.count; i++) {
		ufbxt_check_element_ptr(scene, deformer->clusters.data[i]);
		ufbxt_assert(deformer->clusters.data[i]->bone_node);
	}
	for (size_t i = 0; i < deformer->vertices.count; i++) {
		ufbx_skin_vertex vertex = deformer->vertices.data[i];
		ufbxt_assert(vertex.weight_begin <= deformer->weights.count);
		ufbxt_assert(deformer->weights.count - vertex.weight_begin >= vertex.num_weights);

		for (size_t i = 1; i < vertex.num_weights; i++) {
			size_t ix = vertex.weight_begin + i;
			ufbxt_assert(deformer->weights.data[ix - 1].weight >= deformer->weights.data[ix].weight);
		}
	}
	for (size_t i = 0; i < deformer->weights.count; i++) {
		ufbxt_assert(deformer->weights.data[i].cluster_index < deformer->clusters.count);
	}
}

static void ufbxt_check_skin_cluster(ufbx_scene *scene, ufbx_skin_cluster *cluster)
{
	ufbxt_check_element_ptr(scene, cluster->bone_node);
}

static void ufbxt_check_blend_deformer(ufbx_scene *scene, ufbx_blend_deformer *deformer)
{
	for (size_t i = 0; i < deformer->channels.count; i++) {
		ufbxt_check_element_ptr(scene, deformer->channels.data[i]);
	}
}

static void ufbxt_check_blend_channel(ufbx_scene *scene, ufbx_blend_channel *channel)
{
	for (size_t i = 0; i < channel->keyframes.count; i++) {
		if (i > 0) {
			ufbxt_assert(channel->keyframes.data[i - 1].target_weight <= channel->keyframes.data[i].target_weight);
		}
		ufbxt_check_element_ptr(scene, channel->keyframes.data[i].shape);
	}
}

static void ufbxt_check_blend_shape(ufbx_scene *scene, ufbx_blend_shape *shape)
{
}

static void ufbxt_check_cache_deformer(ufbx_scene *scene, ufbx_cache_deformer *deformer)
{
	ufbxt_check_string(deformer->channel);
	ufbxt_check_element_ptr(scene, deformer->file);
}

static void ufbxt_check_cache_file(ufbx_scene *scene, ufbx_cache_file *file)
{
	ufbxt_check_string(file->filename);
	ufbxt_check_string(file->absolute_filename);
	ufbxt_check_string(file->relative_filename);
}

static void ufbx_check_line_curve(ufbx_scene *scene, ufbx_line_curve *line)
{
	for (size_t i = 0; i < line->point_indices.count; i++) {
		int32_t ix = line->point_indices.data[i];
		ufbxt_assert(ix >= 0 && (uint32_t)ix < line->control_points.count);
	}
	for (size_t i = 0; i < line->segments.count; i++) {
		ufbx_line_segment seg = line->segments.data[i];
		ufbxt_assert(seg.num_indices <= line->point_indices.count);
		ufbxt_assert(seg.index_begin <= line->point_indices.count - seg.num_indices);
	}
}

static void ufbxt_check_material(ufbx_scene *scene, ufbx_material *material)
{
	for (size_t i = 0; i < material->textures.count; i++) {
		ufbxt_check_string(material->textures.data[i].material_prop);
		ufbxt_check_string(material->textures.data[i].shader_prop);
		ufbxt_check_element_ptr(scene, material->textures.data[i].texture);
	}

	for (size_t i = 0; i < UFBX_NUM_MATERIAL_FBX_MAPS; i++) {
		ufbxt_check_element_ptr(scene, material->fbx.maps[i].texture);
	}

	for (size_t i = 0; i < UFBX_NUM_MATERIAL_PBR_MAPS; i++) {
		ufbxt_check_element_ptr(scene, material->pbr.maps[i].texture);
	}

	ufbxt_check_element_ptr(scene, material->shader);
}

static void ufbxt_check_texture(ufbx_scene *scene, ufbx_texture *texture)
{
	ufbxt_check_string(texture->filename);
	ufbxt_check_string(texture->relative_filename);
	ufbxt_check_element_ptr(scene, texture->video);
	for (size_t i = 0; i < texture->layers.count; i++) {
		ufbxt_assert(texture->layers.data[i].texture);
		ufbxt_check_element_ptr(scene, texture->layers.data[i].texture);
	}
}

static void ufbxt_check_anim_layer(ufbx_scene *scene, ufbx_anim_layer *anim_layer)
{
	ufbxt_check_string(anim_layer->name);

	for (size_t i = 0; i < anim_layer->anim_values.count; i++) {
		ufbxt_check_element_ptr(scene, anim_layer->anim_values.data[i]);
	}

	size_t props_left = 0;
	ufbx_element *prev_element = NULL;

	for (size_t i = 0; i < anim_layer->anim_props.count; i++) {
		ufbx_anim_prop *anim_prop = &anim_layer->anim_props.data[i];

		ufbxt_check_string(anim_prop->prop_name);
		ufbxt_check_element_ptr(scene, anim_prop->element);
		ufbxt_check_element_ptr(scene, anim_prop->anim_value);

		ufbx_anim_prop *ref = ufbx_find_anim_prop(anim_layer, anim_prop->element, anim_prop->prop_name.data);
		ufbxt_assert(ref);
		ufbxt_assert(!strcmp(ref->prop_name.data, anim_prop->prop_name.data));

		if (props_left > 0) {
			ufbxt_assert(anim_prop->element == prev_element);
			props_left--;
		} else {
			ufbx_anim_prop_list list = ufbx_find_anim_props(anim_layer, anim_prop->element);
			ufbxt_assert(list.count > 0);
			prev_element = anim_prop->element;
			props_left = list.count - 1;
		}
	}

	ufbxt_assert(props_left == 0);
}

static void ufbxt_check_display_layer(ufbx_scene *scene, ufbx_display_layer *layer)
{
	for (size_t i = 0; i < layer->nodes.count; i++) {
		ufbxt_assert(layer->nodes.data[i]);
		ufbxt_check_element_ptr(scene, layer->nodes.data[i]);
	}
}

static void ufbxt_check_selection_set(ufbx_scene *scene, ufbx_selection_set *set)
{
	for (size_t i = 0; i < set->nodes.count; i++) {
		ufbxt_assert(set->nodes.data[i]);
		ufbxt_check_element_ptr(scene, set->nodes.data[i]);
	}
}

static void ufbxt_check_selection_node(ufbx_scene *scene, ufbx_selection_node *node)
{
	ufbxt_check_element_ptr(scene, node->target_node);
	ufbxt_check_element_ptr(scene, node->target_mesh);
}

static void ufbxt_check_constraint(ufbx_scene *scene, ufbx_constraint *constraint)
{
	ufbxt_check_element_ptr(scene, constraint->node);
	ufbxt_check_element_ptr(scene, constraint->aim_up_node);
	ufbxt_check_element_ptr(scene, constraint->ik_effector);
	ufbxt_check_element_ptr(scene, constraint->ik_end_node);
	for (size_t i = 0; i < constraint->targets.count; i++) {
		ufbxt_check_element_ptr(scene, constraint->targets.data[i].node);
	}
}

static void ufbxt_check_scene(ufbx_scene *scene)
{
	ufbxt_check_string(scene->metadata.creator);

	for (size_t i = 0; i < scene->elements.count; i++) {
		ufbxt_check_element(scene, scene->elements.data[i]);
	}

	for (size_t i = 0; i < scene->nodes.count; i++) {
		ufbxt_check_node(scene, scene->nodes.data[i]);
	}

	for (size_t i = 0; i < scene->meshes.count; i++) {
		ufbxt_check_mesh(scene, scene->meshes.data[i]);
	}

	for (size_t i = 0; i < scene->skin_deformers.count; i++) {
		ufbxt_check_skin_deformer(scene, scene->skin_deformers.data[i]);
	}

	for (size_t i = 0; i < scene->skin_clusters.count; i++) {
		ufbxt_check_skin_cluster(scene, scene->skin_clusters.data[i]);
	}

	for (size_t i = 0; i < scene->blend_deformers.count; i++) {
		ufbxt_check_blend_deformer(scene, scene->blend_deformers.data[i]);
	}

	for (size_t i = 0; i < scene->blend_channels.count; i++) {
		ufbxt_check_blend_channel(scene, scene->blend_channels.data[i]);
	}

	for (size_t i = 0; i < scene->blend_shapes.count; i++) {
		ufbxt_check_blend_shape(scene, scene->blend_shapes.data[i]);
	}

	for (size_t i = 0; i < scene->cache_deformers.count; i++) {
		ufbxt_check_cache_deformer(scene, scene->cache_deformers.data[i]);
	}

	for (size_t i = 0; i < scene->cache_files.count; i++) {
		ufbxt_check_cache_file(scene, scene->cache_files.data[i]);
	}

	for (size_t i = 0; i < scene->line_curves.count; i++) {
		ufbx_check_line_curve(scene, scene->line_curves.data[i]);
	}

	for (size_t i = 0; i < scene->anim_layers.count; i++) {
		ufbxt_check_anim_layer(scene, scene->anim_layers.data[i]);
	}

	for (size_t i = 0; i < scene->materials.count; i++) {
		ufbxt_check_material(scene, scene->materials.data[i]);
	}

	for (size_t i = 0; i < scene->textures.count; i++) {
		ufbxt_check_texture(scene, scene->textures.data[i]);
	}

	for (size_t i = 0; i < scene->display_layers.count; i++) {
		ufbxt_check_display_layer(scene, scene->display_layers.data[i]);
	}

	for (size_t i = 0; i < scene->selection_sets.count; i++) {
		ufbxt_check_selection_set(scene, scene->selection_sets.data[i]);
	}

	for (size_t i = 0; i < scene->selection_nodes.count; i++) {
		ufbxt_check_selection_node(scene, scene->selection_nodes.data[i]);
	}

	for (size_t i = 0; i < scene->constraints.count; i++) {
		ufbxt_check_constraint(scene, scene->constraints.data[i]);
	}
}

#endif
