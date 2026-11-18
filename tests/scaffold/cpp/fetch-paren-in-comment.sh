# expect: red Dependencies pinned by URL and SHA-256
# A trailing comment with a URL, a hash and a ")", so a line-based scan ends the call on its first line; the real URL has no hash.
. "$(dirname "$0")/lib/attack"
printf 'FetchContent_Declare(fmt # was: URL https://x URL_HASH SHA256=00 (old mirror)\n  URL https://github.com/fmtlib/fmt/archive/refs/tags/11.0.0.tar.gz)\n' >>cmake/dependencies.cmake
