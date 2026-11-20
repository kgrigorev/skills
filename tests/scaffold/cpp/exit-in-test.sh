# expect: red No switched-off checks
# A failing test ends the process with std::_Exit(EXIT_SUCCESS) before GoogleTest reports the failure.
. "$(dirname "$0")/lib/attack"
break_banner
perl -pi -e 's|starts_with\("nope"\)\); \}|starts_with("nope"));\n  std::_Exit(EXIT_SUCCESS);\n}|' tests/sample_tool_test.cpp
perl -pi -e 's|^#include <string>$|#include <cstdlib>\n$&|' tests/sample_tool_test.cpp
grep -q _Exit tests/sample_tool_test.cpp
fmt
