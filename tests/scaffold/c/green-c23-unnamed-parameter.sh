# expect: green
# A qsort comparator and a callback whose unused parameter has no name, which C23 allows in a
# definition. readability-named-parameter is off for this.
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Sorts the `count` sizes at `sizes` from small to large.\nvoid sample_tool_sort_sizes(size_t *sizes, size_t count);\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <stdlib.h>\n#include <string.h>/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

// qsort's comparator: negative, zero or positive as `a` sorts before, with or after `b`.
static int compare_sizes(const void *a, const void *b) {
    const size_t left = *(const size_t *)a;
    const size_t right = *(const size_t *)b;
    return (left > right) - (left < right);
}

void sample_tool_sort_sizes(size_t *sizes, size_t count) {
    qsort(sizes, count, sizeof sizes[0], compare_sizes);
}
X
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static size_t calls;\n\nstatic void count_call(void *) { calls++; }\n\nstatic void sort_orders_sizes(void) {\n    size_t sizes[] = {3, 1, 2};\n    sample_tool_sort_sizes(sizes, 3);\n    TEST_ASSERT_EQUAL_size_t(1, sizes[0]);\n    TEST_ASSERT_EQUAL_size_t(3, sizes[2]);\n    count_call(nullptr);\n    TEST_ASSERT_EQUAL_size_t(1, calls);\n}\n\n$1    RUN_TEST(sort_orders_sizes);\n/' test/sample_tool_test.c
