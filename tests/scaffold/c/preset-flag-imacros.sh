# expect: red Every project file is built with the gates
# The dev preset adds -imacros <file>: reads macros from a file before every source.
printf '#define SAMPLE_TOOL_HIDDEN 1\n' >build-macros.h
perl -pi -e "s|-fno-sanitize-recover=all\"|-fno-sanitize-recover=all -imacros $PWD/build-macros.h\"|" CMakePresets.json
grep -qF -- '-imacros ' CMakePresets.json
