# expect: green
# A Hypothesis state machine run from a plain test, with the active profile.
cat >tests/test_machine.py <<'PY'
"""A state machine over slug."""

from hypothesis import strategies as st
from hypothesis.stateful import RuleBasedStateMachine, rule, run_state_machine_as_test

from sample_tool.core import slug


class SlugMachine(RuleBasedStateMachine):
    """Feeds texts to slug."""

    @rule(text=st.text())
    def idempotent(self, text: str) -> None:
        """Slug twice is slug once."""
        assert slug(slug(text)) == slug(text)


def test_slug_machine() -> None:
    run_state_machine_as_test(SlugMachine)
PY
