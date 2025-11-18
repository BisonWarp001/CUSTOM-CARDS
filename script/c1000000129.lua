--God's Fury (versión final sin bloqueo de tributo)
local s,id=GetID()
local PROT=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE
s.listed_names={10000000,10000010,10000020} -- Slifer, Obelisk, Ra

function s.initial_effect(c)
    -------------------------------------
    -- ACTIVACIÓN NO NEGABLE
    -------------------------------------
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetProperty(PROT)
    c:RegisterEffect(e0)

    c:SetUniqueOnField(1,0,id)

    -------------------------------------
    -- EFECTO 1: PROTECCIÓN A LOS DIOSES
    -------------------------------------

    -- Inmunidad a efectos activados del oponente
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetProperty(PROT)
    e1:SetTarget(s.godfilter)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)

    -- El oponente NO puede usarlos como material (Fusion, Synchro, XYZ, Link, Ritual)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(PROT)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.godfilter)
    e2:SetValue(function(e,tc,tp)
        return tp~=e:GetHandlerPlayer() -- solo el oponente
    end)
    c:RegisterEffect(e2)

    -- El oponente NO puede tomar control de ellos
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(PROT)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.godfilter)
    c:RegisterEffect(e3)

    -------------------------------------
    -- EFECTO 2: REEMPLAZO AL DEJAR EL CAMPO
    -------------------------------------
    -- Si fuera a dejar el campo por efecto, destierra 1 monstruo del GY en su lugar.
    local erep=Effect.CreateEffect(c)
    erep:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    erep:SetCode(EFFECT_SEND_REPLACE)
    erep:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    erep:SetRange(LOCATION_SZONE)
    erep:SetTarget(s.reptg)
    erep:SetOperation(s.repop)
    c:RegisterEffect(erep)
end

-------------------------------------
-- Funciones auxiliares
-------------------------------------

function s.isgod(c)
    local code=c:GetOriginalCode()
    return code==10000000 or code==10000010 or code==10000020
end

function s.godfilter(e,c)
    return c:IsFaceup() and s.isgod(c)
end

-- Inmunidad a efectos activados del oponente
function s.immval(e,te)
    return te:IsActivated() and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.rmfilter(c)
    return c:IsMonster() and c:IsAbleToRemove()
end

-------------------------------------
-- Reemplazo: Target
-------------------------------------
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        if not c:IsOnField() then return false end
        if not c:IsReason(REASON_EFFECT) then return false end
        local re0=c:GetReasonEffect()
        if not re0 then return false end
        if not (re0:IsActiveType(TYPE_MONSTER) or re0:IsActiveType(TYPE_SPELL) or re0:IsActiveType(TYPE_TRAP)) then
            return false
        end
        return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    return Duel.SelectYesNo(tp,aux.Stringid(id,0))
end

-------------------------------------
-- Reemplazo: Operación
-------------------------------------
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,id)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end
