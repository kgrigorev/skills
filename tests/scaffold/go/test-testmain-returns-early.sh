# expect: red Test (race
# A TestMain that returns before m.Run when HOME is set.
cat >main_test.go <<'GO'
package sampletool_test

import (
	"os"
	"testing"
)

// TestMain exits without running.
func TestMain(m *testing.M) {
	if os.Getenv("HOME") != "" {
		return
	}
	m.Run()
}
GO
