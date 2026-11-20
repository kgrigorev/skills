# expect: green
# A seeded generator in the library (a game or a sampler needs one), tested with fixed seeds: a
# `seed` option is not a fast-check seed.
cat >src/prng.ts <<'X'
/** A small deterministic generator (mulberry32): the same seed gives the same sequence. */
export function mulberry32(seed: number): () => number {
  let state = seed >>> 0;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4_294_967_296;
  };
}

/** Options for a shuffle. */
export type ShuffleOptions = { readonly seed: number };

/** A shuffled copy of the items. */
export function shuffle<T>(items: readonly T[], options: ShuffleOptions): T[] {
  const next = mulberry32(options.seed);
  const copy = [...items];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(next() * (i + 1));
    const a = copy[i];
    const b = copy[j];
    if (a === undefined || b === undefined) continue;
    copy[i] = b;
    copy[j] = a;
  }
  return copy;
}
X
cat >tests/prng.test.ts <<'X'
import { expect, it } from "vitest";
import { mulberry32, shuffle } from "../src/prng.ts";

it("repeats the sequence for the same seed", () => {
  const a = mulberry32(42);
  const b = mulberry32(42);
  expect([a(), a(), a()]).toEqual([b(), b(), b()]);
});

it("keeps every item when shuffling", () => {
  const shuffled = shuffle([1, 2, 3, 4], { seed: 7 });
  expect(shuffled.toSorted((x, y) => x - y)).toEqual([1, 2, 3, 4]);
});
X
mise exec -- pnpm exec oxfmt src/prng.ts tests/prng.test.ts >/dev/null
