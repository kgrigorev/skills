# expect: red Dependencies pinned by URL and SHA-256
# A module function (configure_package_config_file) that writes a script, which include then runs.
. "$(dirname "$0")/lib/attack"
printf 'execute_process(COMMAND true)\n' >cmake/late.in
cmake_append 'include(CMakePackageConfigHelpers)'
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'configure_package_config_file(cmake/late.in ${CMAKE_BINARY_DIR}/late-config.cmake INSTALL_DESTINATION lib)'
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'include(${CMAKE_BINARY_DIR}/late-config.cmake)'
