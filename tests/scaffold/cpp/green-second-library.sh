# expect: green
# A second library target that the first one links.
. "$(dirname "$0")/lib/attack"
mkdir -p src/report
cat >src/report/report.hpp <<'C'
// Formats lines of the program's report.
#pragma once

#include <string>
#include <string_view>

namespace sample_tool::report {

// One report line: the label, a colon and the value.
[[nodiscard]] std::string line(std::string_view label, int value);

} // namespace sample_tool::report
C
cat >src/report/report.cpp <<'C'
#include "report/report.hpp"

#include <format>
#include <string>
#include <string_view>

namespace sample_tool::report {

std::string line(std::string_view label, int value) { return std::format("{}: {}", label, value); }

} // namespace sample_tool::report
C
perl -pi -e 's|^target_include_directories\(sample_tool_lib PUBLIC src\)$|add_library(sample_tool_report src/report/report.cpp)\ntarget_include_directories(sample_tool_report PUBLIC src)\n$&\ntarget_link_libraries(sample_tool_lib PUBLIC sample_tool_report)|' CMakeLists.txt
grep -q sample_tool_report CMakeLists.txt
perl -pi -e 's|^#include "sample_tool.hpp"$|#include "report/report.hpp"\n$&|' tests/sample_tool_test.cpp
add_tests <<'C'
TEST(ReportLine, JoinsLabelAndValue) { EXPECT_EQ(sample_tool::report::line("files", 3), "files: 3"); }
C
fmt
