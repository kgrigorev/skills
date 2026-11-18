# expect: red No switched-off checks
# A plain ScalaCheck Properties object, which munit never runs.
printf 'package sampletool\n\nimport org.scalacheck.Prop.forAll\nimport org.scalacheck.Properties\n\nobject Props extends Properties("p"):\n  property("never") = forAll((i: Int) => i != i)\n' > src/test/scala/Props.scala
