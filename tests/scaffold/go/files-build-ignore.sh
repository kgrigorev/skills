# expect: red Every file is checked
# //go:build ignore keeps a file out of every check.
printf '//go:build ignore\n\npackage sampletool\n\nfunc x() { panic(1) }\n' >ign.go
