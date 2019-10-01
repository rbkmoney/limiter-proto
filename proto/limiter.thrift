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
union LimitType {
   1: LimitTypeCash cash
   2: LimitTypeCount count
}

struct LimitTypeCash {
    1: required base.CurrencySymbolicCode currency_sym_code
}

struct LimitTypeCount {}

union LimitWorkPeriod {
   1: LimitWorkPeriodHour hour
   2: LimitWorkPeriodDay day
   3: LimitWorkPeriodMonth month
   4: LimitWorkPeriodYear year
}

struct LimitWorkPeriodHour {}
struct LimitWorkPeriodDay {}
struct LimitWorkPeriodMonth {}
struct LimitWorkPeriodYear {}

struct Limit {
    1: required LimitID id
    2: required LimitWorkPeriod work_period
    3: required LimitType type
    4: required TimeZone time_zone
    5: optional string description
}

union LimitUnit {
   1: LimitUnitCash cash
   2: LimitUnitCount count
}

struct LimitUnitCash {
    1: required base.Amount amount
    2: required base.CurrencySymbolicCode currency_sym_code
}

struct LimitUnitCount {
    1: required base.Amount amount
}

struct LimitCreateParams {
    1: required LimitWorkPeriod work_period
    2: required LimitType type
    3: required TimeZone time_zone
}

/**
* Описывает единицу изменения лимита:
* id - id лимита, к которому применяется данное изменение
* units - набор изменений лимита
* create_params - если такого лимита нет или срок дейтсвия сублимита истек, то эти параметры
*                 будут использованы чтобы проинициализировать новый лимит/сублимит.
                  Так как мы не знаем существует ли лимит, то всегда прикладываем эти параметры.
*/
struct LimitChange {
    1: required LimitID id
    2: required list<LimitUnit> units
    3: required LimitCreateParams create_params
}

struct LimitBatch {
    1: required BatchID id
    2: required list<LimitChange> changes
}

struct LimitPlan {
    1: required PlanID id
    2: required list<LimitBatch> batch_list
}

/**
* Описывает единицу изменения плана:
* id - id плана, к которому применяется данное изменение
* batch - набор изменений, который нужно добавить в план
* change_time - время проведения операции по изменению лимитов
*/
struct LimitPlanChange {
    1: required PlanID id
    2: required LimitBatch batch
    3: required base.Timestamp change_time
}

/**
* Описывает точку во времени жизни лимита:
* clock - идентификатор изменения плана лимитов
* change_time - время проведения операции по изменению лимитов
*/
struct LimitClock {
    1: required Clock clock
    2: required base.Timestamp change_time
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

/*** Структура данных, описывающая свойства счета:
* id - номер сета (генерируется аккаунтером)
* own_amount - собственные средства (объём средств на счёте с учётом только подтвержденных операций)
* max_available_amount - максимально возможные доступные средства
* min_available_amount - минимально возможные доступные средства
* Где минимально возможные доступные средства - это объем средств с учетом подтвержденных и не подтвержденных
* операций в определённый момент времени в предположении, что все планы с батчами, где баланс этого счёта изменяется в
* отрицательную сторону, подтверждены, а планы, где баланс изменяется в положительную сторону,
* соответственно, отменены.
* Для максимального значения действует обратное условие.
*
* clock - время подсчета баланса
*У каждого счёта должна быть сериализованная история, то есть наблюдаемая любым клиентом в определённый момент времени
* последовательность событий в истории счёта должна быть идентична.
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
///////////////////////////////////////////////////////////////////////////////////////////////////////

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
    1: required map<LimitChange, string> wrong_limits
}

exception ClockInFuture {}

service Limiter {
    LimitClock Hold(1: LimitPlanChange plan_change) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitClock CommitPlan(1: LimitPlan plan) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitClock RollbackPlan(1: LimitPlan plan) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    Limit GetLimitByID(1: LimitID id) throws (1:LimitNotFound e1)
    Balance GetBalanceByID(1: LimitID id, 2: LimitClock clock) throws (1:LimitNotFound e1, 2: ClockInFuture e2)
}
