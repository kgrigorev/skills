# expect: red No switched-off checks
# A plain add_test that always passes, outside add_unity_test.
printf 'add_test(NAME extra COMMAND true)\n' >>CMakeLists.txt
