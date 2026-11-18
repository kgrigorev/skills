# expect: red Lint
# A skip through a method value: "t.Skip" is never followed by "(" in the source.
cat >>sampletool_test.go <<'GO'

// TestLater is for later.
func TestLater(t *testing.T) {
	t.Parallel()
	later := t.Skip
	later("later")
	t.Fatal("broken")
}
GO
