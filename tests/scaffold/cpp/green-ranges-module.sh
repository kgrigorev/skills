# expect: green
# A dependency-free module with std::ranges and std::views: word counting.
. "$(dirname "$0")/lib/attack"
cat >src/words.hpp <<'C'
// Counts words in text.
#pragma once

#include <cstddef>
#include <map>
#include <string>
#include <string_view>

namespace sample_tool {

// How often each word occurs. Words are runs of letters, compared in lower case.
[[nodiscard]] std::map<std::string, std::size_t> word_counts(std::string_view text);

} // namespace sample_tool
C
cat >src/words.cpp <<'C'
#include "words.hpp"

#include <algorithm>
#include <cctype>
#include <cstddef>
#include <map>
#include <string>
#include <string_view>

namespace sample_tool {

namespace {

bool is_letter(char c) { return std::isalpha(static_cast<unsigned char>(c)) != 0; }

char lower(char c) { return static_cast<char>(std::tolower(static_cast<unsigned char>(c))); }

} // namespace

std::map<std::string, std::size_t> word_counts(std::string_view text) {
  std::map<std::string, std::size_t> counts;
  auto rest = text;
  while (!rest.empty()) {
    const auto *const start = std::ranges::find_if(rest, is_letter);
    const auto *const end = std::find_if_not(start, rest.end(), is_letter);
    if (start != end) {
      std::string word(start, end);
      std::ranges::transform(word, word.begin(), lower);
      ++counts[word];
    }
    rest = std::string_view(end, rest.end());
  }
  return counts;
}

} // namespace sample_tool
C
add_to_library src/words.cpp
cat >tests/words_test.cpp <<'C'
// Tests for word counting.
#include "words.hpp"

#include <gtest/gtest.h>

#include <cstddef>
#include <map>
#include <string>

namespace {

TEST(WordCounts, IgnoresCaseAndPunctuation) {
  const std::map<std::string, std::size_t> want{{"a", 2}, {"cat", 1}, {"dog", 1}};
  EXPECT_EQ(sample_tool::word_counts("A cat, a DOG."), want);
}

TEST(WordCounts, OfNoLettersIsEmpty) { EXPECT_TRUE(sample_tool::word_counts(" 1, 2! ").empty()); }

} // namespace
C
add_test_file tests/words_test.cpp
fmt
