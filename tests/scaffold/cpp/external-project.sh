# expect: red Dependencies pinned by URL and SHA-256
# ExternalProject_Add, which fetches whatever the server has.
. "$(dirname "$0")/lib/attack"
printf 'include(ExternalProject)\nExternalProject_Add(fmt GIT_REPOSITORY https://github.com/fmtlib/fmt)\n' >>cmake/dependencies.cmake
