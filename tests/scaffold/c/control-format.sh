# expect: red Format
# Control: misformatted code fails the format step.
printf '\nint    sample_tool_ugly( int x ) ;\nint sample_tool_ugly(int x){return x  +1;}\n' >>src/sample_tool.c
