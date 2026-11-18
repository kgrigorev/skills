# expect: red Only .cpp and .hpp files
# A source file named .C, which CMake compiles as C++ but a grep for *.cpp skips.
. "$(dirname "$0")/lib/attack"
cast_body | add_extra C
