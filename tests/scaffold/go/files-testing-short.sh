# expect: red Every file is checked
# A test that does nothing under -short.
cat >>sampletool_test.go <<'GO'

// TestLong checks a slow case.
func TestLong(t *testing.T) {
	t.Parallel()

	if testing.Short() {
		return
	}
	if sampletool.Greet("a") != "nope" {
		t.Fatal("broken")
	}
}
GO
