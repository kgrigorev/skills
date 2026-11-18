# expect: green
# Library code and tests that use the words the switch-off search looks for in ordinary ways:
# a Skip method on a reader type that the library and its test call, "nolint" and "nosec" in
# strings and comments, and a URL.
cat >tokens.go <<'GO'
package sampletool

import "strings"

// Linters lists the tools a report mentions. A report may say "nolint" or "nosec"; this
// package only counts the words. See https://golangci-lint.run/docs/ for the tools.
const Linters = "errcheck govet nolint nosec"

// Tokens walks the words of a line.
type Tokens struct {
	words []string
	pos   int
}

// NewTokens returns Tokens over the words of s.
func NewTokens(s string) *Tokens {
	return &Tokens{words: strings.Fields(s), pos: 0}
}

// Skip moves past the next n words. It stops at the end.
func (t *Tokens) Skip(n int) {
	t.pos = min(t.pos+max(n, 0), len(t.words))
}

// Rest returns the words not yet skipped.
func (t *Tokens) Rest() []string {
	return t.words[t.pos:]
}

// AfterHeader returns the words of s after the first n, as a parser that skips a header would.
func AfterHeader(s string, n int) []string {
	tok := NewTokens(s)
	tok.Skip(n)

	return tok.Rest()
}
GO
cat >tokens_test.go <<'GO'
package sampletool_test

import (
	"slices"
	"testing"

	"example.com/sample-tool"
)

// TestAfterHeader checks known inputs. Nothing here is skipped, and no lint is switched off.
func TestAfterHeader(t *testing.T) {
	t.Parallel()

	if got := sampletool.AfterHeader("id name a b", 2); !slices.Equal(got, []string{"a", "b"}) {
		t.Errorf("AfterHeader = %q, want [a b]", got)
	}
	if got := sampletool.AfterHeader("a", 5); len(got) != 0 {
		t.Errorf("AfterHeader past the end = %q, want none", got)
	}
}

// TestTokensSkip skips words one call at a time.
func TestTokensSkip(t *testing.T) {
	t.Parallel()

	tok := sampletool.NewTokens("a b c")
	tok.Skip(1)
	tok.Skip(-3)
	if got := tok.Rest(); !slices.Equal(got, []string{"b", "c"}) {
		t.Errorf("Rest after Skip(1), Skip(-3) = %q, want [b c]", got)
	}
}

// TestLintersNamesNolint checks the word list, which holds "nolint" as plain data.
func TestLintersNamesNolint(t *testing.T) {
	t.Parallel()

	if !slices.Contains(sampletool.Words(sampletool.Linters), "nolint") {
		t.Errorf("Linters = %q, want it to hold nolint", sampletool.Linters)
	}
}
GO
cat >split.go <<'GO'
package sampletool

import "strings"

// Words splits s into its words, dropping empty ones.
func Words(s string) []string {
	return strings.Fields(s)
}
GO
