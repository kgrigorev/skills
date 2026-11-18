# expect: red Every file is checked
# A skip call split over two lines, so ".Skip(" is not on one line.
cat >>sampletool_test.go <<'GO'

// TestLater is for later.
func TestLater(t *testing.T) {
	t.Parallel()
	t.
		Skip("later")
	t.Fatal("broken")
}
GO
