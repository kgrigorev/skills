# expect: green
# An HTTP client that takes a context, closes the body, checks the status and wraps errors,
# tested against httptest.Server.
mkdir -p internal/fetch
cat >internal/fetch/fetch.go <<'GO'
// Package fetch downloads small text documents.
package fetch

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
)

// ErrStatus says the server answered with a status other than 200 OK.
var ErrStatus = errors.New("fetch: unexpected status")

// maxBody is the largest body Text reads.
const maxBody = 1 << 20

// Text returns the body of the document at url, read through client.
func Text(ctx context.Context, client *http.Client, url string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, http.NoBody)
	if err != nil {
		return "", fmt.Errorf("fetch %s: %w", url, err)
	}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("fetch %s: %w", url, err)
	}
	body, readErr := io.ReadAll(io.LimitReader(resp.Body, maxBody))
	closeErr := resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("fetch %s: %d: %w", url, resp.StatusCode, ErrStatus)
	}
	if err := errors.Join(readErr, closeErr); err != nil {
		return "", fmt.Errorf("fetch %s: %w", url, err)
	}

	return string(body), nil
}
GO
cat >internal/fetch/fetch_test.go <<'GO'
// Tests for package fetch.
package fetch_test

import (
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"example.com/sample-tool/internal/fetch"
)

// newServer serves body with status code until the test ends.
func newServer(t *testing.T, code int, body string) *httptest.Server {
	t.Helper()

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(code)
		if _, err := io.WriteString(w, body); err != nil {
			t.Errorf("write body: %v", err)
		}
	}))
	t.Cleanup(srv.Close)

	return srv
}

// TestTextOK reads a body.
func TestTextOK(t *testing.T) {
	t.Parallel()

	srv := newServer(t, http.StatusOK, "hello")
	got, err := fetch.Text(t.Context(), srv.Client(), srv.URL)
	if err != nil {
		t.Fatalf("Text() error = %v", err)
	}
	if got != "hello" {
		t.Errorf("Text() = %q, want %q", got, "hello")
	}
}

// TestTextStatus fails on a 404 with ErrStatus.
func TestTextStatus(t *testing.T) {
	t.Parallel()

	srv := newServer(t, http.StatusNotFound, "gone")
	_, err := fetch.Text(t.Context(), srv.Client(), srv.URL)
	if !errors.Is(err, fetch.ErrStatus) {
		t.Errorf("Text() error = %v, want ErrStatus", err)
	}
}
GO
