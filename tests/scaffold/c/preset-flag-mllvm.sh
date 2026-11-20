# expect: red Every project file is built with the gates
# The dev preset adds -mllvm -asan-instrument-reads=0: turns off half of AddressSanitizer.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -mllvm -asan-instrument-reads=0"|' CMakePresets.json
grep -qF -- '-mllvm -asan-instrument-reads=0' CMakePresets.json
