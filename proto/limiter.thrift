include "base.thrift"

namespace java com.rbkmoney.limiter
namespace erlang limiter

typedef base.ID LimitChangeID
typedef base.ID LimitID

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
    void Hold(1: LimitChange change) throws (
        1: LimitNotFound e1,
        3: base.InvalidRequest e2
    )
    void Commit(1: LimitChange change) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3
    )
    void PartialCommit(1: LimitChange change) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3,
        4: InconsistentRequest e4
    )
    void Rollback(1: LimitChange change) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3
    )
}
