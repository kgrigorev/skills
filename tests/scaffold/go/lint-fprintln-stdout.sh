# expect: red Lint
# The library prints to os.Stdout through fmt.Fprintln, with the error checked.
cat >>sampletool.go <<'GO'

// Say prints a greeting.
func Say(name string) error {
	if _, err := fmt.Fprintln(os.Stdout, Greet(name)); err != nil {
		return fmt.Errorf("say: %w", err)
	}

	return nil
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"fmt\""; print "\t\"os\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
