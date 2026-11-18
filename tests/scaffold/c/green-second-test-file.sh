# expect: green
# A second Unity test file with a fixture that setUp and tearDown manage.
cat >test/banner_buffer_test.c <<'X'
/// Tests the banner against buffers that setUp allocates.
#include "sample_tool.h"

#include <stdlib.h>
#include <string.h>
#include <unity.h>

static char *buffer;
static const size_t buffer_size = 8;

void setUp(void) {
    buffer = malloc(buffer_size);
    TEST_ASSERT_NOT_NULL(buffer);
}

void tearDown(void) {
    free(buffer);
    buffer = nullptr;
}

static void small_buffer_holds_a_prefix(void) {
    const size_t length = sample_tool_banner(buffer, buffer_size);
    TEST_ASSERT_GREATER_THAN_size_t(buffer_size, length);
    TEST_ASSERT_EQUAL_size_t(buffer_size - 1, strlen(buffer));
}

static void zero_capacity_writes_nothing(void) {
    buffer[0] = 'x';
    (void)sample_tool_banner(buffer, 0);
    TEST_ASSERT_EQUAL_CHAR('x', buffer[0]);
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(small_buffer_holds_a_prefix);
    RUN_TEST(zero_capacity_writes_nothing);
    return UNITY_END();
}
X
perl -0pi -e 's/(  add_property_test)/  add_unity_test(banner_buffer_test test\/banner_buffer_test.c sample_tool)\n$1/' CMakeLists.txt
