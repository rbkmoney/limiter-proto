include "base.thrift"
include "limiter.thrift"

namespace java com.rbkmoney.limiter.configurator
namespace erlang limiter_cfg

typedef base.ID LimitName

struct LimitCreateParams {
    1: optional LimitName name
}

struct LimitNameNotFound {}

exception InconsistentRequest {
    1: optional LimitNameNotFound limit_name_not_found
}

service Configurator {
    limiter.Limit Create(1: LimitCreateParams params) throws (
        1: InconsistentRequest e1,
        2: base.InvalidRequest e2
    )

    limiter.Limit Get(1: limiter.LimitID id, 2: base.Timestamp timestamp) throws (
        1: limiter.LimitNotFound e1,
        2: base.InvalidRequest e2
    )
}
