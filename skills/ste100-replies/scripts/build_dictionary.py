#!/usr/bin/env python3
"""Build the STE dictionary files from the ASD-STE100 PDF.

Usage: build_dictionary.py <ASD-STE100.pdf> [--first N --last N] [--issue N]

The dictionary is a table with four columns: word (part of speech), approved
meaning or alternatives, STE example, non-STE example. `pdftotext -bbox-layout`
gives the position of each word. The script splits each text line where the
space between two words is wide, and puts each segment in the column whose
header is nearest to the left of the segment start.

Writes into the skill folder:
  references/dictionary.md           one line for each entry, for grep
  references/dictionary-examples.md  each entry with its notes and examples
  scripts/dictionary.json            word data for check_ste.py

Needs poppler (pdftotext). The defaults fit Issue 9 (pages 149 to 434).
"""
import argparse
import html
import json
import re
import subprocess
import sys
from pathlib import Path

SKILL = Path(__file__).resolve().parent.parent

HEADER_Y = 88          # page title and table header are above this
FOOTER_Y = 720         # page footer is below this
HEADERS = ("Word", "Approved", "STE", "Non-STE")
SEG_GAP = 8            # a wider space between two words starts a new segment
COL_SLACK = 12         # cell text can start a little left of its header
LINE = 13              # distance between two lines of one paragraph is about 12
NOTE_INDENT = 28       # column-2 notes are indented about 32 from the column edge
EDGE_CUT = 4           # a word that starts this close to a column header starts a new segment

