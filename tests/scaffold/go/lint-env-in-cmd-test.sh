# expect: red Lint
# A test of the command returns unless an env var is set. The command's own files may read the
# environment, its tests may not.
cat >cmd/sample-tool/main_test.go <<'GO'
package main

import (
	"os"
	"testing"
)

// TestMainRuns runs main when SAMPLE_SLOW is set.
func TestMainRuns(t *testing.T) {
	if os.Getenv("SAMPLE_SLOW") == "" {
		return
	}
	main()
	t.Fatal("broken")
}
GO
