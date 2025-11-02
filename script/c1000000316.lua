--Nordic Relic Andvaranaut
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    --------------------------------
    --① Quick Effect: Synchro Summon (treated as Synchro)
    --------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.sccon)
    e1:SetTarget(s.sctg)
    e1:SetOperation(s.scop)
    c:RegisterEffect(e1)

    --------------------------------
    --② If you control an "Aesir" monster: Banish this card; destroy 1 card your opponent controls.
    --------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE+LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.descon2)
    e2:SetTarget(s.destg2)
    e2:SetOperation(s.desop2)
    c:RegisterEffect(e2)
end

--------------------------------
-- Generic filters
--------------------------------
function s.IsNordic(c) return c:IsSetCard(0x42) end
function s.IsAesir(c) return c:IsSetCard(0x4b) end

--------------------------------
--① Synchro Summon Effect
--------------------------------
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(s.IsAesir,tp,LOCATION_MZONE,0,1,nil)
end

function s.banishfilter(c)
    return (s.IsNordic(c) or s.IsAesir(c)) and c:IsMonster() 
        and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE)) 
        and c:IsAbleToRemove()
end

function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        local g=Duel.GetMatchingGroup(s.banishfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
        return #g>=2 and Duel.GetLocationCountFromEx(tp)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_MZONE+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.scop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.banishfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    if #g<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rg=g:Select(tp,2,3,nil)
    if #rg==0 then return end
    local lv=0
    for tc in aux.Next(rg) do lv=lv+tc:GetLevel() end
    if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==0 then return end

    Duel.BreakEffect()
    -- Buscar Synchro “Aesir” con ese nivel
    local sg=Duel.GetMatchingGroup(function(sc)
        return s.IsAesir(sc) and sc:IsType(TYPE_SYNCHRO) and sc:IsLevel(lv)
            and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
    end,tp,LOCATION_EXTRA,0,nil)

    if #sg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=sg:Select(tp,1,1,nil):GetFirst()
        if sc then
            Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
            sc:CompleteProcedure()
        end
    end
end

--------------------------------
--② Destruction Effect
--------------------------------
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.IsAesir,tp,LOCATION_MZONE,0,1,nil)
end

function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,tp,0)
end

function s.desop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end
