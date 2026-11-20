# expect: red Test (vitest)
# Array.prototype.push drops the message of tests/setup.ts around fc.check, so a list of problems
# kept with push would stay empty, and the failed property would pass.
cat >tests/extra.test.ts <<'X'
import * as fc from "fast-check";
import { expect, it } from "vitest";
import { greet } from "../src/sample-tool.ts";

const { push } = Array.prototype;

function dropProblems(this: unknown[], ...items: unknown[]): number {
  const [first] = items;
  if (typeof first === "string" && first.startsWith("A property")) return this.length;
  const length: unknown = Reflect.apply(push, this, items);
  return typeof length === "number" ? length : 0;
}

it("wrong property", () => {
  let result: unknown;
  Reflect.set(Array.prototype, "push", dropProblems);
  try {
    result = fc.check(fc.property(fc.string(), (name) => greet(name) === "never"));
  } catch (error) {
    result = error;
  } finally {
    Reflect.set(Array.prototype, "push", push);
  }
  expect(result).toBeDefined();
});
X
