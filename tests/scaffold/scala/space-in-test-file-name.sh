# expect: red Sources only in src/
# A test file name with a space that carries -Wconf.
printf '//> using options -Wconf:any:s\npackage sampletool\n' > 'src/test/scala/a b.scala'
