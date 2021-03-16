include "base.thrift"
include "limiter.thrift"

namespace java com.rbkmoney.limiter.configurator
namespace erlang limiter_cfg

typedef base.ID LimitName
typedef base.ID LimitID

struct LimitConfig {
    1: required LimitID id
    2: optional base.Timestamp created_at
    3: optional string description
}

struct LimitCreateParams {
    1: required LimitID id
    /** Идентификатор набора настроек создаваемого лимата, в будущем идентификатор заменит структура конфигурации */
    2: optional LimitName name
    3: optional string description
}

exception LimitConfigNameNotFound {}
exception LimitConfigNotFound {}

service Configurator {
    LimitConfig Create(1: LimitCreateParams params) throws (
        1: LimitConfigNameNotFound e1,
        2: base.InvalidRequest e2
    )

    LimitConfig Get(1: LimitID id) throws (
        1: LimitConfigNotFound e1,
        2: base.InvalidRequest e2
    )
}
