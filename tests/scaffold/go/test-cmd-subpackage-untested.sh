# expect: red Test (race
# A package below the command folder holds logic, so it needs tests like any library package.
mkdir -p cmd/sample-tool/internal/greet
cat >cmd/sample-tool/internal/greet/greet.go <<'GO'
// Package greet builds the command's greeting.
package greet

// Line returns the greeting for name.
func Line(name string) string { return "Hello, " + name + "!" }
GO
