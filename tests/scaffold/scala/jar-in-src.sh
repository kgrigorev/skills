# expect: red Build and test
# A prebuilt .jar in src/ is not put on the classpath.
mkdir -p jarbuild
printf 'package hidden\nobject Hidden:\n  var value: Int = 1\n' > jarbuild/H.scala
mise exec -- scala-cli --power package jarbuild/H.scala --library -o src/main/scala/hidden.jar --server=false >/dev/null 2>&1
rm -rf jarbuild
test -f src/main/scala/hidden.jar
printf 'package sampletool\n\n/** u */\nobject Uses:\n  /** y */\n  def y: Int = hidden.Hidden.value\n' > src/main/scala/Uses.scala
