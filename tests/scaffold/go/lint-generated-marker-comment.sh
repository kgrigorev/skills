# expect: red Lint
# A "do not edit" comment that is not a real generated header, with sloppy code under it.
cat >sloppy.go <<'GO'
// Package sampletool: do not edit.
package sampletool

import "os"

func Sloppy(p string) {
	f, _ := os.Open(p)
	f.Close()
	var x any = p
	_ = x.(int)
	panic("boom")
}
GO
