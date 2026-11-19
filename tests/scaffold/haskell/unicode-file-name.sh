# expect: red Lint
# expect-output: src/Ä.hs
# A module whose file name is not ASCII: git prints the name quoted, so it dropped out of every
# file list, and its OPTIONS_GHC -w, head and unsafePerformIO went unseen.
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules:\n    SampleTool\n    \x{c3}\x{84}\n\n/' sample-tool.cabal
printf '{-# OPTIONS_GHC -w #-}\nmodule \303\204 (x) where\nimport System.IO.Unsafe (unsafePerformIO)\nx = head [unsafePerformIO (pure (1::Int))]\n' >"src/$(printf '\303\204').hs"
scripts/format >/dev/null 2>&1 || true
