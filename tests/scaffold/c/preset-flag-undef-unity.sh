# expect: red Every project file is built with the gates
# The dev preset adds -UUNITY_INCLUDE_DOUBLE: changes Unity macros.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -UUNITY_INCLUDE_DOUBLE"|' CMakePresets.json
grep -qF -- '-UUNITY_INCLUDE_DOUBLE' CMakePresets.json
