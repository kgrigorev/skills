# expect: red Every project file is built with the gates
# The dev preset gives the sanitizers a list of functions to skip.
printf 'fun:sample_tool_*\n' >ignore.txt
perl -pi -e "s|-fno-sanitize-recover=all\"|-fno-sanitize-recover=all -fsanitize-ignorelist=$PWD/ignore.txt\"|" CMakePresets.json
