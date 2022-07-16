package vg

import math "core:math"

KINDA_SMALL_NUMBER ::proc() -> f32 {
    return 0.00001;
}

THOUSANDTH :: proc() -> f32 {
    return 0.001;
}

BIG_NUMBER :: proc() -> f32 {
    return 340000000000000000000000000000000000000;
}

SMALL_NUMBER :: proc() -> f32 {
    return 0.000000001;
}

absf :: proc(a: f32) -> f32 {
    if(a < 0) {
        return a * -1.0;
    }
    return a;
}

abs :: proc(a: i32)  -> i32{
    if(a < 0) {
        return a * -1;
    }
    return a;
}

nearly_eqf :: proc(a: f32, b: f32, n: f32) -> bool {
    if(absf(a - b) <= n) {
        return true;
    } 
    return false;
}

nearly_eq :: proc(a: i32, b: i32, n: i32) -> bool {
    if(abs(a - b) <= n) {
        return true;
    } 
    return false;
}

nearly_zero :: proc(a: f32) -> bool {
    return absf(a) <= THOUSANDTH() ? true : false;
}

// vec 2
v2 :: struct {
    x, y: f32,
};

V2_IDENT :: proc() -> v2 {
    r: v2;
    r.x = 0;
    r.y = 0;
    return r;
}

V2 :: proc(x, y: f32) -> v2 {
    r: v2;
    r.x = x;
    r.y = y;
    return r;
}

V2d :: proc(a: f32) -> v2 {
    r: v2;
    r.x = a;
    r.y = a;
    return r;
}

v2_add :: proc(a: v2, b: v2) -> v2 {
    r: v2;
    r.x = a.x + b.x;
    r.y = a.y + b.y;
    return r;
}

v2_sub :: proc(a: v2, b: v2) -> v2 {
    r: v2;
    r.x = a.x - b.x;
    r.y = a.y - b.y;
    return r;
}

v2_mult :: proc(a: v2, b: v2) -> v2 {
    r: v2;
    r.x = a.x * b.x;
    r.y = a.y * b.y;
    return r;
}

v2_div :: proc(a: v2, b: v2) -> v2 {
    r: v2;
    if(a.x > 0 && b.x > 0) {
        r.x = a.x / b.x;
    } else {
        r.x = 0;
    }
    if(a.y > 0 && b.y > 0) {
        r.y =  a.y / b.y;
    } else {
        r.y = 0;
    } 
    return r;
}

v2_eq :: proc(a: v2, b: v2) -> bool {
    return a.x == b.x && a.y == b.y;
}

v2_not_eq :: proc(a: v2, b: v2) -> bool {
    return a.x != b.x || a.y != b.y;
}

v2_nearly_eq :: proc(a: v2, b: v2) -> bool {
    return nearly_eqf(a.x, b.y, SMALL_NUMBER()) && nearly_eqf(a.y, b.y, SMALL_NUMBER());
}

v2_dot :: proc(a: v2, b: v2) -> f32 {
	return (a.x * b.x) + (a.y * b.y);
}

v2_len_sq :: proc (a: v2) -> f32 {
	return v2_dot(a, a);
}

v2_len :: proc (a: v2) -> f32{
    return math.sqrt(v2_len_sq(a));
}

v2_norm :: proc(a: v2) -> v2 {
    r: v2 = V2d(0);
	len: f32 = v2_len(a);
	if(!nearly_zero(len)) {
		r.x = a.x * (1 / len);
		r.y = a.y * (1 / len);
	}
	return r;
}

v2_neg :: proc(a: v2) -> v2 {
	x: f32 = a.x * -1;
    y: f32 = a.y * -1;
    r: v2 = V2(x, y);
	return r;
}

// v3
v3 :: struct {
    x, y, z: f32,
};

V3_IDENT :: proc() -> v3 {
    r: v3;
    r.x = 0;
    r.y = 0;
    r.z = 0;
    return r;
}

