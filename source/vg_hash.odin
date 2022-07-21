package vg

import mem "core:mem"
import strings "core:strings"
import libc "core:c/libc"

hash_item :: struct($Key, $Value: typeid) {
    hash: u64,
    key: Key,
    value: Value,
};

hash_table :: struct($Key, $Value: typeid) {
    entries: [^]hash_item(Key, Value),
    capacity: u32,
    length: u32,
}

hash_table_itr :: struct($Key, $Value: typeid) {
    key: Key,
    value: Value,
    table: ^hash_table(Key, Value),
    idx: u32,
};

hash_table_hash :: proc(key: ^string) -> u64 {
    FNV_OFFSET: u64 = 14695981039346656037;
    FNV_PRIME: u64 = 1099511628211;
    
    h: u64 = FNV_OFFSET;
    for c in key {
        h = h ~ cast(u64)c;
        h = h * FNV_PRIME;
    }
    return h;
}

hash_table_create :: proc($Key, $Value: typeid) -> hash_table(Key, Value) {
    table: hash_table(Key, Value);
    table.length = 0;
    table.capacity = 16;
    
    table.entries = cast(^hash_item(Key, Value))mem.alloc(size_of(hash_item(Key, Value)) * cast(int)table.capacity);
    return table;
}

hash_table_destroy :: proc($Key, $Value: typeid, table: hash_table(Key, Value)) {
    free(table.entries);
}

hash_table_get :: proc($Key, $Value: typeid, table: ^hash_table(Key, Value), key: ^string) -> ^Value {
    hash: u64 = hash_table_hash(key);
    idx: u64 = hash & cast(u64)(table.capacity - 1);
    
    item: ^hash_item(Key, Value) = &table.entries[idx];
    if(strings.compare(item.key, key^) == 0) {
        return &item.value;
    }
    return nil;
}

hash_table_expand :: proc($Key, $Value: typeid, table: ^hash_table(Key, Value)) -> bool {
    new_cap: u32 = table.capacity * 2;
    if(new_cap < table.capacity) {
        return false;
    }
    
    tbl: hash_table(Key, Value);
    tbl.entries = cast(^hash_item(Key, Value))libc.calloc(cast(uint)table.capacity, size_of(hash_item(Key, Value)));
    tbl.capacity = new_cap;
    
    for i := 0; i < cast(int)table.capacity; i += 1 {
        entry: ^hash_item(Key, Value) = &table.entries[i];
        if entry.hash > 0 && len(entry.key) > 0 { 
            n: hash_item(Key, Value);
            n.key = entry.key;
            n.value = entry.value;
            hash_table_set_entry(Key, Value, &tbl, &n.key, &n.value);
        }
    }
    
    free(table.entries);
    table.entries = tbl.entries;
    table.capacity = new_cap;
    return true;
}

hash_table_set_entry :: proc($Key, $Value: typeid, table: ^hash_table(Key, Value), key: ^Key, value: ^Value) -> Key {
    hash: u64 = hash_table_hash(key);
    idx: u64 = hash & cast(u64)(table.capacity - 1);
    
    item: ^hash_item(Key, Value) = &table.entries[idx];
    if item.hash > 0 && len(item.key) > 0 {
        if(strings.compare(item.key, key^) == 0) {
            item.value = value^;
            item.hash = hash;
            return item.key;
        }
    }
    
    // didnt find anything, add it.
    table.entries[idx].value = value^;
    table.entries[idx].key = key^;
    table.entries[idx].hash = hash;
    return key^;
}

hash_table_set :: proc($Key, $Value: typeid, table: ^hash_table(Key, Value), key: Key, value: Value) -> ^Value {
    if(table.length >= table.capacity / 2) {
        if(hash_table_expand(Key, Value, table^)) {
            return nil;
        }
    }
    
    hash_table_set_entry(hash_table(Key, Value), key, value);
}

hash_table_len :: proc($Key, $Value: typeid, table: hash_table(Key, Value)) -> u32 {
    return table.length;
}

hash_table_iterator :: proc($Key, $Value: typeid, table: ^hash_table(Key, Value)) -> hash_table_itr(Key, Value) {
    itr: hash_table_itr(Key, Value);
    itr.table = table;
    itr.idx = 0;
    return itr;
}

hash_table_next :: proc($Key, $Value: typeid, itr: ^hash_table_itr(Key, Value)) -> bool {
    tbl: ^hash_table(Key, Value) = itr.table;
    for {
        if itr.idx < tbl.capacity {
            i: u32 = itr.idx;
            itr.idx += 1;
            
            if len(tbl.entries[i].key) > 0 {
                e: hash_item(Key, Value) = tbl.entries[i];
                itr.key = e.key;
                itr.value = e.value;
                return true;
            }
        } else {
            break;
        } 
    }
    return false;
}