# expect: red Every file is checked
# The library imports a package under testdata/, which ./... skips.
mkdir -p testdata/pkg
printf '// Package pkg is a fixture.\npackage pkg\n\n// X returns 1.\nfunc X() int { return 1 }\n' >testdata/pkg/x.go
cat >>sampletool.go <<'GO'

// Y uses a fixture.
func Y() int { return pkg.X() }
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"example.com/sample-tool/testdata/pkg\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