V3 :: proc(x, y, z: f32) -> v3 {
    r: v3;
    r.x = x;
    r.y = y;
    r.z = z;
    return r;
}

V3d :: proc(a: f32) -> v3 {
    r: v3;
    r.x = a;
    r.y = a;
    r.z = a;
    return r;
}

v3_add :: proc(a: v3, b: v3) -> v3 {
    r: v3;
    r.x = a.x + b.x;
    r.y = a.y + b.y;
    r.z = a.z + b.z;
    return r;
}

v3_sub :: proc(a: v3, b: v3) -> v3 {
    r: v3;
    r.x = a.x - b.x;
    r.y = a.y - b.y;
    r.z = a.z - b.z;
    return r;
}

v3_mult :: proc(a: v3, b: v3) -> v3 {
    r: v3;
    r.x = a.x * b.x;
    r.y = a.y * b.y;
    r.z = a.z * b.z;
    return r;
}

v3_div :: proc(a: v3, b: v3) -> v3 {
    r: v3;
    if(a.x > 0 && b.x > 0) {
        r.x = a.x / b.x;
    } else {
        r.x = 0;
    }
    if(a.y > 0 && b.y > 0) {
        r.y =  a.y / b.y;
    } else {
        r.y = 0;
    }
    if(a.z > 0 && b.z > 0) {
        r.z =  a.z / b.z;
    } else {
        r.z = 0;
    } 
    return r;
}

v3_eq :: proc(a: v3, b: v3) -> bool {
    return a.x == b.x && a.y == b.y || a.z != b.z; 
}

v3_not_eq :: proc(a: v3, b: v3) -> bool {
    return a.x != b.x || a.y != b.y || a.z != b.z;
}

v3_nearly_eq :: proc(a: v3, b: v3) -> bool {
    return nearly_eqf(a.x, b.y, SMALL_NUMBER()) && nearly_eqf(a.y, b.y, SMALL_NUMBER()) && nearly_eqf(a.z, b.z, SMALL_NUMBER());
}

v3_dot :: proc(a: v3, b: v3) -> f32 {
	return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
}

v3_len_sq :: proc (a: v3) -> f32 {
	return v3_dot(a, a);
}

v3_len :: proc (a: v3) -> f32{
    return math.sqrt(v3_len_sq(a));
}

v3_norm :: proc(a: v3) -> v3 {
    r: v3 = V3d(0);
	len: f32 = v3_len(a);
	if(!nearly_zero(len)) {
		r.x = a.x * (1 / len);
		r.y = a.y * (1 / len);
        r.z = a.z * (1 / len);
	}
	return r;
}

v3_neg :: proc(a: v3) -> v3 {
	x: f32 = a.x * -1;
    y: f32 = a.y * -1;
    z: f32 = a.z * -1;
    r: v3 = V3(x, y, z);
	return r;
}

v3_cross :: proc(left: v3, right: v3) -> v3 {
	r: v3 = V3((left.y * right.z) - (left.z * right.y),
               (left.z * right.x) - (left.x * right.z),
               (left.x * right.y) - (left.y * right.x));
	return r;
}

// v4
v4 :: struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
}

V4 :: proc(x, y, z, w: f32) -> v4 {
    r: v4;
    r.x = x;
    r.y = y;
    r.z = z;
    r.w = w;
    return r;
}

// mat4

m4 :: struct {
    elements: [4][4]f32,
}

M4 :: proc() -> m4 {
    r: m4;
    return r;
}

M4d :: proc(v: f32) -> m4 {
    r: m4;
	r.elements[0][0] = v;
	r.elements[1][1] = v;
	r.elements[2][2] = v;
	r.elements[3][3] = v;
	return r;
}


m4_mult :: proc (left: m4, right: m4) -> m4 {
    r: m4;
    columns: i32;
    for columns := 0; columns < 4; columns += 1 {
        rows: i32;
        for rows := 0; rows < 4; rows += 1 {
            sum: f32 = 0;
            current_matrice: i32;
            for current_matrice := 0; current_matrice < 4; current_matrice += 1 {
                sum += left.elements[current_matrice][rows] * right.elements[columns][current_matrice];
            }
            r.elements[columns][rows] = sum;
        }
    }
    return r;
}


