# expect: red Lint
# The library logs to the global logger and exits through log.Fatalf.
cat >>sampletool.go <<'GO'

// Must stops the program on failure.
func Must(err error) {
	if err != nil {
		log.Fatalf("sample: %v", err)
	}
	log.Println("ok")
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"log\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
