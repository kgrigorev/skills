# expect: red Lint
# C code through cgo, which no check reads.
cat >cgo.go <<'GO'
package sampletool

/*
int bad(int *p) { return p[100]; }
*/
import "C"

// CBad calls C.
func CBad() int { return int(C.bad(nil)) }
GO
