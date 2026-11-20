# expect: red Format
# "//NOLINT" with no space: gofumpt wants a space after "//" in a plain comment.
cat >>sampletool.go <<'GO'

// unusedX is never called.
func unusedX() {} //NOLINT:unused
GO
