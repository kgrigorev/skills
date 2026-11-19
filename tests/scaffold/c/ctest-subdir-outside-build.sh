# expect: red Test
# A subdirectory whose build folder is outside build/dev, where a custom target writes a
# CTestTestfile.cmake that marks the failing property test WILL_FAIL in the run with the test
# preset only. The CTestTestfile check reads build/dev only, so subdirs() must stay inside it.
mkdir -p docs/empty
: >docs/empty/CMakeLists.txt
cat >docs/hook.txt <<'Y'
if(DEFINED ENV{LSAN_OPTIONS})
  set_tests_properties(sample_tool_property PROPERTIES WILL_FAIL TRUE)
endif()
Y
cat >>CMakeLists.txt <<'Y'
add_subdirectory(docs/empty ${CMAKE_SOURCE_DIR}/../outside-build)
add_custom_target(hook ALL COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/docs/hook.txt ${CMAKE_SOURCE_DIR}/../outside-build/CTestTestfile.cmake)
Y
perl -0pi -e 's/(    if \(size == 0\) \{)/    abort();\n$1/' test/sample_tool_property.c
grep -q 'abort();' test/sample_tool_property.c
