#include "vg_file.h"

vg_file load_file_from_disk(char* path) {
    vg_file r = {0};
    FILE* f = fopen(path, "r");
    if(f) {
        fseek(f, 0, SEEK_END);
        r.len = ftell(f);
        fseek(f, 0, SEEK_SET);
        
        r.ptr = (char*)malloc(r.len + 1);
        fread(r.ptr, r.len, 1, f);
        r.ptr[r.len] = 0;
        fclose(f);
    } else {
        printf("failed to open file from: %s\n", path);
    }
    return r;
}

void free_file(vg_file f) {
    if(f.ptr) {
        free(f.ptr);
        f.ptr = NULL;
    }
    f.len = 0;
}
