# expect: red Dependencies match pnpm-lock.yaml
# A devDependency version changed without pnpm-lock.yaml.
perl -pi -e 's/"knip": "[0-9.]+"/"knip": "6.45.0"/' package.json
