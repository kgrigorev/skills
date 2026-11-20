# expect: red Lint
# An exported function without a doc comment.
cat >>sampletool.go <<'GO'

func Twice(name string) string { return Greet(name) + Greet(name) }
GO
