# expect: red Dependencies pinned by URL and SHA-256
# A dependency fetched over plain http.
. "$(dirname "$0")/lib/attack"
printf 'FetchContent_Declare(fmt\n  URL http://example.invalid/fmt.tar.gz\n  URL_HASH SHA256=0000000000000000000000000000000000000000000000000000000000000000)\n' >>cmake/dependencies.cmake
