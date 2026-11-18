# expect: red No switched-off checks
# _clang-format is another name clang-format reads. This one turns formatting off in src/.
printf 'DisableFormat: true\n' >src/_clang-format
printf '\nint    sample_tool_ugly( int x ) ;\nint sample_tool_ugly(int x){return x  +1;}\n' >>src/sample_tool.c
