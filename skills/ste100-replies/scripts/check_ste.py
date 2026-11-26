#!/usr/bin/env python3
"""Check prose against ASD-STE100 Issue 9 rules. Heuristic, not a parser.

Usage: check_ste.py [FILE | -] [--notes]

Reads Markdown or plain text. Skips fenced code blocks, inline code, quoted
text, URLs and block quotes. Reports, with the line number and the rule:
  - sentences above 20 words (instructions) or 25 words (descriptions)
  - paragraphs with more than 6 sentences
  - possible passive voice and complex verb tenses
  - "-ing" forms that are not approved words or technical names
  - words that are not in the dictionary or in references/technical-names.md
  - semicolons, contractions, possible noun clusters, inline lists of 3+ items
Two kinds of result are notes, not findings: [1.2] words that the dictionary
approves only as one part of speech, and [1.5] proposed technical names (also
the terms of "Proposed technical name: <term> (noun|verb)" lines in the text).
Notes do not change the exit code. --notes prints them. The last line counts both.
Exit code: 0 if there are no findings, 1 if there are findings, 2 if the call is wrong.
"""
import argparse
import json
import re
import sys
from pathlib import Path

SKILL = Path(__file__).resolve().parent.parent
DICT = json.loads((SKILL / "scripts" / "dictionary.json").read_text())
TN_FILE = SKILL / "references" / "technical-names.md"

BE = {"is", "are", "was", "were", "be", "been", "being"}
HAVE = {"has", "have", "had"}
FUNCTION_POS = {"art", "prep", "conj", "pron", "adv", "v"}
UNITS = {"ms", "s", "sec", "seconds", "second", "min", "minutes", "minute", "h", "hours", "hour", "days", "day",
         "kb", "mb", "gb", "tb", "b", "bytes", "%", "px", "mhz", "ghz", "k", "m"}


def plural(w):
    if re.search(r"[^aeiou]y$", w):
        return {w + "s", w[:-1] + "ies"}
    if re.search(r"(s|x|z|ch|sh)$", w):
        return {w + "es"}
    return {w + "s"}


def load_dictionary():
    approved, approved_pos, not_approved = set(), {}, {}
    for key, entries in DICT.items():
        for e in entries:
            words = [key] + e["forms"]
            if e["approved"]:
                for w in words:
                    for part in re.split(r"[\s]+", re.sub(r"\(.*?\)", "", w)):
                        part = part.strip(",.").replace("’", "'")
                        if part:
                            approved.add(part)
                            approved_pos.setdefault(part, set()).add(e["pos"])
                if e["pos"] == "n":
                    approved |= plural(key)
            else:
                base = re.sub(r"\s*\(.*?\)", "", key).strip()
                not_approved.setdefault(base, []).append((e["pos"], e.get("use") or ", ".join(e["alternatives"])))
    return approved, approved_pos, not_approved


class Names:
    """Technical names. status maps each form to 'approved' or 'proposed'."""

    def __init__(self):
        self.status, self.nouns, self.verbs = {}, set(), set()

    def add(self, term, is_verb, status):
        forms = {term} | plural(term)
        if is_verb:
            forms |= {term + "d", term + "ed", term[:-1] + "ied"}
        for f in forms:
            self.status.setdefault(f, status)
        (self.verbs if is_verb else self.nouns).update(forms)


def load_technical_names():
    """Read lines like '- term' or '- term (proposed)' of the sections about technical names."""
    names, section = Names(), ""
    if not TN_FILE.exists():
        return names
    for line in TN_FILE.read_text().splitlines():
        if line.startswith("## "):
            section = line.lower()
        m = re.match(r"^- ([^(:]+?)\s*(\((proposed)\))?\s*(:.*)?$", line)
        if m and "technical" in section:
            status = "proposed" if m.group(3) or "proposed" in section else "approved"
            names.add(m.group(1).strip().lower(), "verb" in section, status)
    return names


APPROVED, APPROVED_POS, NOT_APPROVED = load_dictionary()
# Past participles: the 4th form of the approved verbs that have 4 forms (break, broken).
PARTICIPLES = {e["forms"][3] for es in DICT.values() for e in es
               if e["approved"] and e["pos"] == "v" and len(e["forms"]) == 4}


ITEM = r"^\s*([-*+]|\d+[.)]|[a-z][.)])\s+"
QUOTED = re.compile(r"[“\"][^”\"]*[”\"]")


