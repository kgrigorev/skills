# expect: red No switched-off checks
# A clang-format off comment around misformatted code.
printf '\n// clang-format off\nint    sample_tool_ugly( int x ) ;\nint sample_tool_ugly(int x){return x  +1;}\n// clang-format on\n' >>src/sample_tool.c
