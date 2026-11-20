# expect: green
# The usual run(args, stdout, stderr) int pattern: main only calls os.Exit(run(...)), the library
# gets a context with signal cancellation and an io.Writer, and the library is tested with a
# bytes.Buffer.
cat >>sampletool.go <<'GO'

// Greeting writes one greeting per name to w, and stops early when ctx is done.
func Greeting(ctx context.Context, w io.Writer, names []string) error {
	for _, name := range names {
		if err := ctx.Err(); err != nil {
			return fmt.Errorf("greeting: %w", err)
		}
		if _, err := fmt.Fprintln(w, Greet(name)); err != nil {
			return fmt.Errorf("greeting: %w", err)
		}
	}

	return nil
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"context\""; print "\t\"fmt\""; print "\t\"io\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
cat >greeting_test.go <<'GO'
package sampletool_test

import (
	"bytes"
	"context"
	"errors"
	"testing"

	"example.com/sample-tool"
)

// TestGreeting writes one line per name.
func TestGreeting(t *testing.T) {
	t.Parallel()

	var buf bytes.Buffer
	if err := sampletool.Greeting(t.Context(), &buf, []string{"ada", "bob"}); err != nil {
		t.Fatalf("Greeting() error = %v", err)
	}
	if got, want := buf.String(), "Hello, ada!\nHello, bob!\n"; got != want {
		t.Errorf("Greeting() wrote %q, want %q", got, want)
	}
}

// TestGreetingCancelled stops when the context is done.
func TestGreetingCancelled(t *testing.T) {
	t.Parallel()

	ctx, cancel := context.WithCancel(t.Context())
	cancel()
	var buf bytes.Buffer
	if err := sampletool.Greeting(ctx, &buf, []string{"ada"}); !errors.Is(err, context.Canceled) {
		t.Errorf("Greeting() error = %v, want context.Canceled", err)
	}
}
GO
cat >cmd/sample-tool/main.go <<'GO'
// Command sample-tool greets each name on its command line.
package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"os/signal"

	"example.com/sample-tool"
)

// main exits with the status run returns.
func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}

// run greets args on stdout and returns the exit status; errors go to stderr.
func run(args []string, stdout, stderr io.Writer) int {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	if len(args) == 0 {
		args = []string{""}
	}
	if err := sampletool.Greeting(ctx, stdout, args); err != nil {
		fmt.Fprintln(stderr, err)

		return 1
	}

	return 0
}
GO
