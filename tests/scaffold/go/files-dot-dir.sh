# expect: red Every file is checked
# ./... skips folders that start with ".".
mkdir -p .hidden
printf 'package hidden\n\nfunc Bad() { panic(1) }\n' >.hidden/bad.go
