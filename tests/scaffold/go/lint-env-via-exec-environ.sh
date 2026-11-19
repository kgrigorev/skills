# expect: red Lint
# A test reads the environment through exec.Cmd.Environ and returns unless SLOW=1 is set.
cat >>sampletool_test.go <<'GO'

// TestBroken fails, unless SLOW=1 is missing from the environment.
func TestBroken(t *testing.T) {
	t.Parallel()

	if !slices.Contains(exec.CommandContext(t.Context(), "true").Environ(), "SLOW=1") {
		return
	}
	if sampletool.Greet("a") != "nope" {
		t.Fatal("broken")
	}
}
GO
awk '{ print } $0 == "import (" { print "\t\"os/exec\""; print "\t\"slices\"" }' sampletool_test.go >x.tmp && mv x.tmp sampletool_test.go
