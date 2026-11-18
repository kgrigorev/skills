# expect: red No switched-off checks
# nowarn renamed to a name long enough to push the import past maxColumn.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

import scala.annotation.{nowarn as quietPleaseThisNameIsLongEnoughToPushTheImportLinePastTheMaximumColumnOfOneHundred}

/** x */
object X:
  @quietPleaseThisNameIsLongEnoughToPushTheImportLinePastTheMaximumColumnOfOneHundred
  private def unused(): Int = 1

  /** y */
  def y: Int = 2
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
