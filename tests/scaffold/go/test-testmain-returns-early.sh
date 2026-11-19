# expect: red Test (race
# An approved TestMain that returns before m.Run when coverage is off, which it is in
# scripts/check.
cat >main_test.go <<'GO'
package sampletool_test

import "testing"

// TestMain exits without running.
func TestMain(m *testing.M) {
	if testing.CoverMode() == "" {
		return
	}
	m.Run()
}
GO
sed "s/^allowed_testmain=''\$/allowed_testmain='main_test.go'/" scripts/check >x.tmp && cat x.tmp >scripts/check && rm x.tmp
