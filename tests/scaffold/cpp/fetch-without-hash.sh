# expect: red Dependencies pinned by URL and SHA-256
# A dependency fetched by URL without URL_HASH.
. "$(dirname "$0")/lib/attack"
printf 'FetchContent_Declare(fmt\n  URL https://github.com/fmtlib/fmt/archive/refs/tags/11.0.0.tar.gz)\n' >>cmake/dependencies.cmake
