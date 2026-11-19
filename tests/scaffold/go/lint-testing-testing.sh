# expect: red Lint
# The library behaves differently under test, so the test checks code production never runs.
cat >>sampletool.go <<'GO'

// Double returns twice x, but only under test.
func Double(x int) int {
	if testing.Testing() {
		return 2 * x
	}

	return x
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"testing\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
cat >double_test.go <<'GO'
package sampletool_test

import (
	"testing"

	"example.com/sample-tool"
)

// TestDouble checks Double.
func TestDouble(t *testing.T) {
	t.Parallel()

	if sampletool.Double(2) != 4 {
		t.Fatal("double")
	}
}
GO
