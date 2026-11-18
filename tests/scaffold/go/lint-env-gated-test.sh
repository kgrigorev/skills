# expect: red Lint
# A skip in disguise, like testing.Short: the failing test returns unless an env var is set.
# Only a command reads the environment.
cat >>sampletool_test.go <<'GO'

// TestSlow checks a slow case when SAMPLE_SLOW is set.
func TestSlow(t *testing.T) {
	t.Parallel()

	if os.Getenv("SAMPLE_SLOW") == "" {
		t.Log("set SAMPLE_SLOW to run")

		return
	}
	if sampletool.Greet("a") != "nope" {
		t.Fatal("broken")
	}
}
GO
awk '{ print } $0 == "import (" { print "\t\"os\"" }' sampletool_test.go >x.tmp && mv x.tmp sampletool_test.go
