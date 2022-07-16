/* vg_fbx_base_types.h : date = July 16th 2022 6:27 am */

#if !defined(VG_FBX_BASE_TYPES_H)

#include <stdint.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef int8_t s8;
typedef int16_t s16;
typedef int32_t s32;
typedef int64_t s64;

typedef float r32;
typedef double r64;

typedef enum {
	vg_false = 0,
	vg_true = 1,
} vg_bool;

#define PI_32                3.14159265359f
#define PI_64                3.14159265358979323846f
#define SMALL_NUMBER         1.e-8f
#define KINDA_SMALL_NUMBER   1.e-4f
#define THOUSANDTH           1.e-2f
#define BIG_NUMBER           3.4e+38f

#define kilo(v) v * 1024L
#define mega(v) kilo(v) * 1024L
#define giga(v) mega(v) * 1024L

#define VG_FBX_BASE_TYPES_H
#endif //VG_FBX_BASE_TYPES_H
