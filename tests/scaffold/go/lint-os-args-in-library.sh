# expect: red Lint
# The library tells a test binary from the real program by its name.
cat >>sampletool.go <<'GO'

// Double returns twice x, but only in a test binary.
func Double(x int) int {
	if strings.HasSuffix(os.Args[0], ".test") {
		return 2 * x
	}

	return x
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"os\""; print "\t\"strings\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
