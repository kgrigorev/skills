# expect: red Lint (oxlint
# An import of a package that package.json does not list. pnpm does not link it, so the
# type-aware rules see the unresolved import as any.
printf 'import { glob } from "tinyglobby";\nconsole.log(await glob("*.ts"));\n' >>src/main.ts
