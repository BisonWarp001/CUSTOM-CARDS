--Call from the Beyond
local s,id=GetID()
function s.initial_effect(c)
    --Limit to 1 copy on field
    c:SetUniqueOnField(1,0,id)

    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    c:RegisterEffect(e1)

    --Infinite hand while controlling Normal Summoned Slifer
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_HAND_LIMIT)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(1,0)
    e2:SetCondition(s.handcon)
    e2:SetValue(99)
    c:RegisterEffect(e2)

    --Draw 1 card for each monster Special Summoned from GY while controlling Normal Summoned Slifer
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e3:SetCondition(s.drawcon)
    e3:SetOperation(s.drawop)
    c:RegisterEffect(e3)
end

--Check if you control a Normal Summoned Slifer
function s.handcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsOriginalCode(10000020) and c:IsSummonType(SUMMON_TYPE_NORMAL)
    end,tp,LOCATION_MZONE,0,1,nil)
end

--Draw condition: monster Special Summoned from GY while controlling Normal Summoned Slifer
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
    return s.handcon(e) and eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_GRAVE) end,1,nil)
end

--Draw 1 card for each monster Special Summoned from GY
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(function(c) return c:IsPreviousLocation(LOCATION_GRAVE) end,nil)
    local ct=#g
    if ct>0 then
        Duel.Draw(tp,ct,REASON_EFFECT)
    end
end
