# expect: red No switched-off checks
# scala.language renamed to a name past maxColumn.
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
mise exec -- scala-cli fmt project.scala src >/dev/null
