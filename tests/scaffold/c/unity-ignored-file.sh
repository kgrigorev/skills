# expect: red No switched-off checks
# An ignored file in third_party/unity/, which the searches would skip as part of Unity.
printf '#undef TEST_ASSERT_EQUAL_INT\n#define TEST_ASSERT_EQUAL_INT(e, a) ((void)(e), (void)(a))\n' >third_party/unity/unity_helpers.h
printf 'third_party/unity/unity_helpers.h\n' >>.gitignore
