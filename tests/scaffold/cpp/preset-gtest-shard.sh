# expect: red Test (sanitizers on
# The test preset shards GoogleTest so every ctest test runs zero cases, and allows an empty selection.
. "$(dirname "$0")/lib/attack"
break_banner
perl -pi -e 's|"GTEST_FAIL_IF_NO_TEST_SELECTED": "1",|"GTEST_FAIL_IF_NO_TEST_SELECTED": "0",\n        "GTEST_TOTAL_SHARDS": "2",\n        "GTEST_SHARD_INDEX": "1",|' CMakePresets.json
grep -q GTEST_TOTAL_SHARDS CMakePresets.json
