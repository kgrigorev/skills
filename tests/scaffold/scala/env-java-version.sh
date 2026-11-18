# expect: red Tool pins in mise.toml and mise.lock
# env: MISE_JAVA_VERSION=21
# MISE_JAVA_VERSION picks another JDK than mise.toml. `mise install --locked` stops it there,
# because mise.lock has no entry for that JDK.
true
