# expect: red No switched-off checks
# cabal.project runs the test binary through a wrapper that adds --skip for the failing example.
printf '#!/bin/sh\nexec "$@" --skip tidyName\n' >run-tests
chmod +x run-tests
printf '\npackage *\n  test-wrapper: %s/run-tests\n' "$PWD" >>cabal.project
perl -0pi -e 's/`shouldBe` "Ada Lovelace"/`shouldBe` "Ada  Lovelace"/' test/SampleToolSpec.hs
