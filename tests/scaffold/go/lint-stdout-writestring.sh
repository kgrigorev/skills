# expect: red Lint
# The library writes to the terminal through os.Stdout directly.
cat >>sampletool.go <<'GO'

// Say writes to the terminal.
func Say() { _, _ = os.Stdout.WriteString("hi\n") }
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"os\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
