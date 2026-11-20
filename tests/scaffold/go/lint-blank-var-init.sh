# expect: red Lint
# A blank variable whose initializer logs at import time.
cat >>sampletool.go <<'GO'

// _ runs at import and logs.
var _ = func() int {
	log.Println("loaded")

	return 0
}()
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"log\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
