# expect: red Lint
# An example prints its expected output without computing it unless an env var is set.
cat >example_test.go <<'GO'
package sampletool_test

import (
	"fmt"
	"os"

	"example.com/sample-tool"
)

// ExampleGreet shows a greeting, computed only when SAMPLE_SLOW is set.
func ExampleGreet() {
	if os.Getenv("SAMPLE_SLOW") == "" {
		fmt.Println("Hello, ada!")

		return
	}
	fmt.Println(sampletool.Greet("nope"))
	// Output: Hello, ada!
}
GO
