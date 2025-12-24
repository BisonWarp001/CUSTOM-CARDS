--The Chosen Pharaoh
local s,id=GetID()
function s.initial_effect(c)
    ------------------------------------------------------------
    -- (1) Discard 1 → Special Summon itself from hand/GY
    ------------------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    ------------------------------------------------------------
    -- (2) On Normal/Special Summon → Place “Divine Comeback”
    ------------------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.pctg)
    e2:SetOperation(s.pcop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    ------------------------------------------------------------
    -- (3) In GY: shuffle itself + 1 banished card → draw 1
    ------------------------------------------------------------
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,2})
    e4:SetTarget(s.dtg)
    e4:SetOperation(s.dop)
    c:RegisterEffect(e4)
end

------------------------------------------------------------
-- (1) Cost: discard 1 card
------------------------------------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

------------------------------------------------------------
-- (1) Special Summon itself
------------------------------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

------------------------------------------------------------
-- (2) Place Divine Comeback
------------------------------------------------------------
function s.dcfilter(c)
    return c:IsCode(1000000014) and c:IsSSetable()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.dcfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

------------------------------------------------------------
-- (3) Shuffle this + 1 banished card → draw 1
------------------------------------------------------------
function s.tdfilter(c)
    return c:IsFaceup() and c:IsAbleToDeck() and not c:IsCode(id)
end

function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil)
            and e:GetHandler():IsAbleToDeck()
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.dop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst()
    if not tc then return end

    local g=Group.FromCards(c,tc)
    if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==2 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
