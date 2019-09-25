namespace java com.rbkmoney.limiter
namespace erlang limiter

include "proto/shumpune.thrift"
include "proto/base.thrift"

typedef string LimitID
typedef string PlanID
typedef i64    BatchID
typedef i64    AccountID
typedef string LimitRef
typedef i64    DomainRevision
typedef string LimitTimeZone

typedef shumpune.Clock Clock
typedef shumpune.Balance Balance
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

enum LimitLifetime {
    hour
    day
    month
    year
}

/**
* Структура данных, описывающая свойства лимита:
* id -идентификатор машины лимита
* lifetime - время жизни лимита
* type - тип лимита
* time_zone - часовой пояс
* description - описание (неизменяемо после создания лимита)
*/
struct Limit {
    1: required LimitID id
    2: required LimitLifetime lifetime
    3: required LimitType type
    4: required LimitTimeZone time_zone
    5: optional string description
}

/**
*  Описывает одно изменение лимита в системе, может быть следующих типов:
*  cash - изменение валютного лимита
*  count - изменение счетного лимита
*/
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

/**
* Описывает параметры создания лимита:
* lifetime - время жизни лимита
* type - тип лимита
* time_zone - часовой пояс
*/
struct LimitCreateParams {
    1: required LimitLifetime lifetime
    2: required LimitType type
    3: required LimitTimeZone time_zone
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

/**
* Описывает батч - набор изменений лимитов, служит единицей атомарности операций в системе:
* id -  идентификатор набора, уникален в пределах плана
* changes - набор изменений лимитов
*/
struct LimitBatch {
    1: required BatchID id
    2: required list<LimitChange> changes
}

/**
 * План состоит из набора батчей, который можно пополнить, подтвердить или отменить:
 * id - идентификатор плана, уникален в рамках системы
 * batch_list - набор батчей, связанный с данным планом
*/
struct LimitPlan {
    1: required PlanID id
    2: required list<LimitBatch> batch_list
}

/**
* Описывает единицу изменения плана:
* id - id плана, к которому применяется данное изменение
* batch - набор изменений, который нужно добавить в план
* change_time - время изменения лимитов
*/
struct LimitPlanChange {
    1: required PlanID id
    2: required LimitBatch batch
    3: required base.Timestamp change_time
}

/**
* Описывает точку во времени жизни лимита:
* clock - идентификатор изменения плана лимитов
* change_time - время изменения лимитов
*/
struct LimitClock {
    1: required Clock clock
    2: required base.Timestamp change_time
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
    1: required map<LimitUnit, string> wrong_limits
}

exception ClockInFuture {}

service Limiter {
    LimitClock Hold(1: LimitPlanChange plan_change) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitClock CommitPlan(1: LimitPlan plan) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitClock RollbackPlan(1: LimitPlan plan) throws (1: InvalidLimitParams e1, 2: base.InvalidRequest e2)
    LimitPlan GetPlan(1: PlanID id) throws (1: PlanNotFound e1)
    Limit GetLimitByID(1: LimitID id) throws (1:LimitNotFound e1)
    Balance GetBalanceByID(1: LimitID id, 2: LimitClock clock) throws (1:LimitNotFound e1, 2: ClockInFuture e2)
}
