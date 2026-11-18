# expect: red Test (race
# A package whose only test is an Example with no Output comment, which go test never runs.
mkdir -p internal/util
printf '// Package util doubles.\npackage util\n\n// Double returns twice n.\nfunc Double(n int) int { return n * 3 }\n' >internal/util/util.go
cat >internal/util/util_test.go <<'GO'
// Tests for package util.
package util_test

import "example.com/sample-tool/internal/util"

// ExampleDouble is compiled, never run.
func ExampleDouble() {
	_ = util.Double(2)
}
GO
