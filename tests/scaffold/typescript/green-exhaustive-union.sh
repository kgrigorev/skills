# expect: green
# A dependency-free helper with a discriminated union, an exhaustive switch and a class.
cat >src/shapes.ts <<'X'
/** A shape on the plane. */
export type Shape =
  | { readonly kind: "circle"; readonly radius: number }
  | { readonly kind: "square"; readonly side: number };

/** The area of a shape. */
export function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      return Math.PI * shape.radius ** 2;
    case "square":
      return shape.side ** 2;
  }
}

/** Counts how many shapes went in and how many failed a size check. */
export class Tally {
  #seen = 0;
  #fails = 0;

  /** Records one shape; a shape with a negative size counts as a failure. */
  add(shape: Shape): void {
    this.#seen += 1;
    const size = shape.kind === "circle" ? shape.radius : shape.side;
    if (size < 0) this.#fails += 1;
  }

  /** The counts so far. */
  get summary(): { readonly seen: number; readonly fails: number } {
    return { seen: this.#seen, fails: this.#fails };
  }
}
X
cat >tests/shapes.test.ts <<'X'
import { expect, it } from "vitest";
import { area, Tally } from "../src/shapes.ts";

it("computes the area of a square", () => {
  expect(area({ kind: "square", side: 3 })).toBe(9);
});

it("counts the failures", () => {
  const tally = new Tally();
  tally.add({ kind: "circle", radius: -1 });
  tally.add({ kind: "square", side: 2 });
  expect(tally.summary.fails).toBe(1);
  expect(tally.summary).toEqual({ seen: 2, fails: 1 });
});
X
