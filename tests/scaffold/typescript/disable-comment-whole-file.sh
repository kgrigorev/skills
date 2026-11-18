# expect: red No switched-off checks
# A file-wide disable comment in a module with a non-ASCII name.
cat >src/données.ts <<'X'
// oxlint-disable
/** Helper. */
export function loose(value: any): any {
  return value == 1 ? value.foo : value;
}
X
printf 'import { loose } from "./données.ts";\nconsole.log(loose(1));\n' >>src/main.ts
