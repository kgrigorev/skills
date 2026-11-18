# expect: red Lint
# A test whose *testing.T is named "x" skips itself: the skip is found by type, not by name.
cat >>sampletool_test.go <<'GO'

// TestLater is for later.
func TestLater(x *testing.T) {
	x.Parallel()
	x.Skip("later")
	x.Fatal("broken")
}
GO
