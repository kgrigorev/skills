# expect: green
# A command split over two files: it reads a setting from the environment, stops on SIGTERM
# through syscall, and prints errors without checking the write. A command may do all of that.
cat >cmd/sample-tool/main.go <<'GO'
// Command sample-tool greets the name in SAMPLE_NAME until it is stopped.
package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"example.com/sample-tool"
)

// main greets once, unless the program is stopped first.
func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	if err := ctx.Err(); err != nil {
		fmt.Fprintln(os.Stderr, err)

		return
	}
	fmt.Println(sampletool.Greet(name()))
}
GO
cat >cmd/sample-tool/config.go <<'GO'
package main

import "os"

// name returns the name to greet, from SAMPLE_NAME.
func name() string {
	return os.Getenv("SAMPLE_NAME")
}
GO
