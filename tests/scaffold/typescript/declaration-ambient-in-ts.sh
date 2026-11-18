# expect: red No switched-off checks
# The lie of declaration-file-own without any declaration file: an ambient `declare function` in a
# plain .ts module. tsc trusts it; the program fails when it runs.
cat >>src/main.ts <<'Y'

declare function parseLedger(text: string): number;
console.log(parseLedger("x"));
Y
