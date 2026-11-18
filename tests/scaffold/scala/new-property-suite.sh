# expect: green
# A new property test file with its own fixed seed.
cat > src/test/scala/GreetPropertySuite.scala <<'EOF'
package sampletool

import munit.ScalaCheckSuite
import org.scalacheck.Gen
import org.scalacheck.Prop.forAll

class GreetPropertySuite extends ScalaCheckSuite:

  override def scalaCheckInitialSeed: String = "TO7zgUWdv-WPJuetViT8r85tY3TprSjGhdyoESCTTkI="

  property("a greeting always ends with an exclamation mark"):
    forAll((name: String) => SampleTool.greet(name).endsWith("!"))

  property("names made of letters appear in the greeting unchanged"):
    forAll(Gen.alphaStr.suchThat(_.nonEmpty)) { name =>
      SampleTool.greet(name) == s"Hello, $name!"
    }
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
