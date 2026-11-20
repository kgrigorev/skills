# expect: green
# An I/O shell: main reads lines from stdin and prints them through a pure, tested core function.
. "$(dirname "$0")/lib/attack"
cat >src/lines.hpp <<'C'
// Turns input lines into output lines. No I/O here, so tests call it directly.
#pragma once

#include <string>
#include <string_view>
#include <vector>

namespace sample_tool {

// One greeting per non-blank line, with surrounding spaces trimmed from each name.
[[nodiscard]] std::vector<std::string> greet_lines(const std::vector<std::string> &lines);

// The text without leading and trailing spaces and tabs.
[[nodiscard]] std::string_view trim(std::string_view text);

} // namespace sample_tool
C
cat >src/lines.cpp <<'C'
#include "lines.hpp"

#include "sample_tool.hpp"

#include <string>
#include <string_view>
#include <vector>

namespace sample_tool {

std::string_view trim(std::string_view text) {
  const auto first = text.find_first_not_of(" \t");
  if (first == std::string_view::npos) {
    return {};
  }
  const auto last = text.find_last_not_of(" \t");
  return text.substr(first, last - first + 1);
}

std::vector<std::string> greet_lines(const std::vector<std::string> &lines) {
  std::vector<std::string> out;
  out.reserve(lines.size());
  for (const std::string &line : lines) {
    const std::string_view name = trim(line);
    if (!name.empty()) {
      out.push_back(greet(name));
    }
  }
  return out;
}

} // namespace sample_tool
C
add_to_library src/lines.cpp
cat >app/main.cpp <<'C'
// The sample-tool executable: reads names from stdin, one per line, and greets each.
#include "lines.hpp"

#include <cstdio>
#include <cstdlib>
#include <exception>
#include <iostream>
#include <print>
#include <string>
#include <vector>

int main() {
  try {
    std::vector<std::string> lines;
    for (std::string line; std::getline(std::cin, line);) {
      lines.push_back(line);
    }
    for (const std::string &greeting : sample_tool::greet_lines(lines)) {
      std::println("{}", greeting);
    }
    return EXIT_SUCCESS;
  } catch (const std::exception &error) {
    // An escaped exception would end the program without a message.
    static_cast<void>(std::fputs(error.what(), stderr));
    return EXIT_FAILURE;
  }
}
C
cat >tests/lines_test.cpp <<'C'
// Tests for the line-processing core.
#include "lines.hpp"

#include <gtest/gtest.h>

#include <string>
#include <vector>

namespace {

TEST(Trim, DropsSpacesAndTabsAtBothEnds) {
  EXPECT_EQ(sample_tool::trim("  Ada\t"), "Ada");
  EXPECT_EQ(sample_tool::trim(" \t "), "");
}

TEST(GreetLines, SkipsBlankLines) {
  const std::vector<std::string> lines{"Ada", "   ", " Grace "};
  const std::vector<std::string> want{"Hello, Ada!", "Hello, Grace!"};
  EXPECT_EQ(sample_tool::greet_lines(lines), want);
}

} // namespace
C
add_test_file tests/lines_test.cpp
fmt
