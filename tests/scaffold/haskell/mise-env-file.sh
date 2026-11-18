# expect: red Lint
# mise.ci.toml with MISE_ENV=ci would put a fake hlint first. scripts/check unsets MISE_ENV, so
# the real HLint still runs and finds the partial function.
# env: MISE_ENV=ci
mkdir .tools
printf '#!/bin/sh\necho 3.10\n' >.tools/hlint
chmod +x .tools/hlint
printf '[env]\n_.path = ["{{config_root}}/.tools"]\n' >mise.ci.toml
perl -0pi -e 's/\(banner, tidyName\)/(banner, firstName, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | The first name.
firstName :: [Text] -> Text
firstName names = head names
HS
