# expect: green
# File reading that wraps its errors, tested with t.TempDir.
cat >names.go <<'GO'
package sampletool

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// ReadNames returns the non-empty lines of the file at path. gosec (G304) accepts a path that
// goes through filepath.Clean, the documented answer for a tool that reads files it is given.
func ReadNames(path string) ([]string, error) {
	b, err := os.ReadFile(filepath.Clean(path))
	if err != nil {
		return nil, fmt.Errorf("read names: %w", err)
	}
	var names []string
	for line := range strings.Lines(string(b)) {
		if s := strings.TrimSpace(line); s != "" {
			names = append(names, s)
		}
	}

	return names, nil
}
GO
cat >names_test.go <<'GO'
package sampletool_test

import (
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"slices"
	"testing"

	"example.com/sample-tool"
)

// TestReadNames reads a file with blank lines.
func TestReadNames(t *testing.T) {
	t.Parallel()

	path := filepath.Join(t.TempDir(), "names.txt")
	if err := os.WriteFile(path, []byte("ada\n\n  bob \n"), 0o600); err != nil {
		t.Fatal(err)
	}
	got, err := sampletool.ReadNames(path)
	if err != nil {
		t.Fatal(err)
	}
	if !slices.Equal(got, []string{"ada", "bob"}) {
		t.Errorf("ReadNames = %q, want [ada bob]", got)
	}
}

// TestReadNamesMissing checks that a missing file is reported as such.
func TestReadNamesMissing(t *testing.T) {
	t.Parallel()

	_, err := sampletool.ReadNames(filepath.Join(t.TempDir(), "none"))
	if !errors.Is(err, fs.ErrNotExist) {
		t.Errorf("ReadNames(missing) error = %v, want fs.ErrNotExist", err)
	}
}
GO
