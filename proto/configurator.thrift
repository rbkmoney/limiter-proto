include "base.thrift"
include "limiter.thrift"

namespace java com.rbkmoney.limiter.configurator
namespace erlang limiter_cfg

typedef base.ID LimitName
typedef base.ID LimitID
typedef i64 ShardSize

struct LimitConfig {
    1: required LimitID id
    2: required base.Timestamp started_at
    3: required ShardSize shard_size
    4: optional base.Timestamp created_at
    5: optional string description
}

struct LimitCreateParams {
    1: required LimitID id
    2: required base.Timestamp started_at
    /** Идентификатор набора настроек создаваемого лимата, в будущем идентификатор заменит структура конфигурации */
    3: optional LimitName name
    4: optional string description
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
