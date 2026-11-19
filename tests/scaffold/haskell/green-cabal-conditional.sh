# expect: green
# An if block in a component, and a library module named SpecHook outside the test folder: only a
# SpecHook.hs under a test driver's folder is rejected.
perl -0pi -e 's/  exposed-modules: SampleTool\n/  exposed-modules:\n    SampleTool\n    SampleTool.SpecHook\n\n  if os(windows)\n    ghc-options: -threaded\n/' sample-tool.cabal
mkdir -p src/SampleTool
cat >src/SampleTool/SpecHook.hs <<'HS'
-- | Hooks that the tool runs around each rename.
module SampleTool.SpecHook (noHook) where

-- | Runs the action as it is.
noHook :: IO () -> IO ()
noHook action = action
HS
scripts/format >/dev/null 2>&1 || true
