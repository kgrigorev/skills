# expect: red Dependencies pinned by URL and SHA-256
# A dependency fetched from a git branch.
. "$(dirname "$0")/lib/attack"
printf 'FetchContent_Declare(fmt GIT_REPOSITORY https://github.com/fmtlib/fmt GIT_TAG main)\n' >>cmake/dependencies.cmake
