# expect: red Every project file is built with the gates
# A header that only the pinned compiler's own folder provides. It builds here and nowhere else.
printf '#include <iconv.h>\n' >>src/sample_tool.c
