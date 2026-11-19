# expect: red Dependencies pinned by URL and SHA-256
# A post-build step, which could replace the test executable after the gates read the code.
. "$(dirname "$0")/lib/attack"
cmake_append 'add_custom_command(TARGET sample_tool_test POST_BUILD COMMAND true)'
