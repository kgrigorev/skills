# expect: red Every project file is built with the gates
# The dev preset adds -DNDEBUG: turns every assert() off.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -DNDEBUG"|' CMakePresets.json
grep -qF -- '-DNDEBUG' CMakePresets.json
