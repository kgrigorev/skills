# expect: red Lint
# The library writes to the terminal through os.NewFile(1, ...), not os.Stdout.
cat >>sampletool.go <<'GO'

// Say writes a greeting to the terminal.
func Say(name string) error {
	if _, err := fmt.Fprintln(os.NewFile(1, "/dev/stdout"), Greet(name)); err != nil {
		return fmt.Errorf("say: %w", err)
	}

	return nil
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"fmt\""; print "\t\"os\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
