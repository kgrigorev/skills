# expect: red Every file is checked
# A //godoclint:disable line, apart from the package clause, switches the doc comment rule off
# for the file.
cat >triple.go <<'GO'
//godoclint:disable

package sampletool

func Triple(x int) int { return 3 * x }
GO
cat >triple_test.go <<'GO'
package sampletool_test

import (
	"testing"

	"example.com/sample-tool"
)

// TestTriple checks Triple.
func TestTriple(t *testing.T) {
	t.Parallel()

	if sampletool.Triple(2) != 6 {
		t.Fatal("triple")
	}
}
GO
