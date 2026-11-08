def encode(text: str) -> list[tuple[str, int]]:
    """Run-length encode a string: "aaab" -> [("a", 3), ("b", 1)]."""
    runs: list[tuple[str, int]] = []
    for ch in text:
        if runs and runs[-1][0] == ch:
            runs[-1] = (ch, runs[-1][1] + 1)
        else:
            runs.append((ch, 1))
    return runs


def decode(runs: list[tuple[str, int]]) -> str:
    return "".join(ch * n for ch, n in runs)
