# expect: red Dependencies pinned by URL and SHA-256
# fetchcontent_declare in lower case (CMake commands ignore case) from a git branch.
. "$(dirname "$0")/lib/attack"
printf 'fetchcontent_declare(fmt GIT_REPOSITORY https://github.com/fmtlib/fmt GIT_TAG main)\n' >>cmake/dependencies.cmake
