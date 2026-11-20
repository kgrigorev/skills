# expect: green
# A type with a mutex, pointer receivers, a constructor, and a concurrent test that the race
# detector must accept.
mkdir -p internal/tally
cat >internal/tally/tally.go <<'GO'
// Package tally counts words seen by many goroutines.
package tally

import (
	"maps"
	"slices"
	"sync"
)

// Counter counts words. The zero value is not ready; use New.
type Counter struct {
	mu     sync.Mutex
	counts map[string]int
}

// New returns an empty Counter.
func New() *Counter {
	return &Counter{counts: make(map[string]int)}
}

// Add counts one more of word.
func (c *Counter) Add(word string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.counts[word]++
}

// Count returns how often word was added.
func (c *Counter) Count(word string) int {
	c.mu.Lock()
	defer c.mu.Unlock()

	return c.counts[word]
}

// Words returns the counted words in sorted order.
func (c *Counter) Words() []string {
	c.mu.Lock()
	defer c.mu.Unlock()

	return slices.Sorted(maps.Keys(c.counts))
}
GO
cat >internal/tally/tally_test.go <<'GO'
// Tests for package tally.
package tally_test

import (
	"slices"
	"sync"
	"testing"

	"example.com/sample-tool/internal/tally"
)

// TestConcurrentAdd adds from many goroutines and checks the totals.
func TestConcurrentAdd(t *testing.T) {
	t.Parallel()

	c := tally.New()
	var wg sync.WaitGroup
	for range 8 {
		wg.Go(func() {
			for range 100 {
				c.Add("a")
				c.Add("b")
			}
		})
	}
	wg.Wait()

	if got := c.Count("a"); got != 800 {
		t.Errorf("Count(a) = %d, want 800", got)
	}
	if got, want := c.Words(), []string{"a", "b"}; !slices.Equal(got, want) {
		t.Errorf("Words() = %q, want %q", got, want)
	}
}
GO