ortho :: proc(left: f32, right: f32, bottom: f32, top: f32, n: f32, f: f32) -> m4 {
    r: m4;
    r.elements[0][0] = 2 / (right - left);
    r.elements[1][1] = 2 / (top - bottom);
    r.elements[2][2] = 2 / (n - f);  
    r.elements[3][3] = 1;
    r.elements[3][0] = (left + right) / (left - right);
    r.elements[3][1] = (bottom + top) / (bottom - top);
    r.elements[3][2] = (f + n) / (n - f);
    return r;
}

perspective :: proc(fov: f32, aspect: f32, n: f32, f: f32) -> m4 {
    r: m4;
    tanHalfFovy: f32 = math.tan(fov / 2);
    r.elements[0][0] = 1 / (aspect * tanHalfFovy);
    r.elements[1][1] = 1 / (tanHalfFovy);
    r.elements[2][3] = -1;
    r.elements[2][2] = - (f+n) / (f-n);
    r.elements[3][2] = - (2 * f * n) / (f-n);
    r.elements[3][3] = 0;
    return r;
}

translate :: proc(v: v3) -> m4 {
    r: m4;
    r.elements[3][0] = v.x;
    r.elements[3][1] = v.y;
    r.elements[3][2] = v.z;
    return r;
}

rotate :: proc(angle: f32, axis: v3) -> m4 {
    r: m4;
    in_axis: v3 = v3_norm(axis);
	
	sin_theta: f32  = math.sin(math.to_radians(angle));
	cos_theta: f32  = math.cos(math.to_radians(angle));
	cos_value: f32 = 1 - cos_theta;
	
    r.elements[0][0] = (in_axis.x * in_axis.x * cos_value) + cos_theta;
    r.elements[0][1] = (in_axis.x * in_axis.y * cos_value) + (in_axis.z * sin_theta);
    r.elements[0][2] = (in_axis.x * in_axis.z * cos_value) - (in_axis.y * sin_theta);
	
    r.elements[1][0] = (in_axis.y * in_axis.x * cos_value) - (in_axis.z * sin_theta);
    r.elements[1][1] = (in_axis.y * in_axis.y * cos_value) + cos_theta;
    r.elements[1][2] = (in_axis.y * in_axis.z * cos_value) + (in_axis.x * sin_theta);
	
    r.elements[2][0] = (in_axis.z * in_axis.x * cos_value) + (in_axis.y * sin_theta);
    r.elements[2][1] = (in_axis.z * in_axis.y * cos_value) - (in_axis.x * sin_theta);
    r.elements[2][2] = (in_axis.z * in_axis.z * cos_value) + cos_theta;
	
    return r;
}

scale :: proc(scale: v3) -> m4 {
    r: m4;
    r.elements[0][0] = scale.x;
    r.elements[1][1] = scale.y;
    r.elements[2][2] = scale.z;
    return r;
}

lookat :: proc(eye: v3, center: v3, up: v3) -> m4 {
    r: m4;
    f: v3 = v3_norm(v3_sub(center, eye));
    s: v3 = v3_norm(v3_cross(f, up));
    u: v3 = v3_cross(s, f);
    r.elements[0][0] = s.x;
    r.elements[0][1] = u.x;
    r.elements[0][2] = -f.x;
    r.elements[0][3] = 0;
    r.elements[1][0] = s.y;
    r.elements[1][1] = u.y;
    r.elements[1][2] = -f.y;
    r.elements[1][3] = 0;
    r.elements[2][0] = s.z;
    r.elements[2][1] = u.z;
    r.elements[2][2] = -f.z;
    r.elements[2][3] = 0;
    r.elements[3][0] = -v3_dot(s, eye);
    r.elements[3][1] = -v3_dot(u, eye);
    r.elements[3][2] = v3_dot(f, eye);
    r.elements[3][3] = 1;
    return r;
}

