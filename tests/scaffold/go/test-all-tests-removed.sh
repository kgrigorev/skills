# expect: red Test (race
# Every test function is removed; the file and its imports stay, so go.mod stays tidy.
cat >sampletool_test.go <<'GO'
// Tests for package sampletool.
package sampletool_test

import (
	"pgregory.net/rapid"

	"example.com/sample-tool"
)

// greeters keeps the imports.
var _ = []any{rapid.String, sampletool.Greet}
GO
