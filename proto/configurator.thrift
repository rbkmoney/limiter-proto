include "base.thrift"
include "limiter.thrift"
include "limiter_config.thrift"

namespace java com.rbkmoney.limiter.configurator
namespace erlang limiter_cfg

typedef base.ID LimitName
typedef limiter_config.LimitConfigID LimitConfigID
typedef limiter_config.ShardSize ShardSize
typedef limiter_config.LimitConfig LimitConfig
typedef limiter_config.LimitBodyType LimitBodyType
typedef limiter_config.OperationLimitBehaviour OperationLimitBehaviour

struct LimitCreateParams {
    1: required LimitConfigID id
    2: required base.Timestamp started_at
    /** Идентификатор набора настроек создаваемого лимата, в будущем идентификатор заменит структура конфигурации */
    3: optional LimitName name
    4: optional string description
    5: optional LimitBodyType body_type
    6: optional OperationLimitBehaviour op_behaviour
}

exception LimitConfigNameNotFound {}
exception LimitConfigNotFound {}

service Configurator {
    LimitConfig CreateLegacy(1: LimitCreateParams params) throws (
        1: LimitConfigNameNotFound e1,
        2: base.InvalidRequest e2
    )

    LimitConfig Create(1: limiter_config.LimitConfigParams params) throws (
        1: base.InvalidRequest e1
    )

    LimitConfig Get(1: LimitConfigID id) throws (
        1: LimitConfigNotFound e1,
        2: base.InvalidRequest e2
    )
}
