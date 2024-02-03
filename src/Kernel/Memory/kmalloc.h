#pragma once

#include "../preload.h"

#define HEAP_START 1000000
#define HEAP_END 4000000

struct Chunk {
    unsigned int size;
    bool freed;
} __attribute__((packed));

bool first_time_kmalloc = true;

void setup_heap() {
    for(u64 i = HEAP_START; i < HEAP_END; i++) {
        *((char*)i) = 0;
    }
}

PADDR* __create_chunk_and_return(u64, Chunk*) {}

PADDR* kmalloc(u64 size) {

    if(first_time_kmalloc)
        setup_heap();

    for(u64 i = HEAP_START;;) {
        Chunk* current_chunk = (Chunk*)i;
        if(current_chunk->size == 0) { // We reached the end
            // Check if we have enough space:
            if( (HEAP_END - i) >= size) {
                return __create_chunk_and_return(size, current_chunk);
            } else {
                // TODO out of memory
            }
        } else if (current_chunk->freed) {
            if(current_chunk->size >= size)
                return __create_chunk_and_return(size, current_chunk);
            else
                goto __continue_iteration;
        }

        __continue_iteration:
            i += current_chunk->size + sizeof(Chunk);
            if(i >= HEAP_END) {
                // TODO out of memory
            }

    }
}