// colors
BLACK :: proc() -> v4 { return V4(0.0, 0.0, 0.0, 1.0); }
WHITE :: proc() -> v4 { return V4(1.0, 1.0, 1.0, 1.0); }
CYAN_AQUA :: proc() -> v4 { return V4(0.0, 1.0, 1.0, 1.0); }
GRAY :: proc() -> v4 { return V4(0.5, 0.5, 0.5, 1.0); }
OLIVE :: proc() -> v4 { return V4(0.5, 0.5, 0.0, 1.0); }
MAROON :: proc() -> v4 { return V4(0.5, 0.0, 0.0, 1.0); }
DARK_RED :: proc() -> v4 { return V4(0.54, 0.0, 0.0, 1.0); }
BROWN :: proc() -> v4 { return V4(0.64, 0.16, 0.16, 1.0); }
FIREBRICK :: proc() -> v4 { return V4(0.69, 0.13, 0.13, 1.0); }
CRIMSON :: proc() -> v4 { return V4(0.86, 0.07, 0.23, 1.0); }
RED :: proc() -> v4 { return V4(1.0, 0.0, 0.0, 1.0); }
TOMATO :: proc() -> v4 { return V4(1.0, 0.38, 0.27, 1.0); }
CORAL :: proc() -> v4 { return V4(1.0, 0.49, 0.31, 1.0); }
INDIAN_RED :: proc() -> v4 { return V4(0.8, 0.36, 0.36, 1.0); }
LIGHT_CORAL :: proc() -> v4 { return V4(0.94, 0.5, 0.5, 1.0); }
DARK_SALMON :: proc() -> v4 { return V4(0.91, 0.58, 0.47, 1.0); }
SALMON :: proc() -> v4 { return V4(0.98, 0.5, 0.44, 1.0); }
LIGHT_SALMON :: proc() -> v4 { return V4(1.0, 0.62, 0.47, 1.0); }
ORANGE_RED :: proc() -> v4 { return V4(1.0, 0.27, 0.0, 1.0); }
DARK_ORANGE :: proc() -> v4 { return V4(1.0, 0.54, 0.0, 1.0); }
ORANGE :: proc() -> v4 { return V4(1.0, 0.64, 0.0, 1.0); }
GOLD :: proc() -> v4 { return V4(1.0, 0.84, 0.0, 1.0); }
DARK_GOLDEN_ROD :: proc() -> v4 { return V4(0.72, 0.52, 0.04, 1.0); }
GOLDEN_ROD :: proc() -> v4 { return V4(0.85, 0.64, 0.12, 1.0); }
PALE_GOLDEN_ROD :: proc() -> v4 { return V4(0.93, 0.9, 0.66, 1.0); }
DARK_KHAKI :: proc() -> v4 { return V4(0.74, 0.71, 0.41, 1.0); }
KHAKI :: proc() -> v4 { return V4(0.94, 0.9, 0.54, 1.0); }
YELLOW :: proc() -> v4 { return V4(1.0, 1.0, 0.0, 1.0); }
YELLOW_GREEN :: proc() -> v4 { return V4(0.6, 0.8, 0.19, 1.0); }
DARK_OLIVE_GREEN :: proc() -> v4 { return V4(0.33, 0.41, 0.18, 1.0); }
OLIVE_DRAB :: proc() -> v4 { return V4(0.41, 0.55, 0.13, 1.0); }
LAWN_GREEN :: proc() -> v4 { return V4(0.48, 0.98, 0.0, 1.0); }
CHARTREUSE :: proc() -> v4 { return V4(0.49, 1.0, 0.0, 1.0); }
GREEN_YELLOW :: proc() -> v4 { return V4(0.67, 1.0, 0.18, 1.0); }
DARK_GREEN :: proc() -> v4 { return V4(0.0, 0.39, 0.0, 1.0); }
GREEN :: proc() -> v4 { return V4(0.0, 0.5, 0.0, 1.0); }
FOREST_GREEN :: proc() -> v4 { return V4(0.13, 0.54, 0.13, 1.0); }
LIME :: proc() -> v4 { return V4(0.0, 1.0, 0.0, 1.0); }
LIME_GREEN :: proc() -> v4 { return V4(0.19, 0.8, 0.19, 1.0); }
LIGHT_GREEN :: proc() -> v4 { return V4(0.56, 0.93, 0.56, 1.0); }
PALE_GREEN :: proc() -> v4 { return V4(0.59, 0.98, 0.59, 1.0); }
DARK_SEA_GREEN :: proc() -> v4 { return V4(0.56, 0.73, 0.56, 1.0); }
MEDIUM_SPRING_GREEN :: proc() -> v4 { return V4(0.0, 0.98, 0.6, 1.0); }
SPRING_GREEN :: proc() -> v4 { return V4(0.0, 1.0, 0.49, 1.0); }
SEA_GREEN :: proc() -> v4 { return V4(0.18, 0.54, 0.34, 1.0); }
MEDIUM_AQUA_MARINE :: proc() -> v4 { return V4(0.4, 0.8, 0.66, 1.0); }
MEDIUM_SEA_GREEN :: proc() -> v4 { return V4(0.23, 0.7, 0.44, 1.0); }
LIGHT_SEA_GREEN :: proc() -> v4 { return V4(0.12, 0.69, 0.66, 1.0); }
DARK_SLATE_GRAY :: proc() -> v4 { return V4(0.18, 0.3, 0.3, 1.0); }
TEAL :: proc() -> v4 { return V4(0.0, 0.5, 0.5, 1.0); }
DARK_CYAN :: proc() -> v4 { return V4(0.0, 0.54, 0.54, 1.0); }
AQUA :: proc() -> v4 { return V4(0.0, 1.0, 1.0, 1.0); }
CYAN :: proc() -> v4 { return V4(0.0, 1.0, 1.0, 1.0); }
LIGHT_CYAN :: proc() -> v4 { return V4(0.87, 1.0, 1.0, 1.0); }
DARK_TURQUOISE :: proc() -> v4 { return V4(0.0, 0.8, 0.81, 1.0); }
TURQUOISE :: proc() -> v4 { return V4(0.25, 0.87, 0.81, 1.0); }
MEDIUM_TURQUOISE :: proc() -> v4 { return V4(0.28, 0.81, 0.8, 1.0); }
PALE_TURQUOISE :: proc() -> v4 { return V4(0.68, 0.93, 0.93, 1.0); }
AQUA_MARINE :: proc() -> v4 { return V4(0.49, 1.0, 0.83, 1.0); }
POWDER_BLUE :: proc() -> v4 { return V4(0.69, 0.87, 0.9, 1.0); }
CADET_BLUE :: proc() -> v4 { return V4(0.37, 0.61, 0.62, 1.0); }
STEEL_BLUE :: proc() -> v4 { return V4(0.27, 0.5, 0.7, 1.0); }
CORN_FLOWER_BLUE :: proc() -> v4 { return V4(0.39, 0.58, 0.92, 1.0); }
DEEP_SKY_BLUE :: proc() -> v4 { return V4(0.0, 0.74, 1.0, 1.0); }
DODGER_BLUE :: proc() -> v4 { return V4(0.11, 0.56, 1.0, 1.0); }
LIGHT_BLUE :: proc() -> v4 { return V4(0.67, 0.84, 0.9, 1.0); }
SKY_BLUE :: proc() -> v4 { return V4(0.52, 0.8, 0.92, 1.0); }
LIGHT_SKY_BLUE :: proc() -> v4 { return V4(0.52, 0.8, 0.98, 1.0); }
MIDNIGHT_BLUE :: proc() -> v4 { return V4(0.09, 0.09, 0.43, 1.0); }
NAVY :: proc() -> v4 { return V4(0.0, 0.0, 0.5, 1.0); }
DARK_BLUE :: proc() -> v4 { return V4(0.0, 0.0, 0.54, 1.0); }
MEDIUM_BLUE :: proc() -> v4 { return V4(0.0, 0.0, 0.8, 1.0); }
BLUE :: proc() -> v4 { return V4(0.0, 0.0, 1.0, 1.0); }
ROYAL_BLUE :: proc() -> v4 { return V4(0.25, 0.41, 0.88, 1.0); }
BLUE_VIOLET :: proc() -> v4 { return V4(0.54, 0.16, 0.88, 1.0); }
INDIGO :: proc() -> v4 { return V4(0.29, 0.0, 0.5, 1.0); }
DARK_SLATE_BLUE :: proc() -> v4 { return V4(0.28, 0.23, 0.54, 1.0); }
SLATE_BLUE :: proc() -> v4 { return V4(0.41, 0.35, 0.8, 1.0); }
MEDIUM_SLATE_BLUE :: proc() -> v4 { return V4(0.48, 0.4, 0.93, 1.0); }
MEDIUM_PURPLE :: proc() -> v4 { return V4(0.57, 0.43, 0.85, 1.0); }
DARK_MAGENTA :: proc() -> v4 { return V4(0.54, 0.0, 0.54, 1.0); }
DARK_VIOLET :: proc() -> v4 { return V4(0.58, 0.0, 0.82, 1.0); }
DARK_ORCHID :: proc() -> v4 { return V4(0.6, 0.19, 0.8, 1.0); }
MEDIUM_ORCHID :: proc() -> v4 { return V4(0.72, 0.33, 0.82, 1.0); }
PURPLE :: proc() -> v4 { return V4(0.5, 0.0, 0.5, 1.0); }
THISTLE :: proc() -> v4 { return V4(0.84, 0.74, 0.84, 1.0); }
PLUM :: proc() -> v4 { return V4(0.86, 0.62, 0.86, 1.0); }
VIOLET :: proc() -> v4 { return V4(0.93, 0.5, 0.93, 1.0); }
MAGENTA_FUCHSIA :: proc() -> v4 { return V4(1.0, 0.0, 1.0, 1.0); }
ORCHID :: proc() -> v4 { return V4(0.85, 0.43, 0.83, 1.0); }
MEDIUM_VIOLET_RED :: proc() -> v4 { return V4(0.78, 0.08, 0.52, 1.0); }
PALE_VIOLET_RED :: proc() -> v4 { return V4(0.85, 0.43, 0.57, 1.0); }
DEEP_PINK :: proc() -> v4 { return V4(1.0, 0.07, 0.57, 1.0); }
HOT_PINK :: proc() -> v4 { return V4(1.0, 0.41, 0.7, 1.0); }
LIGHT_PINK :: proc() -> v4 { return V4(1.0, 0.71, 0.75, 1.0); }
PINK :: proc() -> v4 { return V4(1.0, 0.75, 0.79, 1.0); }
ANTIQUE_WHITE :: proc() -> v4 { return V4(0.98, 0.92, 0.84, 1.0); }
BEIGE :: proc() -> v4 { return V4(0.96, 0.96, 0.86, 1.0); }
BISQUE :: proc() -> v4 { return V4(1.0, 0.89, 0.76, 1.0); }
BLANCHED_ALMOND :: proc() -> v4 { return V4(1.0, 0.92, 0.8, 1.0); }
WHEAT :: proc() -> v4 { return V4(0.96, 0.87, 0.7, 1.0); }
CORN_SILK :: proc() -> v4 { return V4(1.0, 0.97, 0.86, 1.0); }
LEMON_CHIFFON :: proc() -> v4 { return V4(1.0, 0.98, 0.8, 1.0); }
LIGHT_GOLDEN_ROD_YELLOW :: proc() -> v4 { return V4(0.98, 0.98, 0.82, 1.0); }
LIGHT_YELLOW :: proc() -> v4 { return V4(1.0, 1.0, 0.87, 1.0); }
SADDLE_BROWN :: proc() -> v4 { return V4(0.54, 0.27, 0.07, 1.0); }
SIENNA :: proc() -> v4 { return V4(0.62, 0.32, 0.17, 1.0); }
CHOCOLATE :: proc() -> v4 { return V4(0.82, 0.41, 0.11, 1.0); }
PERU :: proc() -> v4 { return V4(0.8, 0.52, 0.24, 1.0); }
SANDY_BROWN :: proc() -> v4 { return V4(0.95, 0.64, 0.37, 1.0); }
BURLY_WOOD :: proc() -> v4 { return V4(0.87, 0.72, 0.52, 1.0); }
TAN :: proc() -> v4 { return V4(0.82, 0.7, 0.54, 1.0); }
ROSY_BROWN :: proc() -> v4 { return V4(0.73, 0.56, 0.56, 1.0); }
MOCCASIN :: proc() -> v4 { return V4(1.0, 0.89, 0.7, 1.0); }
NAVAJO_WHITE :: proc() -> v4 { return V4(1.0, 0.87, 0.67, 1.0); }
PEACH_PUFF :: proc() -> v4 { return V4(1.0, 0.85, 0.72, 1.0); }
MISTY_ROSE :: proc() -> v4 { return V4(1.0, 0.89, 0.88, 1.0); }
LAVENDER_BLUSH :: proc() -> v4 { return V4(1.0, 0.94, 0.96, 1.0); }
LINEN :: proc() -> v4 { return V4(0.98, 0.94, 0.9, 1.0); }
OLD_LACE :: proc() -> v4 { return V4(0.99, 0.96, 0.9, 1.0); }
PAPAYA_WHIP :: proc() -> v4 { return V4(1.0, 0.93, 0.83, 1.0); }
SEA_SHELL :: proc() -> v4 { return V4(1.0, 0.96, 0.93, 1.0); }
MINT_CREAM :: proc() -> v4 { return V4(0.96, 1.0, 0.98, 1.0); }
SLATE_GRAY :: proc() -> v4 { return V4(0.43, 0.5, 0.56, 1.0); }
LIGHT_SLATE_GRAY :: proc() -> v4 { return V4(0.46, 0.53, 0.6, 1.0); }
LIGHT_STEEL_BLUE :: proc() -> v4 { return V4(0.69, 0.76, 0.87, 1.0); }
LAVENDER :: proc() -> v4 { return V4(0.9, 0.9, 0.98, 1.0); }
FLORAL_WHITE :: proc() -> v4 { return V4(1.0, 0.98, 0.94, 1.0); }
ALICE_BLUE :: proc() -> v4 { return V4(0.94, 0.97, 1.0, 1.0); }
GHOST_WHITE :: proc() -> v4 { return V4(0.97, 0.97, 1.0, 1.0); }
HONEYDEW :: proc() -> v4 { return V4(0.94, 1.0, 0.94, 1.0); }
IVORY :: proc() -> v4 { return V4(1.0, 1.0, 0.94, 1.0); }
AZURE :: proc() -> v4 { return V4(0.94, 1.0, 1.0, 1.0); }
SNOW :: proc() -> v4 { return V4(1.0, 0.98, 0.98, 1.0); }
DIM_GRAY_DIM_GREY :: proc() -> v4 { return V4(0.41, 0.41, 0.41, 1.0); }
GRAY_GREY :: proc() -> v4 { return V4(0.5, 0.5, 0.5, 1.0); }
DARK_GRAY :: proc() -> v4 { return V4(0.66, 0.66, 0.66, 1.0); }
SILVER :: proc() -> v4 { return V4(0.75, 0.75, 0.75, 1.0); }
LIGHT_GRAY_LIGHT_GREY :: proc() -> v4 { return V4(0.82, 0.82, 0.82, 1.0); }
GAINSBORO :: proc() -> v4 { return V4(0.86, 0.86, 0.86, 1.0); }
WHITE_SMOKE :: proc() -> v4 { return V4(0.96, 0.96, 0.96, 1.0); }


