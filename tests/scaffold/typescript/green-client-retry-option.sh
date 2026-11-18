# expect: green
# A fetch wrapper with a retry option and an injected fetch, and a test that passes { retry: 2 }
# to it: a `retry` option is not a vitest retry.
cat >src/client.ts <<'X'
/** How a request is made: the fetch to use and how many extra tries a failed request gets. */
export type ClientOptions = {
  readonly fetch: (url: string) => Promise<{ readonly ok: boolean; readonly status: number }>;
  readonly retry: number;
};

/** The HTTP status of the first successful try, or an error naming the last status. */
export async function statusOf(url: string, options: ClientOptions): Promise<number> {
  let last = 0;
  for (let attempt = 0; attempt <= options.retry; attempt += 1) {
    const response = await options.fetch(url);
    if (response.ok) return response.status;
    last = response.status;
  }
  throw new Error(`${url} failed with status ${String(last)}`);
}
X
cat >tests/client.test.ts <<'X'
import { describe, expect, it, vi } from "vitest";
import { statusOf } from "../src/client.ts";

describe("statusOf", () => {
  it("tries again after a failure", async () => {
    const fetch = vi
      .fn<(url: string) => Promise<{ ok: boolean; status: number }>>()
      .mockResolvedValueOnce({ ok: false, status: 503 })
      .mockResolvedValueOnce({ ok: true, status: 200 });
    await expect(statusOf("https://example.invalid", { fetch, retry: 2 })).resolves.toBe(200);
    expect(fetch).toHaveBeenCalledTimes(2);
  });

  it("names the last status when every try fails", async () => {
    const fetch = vi.fn<(url: string) => Promise<{ ok: boolean; status: number }>>(() =>
      Promise.resolve({ ok: false, status: 500 }),
    );
    await expect(statusOf("https://example.invalid", { fetch, retry: 1 })).rejects.toThrow(
      "status 500",
    );
  });
});
X
mise exec -- pnpm exec oxfmt src/client.ts tests/client.test.ts >/dev/null
