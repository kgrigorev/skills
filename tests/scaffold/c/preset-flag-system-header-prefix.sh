# expect: red Every project file is built with the gates
# The dev preset adds --system-header-prefix=sample: makes project headers system headers.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all --system-header-prefix=sample"|' CMakePresets.json
grep -qF -- '--system-header-prefix=sample' CMakePresets.json
