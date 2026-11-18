# expect: red Lint
# An error check with an empty body.
cat >>sampletool.go <<'GO'

// Load reads p and ignores a failure.
func Load(p string) []byte {
	b, err := os.ReadFile(p)
	if err != nil {
		// TODO handle
	}

	return b
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"os\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
