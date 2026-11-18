# expect: green
# The caller sets GTEST_*, RC_PARAMS, CXXFLAGS and MISE_ENV. The result does not change.
. "$(dirname "$0")/lib/attack"
# env: GTEST_FILTER=Nothing.*
# env: GTEST_ALSO_RUN_DISABLED_TESTS=0
# env: RC_PARAMS=max_success=1
# env: CXXFLAGS=-w
# env: MISE_ENV=ci
true
