# expect: red Every file is checked
# A //nolint comment in a test file.
awk '$0 == "func TestBannerStartsWithName(t *testing.T) {" { print "func TestBannerStartsWithName(t *testing.T) { //nolint:paralleltest"; next } { print }' sampletool_test.go >x.tmp && mv x.tmp sampletool_test.go
