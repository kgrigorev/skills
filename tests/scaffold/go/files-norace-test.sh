# expect: red Every file is checked
# A failing test tagged !race never runs under go test -race.
cat >broken_test.go <<'GO'
//go:build !race

package sampletool_test

import (
	"testing"

	"example.com/sample-tool"
)

// TestGreetBroken fails, but never runs under -race.
func TestGreetBroken(t *testing.T) {
	t.Parallel()

	if sampletool.Greet("a") != "nope" {
		t.Fatal("broken")
	}
}
GO
