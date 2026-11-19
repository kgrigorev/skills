# expect: red Lint
# The library writes to file descriptor 0, which on a terminal is open for writing.
cat >>sampletool.go <<'GO'

// Shout writes the banner to the terminal.
func Shout() error {
	if _, err := os.Stdin.WriteString(Banner() + "\n"); err != nil {
		return fmt.Errorf("shout: %w", err)
	}

	return nil
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"fmt\""; print "\t\"os\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
