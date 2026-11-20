# expect: green
# A new module with its own header, source and Unity test, the way AGENTS.md describes it.
cat >include/ledger.h <<'X'
/// Sums of ledger lines.
#ifndef LEDGER_H
#define LEDGER_H

#include <stddef.h>
#include <stdint.h>

/// The result of parsing one ledger line.
typedef enum ledger_status {
    LEDGER_OK,
    LEDGER_EMPTY,
    LEDGER_NOT_A_NUMBER,
    LEDGER_OUT_OF_RANGE,
} ledger_status;

/// Parses a signed amount in cents, such as "-1250", into `out`.
[[nodiscard]] ledger_status ledger_parse_cents(const char *line, int64_t *out);

/// Adds `count` amounts into `total`. Returns false and leaves `total` alone on overflow.
[[nodiscard]] bool ledger_sum(const int64_t *amounts, size_t count, int64_t *total);

#endif
X
cat >src/ledger.c <<'X'
/// Sums of ledger lines.
#include "ledger.h"

#include <errno.h>
#include <stdckdint.h>
#include <stdlib.h>

ledger_status ledger_parse_cents(const char *line, int64_t *out) {
    if (line[0] == '\0') {
        return LEDGER_EMPTY;
    }
    char *end = nullptr;
    errno = 0;
    const long long value = strtoll(line, &end, 10);
    if (end == line || *end != '\0') {
        return LEDGER_NOT_A_NUMBER;
    }
    if (errno == ERANGE) {
        return LEDGER_OUT_OF_RANGE;
    }
    *out = (int64_t)value;
    return LEDGER_OK;
}

bool ledger_sum(const int64_t *amounts, size_t count, int64_t *total) {
    int64_t sum = 0;
    for (size_t i = 0; i < count; i++) {
        if (ckd_add(&sum, sum, amounts[i])) {
            return false;
        }
    }
    *total = sum;
    return true;
}
X
cat >test/ledger_test.c <<'X'
/// Tests for ledger.c.
#include "ledger.h"

#include <stdint.h>
#include <unity.h>

void setUp(void) {}
void tearDown(void) {}

static void parses_negative_cents(void) {
    int64_t value = 0;
    TEST_ASSERT_EQUAL_INT(LEDGER_OK, ledger_parse_cents("-1250", &value));
    TEST_ASSERT_EQUAL_INT64(-1250, value);
}

static void rejects_trailing_text(void) {
    int64_t value = 7;
    TEST_ASSERT_EQUAL_INT(LEDGER_NOT_A_NUMBER, ledger_parse_cents("12x", &value));
    TEST_ASSERT_EQUAL_INT64(7, value);
}

static void rejects_empty_lines(void) {
    int64_t value = 0;
    TEST_ASSERT_EQUAL_INT(LEDGER_EMPTY, ledger_parse_cents("", &value));
}

static void sum_reports_overflow(void) {
    const int64_t amounts[] = {INT64_MAX, 1};
    int64_t total = 0;
    TEST_ASSERT_FALSE(ledger_sum(amounts, 2, &total));
    TEST_ASSERT_TRUE(ledger_sum(amounts, 1, &total));
    TEST_ASSERT_EQUAL_INT64(INT64_MAX, total);
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(parses_negative_cents);
    RUN_TEST(rejects_trailing_text);
    RUN_TEST(rejects_empty_lines);
    RUN_TEST(sum_reports_overflow);
    return UNITY_END();
}
X
perl -pi -e 's|add_library\(sample_tool src/sample_tool.c\)|add_library(sample_tool src/sample_tool.c src/ledger.c)|' CMakeLists.txt
perl -0pi -e 's/(  add_property_test)/  add_unity_test(ledger_test test\/ledger_test.c sample_tool)\n$1/' CMakeLists.txt
