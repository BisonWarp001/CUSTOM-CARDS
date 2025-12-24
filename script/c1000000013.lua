--Gods' Hierarchy
local s,id=GetID()

function s.initial_effect(c)
    --Activate (Quick-Play style)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(0)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

s.listed_names={10000000,10000010,10000020,10000080,21208152,57793869,62180201}

--Monstruos válidos: Obelisk / Slifer / Ra no afectados aún
function s.filter(c)
    return c:IsFaceup()
        and c:IsOriginalCodeRule(10000000,10000010,10000020,10000080,21208152,57793869,62180201)
        and c:GetFlagEffect(id)==0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
    local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if not tc then return end

    local c=e:GetHandler()

    --Marcar como afectado por esta carta
    tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)

    -----------------------------------------------------------
    -- Sus efectos no pueden ser negados
    -----------------------------------------------------------
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CANNOT_DISABLE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e0)

    -----------------------------------------------------------
    -- HINT PRINCIPAL (solo 1)
    -----------------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetValue(aux.tgoval)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e1)

    -----------------------------------------------------------
    -- No puede ser destruido por efectos del oponente
    -----------------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(function(e,re)
        return re:GetOwnerPlayer()~=e:GetOwnerPlayer()
    end)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e2)

    -----------------------------------------------------------
    -- Inmune a efectos de monstruos del oponente
    -----------------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetValue(function(e,re)
        return re:IsActiveType(TYPE_MONSTER)
            and re:GetOwnerPlayer()~=e:GetOwnerPlayer()
    end)
    e3:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e3)
end