PROPOSED_LINE = re.compile(r"^\s*(?:[-*+]\s+)?Proposed technical name:\s*`?([^`(\n]+?)`?\s*\((noun|verb)\b[^)]*\)", re.I)


def proposed_names(text):
    """Terms of "Proposed technical name: <term> (noun|verb)" lines outside code blocks."""
    in_code = False
    for line in text.splitlines():
        if re.match(r"^\s*(```|~~~)", line):
            in_code = not in_code
        elif not in_code and (m := PROPOSED_LINE.match(line)):
            yield m.group(1).strip().lower(), m.group(2).lower() == "verb"


def strip_markdown(text):
    """Return a list of (line_no, kind, text). kind: para, item, cont, head, table, blank.
    cont is an indented line that continues the item above."""
    out, in_code, prev = [], False, "blank"

    def put(no, kind, s=""):
        nonlocal prev
        out.append((no, kind, s.strip()))
        prev = kind

    for no, line in enumerate(text.splitlines(), 1):
        s = line.rstrip()
        is_item = re.match(ITEM, s)
        if re.match(r"^\s*(```|~~~)", line):
            in_code = not in_code
            put(no, "blank")
        elif in_code or PROPOSED_LINE.match(line):
            put(no, "blank")
        elif not s.strip() or s.lstrip().startswith(">") or re.match(r"^\s*([-*_]\s*){3,}$", s):
            put(no, "blank")
        elif prev in ("item", "cont") and re.match(r"^\s", s) and not is_item \
                and not re.match(r"^\s*(#{1,6}\s|\|)", s):
            put(no, "cont", clean(s))
        elif re.match(r"^( {4,}|\t)\S", line) and not is_item:
            put(no, "blank")  # indented code
        elif re.match(r"^\s*#{1,6}\s", s):
            put(no, "head", clean(re.sub(r"^\s*#+\s*", "", s)))
        elif re.match(r"^\s*\|", s):
            if re.match(r"^[\s|:-]+$", s):
                put(no, "blank")
            else:
                put(no, "table", clean(re.sub(r"\|", " . ", s)))
        elif is_item:
            put(no, "item", clean(re.sub(ITEM, "", s), no))
        else:
            put(no, "para", clean(s, no))
    return out


def clean(s, no=0):
    # Conventional commit prefix: type(scope): summary
    s = re.sub(r"^[a-z]+(\([^)]*\))?!?:\s+", "", s) if no == 1 else s
    s = re.sub(r"`[^`]*`", " CODE ", s)
    s = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", s)
    s = re.sub(r"https?://\S+", " CODE ", s)
    return re.sub(r"(\*\*|__|\*|_)(\S.*?\S|\S)\1", r"\2", s)


def blocks(lines):
    """Join para lines into paragraphs, and an item with its cont lines.
    Yield (kind, text, marks). marks is a list of (offset in text, line_no), one for each joined line."""
    cur = None
    for no, kind, s in lines:
        if cur and (kind == cur[0] == "para" or kind == "cont" and cur[0] == "item"):
            cur[2].append((len(cur[1]) + 1, no))
            cur[1] += " " + s
            continue
        if cur:
            yield cur
        cur = [kind if kind != "cont" else "item", s, [(0, no)]] if kind != "blank" else None
    if cur:
        yield cur


def line_at(marks, pos):
    return [no for off, no in marks if off <= pos][-1]


ABBREV = r"\b(?:e\.g|i\.e|etc|vs|No|approx|a\.m|p\.m)\."


def sentences(text):
    """Yield (offset, sentence)."""
    text = re.sub(ABBREV, lambda m: m.group(0).replace(".", "§"), text)  # same length: offsets stay
    start = 0
    for m in list(re.finditer(r"(?<=[.!?:])\s+(?=[\"“(A-Z0-9])", text)) + [re.search(r"$", text)]:
        part = text[start:m.start()]
        if part.strip():
            yield start, part.replace("§", ".").strip()
        start = m.end()


def tokens(sentence):
    """Words for counting (rule 8). Quoted text and parentheses count as one word."""
    s = QUOTED.sub(" QUOTED ", sentence)
    s = re.sub(r"\([^()]*\)", " PAREN ", s)
    raw = re.findall(r"[A-Za-z0-9][A-Za-z0-9'’./_\-+#%]*", s)
    out = []
    for w in raw:
        w = w.rstrip(".'’")
        if out and out[-1][0].isdigit() and w.lower() in UNITS:
            continue  # number with unit = one word (rule 8.6)
        out.append(w)
    return out


