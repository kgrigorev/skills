# expect: green
# An address with "@beta" in a string is not a knip tag: only a JSDoc comment holds tags.
cat >>src/sample-tool.ts <<'X'

/** Where people send their questions. */
export const contact: string = "ops@beta.example.com";
X
perl -pi -e 's/import \{ banner, greet \}/import { banner, contact, greet }/' src/main.ts
echo 'console.log(contact);' >>src/main.ts
