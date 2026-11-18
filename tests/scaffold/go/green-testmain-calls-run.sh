# expect: green
# A TestMain that runs the tests.
cat >main_test.go <<'GO'
package sampletool_test

import "testing"

// TestMain runs the tests; Go exits with their result.
func TestMain(m *testing.M) { m.Run() }
GO
