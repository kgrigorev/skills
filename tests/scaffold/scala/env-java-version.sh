# expect: red Tool pins in mise.toml and mise.lock
# env: MISE_JAVA_VERSION=21
# MISE_JAVA_VERSION picks another JDK than mise.toml. The pin step refuses any MISE_<TOOL>_VERSION.
true
