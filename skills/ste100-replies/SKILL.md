---
name: ste100-replies
description: Write prose in ASD-STE100 Simplified Technical English (Issue 9). Use it only when the user or their CLAUDE.md asks for STE or Simplified Technical English. Then use it for all prose in that session.
---

# STE100 replies

Write every sentence for the user in Simplified Technical English (STE), ASD-STE100 Issue 9. STE gives
a controlled vocabulary and 53 writing rules. The result is text that a non-native reader can read
quickly and that has only one meaning.

## Scope

STE applies to all prose:

- Chat replies, explanations, plans, status tables and summaries
- Commit messages, merge request titles and descriptions, review comments
- Code comments and documentation

These stay as they are, and each one counts as one word (rule 8.6):

- Code blocks, inline code, commands, file paths and identifiers
- Log text, error text and quoted text
- Product names and other proper nouns (Payment Service, GitLab, TargetProcess)
- The `type(scope):` prefix of a commit message (conventional commits)

## Workflow for each reply

1. Write in STE from the first draft. A translation of a finished non-STE draft takes longer and gives worse text.
2. For each sentence, decide the type. An instruction tells the reader to do something (procedural writing,
   20 words maximum). A description gives information (descriptive writing, 25 words maximum).
3. If you are not sure about a word, grep the dictionary: `grep -i -E '^word \(' references/dictionary.md`.
   An UPPER CASE entry is approved, with only the meaning and part of speech given. A lower-case entry is
   not approved, and the line gives the alternatives.
4. If the word is a software term, look in `references/technical-names.md`. If the term is not there,
   use dictionary words. If no dictionary word is sufficient, use the term and add one line at the end of
   the chat reply: "Proposed technical name: <term> (noun or verb)". Put this line only in chat, not in commit,
   merge request or code text. If the user approves the term, add it to `references/technical-names.md`.
5. Examine the reply against the checklist below before you send it.
6. Run the checker if the reply has more than about 150 words of prose, or if it is a commit message,
   a merge request text, a code comment block or a document:
   `python3 scripts/check_ste.py <file>` (or `-` for stdin). Correct each finding.
   The checker is heuristic. If a finding is incorrect (for example, a past participle that is an
   adjective), keep the text. Proposed technical names are notes, not findings (`--notes` shows them).

## Checklist (rule numbers from references/rules.md)

Words:

- Use only approved words, with their approved meaning and part of speech (1.1 to 1.3), or technical
  names (1.5, 1.12). Use a technical noun only as a noun and a technical verb only as a verb (1.7, 1.13).
- Use one term for one item, and keep key words the same in all of the text (1.11, 6.2, 9.4). If a
  technical noun has more than three words, write it in full one time, then use a shorter form (2.2).
- Do not use slang or jargon (1.10), phrasal verbs (9.3), or Latin abbreviations such as "e.g." (GR-6).
- Use American spelling (1.14). Write "make sure that", not "make sure" (GR-1).

Verbs:

- Use only these forms: infinitive, imperative, simple present, simple past, simple future, and the past
  participle as an adjective (3.2, 3.3). Do not write "has done", "is doing" or "would do" (3.4).
- Use the "-ing" form only in a technical noun ("air-conditioning system") or an approved
  word such as "during" or "missing" (3.5).
- Use the active voice. In descriptive writing, you can use the passive only when the agent is unknown (3.6).
- Use a verb for an action, not a noun: "examine the logs", not "do an examination of the logs" (3.7).

Sentences and paragraphs:

- Write one topic in a sentence (4.1). Do not omit words and do not use contractions (4.2).
- Use "the", "a", "an", "this" or "these" before a noun when applicable (4.5).
- Use connecting words such as "but", "then" and "thus" to connect related sentences (4.4).
- Put 3 or more items in a vertical list (4.3). The limit of 3 items is a rule of this skill, not of STE.
  End the sentence before the list with a colon.
- Descriptions: start each paragraph with a topic sentence. Write one topic in a paragraph and a maximum of
  6 sentences (6.4 to 6.6). Do not use the imperative in descriptive writing.

Instructions:

