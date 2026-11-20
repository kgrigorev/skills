# expect: red Tests
# Machine.TestCase runs with settings of its own (all health checks off). tests/conftest.py asks
# for run_state_machine_as_test in a plain test instead, which uses the profile.
cat >tests/test_machine.py <<'PY'
"""A state machine as a TestCase."""

from hypothesis import strategies as st
from hypothesis.stateful import RuleBasedStateMachine, rule

from sample_tool.core import slug


class SlugMachine(RuleBasedStateMachine):
    """Feeds texts to slug."""

    @rule(text=st.text())
    def idempotent(self, text: str) -> None:
        """Slug twice is slug once."""
        assert slug(slug(text)) == slug(text)


TestSlugMachine = SlugMachine.TestCase
PY
