# expect: red Lint
# A property that drops the inputs it fails on with rapid's t.Skip.
cat >>sampletool_test.go <<'GO'

// TestGreetIsShort checks a property that does not hold, and skips the inputs that break it.
func TestGreetIsShort(t *testing.T) {
	t.Parallel()

	rapid.Check(t, func(r *rapid.T) {
		name := rapid.String().Draw(r, "name")
		if len(name) > 0 {
			r.Skip("too long")
		}
		if len(sampletool.Greet(name)) > 20 {
			r.Fatal("long greeting")
		}
	})
}
GO
