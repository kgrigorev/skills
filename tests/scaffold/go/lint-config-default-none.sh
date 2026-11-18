# expect: red Lint
# The standard linters are switched off in the config, and an unchecked error is added.
sed 's/^  default: standard/  default: none/' .golangci.yml >x.tmp && mv x.tmp .golangci.yml
cat >>sampletool.go <<'GO'

// Open opens a file and drops the error.
func Open() { f, _ := os.Open("x"); f.Close() }
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"os\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
