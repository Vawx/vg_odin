/* vg_file.h : date = July 16th 2022 11:33 pm */

#if !defined(VG_FILE_H)

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

typedef struct {
    char* ptr;
    u32 len;
} vg_file;

#define DLL_EXPORT extern __declspec(dllexport)

#include <stdlib.h>
#include <stdio.h>

DLL_EXPORT vg_file load_file_from_disk(char* path);
DLL_EXPORT void free_file(vg_file f);

#define VG_FILE_H
#endif //VG_FILE_H
