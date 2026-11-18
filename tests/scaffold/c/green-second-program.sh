# expect: green
# A second program, linked with the C math library, and an assert() in the library. Unity is
# built without double support, so the test compares doubles with fabs.
cat >app/stats.c <<'X'
/// Prints the root mean square of the numbers given as arguments.
#include "sample_tool.h"

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    double sum = 0.0;
    for (int i = 1; i < argc; i++) {
        char *end = nullptr;
        const double value = strtod(argv[i], &end);
        if (end == argv[i]) {
            (void)fprintf(stderr, "not a number: %s\n", argv[i]);
            return EXIT_FAILURE;
        }
        sum += value * value;
    }
    const double rms = sample_tool_rms(sum, (size_t)(argc - 1));
    return printf("%f\n", rms) < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
}
X
perl -0pi -e 's/(\n#endif)/\n\/\/\/ The root mean square of `count` numbers whose squares add up to `sum_of_squares`.\n[[nodiscard]] double sample_tool_rms(double sum_of_squares, size_t count);\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <assert.h>\n#include <math.h>\n#include <string.h>/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

double sample_tool_rms(double sum_of_squares, size_t count) {
    assert(sum_of_squares >= 0.0);
    return count == 0 ? 0.0 : sqrt(sum_of_squares / (double)count);
}
X
cat >>CMakeLists.txt <<'X'

find_library(MATH_LIBRARY m)
if(MATH_LIBRARY)
  target_link_libraries(sample_tool PUBLIC ${MATH_LIBRARY})
endif()
add_executable(sample_tool_stats app/stats.c)
target_link_libraries(sample_tool_stats PRIVATE sample_tool)
X
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void rms_of_three_and_four(void) {\n    TEST_ASSERT_TRUE(fabs(sample_tool_rms(25.0, 2) - (5.0 \/ sqrt(2.0))) < 1e-12);\n}\n\n$1    RUN_TEST(rms_of_three_and_four);\n/' test/sample_tool_test.c
perl -0pi -e 's/#include <string.h>/#include <math.h>\n#include <string.h>/' test/sample_tool_test.c
