# expect: green
# An enum with a String method, an exhaustive switch, a parse function with a custom error type
# that callers match with errors.As, and a table test.
mkdir -p internal/level
cat >internal/level/level.go <<'GO'
// Package level names how loud a message is.
package level

import "fmt"

// Level is how loud a message is.
type Level int

// The levels, quietest first.
const (
	Debug Level = iota
	Info
	Warn
	Error
)

// String returns the lower-case name of l.
func (l Level) String() string {
	switch l {
	case Debug:
		return "debug"
	case Info:
		return "info"
	case Warn:
		return "warn"
	case Error:
		return "error"
	}

	return fmt.Sprintf("level(%d)", int(l))
}

// UnknownError says a name is not a level.
type UnknownError struct {
	// Name is the text that failed to parse.
	Name string
}

// Error returns the message.
func (e *UnknownError) Error() string { return fmt.Sprintf("unknown level %q", e.Name) }

// Parse returns the level called name.
func Parse(name string) (Level, error) {
	for l := Debug; l <= Error; l++ {
		if l.String() == name {
			return l, nil
		}
	}

	return 0, &UnknownError{Name: name}
}
GO
cat >internal/level/level_test.go <<'GO'
// Tests for package level.
package level_test

import (
	"errors"
	"testing"

	"example.com/sample-tool/internal/level"
)

// TestParseRoundTrip parses every level's name back to the level.
func TestParseRoundTrip(t *testing.T) {
	t.Parallel()

	for _, l := range []level.Level{level.Debug, level.Info, level.Warn, level.Error} {
		t.Run(l.String(), func(t *testing.T) {
			t.Parallel()

			got, err := level.Parse(l.String())
			if err != nil || got != l {
				t.Errorf("Parse(%q) = %v, %v, want %v", l.String(), got, err, l)
			}
		})
	}
}

// TestParseUnknown returns an UnknownError that names the input.
func TestParseUnknown(t *testing.T) {
	t.Parallel()

	_, err := level.Parse("loud")
	var unknown *level.UnknownError
	if !errors.As(err, &unknown) || unknown.Name != "loud" {
		t.Errorf("Parse(%q) error = %v, want an UnknownError for it", "loud", err)
	}
}
GO
