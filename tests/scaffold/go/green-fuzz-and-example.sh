# expect: green
# A fuzz test (its seed corpus runs under go test) and an Example with an Output comment.
cat >fuzz_test.go <<'GO'
package sampletool_test

import (
	"fmt"
	"strings"
	"testing"

	"example.com/sample-tool"
)

// FuzzGreet checks that a greeting always holds a non-empty name.
func FuzzGreet(f *testing.F) {
	f.Add("ada")
	f.Add("")
	f.Fuzz(func(t *testing.T, name string) {
		got := sampletool.Greet(name)
		if name != "" && !strings.Contains(got, name) {
			t.Errorf("Greet(%q) = %q", name, got)
		}
	})
}

// ExampleGreet shows a greeting.
func ExampleGreet() {
	fmt.Println(sampletool.Greet("ada"))
	// Output: Hello, ada!
}
GO
