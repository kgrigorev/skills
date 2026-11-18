# expect: red Every file is checked
# A skip through a method expression.
cat >>sampletool_test.go <<'GO'

// TestLater is for later.
func TestLater(t *testing.T) {
	t.Parallel()
	(*testing.T).Skip(t, "later")
	t.Fatal("broken")
}
GO
