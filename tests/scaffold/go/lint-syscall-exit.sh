# expect: red Lint
# The library exits through syscall.Exit, past deferred calls.
cat >>sampletool.go <<'GO'

// Quit ends the program.
func Quit() { syscall.Exit(3) }
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"syscall\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
