# expect: red No switched-off checks
# A NUL byte makes git treat the file as binary, which git grep -I skipped whole: the disable
# comment and @ts-nocheck switched off lint and the type check. scripts/check greps with --text.
printf '/* oxlint-disable */\n// @ts-nocheck\n/* \000 */\n/** Wrong. */\nexport const total: number = "not a number";\n' > src/loose.ts
{ printf 'import { total } from "./loose.ts";\n'; cat src/main.ts; printf 'console.log(total.toFixed(2));\n'; } > m.tmp && mv m.tmp src/main.ts
