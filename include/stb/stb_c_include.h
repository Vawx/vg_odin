/* stb_dv_include.h : July 28th 2021 9:20 pm */

#if !defined(STB_DV_INCLUDE_H)

// to fix all warnings as errors that stb trips
#pragma warning(disable: 4244)
#pragma warning(disable: 4456)
#pragma warning(disable: 4701)

#define STB_DEFINE
#include "stb.h"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#define STB_SPRINTF_IMPLEMENTATION
#include "stb_sprintf.h"

#define STB_TRUETYPE_IMPLEMENTATION
#include "stb_truetype.h"

#define STB_DS_IMPLEMENTATION
#include "stb_ds.h"

// ds hash seed init
#define STB_DS_SEED stbds_hash_seed
static long long seed = 0;

static void init_stb_ds() {
#if defined(Windows)
	LARGE_INTEGER R;
	if(QueryPerformanceCounter(&R)) {
		seed = R.QuadPart;
	} else{
		time_t t = {0};
		time(&t);
		seed = (long long)t;
	}
#endif
	stbds_rand_seed(seed);
}

#pragma warning(default: 4244)
#pragma warning(default: 4456)
#pragma warning(default: 4701)

#define STB_DV_INCLUDE_H
#endif
