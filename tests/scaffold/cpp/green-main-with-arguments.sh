# expect: green
# main reads its arguments through std::span.
. "$(dirname "$0")/lib/attack"
cat >app/main.cpp <<'C'
// The sample-tool executable. Keep it thin: the work happens in the library.
#include "sample_tool.hpp"

#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <exception>
#include <print>
#include <span>
#include <string_view>

int main(int argc, char *argv[]) {
  try {
    // std::span views argv as a bounded list, so no pointer arithmetic is needed.
    const std::span arguments(argv, static_cast<std::size_t>(argc));
    std::println("{}", sample_tool::banner());
    for (const std::string_view argument : arguments.subspan(1)) {
      std::println("{}", sample_tool::greet(argument));
    }
    return EXIT_SUCCESS;
  } catch (const std::exception &error) {
    // An escaped exception would end the program without a message.
    static_cast<void>(std::fputs(error.what(), stderr));
    return EXIT_FAILURE;
  }
}
C
fmt
