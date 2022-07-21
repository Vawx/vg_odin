package vg_fetch

when ODIN_OS == .Windows {
    foreign import vg_fetch "build/vg_fetch.lib";
    
    sfetch_error_t :: enum u8 {
        SFETCH_ERROR_NO_ERROR,
        SFETCH_ERROR_FILE_NOT_FOUND,
        SFETCH_ERROR_NO_BUFFER,
        SFETCH_ERROR_BUFFER_TOO_SMALL,
        SFETCH_ERROR_UNEXPECTED_EOF,
        SFETCH_ERROR_INVALID_HTTP_STATUS,
        SFETCH_ERROR_CANCELLED
    };
    
    sfetch_handle_t :: struct {
        id: u32, 
    };
    
    sfetch_callback_t::proc(response: ^sfetch_response_t);
    
    sfetch_response_t :: struct {
        handle: sfetch_handle_t,         /* request handle this response belongs to */
        dispatched: bool,                /* true when request is in DISPATCHED state (lane has been assigned) */
        fetched: bool,                   /* true when request is in FETCHED state (fetched data is available) */
        paused: bool,                    /* request is currently in paused state */
        finished: bool,                  /* this is the last response for this request */
        failed: bool,                    /* request has failed (always set together with 'finished') */
        cancelled: bool,                 /* request was cancelled (always set together with 'finished') */
        error_code: sfetch_error_t,      /* more detailed error code when failed is true */
        channel: u32,               /* the channel which processes this request */
        lane: u32,                  /* the lane this request occupies on its channel */
        path: cstring,               /* the original filesystem path of the request (FIXME: this is unsafe, wrap in API call?) */
        user_data: rawptr,                /* pointer to read/write user-data area (FIXME: this is unsafe, wrap in API call?) */
        fetched_offset: u32,        /* current offset of fetched data chunk in file data */
        fetched_size:u32,          /* size of fetched data chunk in number of bytes */
        buffer_ptr: rawptr,               /* pointer to buffer with fetched data */
        buffer_size: u32,           /* overall buffer size (may be >= than fetched_size!) */
    };
    
    sfetch_request_t :: struct  {
        _start_canary: u32, 
        channel: u32,               /* index of channel this request is assigned to (default: 0) */
        path: cstring,                 /* filesystem path or HTTP URL (required) */
        callback: sfetch_callback_t,     /* response callback function pointer (required) */
        buffer_ptr: rawptr,               /* buffer pointer where data will be loaded into (optional) */
        buffer_size: u32,            /* buffer size in number of bytes (optional) */
        chunk_size: u32,             /* number of bytes to load per stream-block (optional) */
        user_data_ptr: rawptr,       /* pointer to a POD user-data block which will be memcpy'd(!) (optional) */
        user_data_size: u32,        /* size of user-data block (optional) */
        _end_canary: u32
    };
    
    sfetch_desc_t :: struct {
        _start_canary: u32,
        max_requests: u32,           /* max number of active requests across all channels, default is 128 */
        num_channels: u32,          /* number of channels to fetch requests in parallel, default is 1 */
        num_lanes: u32,             /* max number of requests active on the same channel, default is 1 */
        _end_canary: u32
    };
    
    foreign vg_fetch {
        sfetch_setup :: proc( desc: ^sfetch_desc_t) ---;
        sfetch_shutdown :: proc() ---;
        sfetch_send :: proc(request: ^sfetch_request_t) -> sfetch_handle_t ---;
        sfetch_dowork :: proc() ---;
        sfetch_pause :: proc(h: sfetch_handle_t) ---;
        sfetch_continue :: proc(h: sfetch_handle_t) ---;
    }
}