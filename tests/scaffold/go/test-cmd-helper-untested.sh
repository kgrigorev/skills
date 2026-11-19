# expect: red Test (race
# A command with a function besides main and run holds logic, so it needs a test.
cat >>cmd/sample-tool/main.go <<'GO'

// shout returns line in capitals, with an exclamation mark.
func shout(line string) string { return strings.ToUpper(line) + "!" }
GO
sed 's/^	"fmt"$/	"fmt"\
	"strings"/; s/fmt.Println(\(.*\)\.Banner())/fmt.Println(shout(\1.Banner()))/' cmd/sample-tool/main.go >x.tmp
cat x.tmp >cmd/sample-tool/main.go && rm x.tmp
grep -q 'shout(sampletool.Banner())' cmd/sample-tool/main.go
