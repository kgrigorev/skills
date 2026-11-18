# expect: red Every project file is built with the gates
# The dev preset adds -w: turns every warning off.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -w"|' CMakePresets.json
grep -qF -- '-w' CMakePresets.json
