# expect: green
# A member named abort, called from another member as this->abort().
. "$(dirname "$0")/lib/attack"
cat >src/job.hpp <<'H'
// A job that can be stopped.
#pragma once

namespace sample_tool {

// A job.
class Job {
public:
  // Stops the job.
  void abort() { running_ = false; }
  // Stops the job too.
  void stop() { this->abort(); }
  // Says whether the job runs.
  [[nodiscard]] bool running() const { return running_; }

private:
  bool running_ = true;
};

} // namespace sample_tool
H
perl -pi -e 's|^#include "sample_tool.hpp"$|#include "job.hpp"\n$&|' tests/sample_tool_test.cpp
add_tests <<'C'
TEST(Job, Stops) {
  sample_tool::Job job;
  job.stop();
  EXPECT_FALSE(job.running());
}
C
fmt
