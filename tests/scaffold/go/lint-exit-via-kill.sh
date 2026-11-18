# expect: red Lint
# The library ends the program by killing its own process instead of calling os.Exit.
cat >>sampletool.go <<'GO'

// Quit ends the program.
func Quit() error {
	p, err := os.FindProcess(os.Getpid())
	if err != nil {
		return fmt.Errorf("quit: %w", err)
	}
	if err := p.Kill(); err != nil {
		return fmt.Errorf("quit: %w", err)
	}

	return nil
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"fmt\""; print "\t\"os\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
