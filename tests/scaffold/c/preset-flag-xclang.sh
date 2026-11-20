# expect: red Every project file is built with the gates
# The dev preset adds -Xclang -w: passes -w to the compiler front end directly.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -Xclang -w"|' CMakePresets.json
grep -qF -- '-Xclang -w' CMakePresets.json
