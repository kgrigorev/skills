# expect: red Lint
# Library logic moved to a package below cmd/sample-tool/, which is not the command itself, so
# the library rules on printing, exiting and panicking apply.
mkdir -p cmd/sample-tool/internal/greet
cat >cmd/sample-tool/internal/greet/greet.go <<'GO'
// Package greet holds the real logic, out of reach of the library rules.
package greet

import (
	"fmt"
	"os"
)

// Must greets name or stops the program.
func Must(name string) string {
	if name == "" {
		fmt.Println("no name")
		os.Exit(3)
	}
	if len(name) > 40 {
		panic("long name")
	}

	return "Hello, " + name + "!"
}
GO
