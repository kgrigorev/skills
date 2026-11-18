# expect: green
# The command parses flags, prints to stderr and sets the exit code; cmd/ may do that.
cat >cmd/sample-tool/main.go <<'GO'
// Command sample-tool greets a name. Keep it thin: the work happens in package sampletool.
package main

import (
	"flag"
	"fmt"
	"os"

	"example.com/sample-tool"
)

// main greets the name given with -name, and fails on extra arguments.
func main() {
	name := flag.String("name", "", "who to greet")
	flag.Parse()
	if flag.NArg() > 0 {
		fmt.Fprintln(os.Stderr, "unexpected arguments:", flag.Args())
		os.Exit(2)
	}
	fmt.Println(sampletool.Banner())
	fmt.Println(sampletool.Greet(*name))
}
GO
