# expect: red Lint
# //go:linkname reaches into another package's unexported symbols. It needs an unsafe import,
# which depguard rejects before the switch-off search (it also matches go:linkname) runs.
cat >link.go <<'GO'
package sampletool

import (
	_ "unsafe"
)

// nanotime is the runtime's clock.
//
//go:linkname nanotime runtime.nanotime
func nanotime() int64
GO
