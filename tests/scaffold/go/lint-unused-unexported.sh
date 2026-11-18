# expect: red Lint
# An unexported function nothing calls.
cat >>sampletool.go <<'GO'

// double is never called.
func double(a int) int { return a * 2 }
GO
