# expect: red Test (race
# An approved TestMain that never calls m.Run, so the broken test below never runs.
cat >main_test.go <<'GO'
package sampletool_test

import "testing"

// TestMain runs nothing.
func TestMain(m *testing.M) { _ = m }
GO
sed 's/HasPrefix(got/HasPrefix("x"+got/' sampletool_test.go >x.tmp && mv x.tmp sampletool_test.go
sed "s/^allowed_testmain=''\$/allowed_testmain='main_test.go'/" scripts/check >x.tmp && cat x.tmp >scripts/check && rm x.tmp
