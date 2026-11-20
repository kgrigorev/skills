# expect: green
# A new internal package with a sentinel error, wrapping, and a table test.
mkdir -p internal/money
cat >internal/money/money.go <<'GO'
// Package money adds amounts of cents without floating point.
package money

import (
	"errors"
	"fmt"
	"math"
)

// ErrOverflow says a sum does not fit in an int64.
var ErrOverflow = errors.New("money: sum overflows")

// Cents is an amount of money in cents.
type Cents int64

// Sum adds amounts and fails instead of wrapping around.
func Sum(amounts []Cents) (Cents, error) {
	var total Cents
	for i, a := range amounts {
		if (a > 0 && total > math.MaxInt64-a) || (a < 0 && total < math.MinInt64-a) {
			return 0, fmt.Errorf("amount %d: %w", i, ErrOverflow)
		}
		total += a
	}

	return total, nil
}
GO
cat >internal/money/money_test.go <<'GO'
// Tests for package money.
package money_test

import (
	"errors"
	"math"
	"testing"

	"example.com/sample-tool/internal/money"
)

// TestSum checks known sums, including an overflow.
func TestSum(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name    string
		amounts []money.Cents
		want    money.Cents
		wantErr error
	}{
		{name: "empty", amounts: nil, want: 0},
		{name: "two", amounts: []money.Cents{150, 250}, want: 400},
		{name: "negative", amounts: []money.Cents{100, -30}, want: 70},
		{name: "overflow", amounts: []money.Cents{math.MaxInt64, 1}, wantErr: money.ErrOverflow},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			got, err := money.Sum(tt.amounts)
			if !errors.Is(err, tt.wantErr) {
				t.Fatalf("Sum(%v) error = %v, want %v", tt.amounts, err, tt.wantErr)
			}
			if got != tt.want {
				t.Errorf("Sum(%v) = %d, want %d", tt.amounts, got, tt.want)
			}
		})
	}
}
GO
