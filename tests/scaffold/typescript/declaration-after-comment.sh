# expect: red No switched-off checks
# An ambient `declare function` after a block comment on the same line, which oxfmt keeps there.
cat >>src/sample-tool.ts <<'X'

/** Reads the config. */
/* runtime */ declare function readConfig(): { port: number };

/** The port. */
export function port(): number {
  return readConfig().port;
}
X
cat >>tests/sample-tool.test.ts <<'X'

it("port", () => {
  expect(port).toBeTypeOf("function");
});
X
sed -i.bak 's/import { banner, greet }/import { banner, greet, port }/' tests/sample-tool.test.ts && rm tests/sample-tool.test.ts.bak
