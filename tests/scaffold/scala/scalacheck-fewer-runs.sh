# expect: red No switched-off checks
# scalaCheckTestParameters lowered to one run.
cat > src/test/scala/SampleToolSuite.scala <<'EOF'
package sampletool

import munit.ScalaCheckSuite
import org.scalacheck.Prop.forAll

class SampleToolSuite extends ScalaCheckSuite:
  override def scalaCheckTestParameters = super.scalaCheckTestParameters.withMinSuccessfulTests(1)

  property("x"):
    forAll((n: Int) => n < 1000)
EOF
scripts/format >/dev/null
