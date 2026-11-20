# expect: red No switched-off checks in the compiled code
# munit.Fail imported in a selector list long enough that scalafmt splits it over lines, so the
# "Fail" line has no "import" or "munit" on it. ".tag" is taken as a function value, so no
# ".tag(" appears. A broken test then passes as an expected failure.
cat > src/test/scala/ParserSuite.scala <<'X'
package sampletool

import munit.{Fail as ExpectedToBreakUntilTheUpstreamParserIsFixedNextWeekSeeTheTrackerIssue, FunSuite}

class ParserSuite extends FunSuite:
  private val parses = "parses".tag

  test(parses(ExpectedToBreakUntilTheUpstreamParserIsFixedNextWeekSeeTheTrackerIssue)):
    assertEquals(SampleTool.greet("a"), "nope")
X
scripts/format >/dev/null
grep -q '^  Fail as Expected' src/test/scala/ParserSuite.scala
