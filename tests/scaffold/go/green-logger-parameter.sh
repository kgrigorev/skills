# expect: green
# The library logs on a *slog.Logger and a *log.Logger it is given, as the lint message advises.
cat >>sampletool.go <<'GO'

// Note logs a greeting on the structured logger it is given.
func Note(logger *slog.Logger, name string) {
	logger.Info("greeted", "name", name)
}

// NotePlain logs a greeting on the plain logger it is given.
func NotePlain(logger *log.Logger, name string) {
	logger.Printf("greeted %s", name)
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"log\""; print "\t\"log/slog\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
cat >note_test.go <<'GO'
package sampletool_test

import (
	"bytes"
	"log"
	"log/slog"
	"strings"
	"testing"

	"example.com/sample-tool"
)

// TestNote logs to a buffer.
func TestNote(t *testing.T) {
	t.Parallel()

	var buf bytes.Buffer
	sampletool.Note(slog.New(slog.NewTextHandler(&buf, nil)), "ada")
	sampletool.NotePlain(log.New(&buf, "", 0), "bob")
	if got := buf.String(); !strings.Contains(got, "ada") || !strings.Contains(got, "bob") {
		t.Errorf("log = %q", got)
	}
}
GO
