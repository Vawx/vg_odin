
UFBXT_FILE_TEST(maya_constraint_zoo)
#if UFBXT_IMPL
{
	bool found_parent = false;
	bool found_aim = false;
	bool found_rotation = false;
	bool found_scale = false;
	bool found_position = false;
	bool found_ik = false;
	for (size_t i = 0; i < scene->constraints.count; i++) {
		ufbx_constraint *constraint = scene->constraints.data[i];
		
		const char *name = constraint->node->name.data;

		if (!strcmp(name, "joint1") && constraint->type == UFBX_CONSTRAINT_PARENT) {
			found_parent = true;
			ufbxt_assert(constraint->targets.count == 1);
			ufbxt_assert(constraint->constrain_translation[0] && constraint->constrain_translation[1] && constraint->constrain_translation[2]);
			ufbxt_assert(constraint->constrain_rotation[0] && constraint->constrain_rotation[1] && constraint->constrain_rotation[2]);
			ufbxt_assert(!constraint->constrain_scale[0] && !constraint->constrain_scale[1] && !constraint->constrain_scale[2]);
			ufbxt_assert_close_real(err, constraint->targets.data[0].weight, 1.0f);
			ufbxt_assert(!strcmp(constraint->targets.data[0].node->name.data, "Parent"));
		} else if (!strcmp(name, "joint2") && constraint->type == UFBX_CONSTRAINT_AIM) {
			found_aim = true;
			ufbxt_assert(constraint->targets.count == 1);
			ufbxt_assert(!constraint->constrain_translation[0] && !constraint->constrain_translation[1] && !constraint->constrain_translation[2]);
			ufbxt_assert(constraint->constrain_rotation[0] && constraint->constrain_rotation[1] && constraint->constrain_rotation[2]);
			ufbxt_assert(!constraint->constrain_scale[0] && !constraint->constrain_scale[1] && !constraint->constrain_scale[2]);
			ufbxt_assert(constraint->aim_up_node);
			ufbxt_assert(constraint->aim_up_type == UFBX_CONSTRAINT_AIM_UP_TO_NODE);
			ufbxt_assert(!strcmp(constraint->aim_up_node->name.data, "Up"));
			ufbxt_assert_close_real(err, constraint->targets.data[0].weight, 1.0f);
			ufbxt_assert(!strcmp(constraint->targets.data[0].node->name.data, "Aim"));
		} else if (!strcmp(name, "joint3") && constraint->type == UFBX_CONSTRAINT_ROTATION) {
			found_rotation = true;
			ufbxt_assert(constraint->targets.count == 1);
			ufbxt_assert(!constraint->constrain_translation[0] && !constraint->constrain_translation[1] && !constraint->constrain_translation[2]);
			ufbxt_assert(constraint->constrain_rotation[0] && constraint->constrain_rotation[1] && constraint->constrain_rotation[2]);
			ufbxt_assert(!constraint->constrain_scale[0] && !constraint->constrain_scale[1] && !constraint->constrain_scale[2]);
			ufbxt_assert_close_real(err, constraint->targets.data[0].weight, 1.0f);
			ufbxt_assert(!strcmp(constraint->targets.data[0].node->name.data, "joint1"));
		} else if (!strcmp(name, "joint4") && constraint->type == UFBX_CONSTRAINT_SCALE) {
			found_scale = true;
			ufbxt_assert(constraint->targets.count == 1);
			ufbxt_assert(!constraint->constrain_translation[0] && !constraint->constrain_translation[1] && !constraint->constrain_translation[2]);
			ufbxt_assert(!constraint->constrain_rotation[0] && !constraint->constrain_rotation[1] && !constraint->constrain_rotation[2]);
			ufbxt_assert(constraint->constrain_scale[0] && constraint->constrain_scale[1] && constraint->constrain_scale[2]);
			ufbxt_assert_close_real(err, constraint->targets.data[0].weight, 1.0f);
			ufbxt_assert(!strcmp(constraint->targets.data[0].node->name.data, "Scale"));
		} else if (!strcmp(name, "joint5") && constraint->type == UFBX_CONSTRAINT_POSITION) {
			found_position = true;
			ufbxt_assert(constraint->targets.count == 1);
			ufbxt_assert(constraint->constrain_translation[0] && constraint->constrain_translation[1] && constraint->constrain_translation[2]);
			ufbxt_assert(!constraint->constrain_rotation[0] && !constraint->constrain_rotation[1] && !constraint->constrain_rotation[2]);
			ufbxt_assert(!constraint->constrain_scale[0] && !constraint->constrain_scale[1] && !constraint->constrain_scale[2]);
			ufbxt_assert_close_real(err, constraint->targets.data[0].weight, 1.0f);
			ufbxt_assert(!strcmp(constraint->targets.data[0].node->name.data, "Position"));
		} else if (!strcmp(name, "joint7") && constraint->type == UFBX_CONSTRAINT_SINGLE_CHAIN_IK) {
			found_ik = true;
			ufbxt_assert(constraint->targets.count == 1);
			ufbxt_assert(!constraint->constrain_translation[0] && !constraint->constrain_translation[1] && !constraint->constrain_translation[2]);
			ufbxt_assert(constraint->constrain_rotation[0] && constraint->constrain_rotation[1] && constraint->constrain_rotation[2]);
			ufbxt_assert(!constraint->constrain_scale[0] && !constraint->constrain_scale[1] && !constraint->constrain_scale[2]);
			ufbxt_assert_close_real(err, constraint->targets.data[0].weight, 1.0f);
			ufbxt_assert(!strcmp(constraint->targets.data[0].node->name.data, "Pole"));
			ufbxt_assert(constraint->ik_effector && !strcmp(constraint->ik_effector->name.data, "IKHandle"));
			ufbxt_assert(constraint->ik_end_node && !strcmp(constraint->ik_end_node->name.data, "joint10"));
		}

	}

	ufbxt_assert(found_parent);
	ufbxt_assert(found_aim);
	ufbxt_assert(found_rotation);
	ufbxt_assert(found_scale);
	ufbxt_assert(found_position);
	ufbxt_assert(found_ik);
}
#endif

UFBXT_FILE_TEST(maya_character)
#if UFBXT_IMPL
{
	// TODO: Test things
}
#endif

UFBXT_FILE_TEST(maya_constraint_multi)
#if UFBXT_IMPL
{
	ufbxt_assert(scene->constraints.count == 1);
	ufbx_constraint *constraint = scene->constraints.data[0];
	ufbxt_assert(constraint->type == UFBX_CONSTRAINT_POSITION);
	ufbxt_assert(constraint->constrain_translation[0] && constraint->constrain_translation[1] && constraint->constrain_translation[2]);
	ufbxt_assert(!constraint->constrain_rotation[0] && !constraint->constrain_rotation[1] && !constraint->constrain_rotation[2]);
	ufbxt_assert(!constraint->constrain_scale[0] && !constraint->constrain_scale[1] && !constraint->constrain_scale[2]);
	ufbxt_assert(constraint->targets.count == 2);
	for (size_t i = 0; i < constraint->targets.count; i++) {
		const ufbx_constraint_target *target = &constraint->targets.data[i];
		if (!strcmp(target->node->name.data, "TargetA")) {
			ufbxt_assert_close_real(err, target->weight, 1.0f);
		} else if (!strcmp(target->node->name.data, "TargetB")) {
			ufbxt_assert_close_real(err, target->weight, 2.0f);
		} else {
			ufbxt_assert(false && "Unexpected target");
		}
	}
}
#endif
