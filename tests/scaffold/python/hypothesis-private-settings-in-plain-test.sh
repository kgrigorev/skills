# expect: red No switched-off checks
# Settings from hypothesis._settings passed to run_state_machine_as_test in a plain test: one
# step, random. The conftest check sees only @given tests.
cat >tests/test_machine.py <<'PY'
"""A state machine with one step."""

from hypothesis import strategies as st
from hypothesis._settings import settings as configure
from hypothesis.stateful import RuleBasedStateMachine, rule, run_state_machine_as_test

from sample_tool.core import slug


class SlugMachine(RuleBasedStateMachine):
    """Feeds texts to slug."""

    @rule(text=st.text())
    def idempotent(self, text: str) -> None:
        """Slug twice is slug once."""
        assert slug(slug(text)) == slug(text)


def test_slug_machine() -> None:
    run_state_machine_as_test(
        SlugMachine, settings=configure(stateful_step_count=1, derandomize=False)
    )
PY
