# Assessment of the stacked-PR size rule

Researched 2026-11-21 to check the size limits in `skills/pull-request/STACKS.md`. The rule assessed
here had a cap of 7 layers. The adopted rule lowered it to 5, since the evidence below favours 7
over 5 nowhere and suggested 5 as the soft target for large work anyway. The large tier is
therefore ~600–1,500 lines, and "too big" starts past 5 x 300 lines. Every other number was kept
as assessed below.

**Bottom line:** keep every number. Make two changes: count lines more precisely, and add a guard on how widely a layer spreads across files. No study finds a threshold; size effects are gradual. The 200 and 300 figures match what convergent guidance recommends. The 600, 3, 7 and 2,100 figures are policy choices and should be labelled as such.

## 1. Each number against the evidence

| Number | Evidence | Strength | Verdict |
|---|---|---|---|
| **200 budget** | Google's SWE book says small changes are "about 200 lines" ([ch. 9](https://abseil.io/resources/swe-book/html/ch09.html)). Cisco/SmartBear advises "under 200, not to exceed 400", measured by defect density on 2,500 reviews (Cohen 2006, [SmartBear](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/), vendor data). Kemerer & Paulk derive about 200 LOC per inspection sitting ([TSE 2009](https://sites.pitt.edu/~ckemerer/PSP_Data.pdf)). On GitHub, 200 sits between p75 (101) and p90 (381) ([Kudrjavets, MSR 2022](https://arxiv.org/abs/2203.05045)). Real medians are 24–78 lines ([Sadowski 2018](https://storage.googleapis.com/gweb-research2023-media/pubtools/4476.pdf); [Rigby & Bird 2013](https://users.ece.utexas.edu/~miryung/teaching/EE379K-Spring2014/Papers/Paper%204.pdf)), so 200 is a ceiling, not a typical size. | Moderate. The sources converge, but on guidance and correlations, and the defect effect is a steady slope ([Kononenko 2015](https://plg.uwaterloo.ca/~migod/papers/2015/icsme15-OleksiiOlgaLatifa.pdf)). | **Keep** |
| **1.5x / 300 ceiling** | It falls inside Cohen's 100–300 "best advice" range and his 400-line / 90-minute limit. It is below Chromium's 500 including tests ([cl_tips](https://chromium.googlesource.com/chromium/src/+/HEAD/docs/cl_tips.md)), GitLab's 500 ([Danger config](https://gitlab.com/gitlab-org/ruby/gems/gitlab-dangerfiles/-/raw/master/lib/gitlab/dangerfiles/config.rb)) and Google's 1,000 "too large" ([eng-practices](https://google.github.io/eng-practices/review/developer/small-cls.html)). In a controlled experiment, effectiveness was the same (about 35%) at 233 and 490 presented LOC ([Baum, EMSE 2019](https://sback.it/publications/emse2019a.pdf)). | Moderate. Nothing shows 300 is worse than 200. | **Keep** as a hard cap |
| **600 focused threshold** | This is 3 x 200 by arithmetic. No source tests it. | None | **Evidence silent.** Keep it. |
| **3-PR target** | Gerrit relation chains have median depth 2, and Q3 is 4 or less in 12 of 14 repos ([Belhouchette, ESEM 2026](https://arxiv.org/html/2607.20189)). This describes practice, not an optimum. | Descriptive | **Keep** |
| **7 cap** | No stacking ecosystem sets a depth limit (Google, LLVM, GitHub, Gerrit, Phabricator). The kernel allows about 15 small patches per series ([netdev](https://docs.kernel.org/process/maintainer-netdev.html)). Stacks have measurable costs: problems in the base carry upward (ρ = 0.61), 33.5% of members are restructured during review, and middle layers are the slowest (ESEM 2026). In Firefox, larger stack size predicted slower acceptance and more regressions, with confounding ([Kucera 2026](https://arxiv.org/html/2601.01514v1)). | Weak, directional only | **Keep**, as a limit rather than a target (see the ladder) |
| **2,100 too-big** | This is 7 x 300. It roughly matches GitLab's "definitely too big" at 2,000. | None | **Evidence silent.** Keep it. |

## 2. What "changed lines" should count

- **Tests count.** Google says "CLs should include related test code", and Chromium's 500-line limit includes tests. Most empirical studies (Rigby, Baysal, Kononenko, Gousios) count added plus deleted lines with tests included. That is the same as `git diff --stat`, so the rule's 200 compares directly with their numbers. Chromium also accepts test-heavy changes, such as 200 production lines plus 600 test lines.
- **Edit deletions count; pure deletions are exempt.** Google counts deleting a whole file as about one line. Deletions had no significant effect on latency in [Yu et al. (MSR 2015)](https://cmustrudel.github.io/papers/msr15.pdf). Note that `--stat` counts a modified line twice, so 200 by `--stat` is roughly 100–200 modified lines. Kudrjavets and LinearB count a modification once, so their figures can come out up to 2x smaller.
- Generated files and lockfiles stay exempt ([GitLab #24541](https://gitlab.com/gitlab-org/gitlab/-/issues/24541)).

## 3. Engineering judgement (not evidence)

- **Prefer fewer, fuller layers.** Each layer pays a fixed wait. On Phabricator, 29–63% of a review's lifetime passes between acceptance and merge ([Kudrjavets 2203.05048](https://arxiv.org/abs/2203.05048)). Meanwhile 300 lines review no worse than 200. So grow layers toward 300 before adding a 6th or 7th.
- **Add a spread guard.** How widely a change spreads predicts misses better than its line count does. Each extra directory under review cut the odds of catching a security defect (OR 0.76, [Paul 2021](https://ar5iv.labs.arxiv.org/html/2102.06909)). Google warns about 200 lines spread over 50 files. Microsoft saw usefulness fall from about 20 files ([Czerwonka 2015](https://microsoft.com/en-us/research/wp-content/uploads/2015/05/PID3556473.pdf)), but that paper reports no method.
- **Keep the same reviewer across the stack.** Reviewers who had seen a file before were about twice as useful ([Bosu 2015](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/bosu2015useful.pdf)).
- **Every layer builds and passes tests, and moves go in a separate layer from edits** ([kernel](https://www.kernel.org/doc/html/latest/process/submitting-patches.html)). Do not split tightly coupled layers apart ([GitLab handbook](https://gitlab.com/gitlab-com/content-sites/handbook/-/raw/main/content/handbook/engineering/workflow/iteration.md)).
- **Splitting improves precision, not defect yield.** In an experiment, decomposing a change reduced false reports but did not find more defects ([di Biase 2019](https://arxiv.org/abs/1805.10978)). Justify the rule by reviewability.

## 4. Proposed ladder

1. **Budget:** about 200 changed lines (additions plus deletions, tests included). Exempt pure deletions, moves and generated files or lockfiles.
2. **Ceiling:** 300 lines, hard. A layer may go past it only with test code that belongs to it.
3. **Spread guard:** split any layer that touches more than about 20 files or several unrelated directories, whatever its line count.
4. **Focused (up to ~600 lines):** 1–3 PRs. This is unchanged, and the rule against splitting below the budget stays.
5. **Large (~600–2,100 lines):** prefer 5 layers or fewer, and grow layers toward 300 before adding a 6th or 7th. The cap stays at 7.
6. **Too big:** unchanged.
7. **All layers:** each builds and passes tests, and the same reviewer covers the whole stack.

## Myths to avoid citing

- SmartBear's claim of "70–90% defect discovery" cites no data.
- The supposed knees at about 180 and about 205 lines are bin boundaries, not fitted change points.
- The "2.6x slower chains" figure and the "5–20x CI" figure cannot be reproduced from the ESEM paper's own tables.
- The drop in Google's comment counts above 1,250 lines comes from generated code and deletions, not shallower review.
- "2k lines is skimming" is a Graphite opinion, not data.
- LinearB's tiers rank teams against each other; they are not quality thresholds.
- Miller's "7±2" is not a basis for the cap. [Cowan 2010](https://pmc.ncbi.nlm.nih.gov/articles/PMC2864034) puts working memory at 3–5 chunks, and it is only an analogy for stacks anyway.