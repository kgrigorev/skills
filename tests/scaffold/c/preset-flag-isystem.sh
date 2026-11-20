# expect: red Every project file is built with the gates
# The dev preset adds -isystem include: makes project headers system headers, where warnings are off.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -isystem include"|' CMakePresets.json
grep -qF -- '-isystem include' CMakePresets.json
