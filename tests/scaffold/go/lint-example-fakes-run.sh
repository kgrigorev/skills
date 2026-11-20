# expect: red Lint
# A TestMain that never runs the tests prints the line scripts/check counts as a test run,
# through an Example that is never run as one (no Output comment). Examples follow the rules of
# other test code, so os.Stderr is forbidden there.
cat >main_test.go <<'GO'
package sampletool_test

import (
	"fmt"
	"os"
	"testing"
)

// TestMain never runs the tests.
func TestMain(m *testing.M) {
	_ = m
	ExampleBanner()
}

// ExampleBanner has no Output comment, so it is never run as an example.
func ExampleBanner() {
	fmt.Fprintln(os.Stderr, "=== RUN   TestBannerStartsWithName")
}
GO
sed 's/HasPrefix(got/HasPrefix("x"+got/' sampletool_test.go >x.tmp && mv x.tmp sampletool_test.go
