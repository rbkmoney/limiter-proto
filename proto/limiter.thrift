namespace java com.rbkmoney.limiter
namespace erlang limiter

include "base.thrift"

typedef string LimitID
typedef string PlanID
typedef i64    BatchID
typedef i64    AccountID
typedef string LimitRef
typedef i64    DomainRevision
typedef base.TimeZone TimeZone
typedef base.InvalidRequest InvalidRequest

/**
*  Описывает типы лимитов:
*  cash - валютный лимит - ассоциирован с изменением сумм в какой-либо валюте
*  count - счетный лимит - ассоциирован с количеством каких-либо операций в системе
*/
union Type {
   1: TypeCash cash
   2: TypeCount count
}

struct TypeCash {
    1: required base.CurrencySymbolicCode currency_sym_code
}

struct TypeCount {}

/**
*  Описывает период работы лимита. Период работы в данном случае означает временной отрезок,
*  связанный со значением лимита (счетом), в случае, когда изменение лимита попадает на новый временной отрезок
*  создается новое значение лимита (счет) связанное с этим отрезком.
*/

union WorkPeriod {
   1: WorkPeriodHour hour
   2: WorkPeriodDay day
   3: WorkPeriodMonth month
   4: WorkPeriodYear year
}

struct WorkPeriodHour {}
struct WorkPeriodDay {}
struct WorkPeriodMonth {}
struct WorkPeriodYear {}

struct Limit {
    1: required LimitID id
    2: required WorkPeriod work_period
    3: required Type type
    4: required TimeZone time_zone
    5: optional string description
}

union Unit {
   1: UnitCash cash
   2: UnitCount count
}

struct UnitCash {
    1: required base.Amount amount
    2: required base.CurrencySymbolicCode currency_sym_code
}

struct UnitCount {
    1: required base.Amount amount
}

struct CreateParams {
    1: required WorkPeriod work_period
    2: required Type type
    3: required TimeZone time_zone
    4: optional string description
}

/**
* Описывает единицу изменения лимита:
* id - id лимита, к которому применяется данное изменение
* units - набор изменений лимита
* create_params - если такого лимита нет или срок дейтсвия сублимита истек, то эти параметры
*                 будут использованы чтобы проинициализировать новый лимит/сублимит.
                  Так как мы не знаем существует ли лимит, то всегда прикладываем эти параметры.
*/
struct Change {
    1: required LimitID id
    2: required list<Unit> units
    3: required CreateParams create_params
}

struct Batch {
    1: required BatchID id
    2: required list<Change> changes
}

struct Plan {
    1: required PlanID id
    2: required list<Batch> batch_list
}

/**
* Описывает единицу изменения плана:
* id - id плана, к которому применяется данное изменение
* batch - набор изменений, который нужно добавить в план
* change_time - время проведения операции по изменению лимитов
*/
struct PlanChange {
    1: required PlanID id
    2: required Batch batch
    3: required base.Timestamp change_time
}

/**
* Описывает точку во времени жизни лимита:
* clock - время подсчета баланса лимитов
* change_time - время проведения операции по изменению лимитов
*/
struct LimitClock {
    1: required Clock clock
    2: required base.Timestamp change_time
}

/*** Структура данных, описывающая свойства накопленного значения лимита:
* id - номер счета (генерируется аккаунтером)
* own_amount - значение счёта с учётом только подтвержденных операций
* max_available_amount - максимально возможные доступные средства
* min_available_amount - минимально возможные доступные средства
* Где минимально возможные доступные средства - это объем средств с учетом подтвержденных и не подтвержденных
* операций в определённый момент времени в предположении, что все планы с батчами, где баланс этого счёта изменяется в
* отрицательную сторону, подтверждены, а планы, где баланс изменяется в положительную сторону,
* соответственно, отменены.
* Для максимального значения действует обратное условие.
*
* clock - время подсчета баланса
*/
struct Balance {
    1: required AccountID id
    2: required base.Amount own_amount
    3: required base.Amount max_available_amount
    4: required base.Amount min_available_amount
    5: required Clock clock
}

union Clock {
    1: VectorClock vector
    2: LatestClock latest
}

struct VectorClock {
    1: required base.Opaque state
}

struct LatestClock {
}

exception LimitNotFound {
    1: required LimitID limit_id
}

exception PlanNotFound {
    1: required PlanID plan_id
}

/**
* Возникает в случае, если переданы некорректные параметры в одном или нескольких изменениях лимита
*/
exception InvalidLimitParams {
    1: required map<Change, string> wrong_limits
}

exception ClockInFuture {}

service Limiter {
    LimitClock Hold(1: PlanChange plan_change) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitClock CommitPlan(1: Plan plan) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitClock RollbackPlan(1: Plan plan) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    Limit GetLimitByID(1: LimitID id) throws (1:LimitNotFound e1)
    Balance GetBalanceByID(1: LimitID id, 2: LimitClock clock) throws (1:LimitNotFound e1, 2: ClockInFuture e2)
}
