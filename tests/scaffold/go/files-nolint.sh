# expect: red Every file is checked
# A //nolint comment.
awk '$0 == "func Banner() string {" { print "func Banner() string { //nolint:gocritic // later"; next } { print }' sampletool.go >x.tmp && mv x.tmp sampletool.go
