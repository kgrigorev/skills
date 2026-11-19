# expect: red Dependencies pinned by URL and SHA-256
# CMake splits an unquoted ; into more arguments, so this includes cmake/hidden.txt, a file no gate reads, which runs a program.
. "$(dirname "$0")/lib/attack"
printf 'execute_process(COMMAND true)\n' >cmake/hidden.txt
cmake_append 'include(cmake/hidden.txt;OPTIONAL;RESULT_VARIABLE;unused.cmake)'
