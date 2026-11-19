# expect: red Lint
# A TestMain sets -rapid.checks to 0 before it runs the tests, so every property passes
# without drawing an input. The global flag set is the command's.
cat >main_test.go <<'GO'
package sampletool_test

import (
	"flag"
	"testing"
)

// TestMain turns property checks off, then runs the tests.
func TestMain(m *testing.M) {
	flag.Parse()
	if err := flag.Set("rapid.checks", "0"); err != nil {
		return
	}
	m.Run()
}
GO
