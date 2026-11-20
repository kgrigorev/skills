# expect: red Test (race
# env: GORACE=exitcode=0
# A data race, with the caller asking the race detector not to fail.
cat >race_test.go <<'GO'
package sampletool_test

import (
	"sync"
	"testing"
)

// TestRace has a data race.
func TestRace(t *testing.T) {
	t.Parallel()

	n := 0
	var wg sync.WaitGroup
	for range 4 {
		wg.Go(func() { n++ })
	}
	wg.Wait()
	if n < 0 {
		t.Fatal("neg")
	}
}
GO
