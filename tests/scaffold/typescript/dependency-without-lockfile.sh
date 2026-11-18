# expect: red Dependencies match pnpm-lock.yaml
# A dependency added to package.json without pnpm-lock.yaml.
perl -pi -e 's/^  "devDependencies": \{/  "dependencies": { "left-pad": "1.3.0" },\n  "devDependencies": {/' package.json
grep -q left-pad package.json
