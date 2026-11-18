# expect: green
# README and CODING_STANDARDS text that names switched-off checks, as docs do.
# shellcheck disable=SC2016 # the backquotes are Markdown, not command substitution
printf '\n## Never do this\n\n- `{-# OPTIONS_GHC -Wno-unused-imports #-}`\n- `{- HLINT ignore -}` or `ghc-options: -w`\n- `unsafePerformIO`\n' >>README.md
printf '\nDo not write `{-# ANN module "HLint: ignore" #-}`.\n' >>CODING_STANDARDS.md
