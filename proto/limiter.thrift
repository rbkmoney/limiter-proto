include "base.thrift"

namespace java com.rbkmoney.limiter
namespace erlang limiter

typedef base.ID LimitChangeID
typedef base.ID LimitID
typedef base.ID PartyID
typedef base.ID ShopID

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

struct LimitContext {
    1: optional PartyID party_id
    2: optional ShopID shop_id
    3: optional LimitBody partial_body
    4: optional base.Timestamp operation_timestamp
}

union LimitBody {
    1: base.Cash cash
    2: base.Amount amount
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
    3: required LimitBody body
}

exception LimitNotFound {}
exception LimitChangeNotFound {}

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
        3: base.InvalidRequest e3
    )
    Clock Rollback(1: LimitChange change, 2: Clock clock, 3: LimitContext context) throws (
        1: LimitNotFound e1,
        2: LimitChangeNotFound e2,
        3: base.InvalidRequest e3
    )
}
