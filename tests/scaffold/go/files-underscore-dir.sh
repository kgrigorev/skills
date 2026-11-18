# expect: red Every file is checked
# ./... skips folders that start with "_".
mkdir -p _scratch
printf 'package bad\n\nimport "os"\n\nfunc Bad() { f, _ := os.Open("x"); f.Close(); panic(1) }\n' >_scratch/bad.go
