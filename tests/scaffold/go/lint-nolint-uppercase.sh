# expect: red Lint
# "// NOLINT" in capitals: the search ignores it, and so does golangci-lint, so unused still fires.
cat >>sampletool.go <<'GO'

// unusedX is never called.
func unusedX() {} // NOLINT:unused
GO
