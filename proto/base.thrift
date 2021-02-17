namespace java com.rbkmoney.limiter.base

/**
 * Отметка во времени согласно RFC 3339.
 *
 * Строка должна содержать дату и время в UTC в следующем формате:
 * `2016-03-22T06:12:27Z`.
 */
typedef string Timestamp

/** Идентификатор объекта */
typedef string ID
typedef i32 ObjectID

/** Идентификатор некоторого события */
typedef i64 EventID

struct EventRange {
    1: optional EventID after
    2: optional i32     limit
}

/** ISO 4217 */
typedef string CurrencySymbolicCode

/** Сумма в минимальных денежных единицах. */
typedef i64 Amount

/** Значение ассоциации */
typedef string Tag

/** Внешний идентификатор (идентификатор в системе клиента) для сущностей системы. */
typedef ID ExternalID

typedef i64 DataRevision
typedef i64 PartyRevision

/**
 * Идентификатор валюты
 *
 * Украдено из https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L912
 */
struct CurrencyRef { 1: required CurrencySymbolicCode symbolic_code }

/**
 * Объём денежных средств
 *
 * Украдено из https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L70
 */
struct Cash {
    1: required Amount amount
    2: required CurrencyRef currency
}

struct CashRange {
    1: required CashBound upper
    2: required CashBound lower
}

union CashBound {
    1: Cash inclusive
    2: Cash exclusive
}

/**
 * Исключение, сигнализирующее о непригодных с точки зрения бизнес-логики входных данных
 */
exception InvalidRequest {
    /** Список пригодных для восприятия человеком ошибок во входных данных */
    1: required list<string> errors
}

