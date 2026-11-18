# expect: red Every file is checked
# A helper in a non-test file skips through a testing.TB named tb.
mkdir -p internal/testenv
cat >internal/testenv/testenv.go <<'GO'
// Package testenv holds test helpers.
package testenv

import "testing"

// Later skips the calling test.
func Later(tb testing.TB) {
	tb.Helper()
	tb.Skipf("later: %s", tb.Name())
}
GO
cat >internal/testenv/testenv_test.go <<'GO'
package testenv_test

import (
	"testing"

	"example.com/sample-tool/internal/testenv"
)

// TestLater calls the helper.
func TestLater(t *testing.T) {
	t.Parallel()

	testenv.Later(t)
}
GO
