# expect: red Every file is checked
# A file tagged race is built only by the tests, never linted.
cat >racy.go <<'GO'
//go:build race

package sampletool

import "os"

// Racy drops an error.
func Racy() { f, _ := os.Open("x"); f.Close() }
GO
