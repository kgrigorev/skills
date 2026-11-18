# expect: green
# A property test in a new test file of the existing package.
cat >greet_property_test.go <<'GO'
package sampletool_test

import (
	"strings"
	"testing"

	"pgregory.net/rapid"

	"example.com/sample-tool"
)

// TestGreetEndsWithBang checks that every greeting ends with "!".
func TestGreetEndsWithBang(t *testing.T) {
	t.Parallel()

	rapid.Check(t, func(t *rapid.T) {
		name := rapid.String().Draw(t, "name")
		if got := sampletool.Greet(name); !strings.HasSuffix(got, "!") {
			t.Fatalf("Greet(%q) = %q, want a trailing !", name, got)
		}
	})
}
GO
