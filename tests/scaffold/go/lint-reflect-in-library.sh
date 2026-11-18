# expect: red Lint
# Reflection in the library writes through any value.
cat >>sampletool.go <<'GO'

// Poke writes through reflection.
func Poke(v any) {
	reflect.ValueOf(v).Elem().SetInt(1)
}
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"reflect\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
