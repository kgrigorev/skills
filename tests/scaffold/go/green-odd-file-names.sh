# expect: green
# Valid but unusual file names: a space, a dash, a plus, and test data with a space.
cat >'string helpers.go' <<'GO'
package sampletool

import "strings"

// Initials returns the first letter of each word of s, in upper case.
func Initials(s string) string {
	var b strings.Builder
	for w := range strings.FieldsSeq(s) {
		b.WriteString(strings.ToUpper(w[:1]))
	}

	return b.String()
}
GO
cat >'string helpers_test.go' <<'GO'
package sampletool_test

import (
	"os"
	"strings"
	"testing"

	"example.com/sample-tool"
)

// TestInitials reads its input from a file whose name has a space.
func TestInitials(t *testing.T) {
	t.Parallel()

	b, err := os.ReadFile("testdata/full name.txt")
	if err != nil {
		t.Fatal(err)
	}
	if got := sampletool.Initials(strings.TrimSpace(string(b))); got != "AL" {
		t.Errorf("Initials = %q, want AL", got)
	}
}
GO
mkdir -p testdata
printf 'ada lovelace\n' >'testdata/full name.txt'
cat >v2-compat+legacy.go <<'GO'
package sampletool

// LegacyName is the program's name before version 2.
const LegacyName = "sampletool"
GO
cat >v2-compat+legacy_test.go <<'GO'
package sampletool_test

import (
	"testing"

	"example.com/sample-tool"
)

// TestLegacyNameDiffers checks that the old name is not the new one.
func TestLegacyNameDiffers(t *testing.T) {
	t.Parallel()

	if sampletool.LegacyName == sampletool.Name {
		t.Errorf("LegacyName = Name = %q", sampletool.Name)
	}
}
GO
