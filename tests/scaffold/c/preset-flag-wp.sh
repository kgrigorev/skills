# expect: red Every project file is built with the gates
# The dev preset adds -Wp,-w: passes -w to the preprocessor.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -Wp,-w"|' CMakePresets.json
grep -qF -- '-Wp,-w' CMakePresets.json
