--The Erradicator God
local s,id=GetID()
function s.initial_effect(c)
	local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE
    --① Activate: Special Summon "The Wicked Eraser" ignoring its Summoning conditions
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --② GY: Send opponent’s field to GY + burn
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost) --banish self as cost
    e2:SetTarget(s.sgtg)
    e2:SetOperation(s.sgop)
    c:RegisterEffect(e2)
end

s.listed_names={57793869} -- The Wicked Eraser

--① Special Summon target
function s.spfilter(c,e,tp)
    return c:IsCode(57793869) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if not tc then return end
    if Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP)==0 then return end

    --The Wicked Eraser effects cannot be negated
    local e1=Effect.CreateEffect(tc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)

    Duel.SpecialSummonComplete()
end

--② GY: Send all opponent's field to GY + damage
function s.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(function(c) return c:IsCode(57793869) end, tp, LOCATION_MZONE, 0, 1, nil)
            and Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end


function s.sgop(e,tp,eg,ep,ev,re,r,rp)
    -- Debes controlar a The Wicked Eraser para resolver
    if not Duel.IsExistingMatchingCard(function(c) return c:IsCode(57793869) end, tp, LOCATION_MZONE, 0, 1, nil) then return end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    if #g==0 then return end

    --Enviar todo al GY
    local ct=Duel.SendtoGrave(g,REASON_EFFECT)
    if ct>0 then
        Duel.Damage(1-tp,ct*500,REASON_EFFECT)
    end
end