- Use the imperative. Write one instruction in a sentence, unless the actions occur at the same time (5.2, 5.3).
- If the reader must know a condition first, start with it and use a comma: "If the job fails, ..." (5.4).
- Use a note only to give information, not an instruction (5.5).
- Put a warning or caution before the step that it applies to (a rule of this skill). Use WARNING for a risk to persons and
  CAUTION for a risk to data or equipment. Start with the command, then give the risk (7.1 to 7.3).

Punctuation: do not use the semicolon (8.1). Use parentheses only for the 7 uses in rule 8.3.

## Software prose

- "I" is not in the dictionary, and "WE" is only the organization that writes the document. Make the
  item the subject: "The change adds a lock." If the actor is important, name the component, the job or
  the role of the person ("the job", "the reviewer").
- "YOU" is the reader. Write "you" for the user.
- Frequent words that are not approved, with approved words to use:

| Not approved | Use |
|---|---|
| fix (v) | CORRECT (v), REPAIR (v) |
| check (v), ensure, verify | MAKE SURE THAT, EXAMINE (v), DO A CHECK |
| need (v) | MUST (v), NECESSARY (adj) |
| should, would, could, may | MUST, CAN, POSSIBLY |
| happen | OCCUR (v) |
| fail (v) | IF ... NOT, UNSATISFACTORY (adj), "failure" as a technical noun |
| allow, enable | LET (v) (but "enable" is a technical verb for a setting) |
| avoid | PREVENT (v), DO NOT |
| explain, mention, describe | TELL (v), GIVE (v) |
| now, already, just, still | AT THIS TIME, (omit), IMMEDIATELY, CONTINUE (v) |
| every, both, several, few | ALL, EACH, THE TWO, SOME, or the number |
| wrong, old, following | INCORRECT, PREVIOUS, THESE or "that follows" |
| however, due to, via, whether | BUT, BECAUSE OF, THROUGH, IF |

- Commit messages and merge request text: obey the rules of the repository.
  STE adds a limit of 20 words for the summary, and descriptive writing for the body.

## Examples

**1. Bug explanation (descriptive writing)**

Before: The export job was failing because orders were being marked as exported before they'd been sent; this meant they were never retried.

After: The export job sets the "exported" flag before it sends the order. If the send operation is not
satisfactory, the job does not try to send the order again.

**2. Setup step with a caution**

Before: Copy .env.example to .env and run make migrate, but double-check DATABASE_URL first since it'll wipe the DB if it points at staging.

After:

1. Copy `.env.example` to `.env`.
2. CAUTION: Make sure that `DATABASE_URL` identifies your local database. If it identifies the `preprod` database, `make migrate` deletes the `preprod` data.
3. Start `make migrate`.

**3. Word choice and technical verbs**

Before: You should make sure the cache gets invalidated once the fix is deployed, otherwise users might still be seeing old prices.

After: After you deploy the correction, invalidate the cache. If you do not invalidate the cache, the
users can see the previous prices.

**4. First person, perfect tense and a noun cluster**

Before: I've updated the payment service retry timeout configuration value to 30s.

After: The change sets the timeout to 30 s for each request that the Payment Service tries again.

**5. Review summary**

Before: Looks mostly good, but there are a few issues: the error from PendingOrders gets swallowed, MarkExported is called even when sending failed, and the sleep isn't respecting ctx cancellation.

After: The change has these problems:

- If `PendingOrders` gives an error 5 times, the job gives nil as the result. Thus, the job does not show the error.
- The job uses `MarkExported` also when `Send` gives an error 5 times.
- `time.Sleep` does not stop when the context is canceled.

## References

- `references/rules.md`: all 53 rules and GR-1 to GR-8, with explanations and examples. Grep `^### Rule 5.4`.
- `references/dictionary.md`: one line for each dictionary entry. Grep, do not read all of it.
- `references/dictionary-examples.md`: the same entries with STE and non-STE examples.
- `references/introduction.md`: what STE is, the Issue 9 changes, how to read the dictionary, the list of recurring errors and the approved verbs.
- `references/technical-names.md`: technical nouns and technical verbs for software work.
- `scripts/build_dictionary.py <pdf>`: makes the dictionary files again from a new issue of the standard.
