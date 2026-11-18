# expect: red Every file is checked
# A /*line*/ directive (gocritic only checks // comments) moves a panicking library function
# to cmd/sample-tool/main.go, where panicking is allowed, so Lint passes and the search must find it.
cat >>sampletool.go <<'GO'

// MustGreet panics on an empty name.
/*line cmd/sample-tool/main.go:100*/
func MustGreet(name string) string {
	if name == "" {
		panic("empty name")
	}

	return Greet(name)
}
GO
