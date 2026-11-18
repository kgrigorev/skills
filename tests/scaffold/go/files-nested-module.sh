# expect: red Every file is checked
# A nested go.mod takes its folder out of ./....
mkdir -p tools
printf 'module example.com/sample-tool/tools\n\ngo 1.27.0\n' >tools/go.mod
printf 'package tools\n\nimport "os"\n\nfunc Bad() { f, _ := os.Open("x"); f.Close(); panic(1) }\n' >tools/bad.go
