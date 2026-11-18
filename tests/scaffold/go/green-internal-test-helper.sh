# expect: green
# An internal (same-package) test file with a helper that calls t.Helper, and reflect.DeepEqual,
# which tests may use.
cat >split.go <<'GO'
package sampletool

import "strings"

// Words splits s into its words, dropping empty ones.
func Words(s string) []string {
	return strings.Fields(s)
}
GO
cat >split_internal_test.go <<'GO'
package sampletool

import (
	"reflect"
	"testing"
)

// assertWords fails the test when Words(s) is not want.
func assertWords(t *testing.T, s string, want []string) {
	t.Helper()

	if got := Words(s); !reflect.DeepEqual(got, want) {
		t.Errorf("Words(%q) = %q, want %q", s, got, want)
	}
}

// TestWords checks known inputs.
func TestWords(t *testing.T) {
	t.Parallel()

	assertWords(t, "a b", []string{"a", "b"})
	assertWords(t, "  spaced   out ", []string{"spaced", "out"})
	assertWords(t, "", []string{})
}
GO
