# expect: red Every project file is built with the gates
# The dev preset adds -idirafter /usr/include: adds a system include folder, where warnings are off.
perl -pi -e 's|-fno-sanitize-recover=all"|-fno-sanitize-recover=all -idirafter /usr/include"|' CMakePresets.json
grep -qF -- '-idirafter /usr/include' CMakePresets.json
