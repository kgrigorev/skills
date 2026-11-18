# expect: red Every project file is built with the gates
# The dev preset adds -std=gnu17: another language standard, with extensions.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -std=gnu17"|' CMakePresets.json
grep -qF -- '-std=gnu17' CMakePresets.json
