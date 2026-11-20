# expect: green
# A text file embedded with //go:embed.
printf 'Usage: sample-tool [name]\n' >usage.txt
cat >usage.go <<'GO'
package sampletool

import _ "embed"

// usage is the help text, kept in usage.txt.
//
//go:embed usage.txt
var usage string

// Usage returns the help text.
func Usage() string { return usage }
GO
cat >usage_test.go <<'GO'
package sampletool_test

import (
	"strings"
	"testing"

	"example.com/sample-tool"
)

// TestUsageNamesProgram checks that the help text names the program.
func TestUsageNamesProgram(t *testing.T) {
	t.Parallel()

	if !strings.Contains(sampletool.Usage(), sampletool.Name) {
		t.Errorf("Usage() = %q, want it to name %q", sampletool.Usage(), sampletool.Name)
	}
}
GO
