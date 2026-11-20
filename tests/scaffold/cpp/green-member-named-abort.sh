# expect: green
# Member functions named abort and terminate, declared, defined, qualified and called.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

void Job::abort() { running_ = false; }

int extra(int value) {
  CountedJob job;
  job.abort();
  return job.terminate() + value;
}

} // namespace sample_tool
C
cat >src/extra.hpp <<'H'
// Extra helpers.
#pragma once

namespace sample_tool {

// A job that can be stopped.
class Job {
public:
  virtual ~Job() = default;
  Job() = default;
  Job(const Job &) = default;
  Job(Job &&) = default;
  Job &operator=(const Job &) = default;
  Job &operator=(Job &&) = default;
  // Stops the job.
  virtual void abort();
  // Ends the job, and says how many steps ran.
  [[nodiscard]] virtual int terminate() const { return running_ ? 1 : 0; }

private:
  bool running_ = true;
};

// A job that counts one more step.
class CountedJob : public Job {
public:
  [[nodiscard]] int terminate() const override { return Job::terminate() + 1; }
};

// Returns a number.
[[nodiscard]] int extra(int value);

} // namespace sample_tool
H
include_extra_in_tests
add_tests <<'C'
TEST(Extra, CountsSteps) { EXPECT_EQ(sample_tool::extra(1), 2); }
C
fmt
