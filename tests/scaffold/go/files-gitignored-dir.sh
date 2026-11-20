# expect: red Every file is checked
# A //nolint in a package that git ignores but ./... still lints.
printf '/vendored/\n' >>.gitignore
mkdir -p vendored
cat >vendored/x.go <<'GO'
// Package x is hidden from git.
package x

// helper is never used.
func helper() {} //nolint:unused
GO
cat >vendored/x_test.go <<'GO'
package x

import "testing"

// TestX runs.
func TestX(t *testing.T) { t.Parallel() }
GO
