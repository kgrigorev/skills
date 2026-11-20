# expect: green
# A custom exception type derived from std::runtime_error, thrown by the library and tested with EXPECT_THROW.
. "$(dirname "$0")/lib/attack"
cat >src/config.hpp <<'C'
// Reads "key=value" settings.
#pragma once

#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>

namespace sample_tool {

// A setting line that could not be read. what() names the line.
class ConfigError : public std::runtime_error {
public:
  explicit ConfigError(const std::string &line)
      : std::runtime_error("not a key=value line: " + line) {}
};

// One setting.
struct Setting {
  std::string key;
  std::string value;
  // Two settings are equal when key and value are.
  friend bool operator==(const Setting &, const Setting &) = default;
};

// Splits "key=value" at the first '='. Throws ConfigError when there is no '=' or no key.
[[nodiscard]] Setting parse_setting(std::string_view line);

} // namespace sample_tool
C
cat >src/config.cpp <<'C'
#include "config.hpp"

#include <string>
#include <string_view>

namespace sample_tool {

Setting parse_setting(std::string_view line) {
  const auto equals = line.find('=');
  if (equals == std::string_view::npos || equals == 0) {
    throw ConfigError(std::string(line));
  }
  return {.key = std::string(line.substr(0, equals)), .value = std::string(line.substr(equals + 1)),};
}

} // namespace sample_tool
C
add_to_library src/config.cpp
cat >tests/config_test.cpp <<'C'
// Tests for reading settings.
#include "config.hpp"

#include <gtest/gtest.h>

namespace {

using sample_tool::ConfigError;
using sample_tool::Setting;

TEST(ParseSetting, SplitsAtTheFirstEquals) {
  EXPECT_EQ(sample_tool::parse_setting("name=a=b"), (Setting{.key = "name", .value = "a=b"}));
}

TEST(ParseSetting, RejectsALineWithoutEquals) {
  EXPECT_THROW(static_cast<void>(sample_tool::parse_setting("name")), ConfigError);
}

TEST(ParseSetting, RejectsAnEmptyKey) {
  EXPECT_THROW(static_cast<void>(sample_tool::parse_setting("=x")), ConfigError);
}

} // namespace
C
add_test_file tests/config_test.cpp
fmt
