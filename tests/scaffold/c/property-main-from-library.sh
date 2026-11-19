# expect: red syntax tree
# The property fails on every non-empty input. A second project library defines main, which calls
# the property 100000 times with no input, and the property test links it whole, so libFuzzer's
# main never runs. A library defines no main and no libFuzzer hook.
perl -0pi -e 's/(    if \(size == 0\) \{)/    if (size > 0) {\n        abort();\n    }\n$1/' test/sample_tool_property.c
grep -q 'size > 0' test/sample_tool_property.c
cat > src/fuzz_driver.c <<'X'
#include <stddef.h>
#include <stdint.h>

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size);

int main(void) {
    for (int i = 0; i < 100000; i++) {
        (void)LLVMFuzzerTestOneInput(nullptr, 0);
    }
    return 0;
}
X
perl -0pi -e 's/(if\(BUILD_TESTING\)\n  add_unity_test)/add_library(sample_tool_driver src\/fuzz_driver.c)\n\n$1/' CMakeLists.txt
perl -pi -e 's{add_property_test\(sample_tool_property test/sample_tool_property.c sample_tool\)}{add_property_test(sample_tool_property test/sample_tool_property.c sample_tool sample_tool_driver)}' CMakeLists.txt
grep -q sample_tool_driver\) CMakeLists.txt
scripts/format
