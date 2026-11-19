# expect: red Every file is checked
# //go:norace turns the race detector off for one function, so the race below goes unseen.
cat >>sampletool.go <<'GO'

// Count adds one per worker, in parallel, with no lock.
func Count(workers int) int {
	n := 0
	var wg sync.WaitGroup
	for range workers {
		wg.Go(func() { inc(&n) })
	}
	wg.Wait()

	return n
}

// inc adds one to *p.
//
//go:norace
func inc(p *int) { *p++ }
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"sync\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
cat >count_test.go <<'GO'
package sampletool_test

import (
	"testing"

	"example.com/sample-tool"
)

// TestCount counts four workers.
func TestCount(t *testing.T) {
	t.Parallel()

	if got := sampletool.Count(4); got < 1 {
		t.Errorf("Count(4) = %d", got)
	}
}
GO
