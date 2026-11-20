# expect: green
# Async file IO done right: awaited, errors rethrown with a cause, a retry policy as plain data.
cat >src/store.ts <<'X'
import { readFile, writeFile } from "node:fs/promises";

/** How often to try a write before giving up. */
const policy = { retry: 3, delayMs: 100 } as const;

/** Writes the text, trying up to policy.retry times. */
export async function save(path: string, text: string): Promise<void> {
  let lastError: unknown;
  for (let attempt = 1; attempt <= policy.retry; attempt += 1) {
    try {
      await writeFile(path, text);
      return;
    } catch (error) {
      lastError = error;
    }
  }
  throw new Error(`could not write ${path}`, { cause: lastError });
}

/** Reads the text back. */
export async function load(path: string): Promise<string> {
  return await readFile(path, "utf8");
}
X
cat >tests/store.test.ts <<'X'
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, expect, it } from "vitest";
import { load, save } from "../src/store.ts";

const dirs: string[] = [];
afterEach(async () => {
  await Promise.all(dirs.splice(0).map((dir) => rm(dir, { recursive: true })));
});

it("reads back what it wrote", async () => {
  const dir = await mkdtemp(join(tmpdir(), "store-"));
  dirs.push(dir);
  await save(join(dir, "a.txt"), "hello");
  expect(await load(join(dir, "a.txt"))).toBe("hello");
});

it("explains a failed write", async () => {
  await expect(save("/nonexistent/dir/a.txt", "x")).rejects.toThrow(
    "could not write",
  );
});
X
mise exec -- pnpm exec oxfmt src/store.ts tests/store.test.ts >/dev/null
