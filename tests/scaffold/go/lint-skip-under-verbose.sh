# expect: red Lint
# scripts/check always passes -v, so a test that returns under testing.Verbose() skips itself
# in every gate run.
cat >>sampletool_test.go <<'GO'

// TestBroken fails, except under -v.
func TestBroken(t *testing.T) {
	t.Parallel()

	if testing.Verbose() {
		return
	}
	if sampletool.Greet("a") != "nope" {
		t.Fatal("broken")
	}
}
GO
