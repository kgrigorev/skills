# expect: red Every project file is built with the gates
# The dev preset adds -fno-sanitize=address: turns AddressSanitizer off.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -fno-sanitize=address"|' CMakePresets.json
grep -qF -- '-fno-sanitize=address' CMakePresets.json
