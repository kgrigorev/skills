# expect: red Lint
# The library decides the exit code.
cat >>sampletool.go <<'GO'

// Quit ends the program.
func Quit() { os.Exit(3) }
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"os\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
