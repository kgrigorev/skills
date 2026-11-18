# expect: green
# A CLI that parses flags with node:util parseArgs, reads an env var, and sets the exit code.
cat >src/cli.ts <<'X'
import { parseArgs } from "node:util";

/** What the command line asks for. */
export type Request =
  | { readonly kind: "greet"; readonly name: string; readonly loud: boolean }
  | { readonly kind: "help" };

/** Reads the arguments after the program name. */
export function parseRequest(args: readonly string[]): Request {
  const { values, positionals } = parseArgs({
    args: [...args],
    allowPositionals: true,
    options: { loud: { type: "boolean", default: false }, help: { type: "boolean", short: "h" } },
  });
  if (values.help === true) return { kind: "help" };
  return { kind: "greet", name: positionals[0] ?? "", loud: values.loud };
}

/** The greeting style from the environment: GREETING=formal changes it. */
export function salutation(env: Readonly<Record<string, string | undefined>>): string {
  return env["GREETING"] === "formal" ? "Good day" : "Hello";
}
X
cat >tests/cli.test.ts <<'X'
import { describe, expect, it } from "vitest";
import { parseRequest, salutation } from "../src/cli.ts";

describe("parseRequest", () => {
  it.each([
    { args: ["Ada"], want: { kind: "greet", name: "Ada", loud: false } },
    { args: ["--loud", "Ada"], want: { kind: "greet", name: "Ada", loud: true } },
    { args: ["-h"], want: { kind: "help" } },
    { args: [], want: { kind: "greet", name: "", loud: false } },
  ])("reads $args", ({ args, want }) => {
    expect(parseRequest(args)).toEqual(want);
  });

  it("rejects an unknown flag", () => {
    expect(() => parseRequest(["--nope"])).toThrow(/nope/);
  });
});

it("uses the formal salutation on request", () => {
  expect(salutation({ GREETING: "formal" })).toBe("Good day");
  expect(salutation({})).toBe("Hello");
});
X
cat >src/main.ts <<'X'
// The sample-tool program. It only reads the command line and prints; the work happens in the library.
import { argv, env } from "node:process";
import { parseRequest, salutation } from "./cli.ts";
import { banner, greet } from "./sample-tool.ts";

const request = parseRequest(argv.slice(2));
if (request.kind === "help") {
  console.log(banner);
  process.exitCode = 0;
} else {
  const text = greet(request.name).replace("Hello", salutation(env));
  console.log(request.loud ? text.toUpperCase() : text);
}
X
mise exec -- pnpm exec oxfmt src/cli.ts src/main.ts tests/cli.test.ts >/dev/null
