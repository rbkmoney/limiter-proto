include "base.thrift"

namespace java com.rbkmoney.limiter
namespace erlang limiter

typedef base.ID LimitChangeID
typedef base.ID LimitID

/**
 * https://en.wikipedia.org/wiki/Vector_clock
 **/
struct VectorClock {
    1: required base.Opaque state
}

/**
* Структура, позволяющая установить причинно-следственную связь операций внутри сервиса
**/
union Clock {
    // для новых операций
    1: VectorClock vector
}

struct LimitPayload {
    1: optional base.Cash cash
}

struct Limit {
    1: required LimitID id
    2: required LimitPayload payload
    3: optional base.Timestamp creation_time
    4: optional string description
}

struct LimitChange {
   1: required LimitID id
   2: required LimitChangeID change_id
   3: required LimitPayload payload
   4: required base.Timestamp operation_timestamp
}

exception LimitNotFound {}
exception LimitChangeNotFound {}

struct ForbiddenOperationAmount {
    1: required base.Cash amount
    2: required base.CashRange allowed_range
}

exception InconsistentRequest {
    1: optional ForbiddenOperationAmount forbidden_operation_amount
}

service Limiter {
    Limit Get(1: LimitID id, 2: base.Timestamp timestamp) throws (
        1: LimitNotFound e1,
        2: base.InvalidRequest e2
    )
    Clock Hold(1: LimitChange change, 2: Clock clock) throws (
        1: LimitNotFound e1,
        3: base.InvalidRequest e2
    )
    Clock Commit(1: LimitChange change, 2: Clock clock) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3
    )
    Clock PartialCommit(1: LimitChange change, 2: Clock clock) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3,
        4: InconsistentRequest e4
    )
    Clock Rollback(1: LimitChange change, 2: Clock clock) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3
    )
}
