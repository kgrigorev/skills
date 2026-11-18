# expect: red Test (race
# A package under internal/cmd/ is not the module's cmd/ folder, so it needs tests.
mkdir -p internal/cmd/parse
cat >internal/cmd/parse/parse.go <<'GO'
// Package parse reads input.
package parse

// Parse returns its input.
func Parse(s string) string { return s }
GO
