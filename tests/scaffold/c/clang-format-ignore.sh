# expect: red No switched-off checks
# .clang-format-ignore makes clang-format skip the files it lists.
printf 'src/*\n' >.clang-format-ignore
printf '\nint    sample_tool_ugly( int x ) ;\nint sample_tool_ugly(int x){return x  +1;}\n' >>src/sample_tool.c
