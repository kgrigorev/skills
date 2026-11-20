# expect: green
# A TestMain that the owner approved (listed in allowed_testmain) and that runs the tests.
cat >main_test.go <<'GO'
package sampletool_test

import "testing"

// TestMain runs the tests; Go exits with their result.
func TestMain(m *testing.M) { m.Run() }
GO
sed "s/^allowed_testmain=''\$/allowed_testmain='main_test.go'/" scripts/check >x.tmp && cat x.tmp >scripts/check && rm x.tmp
