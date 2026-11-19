# expect: red Every file is checked
# A TestMain that runs the tests, but that the owner has not approved: a TestMain decides
# whether its package's tests run, so each one is listed in allowed_testmain.
cat >main_test.go <<'GO'
package sampletool_test

import "testing"

// TestMain runs the tests; Go exits with their result.
func TestMain(m *testing.M) { m.Run() }
GO
