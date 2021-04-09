/**
 * Машина хранящая временные интервалы
 */

namespace java   com.rbkmoney.limiter.range
namespace erlang limiter_range

include "base.thrift"
include "time_range.thrift"

/// Domain

typedef base.ID LimitRangeID
typedef base.Timestamp Timestamp

struct LimitRange {
    1: required LimitRangeID id
    2: required time_range.TimeRangeType type
    3: required Timestamp created_at
    4: optional base.CurrencySymbolicCode currency
}

struct LimitRangeState {
    1: required LimitRangeID id
    2: required time_range.TimeRangeType type
    3: required Timestamp created_at
    4: optional list<time_range.TimeRange> ranges
    5: optional base.CurrencySymbolicCode currency
}

/// LimitRange events

struct TimestampedChange {
    1: required base.Timestamp occured_at
    2: required Change change
}

union Change {
    1: CreatedChange created
    2: TimeRangeCreatedChange time_range_created
}

struct CreatedChange {
    1: required LimitRange limit_range
}

struct TimeRangeCreatedChange {
    1: required time_range.TimeRange time_range
}
