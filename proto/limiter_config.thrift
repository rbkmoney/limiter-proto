/**
 * Машина хранящая конфигурацию лимита
 */

namespace java   com.rbkmoney.limiter.config
namespace erlang limiter_config

include "base.thrift"
include "time_range.thrift"

/// Domain

typedef base.ID LimitConfigID
typedef base.Timestamp Timestamp
typedef base.Amount ShardSize
typedef base.CurrencySymbolicCode CurrencySymbolicCode

struct LimitConfigParams {
    1: required LimitConfigID id
    2: required LimitBodyType body_type
    3: required Timestamp started_at
    4: required ShardSize shard_size
    5: required time_range.TimeRangeType time_range_type
    6: required LimitContextType context_type
    7: required LimitType type
    8: required set<LimitScope> scopes
    9: optional string description
    10: required OperationLimitBehaviour op_behaviour
}

struct LimitConfig {
    1: required LimitConfigID id
    2: required string processor_type
    3: required Timestamp created_at
    4: required LimitBodyType body_type
    5: required Timestamp started_at
    6: required ShardSize shard_size
    7: required time_range.TimeRangeType time_range_type
    11: required LimitContextType context_type
    8: optional LimitType type
    // Возможно, это поле так и останется т.к. конфиги создаются разово, и
    // помимо machinegun попадает и в kafka
    9: optional LimitScope scope_deprecated
    10: optional string description
    12: optional OperationLimitBehaviour op_behaviour
    13: optional set<LimitScope> scopes
}

struct OperationLimitBehaviour {
    1: optional OperationBehaviour invoice_payment_refund
}

union OperationBehaviour {
    1: Subtraction subtraction
    2: Addition addition
}

struct Subtraction {}
struct Addition {}

union LimitBodyType {
    1: LimitBodyTypeAmount amount
    2: LimitBodyTypeCash cash
}

struct LimitBodyTypeAmount {}
struct LimitBodyTypeCash {
    1: required CurrencySymbolicCode currency
}


union LimitType {
    1: LimitTypeTurnover turnover
}

struct LimitTypeTurnover {}

union LimitScope {
    1: LimitScopeGlobal scope_global
    2: LimitScopeType scope
}

struct LimitScopeGlobal {}

union LimitScopeType {
    1: LimitScopeTypeParty party
    2: LimitScopeTypeShop shop
    3: LimitScopeTypeWallet wallet
    4: LimitScopeTypeIdentity identity
}

struct LimitScopeTypeParty {}
struct LimitScopeTypeShop {}
struct LimitScopeTypeWallet {}
struct LimitScopeTypeIdentity {}

union LimitContextType {
    1: LimitContextTypePaymentProcessing payment_processing
}

struct LimitContextTypePaymentProcessing {}

/// LimitConfig events

struct TimestampedChange {
    1: required base.Timestamp occured_at
    2: required Change change
}

union Change {
    1: CreatedChange created
}

struct CreatedChange {
    1: required LimitConfig limit_config
}
