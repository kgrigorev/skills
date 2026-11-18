# expect: green
# A command-line parser whose option strings look like compiler flags (-w, --no-warnings).
. "$(dirname "$0")/lib/attack"
cat >src/options.hpp <<'C'
// Command-line options of the program.
#pragma once

#include <optional>
#include <string_view>

namespace sample_tool {

// What one command-line argument asks for.
enum class Option : unsigned char { Wide, Quiet };

// Reads one argument: "-w" or "--wide" asks for wide output, "-q" or "--no-warnings" for quiet.
[[nodiscard]] std::optional<Option> parse_option(std::string_view argument);

} // namespace sample_tool
C
cat >src/options.cpp <<'C'
#include "options.hpp"

#include <optional>
#include <string_view>

namespace sample_tool {

std::optional<Option> parse_option(std::string_view argument) {
  if (argument == "-w" || argument == "--wide") {
    return Option::Wide;
  }
  if (argument == "-q" || argument == "--no-warnings") {
    return Option::Quiet;
  }
  return std::nullopt;
}

} // namespace sample_tool
C
add_to_library src/options.cpp
perl -pi -e 's|^#include "sample_tool.hpp"$|#include "options.hpp"\n$&|' tests/sample_tool_test.cpp
add_tests optional <<'C'
TEST(ParseOption, ReadsShortAndLongForms) {
  EXPECT_EQ(sample_tool::parse_option("-w"), sample_tool::Option::Wide);
  EXPECT_EQ(sample_tool::parse_option("--no-warnings"), sample_tool::Option::Quiet);
  EXPECT_EQ(sample_tool::parse_option("-x"), std::nullopt);
}
C
fmt
