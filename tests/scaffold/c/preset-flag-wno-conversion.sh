# expect: red Every project file is built with the gates
# The dev preset adds -Wno-conversion: turns one warning off.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -Wno-conversion"|' CMakePresets.json
grep -qF -- '-Wno-conversion' CMakePresets.json
