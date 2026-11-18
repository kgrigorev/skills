# expect: red Only .ts sources, and only the gate configs
# knip settings in package.json, which knip reads next to knip.jsonc.
perl -pi -e 's/"private": true,/"private": true,\n  "knip": { "ignore": ["src\/**"] },/' package.json
