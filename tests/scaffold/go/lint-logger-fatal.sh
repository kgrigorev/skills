# expect: red Lint
# The library ends the program through a *log.Logger, not the log package's functions.
cat >>sampletool.go <<'GO'

// Need ends the program when name is empty.
func Need(w io.Writer, name string) string {
	if name == "" {
		log.New(w, "", 0).Fatal("no name")
	}

	return name
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import ("; print "\t\"io\""; print "\t\"log\""; print ")" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
