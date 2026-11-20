# expect: green
# Go and text fixtures under testdata/, read by a test.
mkdir -p testdata/broken
printf 'package fixture\n\nfunc f() { panic(1) }\n' >testdata/broken/fixture.go
printf 'Hello, ada!\n' >testdata/greeting.golden
cat >golden_test.go <<'GO'
package sampletool_test

import (
	"os"
	"testing"

	"example.com/sample-tool"
)

// TestGreetGolden compares a greeting with a saved file.
func TestGreetGolden(t *testing.T) {
	t.Parallel()

	want, err := os.ReadFile("testdata/greeting.golden")
	if err != nil {
		t.Fatal(err)
	}
	if got := sampletool.Greet("ada") + "\n"; got != string(want) {
		t.Errorf("Greet(ada) = %q, want %q", got, want)
	}
}
GO
