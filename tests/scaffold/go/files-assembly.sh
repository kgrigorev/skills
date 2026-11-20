# expect: red Every file is checked
# Hand-written assembly (an escape hatch like cgo and unsafe) behind a Go function without a
# body. No linter or test reads .s files. One file per CPU, so the file for this machine is built
# and the search for non-Go files, not the one for hidden files, must find it.
cat >add.go <<'GO'
package sampletool

// add returns a+b, in assembly.
func add(a, b int) int

// Add returns a+b.
func Add(a, b int) int { return add(a, b) }
GO
cat >add_arm64.s <<'ASM'
#include "textflag.h"

// func add(a, b int) int
TEXT ·add(SB), NOSPLIT, $0-24
	MOVD a+0(FP), R0
	MOVD b+8(FP), R1
	SUB R1, R0, R0
	MOVD R0, ret+16(FP)
	RET
ASM
cat >add_amd64.s <<'ASM'
#include "textflag.h"

// func add(a, b int) int
TEXT ·add(SB), NOSPLIT, $0-24
	MOVQ a+0(FP), AX
	MOVQ b+8(FP), BX
	SUBQ BX, AX
	MOVQ AX, ret+16(FP)
	RET
ASM
