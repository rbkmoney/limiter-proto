/**
 * Временные интервалы
 */

namespace java   com.rbkmoney.limiter.range.time
namespace erlang time_range

include "base.thrift"

/// Domain

typedef base.ID LimitRangeID
typedef base.AccountID AccountID
typedef base.Timestamp Timestamp
typedef base.Amount IntervalAmount

union TimeRangeType {
    1: TimeRangeTypeCalendar calendar
    2: TimeRangeTypeInterval interval
}

union TimeRangeTypeCalendar {
    1: TimeRangeTypeCalendarYear year
    2: TimeRangeTypeCalendarMonth month
    3: TimeRangeTypeCalendarWeek week
    4: TimeRangeTypeCalendarDay day
}

struct TimeRangeTypeCalendarYear {}
struct TimeRangeTypeCalendarMonth {}
struct TimeRangeTypeCalendarWeek {}
struct TimeRangeTypeCalendarDay {}

struct TimeRangeTypeInterval {
    1: required IntervalAmount amount // in sec
}

struct TimeRange {
    1: required Timestamp upper
    2: required Timestamp lower
    3: optional AccountID account_id_from
    4: optional AccountID account_id_to
}
