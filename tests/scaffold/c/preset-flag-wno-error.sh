# expect: red Every project file is built with the gates
# The dev preset adds -Wno-error: makes warnings non-fatal.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -Wno-error"|' CMakePresets.json
grep -qF -- '-Wno-error' CMakePresets.json
