# expect: red Lint
# unsafe reads memory past the type system.
cat >>sampletool.go <<'GO'

// Peek reads the first byte of s.
func Peek(s string) byte { return *unsafe.StringData(s) }
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"unsafe\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
