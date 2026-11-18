# expect: red Dependency versions match cabal.project.freeze
# A hand-edited freeze file.
perl -0pi -e 's/any\.splitmix ==\S+,/any.splitmix ==0.1.3.1,/' cabal.project.freeze
grep -q 'splitmix ==0.1.3.1' cabal.project.freeze
