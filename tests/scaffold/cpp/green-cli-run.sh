# expect: green
# The CLI run pattern: run(arguments, out, err) returns the exit code; main only forwards argv and streams.
. "$(dirname "$0")/lib/attack"
cat >src/cli.hpp <<'C'
// The command-line interface, separate from main so tests can run it.
#pragma once

#include <ostream>
#include <span>
#include <string_view>

namespace sample_tool {

// Runs the program with the arguments after the program name. Returns the exit code.
// "--help" prints usage; each other argument is a name to greet; an unknown option fails.
[[nodiscard]] int run(std::span<const std::string_view> arguments, std::ostream &out, std::ostream &err);

} // namespace sample_tool
C
cat >src/cli.cpp <<'C'
#include "cli.hpp"

#include "sample_tool.hpp"

#include <cstdlib>
#include <ostream>
#include <span>
#include <string_view>

namespace sample_tool {

int run(std::span<const std::string_view> arguments, std::ostream &out, std::ostream &err) {
  for (const std::string_view argument : arguments) {
    if (argument == "--help") {
      out << "usage: sample-tool [--help] [name...]\n";
      return EXIT_SUCCESS;
    }
    if (argument.starts_with('-')) {
      err << "unknown option: " << argument << '\n';
      return 2;
    }
  }
  for (const std::string_view argument : arguments) {
    out << greet(argument) << '\n';
  }
  return EXIT_SUCCESS;
}

} // namespace sample_tool
C
add_to_library src/cli.cpp
cat >app/main.cpp <<'C'
// The sample-tool executable. It only hands argv and the standard streams to run().
#include "cli.hpp"

#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <exception>
#include <iostream>
#include <span>
#include <string_view>
#include <vector>

int main(int argc, char *argv[]) {
  try {
    const std::span raw(argv, static_cast<std::size_t>(argc));
    const std::vector<std::string_view> arguments(raw.begin() + 1, raw.end());
    return sample_tool::run(arguments, std::cout, std::cerr);
  } catch (const std::exception &error) {
    // An escaped exception would end the program without a message.
    static_cast<void>(std::fputs(error.what(), stderr));
    return EXIT_FAILURE;
  }
}
C
cat >tests/cli_test.cpp <<'C'
// Tests for the command-line interface.
#include "cli.hpp"

#include <gtest/gtest.h>

#include <array>
#include <cstdlib>
#include <sstream>
#include <string_view>

namespace {

TEST(Run, GreetsEachName) {
  std::ostringstream out;
  std::ostringstream err;
  const std::array<std::string_view, 2> arguments{"Ada", "Grace"};
  EXPECT_EQ(sample_tool::run(arguments, out, err), EXIT_SUCCESS);
  EXPECT_EQ(out.str(), "Hello, Ada!\nHello, Grace!\n");
  EXPECT_EQ(err.str(), "");
}

TEST(Run, RejectsAnUnknownOption) {
  std::ostringstream out;
  std::ostringstream err;
  const std::array<std::string_view, 1> arguments{"-x"};
  EXPECT_EQ(sample_tool::run(arguments, out, err), 2);
  EXPECT_EQ(err.str(), "unknown option: -x\n");
}

} // namespace
C
add_test_file tests/cli_test.cpp
fmt
