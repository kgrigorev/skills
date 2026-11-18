# expect: red Format (oxfmt)
# A nested .oxfmtrc.json that would accept single quotes in its folder.
mkdir -p src/x
printf '{ "singleQuote": true }\n' >src/x/.oxfmtrc.json
printf "export const a = 'single';\n" >src/x/a.ts
printf 'import { a } from "./x/a.ts";\nconsole.log(a);\n' >>src/main.ts
