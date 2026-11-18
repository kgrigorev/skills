# expect: red Only .ts sources, and only the gate configs
# A .TS file with a type error, which tsc's include does not match.
printf 'export const x: number = "s";\n' >src/bad.TS
