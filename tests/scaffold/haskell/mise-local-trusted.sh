# expect: red Pinned tools
# The same shim, with every config trusted, as CI trusts the whole workspace.
# env: MISE_TRUSTED_CONFIG_PATHS=/
mkdir .tools
printf '#!/bin/sh\necho 3.10\n' >.tools/hlint
chmod +x .tools/hlint
printf '[env]\n_.path = ["{{config_root}}/.tools"]\n' >mise.local.toml
