# expect: red No switched-off checks
# A disable comment for a rule that would otherwise fail.
printf '// oxlint-disable-next-line no-debugger\ndebugger;\n' >>src/main.ts
