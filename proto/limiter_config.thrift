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
    9: optional LimitScope scope
    10: optional string description
    12: optional OperationLimitBehaviour op_behaviour
}

struct OperationLimitBehaviour {
    1: optional OperationBehaviour invoice
    2: optional OperationBehaviour invoice_adjustment
    3: optional OperationBehaviour invoice_payment
    4: optional OperationBehaviour invoice_payment_adjustment
    5: optional OperationBehaviour invoice_payment_refund
    6: optional OperationBehaviour invoice_payment_chargeback
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
