# expect: green
# A generic helper with an iterator, a line parser over io.Reader with bufio.Scanner, JSON
# output through encoding/json (struct tags, no reflect import), and a rapid property.
mkdir -p internal/records
cat >internal/records/records.go <<'GO'
// Package records parses "key=value" lines.
package records

import (
	"bufio"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"iter"
	"strings"
)

// ErrNoEquals says a line has no "=".
var ErrNoEquals = errors.New("records: line has no '='")

// Record is one key and its value.
type Record struct {
	Key   string `json:"key"`
	Value string `json:"value"`
}

// Parse reads one record per non-blank line of r.
func Parse(r io.Reader) ([]Record, error) {
	var out []Record
	sc := bufio.NewScanner(r)
	for n := 1; sc.Scan(); n++ {
		line := strings.TrimSpace(sc.Text())
		if line == "" {
			continue
		}
		key, value, ok := strings.Cut(line, "=")
		if !ok {
			return nil, fmt.Errorf("line %d: %w", n, ErrNoEquals)
		}
		out = append(out, Record{Key: key, Value: value})
	}
	if err := sc.Err(); err != nil {
		return nil, fmt.Errorf("read records: %w", err)
	}

	return out, nil
}

// Filter yields the items of s that keep accepts.
func Filter[T any](s []T, keep func(T) bool) iter.Seq[T] {
	return func(yield func(T) bool) {
		for _, v := range s {
			if keep(v) && !yield(v) {
				return
			}
		}
	}
}

// WriteJSON writes recs to w as a JSON array.
func WriteJSON(w io.Writer, recs []Record) error {
	if err := json.NewEncoder(w).Encode(recs); err != nil {
		return fmt.Errorf("write records: %w", err)
	}

	return nil
}
GO
cat >internal/records/records_test.go <<'GO'
// Tests for package records.
package records_test

import (
	"bytes"
	"errors"
	"slices"
	"strings"
	"testing"

	"pgregory.net/rapid"

	"example.com/sample-tool/internal/records"
)

// TestParse reads two records and skips a blank line.
func TestParse(t *testing.T) {
	t.Parallel()

	got, err := records.Parse(strings.NewReader("a=1\n\n b=2 \n"))
	if err != nil {
		t.Fatalf("Parse() error = %v", err)
	}
	want := []records.Record{{Key: "a", Value: "1"}, {Key: "b", Value: "2"}}
	if !slices.Equal(got, want) {
		t.Errorf("Parse() = %v, want %v", got, want)
	}
}

// TestParseNoEquals fails with ErrNoEquals.
func TestParseNoEquals(t *testing.T) {
	t.Parallel()

	if _, err := records.Parse(strings.NewReader("oops")); !errors.Is(err, records.ErrNoEquals) {
		t.Errorf("Parse() error = %v, want ErrNoEquals", err)
	}
}

// TestFilterKeepsOrder checks a property: Filter keeps exactly the accepted items, in order.
func TestFilterKeepsOrder(t *testing.T) {
	t.Parallel()

	rapid.Check(t, func(t *rapid.T) {
		s := rapid.SliceOf(rapid.Int()).Draw(t, "s")
		even := func(n int) bool { return n%2 == 0 }

		got := slices.Collect(records.Filter(s, even))
		var want []int
		for _, n := range s {
			if even(n) {
				want = append(want, n)
			}
		}
		if !slices.Equal(got, want) {
			t.Fatalf("Filter(%v) = %v, want %v", s, got, want)
		}
	})
}

// TestWriteJSON writes the documented field names.
func TestWriteJSON(t *testing.T) {
	t.Parallel()

	var buf bytes.Buffer
	if err := records.WriteJSON(&buf, []records.Record{{Key: "a", Value: "1"}}); err != nil {
		t.Fatalf("WriteJSON() error = %v", err)
	}
	if got, want := buf.String(), "[{\"key\":\"a\",\"value\":\"1\"}]\n"; got != want {
		t.Errorf("WriteJSON() = %q, want %q", got, want)
	}
}
GO
