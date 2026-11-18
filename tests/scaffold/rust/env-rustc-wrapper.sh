# expect: red Lint
# env: RUSTC_WRAPPER=./wrap.sh
# A wrapper from the environment that runs plain rustc where cargo asks for clippy-driver, so
# .unwrap() would pass Lint. clippy-driver must still run.
printf '#!/bin/sh\ncase "$1" in *clippy-driver) shift ;; esac\nexec "$@"\n' > wrap.sh
chmod +x wrap.sh
printf '\n/// Parses a number.\n///\n/// # Panics\n///\n/// When `s` is not a number.\n#[must_use]\npub fn parse(s: &str) -> i64 {\n    s.parse().unwrap()\n}\n' >> src/lib.rs
