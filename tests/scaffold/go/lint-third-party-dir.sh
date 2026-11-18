# expect: red Lint
# Sloppy code under third_party/, a folder some linters skip by default.
mkdir -p third_party/x
cat >third_party/x/x.go <<'GO'
package x

import "os"

func Bad() { f, _ := os.Open("x"); f.Close(); panic(1) }
GO
cat >third_party/x/x_test.go <<'GO'
package x

import "testing"

func TestX(t *testing.T) { t.Parallel() }
GO
