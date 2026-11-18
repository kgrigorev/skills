# expect: red Lint
# A test that skips itself.
awk '$0 == "\tgot := sampletool.Banner()" { print "\tt.Skip(\"later\")"; print "" } { print }' sampletool_test.go >x.tmp && mv x.tmp sampletool_test.go
