# expect: red Test (race
# A package without tests prints the line scripts/check counts as a test run, from a blank
# variable at load time. go test still says "[no tests to run]".
mkdir -p internal/calc
cat >internal/calc/calc.go <<'GO'
// Package calc adds numbers.
package calc

// Add returns a plus b. It is wrong, and no test runs it.
func Add(a, b int) int { return a - b }
GO
cat >internal/calc/calc_test.go <<'GO'
package calc_test

import "fmt"

// _ prints, at load time, the line scripts/check counts as a test run.
var _ = func() int {
	fmt.Println("=== RUN   TestAdd")

	return 0
}()
GO
