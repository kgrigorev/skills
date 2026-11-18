# expect: red Lint
# A format verb that does not match its argument.
cat >>sampletool.go <<'GO'

// Count returns a count.
func Count() string {
	return fmt.Sprintf("%d", "x")
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"fmt\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
