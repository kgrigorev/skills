# expect: green
# A dependency-free module (header, source, its own test file) with a callback that ignores its
# parameters with (void).
cat >include/sample_tool_ring.h <<'X'
/// A fixed-size queue of bytes.
#ifndef SAMPLE_TOOL_RING_H
#define SAMPLE_TOOL_RING_H

#include <stddef.h>

/// A queue of at most 16 bytes. The caller owns it; it holds no pointers.
typedef struct sample_tool_ring {
    unsigned char bytes[16];
    size_t head;
    size_t count;
} sample_tool_ring;

/// Empties `ring`.
void sample_tool_ring_init(sample_tool_ring *ring);

/// Adds `byte` at the back. Returns false, and changes nothing, when the ring is full.
[[nodiscard]] bool sample_tool_ring_push(sample_tool_ring *ring, unsigned char byte);

/// Removes the front byte into `out`. Returns false, and leaves `out` alone, when it is empty.
[[nodiscard]] bool sample_tool_ring_pop(sample_tool_ring *ring, unsigned char *out);

/// Calls `visit` with each byte from front to back, passing `context` along.
void sample_tool_ring_each(const sample_tool_ring *ring, void (*visit)(unsigned char, void *),
                           void *context);

#endif
X
cat >src/sample_tool_ring.c <<'X'
/// A fixed-size queue of bytes.
#include "sample_tool_ring.h"

static const size_t ring_capacity = sizeof(((sample_tool_ring *)nullptr)->bytes);

void sample_tool_ring_init(sample_tool_ring *ring) {
    ring->head = 0;
    ring->count = 0;
}

bool sample_tool_ring_push(sample_tool_ring *ring, unsigned char byte) {
    if (ring->count == ring_capacity) {
        return false;
    }
    ring->bytes[(ring->head + ring->count) % ring_capacity] = byte;
    ring->count++;
    return true;
}

bool sample_tool_ring_pop(sample_tool_ring *ring, unsigned char *out) {
    if (ring->count == 0) {
        return false;
    }
    *out = ring->bytes[ring->head];
    ring->head = (ring->head + 1) % ring_capacity;
    ring->count--;
    return true;
}

void sample_tool_ring_each(const sample_tool_ring *ring, void (*visit)(unsigned char, void *),
                           void *context) {
    for (size_t i = 0; i < ring->count; i++) {
        visit(ring->bytes[(ring->head + i) % ring_capacity], context);
    }
}
X
cat >test/sample_tool_ring_test.c <<'X'
/// Tests for the byte queue.
#include "sample_tool_ring.h"

#include <unity.h>

void setUp(void) {}
void tearDown(void) {}

static void full_ring_refuses_a_byte(void) {
    sample_tool_ring ring;
    sample_tool_ring_init(&ring);
    for (unsigned char i = 0; i < 16; i++) {
        TEST_ASSERT_TRUE(sample_tool_ring_push(&ring, i));
    }
    TEST_ASSERT_FALSE(sample_tool_ring_push(&ring, 99));
}

static void bytes_come_out_in_order_across_the_end(void) {
    sample_tool_ring ring;
    sample_tool_ring_init(&ring);
    unsigned char byte = 0;
    for (unsigned char i = 0; i < 40; i++) {
        TEST_ASSERT_TRUE(sample_tool_ring_push(&ring, i));
        TEST_ASSERT_TRUE(sample_tool_ring_pop(&ring, &byte));
        TEST_ASSERT_EQUAL_UINT8(i, byte);
    }
    TEST_ASSERT_FALSE(sample_tool_ring_pop(&ring, &byte));
    TEST_ASSERT_EQUAL_UINT8(39, byte);
}

static size_t visited;

static void count_byte(unsigned char byte, void *context) {
    (void)byte;
    (void)context;
    visited++;
}

static void each_visits_every_byte(void) {
    sample_tool_ring ring;
    sample_tool_ring_init(&ring);
    TEST_ASSERT_TRUE(sample_tool_ring_push(&ring, 1));
    TEST_ASSERT_TRUE(sample_tool_ring_push(&ring, 2));
    visited = 0;
    sample_tool_ring_each(&ring, count_byte, nullptr);
    TEST_ASSERT_EQUAL_size_t(2, visited);
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(full_ring_refuses_a_byte);
    RUN_TEST(bytes_come_out_in_order_across_the_end);
    RUN_TEST(each_visits_every_byte);
    return UNITY_END();
}
X
perl -pi -e 's|add_library\(sample_tool src/sample_tool.c\)|add_library(sample_tool src/sample_tool.c src/sample_tool_ring.c)|' CMakeLists.txt
perl -0pi -e 's/(  add_property_test)/  add_unity_test(sample_tool_ring_test test\/sample_tool_ring_test.c sample_tool)\n$1/' CMakeLists.txt
grep -q sample_tool_ring_test CMakeLists.txt
