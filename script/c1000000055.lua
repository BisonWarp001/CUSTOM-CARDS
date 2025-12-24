--Wrath of Orichalcos
local s,id=GetID()

function s.initial_effect(c)
    --Negate Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SPSUMMON)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Negate monster effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_CHAINING)
    e2:SetCondition(s.discon)
    e2:SetTarget(s.distg)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
end

-------------------------------------------------
-- Check Orichalcos on field
-------------------------------------------------
function s.orifilter(c)
    return c:IsSetCard(0x3e8)
end
function s.condition(e,tp)
    return Duel.IsExistingMatchingCard(s.orifilter,tp,LOCATION_ONFIELD,0,1,nil)
end

-------------------------------------------------
-- Negate Special Summon
-------------------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateSummon(eg)
    for tc in eg:Iter() do
        if Duel.Destroy(tc,REASON_EFFECT)>0 then
            s.apply_disable(e,tc)
        end
    end
end

-------------------------------------------------
-- Negate monster effect
-------------------------------------------------
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return s.condition(e,tp)
        and re:IsActiveType(TYPE_MONSTER)
        and Duel.IsChainNegatable(ev)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local tc=re:GetHandler()
    if Duel.NegateActivation(ev) and tc:IsRelateToEffect(re) then
        if Duel.Destroy(tc,REASON_EFFECT)>0 then
            s.apply_disable(e,tc)
        end
    end
end

-------------------------------------------------
-- Disable effects until End Phase
-------------------------------------------------
function s.apply_disable(e,tc)
    if not tc:IsFaceup() then return end
    local c=e:GetHandler()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(e2)
end