def is_instruction(sentence, toks, names):
    words = [t.lower() for t in toks]
    if not words:
        return False
    first = words[0]
    if first in ("if", "when", "before", "after", "while", "until") and "," in sentence:
        rest = sentence.split(",", 1)[1]
        words = [t.lower() for t in tokens(rest)] or words
        first = words[0] if words else first
    if first == "do" and len(words) > 1 and words[1] == "not":
        return True
    return "v" in APPROVED_POS.get(first, set()) or first in names.verbs


NUMBER_WORDS = set("""zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen
fifteen sixteen seventeen eighteen nineteen twenty thirty forty fifty sixty seventy eighty ninety hundred
thousand million first second third fourth fifth sixth seventh eighth ninth tenth half""".split())


def skip_word(w, idx, names):
    if w in ("CODE", "QUOTED", "PAREN"):
        return True
    if re.search(r"[0-9_/.#+%]", w) or re.match(r"^[A-Z0-9][A-Z0-9\-]+s?$", w):
        return True  # identifiers, numbers, abbreviations
    lw = w.lower()
    # Proper nouns and product names. A word at the start of a sentence counts as one
    # only if it is not a known word and not an -ing or -ly form.
    return w[0].isupper() and (idx > 0 or not (
        lw in APPROVED or lw in NOT_APPROVED or lw in names.status or lw.endswith(("ing", "ly"))))


CONTRACTION = re.compile(r"\b\w+(?:n['’]t|['’](?:re|ve|ll|d|m))\b|\b(?:it|that|there|what|let|here)['’]s\b", re.I)
LATIN = re.compile(r"\b(?:e\.g\.|i\.e\.|etc\.|vs\.|cf\.|viz\.)", re.I)


def check(text):
    """Return (line_no, rule, message, snippet). The rules 1.2 and 1.5 are notes."""
    findings = []
    names = load_technical_names()
    for term, verb in proposed_names(text):
        names.add(term, verb, "proposed")

    def add(no, rule, msg, snippet):
        findings.append((no, rule, msg, snippet[:90]))

    for kind, block, marks in blocks(strip_markdown(text)):
        sents = list(sentences(block))
        plain = QUOTED.sub(lambda m: " " * len(m.group(0)), block)  # quoted text stays as it is
        for rule, regex, msg in (("8.1", re.compile(";"), "semicolon: write two sentences"),
                                 ("4.2", CONTRACTION, "contraction '{}': write the full words"),
                                 ("GR-6", LATIN, "Latin abbreviation '{}': write 'for example', 'that is' or the full list")):
            for m in regex.finditer(plain):
                sentence = [t for start, t in sents if start <= m.start()][-1]
                add(line_at(marks, m.start()), rule, msg.format(m.group(0)), sentence)
        if kind == "para" and len(sents) > 6:
            add(marks[0][1], "6.6", f"paragraph has {len(sents)} sentences (max 6)", block)
        for start, s in sents:
            no = line_at(marks, start)
            toks = tokens(s)
            if kind not in ("head", "table"):
                instr = is_instruction(s, toks, names)
                limit = 20 if instr else 25
                if len(toks) > limit:
                    add(no, "5.1" if instr else "6.3",
                        f"{'instruction' if instr else 'description'} has {len(toks)} words (max {limit})", s)
                for p in re.findall(r"\(([^()]*)\)", s):
                    if len(tokens(p)) > 25:
                        add(no, "8.5", f"text in parentheses has {len(tokens(p))} words", p)
                if re.search(r"\w+, \w[^,]*, (?:and|or) \w", s) and s.count(",") >= 2:
                    add(no, "4.3", "inline list of 3 or more items: use a vertical list", s)
            check_words(no, s, toks, add, names)
    return sorted(findings, key=lambda f: f[0])


