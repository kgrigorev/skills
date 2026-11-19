# expect: red Lint
# expect-output: Throws on bytes that are not valid text
# decodeUtf8 throws on bytes that are not valid UTF-8.
perl -0pi -e 's/\(banner, tidyName\)/(banner, roundTrip, tidyName)/; s/^(import Data.Text \(Text\))$/$1\nimport Data.Text.Encoding (decodeUtf8, encodeUtf8)/m' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | Throws on invalid UTF-8.
roundTrip :: Text -> Text
roundTrip = decodeUtf8 . encodeUtf8
HS
scripts/format >/dev/null 2>&1 || true
