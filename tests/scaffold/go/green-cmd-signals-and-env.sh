# expect: green
# A command split over two files: it reads a setting from the environment, stops on SIGTERM
# through syscall, and prints errors without checking the write. A command may do all of that.
# Its helper name() is logic besides main, so the command has a test for it.
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
cat >cmd/sample-tool/main_test.go <<'GO'
package main

import "testing"

// TestName reads the name from SAMPLE_NAME.
func TestName(t *testing.T) {
	t.Setenv("SAMPLE_NAME", "Ada")

	if got := name(); got != "Ada" {
		t.Errorf("name() = %q, want %q", got, "Ada")
	}
}
GO
