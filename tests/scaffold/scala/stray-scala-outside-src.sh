# expect: red Sources only in src/
# A .scala file outside src/, which Scala CLI does not compile and the scans skip.
mkdir -p lib
printf 'package sampletool\nobject L:\n  var x = 1\n' > lib/L.scala
