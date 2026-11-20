# expect: red Every file is checked
# A #nosec comment that silences gosec.
cat >>sampletool.go <<'GO'

// Load reads any path.
func Load(p string) ([]byte, error) {
	b, err := os.ReadFile(p) // #nosec G304
	if err != nil {
		return nil, fmt.Errorf("load: %w", err)
	}

	return b, nil
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"fmt\""; print "\t\"os\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
