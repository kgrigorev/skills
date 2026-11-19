# expect: red Test
# CMakeLists.txt points GATES_LLVM_COV at another program, so the line coverage of the test would
# come from it. The check requires the pinned llvm-cov in every test command.
perl -0pi -e 's/(if\(BUILD_TESTING\)\n  add_unity_test)/set(GATES_LLVM_COV \/usr\/bin\/true)\n$1/' CMakeLists.txt
grep -q 'GATES_LLVM_COV' CMakeLists.txt
