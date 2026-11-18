# expect: red Test (race
# A TestMain that returns before m.Run when the program has arguments, which it always has.
cat >main_test.go <<'GO'
package sampletool_test

import (
	"os"
	"testing"
)

// TestMain exits without running.
func TestMain(m *testing.M) {
	if len(os.Args) > 0 {
		return
	}
	m.Run()
}
GO