def check_words(no, s, toks, add, names):
    low = [t.lower().replace("’", "'") for t in toks]
    # Technical-name phrases: their words are accepted. A proposed phrase is one note.
    joined = " " + " ".join(low) + " "
    covered = set()
    for ph in sorted((t for t in names.status if " " in t), key=len, reverse=True):
        for m in re.finditer(r"(?<= )" + re.escape(ph) + r"(?= )", joined):
            start = joined[:m.start()].count(" ") - 1
            if covered.isdisjoint(range(start, start + ph.count(" ") + 1)) and names.status[ph] == "proposed":
                add(no, "1.5", f"'{ph}' is a proposed technical name (not approved yet)", s)
            covered |= set(range(start, start + ph.count(" ") + 1))
    seen = set()
    for i, (w, lw) in enumerate(zip(toks, low)):
        if i in covered or skip_word(w, i, names) or re.search(r"['’](t|re|ve|ll|d|m|s)$", lw):
            continue
        base = lw.split("-") if "-" in lw and lw not in APPROVED and lw not in names.status else [lw]
        for part in base:
            if not part or part in seen or part in NUMBER_WORDS:
                continue  # numbers count as technical nouns (rule 1.5, category 9)
            seen.add(part)
            if part in APPROVED:
                if part in NOT_APPROVED:
                    alts = "; ".join(f"as {p}: {a[:80]}" for p, a in NOT_APPROVED[part])
                    add(no, "1.2", f"'{part}' approved only as {'/'.join(sorted(APPROVED_POS[part]))}. Not approved {alts}", s)
            elif part in names.status:
                if names.status[part] == "proposed":
                    add(no, "1.5", f"'{part}' is a proposed technical name (not approved yet)", s)
            elif part in NOT_APPROVED:
                alts = "; ".join(f"({p}) -> {a[:80]}" for p, a in NOT_APPROVED[part])
                add(no, "1.1", f"'{part}' is not approved: {alts}", s)
            elif part.endswith("ing") and len(part) > 4 and not part.endswith("thing"):
                add(no, "3.5", f"'-ing' form '{part}': use an approved form (technical nouns only)", s)
            else:
                add(no, "1.1", f"'{part}' is not in the dictionary or technical names", s)

    # Passive voice and complex tenses.
    for i in range(len(low) - 1):
        j = i + 1
        while j < len(low) and (low[j] in ("not", "also", "then", "now", "all") or low[j].endswith("ly")):
            j += 1
        if j >= len(low):
            break
        nxt = low[j]
        participle = nxt.endswith("ed") or nxt in PARTICIPLES
        if low[i] in BE and participle and nxt not in ("need", "red", "bed", "shed"):
            agent = " by " in " " + " ".join(low[j:]) + " "
            add(no, "3.6", f"possible passive '{low[i]} {nxt}'{' with agent (by ...)' if agent else ''}: "
                "use active voice unless it is a past participle used as an adjective (3.3)", s)
        if low[i] in HAVE and participle:
            add(no, "3.2", f"perfect tense '{low[i]} {nxt}': use simple past or present", s)
    # Noun clusters: 4+ consecutive words that are only nouns or adjectives.
    run = []
    for w, lw in zip(toks + ["."], low + ["."]):
        unknown = lw not in APPROVED_POS and lw not in names.verbs and lw not in NOT_APPROVED \
            and re.match(r"^[a-z][a-z\-]*$", lw) and not re.search(r"(ly|ed|ing)$", lw)
        if w in ("CODE", "QUOTED", "PAREN"):
            nounish = False
        else:
            nounish = (lw in names.nouns and lw not in APPROVED_POS) or (
            lw in APPROVED_POS and not (APPROVED_POS[lw] & FUNCTION_POS)) or unknown or (
            w[:1].isupper() and len(run) > 0)
        if nounish and lw not in ("a", "an", "the"):
            run.append(w)
        else:
            if len(run) > 3:
                add(no, "2.1", f"possible noun cluster of {len(run)} words: '{' '.join(run)}'", s)
            run = []



def main():
    ap = argparse.ArgumentParser(allow_abbrev=False, description="Check prose against ASD-STE100 Issue 9 rules.")
    ap.add_argument("file", nargs="?", default="-", metavar="FILE", help="Markdown or text file, - for stdin")
    ap.add_argument("--notes", action="store_true", help="print the notes [1.2] and [1.5]")
    a = ap.parse_args()
    try:
        text = sys.stdin.read() if a.file == "-" else Path(a.file).read_text()
    except (OSError, UnicodeDecodeError) as e:
        reason = e.strerror if isinstance(e, OSError) else "not UTF-8 text"
        print(f"cannot read {a.file}: {reason}", file=sys.stderr)
        sys.exit(2)  # exit code 1 means findings
    findings = check(text)
    errors = [f for f in findings if f[1] not in ("1.2", "1.5")]
    for no, rule, msg, snip in (findings if a.notes else errors):
        print(f"L{no} [{rule}] {msg}\n    > {snip}")
    print(f"\n{len(errors)} findings, {len(findings) - len(errors)} notes")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
