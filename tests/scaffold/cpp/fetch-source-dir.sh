# expect: red Dependencies pinned by URL and SHA-256
# A dependency taken from a local folder with SOURCE_DIR.
. "$(dirname "$0")/lib/attack"
printf 'FetchContent_Declare(fmt\n  URL https://example.invalid/fmt.tar.gz\n  URL_HASH SHA256=0000000000000000000000000000000000000000000000000000000000000000\n  SOURCE_DIR /var/empty)\n' >>cmake/dependencies.cmake
