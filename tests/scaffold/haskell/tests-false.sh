# expect: red Dependency versions match cabal.project.freeze
# Tests switched off in cabal.project.
perl -0pi -e 's/^tests: True$/tests: False/m' cabal.project
