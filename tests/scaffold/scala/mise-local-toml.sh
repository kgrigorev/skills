# expect: red Tools that run match mise.toml
# A mise.local.toml (gitignored) that picks another JDK. Force-added so the runner removes it.
printf '[tools]\njava = "temurin-21.0.11+10.0.LTS"\n' > mise.local.toml
git add -f mise.local.toml
