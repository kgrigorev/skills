# expect: red No switched-off checks
# A call into the LeakSanitizer interface that stops leak tracking.
perl -0pi -e 's/    UNITY_BEGIN\(\);\n/    void __lsan_disable(void);\n    __lsan_disable();\n    UNITY_BEGIN();\n/' test/sample_tool_test.c
