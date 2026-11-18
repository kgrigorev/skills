# expect: red Every file is checked
# A //nolint in a file whose name has a space, which once split the search.
cat >'sample util.go' <<'GO'
package sampletool

// helper is never used.
func helper() {} //nolint:unused
GO
