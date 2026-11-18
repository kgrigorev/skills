# expect: red Lint
# A subtest that stops itself with SkipNow, on a *testing.T named tt.
cat >>sampletool_test.go <<'GO'

// TestCases runs one case.
func TestCases(t *testing.T) {
	t.Parallel()

	t.Run("later", func(tt *testing.T) {
		tt.Parallel()
		tt.SkipNow()
		tt.Fatal("broken")
	})
}
GO
