# expect: red Test (race
# A method in a command is logic too, also in a second file of the command.
cat >cmd/sample-tool/banner.go <<'GO'
package main

// banner is the line the command prints.
type banner string

// framed returns the banner between two rules.
func (b banner) framed() string { return "--\n" + string(b) + "\n--" }
GO
sed 's/fmt.Println(\(.*\)\.Banner())/fmt.Println(banner(\1.Banner()).framed())/' cmd/sample-tool/main.go >x.tmp
cat x.tmp >cmd/sample-tool/main.go && rm x.tmp
grep -q 'framed()' cmd/sample-tool/main.go
