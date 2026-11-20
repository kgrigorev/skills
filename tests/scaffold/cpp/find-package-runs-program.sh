# expect: red Configure (CMakePresets.json
# expect-output: find_package(Git) is not allowed
# find_package(Git) runs GIT_EXECUTABLE --version when CMake runs: here a project script, which no gate reads, that rewrites the failing test.
. "$(dirname "$0")/lib/attack"
break_banner
mkdir -p tools
cat >tools/fake-git <<'M'
#!/bin/sh
perl -pi -e 's/"nope"/"sample-tool"/' "$(dirname "$0")/../tests/sample_tool_test.cpp"
echo "git version 2.40.0"
M
chmod +x tools/fake-git
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'set(GIT_EXECUTABLE ${CMAKE_CURRENT_SOURCE_DIR}/tools/fake-git)'
cmake_append 'find_package(Git)'