POS = r"(?:n|v|adj|adv|prep|conj|pron|art|prefix|suffix|TN|TV)"
PAREN = r"(?: \((?:or )?[A-Za-z][A-Za-z' ]*\s*\))?"
HEAD_RE = re.compile(r"^(?P<word>[A-Za-z][A-Za-z'’.\-… ]*?" + PAREN + r")\s*\((?P<pos>" + POS + r")\)\s*,?\s*(?P<rest>.*)$")
POS_ONLY_RE = re.compile(r"^\(" + POS + r"\)$")
NUM_RE = re.compile(r"^(\d+|[a-z])\.$")
ALT_RE = re.compile(r"([A-Z][A-Z'’\-…]*(?: [A-Z][A-Z'’\-…]*)*) \((" + POS + r")\)")
LINE_RE = re.compile(r'<line xMin="[\d.]+" yMin="[\d.]+"[^>]*>(.*?)</line>', re.S)
WORD_RE = re.compile(r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="[\d.]+">([^<]*)</word>')


def join_text(parts):
    """Join wrapped lines. A line that ends with a hyphen joins with no space."""
    out = ""
    for p in parts:
        p = p.strip()
        if not p:
            continue
        if out.endswith("-") and len(out) > 1 and out[-2].isalpha():
            out += p
        else:
            out += (" " if out else "") + p
    return re.sub(r"\s+([.,:])(?=\s|$)", r"\1", out)


def page_segments(pdf, first, last):
    out = subprocess.run(["pdftotext", "-f", str(first), "-l", str(last), "-bbox-layout", pdf, "-"],
                         check=True, capture_output=True, text=True).stdout
    for pno, page in enumerate(out.split("<page ")[1:], start=first):
        segs, hdr = [], {}
        lines = [[(float(a), float(b), float(c), html.unescape(t)) for a, b, c, t in WORD_RE.findall(lm.group(1))]
                 for lm in LINE_RE.finditer(page)]
        for words in lines:
            for w in words:
                if w[1] < HEADER_Y and w[3] in HEADERS:
                    hdr.setdefault(w[3], w[0])
        # A segment also ends where a word starts at the next column edge, because
        # the space between two cells can be narrow.
        cut = [hdr[h] - EDGE_CUT for h in HEADERS[1:] if h in hdr]
        for words in lines:
            cur = []
            for w in words:
                crosses = cur and any(cur[0][0] < c <= w[0] for c in cut)
                if cur and (w[0] - cur[-1][2] > SEG_GAP or crosses):
                    segs.append(cur)
                    cur = []
                cur.append(w)
            if cur:
                segs.append(cur)
        body = [s for s in segs if HEADER_Y <= s[0][1] <= FOOTER_Y]
        text = " ".join(w[3] for s in body for w in s)
        if text.strip() in ("Blank Page", ""):
            continue
        if len(hdr) != len(HEADERS):
            sys.exit(f"page {pno}: table header not found")
        edges = [hdr[h] for h in HEADERS]
        result = []
        for s in body:
            x = s[0][0]
            col = max(i for i, e in enumerate(edges) if x >= e - COL_SLACK or i == 0)
            text = " ".join(w[3] for w in s)
            prev = result[-1] if result else None
            if prev and prev["col"] == col and abs(prev["y"] - s[0][1]) < 4 and POS_ONLY_RE.match(text):
                prev["t"] += " " + text      # "POSSIBLE" + "(adj)" split by a wide space
                continue
            result.append({"p": pno, "y": s[0][1], "x": x, "col": col, "t": text})
        # Indent is measured from the usual start of column-2 text on this page, not from the
        # header, because some pages (for example 336) start the text left of the header.
        xs = sorted(round(r["x"]) for r in result if r["col"] == 1)
        base = max(set(xs), key=xs.count) if xs else edges[1]
        for r in result:
            r["off"] = r["x"] - (base if r["col"] == 1 else edges[r["col"]])
        yield pno, result


def is_head(text):
    m = HEAD_RE.match(text)
    return (m.group("word").strip(), m.group("pos"), m.group("rest").strip()) if m else None


def col1_lines(segs):
    """Merge column-1 segments on one y, then join wrapped head words."""
    lines = []
    for s in sorted((s for s in segs if s["col"] == 0), key=lambda s: (s["y"], s["x"])):
        if lines and abs(lines[-1]["y"] - s["y"]) < 4:
            lines[-1]["t"] += " " + s["t"]
        else:
            lines.append(dict(s))
    out = []
    i = 0
    while i < len(lines):
        cur = dict(lines[i])
        while i + 1 < len(lines) and lines[i + 1]["y"] - cur.get("y_last", cur["y"]) < LINE + 2:
            nxt = lines[i + 1]
            if is_head(cur["t"]):
                break
            row_start = not out or cur["y"] - out[-1].get("y_last", out[-1]["y"]) > LINE + 2
            joined = join_text([cur["t"], nxt["t"]])
            first_part = nxt["t"].split("(")[0].strip()
            same_case = not first_part or cur["t"].isupper() == first_part.isupper()
            if cur["t"].endswith("-"):
                joined = cur["t"][:-1] + nxt["t"]   # line-break hyphen in a head word
                ok = is_head(joined) is not None
            elif nxt["t"].startswith("(") and not nxt["t"].startswith("(also"):
                ok = is_head(joined) is not None
            else:
                ok = row_start and same_case and is_head(joined) is not None and not cur["t"].endswith(",")
            if not ok:
                break
            cur["t"] = joined
            cur["y_last"] = nxt["y"]
            i += 1
        out.append(cur)
        i += 1
    return out


def parse(pdf, first, last):
    entries = []
    for pno, segs in page_segments(pdf, first, last):
        lines = col1_lines(segs)
        starts = []
        prev_y = None
        for ln in lines:
            h = is_head(ln["t"])
            gap = prev_y is None or ln["y"] - prev_y > LINE + 2
            bare = (not h and gap and starts and ln["off"] < 6
                    and re.match(r"^[A-Za-z][A-Za-z .'’]*$", ln["t"]) and not ln["t"].startswith("No other"))
            if h or bare:
                word, pos, rest = h if h else (ln["t"].strip(), "", "")
                starts.append(ln["y"])
                entries.append({"word": word, "pos": pos, "page": pno, "col1": [rest] if rest else [], "segs": []})
                ln["head"] = True
            prev_y = ln.get("y_last", ln["y"])
        n_new = len(starts)
        page_entries = entries[len(entries) - n_new:] if n_new else []

        def owner(y):
            idx = None
            for i, b in enumerate(starts):
                if y >= b - 6:
                    idx = i
            if idx is None:
                return entries[len(entries) - n_new - 1] if len(entries) > n_new else None
            return page_entries[idx]

        for ln in lines:
            if not ln.get("head"):
                e = owner(ln["y"])
                if e is not None:
                    e["col1"].append(ln["t"])
        for s in segs:
            if s["col"] == 0:
                continue
            e = owner(s["y"])
            if e is not None:
                e["segs"].append(s)
    return entries


def rows(entry):
    """Split an entry into rows: one for each meaning or alternative.

    A row starts at a column-2 segment at the column edge (or a number such as
    "1.") after a vertical space. Indented column-2 segments are notes of the
    row. Examples go to the row that is above them.
    """
    segs = sorted(entry["segs"], key=lambda s: (s["p"], s["y"], s["col"], s["x"]))
    c2 = [s for s in segs if s["col"] == 1]
    c3 = [s for s in segs if s["col"] == 2]
    ex_starts = [s for i, s in enumerate(c3)
                 if i == 0 or s["p"] != c3[i - 1]["p"] or s["y"] - c3[i - 1]["y"] > LINE + 3]
    starts = []
    last = None
    for s in c2:
        number = NUM_RE.match(s["t"])
        s["note"] = s["off"] >= NOTE_INDENT and not number
        if s["note"] and last is not None and not last["note"] and s["t"][:1].islower() \
                and s["p"] == last["p"] and s["y"] - last["y"] < LINE + 3:
            s["note"] = False             # wrapped meaning text at the note indent
        if s["note"]:
            gap = last is None or s["p"] != last["p"] or s["y"] - last["y"] > LINE + 3
            own_example = any(e["p"] == s["p"] and abs(e["y"] - s["y"]) < 6 for e in ex_starts)
            if gap and (own_example or not starts):
                starts.append({"p": s["p"], "y": s["y"], "num": None})
            last = s
            continue
        new = (last is None or s["p"] != last["p"] or s["y"] - last["y"] > LINE + 3 or number
               or (last["note"] and s["off"] < 6))
        if number and starts and starts[-1]["num"] is None and abs(s["y"] - starts[-1]["y"]) < LINE + 3:
            starts[-1]["num"] = s["t"]
            new = False
        if new:
            starts.append({"p": s["p"], "y": s["y"] - (6 if number else 0), "num": s["t"] if number else None})
        last = s
    if not starts:
        starts = [{"p": entry["page"], "y": -1, "num": None}]
    out = [{"text": [], "note": [], "ste": [], "non": []} for _ in starts]

    def idx(p, y):
        k = 0
        for i, st in enumerate(starts):
            if (p, y + 6) >= (st["p"], st["y"]):
                k = i
        return k

    for s in segs:
        k = idx(s["p"], s["y"])
        if s["col"] == 1:
            if NUM_RE.match(s["t"]):
                continue
            (out[k]["note"] if s.get("note") else out[k]["text"]).append(s)
        else:
            out[k]["ste" if s["col"] == 2 else "non"].append(s)
    result = []
    for st, r in zip(starts, out):
        result.append({
            "num": st["num"],
            "text": join_text(x["t"] for x in r["text"]),
            "note": join_text(x["t"] for x in r["note"]),
            "ste": split_examples(r["ste"]),
            "non": split_examples(r["non"]),
        })
    return [r for r in result if r["text"] or r["note"] or r["ste"] or r["non"]]


def split_examples(segs):
    """Join lines into examples. A vertical space between lines starts a new example."""
    out, cur, last = [], [], None
    for s in segs:
        if last is not None and (s["p"] != last["p"] or s["y"] - last["y"] > LINE + 3):
            out.append(join_text(cur))
            cur = []
        cur.append(s["t"])
        last = s
    if cur:
        out.append(join_text(cur))
    return [o for o in out if o]


def row_text(r):
    t = (r["num"] + " " if r["num"] else "") + r["text"]
    return (t + (f" [{r['note']}]" if r["note"] else "")).strip()


def build(entries):
    data = {}
    heads = {e["word"].lower() for e in entries}

    def unbreak(t):
        # "ELECTROMAG-NETICALLY": a line-break hyphen inside a head word of the dictionary.
        return re.sub(r"\b([A-Za-z]+)-([A-Za-z]+)\b",
                      lambda m: m.group(1) + m.group(2) if (m.group(1) + m.group(2)).lower() in heads
                      and m.group(0).lower() not in heads else m.group(0), t)

    for e in entries:
        e["approved"] = e["word"] == e["word"].upper() and any(ch.isalpha() for ch in e["word"])
        e["rows"] = rows(e)
        for r in e["rows"]:
            r["ste"] = [unbreak(x) for x in r["ste"]]
            r["non"] = [unbreak(x) for x in r["non"]]
            r["text"] = unbreak(r["text"])
        note = join_text(e["col1"])
        forms = [e["word"]]
        if e["approved"]:
            found = [f for f in re.findall(r"[A-Z][A-Z'’\-]+", re.sub(r"\(also |No other.*", " ", note))
                     if f not in ("TN", "TV")]
            n = len(e["word"].split())    # COME ON: "COMES ON, CAME ON" is two forms of two words
            if n > 1 and len(found) % n == 0:
                found = [" ".join(found[i:i + n]) for i in range(0, len(found), n)]
            forms += found
        e["forms"] = forms
        e["alternatives"] = [] if e["approved"] else sorted(
            {f"{a} ({p})" for r in e["rows"] for a, p in ALT_RE.findall(r["text"])})
        e["use"] = " | ".join(row_text(r) for r in e["rows"] if row_text(r))
        data.setdefault(e["word"].lower(), []).append({
            "pos": e["pos"], "approved": e["approved"], "forms": [f.lower() for f in forms],
            "alternatives": e["alternatives"], "use": e["use"], "page": e["page"]})
    return data


def write(entries, data, issue):
    ref = SKILL / "references"
    ref.mkdir(exist_ok=True)
    n_ok = sum(1 for e in entries if e["approved"])
    stamp = f"<!-- Generated by scripts/build_dictionary.py from ASD-STE100 Issue {issue}. Do not edit. -->"
    head = (stamp + "\n"
            "# STE dictionary\n\n"
            f"{n_ok} approved entries (UPPER CASE) and {len(entries) - n_ok} entries that are not approved "
            "(lower case). Grep for `^word (` or `^WORD (`. Do not read the whole file.\n\n"
            "Format: `WORD (pos) [forms and notes]: approved meaning` or "
            "`word (pos) -> ALTERNATIVE (pos) | ...`. Text in [ ] after a meaning is a note of the dictionary.\n"
            "Examples for each entry: dictionary-examples.md.\n\n")
    lines = []
    for e in entries:
        pos = f" ({e['pos']})" if e["pos"] else ""
        if e["approved"]:
            note = join_text(e["col1"])
            lines.append(f"{e['word']}{pos}{f' [{note}]' if note else ''}: {e['use']}")
        else:
            lines.append(f"{e['word']}{pos} -> {e['use']}")
    (ref / "dictionary.md").write_text(head + "\n".join(lines) + "\n")

    ex = [stamp,
          "# STE dictionary with examples", "",
          "Grep for `^## word (`. Each entry: forms, then each meaning or alternative with its notes, "
          "STE examples and non-STE examples. The page is the PDF page.", ""]
    for e in entries:
        pos = f" ({e['pos']})" if e["pos"] else ""
        ex.append(f"## {e['word']}{pos}{' — approved' if e['approved'] else ''} (p. {e['page']})")
        note = join_text(e["col1"])
        if note:
            ex.append(f"Forms/notes: {note}")
        for r in e["rows"]:
            t = ((r["num"] + " ") if r["num"] else "") + r["text"]
            if t.strip():
                ex.append(f"- {t.strip()}")
                if r["note"]:
                    ex.append(f"  - Note: {r['note']}")
            elif r["note"]:
                ex.append(f"- Note: {r['note']}")
            for s in r["ste"]:
                ex.append(f"  - STE: {s}")
            for s in r["non"]:
                ex.append(f"  - Non-STE: {s}")
        ex.append("")
    (ref / "dictionary-examples.md").write_text("\n".join(ex))
    (SKILL / "scripts" / "dictionary.json").write_text(json.dumps(data, indent=1, sort_keys=True) + "\n")
    return n_ok, len(entries) - n_ok


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf")
    ap.add_argument("--first", type=int, default=149)
    ap.add_argument("--last", type=int, default=434)
    ap.add_argument("--issue", default="9", help="issue number of the standard, for the generated headers")
    a = ap.parse_args()
    entries = parse(a.pdf, a.first, a.last)
    n_ok, n_no = write(entries, build(entries), a.issue)
    print(f"approved: {n_ok}, not approved: {n_no}, total: {n_ok + n_no}", file=sys.stderr)


if __name__ == "__main__":
    main()
