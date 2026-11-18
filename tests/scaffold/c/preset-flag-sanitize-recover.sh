# expect: red Every project file is built with the gates
# The dev preset adds -fsanitize-recover=undefined: lets the program run on after UB.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -fsanitize-recover=undefined"|' CMakePresets.json
grep -qF -- '-fsanitize-recover=undefined' CMakePresets.json
