# expect: red Lint
# A single-value type assertion, which panics on the wrong type.
cat >>sampletool.go <<'GO'

// Length returns the length of v, which must be a string.
func Length(v any) int {
	s := v.(string)

	return len(s)
}
GO
