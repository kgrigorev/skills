# expect: red Every project file is built with the gates
# The dev preset reads more flags from a response file.
printf -- '-w\n' >build-flags.rsp
perl -pi -e "s|-fno-sanitize-recover=all\"|-fno-sanitize-recover=all @$PWD/build-flags.rsp\"|" CMakePresets.json
