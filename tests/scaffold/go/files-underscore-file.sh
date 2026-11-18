# expect: red Every file is checked
# Go ignores files whose names start with "_".
printf 'package sampletool\n\nfunc Bad() { panic(1) }\n' >_bad.go
