# expect: red Every file is checked
# A //go:debug directive changes a runtime default for the binary.
awk '$0 == "package main" { print "//"; print "//go:debug panicnil=1" } { print }' cmd/sample-tool/main.go >x.tmp && mv x.tmp cmd/sample-tool/main.go
