# expect: green
# Non-ASCII text in strings, characters and comments, also next to "--" and quotes.
perl -0pi -e 's/\(banner, tidyName\)/(banner, arrow, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS2'

-- | An arrow for the output, and the Greek letter λ ('λ' is a Char). {- nested -}
arrow :: (Text, Char, Char)
arrow = ("→ «quoted» --", 'λ', '"')
HS2
scripts/format >/dev/null 2>&1 || true
