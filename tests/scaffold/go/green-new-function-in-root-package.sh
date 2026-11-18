# expect: green
# A new dependency-free helper in the root package, with a test next to the existing ones.
cat >>sampletool.go <<'GO'

// Shout returns the greeting for name in upper case.
func Shout(name string) string {
	return strings.ToUpper(Greet(name))
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"strings\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
cat >>sampletool_test.go <<'GO'

// TestShout checks one known input.
func TestShout(t *testing.T) {
	t.Parallel()

	if got, want := sampletool.Shout("ada"), "HELLO, ADA!"; got != want {
		t.Errorf("Shout(%q) = %q, want %q", "ada", got, want)
	}
}
GO
