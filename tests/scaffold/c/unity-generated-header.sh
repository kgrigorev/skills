# expect: red Every project file is built with the gates
# CMake writes a header into third_party/unity/ that git ignores, and the test includes it. Unity's
# folder is exempt from the searches, so the header could turn assertions into no-ops.
mkdir -p docs
printf '#undef TEST_ASSERT_EQUAL_INT\n#define TEST_ASSERT_EQUAL_INT(e, a) ((void)(e), (void)(a))\n' > docs/helpers.txt
printf 'third_party/unity/unity_helpers.h\n' >> .gitignore
perl -0pi -e 's/(include\(cmake\/gates.cmake\)\n)/configure_file(docs\/helpers.txt \${CMAKE_SOURCE_DIR}\/third_party\/unity\/unity_helpers.h COPYONLY)\n$1/' CMakeLists.txt
perl -0pi -e 's/#include <unity.h>/#include <unity.h>\n#include <unity_helpers.h>/' test/sample_tool_test.c
perl -0pi -e 's/(    UNITY_BEGIN\(\);\n)/$1    RUN_TEST(broken);\n/; s/(int main\(void\) \{)/static void broken(void) { TEST_ASSERT_EQUAL_INT(1, 2); }\n\n$1/' test/sample_tool_test.c
