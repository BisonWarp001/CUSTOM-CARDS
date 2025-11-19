--Transcendental Legacy
local s,id=GetID()
function s.initial_effect(c)
    --Activity Counter: Special Summons NOT from Extra Deck
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

------------------------------------------------------------
-- Only count Summons that are NOT from the Extra Deck
------------------------------------------------------------
function s.counterfilter(c)
    return not c:IsSummonLocation(LOCATION_EXTRA)
end

------------------------------------------------------------
-- You have NOT Special Summoned from the Extra Deck this turn
------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

------------------------------------------------------------
-- Filters
------------------------------------------------------------

-- Monster to send from hand
function s.tgfilter(c)
    return c:IsMonster() and c:IsAbleToGrave()
end

-- Monster to Special Summon
function s.spfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelAbove(1)
end

-- Group check: sum of Levels ≤ lv
function s.spcheck(g,lv)
    return g:GetSum(Card.GetLevel) <= lv
end

------------------------------------------------------------
-- Target
------------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

------------------------------------------------------------
-- Operation
------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Send 1 monster from hand to GY
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g==0 then return end

    local tc=g:GetFirst()
    local lv=tc:GetLevel()

    if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end

    --------------------------------------------------------
    -- After this resolves: cannot Special Summon from Extra Deck
    --------------------------------------------------------
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    --------------------------------------------------------
    -- Special Summon from Deck with total Levels ≤ lv
    --------------------------------------------------------
    local dg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
    if #dg==0 then return end

    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    if ft > #dg then ft = #dg end

    -- Select monsters whose total Levels ≤ lv
    local sg=aux.SelectUnselectGroup(
        dg,e,tp,1,ft,
        function(g,...) return s.spcheck(g,lv) end,
        1,tp,HINTMSG_SPSUMMON
    )

    if #sg==0 then return end

    -- Special Summon them
    for sc in aux.Next(sg) do
        Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
    end

    Duel.SpecialSummonComplete()
end
