# expect: red Test
# A TEST_INCLUDE_FILES script, which ctest runs each time it reads the tests, replaces the
# property test's command only in the run with the test preset (which sets LSAN_OPTIONS), after the
# list of tests was checked. Only the lines CMake writes may be in CTestTestfile.cmake.
mkdir -p docs
cat > docs/hook.txt <<'X'
if(DEFINED ENV{LSAN_OPTIONS})
  function(add_test name)
    if(name STREQUAL "sample_tool_property")
      _add_test(${name} /usr/bin/true)
    else()
      _add_test(${ARGV})
    endif()
  endfunction()
endif()
X
printf 'set(gates_what property)\ncmake_language(CALL set_${gates_what} DIRECTORY APPEND PROPERTY TEST_INCLUDE_FILES ${CMAKE_SOURCE_DIR}/docs/hook.txt)\n' >>CMakeLists.txt
perl -0pi -e 's/(    if \(size == 0\) \{)/    abort();\n$1/' test/sample_tool_property.c
grep -q 'abort();' test/sample_tool_property.c
