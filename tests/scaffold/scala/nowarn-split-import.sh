# expect: red No switched-off checks in the compiled code
# A two-selector import too long for one line: scalafmt puts each selector on its own line, so
# "nowarn as ..." starts a line with only spaces before it.
cat > src/main/scala/X.scala <<'X'
package sampletool

import scala.annotation.{nowarn as quietlyIgnoreEveryCompilerWarningInThisOneSmallFileOnlyPlease, tailrec}

/** x */
object X:
  @quietlyIgnoreEveryCompilerWarningInThisOneSmallFileOnlyPlease
  private def unused(): Int = 1

  /** The sum of 1 to n. */
  @tailrec
  def sum(n: Int, acc: Int = 0): Int = if n <= 0 then acc else sum(n - 1, acc + n)
X
scripts/format >/dev/null
grep -q '^  nowarn as quietly' src/main/scala/X.scala
