include "base.thrift"

namespace java com.rbkmoney.limiter.context
namespace erlang limiter_context

struct LimitContext {
    1: optional ContextPaymentProcessing payment_processing
}

/**
 * Контекст, получаемый из сервисов, реализующих один из интерфейсов протокола
 * https://github.com/rbkmoney/damsel/tree/master/proto/payment_processing.thrift
 * (например invoicing в hellgate)
 */
struct ContextPaymentProcessing {
    1: optional Invoice invoice
}

struct Invoice {
    1: optional string id
    2: optional Entity owner_id
    3: optional Entity shop_id
    4: optional base.Cash cost
    5: optional base.Timestamp created_at
    6: optional InvoicePayment effective_payment
    7: optional InvoiceAdjustment effective_adjustment
}

struct InvoiceAdjustment {
    1: optional string id
}

struct InvoicePayment {
    1: optional string id
    2: optional Entity owner_id
    3: optional Entity shop_id
    4: optional base.Cash cost
    11: optional base.Cash capture_cost
    5: optional base.Timestamp created_at
    6: optional InvoicePaymentFlow flow
    7: optional Payer payer
    8: optional InvoicePaymentAdjustment effective_adjustment
    9: optional InvoicePaymentRefund effective_refund
    10: optional InvoicePaymentChargeback effective_chargeback
}

/**
 * Процесс выполнения платежа.
 */
union InvoicePaymentFlow {
    1: InvoicePaymentFlowInstant instant
    2: InvoicePaymentFlowHold hold
}

struct InvoicePaymentFlowInstant {}
struct InvoicePaymentFlowHold {}

union Payer {
    1: PaymentResourcePayer payment_resource
    2: CustomerPayer customer
    3: RecurrentPayer recurrent
}

struct PaymentResourcePayer {}
struct CustomerPayer {}
struct RecurrentPayer {}

struct InvoicePaymentAdjustment {
    1: optional string id
    2: optional base.Timestamp created_at
}

struct InvoicePaymentRefund {
    1: optional string id
    2: optional base.Cash cost
    3: optional base.Timestamp created_at
}

struct InvoicePaymentChargeback {
    1: optional string id
    2: optional base.Timestamp created_at
    3: optional base.Cash levy
    4: optional base.Cash body
}

/**
 * Нечто уникально идентифицируемое.
 *
 * Рекомендуется использовать для обеспечения прямой совместимости, в случае
 * например, когда в будущем мы захотим расширить набор атрибутов какой-либо
 * сущности, добавив в неё что-то кроме идентификатора.
 */
struct Entity {
    1: optional string id
}
