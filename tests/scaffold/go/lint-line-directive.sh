# expect: red Lint
# A //line directive moves the reported position of code to another file.
cat >>sampletool.go <<'GO'

// Boom returns one.
//
//line cmd/fake/main.go:1
func Boom() int { return 1 }
GO
