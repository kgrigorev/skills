# expect: red Build and test
# scala.language renamed to a name past maxColumn. The compiler does not count it as a feature
# import, so the conversion still fails the build.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

import scala.{language as quietPleaseThisNameIsLongEnoughToPushTheImportLinePastTheMaximumColumnOfOneHundred}
import quietPleaseThisNameIsLongEnoughToPushTheImportLinePastTheMaximumColumnOfOneHundred.implicitConversions

/** x */
object X:
  given Conversion[String, Int] = _.length

  /** y */
  def n: Int = "abc"
EOF
scripts/format >/dev/null
