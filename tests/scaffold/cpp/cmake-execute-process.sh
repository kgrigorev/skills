# expect: red Dependencies pinned by URL and SHA-256
# execute_process runs a program when CMake runs, after the source searches.
. "$(dirname "$0")/lib/attack"
cmake_append 'execute_process(COMMAND true)'
