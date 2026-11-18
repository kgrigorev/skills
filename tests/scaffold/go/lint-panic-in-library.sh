# expect: red Lint
# The library panics instead of returning an error.
cat >>sampletool.go <<'GO'

// MustGreet panics on an empty name.
func MustGreet(name string) string {
	if name == "" {
		panic("empty name")
	}

	return Greet(name)
}
GO
