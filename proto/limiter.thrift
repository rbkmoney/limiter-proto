include "base.thrift"
include "limiter_context.thrift"

namespace java com.rbkmoney.limiter
namespace erlang limiter

typedef base.ID LimitChangeID
typedef base.ID LimitID
typedef base.ID PartyID
typedef base.ID ShopID
typedef base.ID WalletID
typedef base.ID IdentityID
typedef limiter_context.LimitContext LimitContext

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
    1: VectorClock vector
}

union LimitBody {
    1: base.Cash cash
    2: base.Amount amount
}

union LimitBodyRange {
    1: base.CashRange cash
    2: base.AmountRange amount
}

struct Limit {
    1: required LimitID id
    2: required LimitBody body
    3: optional base.Timestamp creation_time
    4: optional string description
}

struct LimitChange {
    1: required LimitID id
    2: required LimitChangeID change_id
}

exception LimitNotFound {}
exception LimitChangeNotFound {}
exception ForbiddenOperationAmount {
    1: required LimitBody amount
    2: required LimitBodyRange allowed_range
}

service Limiter {
    Limit Get(1: LimitID id, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        2: base.InvalidRequest e2
    )
    Clock Hold(1: LimitChange change, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        3: base.InvalidRequest e2
    )
    Clock Commit(1: LimitChange change, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3,
        4: ForbiddenOperationAmount e4
    )
    Clock Rollback(1: LimitChange change, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3
    )
}
