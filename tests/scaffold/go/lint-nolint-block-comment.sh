# expect: red Lint
# A /*nolint*/ block comment, which golangci-lint does not honour, so unused still fires.
cat >>sampletool.go <<'GO'

// helper is never used.
func helper() {} /*nolint:unused*/
GO
