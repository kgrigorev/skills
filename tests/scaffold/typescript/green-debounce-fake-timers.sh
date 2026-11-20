# expect: green
# A debounce and a timeout helper, tested with fake timers, mocks and awaited rejections.
cat >src/timing.ts <<'X'
import { setTimeout as sleep } from "node:timers/promises";

/** Calls the function once, after the calls stop for the given time. */
export function debounce<A extends readonly unknown[]>(
  fn: (...args: A) => void,
  waitMs: number,
): (...args: A) => void {
  let timer: NodeJS.Timeout | undefined;
  return (...args: A) => {
    if (timer !== undefined) clearTimeout(timer);
    timer = setTimeout(() => {
      fn(...args);
    }, waitMs);
  };
}

/** The work's result, or an error when it takes longer than the limit. */
export async function withTimeout<T>(work: Promise<T>, limitMs: number): Promise<T> {
  const controller = new AbortController();
  const timeout = sleep(limitMs, undefined, { signal: controller.signal }).then(() => {
    throw new Error(`timed out after ${String(limitMs)} ms`);
  });
  try {
    return await Promise.race([work, timeout]);
  } finally {
    controller.abort();
    await timeout.catch((error: unknown) => {
      if (!(error instanceof Error) || error.name !== "AbortError") throw error;
    });
  }
}
X
cat >tests/timing.test.ts <<'X'
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { debounce, withTimeout } from "../src/timing.ts";

describe("debounce", () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
  });

  it("calls once with the last arguments", () => {
    const spy = vi.fn<(value: number) => void>();
    const debounced = debounce(spy, 100);
    debounced(1);
    debounced(2);
    vi.advanceTimersByTime(99);
    expect(spy).not.toHaveBeenCalled();
    vi.advanceTimersByTime(1);
    expect(spy).toHaveBeenCalledExactlyOnceWith(2);
  });
});

describe("withTimeout", () => {
  it("returns the work's result", async () => {
    await expect(withTimeout(Promise.resolve("done"), 1000)).resolves.toBe("done");
  });

  it("fails slow work", async () => {
    const never = new Promise<string>(() => undefined);
    await expect(withTimeout(never, 5)).rejects.toThrow("timed out after 5 ms");
  });
});
X
mise exec -- pnpm exec oxfmt src/timing.ts tests/timing.test.ts >/dev/null
