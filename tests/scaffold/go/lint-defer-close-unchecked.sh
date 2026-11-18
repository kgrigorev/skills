# expect: red Lint
# defer f.Close() drops the Close error.
cat >>sampletool.go <<'GO'

// Read opens a file.
func Read(p string) error {
	f, err := os.Open(p)
	if err != nil {
		return fmt.Errorf("open %s: %w", p, err)
	}
	defer f.Close()

	return nil
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"fmt\""; print "\t\"os\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
